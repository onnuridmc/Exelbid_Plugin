package com.exelbid.flutter.mappers

import com.exelbid.flutter.mediation.nativead.NativeAdModel

/**
 * Encodes a [NativeAdModel] into the `data` map carried by the native `onLoad`
 * event. Keys match the Dart `ExelbidNativeAdData.fromMap` (and iOS
 * `NativeAdDataMapper`).
 */
object NativeAdDataMapper {
    fun encode(m: NativeAdModel): Map<String, Any?> = buildMap {
        m.title?.let { put("title", it) }
        m.body?.let { put("body", it) }
        m.secondaryBody?.let { put("secondaryBody", it) }
        m.callToAction?.let { put("callToAction", it) }
        m.sponsored?.let { put("sponsored", it) }
        m.displayUrl?.let { put("displayUrl", it) }
        m.phone?.let { put("phone", it) }
        m.address?.let { put("address", it) }
        m.iconImageUrl?.let { put("iconImageUrl", it) }
        m.mainImageUrl?.let { put("mainImageUrl", it) }
        m.logoImageUrl?.let { put("logoImageUrl", it) }
        m.rating?.let { put("rating", it) }
        m.likes?.let { put("likes", it) }
        m.downloads?.let { put("downloads", it) }
        m.price?.let { put("price", it) }
        m.salePrice?.let { put("salePrice", it) }
        put("hasVideo", m.hasVideo)
    }
}
