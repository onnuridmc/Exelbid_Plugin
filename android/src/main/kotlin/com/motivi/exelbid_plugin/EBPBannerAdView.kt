package com.motivi.exelbid_plugin

import android.content.Context
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
    private lateinit var mAdView: ExelBidAdView

    init {
        channel = MethodChannel(messenger, "$(METHOD_CHANNEL_VIEW_ID)_$(id")

        val adUnitId = creationParams?.get("ad_unit_id") as? String
        val isFullWebView = creationParams?.get("is_full_web_view") as? Boolean ?: true
        val coppa = creationParams?.get("coppa") as? Boolean ?: true
        val yob = creationParams?.get("yob") as? String
        val gender = creationParams?.get("gender") as? Boolean ?: true
        val keywords = creationParams?.get("keywords") as? Map<String, String>
        val isTest = creationParams?.get("is_test") as? Boolean ?: false

        mAdView = ExelBidAdView(context)
        mAdView.setAdUnitId(adUnitId)
        mAdView.setFullWebView(isFullWebView)
        mAdView.setCoppa(coppa)
        mAdView.setYob(yob)
        mAdView.setGender(gender)
        mAdView.setTestMode(isTest)

        keywords?.forEach { (key, value) ->
            mAdView.addKeyword(key, value)
        }

        mAdView.setAdListener(object : OnBannerAdListener {
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

        mAdView.loadAd()
    }

    private val adView: LinearLayout = LinearLayout(context).apply {
        addView(mAdView)
    }

    override fun getView(): View = adView

    override fun dispose() {
        mAdView.destroy()
    }
}
