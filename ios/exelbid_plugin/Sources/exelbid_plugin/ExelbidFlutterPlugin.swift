import ExelBidSDK
import Flutter
import UIKit
import AppTrackingTransparency

public class ExelbidFlutterPlugin: NSObject, FlutterPlugin {

    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: ChannelNames.global,
            binaryMessenger: registrar.messenger()
        )
        let instance = ExelbidFlutterPlugin(messenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)

        // Register the ExelBid built-in mediation adapters once at startup so
        // the Mediated* surfaces have at least the ExelBid network available in
        // their waterfall. External network adapters (AdMob/FAN/AdFit) ship as
        // separate modules and are intentionally not bundled here.
        ExelBidMediationKit.shared.register(modules: [
            ExelBidBuiltInMediationModule.self,
        ])

        registrar.register(
            BannerViewFactory(messenger: registrar.messenger()),
            withId: ChannelNames.Banner.viewType
        )
        registrar.register(
            NativeAdViewFactory(messenger: registrar.messenger()),
            withId: ChannelNames.Native.viewType
        )
        registrar.register(
            MediatedBannerViewFactory(messenger: registrar.messenger()),
            withId: ChannelNames.MediatedBanner.viewType
        )
        registrar.register(
            MediatedNativeAdViewFactory(messenger: registrar.messenger()),
            withId: ChannelNames.MediatedNative.viewType
        )
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setLogLevel":
            let args = call.arguments as? [String: Any]
            let raw = args?["level"] as? Int ?? LogLevel.warning.rawValue
            ExelBid.shared.logLevel = LogLevelMapper.from(rawValue: raw)
            result(nil)

        case "getSdkVersion":
            result(ExelBid.shared.sdkVersion)

        case "getTrackingAuthorizationStatus":
            result(currentTrackingAuthorizationStatus())

        case "requestTrackingAuthorization":
            requestTrackingAuthorization(result: result)

        case "video.create":
            createVideo(call: call, result: result)

        case "interstitial.create":
            createInterstitial(call: call, result: result)

        case "mediatedVideo.create":
            createMediatedVideo(call: call, result: result)

        case "mediatedInterstitial.create":
            createMediatedInterstitial(call: call, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - App Tracking Transparency

    /// Returns the current ATT status as an Int matching
    /// `ATTrackingManager.AuthorizationStatus.rawValue`. On iOS < 14 the
    /// system has no ATT concept — IDFA was always available, so we return
    /// `.authorized` (3).
    private func currentTrackingAuthorizationStatus() -> Int {
        if #available(iOS 14.0, *) {
            return Int(ATTrackingManager.trackingAuthorizationStatus.rawValue)
        }
        return 3 // authorized
    }

    /// Asks the user for ATT permission. The system only shows the prompt on
    /// the first call; subsequent calls return the cached status immediately.
    /// Must be called while the app is in the foreground-active state.
    private func requestTrackingAuthorization(result: @escaping FlutterResult) {
        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                // Completion handler may arrive on any thread; hop to main
                // before calling back into Flutter.
                DispatchQueue.main.async {
                    result(Int(status.rawValue))
                }
            }
        } else {
            result(3) // authorized
        }
    }

    // MARK: - Full-screen ad creation

    private func createVideo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String,
              let adUnitId = args["adUnitId"] as? String else {
            result(FlutterError(
                code: "invalid_args",
                message: "video.create requires 'id' and 'adUnitId'.",
                details: nil
            ))
            return
        }
        let options = args["options"] as? [String: Any]
        let handle = VideoAdHandle(
            id: id, adUnitId: adUnitId, options: options, messenger: messenger
        )
        InstanceRegistry.shared.register(handle, forId: id)
        result(nil)
    }

    private func createInterstitial(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String,
              let adUnitId = args["adUnitId"] as? String else {
            result(FlutterError(
                code: "invalid_args",
                message: "interstitial.create requires 'id' and 'adUnitId'.",
                details: nil
            ))
            return
        }
        let options = args["options"] as? [String: Any]
        let fullWebView = args["fullWebView"] as? Bool ?? false
        let handle = InterstitialAdHandle(
            id: id, adUnitId: adUnitId, options: options,
            fullWebView: fullWebView, messenger: messenger
        )
        InstanceRegistry.shared.register(handle, forId: id)
        result(nil)
    }

    private func createMediatedVideo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String,
              let adUnitId = args["adUnitId"] as? String else {
            result(FlutterError(
                code: "invalid_args",
                message: "mediatedVideo.create requires 'id' and 'adUnitId'.",
                details: nil
            ))
            return
        }
        let options = args["options"] as? [String: Any]
        let perNetworkTimeout = args["perNetworkTimeout"] as? Double
        let handle = MediatedVideoAdHandle(
            id: id, adUnitId: adUnitId, options: options,
            perNetworkTimeout: perNetworkTimeout, messenger: messenger
        )
        InstanceRegistry.shared.register(handle, forId: id)
        result(nil)
    }

    private func createMediatedInterstitial(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String,
              let adUnitId = args["adUnitId"] as? String else {
            result(FlutterError(
                code: "invalid_args",
                message: "mediatedInterstitial.create requires 'id' and 'adUnitId'.",
                details: nil
            ))
            return
        }
        let options = args["options"] as? [String: Any]
        let perNetworkTimeout = args["perNetworkTimeout"] as? Double
        let handle = MediatedInterstitialAdHandle(
            id: id, adUnitId: adUnitId, options: options,
            perNetworkTimeout: perNetworkTimeout, messenger: messenger
        )
        InstanceRegistry.shared.register(handle, forId: id)
        result(nil)
    }
}
