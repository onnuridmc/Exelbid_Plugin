package com.exelbid.flutter.mediation.builtin

import android.app.Activity
import com.exelbid.flutter.mappers.AdOptionsMapper
import com.exelbid.flutter.mediation.adapter.InterstitialMediationAdapter
import com.exelbid.flutter.mediation.adapter.MediationAdCallback
import com.exelbid.flutter.mediation.adapter.MediationLoadConfig
import com.onnuridmc.exelbid.ExelBidInterstitial
import com.onnuridmc.exelbid.common.ExelBidError
import com.onnuridmc.exelbid.common.OnInterstitialAdListener

/**
 * Built-in interstitial adapter wrapping [ExelBidInterstitial]. Equivalent to
 * iOS `ExelBidInterstitialAdapter` (networkID "exelbid").
 *
 * `ExelBidInterstitial.show()` uses the context it was created with, so the
 * adapter is loaded with an Activity context (provided by the handle).
 */
class ExelBidInterstitialAdapter : InterstitialMediationAdapter {

    override val networkId = "exelbid"

    private var ad: ExelBidInterstitial? = null
    private var callback: MediationAdCallback? = null

    override fun load(config: MediationLoadConfig, callback: MediationAdCallback) {
        this.callback = callback

        val interstitial = ExelBidInterstitial(config.context, config.unitId)
        interstitial.setInterstitialAdListener(object : OnInterstitialAdListener {
            override fun onInterstitialLoaded() {
                this@ExelBidInterstitialAdapter.callback?.onLoaded()
            }

            override fun onInterstitialFailed(errorCode: ExelBidError?, statusCode: Int) {
                val reason = errorCode?.errorMessage ?: "ExelBid interstitial failed ($statusCode)"
                this@ExelBidInterstitialAdapter.callback?.onFailed(reason)
            }

            override fun onInterstitialShow() {
                this@ExelBidInterstitialAdapter.callback?.onDidAppear()
            }

            override fun onInterstitialDismiss() {
                this@ExelBidInterstitialAdapter.callback?.onDidDisappear()
            }

            override fun onInterstitialClicked() {
                this@ExelBidInterstitialAdapter.callback?.onClicked()
            }
        })

        AdOptionsMapper.apply(interstitial, config.options)
        ad = interstitial
        interstitial.load()
    }

    override fun isReady(): Boolean = ad?.isReady() == true

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
