package com.exelbid.flutter.mediation.adapter

import android.app.Activity
import android.view.View
import com.exelbid.flutter.mediation.AdFormat

/**
 * A mediation adapter wraps one third-party (or in-house) ad SDK for one format.
 *
 * Contract mirrors iOS `EB*MediationAdapter`: "given a unit id, load one ad".
 * Waterfall iteration, per-network timeout, and registration are owned by the
 * orchestrator — adapters never loop.
 */
interface MediationAdapter {
    /** Stable id matching the mediation server's `id` (e.g. "exelbid", "admob"). */
    val networkId: String

    val format: AdFormat

    /** Whether the underlying SDK is linkable/usable at runtime. */
    val isAvailable: Boolean
        get() = true

    /** Begin loading; report the result through [callback]. */
    fun load(config: MediationLoadConfig, callback: MediationAdCallback)

    /** Abort an in-flight load (host `stop()` or orchestrator timeout). */
    fun cancel()

    /** Release the ad and any retained resources. */
    fun destroy()

    // Lifecycle pass-through (banner: ExelBid/AdMob/AdFit need pause/resume).
    fun onPause() {}
    fun onResume() {}
}

/** Banner adapter — exposes the loaded network view for host attachment. */
interface BannerMediationAdapter : MediationAdapter {
    override val format: AdFormat
        get() = AdFormat.BANNER

    /** The network's banner view, valid after [MediationAdCallback.onLoaded]. */
    fun view(): View?
}

/** Interstitial adapter — load then present on an Activity. */
interface InterstitialMediationAdapter : MediationAdapter {
    override val format: AdFormat
        get() = AdFormat.INTERSTITIAL

    fun isReady(): Boolean

    fun show(activity: Activity)
}

/** Video adapter — load then present a full-screen video on an Activity. */
interface VideoMediationAdapter : MediationAdapter {
    override val format: AdFormat
        get() = AdFormat.VIDEO

    fun isReady(): Boolean

    fun show(activity: Activity)
}
