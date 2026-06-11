package com.exelbid.flutter.mediation

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import com.exelbid.flutter.ChannelNames
import com.exelbid.flutter.mappers.NativeAdDataMapper
import com.exelbid.flutter.mediation.adapter.NativeMediationAdapter
import com.exelbid.flutter.mediation.nativead.SlotNativeRenderingView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

/**
 * PlatformView host for a mediated native ad. Holds a [SlotNativeRenderingView]
 * the host fills via per-view MethodChannel slot setters, runs the native
 * waterfall, and on a win renders + binds the winner into the slots.
 *
 * The waterfall starts only after the first slots are placed (debounced), so the
 * winning adapter — in particular ExelBid in-house, which binds by view id at
 * load time — has the asset views available.
 */
class MediatedNativeAdPlatformView(
    private val context: Context,
    viewId: Long,
    args: Map<String, Any?>?,
    messenger: BinaryMessenger,
    private val activityProvider: () -> Activity?,
) : PlatformView, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val rendering = SlotNativeRenderingView(context)
    private val methodChannel = MethodChannel(messenger, ChannelNames.MediatedNative.method(viewId))
    private val eventChannel = EventChannel(messenger, ChannelNames.MediatedNative.events(viewId))
    private val main = Handler(Looper.getMainLooper())

    private val adUnitId: String = args?.get("adUnitId") as? String ?: ""
    private val perNetworkTimeoutMs: Long? =
        (args?.get("perNetworkTimeout") as? Number)?.let { (it.toDouble() * 1000).toLong() }

    @Suppress("UNCHECKED_CAST")
    private val options: Map<String, Any?>? = args?.get("options") as? Map<String, Any?>

    private var sink: EventChannel.EventSink? = null
    private val pending = ArrayList<Map<String, Any?>>()

    private var orchestrator: WaterfallOrchestrator? = null
    private var nativeAdapter: NativeMediationAdapter? = null
    private var started = false
    private val startRunnable = Runnable { startLoad() }

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *>
        when (call.method) {
            "setTitleView" -> args?.let { rendering.setTitleView(it) }
            "setDescriptionView" -> args?.let { rendering.setDescriptionView(it) }
            "setMediaView" -> args?.let { rendering.setMediaView(it) }
            "setIconImageView" -> args?.let { rendering.setIconImageView(it) }
            "setCallToActionView" -> args?.let { rendering.setCallToActionView(it) }
            "setSponsoredView" -> args?.let { rendering.setSponsoredView(it) }
            "setDisplayUrlView" -> args?.let { rendering.setDisplayUrlView(it) }
            "setLogoImageView" -> args?.let { rendering.setLogoImageView(it) }
            "setPrivacyInformationIconImage" -> args?.let { rendering.setPrivacyInformationIconImage(it) }
            else -> {
                result.notImplemented()
                return
            }
        }
        scheduleStart()
        result.success(null)
    }

    /** Debounce: start the waterfall once slots have settled for ~one frame. */
    private fun scheduleStart() {
        if (started) return
        main.removeCallbacks(startRunnable)
        main.postDelayed(startRunnable, 64)
    }

    private fun startLoad() {
        if (started) return
        started = true

        val orch = WaterfallOrchestrator(
            format = AdFormat.NATIVE,
            unitId = adUnitId,
            context = context,
            activity = activityProvider(),
            options = options,
            perNetworkTimeoutMs = perNetworkTimeoutMs,
            rendering = rendering,
            emit = ::emit,
            onWon = { adapter, _ ->
                nativeAdapter = adapter as? NativeMediationAdapter
                nativeAdapter?.bind(rendering, activityProvider())
            },
            onLoadExtra = {
                nativeAdapter?.model()
                    ?.let { mapOf("data" to NativeAdDataMapper.encode(it)) } ?: emptyMap()
            },
        )
        orchestrator = orch
        orch.start()
    }

    private fun emit(event: Map<String, Any?>) {
        val s = sink
        if (s != null) s.success(event) else pending.add(event)
    }

    override fun getView(): View = rendering

    override fun dispose() {
        main.removeCallbacks(startRunnable)
        orchestrator?.dispose()
        orchestrator = null
        nativeAdapter?.unbind()
        nativeAdapter?.destroy()
        nativeAdapter = null
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
