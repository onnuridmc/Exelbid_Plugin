import Flutter
import UIKit
import AppTrackingTransparency
import AdFitSDK

let METHOD_CHANNEL_ID = "adfit"
let METHOD_CHANNEL_VIEW_ID = "adfit/banner_ad"
let METHOD_CHANNEL_NATIVE_VIEW_ID = "adfit/native_ad"

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)

      guard let registrar = registrar(forPlugin: "plugin_name") else { return false }
      
      // Adfit 광고 뷰 등록
      let bannerFactory = AdfitBannerPlatformViewFactory(messenger: registrar.messenger())
      registrar.register(bannerFactory, withId: METHOD_CHANNEL_VIEW_ID)
      let nativeFactory = AdfitNativePaltformViewFactory(messenger: registrar.messenger())
      registrar.register(nativeFactory, withId: METHOD_CHANNEL_NATIVE_VIEW_ID)
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
  }
}
