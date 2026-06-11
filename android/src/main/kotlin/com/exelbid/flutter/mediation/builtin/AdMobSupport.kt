package com.exelbid.flutter.mediation.builtin

import android.content.Context
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.RequestConfiguration

/** Shared, idempotent Google Mobile Ads initialization for the AdMob adapters. */
internal object AdMobSupport {
    @Volatile
    private var initialized = false

    fun ensureInitialized(context: Context) {
        if (initialized) return
        synchronized(this) {
            if (!initialized) {
                MobileAds.initialize(context.applicationContext)
                initialized = true
            }
        }
    }

    /**
     * Applies the COPPA flag globally for AdMob via child-directed treatment.
     * Only acts when `coppa` is present in [options]. (AdMob applies this
     * process-wide, not per-request.)
     */
    fun applyCoppa(options: Map<String, Any?>?) {
        val coppa = options?.get("coppa") as? Boolean ?: return
        val tag = if (coppa) {
            RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_TRUE
        } else {
            RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_FALSE
        }
        MobileAds.setRequestConfiguration(
            RequestConfiguration.Builder().setTagForChildDirectedTreatment(tag).build(),
        )
    }
}
