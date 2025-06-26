import Flutter
import AdFitSDK

class AdfitBannerPlatformView: NSObject, FlutterPlatformView, AdFitBannerAdViewDelegate {
    var channel: FlutterMethodChannel
    var uiView: UIView
    var bannerAdView: AdFitBannerAdView?
    
    init(frame: CGRect,
            viewIdentifier: Int64,
            arguments args: Any?,
            binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        uiView = UIView(frame: frame)
        uiView.backgroundColor = .gray

        channel = FlutterMethodChannel(name: "\(METHOD_CHANNEL_VIEW_ID)_\(viewIdentifier)", binaryMessenger: messenger)

        super.init()

        if let arguments = args as? [String: Any], let clientId = arguments["client_id"] as? String {
            bannerAdView = AdFitBannerAdView(clientId: clientId, adUnitSize: "320x50")
            if let bannerAdView = bannerAdView {
                bannerAdView.delegate = self
                bannerAdView.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
                
                uiView.addSubview(bannerAdView)
                bannerAdView.loadAd()
            }
        }
    }
    
    func view() -> UIView {
        return uiView
    }
    
    func adViewDidReceiveAd(_ bannerAdView: AdFitBannerAdView) {
        channel.invokeMethod("onLoadAd", arguments: nil)
        print("didReceiveAd")
    }
        
    func adViewDidFailToReceiveAd(_ bannerAdView: AdFitBannerAdView, error: Error) {
        channel.invokeMethod("onFailAd", arguments: ["error_message": error.localizedDescription])
        print("didFailToReceiveAd - error :\(error.localizedDescription)")
    }
        
    func adViewDidClickAd(_ bannerAdView: AdFitBannerAdView) {
        channel.invokeMethod("onClickAd", arguments: nil)
        print("didClickAd")
    }
}
