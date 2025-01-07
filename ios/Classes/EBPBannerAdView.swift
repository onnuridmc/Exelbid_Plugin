import Flutter
import ExelBidSDK

class EBPBannerAdView: NSObject, FlutterPlatformView, EBAdViewDelegate {

    var channel: FlutterMethodChannel
    var uiView: UIView
    var adView: EBAdView?

    init(frame: CGRect,
        viewIdentifier: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        channel = FlutterMethodChannel(name: "\(METHOD_CHANNEL_VIEW_ID)_\(viewIdentifier)", binaryMessenger: messenger)
        uiView = UIView(frame: frame)

        super.init()

        if let arguments = args as? [String: Any], let adUnitId = arguments["ad_unit_id"] as? String {
            let isFullWebView = arguments["is_full_web_view"] as? Bool ?? true
            let coppa = arguments["coppa"] as? Bool ?? false
            let yob = arguments["yob"] as? String
            let gender = getGender(arguments["gender"] as? Bool)
            let keywords = arguments["keywords"] as? [String: String]
            let isTest = arguments["is_test"] as? Bool ?? false

            adView = EBAdView(adUnitId: adUnitId, size: frame.size)

            if let adView = adView {
                adView.delegate = self
                adView.fullWebView = isFullWebView
                adView.coppa = "\(coppa ? 1 : 0)"
                adView.yob = yob
                adView.gender = gender
                adView.testing = isTest

                adView.keywords = keywords?.map { key, value in
                    return "\(key):\(value)"
                }.joined(separator: ",")

                uiView.addSubview(adView)

                adView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    adView.topAnchor.constraint(equalTo: uiView.topAnchor),
                    adView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor),
                    adView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
                    adView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor)
                ])

                adView.loadAd()
            }
        }
    }

    func view() -> UIView {
        return uiView
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

    func getGender(_ gender: Bool?) -> String? {
        if let gender = gender {
            return gender ? "M" : "W"
        } else {
            return nil
        }
    }
}
