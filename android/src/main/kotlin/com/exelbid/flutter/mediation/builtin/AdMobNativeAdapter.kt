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
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdLoader
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.nativead.AdChoicesView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView

/**
 * AdMob native adapter. Equivalent to iOS `AdMobNativeAdapter` (networkID
 * "admob"). `load()` fetches a [NativeAd]; `bind()` slips a [NativeAdView]
 * between the PlatformView root and the slot views, wires the asset outlets, and
 * arms tracking via `setNativeAd`. Media uses AdMob's [MediaView] at the
 * main-image slot frame.
 */
class AdMobNativeAdapter : NativeMediationAdapter {

    override val networkId = "admob"

    private var nativeAd: NativeAd? = null
    private var nativeAdView: NativeAdView? = null
    private var callback: MediationAdCallback? = null
    private var model: NativeAdModel? = null

    override fun load(config: MediationLoadConfig, callback: MediationAdCallback) {
        this.callback = callback
        AdMobSupport.ensureInitialized(config.context)
        AdMobSupport.applyCoppa(config.options)

        val loader = AdLoader.Builder(config.context, config.unitId)
            .forNativeAd { ad ->
                nativeAd = ad
                model = toModel(ad)
                this.callback?.onLoaded()
            }
            .withAdListener(object : AdListener() {
                override fun onAdFailedToLoad(error: LoadAdError) {
                    this@AdMobNativeAdapter.callback?.onFailed("AdMob ${error.code}: ${error.message}")
                }

                override fun onAdImpression() {
                    this@AdMobNativeAdapter.callback?.onImpression()
                }

                override fun onAdClicked() {
                    this@AdMobNativeAdapter.callback?.onClicked()
                }
            })
            .build()

        loader.loadAd(AdRequest.Builder().build())
    }

    override fun model(): NativeAdModel? = model

    override fun bind(rendering: NativeAdRendering, activity: Activity?) {
        val ad = nativeAd ?: return
        val adView = NativeAdView(rendering.container.context)
        // Slot views become descendants of the NativeAdView (required by AdMob)
        // without touching the PlatformView root.
        NativeContainerReparenter.reparentChildrenInto(rendering.container, adView)

        rendering.titleView()?.let { it.text = ad.headline; adView.headlineView = it }
        rendering.bodyView()?.let { it.text = ad.body; adView.bodyView = it }
        rendering.callToActionView()?.let { it.text = ad.callToAction; adView.callToActionView = it }
        rendering.iconView()?.let { iv ->
            ad.icon?.drawable?.let(iv::setImageDrawable)
            adView.iconView = iv
        }

        // Media: AdMob always renders via MediaView. Drop it full-bleed into the
        // host's single media slot (mirrors iOS `nativeMediaView()`); the slot is
        // inside the reparented subtree, so the MediaView stays within the
        // NativeAdView that AdMob requires for tracking.
        rendering.mediaContainer()?.let { slot ->
            rendering.mainImageView()?.visibility = View.GONE
            val mediaView = MediaView(adView.context)
            slot.addView(mediaView, fullBleed())
            adView.mediaView = mediaView
            ad.mediaContent?.let { mediaView.mediaContent = it }
        }

        // AdChoices at the host privacy slot position (mirrors FAN's AdOptions
        // handling). Without this AdMob would auto-place AdChoices in its
        // default corner of the NativeAdView and the host's slot would stay
        // empty.
        rendering.privacyView()?.let { privacy ->
            val choices = AdChoicesView(adView.context)
            privacy.visibility = View.GONE
            adView.addView(choices, copyParams(privacy))
            adView.adChoicesView = choices
        }

        adView.setNativeAd(ad)
        nativeAdView = adView
    }

    override fun unbind() {}

    override fun cancel() = release()

    override fun destroy() = release()

    private fun release() {
        nativeAdView?.destroy()
        nativeAdView = null
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
        title = ad.headline,
        body = ad.body,
        callToAction = ad.callToAction,
        sponsored = ad.advertiser,
        iconImageUrl = ad.icon?.uri?.toString(),
        mainImageUrl = ad.images.firstOrNull()?.uri?.toString(),
        hasVideo = ad.mediaContent?.hasVideoContent() == true,
        rating = ad.starRating?.toString(),
        price = ad.price,
        downloads = ad.store,
    )
}
