package com.exelbid.flutter.mediation.builtin

import android.app.Activity
import com.exelbid.flutter.mediation.adapter.InterstitialMediationAdapter
import com.exelbid.flutter.mediation.adapter.MediationAdCallback
import com.exelbid.flutter.mediation.adapter.MediationLoadConfig
import com.facebook.ads.Ad
import com.facebook.ads.AdError
import com.facebook.ads.InterstitialAd
import com.facebook.ads.InterstitialAdListener

/**
 * Facebook Audience Network interstitial adapter. Equivalent to iOS
 * `FANInterstitialAdapter` (networkID "fan").
 */
class FanInterstitialAdapter : InterstitialMediationAdapter {

    override val networkId = "fan"

    private var ad: InterstitialAd? = null
    private var callback: MediationAdCallback? = null

    override fun load(config: MediationLoadConfig, callback: MediationAdCallback) {
        this.callback = callback
        FanSupport.applyCoppa(config.options)

        val interstitial = InterstitialAd(config.context, config.unitId)
        val listener = object : InterstitialAdListener {
            override fun onError(ad: Ad?, error: AdError?) {
                this@FanInterstitialAdapter.callback?.onFailed(
                    error?.errorMessage ?: "FAN interstitial failed",
                )
            }

            override fun onAdLoaded(ad: Ad?) {
                this@FanInterstitialAdapter.callback?.onLoaded()
            }

            override fun onAdClicked(ad: Ad?) {
                this@FanInterstitialAdapter.callback?.onClicked()
            }

            override fun onLoggingImpression(ad: Ad?) {}

            override fun onInterstitialDisplayed(ad: Ad?) {
                this@FanInterstitialAdapter.callback?.onDidAppear()
            }

            override fun onInterstitialDismissed(ad: Ad?) {
                this@FanInterstitialAdapter.callback?.onDidDisappear()
            }
        }

        ad = interstitial
        interstitial.loadAd(interstitial.buildLoadAdConfig().withAdListener(listener).build())
    }

    override fun isReady(): Boolean = ad?.isAdLoaded == true

    override fun show(activity: Activity) {
        ad?.show()
    }

    override fun cancel() = release()

    override fun destroy() = release()

    private fun release() {
        ad?.destroy()
        ad = null
        callback = null
    }
}
