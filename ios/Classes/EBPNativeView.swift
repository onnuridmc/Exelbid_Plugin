import UIKit
import Flutter
import ExelBidSDK

class EBPNativeView : UIView, EBNativeAdRendering {
    var titleView: UILabel?
    var descriptionView: UILabel?
    var mainImageView: UIImageView?
    var mainVideoView: UIView?
    var iconImageView: UIImageView?
    var callToActionView: UILabel?
    var privacyInformationIconImageView: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setTitleView(_ call: FlutterMethodCall) {
        if self.titleView == nil {
            self.titleView = UILabel();
            self.addSubview(self.titleView!)
        }

        if let view = self.titleView {
            view.frame = getCGRact(call)
            view.backgroundColor = .clear

            if let arg = call.arguments as? [String: Any], let styles = arg["styles"] as? [String: Any] {
                
                if let color = styles["color"] as? String {
                    view.textColor = UIColor(hex: color)
                }
                
                if let background_color = styles["background_color"] as? String {
                    view.backgroundColor = UIColor(hex: background_color)
                }
                
                if let font_size = styles["font_size"] as? CGFloat {
                    view.font = UIFont.systemFont(ofSize: font_size)
                }
                
                if let font_weight = styles["font_weight"] as? String {
                    view.font = UIFont.systemFont(ofSize: view.font.pointSize, weight: font_weight.toUIFontWeight())
                }
            }
        }
    }

    func setDescriptionView(_ call: FlutterMethodCall) {
        if self.descriptionView == nil {
            self.descriptionView = UILabel();
            self.addSubview(self.descriptionView!)
        }

        if let view = self.descriptionView {
            view.frame = getCGRact(call)
            view.backgroundColor = .clear

            if let arg = call.arguments as? [String: Any], let styles = arg["styles"] as? [String: Any] {
                
                if let color = styles["color"] as? String {
                    view.textColor = UIColor(hex: color)
                }
                
                if let background_color = styles["background_color"] as? String {
                    view.backgroundColor = UIColor(hex: background_color)
                }
                
                if let font_size = styles["font_size"] as? CGFloat {
                    view.font = UIFont.systemFont(ofSize: font_size)
                }
                
                if let font_weight = styles["font_weight"] as? String {
                    view.font = UIFont.systemFont(ofSize: view.font.pointSize, weight: font_weight.toUIFontWeight()) // 원하는 weight로 변경
                }
            }
        }
    }

    func setMainImageView(_ call: FlutterMethodCall) {
        if self.mainImageView == nil {
            self.mainImageView = UIImageView();
            self.addSubview(self.mainImageView!)
        }
        
        if let view = self.mainImageView {
            view.frame = getCGRact(call)
            view.clipsToBounds = true
            view.backgroundColor = .clear
            
            if let arg = call.arguments as? [String: Any], let styles = arg["styles"] as? [String: Any] {
                
                let object_fit = styles["object_fit"] as? String
                view.contentMode = object_fit == "fill" ? .scaleAspectFill : .scaleAspectFit
                
                if let background_color = styles["background_color"] as? String {
                    view.backgroundColor = UIColor(hex: background_color)
                }
                
                if let border_radius = styles["border_radius"] as? NSNumber {
                    view.layer.cornerRadius = CGFloat(border_radius.doubleValue)
                } else {
                    view.layer.cornerRadius = 0
                }
            }
        }
    }

    func setMainVideoView(_ call: FlutterMethodCall) {
        if self.mainVideoView == nil {
            self.mainVideoView = UIView();
            self.addSubview(self.mainVideoView!)
        }

        if let view = self.mainVideoView {
            view.frame = getCGRact(call)
            view.clipsToBounds = true
            view.backgroundColor = .clear
            
            if let arg = call.arguments as? [String: Any], let styles = arg["styles"] as? [String: Any] {

                if let background_color = styles["background_color"] as? String {
                    view.backgroundColor = UIColor(hex: background_color)
                }
                
                if let border_radius = styles["border_radius"] as? NSNumber {
                    view.layer.cornerRadius = CGFloat(border_radius.doubleValue)
                } else {
                    view.layer.cornerRadius = 0
                }
            }
        }
    }

