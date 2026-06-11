package com.exelbid.flutter.mediation.builtin

import android.app.Activity
import com.exelbid.flutter.mediation.adapter.MediationAdCallback
import com.exelbid.flutter.mediation.adapter.MediationLoadConfig
import com.exelbid.flutter.mappers.AdOptionsMapper
import com.exelbid.flutter.mediation.adapter.NativeMediationAdapter
import com.exelbid.flutter.mediation.nativead.NativeAdModel
import com.exelbid.flutter.mediation.nativead.NativeAdRendering
import com.onnuridmc.exelbid.ExelBidNative
import com.onnuridmc.exelbid.common.AdNativeData
import com.onnuridmc.exelbid.common.ExelBidError
import com.onnuridmc.exelbid.common.NativeAsset
import com.onnuridmc.exelbid.common.NativeViewBinder
import com.onnuridmc.exelbid.common.OnAdNativeListener

/**
 * Built-in native adapter wrapping [ExelBidNative]. Equivalent to iOS
 * `ExelBidNativeAdapter` (networkID "exelbid").
 *
 * ExelBid's in-house native binds by view id, so it needs the host slot views at
 * load time: it builds a [NativeViewBinder] from [MediationLoadConfig.rendering]
 * before `loadAd()`. `bind()` then triggers the final `show()` which renders the
 * assets and arms impression/click tracking.
 */
class ExelBidNativeAdapter : NativeMediationAdapter {

    override val networkId = "exelbid"

    private var nativeAd: ExelBidNative? = null
    private var callback: MediationAdCallback? = null
    private var model: NativeAdModel? = null
    private var shown = false

    override fun load(config: MediationLoadConfig, callback: MediationAdCallback) {
        this.callback = callback
        val rendering = config.rendering
        if (rendering == null) {
            callback.onFailed("ExelBid native requires slot rendering")
            return
        }

        val ad = ExelBidNative(
            config.context,
            config.unitId,
            object : OnAdNativeListener {
                override fun onLoaded() {
                    model = nativeAd?.nativeAdData?.let(::toModel)
                    this@ExelBidNativeAdapter.callback?.onLoaded()
                }

                override fun onFailed(errorCode: ExelBidError?, statusCode: Int) {
                    this@ExelBidNativeAdapter.callback?.onFailed(
                        errorCode?.errorMessage ?: "ExelBid native failed ($statusCode)",
                    )
                }

                override fun onShow() {
                    this@ExelBidNativeAdapter.callback?.onImpression()
                }

                override fun onClick() {
                    this@ExelBidNativeAdapter.callback?.onClicked()
                }
            },
        )

        val builder = NativeViewBinder.Builder(rendering.container)
        rendering.titleView()?.let { builder.titleTextViewId(it.id) }
        rendering.bodyView()?.let { builder.textTextViewId(it.id) }
        rendering.callToActionView()?.let { builder.callToActionButtonId(it.id) }
        rendering.iconView()?.let { builder.iconImageId(it.id) }
        rendering.mainImageView()?.let { builder.mainImageId(it.id) }
        // Do NOT bind mediaViewId to the media container: the SDK expects a
        // dedicated NativeVideoView, not the FrameLayout wrapping the main
        // ImageView — binding the wrapper intermittently hides the main image.
        rendering.privacyView()?.let { builder.adInfoImageId(it.id) }
        ad.setNativeViewBinder(builder.build())
        // Minimal required asset → higher fill; host decides which slots to show.
        ad.setRequiredAsset(arrayOf(NativeAsset.TITLE))
        AdOptionsMapper.apply(ad, config.options)

        nativeAd = ad
        ad.loadAd()
    }

    override fun model(): NativeAdModel? = model

    override fun bind(rendering: NativeAdRendering, activity: Activity?) {
        // show() renders into the binder views and arms impression/click tracking.
        if (shown) return
        shown = true
        nativeAd?.show()
    }

    override fun unbind() {}

    override fun cancel() = release()

    override fun destroy() = release()

    override fun onPause() {
        nativeAd?.onPause()
    }

    override fun onResume() {
        nativeAd?.onResume()
    }

    private fun release() {
        nativeAd?.onDestroy()
        nativeAd = null
        callback = null
        shown = false
    }

    private fun toModel(d: AdNativeData): NativeAdModel = NativeAdModel(
        title = d.title,
        body = d.text,
        callToAction = d.ctatext,
        iconImageUrl = d.icon,
        mainImageUrl = d.main,
        hasVideo = d.hasVideoAsset(),
        rating = d.rating.takeIf { it > 0f }?.toString(),
    )
}
