package com.exelbid.flutter.mediation.builtin

import android.app.Activity
import android.view.View
import android.widget.FrameLayout
import com.exelbid.flutter.mediation.adapter.MediationAdCallback
import com.exelbid.flutter.mediation.adapter.MediationLoadConfig
import com.exelbid.flutter.mediation.adapter.NativeMediationAdapter
import com.exelbid.flutter.mediation.nativead.NativeAdModel
import com.exelbid.flutter.mediation.nativead.NativeAdRendering
import com.exelbid.flutter.mediation.nativead.NativeContainerReparenter
import com.kakao.adfit.ads.na.AdFitMediaView
import com.kakao.adfit.ads.na.AdFitNativeAdBinder
import com.kakao.adfit.ads.na.AdFitNativeAdLayout
import com.kakao.adfit.ads.na.AdFitNativeAdLoader
import com.kakao.adfit.ads.na.AdFitNativeAdRequest
import com.kakao.adfit.ads.na.AdFitNativeAdView

/**
 * Kakao AdFit native adapter. Equivalent to iOS `AdFitNativeAdapter` (networkID
 * "adfit").
 *
 * AdFit's binder fills the provided views itself (no asset getters), so `model()`
 * is minimal (onData best-effort). It requires an [AdFitNativeAdView] container
 * and an [AdFitMediaView]; title + media are mandatory, and the CTA outlet (a
 * real `Button`) is wired from the host's CTA slot when present.
 */
class AdfitNativeAdapter : NativeMediationAdapter {

    override val networkId = "adfit"

    private var binder: AdFitNativeAdBinder? = null
    private var callback: MediationAdCallback? = null
    private var model: NativeAdModel? = null

    override fun load(config: MediationLoadConfig, callback: MediationAdCallback) {
        this.callback = callback
        val loader = AdFitNativeAdLoader.create(config.context, config.unitId)
        loader.loadAd(
            AdFitNativeAdRequest.Builder().build(),
            object : AdFitNativeAdLoader.AdLoadListener {
                override fun onAdLoaded(b: AdFitNativeAdBinder) {
                    binder = b
                    model = NativeAdModel() // AdFit exposes no asset getters.
                    this@AdfitNativeAdapter.callback?.onLoaded()
                }

                override fun onAdLoadError(errorCode: Int) {
                    this@AdfitNativeAdapter.callback?.onFailed("AdFit native failed ($errorCode)")
                }
            },
        )
    }

    override fun model(): NativeAdModel? = model

    override fun bind(rendering: NativeAdRendering, activity: Activity?) {
        val b = binder ?: return
        val title = rendering.titleView() ?: return // required by AdFit
        // AdFit's view constructors hard-require an Activity context; the
        // PlatformView's container.context is the application context.
        val context = activity ?: return

        // AdFit reports taps through its own click listener (no impression
        // callback), so surface clicks to Dart — matching AdMob/FAN/iOS.
        b.onAdClickListener = object : AdFitNativeAdBinder.OnAdClickListener {
            override fun onAdClicked(view: View) {
                this@AdfitNativeAdapter.callback?.onClicked()
            }
        }

        val adfitView = AdFitNativeAdView(context)
        NativeContainerReparenter.reparentChildrenInto(rendering.container, adfitView)

        // AdFit media view full-bleed in the host's single media slot
        // (mirrors iOS `nativeMediaView()`).
        val media = AdFitMediaView(context)
        val slot = rendering.mediaContainer()
        if (slot != null) {
            rendering.mainImageView()?.visibility = View.GONE
            slot.addView(media, fullBleed())
        } else {
            adfitView.addView(media, fullBleed())
        }

        val builder = AdFitNativeAdLayout.Builder(adfitView)
            .setTitleView(title)
            .setMediaView(media)
        rendering.bodyView()?.let { builder.setBodyView(it) }
        rendering.iconView()?.let { builder.setProfileIconView(it) }
        rendering.sponsoredView()?.let { builder.setProfileNameView(it) }
        // AdFit's CTA outlet is strictly a `Button`; the host CTA slot is one.
        rendering.callToActionButton()?.let { builder.setCallToActionButton(it) }

        b.bind(builder.build())
    }

    override fun unbind() {
        binder?.unbind()
    }

    override fun cancel() = release()

    override fun destroy() = release()

    private fun release() {
        binder?.unbind()
        binder = null
        callback = null
    }

    private fun fullBleed() = FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT,
    )
}
