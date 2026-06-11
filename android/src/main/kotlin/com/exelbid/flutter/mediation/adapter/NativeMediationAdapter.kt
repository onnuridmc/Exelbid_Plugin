package com.exelbid.flutter.mediation.adapter

import android.app.Activity
import com.exelbid.flutter.mediation.AdFormat
import com.exelbid.flutter.mediation.nativead.NativeAdModel
import com.exelbid.flutter.mediation.nativead.NativeAdRendering

/**
 * Native adapter — `load()` produces normalized assets ([model]); `bind()`
 * renders them into the host slots and arms the network's tracking. Mirrors iOS
 * `EBNativeMediationAdapter`.
 *
 * Some networks (ExelBid in-house) need the host slot views at load time to
 * build their binder — those read [MediationLoadConfig.rendering] in `load()`,
 * and their `bind()` only triggers the final show. Third-party networks load
 * without the views and do the real wiring in `bind()`.
 */
interface NativeMediationAdapter : MediationAdapter {
    override val format: AdFormat
        get() = AdFormat.NATIVE

    /** Normalized assets, valid after [MediationAdCallback.onLoaded]. */
    fun model(): NativeAdModel?

    /** Render assets into [rendering]'s slots and arm tracking. */
    fun bind(rendering: NativeAdRendering, activity: Activity?)

    fun unbind()
}
