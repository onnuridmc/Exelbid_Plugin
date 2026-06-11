import Foundation

enum AdErrorMapper {
    /// Encodes an NSError (from ExelBidSDK's onFailureBlock) into a Dart-friendly map.
    /// {
    ///   "code": Int,         // 1..10 matching AdErrorCode
    ///   "message": String,
    ///   "statusCode": Int?   // only present for code == 4 (httpStatus)
    /// }
    static func encode(_ error: NSError) -> [String: Any] {
        var payload: [String: Any] = [
            "code": error.code,
            "message": error.localizedDescription,
        ]
        // ExelBidSDK's `EBAdError.asNSError` stores the HTTP status under
        // "HTTPStatusCode" (only for code == 4 / httpStatus). Forward it as
        // `statusCode` so `HttpStatusAdError` on the Dart side is populated.
        if let statusCode = error.userInfo["HTTPStatusCode"] as? Int {
            payload["statusCode"] = statusCode
        }
        return payload
    }
}
