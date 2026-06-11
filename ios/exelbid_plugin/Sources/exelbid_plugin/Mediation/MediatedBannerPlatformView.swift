import ExelBidSDK
import Flutter
import UIKit

/// Hosts an `ExelBidSDK.EBMediatedBannerAd` (a `UIView`) inside a Flutter
/// platform view. Mirrors `BannerPlatformView`, but mediation has no
/// `autoRefresh`; instead it reports waterfall progress and the winning
/// network over the per-view `EventChannel`.
final class MediatedBannerPlatformView: NSObject, FlutterPlatformView, FlutterStreamHandler {

    private let containerView: UIView
    private var bannerAd: EBMediatedBannerAd?
    private var eventSink: FlutterEventSink?
    private let eventChannel: FlutterEventChannel

    init(frame: CGRect, viewId: Int64, arguments: [String: Any],
         messenger: FlutterBinaryMessenger) {
        let container = UIView(frame: frame)
        container.backgroundColor = .clear
        self.containerView = container

        self.eventChannel = FlutterEventChannel(
            name: ChannelNames.MediatedBanner.events(forViewId: viewId),
            binaryMessenger: messenger
        )

        super.init()

        self.eventChannel.setStreamHandler(self)
        setupBanner(arguments: arguments)
    }

    deinit {
        bannerAd?.stop()
        bannerAd?.removeFromSuperview()
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

    // MARK: - Banner setup

    private func setupBanner(arguments: [String: Any]) {
        let adUnitId = arguments["adUnitId"] as? String ?? ""
        let width = arguments["width"] as? Double ?? 320
        let height = arguments["height"] as? Double ?? 50
        let autoLoad = arguments["autoLoad"] as? Bool ?? true
        let perNetworkTimeout = arguments["perNetworkTimeout"] as? Double
        let optionsMap = arguments["options"] as? [String: Any]

        let banner = EBMediatedBannerAd(
            adUnitId: adUnitId,
            size: CGSize(width: width, height: height)
        )
        banner.options = AdOptionsMapper.decode(optionsMap)
        if let perNetworkTimeout = perNetworkTimeout {
            banner.perNetworkTimeout = perNetworkTimeout
        }
        banner.rootViewControllerProvider = { TopViewController.find() }
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

    private func wireCallbacks(banner: EBMediatedBannerAd) {
        banner.onLoad = { [weak self, weak banner] in
            var payload: [String: Any] = ["event": "onLoad"]
            if let network = banner?.winningNetwork {
                payload["winningNetwork"] = network
            }
            self?.send(payload)
        }
        banner.onFailureBlock = { [weak self] error in
            self?.send([
                "event": "onFail",
                "error": AdErrorMapper.encode(error as NSError),
            ])
        }
        banner.onWaterfallEvent = { [weak self] event in
            self?.send([
                "event": "onWaterfall",
                "waterfall": WaterfallEventMapper.encode(event),
            ])
        }
        banner.onClick = { [weak self] in self?.send(["event": "onClick"]) }
        banner.onLeaveApp = { [weak self] in self?.send(["event": "onLeaveApp"]) }
        banner.onClickFinish = { [weak self] in self?.send(["event": "onClickFinish"]) }
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
