import CoreLocation
import ExelBidSDK

enum AdOptionsMapper {
    /// Decodes the EBAdOptions payload sent from Dart.
    /// Expected map shape:
    /// {
    ///   "keywords": {String: String},
    ///   "yearOfBirth": Int,        // 0 means unspecified
    ///   "gender": Int,             // 0 unspecified / 1 male / 2 female
    ///   "location": {"latitude": Double, "longitude": Double}?,
    ///   "coppa": Bool,
    ///   "testing": Bool,
    ///   "videoSkipMin": Int?,
    ///   "videoSkipAfter": Int?
    /// }
    static func decode(_ map: [String: Any]?) -> EBAdOptions {
        let options = EBAdOptions()
        guard let map = map else { return options }

        if let kw = map["keywords"] as? [String: String] {
            options.keywords = kw
        }
        if let year = map["yearOfBirth"] as? Int {
            options.yearOfBirth = year
        }
        if let genderRaw = map["gender"] as? Int,
           let gender = Gender(rawValue: genderRaw) {
            options.gender = gender
        }
        if let loc = map["location"] as? [String: Double],
           let lat = loc["latitude"], let lon = loc["longitude"] {
            options.location = CLLocation(latitude: lat, longitude: lon)
        }
        if let coppa = map["coppa"] as? Bool {
            options.coppa = coppa
        }
        if let testing = map["testing"] as? Bool {
            options.testing = testing
        }
        if let skipMin = map["videoSkipMin"] as? Int {
            options.videoSkipMin = skipMin
        }
        if let skipAfter = map["videoSkipAfter"] as? Int {
            options.videoSkipAfter = skipAfter
        }
        return options
    }
}
