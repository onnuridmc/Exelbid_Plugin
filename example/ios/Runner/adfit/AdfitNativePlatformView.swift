import Flutter
import AdFitSDK

class AdfitNativePlatformView: NSObject, FlutterPlatformView, AdFitNativeAdLoaderDelegate {
    var channel: FlutterMethodChannel
    var uiView: UIView
    private var nativeAdView: AdfitNativeView?
    private var nativeAdLoader: AdFitNativeAdLoader?
    private var nativeAd: AdFitNativeAd?
    
    init(frame: CGRect,
            viewIdentifier: Int64,
            arguments args: Any?,
            binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        uiView = UIView(frame: frame)
        uiView.backgroundColor = .gray
        
        channel = FlutterMethodChannel(name: "\(METHOD_CHANNEL_NATIVE_VIEW_ID)_\(viewIdentifier)", binaryMessenger: messenger)
        
        super.init()
        
        self.channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }

            if call.method == "loadAd", let args = call.arguments as? [String: Any] {
                self.loadAd(args: args)
                result(nil)
            }
        }
    }
    
    func view() -> UIView {
        return self.uiView
    }
    
    func loadAd(args: [String: Any]) {
        if let clientId = args["client_id"] as? String {
            self.nativeAdLoader = AdFitNativeAdLoader(clientId: clientId)
            self.nativeAdLoader?.delegate = self
            self.nativeAdLoader?.infoIconPosition = .topRight
            self.nativeAdLoader?.loadAd()
        }
    }
    
    // MARK: AdFitNativeAdLoaderDelegate
    func nativeAdLoaderDidReceiveAd(_ nativeAd: AdFitNativeAd) {
        self.channel.invokeMethod("onLoadAd", arguments: nil)
        
        if let nativeAdView = Bundle.main.loadNibNamed("AdfitNativeView", owner: nil, options: nil)?.first as? AdfitNativeView {
            self.nativeAd = nativeAd
            nativeAdView.backgroundColor = .white
            nativeAd.bind(nativeAdView)
            uiView.addSubview(nativeAdView)
            self.nativeAdView = nativeAdView
            
            // 오토레이아웃 정렬
            nativeAdView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nativeAdView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
                nativeAdView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
                nativeAdView.topAnchor.constraint(equalTo: uiView.topAnchor),
                nativeAdView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor),
            ])
        }
    }
    
    func nativeAdLoaderDidFailToReceiveAd(_ nativeAdLoader: AdFitNativeAdLoader, error: Error) {
        self.channel.invokeMethod("onFailAd", arguments: ["error_message": error.localizedDescription])
    }
}