    func setIconImageView(_ call: FlutterMethodCall) {
        if self.iconImageView == nil {
            self.iconImageView = UIImageView();
            self.addSubview(self.iconImageView!)
        }

        if let view = self.iconImageView {
            view.frame = getCGRact(call)
            view.clipsToBounds = true
            view.backgroundColor = .clear
            
            if let arg = call.arguments as? [String: Any], let styles = arg["styles"] as? [String: Any] {
                
                if let object_fit = styles["object_fit"] as? String {
                    view.contentMode = object_fit == "fill" ? .scaleAspectFill : .scaleAspectFit
                }
                
                if let background_color = styles["background_color"] as? String {
                    view.backgroundColor = UIColor(hex: background_color)
                }
                
                if let border_radius = styles["border_radius"] as? NSNumber {
                    view.layer.cornerRadius = CGFloat(border_radius.doubleValue)
                } else {
                    view.layer.cornerRadius = 0
                }
            }
        }
    }

    func setCallToActionView(_ call: FlutterMethodCall) {
        if self.callToActionView == nil {
            self.callToActionView = UILabel();
            self.addSubview(self.callToActionView!)
        }

        if let view = self.callToActionView {
            view.frame = getCGRact(call)
            view.clipsToBounds = true
            view.textAlignment = .center
            view.backgroundColor = .clear
            
            if let arg = call.arguments as? [String: Any], let styles = arg["styles"] as? [String: Any] {
                if let color = styles["color"] as? String {
                    view.textColor = UIColor(hex: color)
                }
                
                if let background_color = styles["background_color"] as? String {
                    view.backgroundColor = UIColor(hex: background_color)
                }
                
                if let border_radius = styles["border_radius"] as? NSNumber {
                    view.layer.cornerRadius = CGFloat(border_radius.doubleValue)
                } else {
                    view.layer.cornerRadius = 0
                }
                
                if let font_size = styles["font_size"] as? CGFloat {
                    view.font = UIFont.systemFont(ofSize: font_size)
                }
                
                if let font_weight = styles["font_weight"] as? String {
                    view.font = UIFont.systemFont(ofSize: view.font.pointSize, weight: font_weight.toUIFontWeight()) // 원하는 weight로 변경
                }
            }
        }
    }

    func setPrivacyInformationIconImage(_ call: FlutterMethodCall) {    
        if self.privacyInformationIconImageView == nil {
            self.privacyInformationIconImageView = UIImageView();
            self.addSubview(self.privacyInformationIconImageView!)
        }

        if let view = self.privacyInformationIconImageView {
            view.frame = getCGRact(call)
            view.clipsToBounds = true
            view.backgroundColor = .clear
            
            if let arg = call.arguments as? [String: Any], let styles = arg["styles"] as? [String: Any] {
                if let object_fit = styles["object_fit"] as? String {
                    view.contentMode = object_fit == "fill" ? .scaleAspectFill : .scaleAspectFit
                }
                
                if let background_color = styles["background_color"] as? String {
                    view.backgroundColor = UIColor(hex: background_color)
                } else {
                    view.backgroundColor = .clear
                }
                
                if let border_radius = styles["border_radius"] as? NSNumber {
                    view.layer.cornerRadius = CGFloat(border_radius.doubleValue)
                } else {
                    view.layer.cornerRadius = 0
                }
            }
        }
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
    func nativeMainTextLabel() -> UILabel? {
        return self.descriptionView
    }

    func nativeTitleTextLabel() -> UILabel? {
        return self.titleView
    }

    func nativeIconImageView() -> UIImageView? {
        return iconImageView
    }
    
    func nativeMainImageView() -> UIImageView? {
        return mainImageView
    }
    
    func nativeCallToActionTextLabel() -> UILabel? {
        return callToActionView
    }
    
    func nativePrivacyInformationIconImageView() -> UIImageView? {
        return privacyInformationIconImageView
    }

    func nativeVideoView() -> UIView? {
        return mainVideoView
    }
}
