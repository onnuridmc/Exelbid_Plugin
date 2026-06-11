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
import com.facebook.ads.Ad
import com.facebook.ads.AdError
import com.facebook.ads.AdOptionsView
import com.facebook.ads.MediaView
import com.facebook.ads.NativeAd
import com.facebook.ads.NativeAdLayout
import com.facebook.ads.NativeAdListener

/**
 * Facebook Audience Network native adapter. Equivalent to iOS `FANNativeAdapter`
 * (networkID "fan"). FAN renders media via its own [MediaView] and requires an
 * [AdOptionsView] (AdChoices). The host slots are reparented into a
 * [NativeAdLayout]; text slots are filled, the main-image slot becomes a FAN
 * MediaView, and the views are registered for interaction.
 */
class FanNativeAdapter : NativeMediationAdapter {

    override val networkId = "fan"

    private var nativeAd: NativeAd? = null
    private var callback: MediationAdCallback? = null
    private var model: NativeAdModel? = null

    override fun load(config: MediationLoadConfig, callback: MediationAdCallback) {
        this.callback = callback
        FanSupport.applyCoppa(config.options)
        val ad = NativeAd(config.context, config.unitId)
        val listener = object : NativeAdListener {
            override fun onError(a: Ad?, error: AdError?) {
                this@FanNativeAdapter.callback?.onFailed(error?.errorMessage ?: "FAN native failed")
            }

            override fun onAdLoaded(a: Ad?) {
                model = toModel(ad)
                this@FanNativeAdapter.callback?.onLoaded()
            }

            override fun onAdClicked(a: Ad?) {
                this@FanNativeAdapter.callback?.onClicked()
            }

            override fun onLoggingImpression(a: Ad?) {
                this@FanNativeAdapter.callback?.onImpression()
            }

            override fun onMediaDownloaded(a: Ad?) {}
        }
        nativeAd = ad
        ad.loadAd(ad.buildLoadAdConfig().withAdListener(listener).build())
    }

    override fun model(): NativeAdModel? = model

    override fun bind(rendering: NativeAdRendering, activity: Activity?) {
        val ad = nativeAd ?: return
        val context = rendering.container.context
        val layout = NativeAdLayout(context)
        NativeContainerReparenter.reparentChildrenInto(rendering.container, layout)

        rendering.titleView()?.text = ad.advertiserName
        rendering.bodyView()?.text = ad.adBodyText
        rendering.callToActionView()?.text = ad.adCallToAction

        // Main media → FAN MediaView full-bleed in the host's single media slot
        // (mirrors iOS `nativeMediaView()`).
        val media = MediaView(context)
        val slot = rendering.mediaContainer()
        if (slot != null) {
            rendering.mainImageView()?.visibility = View.GONE
            slot.addView(media, fullBleed())
        } else {
            layout.addView(media, fullBleed())
        }

        // AdChoices (policy) at the privacy slot frame, else top-end.
        val adOptions = AdOptionsView(context, ad, layout)
        val privacy = rendering.privacyView()
        privacy?.visibility = View.GONE
        layout.addView(adOptions, copyParams(privacy))

        val clickable = listOfNotNull(
            rendering.titleView(),
            rendering.callToActionView(),
            media as View,
        )
        val icon = rendering.iconView()
        if (icon != null) {
            ad.registerViewForInteraction(layout, media, icon, clickable)
        } else {
            ad.registerViewForInteraction(layout, media, clickable)
        }
    }

    override fun unbind() {
        nativeAd?.unregisterView()
    }

    override fun cancel() = release()

    override fun destroy() = release()

    private fun release() {
        nativeAd?.unregisterView()
        nativeAd?.destroy()
        nativeAd = null
        callback = null
    }

    private fun fullBleed() = FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT,
    )

    private fun copyParams(view: View?): FrameLayout.LayoutParams {
        val src = view?.layoutParams as? FrameLayout.LayoutParams
        return if (src != null) {
            FrameLayout.LayoutParams(src.width, src.height).also {
                it.leftMargin = src.leftMargin
                it.topMargin = src.topMargin
                it.gravity = src.gravity
            }
        } else {
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
            )
        }
    }

    private fun toModel(ad: NativeAd): NativeAdModel = NativeAdModel(
        title = ad.advertiserName,
        body = ad.adBodyText,
        callToAction = ad.adCallToAction,
        hasVideo = true, // FAN media is delivered via MediaView (image or video).
    )
}
