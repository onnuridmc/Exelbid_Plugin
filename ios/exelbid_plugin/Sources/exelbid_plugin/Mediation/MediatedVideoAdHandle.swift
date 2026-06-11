import ExelBidSDK
import Flutter
import UIKit

/// Per-instance handle for `ExelBidSDK.EBMediatedVideoAd`. Mirrors
/// `VideoAdHandle`, adding waterfall events and the winning network (reported
/// with `onLoad`). Owns its method + event channels; retained by
/// `InstanceRegistry` until Dart calls `dispose`.
final class MediatedVideoAdHandle: NSObject, FlutterStreamHandler {

    private let id: String
    private let videoAd: EBMediatedVideoAd
    private let methodChannel: FlutterMethodChannel
    private let eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?

    init(id: String, adUnitId: String, options: [String: Any]?,
         perNetworkTimeout: Double?, messenger: FlutterBinaryMessenger) {
        self.id = id
        self.videoAd = EBMediatedVideoAd(adUnitId: adUnitId)
        self.videoAd.options = AdOptionsMapper.decode(options)
        if let perNetworkTimeout = perNetworkTimeout {
            self.videoAd.perNetworkTimeout = perNetworkTimeout
        }
        self.methodChannel = FlutterMethodChannel(
            name: ChannelNames.MediatedVideo.method(forId: id),
            binaryMessenger: messenger
        )
        self.eventChannel = FlutterEventChannel(
            name: ChannelNames.MediatedVideo.events(forId: id),
            binaryMessenger: messenger
        )

        super.init()

        videoAd.rootViewControllerProvider = { TopViewController.find() }
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
            videoAd.load()
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
            Task { @MainActor [videoAd] in
                videoAd.present(from: controller)
            }
            result(nil)

        case "isReady":
            result(videoAd.isReady)

        case "stop":
            videoAd.stop()
            result(nil)

        case "dispose":
            videoAd.stop()
            InstanceRegistry.shared.remove(id: id)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Callback wiring

    private func wireCallbacks() {
        videoAd.onLoad = { [weak self, weak videoAd] in
            var payload: [String: Any] = ["event": "onLoad"]
            if let network = videoAd?.winningNetwork {
                payload["winningNetwork"] = network
            }
            self?.send(payload)
        }
        videoAd.onFailureBlock = { [weak self] error in
            self?.send([
                "event": "onFail",
                "error": AdErrorMapper.encode(error as NSError),
            ])
        }
        videoAd.onWaterfallEvent = { [weak self] event in
            self?.send([
                "event": "onWaterfall",
                "waterfall": WaterfallEventMapper.encode(event),
            ])
        }
        videoAd.onProgress = { [weak self] percent in
            self?.send(["event": "onProgress", "percent": percent])
        }
        videoAd.onWillAppear    = { [weak self] in self?.send(["event": "onWillAppear"]) }
        videoAd.onDidAppear     = { [weak self] in self?.send(["event": "onDidAppear"]) }
        videoAd.onWillDisappear = { [weak self] in self?.send(["event": "onWillDisappear"]) }
        videoAd.onDidDisappear  = { [weak self] in self?.send(["event": "onDidDisappear"]) }
        videoAd.onClick         = { [weak self] in self?.send(["event": "onClick"]) }
        videoAd.onLeaveApp      = { [weak self] in self?.send(["event": "onLeaveApp"]) }
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
