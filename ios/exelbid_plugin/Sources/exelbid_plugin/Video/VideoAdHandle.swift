import ExelBidSDK
import Flutter
import UIKit

final class VideoAdHandle: NSObject, FlutterStreamHandler {

    private let id: String
    private let videoAd: EBVideoAd
    private let methodChannel: FlutterMethodChannel
    private let eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?

    init(id: String, adUnitId: String, options: [String: Any]?,
         messenger: FlutterBinaryMessenger) {
        self.id = id
        self.videoAd = EBVideoAd(adUnitId: adUnitId)
        self.videoAd.options = AdOptionsMapper.decode(options)
        self.methodChannel = FlutterMethodChannel(
            name: ChannelNames.Video.method(forId: id),
            binaryMessenger: messenger
        )
        self.eventChannel = FlutterEventChannel(
            name: ChannelNames.Video.events(forId: id),
            binaryMessenger: messenger
        )

        super.init()

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
            // EBVideoAd.present(from:) is @MainActor isolated; method channel
            // calls already arrive on main, but the closure isn't statically
            // isolated, so we hop through a MainActor Task.
            Task { @MainActor [videoAd] in
                videoAd.present(from: controller)
            }
            result(nil)

        case "isReady":
            result(videoAd.isReady)

        case "dispose":
            InstanceRegistry.shared.remove(id: id)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Callback wiring

    private func wireCallbacks() {
        videoAd.onLoad        = { [weak self] in self?.send(["event": "onLoad"]) }
        videoAd.onFailureBlock = { [weak self] error in
            self?.send([
                "event": "onFail",
                "error": AdErrorMapper.encode(error as NSError),
            ])
        }
        videoAd.onProgress    = { [weak self] percent in
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
