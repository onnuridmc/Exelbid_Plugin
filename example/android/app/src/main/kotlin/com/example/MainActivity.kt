package com.example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

const val METHOD_CHANNEL_ID = "adfit"
const val METHOD_CHANNEL_VIEW_ID = "adfit/banner_ad"
const val METHOD_CHANNEL_NATIVE_VIEW_ID = "adfit/native_ad"

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        // Adfit 광고 뷰 등록
        flutterEngine.platformViewsController.registry.registerViewFactory(METHOD_CHANNEL_VIEW_ID, AdfitBannerAdViewFactory(flutterEngine.dartExecutor.binaryMessenger))
        flutterEngine.platformViewsController.registry.registerViewFactory(METHOD_CHANNEL_NATIVE_VIEW_ID, AdfitNativeAdViewFactory(flutterEngine.dartExecutor.binaryMessenger))
    }
}
