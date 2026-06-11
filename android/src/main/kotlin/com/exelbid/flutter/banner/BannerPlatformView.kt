package com.exelbid.flutter.banner

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.exelbid.flutter.ChannelNames
import com.exelbid.flutter.mappers.AdErrorMapper
import com.exelbid.flutter.mappers.AdOptionsMapper
import com.onnuridmc.exelbid.ExelBidAdView
import com.onnuridmc.exelbid.common.ExelBidError
import com.onnuridmc.exelbid.common.OnBannerAdListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

/**
 * PlatformView for a standalone (non-mediated) ExelBid banner — direct
 * [ExelBidAdView]. Honors `autoRefresh`/`autoLoad`/`fullWebView` and exposes
 * `load`/`stop` over the per-view MethodChannel.
 *
 * `OnBannerAdListener` only reports loaded/failed/clicked, so onLeaveApp /
 * onClickFinish are not emitted on Android.
 */
class BannerPlatformView(
    context: Context,
    viewId: Long,
    args: Map<String, Any?>?,
    messenger: BinaryMessenger,
) : PlatformView, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val container = FrameLayout(context)
    private val methodChannel = MethodChannel(messenger, ChannelNames.Banner.method(viewId))
    private val eventChannel = EventChannel(messenger, ChannelNames.Banner.events(viewId))

    private var sink: EventChannel.EventSink? = null
    private val pending = ArrayList<Map<String, Any?>>()

    private val banner: ExelBidAdView = ExelBidAdView(context)

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)

        val adUnitId = args?.get("adUnitId") as? String ?: ""
        val autoRefresh = args?.get("autoRefresh") as? Boolean ?: true
        val autoLoad = args?.get("autoLoad") as? Boolean ?: true
        val fullWebView = args?.get("fullWebView") as? Boolean ?: false

        @Suppress("UNCHECKED_CAST")
        val options = args?.get("options") as? Map<String, Any?>

        banner.setAdUnitId(adUnitId)
        banner.setFullWebView(fullWebView)
        AdOptionsMapper.apply(banner, options)
        if (!autoRefresh) banner.setAutoRefreshDisable()
        banner.setAdListener(object : OnBannerAdListener {
            override fun onAdLoaded() {
                emit(mapOf("event" to "onLoad"))
            }

            override fun onAdFailed(errorCode: ExelBidError?, statusCode: Int) {
                emit(
                    mapOf(
                        "event" to "onFail",
                        "error" to AdErrorMapper.encode(
                            0,
                            errorCode?.errorMessage ?: "Banner failed ($statusCode)",
                        ),
                    ),
                )
            }

            override fun onAdClicked() {
                emit(mapOf("event" to "onClick"))
            }
        })

        container.addView(
            banner,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )

        if (autoLoad) banner.loadAd()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "load" -> {
                banner.loadAd()
                result.success(null)
            }
            "stop" -> {
                banner.setAutoRefreshDisable()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun emit(event: Map<String, Any?>) {
        val s = sink
        if (s != null) s.success(event) else pending.add(event)
    }

    override fun getView(): View = container

    override fun dispose() {
        banner.destroy()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        sink = null
        pending.clear()
        container.removeAllViews()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        if (events != null && pending.isNotEmpty()) {
            pending.forEach { events.success(it) }
            pending.clear()
        }
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }
}
