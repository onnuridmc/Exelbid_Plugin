import Flutter
import UIKit
import AppTrackingTransparency
import ExelBidSDK
import GoogleMobileAds
import ExelBidMediationAdMob
import ExelBidMediationAdFit

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
    
    ExelBidMediationKit.shared.register(modules: [
        AdMobMediationModule.self,
        AdFitMediationModule.self
    ])
    MobileAds.shared.start(completionHandler: nil)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
