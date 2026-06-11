import Foundation

enum ChannelNames {
    static let global = "com.exelbid/flutter"

    enum Banner {
        static let viewType = "com.exelbid/flutter/banner"
        static func method(forViewId viewId: Int64) -> String {
            "com.exelbid/flutter/banner/\(viewId)"
        }
        static func events(forViewId viewId: Int64) -> String {
            "com.exelbid/flutter/banner/\(viewId)/events"
        }
    }

    enum Native {
        static let viewType = "com.exelbid/flutter/native"
        static func method(forViewId viewId: Int64) -> String {
            "com.exelbid/flutter/native/\(viewId)"
        }
        static func events(forViewId viewId: Int64) -> String {
            "com.exelbid/flutter/native/\(viewId)/events"
        }
    }

    enum Video {
        static func method(forId id: String) -> String {
            "com.exelbid/flutter/video/\(id)"
        }
        static func events(forId id: String) -> String {
            "com.exelbid/flutter/video/\(id)/events"
        }
    }

    enum Interstitial {
        static func method(forId id: String) -> String {
            "com.exelbid/flutter/interstitial/\(id)"
        }
        static func events(forId id: String) -> String {
            "com.exelbid/flutter/interstitial/\(id)/events"
        }
    }

    // MARK: - Mediation surfaces

    enum MediatedBanner {
        static let viewType = "com.exelbid/flutter/mediated_banner"
        static func events(forViewId viewId: Int64) -> String {
            "com.exelbid/flutter/mediated_banner/\(viewId)/events"
        }
    }

    enum MediatedNative {
        static let viewType = "com.exelbid/flutter/mediated_native"
        static func method(forViewId viewId: Int64) -> String {
            "com.exelbid/flutter/mediated_native/\(viewId)"
        }
        static func events(forViewId viewId: Int64) -> String {
            "com.exelbid/flutter/mediated_native/\(viewId)/events"
        }
    }

    enum MediatedVideo {
        static func method(forId id: String) -> String {
            "com.exelbid/flutter/mediated_video/\(id)"
        }
        static func events(forId id: String) -> String {
            "com.exelbid/flutter/mediated_video/\(id)/events"
        }
    }

    enum MediatedInterstitial {
        static func method(forId id: String) -> String {
            "com.exelbid/flutter/mediated_interstitial/\(id)"
        }
        static func events(forId id: String) -> String {
            "com.exelbid/flutter/mediated_interstitial/\(id)/events"
        }
    }
}
