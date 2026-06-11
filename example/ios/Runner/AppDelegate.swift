import Flutter
import UIKit
import AppTrackingTransparency
#if canImport(ExelBidMediationAdMob)
import ExelBidSDK
import ExelBidMediationAdMob
import GoogleMobileAds
#endif

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Register the Google AdMob mediation adapter so the ExelBid waterfall can
    // fill through AdMob. Guarded so the example still builds before the
    // `ExelBidMediationAdMob` Swift package is added to the Runner target
    // (see README "AdMob 미디에이션 테스트").
    #if canImport(ExelBidMediationAdMob)
    ExelBidMediationKit.shared.register(modules: [AdMobMediationModule.self])
    MobileAds.shared.start(completionHandler: nil)
    #endif

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
