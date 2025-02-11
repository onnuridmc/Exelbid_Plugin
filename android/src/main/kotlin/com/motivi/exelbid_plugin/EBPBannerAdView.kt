package com.motivi.exelbid_plugin

import android.content.Context
import android.text.TextUtils
import android.util.Log
import android.view.View
import android.widget.LinearLayout
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import com.onnuridmc.exelbid.ExelBidAdView
import com.onnuridmc.exelbid.common.ExelBidError
import com.onnuridmc.exelbid.common.OnBannerAdListener


class EBPBannerAdView(context: Context, id: Int, creationParams: Map<String?, Any?>?, messenger: BinaryMessenger) : PlatformView {
    private val channel: MethodChannel
    private var adView: ExelBidAdView
    private val bannerView: LinearLayout = LinearLayout(context)

    init {
        val adUnitId = creationParams?.get("ad_unit_id") as? String
        val isFullWebView = creationParams?.get("is_full_web_view") as? Boolean ?: true
        val coppa = creationParams?.get("coppa") as? Boolean ?: true
        val isTest = creationParams?.get("is_test") as? Boolean ?: false

        channel = MethodChannel(messenger, "${METHOD_CHANNEL_VIEW_ID}_${id}")

        adView = ExelBidAdView(context)
        adView.setAdUnitId(adUnitId)
        adView.setFullWebView(isFullWebView)
        adView.setCoppa(coppa)
        adView.setTestMode(isTest)

        adView.setAdListener(object : OnBannerAdListener {
            override fun onAdLoaded() {
                Log.e(javaClass.name, "onAdLoaded")
                channel.invokeMethod("onLoadAd", null)
            }

            override fun onAdClicked() {
                Log.e(javaClass.name, "onAdClicked")
                channel.invokeMethod("onClickAd", null)
            }

            override fun onAdFailed(errorCode: ExelBidError, statusCode: Int) {
                Log.e(javaClass.name, "onAdFailed : "+errorCode.errorMessage)
                channel.invokeMethod("onFailAd", mapOf("error_message" to errorCode.errorMessage))
            }
        })

        bannerView.addView(adView)
        adView.loadAd()
    }

    override fun getView(): View = bannerView

    override fun dispose() {
        adView.destroy()
    }
}
