package com.exelbid.flutter.mediation.builtin

import android.app.Activity
import com.exelbid.flutter.mediation.adapter.InterstitialMediationAdapter
import com.exelbid.flutter.mediation.adapter.MediationAdCallback
import com.exelbid.flutter.mediation.adapter.MediationLoadConfig
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback

/**
 * AdMob interstitial adapter. Equivalent to iOS `AdMobInterstitialAdapter`
 * (networkID "admob"). Requires `com.google.android.gms.ads.APPLICATION_ID` in
 * the host manifest.
 */
class AdMobInterstitialAdapter : InterstitialMediationAdapter {

    override val networkId = "admob"

    private var ad: InterstitialAd? = null
    private var callback: MediationAdCallback? = null

    override fun load(config: MediationLoadConfig, callback: MediationAdCallback) {
        this.callback = callback
        AdMobSupport.ensureInitialized(config.context)
        AdMobSupport.applyCoppa(config.options)

        InterstitialAd.load(
            config.context,
            config.unitId,
            AdRequest.Builder().build(),
            object : InterstitialAdLoadCallback() {
                override fun onAdLoaded(loaded: InterstitialAd) {
                    ad = loaded
                    loaded.fullScreenContentCallback = object : FullScreenContentCallback() {
                        override fun onAdShowedFullScreenContent() {
                            this@AdMobInterstitialAdapter.callback?.onDidAppear()
                        }

                        override fun onAdDismissedFullScreenContent() {
                            this@AdMobInterstitialAdapter.callback?.onDidDisappear()
                        }

                        override fun onAdClicked() {
                            this@AdMobInterstitialAdapter.callback?.onClicked()
                        }

                        override fun onAdFailedToShowFullScreenContent(error: AdError) {
                            // Treat a failed presentation as dismissed so the host can rearm.
                            this@AdMobInterstitialAdapter.callback?.onDidDisappear()
                        }
                    }
                    this@AdMobInterstitialAdapter.callback?.onLoaded()
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    this@AdMobInterstitialAdapter.callback?.onFailed("AdMob ${error.code}: ${error.message}")
                }
            },
        )
    }

    override fun isReady(): Boolean = ad != null

    override fun show(activity: Activity) {
        ad?.show(activity)
    }

    override fun cancel() = release()

    override fun destroy() = release()

    private fun release() {
        ad?.fullScreenContentCallback = null
        ad = null
        callback = null
    }
}
