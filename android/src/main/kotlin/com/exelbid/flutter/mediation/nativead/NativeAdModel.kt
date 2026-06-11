package com.exelbid.flutter.mediation.nativead

/**
 * Normalized native ad assets returned by every native adapter's load.
 * Mirrors iOS `EBNativeAdModel` / the Dart `ExelbidNativeAdData`.
 */
data class NativeAdModel(
    val title: String? = null,
    val body: String? = null,
    val callToAction: String? = null,
    val sponsored: String? = null,
    val displayUrl: String? = null,
    val iconImageUrl: String? = null,
    val mainImageUrl: String? = null,
    val logoImageUrl: String? = null,
    val hasVideo: Boolean = false,
    // Data-only assets (no slot; surfaced via onData).
    val secondaryBody: String? = null,
    val phone: String? = null,
    val address: String? = null,
    val rating: String? = null,
    val likes: String? = null,
    val downloads: String? = null,
    val price: String? = null,
    val salePrice: String? = null,
)
