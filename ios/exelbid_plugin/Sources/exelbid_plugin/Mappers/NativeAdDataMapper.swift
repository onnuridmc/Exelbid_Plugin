import ExelBidSDK
import Foundation

/// Common asset-accessor surface shared by `EBNativeAd` and
/// `EBMediatedNativeAd`. Both already expose these identically, so we just
/// declare conformance.
protocol NativeAdDataProviding {
    var titleText: String? { get }
    var bodyText: String? { get }
    var secondaryBodyText: String? { get }
    var callToActionText: String? { get }
    var sponsoredText: String? { get }
    var displayURLText: String? { get }
    var phoneText: String? { get }
    var addressText: String? { get }
    var iconImageURLString: String? { get }
    var mainImageURLString: String? { get }
    var logoImageURLString: String? { get }
    var ratingText: String? { get }
    var likesText: String? { get }
    var downloadsText: String? { get }
    var priceText: String? { get }
    var salePriceText: String? { get }
    var hasVideoAsset: Bool { get }
}

extension EBNativeAd: NativeAdDataProviding {}
extension EBMediatedNativeAd: NativeAdDataProviding {}

/// Encodes a native ad's asset values into the `"data"` map sent with the
/// `onLoad` event, mirroring `ExelbidNativeAdData` on the Dart side. Lets the
/// host render data-only assets (no rendering slot exists for them).
enum NativeAdDataMapper {
    static func encode(_ ad: NativeAdDataProviding) -> [String: Any] {
        var m: [String: Any] = [:]
        if let v = ad.titleText { m["title"] = v }
        if let v = ad.bodyText { m["body"] = v }
        if let v = ad.secondaryBodyText { m["secondaryBody"] = v }
        if let v = ad.callToActionText { m["callToAction"] = v }
        if let v = ad.sponsoredText { m["sponsored"] = v }
        if let v = ad.displayURLText { m["displayUrl"] = v }
        if let v = ad.phoneText { m["phone"] = v }
        if let v = ad.addressText { m["address"] = v }
        if let v = ad.iconImageURLString { m["iconImageUrl"] = v }
        if let v = ad.mainImageURLString { m["mainImageUrl"] = v }
        if let v = ad.logoImageURLString { m["logoImageUrl"] = v }
        if let v = ad.ratingText { m["rating"] = v }
        if let v = ad.likesText { m["likes"] = v }
        if let v = ad.downloadsText { m["downloads"] = v }
        if let v = ad.priceText { m["price"] = v }
        if let v = ad.salePriceText { m["salePrice"] = v }
        m["hasVideo"] = ad.hasVideoAsset
        return m
    }
}
