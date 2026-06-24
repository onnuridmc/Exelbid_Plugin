package com.exelbid.flutter.mediation.builtin

import android.content.Context
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.RequestConfiguration

/** Shared, idempotent Google Mobile Ads initialization for the AdMob adapters. */
internal object AdMobSupport {
    @Volatile
    private var initialized = false

    /**
     * Initializes Google Mobile Ads once, **off the main thread**.
     *
     * `MobileAds.initialize()` does disk I/O / mediation-adapter discovery and can
     * block the caller for hundreds of ms on first run; Google explicitly
     * recommends a background thread. Adapters call `loadAd()` immediately after
     * this returns and GMA tolerates requests issued before init completes, so we
     * don't wait for the callback — we just make sure the blocking call never runs
     * on the main thread. The flag is flipped up front (under the lock) so a
     * second concurrent load doesn't spawn a duplicate init thread.
     */
    fun ensureInitialized(context: Context) {
        if (initialized) return
        val appContext = context.applicationContext
        synchronized(this) {
            if (initialized) return
            initialized = true
        }
        Thread({ MobileAds.initialize(appContext) }, "exelbid-admob-init").start()
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
