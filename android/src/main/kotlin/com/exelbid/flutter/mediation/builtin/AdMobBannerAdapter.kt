package com.exelbid.flutter.mediation.builtin

import android.view.View
import com.exelbid.flutter.mediation.adapter.BannerMediationAdapter
import com.exelbid.flutter.mediation.adapter.MediationAdCallback
import com.exelbid.flutter.mediation.adapter.MediationLoadConfig
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.LoadAdError

/**
 * AdMob (Google Mobile Ads) banner adapter. Equivalent to iOS
 * `AdMobBannerAdapter` (networkID "admob").
 *
 * The host app must declare `com.google.android.gms.ads.APPLICATION_ID` in its
 * manifest (Google requirement); otherwise GMA throws at initialization.
 */
class AdMobBannerAdapter : BannerMediationAdapter {

    override val networkId = "admob"

    private var adView: AdView? = null
    private var callback: MediationAdCallback? = null

    override fun load(config: MediationLoadConfig, callback: MediationAdCallback) {
        this.callback = callback
        AdMobSupport.ensureInitialized(config.context)
        AdMobSupport.applyCoppa(config.options)

        val view = AdView(config.context)
        view.setAdSize(adSizeFor(config))
        view.adUnitId = config.unitId
        view.adListener = object : AdListener() {
            override fun onAdLoaded() {
                this@AdMobBannerAdapter.callback?.onLoaded()
            }

            override fun onAdFailedToLoad(error: LoadAdError) {
                this@AdMobBannerAdapter.callback?.onFailed("AdMob ${error.code}: ${error.message}")
            }

            override fun onAdClicked() {
                this@AdMobBannerAdapter.callback?.onClicked()
            }

            override fun onAdOpened() {
                this@AdMobBannerAdapter.callback?.onLeaveApp()
            }

            override fun onAdClosed() {
                this@AdMobBannerAdapter.callback?.onClickFinish()
            }
        }

        adView = view
        view.loadAd(AdRequest.Builder().build())
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

    private fun adSizeFor(config: MediationLoadConfig): AdSize {
        val w = config.widthDp
        val h = config.heightDp
        return if (w != null && h != null) AdSize(w, h) else AdSize.BANNER
    }
}
