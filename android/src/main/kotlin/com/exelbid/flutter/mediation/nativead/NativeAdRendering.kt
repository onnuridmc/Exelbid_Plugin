package com.exelbid.flutter.mediation.nativead

import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView

/**
 * Host slot access for native rendering — the adapters read these to wire the
 * network SDK's tracking to the host's asset views. Mirrors iOS
 * `EBNativeAdRendering`.
 *
 * [container] is the root that holds all slot views (the view a network
 * container wraps when reparenting is required). Any getter may return null when
 * the host didn't place that slot.
 */
interface NativeAdRendering {
    val container: ViewGroup

    fun titleView(): TextView?
    fun bodyView(): TextView?
    fun callToActionView(): TextView?

    /**
     * The CTA slot as a [Button], for networks whose SDK requires a real
     * `Button` (AdFit's `setCallToActionButton`). Backs the same view as
     * [callToActionView] (a `Button` is a `TextView`); null when no CTA slot was
     * placed.
     */
    fun callToActionButton(): Button?

    fun sponsoredView(): TextView?
    fun displayUrlView(): TextView?

    fun iconView(): ImageView?
    fun logoView(): ImageView?
    fun privacyView(): ImageView?

    /**
     * The single media slot for the main creative (image or video) — an empty
     * container at the slot's measured frame. Mirrors iOS `nativeMediaView()`.
     *
     * - Mediation networks (AdMob/FAN/AdFit) inject their own media view
     *   (`MediaView` / `AdFitMediaView`) as a full-bleed child here.
     * - ExelBid's in-house binder uses this as the `mediaViewId` for video.
     */
    fun mediaContainer(): ViewGroup?

    /**
     * Inner [ImageView] living inside [mediaContainer], used only by ExelBid's
     * in-house `NativeViewBinder.mainImageId` for a static main image (the v2
     * SDK fills views by id, so it needs a concrete ImageView). Third-party
     * adapters ignore it and add their own media view to [mediaContainer].
     */
    fun mainImageView(): ImageView?
}
