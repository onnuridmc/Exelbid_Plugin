import Flutter
import ExelBidSDK

class EBPBannerAdView: NSObject, FlutterPlatformView, EBAdViewDelegate {

    var channel: FlutterMethodChannel
    var bannerAdView: UIView
    var adView: EBAdView?

    init(frame: CGRect,
        viewIdentifier: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        bannerAdView = UIView(frame: frame)
        channel = FlutterMethodChannel(name: "\(METHOD_CHANNEL_VIEW_ID)_\(viewIdentifier)", binaryMessenger: messenger)

        super.init()

        if let arguments = args as? [String: Any], let adUnitId = arguments["ad_unit_id"] as? String {
            let isFullWebView = arguments["is_full_web_view"] as? Bool ?? true
            let coppa = arguments["coppa"] as? Bool ?? false
            let isTest = arguments["is_test"] as? Bool ?? false
            let styles = arguments["styles"] as? [String: Any]
            
            if let styles = styles {
                if let background_color = styles["background_color"] as? String {
                    bannerAdView.backgroundColor = UIColor(hex: background_color)
                } else {
                    bannerAdView.backgroundColor = nil
                }

                if let border_radius = styles["border_radius"] as? NSNumber {
                    bannerAdView.layer.cornerRadius = CGFloat(border_radius.doubleValue)
                    bannerAdView.clipsToBounds = true
                } else {
                    bannerAdView.layer.cornerRadius = 0
                }
            }

            adView = EBAdView(adUnitId: adUnitId, size: frame.size)

            if let adView = adView {
                adView.delegate = self
                adView.fullWebView = isFullWebView
                adView.coppa = "\(coppa ? 1 : 0)"
                adView.testing = isTest

                bannerAdView.addSubview(adView)

                adView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    adView.topAnchor.constraint(equalTo: bannerAdView.topAnchor),
                    adView.bottomAnchor.constraint(equalTo: bannerAdView.bottomAnchor),
                    adView.leadingAnchor.constraint(equalTo: bannerAdView.leadingAnchor),
                    adView.trailingAnchor.constraint(equalTo: bannerAdView.trailingAnchor)
                ])

                adView.loadAd()
            }
        }
    }

    func view() -> UIView {
        return bannerAdView
    }

    func adViewDidLoadAd(_ view: EBAdView?) {
        channel.invokeMethod("onLoadAd", arguments: nil)
    }

    func adViewDidFailToLoadAd(_ view: EBAdView?) {
        channel.invokeMethod("onFailAd", arguments: nil)
    }

    func willLeaveApplicationFromAd(_ view: EBAdView?) {
        channel.invokeMethod("onClickAd", arguments: nil)
    }
}
