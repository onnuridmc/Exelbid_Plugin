package com.exelbid.flutter.mediation.builtin

import android.app.Activity
import com.exelbid.flutter.mediation.adapter.MediationAdCallback
import com.exelbid.flutter.mediation.adapter.MediationLoadConfig
import com.exelbid.flutter.mediation.adapter.VideoMediationAdapter

/**
 * AdMob 비디오 어댑터(networkID "admob"). AdMob의 전면(`InterstitialAd`)은 비디오
 * 크리에이티브도 노출하므로 [AdMobInterstitialAdapter]에 위임한다. iOS
 * `AdMobVideoAdapter`에 대응.
 */
class AdMobVideoAdapter : VideoMediationAdapter {

    override val networkId = "admob"

    private val delegate = AdMobInterstitialAdapter()

    override fun load(config: MediationLoadConfig, callback: MediationAdCallback) =
        delegate.load(config, callback)

    override fun isReady(): Boolean = delegate.isReady()

    override fun show(activity: Activity) = delegate.show(activity)

    override fun cancel() = delegate.cancel()

    override fun destroy() = delegate.destroy()
}
