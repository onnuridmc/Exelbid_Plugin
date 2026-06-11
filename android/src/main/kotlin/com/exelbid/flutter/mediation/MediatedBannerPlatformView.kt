package com.exelbid.flutter.mediation

import android.app.Activity
import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.exelbid.flutter.ChannelNames
import com.exelbid.flutter.mediation.adapter.BannerMediationAdapter
import com.exelbid.flutter.mediation.adapter.MediationAdapter
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView

/**
 * PlatformView host for a mediated banner. Owns a [WaterfallOrchestrator] that
 * runs the waterfall and, on a win, attaches the network's banner view into the
 * container. Events stream to Dart over the per-view EventChannel.
 *
 * Events emitted before Dart subscribes (fetching/fetched/trying) are buffered
 * and flushed on the first [onListen].
 */
class MediatedBannerPlatformView(
    context: Context,
    viewId: Long,
    args: Map<String, Any?>?,
    messenger: BinaryMessenger,
    activity: Activity?,
) : PlatformView, EventChannel.StreamHandler {

    private val container = FrameLayout(context)
    private val eventChannel = EventChannel(messenger, ChannelNames.MediatedBanner.events(viewId))

    private var sink: EventChannel.EventSink? = null
    private val pending = ArrayList<Map<String, Any?>>()

    private var orchestrator: WaterfallOrchestrator? = null

    init {
        eventChannel.setStreamHandler(this)

        val adUnitId = args?.get("adUnitId") as? String ?: ""
        val width = (args?.get("width") as? Number)?.toInt()
        val height = (args?.get("height") as? Number)?.toInt()
        val autoLoad = args?.get("autoLoad") as? Boolean ?: true
        val perNetworkTimeoutSec = (args?.get("perNetworkTimeout") as? Number)?.toDouble()

        @Suppress("UNCHECKED_CAST")
        val options = args?.get("options") as? Map<String, Any?>

        orchestrator = WaterfallOrchestrator(
            format = AdFormat.BANNER,
            unitId = adUnitId,
            context = context,
            activity = activity,
            options = options,
            widthDp = width,
            heightDp = height,
            perNetworkTimeoutMs = perNetworkTimeoutSec?.let { (it * 1000).toLong() },
            emit = ::emit,
            onWon = { adapter, _ -> attachBannerView(adapter) },
        )

        if (autoLoad) orchestrator?.start()
    }

    private fun attachBannerView(adapter: MediationAdapter) {
        val view = (adapter as? BannerMediationAdapter)?.view() ?: return
        (view.parent as? ViewGroup)?.removeView(view)
        container.removeAllViews()
        container.addView(
            view,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )
    }

    /** Called on the main thread by the orchestrator. Buffers until subscribed. */
    private fun emit(event: Map<String, Any?>) {
        val s = sink
        if (s != null) s.success(event) else pending.add(event)
    }

    override fun getView(): View = container

    override fun dispose() {
        orchestrator?.dispose()
        orchestrator = null
        eventChannel.setStreamHandler(null)
        sink = null
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
