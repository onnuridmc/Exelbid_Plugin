package com.exelbid.flutter.mediation

import android.app.Activity
import android.content.Context
import com.exelbid.flutter.ChannelNames
import com.exelbid.flutter.InstanceRegistry
import com.exelbid.flutter.mappers.AdErrorMapper
import com.exelbid.flutter.mediation.adapter.InterstitialMediationAdapter
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Per-instance handle for a mediated interstitial. Owns a per-id MethodChannel
 * (load/isReady/present/stop/dispose) + EventChannel, and a
 * [WaterfallOrchestrator] that runs the INTERSTITIAL waterfall.
 *
 * Two-stage: `load()` runs the waterfall (winner becomes ready), `present()`
 * shows the winner on the current Activity. Lifecycle/interaction events flow
 * through the orchestrator's adapter callback to this handle's sink.
 *
 * Held by [InstanceRegistry] until `dispose`. Mirrors iOS `InterstitialAdHandle`.
 */
class MediatedInterstitialAdHandle(
    private val id: String,
    private val adUnitId: String,
    private val options: Map<String, Any?>?,
    private val perNetworkTimeoutMs: Long?,
    private val applicationContext: Context,
    messenger: BinaryMessenger,
    private val activityProvider: () -> Activity?,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val methodChannel =
        MethodChannel(messenger, ChannelNames.MediatedInterstitial.method(id))
    private val eventChannel =
        EventChannel(messenger, ChannelNames.MediatedInterstitial.events(id))

    private var sink: EventChannel.EventSink? = null
    private val pending = ArrayList<Map<String, Any?>>()

    private var orchestrator: WaterfallOrchestrator? = null
    private var adapter: InterstitialMediationAdapter? = null
    private var ready = false

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "load" -> {
                load()
                result.success(null)
            }
            "isReady" -> result.success(ready && adapter?.isReady() == true)
            "present" -> {
                present()
                result.success(null)
            }
            "stop" -> {
                stop()
                result.success(null)
            }
            "dispose" -> {
                dispose()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun load() {
        orchestrator?.dispose()
        adapter = null
        ready = false

        // Interstitials prefer an Activity context (ExelBid.show() uses it).
        val loadContext: Context = activityProvider() ?: applicationContext

        val orch = WaterfallOrchestrator(
            format = AdFormat.INTERSTITIAL,
            unitId = adUnitId,
            context = loadContext,
            activity = activityProvider(),
            options = options,
            perNetworkTimeoutMs = perNetworkTimeoutMs,
            emit = ::emit,
            onWon = { won, _ ->
                adapter = won as? InterstitialMediationAdapter
                ready = adapter != null
            },
        )
        orchestrator = orch
        orch.start()
    }

    private fun present() {
        val a = adapter
        if (a == null || !a.isReady()) {
            emit(mapOf("event" to "onFail", "error" to AdErrorMapper.encode(9, "Interstitial not ready")))
            return
        }
        val activity = activityProvider()
        if (activity == null) {
            emit(mapOf("event" to "onFail", "error" to AdErrorMapper.encode(9, "No activity to present interstitial")))
            return
        }
        emit(mapOf("event" to "onWillAppear"))
        a.show(activity)
    }

    private fun stop() {
        orchestrator?.dispose()
        orchestrator = null
        adapter = null
        ready = false
    }

    private fun dispose() {
        stop()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        sink = null
        pending.clear()
        InstanceRegistry.remove(id)
    }

    /** Invoked on the main thread (orchestrator marshals; method calls are main). */
    private fun emit(event: Map<String, Any?>) {
        val s = sink
        if (s != null) s.success(event) else pending.add(event)
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
