package com.exelbid.flutter.nativead

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import com.exelbid.flutter.ChannelNames
import com.exelbid.flutter.mappers.AdErrorMapper
import com.exelbid.flutter.mappers.AdOptionsMapper
import com.onnuridmc.exelbid.ExelBidNative
import com.onnuridmc.exelbid.common.AdNativeData
import com.onnuridmc.exelbid.common.ExelBidError
import com.onnuridmc.exelbid.common.NativeAsset
import com.onnuridmc.exelbid.common.NativeViewBinder
import com.onnuridmc.exelbid.common.OnAdNativeListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

/**
 * PlatformView for a standalone (non-mediated) ExelBid native ad.
 *
 * Self-contained: wraps [ExelBidNative] directly with a [NativeSlotView] — no
 * mediation adapter/orchestrator. The host pushes slot rects over the per-view
 * MethodChannel; once they settle the binder is built (by view id), the ad
 * loads, and `show()` renders + arms impression/click tracking.
 */
class NativeAdPlatformView(
    private val context: Context,
    viewId: Long,
    args: Map<String, Any?>?,
    messenger: BinaryMessenger,
    private val activityProvider: () -> Activity?,
) : PlatformView, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val slots = NativeSlotView(context)
    private val methodChannel = MethodChannel(messenger, ChannelNames.Native.method(viewId))
    private val eventChannel = EventChannel(messenger, ChannelNames.Native.events(viewId))
    private val main = Handler(Looper.getMainLooper())

    private val adUnitId: String = args?.get("adUnitId") as? String ?: ""

    @Suppress("UNCHECKED_CAST")
    private val options: Map<String, Any?>? = args?.get("options") as? Map<String, Any?>

    private var sink: EventChannel.EventSink? = null
    private val pending = ArrayList<Map<String, Any?>>()

    private var nativeAd: ExelBidNative? = null
    private var started = false
    private var shown = false
    private val startRunnable = Runnable { startLoad() }

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *>
        when (call.method) {
            "setTitleView" -> args?.let { slots.setTitleView(it) }
            "setDescriptionView" -> args?.let { slots.setDescriptionView(it) }
            "setMediaView" -> args?.let { slots.setMediaView(it) }
            "setIconImageView" -> args?.let { slots.setIconImageView(it) }
            "setCallToActionView" -> args?.let { slots.setCallToActionView(it) }
            "setSponsoredView" -> args?.let { slots.setSponsoredView(it) }
            "setDisplayUrlView" -> args?.let { slots.setDisplayUrlView(it) }
            "setLogoImageView" -> args?.let { slots.setLogoImageView(it) }
            "setPrivacyInformationIconImage" -> args?.let { slots.setPrivacyInformationIconImage(it) }
            else -> {
                result.notImplemented()
                return
            }
        }
        scheduleStart()
        result.success(null)
    }

    /** Start the load once slots have settled for ~one frame. */
    private fun scheduleStart() {
        if (started) return
        main.removeCallbacks(startRunnable)
        main.postDelayed(startRunnable, 64)
    }

    private fun startLoad() {
        if (started) return
        started = true

        val loadContext: Context = activityProvider() ?: context
        val ad = ExelBidNative(
            loadContext,
            adUnitId,
            object : OnAdNativeListener {
                override fun onLoaded() {
                    if (!shown) {
                        shown = true
                        nativeAd?.show() // renders into the binder views + arms tracking
                    }
                    val event = HashMap<String, Any?>()
                    event["event"] = "onLoad"
                    nativeAd?.nativeAdData?.let { event["data"] = encodeData(it) }
                    emit(event)
                }

                override fun onFailed(errorCode: ExelBidError?, statusCode: Int) {
                    emit(
                        mapOf(
                            "event" to "onFail",
                            "error" to AdErrorMapper.encode(
                                0,
                                errorCode?.errorMessage ?: "Native failed ($statusCode)",
                            ),
                        ),
                    )
                }

                override fun onShow() = emit(mapOf("event" to "onImpression"))
                override fun onClick() = emit(mapOf("event" to "onClick"))
            },
        )

        val builder = NativeViewBinder.Builder(slots)
        slots.titleView?.let { builder.titleTextViewId(it.id) }
        slots.bodyView?.let { builder.textTextViewId(it.id) }
        slots.ctaView?.let { builder.callToActionButtonId(it.id) }
        slots.iconView?.let { builder.iconImageId(it.id) }
        slots.mainImageView?.let { builder.mainImageId(it.id) }
        // Note: do NOT bind mediaViewId to the media container — the SDK expects
        // a dedicated NativeVideoView there, not the FrameLayout that wraps the
        // main ImageView. Binding the wrapper makes the SDK's media handling
        // cover/skip the main image (intermittent "no main image"). In-house
        // native video would need a real NativeVideoView slot (future work).
        slots.privacyView?.let { builder.adInfoImageId(it.id) }
        ad.setNativeViewBinder(builder.build())
        ad.setRequiredAsset(arrayOf(NativeAsset.TITLE))
        AdOptionsMapper.apply(ad, options)

        nativeAd = ad
        ad.loadAd()
    }

    /** Maps the SDK asset model to the Dart `ExelbidNativeAdData` keys. */
    private fun encodeData(d: AdNativeData): Map<String, Any?> = buildMap {
        d.title?.let { put("title", it) }
        d.text?.let { put("body", it) }
        d.ctatext?.let { put("callToAction", it) }
        d.icon?.let { put("iconImageUrl", it) }
        d.main?.let { put("mainImageUrl", it) }
        if (d.rating > 0f) put("rating", d.rating.toString())
        put("hasVideo", d.hasVideoAsset())
    }

    private fun emit(event: Map<String, Any?>) {
        main.post {
            val s = sink
            if (s != null) s.success(event) else pending.add(event)
        }
    }

    override fun getView(): View = slots

    override fun dispose() {
        main.removeCallbacks(startRunnable)
        nativeAd?.onDestroy()
        nativeAd = null
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        sink = null
        pending.clear()
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
