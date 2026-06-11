package com.exelbid.flutter.mediation.builtin

import android.view.View
import com.exelbid.flutter.mediation.adapter.BannerMediationAdapter
import com.exelbid.flutter.mediation.adapter.MediationAdCallback
import com.exelbid.flutter.mediation.adapter.MediationLoadConfig
import com.kakao.adfit.ads.AdListener
import com.kakao.adfit.ads.ba.BannerAdView

/**
 * Kakao AdFit banner adapter. Equivalent to iOS `AdFitBannerAdapter`
 * (networkID "adfit").
 */
class AdfitBannerAdapter : BannerMediationAdapter {

    override val networkId = "adfit"

    private var adView: BannerAdView? = null
    private var callback: MediationAdCallback? = null

    override fun load(config: MediationLoadConfig, callback: MediationAdCallback) {
        this.callback = callback

        val view = BannerAdView(config.context)
        view.setClientId(config.unitId)
        view.setAdListener(object : AdListener {
            override fun onAdLoaded() {
                this@AdfitBannerAdapter.callback?.onLoaded()
            }

            override fun onAdFailed(errorCode: Int) {
                this@AdfitBannerAdapter.callback?.onFailed("AdFit banner failed ($errorCode)")
            }

            override fun onAdClicked() {
                this@AdfitBannerAdapter.callback?.onClicked()
            }
        })

        adView = view
        view.loadAd()
    }

    override fun view(): View? = adView

    override fun cancel() = release()

    override fun destroy() = release()

    override fun onPause() {
        adView?.pause()
    }

    override fun onResume() {
        adView?.resume()
    }

    private fun release() {
        adView?.destroy()
        adView = null
        callback = null
    }
}
