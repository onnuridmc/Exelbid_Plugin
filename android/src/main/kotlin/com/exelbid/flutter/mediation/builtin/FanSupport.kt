package com.exelbid.flutter.mediation.builtin

import com.facebook.ads.AdSettings

/** Shared FAN (Audience Network) configuration helpers. */
internal object FanSupport {
    /**
     * Applies the COPPA flag for FAN. FAN models child-directed/COPPA apps as
     * "mixed audience". Only acts when `coppa` is present in [options].
     */
    fun applyCoppa(options: Map<String, Any?>?) {
        val coppa = options?.get("coppa") as? Boolean ?: return
        AdSettings.setMixedAudience(coppa)
    }
}
