package com.exelbid.flutter.mediation.builtin

import com.exelbid.flutter.mediation.AdFormat
import com.exelbid.flutter.mediation.MediationAdapterRegistry

/**
 * Facebook Audience Network 미디에이션 모듈. 호스트 앱이 [register]를 호출해 FAN
 * 어댑터를 등록한다. 호출 전에 호스트가 `audience-network-sdk` 의존성을 추가해야
 * 한다 — 미추가 시 광고 로드 시점에 `ClassNotFoundError`.
 */
object FanMediationModule {
    fun register() {
        MediationAdapterRegistry.register("fan", AdFormat.BANNER) { FanBannerAdapter() }
        MediationAdapterRegistry.register("fan", AdFormat.INTERSTITIAL) { FanInterstitialAdapter() }
        MediationAdapterRegistry.register("fan", AdFormat.NATIVE) { FanNativeAdapter() }
        MediationAdapterRegistry.register("fan", AdFormat.VIDEO) { FanVideoAdapter() }
    }
}
