import UIKit
import Flutter
import ExelBidSDK

class EBPNativeView : UIView, EBNativeAdRendering {
    var titleView: UILabel!
    var descriptionView: UILabel!
    var mainImageView: UIImageView!
    var mainVideoView: UIView!
    var iconImageView: UIImageView!
    var callToActionView: UILabel!
    var privacyInformationIconImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setTitleView(_ call: FlutterMethodCall) {
        if self.titleView == nil {
            self.titleView = UILabel();

            self.addSubview(self.titleView) 
        }

        self.titleView?.frame = getCGRact(call)
    }

    func setDescriptionView(_ call: FlutterMethodCall) {
        if self.descriptionView == nil {
            self.descriptionView = UILabel();

            self.addSubview(self.descriptionView) 
        }

        self.descriptionView?.frame = getCGRact(call)
    }

    func setMainImageView(_ call: FlutterMethodCall) {
        if self.mainImageView == nil {
            self.mainImageView = UIImageView();

            self.addSubview(self.mainImageView) 
        }

        self.mainImageView?.frame = getCGRact(call)
    }

    func setMainVideoView(_ call: FlutterMethodCall) {
        if self.mainVideoView == nil {
            self.mainVideoView = UIView();

            self.addSubview(self.mainVideoView) 
        }

        self.mainVideoView?.frame = getCGRact(call)
    }

    func setIconImageView(_ call: FlutterMethodCall) {
        if self.iconImageView == nil {
            self.iconImageView = UIImageView();

            self.addSubview(self.iconImageView) 
        }

        self.iconImageView?.frame = getCGRact(call)
    }

    func setCallToActionView(_ call: FlutterMethodCall) {
        if self.callToActionView == nil {
            self.callToActionView = UILabel();

            self.addSubview(self.callToActionView) 
        }

        self.callToActionView?.frame = getCGRact(call)
    }

    func setPrivacyInformationIconImage(_ call: FlutterMethodCall) {    
        if self.privacyInformationIconImageView == nil {
            self.privacyInformationIconImageView = UIImageView();

            self.addSubview(self.privacyInformationIconImageView) 
        }

        self.privacyInformationIconImageView?.frame = getCGRact(call)
    }
    
    func getCGRact(_ call: FlutterMethodCall) -> CGRect {
        if let arg = call.arguments as? [String: Any] {
            let x = arg["x"] as? CGFloat ?? 0
            let y = arg["y"] as? CGFloat ?? 0
            let width = arg["width"] as? CGFloat ?? 0
            let height = arg["height"] as? CGFloat ?? 0

            return CGRectMake(x, y, width, height)
        }

        return CGRect.zero
    }

    // MARK: - EBNativeAdRendering Delegate    
    func nativeIconImageView() -> UIImageView? {
        return iconImageView
    }
    
    func nativeMainImageView() -> UIImageView? {
        return mainImageView
    }
    
    func nativePrivacyInformationIconImageView() -> UIImageView? {
        return privacyInformationIconImageView
    }

    func nativeVideoView() -> UIView? {
        return mainVideoView
    }
}