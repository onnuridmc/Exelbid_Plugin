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

        // AdFit's BannerAdView hard-requires an Activity context (throws
        // "Context must be Activity context!" otherwise). For banner the load
        // config's context is the PlatformView context, so use the Activity and
        // fail the step (advancing the waterfall) when none is attached.
        val activity = config.activity ?: run {
            callback.onFailed("AdFit banner requires an Activity context")
            return
        }

        val view = BannerAdView(activity)
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
