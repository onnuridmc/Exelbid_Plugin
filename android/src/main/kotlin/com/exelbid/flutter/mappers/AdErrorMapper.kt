package com.exelbid.flutter.mappers

/**
 * Builds the `"error"` payload map decoded by Dart `AdError.fromMap`.
 *
 * Codes match iOS `EBAdError`/`AdErrorMapper` (and the Dart sealed class):
 * 1 invalidAdUnitId · 2 noFill · 3 network · 4 httpStatus(+statusCode) ·
 * 5 decoding · 6 vastParsing · 7 mediaFileUnavailable · 8 playback ·
 * 9 notReady · 10 canceled · else unknown.
 */
object AdErrorMapper {

    const val CODE_NO_FILL = 2

    fun encode(code: Int, message: String, statusCode: Int? = null): Map<String, Any?> =
        buildMap {
            put("code", code)
            put("message", message)
            if (statusCode != null) put("statusCode", statusCode)
        }

    /** Terminal "waterfall exhausted / no ad" error (Dart `NoFillError`). */
    fun noFill(message: String = "No ad available after mediation waterfall"): Map<String, Any?> =
        encode(CODE_NO_FILL, message)
}
