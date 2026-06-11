package com.exelbid.flutter.mediation.builtin

import android.app.Activity
import com.exelbid.flutter.mappers.AdOptionsMapper
import com.exelbid.flutter.mediation.adapter.MediationAdCallback
import com.exelbid.flutter.mediation.adapter.MediationLoadConfig
import com.exelbid.flutter.mediation.adapter.VideoMediationAdapter
import com.onnuridmc.exelbid.ExelBidInterstitial
import com.onnuridmc.exelbid.common.ExelBidError
import com.onnuridmc.exelbid.common.OnInterstitialAdListener

/**
 * 빌트인 비디오 어댑터. ExelBid는 전체화면 비디오를 [ExelBidInterstitial]로
 * 서빙하므로(단독 비디오와 동일) 전면 어댑터와 같은 흐름이되, `videoSkipMin`을
 * `setTimer`(스킵 타이머)로 적용한다. iOS `ExelBidVideoAdapter`(networkID
 * "exelbid")에 대응.
 */
class ExelBidVideoAdapter : VideoMediationAdapter {

    override val networkId = "exelbid"

    private var ad: ExelBidInterstitial? = null
    private var callback: MediationAdCallback? = null

    override fun load(config: MediationLoadConfig, callback: MediationAdCallback) {
        this.callback = callback

        val video = ExelBidInterstitial(config.context, config.unitId)
        video.setInterstitialAdListener(object : OnInterstitialAdListener {
            override fun onInterstitialLoaded() {
                this@ExelBidVideoAdapter.callback?.onLoaded()
            }

            override fun onInterstitialFailed(errorCode: ExelBidError?, statusCode: Int) {
                val reason = errorCode?.errorMessage ?: "ExelBid video failed ($statusCode)"
                this@ExelBidVideoAdapter.callback?.onFailed(reason)
            }

            override fun onInterstitialShow() {
                this@ExelBidVideoAdapter.callback?.onDidAppear()
            }

            override fun onInterstitialDismiss() {
                this@ExelBidVideoAdapter.callback?.onDidDisappear()
            }

            override fun onInterstitialClicked() {
                this@ExelBidVideoAdapter.callback?.onClicked()
            }
        })

        AdOptionsMapper.apply(video, config.options)
        // videoSkipMin → setTimer(초): 스킵 타이머.
        (config.options?.get("videoSkipMin") as? Number)?.toInt()?.let { if (it > 0) video.setTimer(it) }
        ad = video
        video.load()
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
