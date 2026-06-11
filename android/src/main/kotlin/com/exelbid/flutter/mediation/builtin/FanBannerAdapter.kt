package com.exelbid.flutter.mediation.builtin

import android.view.View
import com.exelbid.flutter.mediation.adapter.BannerMediationAdapter
import com.exelbid.flutter.mediation.adapter.MediationAdCallback
import com.exelbid.flutter.mediation.adapter.MediationLoadConfig
import com.facebook.ads.Ad
import com.facebook.ads.AdError
import com.facebook.ads.AdListener
import com.facebook.ads.AdSize
import com.facebook.ads.AdView

/**
 * Facebook Audience Network banner adapter. Equivalent to iOS
 * `FANBannerAdapter` (networkID "fan").
 */
class FanBannerAdapter : BannerMediationAdapter {

    override val networkId = "fan"

    private var adView: AdView? = null
    private var callback: MediationAdCallback? = null

    override fun load(config: MediationLoadConfig, callback: MediationAdCallback) {
        this.callback = callback
        FanSupport.applyCoppa(config.options)

        val view = AdView(config.context, config.unitId, AdSize.BANNER_HEIGHT_50)
        val listener = object : AdListener {
            override fun onError(ad: Ad?, error: AdError?) {
                this@FanBannerAdapter.callback?.onFailed(
                    error?.errorMessage ?: "FAN banner failed",
                )
            }

            override fun onAdLoaded(ad: Ad?) {
                this@FanBannerAdapter.callback?.onLoaded()
            }

            override fun onAdClicked(ad: Ad?) {
                this@FanBannerAdapter.callback?.onClicked()
            }

            override fun onLoggingImpression(ad: Ad?) {}
        }

        adView = view
        view.loadAd(view.buildLoadAdConfig().withAdListener(listener).build())
    }

    override fun view(): View? = adView

    override fun cancel() = release()

    override fun destroy() = release()

    private fun release() {
        adView?.destroy()
        adView = null
        callback = null
    }
}
