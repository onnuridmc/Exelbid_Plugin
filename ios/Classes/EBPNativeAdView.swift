import UIKit
import Flutter
import ExelBidSDK

class EBPNativeAdView: NSObject, FlutterPlatformView, EBNativeAdDelegate {

    var channel: FlutterMethodChannel
    var uiView: UIView
    var nativeAdView: EBPNativeView
    var nativeAd : EBNativeAd?

    init(frame: CGRect,
        viewIdentifier: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        self.uiView = UIView(frame: frame)
        self.nativeAdView = EBPNativeView(frame: frame)
        self.channel = FlutterMethodChannel(name: "\(METHOD_CHANNEL_NATIVE_VIEW_ID)_\(viewIdentifier)", binaryMessenger: messenger)

        super.init()

        self.channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            if call.method == "setTitleView", let args = call.arguments as? [String: Any] {
                self.nativeAdView.setTitleView(call)
                result(nil)
            } else if call.method == "setDescriptionView", let args = call.arguments as? [String: Any] {
                self.nativeAdView.setDescriptionView(call)
                result(nil)
            } else if call.method == "setMainImageView", let args = call.arguments as? [String: Any] {
                self.nativeAdView.setMainImageView(call)
                result(nil)
            } else if call.method == "setMainVideoView", let args = call.arguments as? [String: Any] {
                self.nativeAdView.setMainImageView(call)
                result(nil)
            } else if call.method == "setIconImageView", let args = call.arguments as? [String: Any] {
                self.nativeAdView.setIconImageView(call)
                result(nil)
            } else if call.method == "setCallToActionView", let args = call.arguments as? [String: Any] {
                self.nativeAdView.setCallToActionView(call)
                result(nil)
            } else if call.method == "setPrivacyInformationIconImage", let args = call.arguments as? [String: Any] {
                self.nativeAdView.setPrivacyInformationIconImage(call)
                result(nil)
            } else if call.method == "loadAd", let args = call.arguments as? [String: Any] {
                self.loadAd(args: args)
                result(nil)
            }
        }
    }

    func view() -> UIView {
        return self.nativeAdView
    }

    func loadAd(args: [String: Any]) {
        if let adUnitId = args["ad_unit_id"] as? String {
            let coppa = args["coppa"] as? Bool ?? false
            let isTest = args["is_test"] as? Bool ?? false
            let assets = args["native_assets"] as? [String] ?? []

            let nativeManager = ExelBidNativeManager(adUnitId, nil)
            nativeManager.coppa("\(coppa ? 1 : 0)")
            nativeManager.testing(isTest)
            nativeManager.desiredAssets(NSSet(array: assets))

            nativeManager.startWithCompletionHandler { (request, response, error) in
                if let error = error {
                    self.channel.invokeMethod("onFailAd", arguments: nil)
                    print(">>> Native Error : \(error.localizedDescription)")
                } else {
                    self.nativeAd = response
                    self.nativeAd?.delegate = self
                    self.channel.invokeMethod("onLoadAd", arguments: nil)

                    if let adView = self.nativeAd?.retrieveAdViewWithAdView(self.nativeAdView) {
                        self.uiView.addSubview(adView)
                        adView.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            adView.topAnchor.constraint(equalTo: self.uiView.topAnchor),
                            adView.bottomAnchor.constraint(equalTo: self.uiView.bottomAnchor),
                            adView.leadingAnchor.constraint(equalTo: self.uiView.leadingAnchor),
                            adView.trailingAnchor.constraint(equalTo: self.uiView.trailingAnchor)
                        ])

                        if let data = self.nativeAd?.getNativeData() {
                            self.channel.invokeMethod("onLoadAd", arguments: ["native_data" : data])
                        }
                    } else {
                        self.channel.invokeMethod("onFailAd", arguments: nil)
                    }
                }
            }
        }
    }
}
