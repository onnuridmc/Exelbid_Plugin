package com.exelbid.flutter.mappers

import android.location.Location
import com.onnuridmc.exelbid.a

/**
 * Applies the `options` map sent from Dart (`AdOptions.toMap()`) to an ExelBid
 * in-house ad object. All ExelBid ad classes (`ExelBidAdView`,
 * `ExelBidInterstitial`, `ExelBidNative`) share the base class
 * `com.onnuridmc.exelbid.a`, which exposes the targeting setters.
 *
 * Map shape (mirrors iOS `AdOptionsMapper`):
 * ```
 * keywords: {String: String}, yearOfBirth: Int (0=unspecified),
 * gender: Int (0 unspecified / 1 male / 2 female),
 * location: {latitude: Double, longitude: Double}?, coppa: Bool, testing: Bool,
 * videoSkipMin: Int?, videoSkipAfter: Int?
 * ```
 *
 * Note: the Android SDK has no `videoSkipMin`/`videoSkipAfter` equivalent, so
 * those are ignored.
 */
object AdOptionsMapper {

    fun apply(target: a, options: Map<String, Any?>?) {
        options ?: return

        (options["testing"] as? Boolean)?.let { target.setTestMode(it) }
        (options["coppa"] as? Boolean)?.let { target.setCoppa(it) }

        (options["yearOfBirth"] as? Number)?.toInt()?.let {
            if (it > 0) target.setYob(it.toString())
        }

        // 0 unspecified → leave unset; 1 male → true; 2 female → false.
        when ((options["gender"] as? Number)?.toInt()) {
            1 -> target.setGender(true)
            2 -> target.setGender(false)
            else -> {}
        }

        (options["keywords"] as? Map<*, *>)?.forEach { (k, v) ->
            if (k is String && v is String) target.addKeyword(k, v)
        }

        (options["location"] as? Map<*, *>)?.let { loc ->
            val lat = (loc["latitude"] as? Number)?.toDouble()
            val lng = (loc["longitude"] as? Number)?.toDouble()
            if (lat != null && lng != null) {
                target.setLocation(
                    Location("flutter").apply {
                        latitude = lat
                        longitude = lng
                    },
                )
            }
        }
    }
}
