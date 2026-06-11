import ExelBidSDK
import Flutter
import UIKit

/// Native rendering view driven by Flutter-side slot widgets.
///
/// Each `setXxxView` call positions a SDK-owned subview at the exact frame
/// the Flutter host measured for its slot. The SDK then fills the
/// corresponding asset (title text, main image, CTA, etc.) through the
/// `EBNativeAdRendering` getters.
final class SlotNativeRenderingView: UIView, EBNativeAdRendering {

    private var titleLabel: PaddedLabel?
    private var descriptionLabel: PaddedLabel?
    /// Call-to-action slot. `EBNativeAdRendering` exposes the CTA as a
    /// `UIButton` (not a label) so mediation adapters whose SDKs require a
    /// tappable CTA button (e.g. Kakao AdFit) can register it directly; the
    /// SDK / network sets the button title from the ad's CTA text.
    private var ctaButton: UIButton?
    private var sponsoredLabel: PaddedLabel?
    private var displayUrlLabel: PaddedLabel?
    private var iconImageView: UIImageView?
    /// Empty container for the main creative (image or VAST video) — the single
    /// media slot the SDK fills via `nativeMediaView()`. Not a `UIImageView`:
    /// the SDK / winning mediation network inserts its own image view or media
    /// view into this container.
    private var mediaView: UIView?
    private var logoImageView: UIImageView?
    private var privacyIconImageView: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    // MARK: - Slot mutation

    func setTitleView(_ call: FlutterMethodCall) {
        if titleLabel == nil {
            let label = PaddedLabel()
            label.numberOfLines = 0
            label.backgroundColor = .clear
            addSubview(label)
            titleLabel = label
        }
        apply(call, to: titleLabel)
    }

    func setDescriptionView(_ call: FlutterMethodCall) {
        if descriptionLabel == nil {
            let label = PaddedLabel()
            label.numberOfLines = 0
            label.backgroundColor = .clear
            addSubview(label)
            descriptionLabel = label
        }
        apply(call, to: descriptionLabel)
    }

    func setCallToActionView(_ call: FlutterMethodCall) {
        if ctaButton == nil {
            let button = UIButton(type: .custom)
            button.titleLabel?.numberOfLines = 1
            button.contentHorizontalAlignment = .center
            button.backgroundColor = .clear
            addSubview(button)
            ctaButton = button
        }
        apply(call, to: ctaButton)
    }

    func setSponsoredView(_ call: FlutterMethodCall) {
        if sponsoredLabel == nil {
            let label = PaddedLabel()
            label.numberOfLines = 1
            label.backgroundColor = .clear
            addSubview(label)
            sponsoredLabel = label
        }
        apply(call, to: sponsoredLabel)
    }

    func setDisplayUrlView(_ call: FlutterMethodCall) {
        if displayUrlLabel == nil {
            let label = PaddedLabel()
            label.numberOfLines = 1
            label.backgroundColor = .clear
            addSubview(label)
            displayUrlLabel = label
        }
        apply(call, to: displayUrlLabel)
    }

    func setLogoImageView(_ call: FlutterMethodCall) {
        if logoImageView == nil {
            let image = UIImageView()
            image.contentMode = .scaleAspectFit
            image.clipsToBounds = true
            addSubview(image)
            logoImageView = image
        }
        apply(call, to: logoImageView)
    }

    func setIconImageView(_ call: FlutterMethodCall) {
        if iconImageView == nil {
            let image = UIImageView()
            image.contentMode = .scaleAspectFit
            image.clipsToBounds = true
            addSubview(image)
            iconImageView = image
        }
        apply(call, to: iconImageView)
    }

    func setMediaView(_ call: FlutterMethodCall) {
        if mediaView == nil {
            let container = UIView()
            container.backgroundColor = .clear
            container.clipsToBounds = true
            addSubview(container)
            mediaView = container
        }
        apply(call, to: mediaView)
    }

    func setPrivacyInformationIconImage(_ call: FlutterMethodCall) {
        if privacyIconImageView == nil {
            let image = UIImageView()
            image.contentMode = .scaleAspectFit
            image.clipsToBounds = true
            addSubview(image)
            privacyIconImageView = image
        }
        apply(call, to: privacyIconImageView)
    }

    // MARK: - EBNativeAdRendering

    func nativeTitleTextLabel() -> UILabel?            { titleLabel }
    func nativeMainTextLabel() -> UILabel?             { descriptionLabel }
    func nativeCallToActionButton() -> UIButton?       { ctaButton }
    func nativeSponsoredTextLabel() -> UILabel?        { sponsoredLabel }
    func nativeDisplayURLTextLabel() -> UILabel?       { displayUrlLabel }
    func nativeIconImageView() -> UIImageView?         { iconImageView }
    func nativeMediaView() -> UIView?                  { mediaView }
    func nativeLogoImageView() -> UIImageView?         { logoImageView }
    func nativePrivacyInformationIconImageView() -> UIImageView? {
        privacyIconImageView
    }

