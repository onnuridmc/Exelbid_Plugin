import ExelBidSDK
import Flutter
import UIKit

/// Mediated native ad platform view. Mirrors `NativeAdPlatformView` but drives
/// an `ExelBidSDK.EBMediatedNativeAdLoader` / `EBMediatedNativeAd`, reporting the
/// per-step waterfall via `onWaterfall` and the winning network alongside
/// `onLoad`.
final class MediatedNativeAdPlatformView: NSObject, FlutterPlatformView, FlutterStreamHandler {

    private let containerView: UIView
    private let renderingView: SlotNativeRenderingView
    private let methodChannel: FlutterMethodChannel
    private let eventChannel: FlutterEventChannel
    private var loader: EBMediatedNativeAdLoader?
    private var nativeAd: EBMediatedNativeAd?
    private var eventSink: FlutterEventSink?

    init(frame: CGRect, viewId: Int64, arguments: [String: Any],
         messenger: FlutterBinaryMessenger) {
        let container = UIView(frame: frame)
        container.backgroundColor = .clear
        self.containerView = container
        self.renderingView = SlotNativeRenderingView()

        self.methodChannel = FlutterMethodChannel(
            name: ChannelNames.MediatedNative.method(forViewId: viewId),
            binaryMessenger: messenger
        )
        self.eventChannel = FlutterEventChannel(
            name: ChannelNames.MediatedNative.events(forViewId: viewId),
            binaryMessenger: messenger
        )

        super.init()

        self.eventChannel.setStreamHandler(self)
        self.methodChannel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call: call, result: result)
        }
        installRenderingView()
        startLoad(arguments: arguments)
    }

    deinit {
        if let ad = nativeAd {
            Task { @MainActor in
                ad.detach()
            }
        }
        methodChannel.setMethodCallHandler(nil)
        eventChannel.setStreamHandler(nil)
    }

    // MARK: - FlutterPlatformView

    func view() -> UIView { containerView }

    // MARK: - FlutterStreamHandler

    func onListen(withArguments arguments: Any?,
                  eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    // MARK: - Method channel (slot frames)

    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setTitleView":
            renderingView.setTitleView(call)
        case "setDescriptionView":
            renderingView.setDescriptionView(call)
        case "setMediaView":
            renderingView.setMediaView(call)
        case "setIconImageView":
            renderingView.setIconImageView(call)
        case "setCallToActionView":
            renderingView.setCallToActionView(call)
        case "setSponsoredView":
            renderingView.setSponsoredView(call)
        case "setDisplayUrlView":
            renderingView.setDisplayUrlView(call)
        case "setLogoImageView":
            renderingView.setLogoImageView(call)
        case "setPrivacyInformationIconImage":
            renderingView.setPrivacyInformationIconImage(call)
        default:
            result(FlutterMethodNotImplemented)
            return
        }
        result(nil)
    }

    // MARK: - Rendering view wiring

    private func installRenderingView() {
        renderingView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(renderingView)
        NSLayoutConstraint.activate([
            renderingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            renderingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            renderingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            renderingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }

    // MARK: - Load

    private func startLoad(arguments: [String: Any]) {
        let adUnitId = arguments["adUnitId"] as? String ?? ""
        let optionsMap = arguments["options"] as? [String: Any]
        let desiredRaw = arguments["desiredAssets"] as? [Int] ?? []
        let perNetworkTimeout = arguments["perNetworkTimeout"] as? Double

        let loader = EBMediatedNativeAdLoader(adUnitId: adUnitId)
        loader.options = AdOptionsMapper.decode(optionsMap)
        loader.desiredAssets = Set(desiredRaw.compactMap { EBNativeAsset(rawValue: $0) })
        if let perNetworkTimeout = perNetworkTimeout {
            loader.perNetworkTimeout = perNetworkTimeout
        }
        loader.rootViewControllerProvider = { TopViewController.find() }
        loader.onWaterfallEvent = { [weak self] event in
            self?.send([
                "event": "onWaterfall",
                "waterfall": WaterfallEventMapper.encode(event),
            ])
        }
        self.loader = loader

        loader.load { [weak self] ad, error in
            DispatchQueue.main.async {
                self?.handleLoadResult(ad: ad, error: error)
            }
        }
    }

    private func handleLoadResult(ad: EBMediatedNativeAd?, error: NSError?) {
        if let error = error {
            send([
                "event": "onFail",
                "error": AdErrorMapper.encode(error),
            ])
            return
        }
        guard let ad = ad else {
            send([
                "event": "onFail",
                "error": ["code": 0, "message": "Mediated native ad returned nil without error"],
            ])
            return
        }

        wireCallbacks(on: ad)
        ad.presenterProvider = { TopViewController.find() }
        Task { @MainActor [renderingView] in
            _ = ad.attach(to: renderingView)
        }
        self.nativeAd = ad

        var payload: [String: Any] = ["event": "onLoad"]
        payload["winningNetwork"] = ad.winningNetwork
        payload["data"] = NativeAdDataMapper.encode(ad)
        send(payload)
    }

    private func wireCallbacks(on ad: EBMediatedNativeAd) {
        ad.onImpression    = { [weak self] in self?.send(["event": "onImpression"]) }
        ad.onImpression50  = { [weak self] in self?.send(["event": "onImpression50"]) }
        ad.onImpression100 = { [weak self] in self?.send(["event": "onImpression100"]) }
        ad.onClick         = { [weak self] in self?.send(["event": "onClick"]) }
        ad.onLeaveApp      = { [weak self] in self?.send(["event": "onLeaveApp"]) }
        ad.onClickFinish   = { [weak self] in self?.send(["event": "onClickFinish"]) }
    }

    private func send(_ payload: [String: Any]) {
        if Thread.isMainThread {
            eventSink?(payload)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.eventSink?(payload)
            }
        }
    }
}
