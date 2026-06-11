package com.exelbid.flutter

import android.app.Activity
import android.content.Context
import com.exelbid.flutter.banner.BannerViewFactory
import com.exelbid.flutter.interstitial.InterstitialAdHandle
import com.exelbid.flutter.nativead.NativeAdViewFactory
import com.exelbid.flutter.video.VideoAdHandle
import com.exelbid.flutter.mediation.AdFormat
import com.exelbid.flutter.mediation.MediatedBannerViewFactory
import com.exelbid.flutter.mediation.MediatedInterstitialAdHandle
import com.exelbid.flutter.mediation.MediatedNativeAdViewFactory
import com.exelbid.flutter.mediation.MediatedVideoAdHandle
import com.exelbid.flutter.mediation.MediationAdapterRegistry
import com.exelbid.flutter.mediation.builtin.ExelBidBannerAdapter
import com.exelbid.flutter.mediation.builtin.ExelBidInterstitialAdapter
import com.exelbid.flutter.mediation.builtin.ExelBidNativeAdapter
import com.exelbid.flutter.mediation.builtin.ExelBidVideoAdapter
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Android entry point for the ExelBid Flutter plugin.
 *
 * Mirrors the iOS `ExelbidFlutterPlugin`: a single global [MethodChannel]
 * (`com.exelbid/flutter`) for one-shot calls, plus — added in later phases —
 * per-instance mediated surfaces (banner PlatformView, interstitial handle).
 *
 * Implements [ActivityAware] because the full-screen / mediated surfaces and
 * several third-party network SDKs require an `Activity` context (not just the
 * application context). The current activity is tracked here and handed to the
 * waterfall orchestrator when those surfaces are built.
 *
 * Phase A (this file): global channel only — `setLogLevel`, `getSdkVersion`,
 * and the ATT shims. Mediation wiring (orchestrator, adapters, factories) lands
 * in Phase B–D.
 */
class ExelbidFlutterPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private var messenger: BinaryMessenger? = null
    private var applicationContext: Context? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        messenger = binding.binaryMessenger
        channel = MethodChannel(binding.binaryMessenger, ChannelNames.GLOBAL)
        channel.setMethodCallHandler(this)

        registerBuiltInAdapters()

        // Mediated banner PlatformView. The factory reads the current activity
        // lazily via the provider so it picks up ActivityAware changes.
        binding.platformViewRegistry.registerViewFactory(
            ChannelNames.MediatedBanner.VIEW_TYPE,
            MediatedBannerViewFactory(binding.binaryMessenger) { activity },
        )
        binding.platformViewRegistry.registerViewFactory(
            ChannelNames.MediatedNative.VIEW_TYPE,
            MediatedNativeAdViewFactory(binding.binaryMessenger) { activity },
        )

        // Standalone (non-mediated) surfaces.
        binding.platformViewRegistry.registerViewFactory(
            ChannelNames.Banner.VIEW_TYPE,
            BannerViewFactory(binding.binaryMessenger),
        )
        binding.platformViewRegistry.registerViewFactory(
            ChannelNames.Native.VIEW_TYPE,
            NativeAdViewFactory(binding.binaryMessenger) { activity },
        )
    }

    /**
     * 인하우스(ExelBid) 어댑터만 자동 등록한다. ExelBid SDK는 항상 번들되므로
     * 추가 의존성이 필요 없다. AdMob·FAN·AdFit 등 외부 네트워크는 iOS와 동일하게
     * **호스트 앱이 옵트인 등록**한다(각 네트워크 SDK 추가 + `*MediationModule.register()`).
     */
    private fun registerBuiltInAdapters() {
        MediationAdapterRegistry.register("exelbid", AdFormat.BANNER) { ExelBidBannerAdapter() }
        MediationAdapterRegistry.register("exelbid", AdFormat.INTERSTITIAL) { ExelBidInterstitialAdapter() }
        MediationAdapterRegistry.register("exelbid", AdFormat.NATIVE) { ExelBidNativeAdapter() }
        MediationAdapterRegistry.register("exelbid", AdFormat.VIDEO) { ExelBidVideoAdapter() }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setLogLevel" -> {
                // TODO(Phase B): ExelBid Android SDK의 로그레벨 제어 API 확인 후 연결.
                //   call.argument<Int>("level") 로 LogLevel.rawValue 수신.
                result.success(null)
            }

            "getSdkVersion" -> {
                // TODO(Phase B): ExelBid Android SDK의 버전 조회 API로 대체.
                //   현재는 빌드 의존성 버전을 반환.
                result.success(EXELBID_SDK_VERSION)
            }

            // Android에는 App Tracking Transparency 개념이 없다. Dart의 ATT API가
            // 크로스플랫폼으로 안전하도록 iOS < 14 와 동일하게 authorized(3)을 반환한다.
            "getTrackingAuthorizationStatus" -> result.success(AUTHORIZED)
            "requestTrackingAuthorization" -> result.success(AUTHORIZED)

            "mediatedInterstitial.create" -> createMediatedInterstitial(call, result)
            "mediatedVideo.create" -> createMediatedVideo(call, result)
            "interstitial.create" -> createInterstitial(call, result)
            "video.create" -> createVideo(call, result)

            else -> result.notImplemented()
        }
    }

    /** Global `mediatedInterstitial.create` — builds a per-id handle and retains it. */
    private fun createMediatedInterstitial(call: MethodCall, result: Result) {
        val id = call.argument<String>("id")
        val ctx = applicationContext
        val msg = messenger
        if (id == null || ctx == null || msg == null) {
            result.error("invalid_args", "Missing id/context/messenger", null)
            return
        }
        val adUnitId = call.argument<String>("adUnitId") ?: ""
        @Suppress("UNCHECKED_CAST")
        val options = call.argument<Map<String, Any?>>("options")
        val timeoutMs = call.argument<Double>("perNetworkTimeout")?.let { (it * 1000).toLong() }

        val handle = MediatedInterstitialAdHandle(
            id = id,
            adUnitId = adUnitId,
            options = options,
            perNetworkTimeoutMs = timeoutMs,
            applicationContext = ctx,
            messenger = msg,
            activityProvider = { activity },
        )
        InstanceRegistry.put(id, handle)
        result.success(null)
    }

    /** Global `mediatedVideo.create` — builds a per-id video handle and retains it. */
    private fun createMediatedVideo(call: MethodCall, result: Result) {
        val id = call.argument<String>("id")
        val ctx = applicationContext
        val msg = messenger
        if (id == null || ctx == null || msg == null) {
            result.error("invalid_args", "Missing id/context/messenger", null)
            return
        }
        val adUnitId = call.argument<String>("adUnitId") ?: ""
        @Suppress("UNCHECKED_CAST")
        val options = call.argument<Map<String, Any?>>("options")
        val timeoutMs = call.argument<Double>("perNetworkTimeout")?.let { (it * 1000).toLong() }

        val handle = MediatedVideoAdHandle(
            id = id,
            adUnitId = adUnitId,
            options = options,
            perNetworkTimeoutMs = timeoutMs,
            applicationContext = ctx,
            messenger = msg,
            activityProvider = { activity },
        )
        InstanceRegistry.put(id, handle)
        result.success(null)
    }

    /** Global `interstitial.create` — standalone interstitial. */
    private fun createInterstitial(call: MethodCall, result: Result) {
        val id = call.argument<String>("id")
        val ctx = applicationContext
        val msg = messenger
        if (id == null || ctx == null || msg == null) {
            result.error("invalid_args", "Missing id/context/messenger", null)
            return
        }
        val handle = InterstitialAdHandle(
            id = id,
            adUnitId = call.argument<String>("adUnitId") ?: "",
            options = call.argument<Map<String, Any?>>("options"),
            applicationContext = ctx,
            messenger = msg,
            activityProvider = { activity },
        )
        InstanceRegistry.put(id, handle)
        result.success(null)
    }

    /** Global `video.create` — standalone interstitial-video. */
    private fun createVideo(call: MethodCall, result: Result) {
        val id = call.argument<String>("id")
        val ctx = applicationContext
        val msg = messenger
        if (id == null || ctx == null || msg == null) {
            result.error("invalid_args", "Missing id/context/messenger", null)
            return
        }
        val handle = VideoAdHandle(
            id = id,
            adUnitId = call.argument<String>("adUnitId") ?: "",
            options = call.argument<Map<String, Any?>>("options"),
            applicationContext = ctx,
            messenger = msg,
            activityProvider = { activity },
        )
        InstanceRegistry.put(id, handle)
        result.success(null)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        messenger = null
        applicationContext = null
    }

    // MARK: - ActivityAware (전면/일부 네트워크가 Activity 필요 — Phase D에서 사용)

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    companion object {
        /** ATT authorized — `ATTrackingManager.AuthorizationStatus.authorized.rawValue`. */
        private const val AUTHORIZED = 3

        /** TODO(Phase B): 실제 SDK 버전 조회 API로 대체. */
        private const val EXELBID_SDK_VERSION = "2.0.2"
    }
}
