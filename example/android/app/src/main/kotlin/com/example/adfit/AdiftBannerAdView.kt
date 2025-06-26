package com.example

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.view.View
import android.widget.LinearLayout
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import com.kakao.adfit.ads.AdListener
import com.kakao.adfit.ads.ba.BannerAdView

class AdiftBannerAdView(context: Context, id: Int, creationParams: Map<String?, Any?>?, messenger: BinaryMessenger) : PlatformView {
    private val channel: MethodChannel
    private var adView: BannerAdView
    private val bannerView: LinearLayout = LinearLayout(context)

    init {
        val clientId = creationParams?.get("client_id") as? String

        channel = MethodChannel(messenger, "${METHOD_CHANNEL_VIEW_ID}_${id}")

        adView = BannerAdView(getActivityContext(context) ?: context)
        adView.setClientId(clientId)
        adView.setAdListener(object : AdListener {
            override fun onAdLoaded() {
                channel.invokeMethod("onLoadAd", null)
            }

            override fun onAdFailed(p0: Int) {
                channel.invokeMethod("onFailAd", mapOf("error_code" to p0))
            }

            override fun onAdClicked() {
                channel.invokeMethod("onClickAd", null)
            }
        })

        bannerView.addView(adView)
        adView.loadAd()
    }

    private fun getActivityContext(context: Context): Activity? {
        return when (context) {
            is Activity -> context
            is ContextWrapper -> {
                var baseContext = context.baseContext
                while (baseContext is ContextWrapper && baseContext !is Activity) {
                    baseContext = baseContext.baseContext
                }
                baseContext as? Activity
            }
            else -> null
        }
    }

    override fun getView(): View = bannerView

    override fun dispose() {
        adView.destroy()
    }
}
