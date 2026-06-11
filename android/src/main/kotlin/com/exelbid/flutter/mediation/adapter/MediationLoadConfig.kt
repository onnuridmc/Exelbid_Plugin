package com.exelbid.flutter.mediation.adapter

import android.app.Activity
import android.content.Context
import com.exelbid.flutter.mediation.nativead.NativeAdRendering

/**
 * Input for a single waterfall step: load this network's ad for [unitId].
 *
 * [activity] may be null when no Activity is currently attached; interstitial
 * and several third-party SDKs require it and should fail the step (advancing
 * the waterfall) when it is missing.
 */
data class MediationLoadConfig(
    /** The winning network's own placement id (the `poll()` pair's second). */
    val unitId: String,
    val context: Context,
    val activity: Activity?,
    /** Banner size in logical dp (null for non-banner formats). */
    val widthDp: Int? = null,
    val heightDp: Int? = null,
    /** Ad targeting/options forwarded from Dart (`AdOptions.toMap()`). */
    val options: Map<String, Any?>? = null,
    /**
     * Host slot rendering (NATIVE only). Provided when the slots are placed so a
     * network whose load needs the asset views up-front (ExelBid in-house) can
     * build its binder before loading. Null for banner/interstitial.
     */
    val rendering: NativeAdRendering? = null,
)
