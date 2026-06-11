package com.exelbid.flutter.mediation.builtin

import com.exelbid.flutter.mediation.AdFormat
import com.exelbid.flutter.mediation.MediationAdapterRegistry

/**
 * AdMob 미디에이션 모듈. 호스트 앱이 [register]를 호출해 AdMob 어댑터를 등록한다
 * (iOS `AdMobMediationModule`에 대응). 호출 전에 호스트가 `play-services-ads`
 * 의존성을 추가해야 한다 — 미추가 시 광고 로드 시점에 `ClassNotFoundError`.
 */
object AdMobMediationModule {
    fun register() {
        MediationAdapterRegistry.register("admob", AdFormat.BANNER) { AdMobBannerAdapter() }
        MediationAdapterRegistry.register("admob", AdFormat.INTERSTITIAL) { AdMobInterstitialAdapter() }
        MediationAdapterRegistry.register("admob", AdFormat.NATIVE) { AdMobNativeAdapter() }
        MediationAdapterRegistry.register("admob", AdFormat.VIDEO) { AdMobVideoAdapter() }
    }
}
