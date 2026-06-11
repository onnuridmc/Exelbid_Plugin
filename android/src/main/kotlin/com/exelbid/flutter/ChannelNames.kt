package com.exelbid.flutter

/**
 * Channel name registry — kept byte-for-byte in sync with the iOS
 * `ChannelNames.swift` and the Dart-side string literals. Changing a name here
 * requires the same change on both other sides.
 */
object ChannelNames {
    const val GLOBAL = "com.exelbid/flutter"

    // MARK: - Mediation surfaces (1차 구현 대상: Banner, Interstitial)

    object MediatedBanner {
        const val VIEW_TYPE = "com.exelbid/flutter/mediated_banner"
        fun events(viewId: Long) = "com.exelbid/flutter/mediated_banner/$viewId/events"
    }

    object MediatedInterstitial {
        fun method(id: String) = "com.exelbid/flutter/mediated_interstitial/$id"
        fun events(id: String) = "com.exelbid/flutter/mediated_interstitial/$id/events"
    }

    // MARK: - Mediation surfaces (추후: Native, Video)

    object MediatedNative {
        const val VIEW_TYPE = "com.exelbid/flutter/mediated_native"
        fun method(viewId: Long) = "com.exelbid/flutter/mediated_native/$viewId"
        fun events(viewId: Long) = "com.exelbid/flutter/mediated_native/$viewId/events"
    }

    object MediatedVideo {
        fun method(id: String) = "com.exelbid/flutter/mediated_video/$id"
        fun events(id: String) = "com.exelbid/flutter/mediated_video/$id/events"
    }

    // MARK: - 비미디에이션 단일 표면

    object Banner {
        const val VIEW_TYPE = "com.exelbid/flutter/banner"
        fun method(viewId: Long) = "com.exelbid/flutter/banner/$viewId"
        fun events(viewId: Long) = "com.exelbid/flutter/banner/$viewId/events"
    }

    object Native {
        const val VIEW_TYPE = "com.exelbid/flutter/native"
        fun method(viewId: Long) = "com.exelbid/flutter/native/$viewId"
        fun events(viewId: Long) = "com.exelbid/flutter/native/$viewId/events"
    }

    object Interstitial {
        fun method(id: String) = "com.exelbid/flutter/interstitial/$id"
        fun events(id: String) = "com.exelbid/flutter/interstitial/$id/events"
    }

    object Video {
        fun method(id: String) = "com.exelbid/flutter/video/$id"
        fun events(id: String) = "com.exelbid/flutter/video/$id/events"
    }
}
