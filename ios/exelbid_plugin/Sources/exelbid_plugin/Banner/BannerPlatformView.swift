import ExelBidSDK
import Flutter
import UIKit

final class BannerPlatformView: NSObject, FlutterPlatformView, FlutterStreamHandler {

    private let containerView: UIView
    private var bannerAd: EBBannerAd?
    private var eventSink: FlutterEventSink?
    private let eventChannel: FlutterEventChannel
    private let methodChannel: FlutterMethodChannel

    init(frame: CGRect, viewId: Int64, arguments: [String: Any],
         messenger: FlutterBinaryMessenger) {
        let container = UIView(frame: frame)
        container.backgroundColor = .clear
        self.containerView = container

        self.methodChannel = FlutterMethodChannel(
            name: ChannelNames.Banner.method(forViewId: viewId),
            binaryMessenger: messenger
        )
        self.eventChannel = FlutterEventChannel(
            name: ChannelNames.Banner.events(forViewId: viewId),
            binaryMessenger: messenger
        )

        super.init()

        self.eventChannel.setStreamHandler(self)
        self.methodChannel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call: call, result: result)
        }
        setupBanner(arguments: arguments)
    }

    deinit {
        bannerAd?.stop()
        bannerAd?.removeFromSuperview()
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

    // MARK: - Method channel

    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "load":
            bannerAd?.load()
        case "stop":
            bannerAd?.stop()
        default:
            result(FlutterMethodNotImplemented)
            return
        }
        result(nil)
    }

    // MARK: - Banner setup

    private func setupBanner(arguments: [String: Any]) {
        let adUnitId = arguments["adUnitId"] as? String ?? ""
        let width = arguments["width"] as? Double ?? 320
        let height = arguments["height"] as? Double ?? 50
        let autoRefresh = arguments["autoRefresh"] as? Bool ?? true
        let autoLoad = arguments["autoLoad"] as? Bool ?? true
        let fullWebView = arguments["fullWebView"] as? Bool ?? false
        let optionsMap = arguments["options"] as? [String: Any]

        let banner = EBBannerAd(adUnitId: adUnitId, size: CGSize(width: width, height: height))
        banner.options = AdOptionsMapper.decode(optionsMap)
        banner.autoRefresh = autoRefresh
        banner.fullWebView = fullWebView
        wireCallbacks(banner: banner)

        containerView.addSubview(banner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: containerView.topAnchor),
            banner.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            banner.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])

        self.bannerAd = banner
        if autoLoad {
            banner.load()
        }
    }

    private func wireCallbacks(banner: EBBannerAd) {
        banner.onLoad = { [weak self] in
            self?.send(["event": "onLoad"])
        }
        banner.onFailureBlock = { [weak self] error in
            self?.send([
                "event": "onFail",
                "error": AdErrorMapper.encode(error as NSError),
            ])
        }
        banner.onClick = { [weak self] in
            self?.send(["event": "onClick"])
        }
        banner.onLeaveApp = { [weak self] in
            self?.send(["event": "onLeaveApp"])
        }
        banner.onClickFinish = { [weak self] in
            self?.send(["event": "onClickFinish"])
        }
    }

    private func send(_ payload: [String: Any]) {
        // Event channel sinks must be invoked on the main thread.
        if Thread.isMainThread {
            eventSink?(payload)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.eventSink?(payload)
            }
        }
    }
}
