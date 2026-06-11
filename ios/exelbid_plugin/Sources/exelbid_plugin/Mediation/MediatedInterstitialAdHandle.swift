import ExelBidSDK
import Flutter
import UIKit

/// Per-instance handle for `ExelBidSDK.EBMediatedInterstitialAd`. Mirrors
/// `InterstitialAdHandle`, adding waterfall events and the winning network
/// (reported with `onLoad`).
final class MediatedInterstitialAdHandle: NSObject, FlutterStreamHandler {

    private let id: String
    private let interstitialAd: EBMediatedInterstitialAd
    private let methodChannel: FlutterMethodChannel
    private let eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?

    init(id: String, adUnitId: String, options: [String: Any]?,
         perNetworkTimeout: Double?, messenger: FlutterBinaryMessenger) {
        self.id = id
        self.interstitialAd = EBMediatedInterstitialAd(adUnitId: adUnitId)
        self.interstitialAd.options = AdOptionsMapper.decode(options)
        if let perNetworkTimeout = perNetworkTimeout {
            self.interstitialAd.perNetworkTimeout = perNetworkTimeout
        }
        self.methodChannel = FlutterMethodChannel(
            name: ChannelNames.MediatedInterstitial.method(forId: id),
            binaryMessenger: messenger
        )
        self.eventChannel = FlutterEventChannel(
            name: ChannelNames.MediatedInterstitial.events(forId: id),
            binaryMessenger: messenger
        )

        super.init()

        interstitialAd.rootViewControllerProvider = { TopViewController.find() }
        wireCallbacks()
        eventChannel.setStreamHandler(self)
        methodChannel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call: call, result: result)
        }
    }

    deinit {
        methodChannel.setMethodCallHandler(nil)
        eventChannel.setStreamHandler(nil)
    }

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

    // MARK: - Methods

    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "load":
            interstitialAd.load()
            result(nil)

        case "present":
            guard let controller = TopViewController.find() else {
                result(FlutterError(
                    code: "no_presenter",
                    message: "Could not find a UIViewController to present from.",
                    details: nil
                ))
                return
            }
            Task { @MainActor [interstitialAd] in
                interstitialAd.present(from: controller)
            }
            result(nil)

        case "isReady":
            result(interstitialAd.isReady)

        case "stop":
            interstitialAd.stop()
            result(nil)

        case "dispose":
            interstitialAd.stop()
            InstanceRegistry.shared.remove(id: id)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Callback wiring

    private func wireCallbacks() {
        interstitialAd.onLoad = { [weak self, weak interstitialAd] in
            var payload: [String: Any] = ["event": "onLoad"]
            if let network = interstitialAd?.winningNetwork {
                payload["winningNetwork"] = network
            }
            self?.send(payload)
        }
        interstitialAd.onFailureBlock = { [weak self] error in
            self?.send([
                "event": "onFail",
                "error": AdErrorMapper.encode(error as NSError),
            ])
        }
        interstitialAd.onWaterfallEvent = { [weak self] event in
            self?.send([
                "event": "onWaterfall",
                "waterfall": WaterfallEventMapper.encode(event),
            ])
        }
        interstitialAd.onWillAppear    = { [weak self] in self?.send(["event": "onWillAppear"]) }
        interstitialAd.onDidAppear     = { [weak self] in self?.send(["event": "onDidAppear"]) }
        interstitialAd.onWillDisappear = { [weak self] in self?.send(["event": "onWillDisappear"]) }
        interstitialAd.onDidDisappear  = { [weak self] in self?.send(["event": "onDidDisappear"]) }
        interstitialAd.onClick         = { [weak self] in self?.send(["event": "onClick"]) }
        interstitialAd.onLeaveApp      = { [weak self] in self?.send(["event": "onLeaveApp"]) }
        interstitialAd.onClickFinish   = { [weak self] in self?.send(["event": "onClickFinish"]) }
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
