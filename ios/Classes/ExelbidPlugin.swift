import Flutter
import UIKit
import ExelBidSDK
import AdSupport
import AppTrackingTransparency

let METHOD_CHANNEL_ID = "exelbid_plugin"
let METHOD_CHANNEL_VIEW_ID = "exelbid_plugin/banner_ad"
let METHOD_CHANNEL_NATIVE_VIEW_ID = "exelbid_plugin/native_ad"
let METHOD_CHANNEL_MEDIATION_ID = "exelbid_plugin/mediation"

public class ExelbidPlugin: NSObject, FlutterPlugin {
    static var channel: FlutterMethodChannel?
    var messenger: FlutterBinaryMessenger
    var interstitial: EBInterstitialAdController?
    var videoManager: EBVideoManager?
    var mediations: [String : EBPMediation] = [:]

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        self.channel = FlutterMethodChannel(name: METHOD_CHANNEL_ID, binaryMessenger: registrar.messenger())
        let instance = ExelbidPlugin(messenger: registrar.messenger()) 

        if let channel = self.channel {
            registrar.addMethodCallDelegate(instance, channel: channel)
        }

        let bannerFactory = EBPBannerAdViewFactory(messenger: registrar.messenger())
        registrar.register(bannerFactory, withId: METHOD_CHANNEL_VIEW_ID)

        let nativeFactory = EBPNativeAdViewFactory(messenger: registrar.messenger())
        registrar.register(nativeFactory, withId: METHOD_CHANNEL_NATIVE_VIEW_ID)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "requestTrackingAuthorization":
                if #available(iOS 14.0, *) {
                    ATTrackingManager.requestTrackingAuthorization { status in 
                        result(status.rawValue)
                    }
                } else {
                    // iOS 12이하 ATT 미적용 상태 처리 (3: Authorized, 2: Denied)
                    result(ASIdentifierManager.shared().isAdvertisingTrackingEnabled ? 3 : 2)
                }
            case "loadInterstitial": 
                if let arguments = call.arguments as? [String: Any], let adUnitId = arguments["ad_unit_id"] as? String {
                    let coppa = arguments["coppa"] as? Bool ?? false
                    let isTest = arguments["is_test"] as? Bool ?? false

                    self.loadInterstitial(adUnitId: adUnitId, coppa: coppa, isTest: isTest)
                }

                result(nil)
            case "showInterstitial":
                self.showInterstitial()

                result(nil)
            case "initMediation":
                if let arguments = call.arguments as? [String: Any],
                    let mediationUnitId = arguments["mediation_unit_id"] as? String,
                    let mediationTypes = arguments["mediation_types"] as? [String] {
                    self.mediations[mediationUnitId] = EBPMediation(unitId: mediationUnitId, types: mediationTypes, binaryMessenger: self.messenger)
                }
                result(nil)
            case "loadInterstitialVideo":
                if let arguments = call.arguments as? [String: Any], let adUnitId = arguments["ad_unit_id"] as? String {
                    let coppa = arguments["coppa"] as? Bool ?? false
                    let isTest = arguments["is_test"] as? Bool ?? false

                    self.loadInterstitialVideo(adUnitId: adUnitId, coppa: coppa, isTest: isTest)
                }

                result(nil)
            case "showInterstitialVideo":
                self.showInterstitialVideo()

                result(nil)
            default:
                result(FlutterMethodNotImplemented)
        }
    }

    func setInterstitialHandler() {

    }

    func loadInterstitial(adUnitId: String, coppa: Bool = false, isTest: Bool = false) {
        self.interstitial = EBInterstitialAdController(adUnitId: adUnitId)
        if let interstitial = self.interstitial {
            interstitial.delegate = self

            interstitial.coppa = "\(coppa ? 1 : 0)"
            interstitial.testing = isTest

            interstitial.loadAd()
        }
    }

    func showInterstitial() {
        self.interstitial?.showFromViewController()
    }
    
    func loadInterstitialVideo(adUnitId: String, coppa: Bool = false, isTest: Bool = false) {
        self.videoManager = EBVideoManager(identifier: adUnitId)
        
        if let videoManager = self.videoManager {
            // 광고의 효율을 높이기 위해 옵션 설정
            videoManager.coppa("\(coppa ? 1 : 0)")
            
            // 테스트 광고 설정 (true - 테스트 광고가 응답)
            videoManager.testing(isTest)

            videoManager.startWithCompletionHandler { (request, error) in
                if let error = error  {
                    print(">>> \(error.localizedDescription)")
                    ExelbidPlugin.channel?.invokeMethod("onVideoFailAd", arguments: ["error_message": error.localizedDescription])
                }else{
                   ExelbidPlugin.channel?.invokeMethod("onVideoLoadAd", arguments: nil)
                }
            }
        }
    }

    func showInterstitialVideo() {
        if let videoManager = videoManager, let uiViewController = topViewController {
            videoManager.presentAd(controller: uiViewController, delegate: self)
        } else {
            ExelbidPlugin.channel?.invokeMethod("onVideoFailAd", arguments: ["error_message": "Not Found ViewController"])
        }
    }
    
    var topViewController: UIViewController? {
        var mainWindow: UIWindow? = nil
        if #available(iOS 15, *) {
            // iOS 15 이상
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }) {
                mainWindow = windowScene.windows.first(where: { $0.isKeyWindow })
            }
        } else if #available(iOS 13, *) {
            // iOS 13 ~ iOS 14
            mainWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        } else {
            // iOS 12 이하
            mainWindow = UIApplication.shared.keyWindow
        }
        
        var topViewController = mainWindow?.rootViewController
        
        if let presented = topViewController?.presentedViewController {
            topViewController = presented
        } else if let navController = topViewController as? UINavigationController {
            topViewController = navController.topViewController
        } else if let tabBarController = topViewController as? UITabBarController {
            topViewController = tabBarController.selectedViewController
        }
        
        return topViewController
    }
}

