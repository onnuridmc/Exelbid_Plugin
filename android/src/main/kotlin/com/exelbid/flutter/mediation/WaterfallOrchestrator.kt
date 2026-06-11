package com.exelbid.flutter.mediation

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import com.exelbid.flutter.mappers.AdErrorMapper
import com.exelbid.flutter.mappers.WaterfallEventMapper
import com.exelbid.flutter.mediation.adapter.MediationAdCallback
import com.exelbid.flutter.mediation.adapter.MediationAdapter
import com.exelbid.flutter.mediation.adapter.MediationLoadConfig
import com.exelbid.flutter.mediation.nativead.NativeAdRendering
import com.onnuridmc.exelbid.ExelBid
import com.onnuridmc.exelbid.common.OnMediationOrderResultListener
import com.onnuridmc.exelbid.lib.ads.mediation.MediationOrderResult

/**
 * Runs the mediation waterfall on Android, reproducing what the iOS SDK does
 * internally.
 *
 * The Android ExelBid SDK only returns an *order* (`MediationOrderResult`) from
 * `getMediationData`; iterating networks and falling back on failure is the
 * caller's job. This orchestrator owns that loop so Dart sees the same API as
 * iOS:
 *
 *   fetching → getMediationData → fetched(networks)
 *     → for each polled entry: trying → adapter.load
 *         → onLoaded ⇒ won + onLoad(winningNetwork)  (waterfall ends)
 *         → onFailed/timeout ⇒ lost ⇒ next entry
 *     → queue exhausted / getMediationData fail ⇒ noFill + onFail
 *
 * All Flutter-facing emits and the [onWon] hand-off are marshalled to the main
 * thread (SDK callbacks arrive on unspecified threads).
 *
 * One orchestrator drives one load; create a new one per (re)load.
 */
