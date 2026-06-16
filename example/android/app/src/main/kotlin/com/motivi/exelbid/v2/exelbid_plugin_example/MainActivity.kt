package com.motivi.exelbid.v2.exelbid_plugin_example

import com.exelbid.flutter.mediation.builtin.AdfitMediationModule
import com.exelbid.flutter.mediation.builtin.AdMobMediationModule
import com.exelbid.flutter.mediation.builtin.FanMediationModule
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    // 미디에이션 어댑터 옵트인 등록. 플러그인은 ExelBid(인하우스)만 자동 등록하고,
    // 외부 네트워크는 호스트가 사용하는 것만 등록한다(각 네트워크 SDK 추가 필요).
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AdMobMediationModule.register()
        AdfitMediationModule.register()
    }
}