    // MARK: - Frame + style application

    /// Positions `view` at the slot's measured frame and applies the optional
    /// `style` map forwarded from Dart.
    private func apply(_ call: FlutterMethodCall, to view: UIView?) {
        guard let view = view else { return }
        view.frame = rect(from: call)

        guard let args = call.arguments as? [String: Any],
              let style = args["style"] as? [String: Any] else { return }
        applyCommonStyle(style, to: view)
        if let button = view as? UIButton { applyButtonStyle(style, to: button) }
        else if let label = view as? UILabel { applyLabelStyle(style, to: label) }
        if let image = view as? UIImageView { applyImageStyle(style, to: image) }
    }

    private func applyCommonStyle(_ s: [String: Any], to view: UIView) {
        if let bg = color(s["backgroundColor"]) { view.backgroundColor = bg }
        if let radius = s["cornerRadius"] as? NSNumber {
            view.layer.cornerRadius = CGFloat(radius.doubleValue)
            view.layer.masksToBounds = true
        }
        if let width = s["borderWidth"] as? NSNumber {
            view.layer.borderWidth = CGFloat(width.doubleValue)
        }
        if let border = color(s["borderColor"]) {
            view.layer.borderColor = border.cgColor
        }
    }

    private func applyLabelStyle(_ s: [String: Any], to label: UILabel) {
        if let textColor = color(s["textColor"]) { label.textColor = textColor }

        let family = (s["fontFamily"] as? String).flatMap { $0.isEmpty ? nil : $0 }
        let size = (s["fontSize"] as? NSNumber).map { CGFloat($0.doubleValue) }
        let weight = (s["fontWeight"] as? NSNumber).map { fontWeight(from: $0.intValue) }
        if let family = family {
            label.font = font(family: family,
                              size: size ?? label.font.pointSize,
                              weight: weight)
        } else if size != nil || weight != nil {
            label.font = .systemFont(
                ofSize: size ?? label.font.pointSize,
                weight: weight ?? .regular
            )
        }

        if let align = s["textAlign"] as? String {
            label.textAlignment = textAlignment(from: align)
        }
        if let lines = s["maxLines"] as? NSNumber {
            label.numberOfLines = lines.intValue
        }
        if let padded = label as? PaddedLabel, let p = s["padding"] as? [String: Any] {
            padded.textInsets = UIEdgeInsets(
                top: cgFloat(p["top"]),
                left: cgFloat(p["left"]),
                bottom: cgFloat(p["bottom"]),
                right: cgFloat(p["right"])
            )
        }
        if let overflow = s["overflow"] as? String {
            label.lineBreakMode = lineBreakMode(from: overflow)
        }
    }

    /// Applies the text style to a CTA `UIButton`, mapping the same style map
    /// used for labels onto the button's title label / content insets. The
    /// title text itself is set later by the SDK or winning mediation network.
    private func applyButtonStyle(_ s: [String: Any], to button: UIButton) {
        if let textColor = color(s["textColor"]) {
            button.setTitleColor(textColor, for: .normal)
        }

        let family = (s["fontFamily"] as? String).flatMap { $0.isEmpty ? nil : $0 }
        let size = (s["fontSize"] as? NSNumber).map { CGFloat($0.doubleValue) }
        let weight = (s["fontWeight"] as? NSNumber).map { fontWeight(from: $0.intValue) }
        let current = button.titleLabel?.font ?? .systemFont(ofSize: UIFont.systemFontSize)
        if let family = family {
            button.titleLabel?.font = font(family: family,
                                           size: size ?? current.pointSize,
                                           weight: weight)
        } else if size != nil || weight != nil {
            button.titleLabel?.font = .systemFont(
                ofSize: size ?? current.pointSize,
                weight: weight ?? .regular
            )
        }

        if let align = s["textAlign"] as? String {
            button.contentHorizontalAlignment = horizontalAlignment(from: align)
        }
        if let lines = s["maxLines"] as? NSNumber {
            button.titleLabel?.numberOfLines = lines.intValue
        }
        if let p = s["padding"] as? [String: Any] {
            button.contentEdgeInsets = UIEdgeInsets(
                top: cgFloat(p["top"]),
                left: cgFloat(p["left"]),
                bottom: cgFloat(p["bottom"]),
                right: cgFloat(p["right"])
            )
        }
        if let overflow = s["overflow"] as? String {
            button.titleLabel?.lineBreakMode = lineBreakMode(from: overflow)
        }
    }

