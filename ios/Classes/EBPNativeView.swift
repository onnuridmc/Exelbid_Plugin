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
            self.titleView = UILabel()
            self.titleView?.numberOfLines = 1
            self.titleView?.lineBreakMode = .byTruncatingTail
            self.addSubview(self.titleView!)
        }

        if let view = self.titleView {
            view.frame = getCGRact(call)
            view.backgroundColor = .clear
            updateTextStyles(view, call)
        }
    }

    func setDescriptionView(_ call: FlutterMethodCall) {
        if self.descriptionView == nil {
            self.descriptionView = UILabel()
            self.descriptionView?.numberOfLines = 0
            self.descriptionView?.lineBreakMode = .byTruncatingTail
            self.addSubview(self.descriptionView!)
        }

        if let view = self.descriptionView {
            view.frame = getCGRact(call)
            view.backgroundColor = .clear
            updateTextStyles(view, call)
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
                view.contentMode = object_fit == "crop" ? .scaleAspectFill : .scaleAspectFit
                
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
            self.callToActionView = UILabel()
            self.callToActionView?.numberOfLines = 1
            self.callToActionView?.lineBreakMode = .byTruncatingTail
            self.addSubview(self.callToActionView!)
        }

        if let view = self.callToActionView {
            view.frame = getCGRact(call)
            view.clipsToBounds = true
            view.textAlignment = .center
            view.backgroundColor = .clear
            
            if let arg = call.arguments as? [String: Any], let styles = arg["styles"] as? [String: Any] {
                if let border_radius = styles["border_radius"] as? NSNumber {
                    view.layer.cornerRadius = CGFloat(border_radius.doubleValue)
                } else {
                    view.layer.cornerRadius = 0
                }
            }

            updateTextStyles(view, call)
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
    
    private func updateTextStyles(_ view: UILabel, _ call: FlutterMethodCall) {
        if let arg = call.arguments as? [String: Any], let styles = arg["styles"] as? [String: Any] {
            if let color = styles["color"] as? String {
                view.textColor = UIColor(hex: color)
            }

            if let background_color = styles["background_color"] as? String {
                view.backgroundColor = UIColor(hex: background_color)
            }

            let font_size = styles["font_size"] as? CGFloat
            let font_weight = styles["font_weight"] as? String
            let font_family = styles["font_family"] as? String

            view.font = buildFont(family: font_family, weight: font_weight, size: font_size, currentFont: view.font)

            if let max_lines = styles["max_lines"] as? Int {
                view.numberOfLines = max_lines
            }

            if let text_overflow = styles["text_overflow"] as? String {
                switch text_overflow {
                case "ellipsis", "fade":
                    view.lineBreakMode = .byTruncatingTail
                case "clip":
                    view.lineBreakMode = .byClipping
                case "visible":
                    view.lineBreakMode = .byClipping
                    view.clipsToBounds = false
                default:
                    view.lineBreakMode = .byTruncatingTail
                }
            }
        }
    }

    private func buildFont(family: String?, weight: String?, size: CGFloat?, currentFont: UIFont) -> UIFont {
        let fontSize = size ?? currentFont.pointSize
        let fontWeight = weight?.toUIFontWeight() ?? .regular

        if let family = family {
            let base = UIFont(name: family, size: fontSize)!

            let descriptor = base.fontDescriptor.addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.weight: fontWeight]
            ])

            return UIFont(descriptor: descriptor, size: fontSize)
        } else {
            return UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
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
