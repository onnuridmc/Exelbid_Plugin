package com.exelbid.flutter.mediation.builtin

import android.view.View
import com.exelbid.flutter.mappers.AdOptionsMapper
import com.exelbid.flutter.mediation.adapter.BannerMediationAdapter
import com.exelbid.flutter.mediation.adapter.MediationAdCallback
import com.exelbid.flutter.mediation.adapter.MediationLoadConfig
import com.onnuridmc.exelbid.ExelBidAdView
import com.onnuridmc.exelbid.common.ExelBidError
import com.onnuridmc.exelbid.common.OnBannerAdListener

/**
 * Built-in banner adapter wrapping the in-house [ExelBidAdView] as a mediation
 * participant. Equivalent to iOS `ExelBidBannerAdapter` (networkID "exelbid").
 *
 * Note the inner `ExelBidAdView` is a *direct* (non-mediating) banner load — the
 * orchestrator owns the waterfall, so this must not loop again.
 */
class ExelBidBannerAdapter : BannerMediationAdapter {

    override val networkId = "exelbid"

    private var adView: ExelBidAdView? = null
    private var callback: MediationAdCallback? = null

    override fun load(config: MediationLoadConfig, callback: MediationAdCallback) {
        this.callback = callback

        // ExelBidAdView (SDK 2.0.2) exposes no size setter — the banner sizes to
        // its layout. The host PlatformView is already constrained to the
        // requested size, and the view is attached with MATCH_PARENT.
        val view = ExelBidAdView(config.context)
        view.setAdUnitId(config.unitId)
        AdOptionsMapper.apply(view, config.options)
        view.setAdListener(object : OnBannerAdListener {
            override fun onAdLoaded() {
                this@ExelBidBannerAdapter.callback?.onLoaded()
            }

            override fun onAdFailed(errorCode: ExelBidError?, statusCode: Int) {
                val reason = errorCode?.errorMessage ?: "ExelBid banner failed ($statusCode)"
                this@ExelBidBannerAdapter.callback?.onFailed(reason)
            }

            override fun onAdClicked() {
                this@ExelBidBannerAdapter.callback?.onClicked()
            }
        })

        adView = view
        view.loadAd()
    }

    override fun view(): View? = adView

    override fun cancel() {
        releaseView()
    }

    override fun destroy() {
        releaseView()
    }

    override fun onPause() {
        adView?.onPause()
    }

    override fun onResume() {
        adView?.onResume()
    }

    private fun releaseView() {
        adView?.destroy()
        adView = null
        callback = null
    }
}