class WaterfallOrchestrator(
    private val format: AdFormat,
    private val unitId: String,
    private val context: Context,
    private val activity: Activity?,
    private val options: Map<String, Any?>?,
    private val widthDp: Int? = null,
    private val heightDp: Int? = null,
    private val perNetworkTimeoutMs: Long? = null,
    /** Host native slot rendering (NATIVE only); forwarded in the load config. */
    private val rendering: NativeAdRendering? = null,
    /** EventChannel emit. Always invoked on the main thread. */
    private val emit: (Map<String, Any?>) -> Unit,
    /** Winner hand-off (e.g. attach banner view / bind native). Main thread. */
    private val onWon: (adapter: MediationAdapter, networkId: String) -> Unit,
    /** Extra keys merged into the onLoad event (e.g. native `data`). Main thread. */
    private val onLoadExtra: (() -> Map<String, Any?>)? = null,
) {
    private val main = Handler(Looper.getMainLooper())

    private var order: MediationOrderResult? = null
    private var total = 0
    private var position = 0
    private var current: MediationAdapter? = null
    private var startTs = 0L
    private var timeout: Runnable? = null

    /** Terminal: a winner was found or noFill was emitted. */
    private var finished = false

    /** Host released the surface — suppress all further emits/work. */
    private var disposed = false

    // MARK: - Public

    fun start() {
        emitWaterfall(WaterfallEventMapper.fetching())

        val useList = ArrayList(
            MediationAdapterRegistry.registeredNetworks(format).mapNotNull { mediationTypeOf(it) },
        )

        ExelBid.getMediationData(
            context,
            unitId,
            useList,
            object : OnMediationOrderResultListener {
                override fun onMediationOrderResult(result: MediationOrderResult) {
                    if (disposed || finished) return
                    if (result.size <= 0) {
                        noFill()
                        return
                    }
                    total = result.size
                    // fetched.networks: poll-all to read the full order, then
                    // reset() to restore before the real waterfall.
                    emitWaterfall(WaterfallEventMapper.fetched(drain(result)))
                    result.reset()
                    order = result
                    tryNext()
                }

                override fun onMediationFail(errorCode: Int, errorMsg: String?) {
                    if (disposed || finished) return
                    noFill(errorMsg ?: "Mediation failed ($errorCode)")
                }
            },
        )
    }

    /** Stop any in-flight work and release the current adapter. */
    fun dispose() {
        disposed = true
        finished = true
        cancelTimeout()
        current?.let {
            it.cancel()
            it.destroy()
        }
        current = null
        order = null
    }

    fun onPause() {
        current?.onPause()
    }

    fun onResume() {
        current?.onResume()
    }

    // MARK: - Waterfall loop

    private fun tryNext() {
        if (disposed || finished) return
        val pair = order?.poll()
        if (pair == null) {
            noFill()
            return
        }
        position += 1
        val type = pair.first
        val networkUnitId = pair.second
        val networkId = type.networkId()

        emitWaterfall(WaterfallEventMapper.trying(networkId, networkUnitId, position, total))

        val adapter = MediationAdapterRegistry.create(networkId, format)
        if (adapter == null || !adapter.isAvailable) {
            emitWaterfall(WaterfallEventMapper.lost(networkId, position, "adapterNotRegistered"))
            tryNext()
            return
        }

        current = adapter
        startTs = SystemClock.elapsedRealtime()
        scheduleTimeout(networkId)

        adapter.load(
            MediationLoadConfig(networkUnitId, context, activity, widthDp, heightDp, options, rendering),
            object : MediationAdCallback {
                override fun onLoaded() {
                    if (disposed || finished) return
                    cancelTimeout()
                    val latency = SystemClock.elapsedRealtime() - startTs
                    finished = true
                    emitWaterfall(WaterfallEventMapper.won(networkId, position, latency))
                    // onWon (attach/bind) then onLoad in a single main-thread step so
                    // onLoadExtra (native data) sees the bound adapter's model.
                    main.post {
                        if (disposed) return@post
                        onWon(adapter, networkId)
                        val event = HashMap<String, Any?>()
                        event["event"] = "onLoad"
                        event["winningNetwork"] = networkId
                        onLoadExtra?.invoke()?.let { event.putAll(it) }
                        emit(event)
                    }
                }

                override fun onFailed(reason: String) {
                    if (disposed || finished) return
                    cancelTimeout()
                    lostAndNext(networkId, reason)
                }

                override fun onClicked() = emitEvent(mapOf("event" to "onClick"))
                override fun onLeaveApp() = emitEvent(mapOf("event" to "onLeaveApp"))
                override fun onClickFinish() = emitEvent(mapOf("event" to "onClickFinish"))
                override fun onImpression() = emitEvent(mapOf("event" to "onImpression"))
                override fun onImpression50() = emitEvent(mapOf("event" to "onImpression50"))
                override fun onImpression100() = emitEvent(mapOf("event" to "onImpression100"))
                override fun onWillAppear() = emitEvent(mapOf("event" to "onWillAppear"))
                override fun onDidAppear() = emitEvent(mapOf("event" to "onDidAppear"))
                override fun onWillDisappear() = emitEvent(mapOf("event" to "onWillDisappear"))
                override fun onDidDisappear() = emitEvent(mapOf("event" to "onDidDisappear"))
            },
        )
    }

    private fun lostAndNext(networkId: String, reason: String) {
        emitWaterfall(WaterfallEventMapper.lost(networkId, position, reason))
        current?.destroy()
        current = null
        tryNext()
    }

    private fun noFill(message: String = "No ad available after mediation waterfall") {
        if (disposed || finished) return
        finished = true
        cancelTimeout()
        emitWaterfall(WaterfallEventMapper.noFill())
        emitEvent(mapOf("event" to "onFail", "error" to AdErrorMapper.noFill(message)))
    }

    // MARK: - Timeout

    private fun scheduleTimeout(networkId: String) {
        val ms = perNetworkTimeoutMs ?: return
        val r = Runnable {
            if (disposed || finished) return@Runnable
            current?.cancel()
            lostAndNext(networkId, "timeout ${ms}ms")
        }
        timeout = r
        main.postDelayed(r, ms)
    }

    private fun cancelTimeout() {
        timeout?.let { main.removeCallbacks(it) }
        timeout = null
    }

    // MARK: - Helpers

    /** poll() everything to build the network-id order; caller must reset(). */
    private fun drain(result: MediationOrderResult): List<String> {
        val out = ArrayList<String>()
        while (true) {
            val pair = result.poll() ?: break
            out.add(pair.first.networkId())
        }
        return out
    }

    private fun emitWaterfall(waterfall: Map<String, Any?>) =
        emitEvent(mapOf("event" to "onWaterfall", "waterfall" to waterfall))

    private fun emitEvent(event: Map<String, Any?>) {
        main.post { if (!disposed) emit(event) }
    }
}