    private func horizontalAlignment(from name: String) -> UIControl.ContentHorizontalAlignment {
        switch name {
        case "left": return .left
        case "right": return .right
        case "center": return .center
        default: return .center
        }
    }

    /// Maps a Dart `TextOverflow` name to a `UILabel` line-break mode. iOS labels
    /// have no fade and always clip to bounds, so `fade` falls back to ellipsis
    /// and `visible` to clipping.
    private func lineBreakMode(from name: String) -> NSLineBreakMode {
        switch name {
        case "clip", "visible": return .byClipping
        case "ellipsis", "fade": return .byTruncatingTail
        default: return .byTruncatingTail
        }
    }

    private func applyImageStyle(_ s: [String: Any], to image: UIImageView) {
        if let mode = s["contentMode"] as? String {
            image.contentMode = contentMode(from: mode)
            image.clipsToBounds = true
        }
    }

    // MARK: - Helpers

    private func rect(from call: FlutterMethodCall) -> CGRect {
        guard let args = call.arguments as? [String: Any] else {
            return .zero
        }
        let x = cgFloat(args["x"])
        let y = cgFloat(args["y"])
        let width = cgFloat(args["width"])
        let height = cgFloat(args["height"])
        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func cgFloat(_ value: Any?) -> CGFloat {
        if let n = value as? NSNumber { return CGFloat(n.doubleValue) }
        if let d = value as? Double { return CGFloat(d) }
        if let i = value as? Int { return CGFloat(i) }
        return 0
    }

    /// Decodes a Dart ARGB int (0xAARRGGBB) into a `UIColor`.
    private func color(_ value: Any?) -> UIColor? {
        guard let n = value as? NSNumber else { return nil }
        let argb = UInt32(truncatingIfNeeded: n.int64Value)
        let a = CGFloat((argb >> 24) & 0xFF) / 255
        let r = CGFloat((argb >> 16) & 0xFF) / 255
        let g = CGFloat((argb >> 8) & 0xFF) / 255
        let b = CGFloat(argb & 0xFF) / 255
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    /// Builds a font for a named family, honoring the optional weight. Falls
    /// back to the family's exact PostScript name, then the system font, if the
    /// family isn't registered with iOS.
    private func font(family: String, size: CGFloat, weight: UIFont.Weight?) -> UIFont {
        var attributes: [UIFontDescriptor.AttributeName: Any] = [.family: family]
        if let weight = weight {
            attributes[.traits] = [UIFontDescriptor.TraitKey.weight: weight]
        }
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        let resolved = UIFont(descriptor: descriptor, size: size)

        // UIFont(descriptor:) silently falls back to the system font when the
        // family is unknown; detect that and try the name as a PostScript name.
        if resolved.familyName != family, let named = UIFont(name: family, size: size) {
            return named
        }
        return resolved
    }

    /// Maps a Flutter `FontWeight.value` (100–900) to a `UIFont.Weight`.
    private func fontWeight(from value: Int) -> UIFont.Weight {
        switch value {
        case ..<150: return .ultraLight
        case 150..<250: return .thin
        case 250..<350: return .light
        case 350..<450: return .regular
        case 450..<550: return .medium
        case 550..<650: return .semibold
        case 650..<750: return .bold
        case 750..<850: return .heavy
        default: return .black
        }
    }

    private func textAlignment(from name: String) -> NSTextAlignment {
        switch name {
        case "left": return .left
        case "right": return .right
        case "center": return .center
        case "justify": return .justified
        default: return .natural
        }
    }

    private func contentMode(from name: String) -> UIView.ContentMode {
        switch name {
        case "fill": return .scaleToFill
        case "cover": return .scaleAspectFill
        case "contain": return .scaleAspectFit
        case "center": return .center
        default: return .scaleAspectFit
        }
    }
}

/// `UILabel` with content insets, so a text slot's background/border can fill the
/// slot frame while its text is padded inward (e.g. button-like CTA slots).
/// `UILabel` has no native content inset, so the draw + sizing rects are inset
/// manually.
final class PaddedLabel: UILabel {

    var textInsets: UIEdgeInsets = .zero {
        didSet { setNeedsDisplay() }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override func textRect(
        forBounds bounds: CGRect,
        limitedToNumberOfLines numberOfLines: Int
    ) -> CGRect {
        let inset = bounds.inset(by: textInsets)
        let rect = super.textRect(forBounds: inset, limitedToNumberOfLines: numberOfLines)
        return rect.inset(by: UIEdgeInsets(
            top: -textInsets.top,
            left: -textInsets.left,
            bottom: -textInsets.bottom,
            right: -textInsets.right
        ))
    }
}
