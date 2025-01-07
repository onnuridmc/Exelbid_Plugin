import Flutter
import UIKit
import ExelBidSDK

let METHOD_CHANNEL_ID = "exelbid_plugin"
let METHOD_CHANNEL_VIEW_ID = "exelbid_plugin/banner_ad"

public class ExelbidPlugin: NSObject, FlutterPlugin {

    static var channel: FlutterMethodChannel?
    var interstitial: EBInterstitialAdController?

    public static func register(with registrar: FlutterPluginRegistrar) {
        self.channel = FlutterMethodChannel(name: METHOD_CHANNEL_ID, binaryMessenger: registrar.messenger())
        let instance = ExelbidPlugin()
        if let channel = self.channel {
            registrar.addMethodCallDelegate(instance, channel: channel)
        }

        let bannerFactory = EBPBannerAdViewFactory(messenger: registrar.messenger())
        registrar.register(bannerFactory, withId: METHOD_CHANNEL_VIEW_ID)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "loadInterstitial":
                if let arguments = call.arguments as? [String: Any], let adUnitId = arguments["ad_unit_id"] as? String {
                    let coppa = arguments["coppa"] as? Bool ?? false
                    let yob = arguments["yob"] as? String
                    let gender = getGender(arguments["gender"] as? Bool)
                    let keywords = arguments["keywords"] as? [String: String]
                    let isTest = arguments["is_test"] as? Bool ?? false

                    self.loadInterstitial(adUnitId: adUnitId, coppa: coppa, yob: yob, gender: gender, keywords: keywords, isTest: isTest)
                }
            case "showInterstitial":
                self.showInterstitial()
            default:
                result(FlutterMethodNotImplemented)
        }
    }

    func setInterstitialHandler() {

    }

    func loadInterstitial(adUnitId: String, coppa: Bool = false, yob: String?, gender: String?, keywords: [String: String]?, isTest: Bool = false) {
        self.interstitial = EBInterstitialAdController(adUnitId: adUnitId)
        if let interstitial = self.interstitial {
            interstitial.delegate = self

            interstitial.coppa = "\(coppa ? 1 : 0)"
            interstitial.yob = yob
            interstitial.gender = gender
            interstitial.testing = isTest

            interstitial.keywords = keywords?.map { key, value in
                return "\(key):\(value)"
            }.joined(separator: ",")

            interstitial.loadAd()
        }
    }

    func showInterstitial() {
        self.interstitial?.showFromViewController()
    }

    func getGender(_ gender: Bool?) -> String? {
        if let gender = gender {
            return gender ? "M" : "W"
        } else {
            return nil
        }
    }
}

extension ExelbidPlugin : EBInterstitialAdControllerDelegate{
    public func interstitialDidLoadAd(_ interstitial: EBInterstitialAdController?) {
        ExelbidPlugin.channel?.invokeMethod("onLoadAd", arguments: nil)
    }

    public func interstitialDidFailToLoadAd(_ interstitial: EBInterstitialAdController?) {
        ExelbidPlugin.channel?.invokeMethod("onFailAd", arguments: nil)
    }

    public func interstitialDidAppear(_ interstitial: EBInterstitialAdController?) {
        ExelbidPlugin.channel?.invokeMethod("onInterstitialShow", arguments: nil)
    }

    public func interstitialDidDisappear(_ interstitial: EBInterstitialAdController?) {
        ExelbidPlugin.channel?.invokeMethod("onInterstitialDismiss", arguments: nil)
    }

    public func interstitialDidReceiveTapEvent(_ interstitial: EBInterstitialAdController?) {
        ExelbidPlugin.channel?.invokeMethod("onClickAd", arguments: nil)
    }
}