// MARK: - EBInterstitialAdControllerDelegate

extension ExelbidPlugin : EBInterstitialAdControllerDelegate{
    public func interstitialDidLoadAd(_ interstitial: EBInterstitialAdController?) {
        ExelbidPlugin.channel?.invokeMethod("onInterstitialLoadAd", arguments: nil)
    }

    public func interstitialDidFailToLoadAd(_ interstitial: EBInterstitialAdController?) {
        ExelbidPlugin.channel?.invokeMethod("onInterstitialFailAd", arguments: nil)
    }

    public func interstitialDidAppear(_ interstitial: EBInterstitialAdController?) {
        ExelbidPlugin.channel?.invokeMethod("onInterstitialShow", arguments: nil)
    }

    public func interstitialDidDisappear(_ interstitial: EBInterstitialAdController?) {
        ExelbidPlugin.channel?.invokeMethod("onInterstitialDismiss", arguments: nil)
    }

    public func interstitialDidReceiveTapEvent(_ interstitial: EBInterstitialAdController?) {
        ExelbidPlugin.channel?.invokeMethod("onInterstitialClickAd", arguments: nil)
    }
}


// MARK: - EBVideoDelegate

extension ExelbidPlugin : EBVideoDelegate {

    public func videoAdDidLoad(adUnitID: String) {
        ExelbidPlugin.channel?.invokeMethod("onVideoLoadAd", arguments: nil)
    }

    public func videoAdDidFailToLoad(adUnitID: String, error: any Error) {
        ExelbidPlugin.channel?.invokeMethod("onVideoFailAd", arguments: ["error_message": error.localizedDescription])
    }

    public func videoAdDidAppear(adUnitID: String) {
        ExelbidPlugin.channel?.invokeMethod("onVideoShow", arguments: nil)
    }

    public func videoAdDidDisappear(adUnitID: String) {
        ExelbidPlugin.channel?.invokeMethod("onVideoDismiss", arguments: nil)
    }

    public func videoAdDidReceiveTapEvent(adUnitID: String) {
        ExelbidPlugin.channel?.invokeMethod("onVideoClickAd", arguments: nil)
    }
}

class EBPMediation {
    var unitId: String
    var manager: EBMediationManager
    var channel: FlutterMethodChannel

    init(unitId: String, types: [String], binaryMessenger: FlutterBinaryMessenger) {
        self.unitId = unitId
        self.manager = EBMediationManager(adUnitId: unitId, mediationTypes: types)
        self.channel = FlutterMethodChannel(name: "\(METHOD_CHANNEL_MEDIATION_ID)_\(unitId)", binaryMessenger: binaryMessenger)
        self.channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            if call.method == "loadMediation" {
                self.loadMediation(result)
            } else if call.method == "nextMediation" {
                self.nextMediation(result)
            }
        }

        channel.invokeMethod("onInitMediation", arguments: nil);
    }

    func loadMediation(_ result: @escaping FlutterResult) {
        self.manager.requestMediation { (manager, error) in
            DispatchQueue.main.async {
                if error != nil {
                    result(false)
                } else {
                    result(true)
                }
            }
        }
    }

    func nextMediation(_ result: @escaping FlutterResult) {
        if let mediation = manager.next() {
            result(["network_id": mediation.id, "unit_id": mediation.unit_id]);
        } else {
            result(nil)
        }
    }
}
