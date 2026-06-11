package com.exelbid.flutter.mediation.builtin

import com.exelbid.flutter.mediation.AdFormat
import com.exelbid.flutter.mediation.MediationAdapterRegistry

/**
 * Kakao AdFit 미디에이션 모듈. 호스트 앱이 [register]를 호출해 AdFit 어댑터를
 * 등록한다. 호출 전에 호스트가 `com.kakao.adfit:ads-base` 의존성(+ Kakao maven
 * 저장소)을 추가해야 한다. AdFit은 전면/비디오가 없어 배너·네이티브만 등록한다.
 */
object AdfitMediationModule {
    fun register() {
        MediationAdapterRegistry.register("adfit", AdFormat.BANNER) { AdfitBannerAdapter() }
        MediationAdapterRegistry.register("adfit", AdFormat.NATIVE) { AdfitNativeAdapter() }
    }
}
