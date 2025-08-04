package com.motivi.exelbid_plugin

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.Log
import android.view.View
import android.view.ViewOutlineProvider
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
        val coppa = creationParams?.get("coppa") as? Boolean ?: false
        val isTest = creationParams?.get("is_test") as? Boolean ?: false
        val styles = creationParams?.get("styles") as? Map<String, Any>
        val backgroundColor = styles?.get("background_color") as String?
        val borderRadius = styles?.get("border_radius") as Double?

        channel = MethodChannel(messenger, "${METHOD_CHANNEL_VIEW_ID}_${id}")

        val drawable = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            backgroundColor?.let {
                setColor(Color.parseColor(it))
            }
            borderRadius.let {
                cornerRadius = it?.toFloat() ?: 0f
            }
        }

        bannerView.apply {
            clipChildren = true
            clipToPadding = true
            outlineProvider = ViewOutlineProvider.BACKGROUND
            clipToOutline = true
            background = drawable
        }

        adView = ExelBidAdView(context)
        adView.setAdUnitId(adUnitId)
        adView.setFullWebView(isFullWebView)
        if (coppa) {
            adView.setCoppa(true)
        }
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
        bannerView.removeAllViews()
        channel.setMethodCallHandler(null)
    }
}
