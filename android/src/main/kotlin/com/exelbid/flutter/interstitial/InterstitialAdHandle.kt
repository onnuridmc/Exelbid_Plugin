package com.exelbid.flutter.interstitial

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import com.exelbid.flutter.ChannelNames
import com.exelbid.flutter.InstanceRegistry
import com.exelbid.flutter.mappers.AdErrorMapper
import com.exelbid.flutter.mappers.AdOptionsMapper
import com.onnuridmc.exelbid.ExelBidInterstitial
import com.onnuridmc.exelbid.common.ExelBidError
import com.onnuridmc.exelbid.common.OnInterstitialAdListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Per-instance handle for a standalone (non-mediated) interstitial. Wraps
 * [ExelBidInterstitial] directly. Mirrors iOS `InterstitialAdHandle`.
 *
 * Two-stage: `load()` → `present()`. Held by [InstanceRegistry] until `dispose`.
 */
class InterstitialAdHandle(
    private val id: String,
    private val adUnitId: String,
    private val options: Map<String, Any?>?,
    private val applicationContext: Context,
    messenger: BinaryMessenger,
    private val activityProvider: () -> Activity?,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val methodChannel = MethodChannel(messenger, ChannelNames.Interstitial.method(id))
    private val eventChannel = EventChannel(messenger, ChannelNames.Interstitial.events(id))

    private var sink: EventChannel.EventSink? = null
    private val main = Handler(Looper.getMainLooper())
    private val pending = ArrayList<Map<String, Any?>>()

    private var ad: ExelBidInterstitial? = null
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
            "isReady" -> result.success(ready && ad?.isReady() == true)
            "present" -> {
                present()
                result.success(null)
            }
            "stop" -> {
                ad?.destroy()
                ad = null
                ready = false
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
        ready = false
        // ExelBidInterstitial.show() uses the context it was created with → prefer Activity.
        val ctx: Context = activityProvider() ?: applicationContext
        val interstitial = ExelBidInterstitial(ctx, adUnitId)
        interstitial.setInterstitialAdListener(object : OnInterstitialAdListener {
            override fun onInterstitialLoaded() {
                ready = true
                emit(mapOf("event" to "onLoad"))
            }

            override fun onInterstitialFailed(errorCode: ExelBidError?, statusCode: Int) {
                emit(
                    mapOf(
                        "event" to "onFail",
                        "error" to AdErrorMapper.encode(
                            0,
                            errorCode?.errorMessage ?: "Interstitial failed ($statusCode)",
                        ),
                    ),
                )
            }

            override fun onInterstitialShow() = emit(mapOf("event" to "onDidAppear"))
            override fun onInterstitialDismiss() = emit(mapOf("event" to "onDidDisappear"))
            override fun onInterstitialClicked() = emit(mapOf("event" to "onClick"))
        })
        AdOptionsMapper.apply(interstitial, options)
        ad = interstitial
        interstitial.load()
    }

    private fun present() {
        val current = ad
        if (current == null || !ready || !current.isReady()) {
            emit(mapOf("event" to "onFail", "error" to AdErrorMapper.encode(9, "Interstitial not ready")))
            return
        }
        emit(mapOf("event" to "onWillAppear"))
        current.show()
    }

    private fun dispose() {
        ad?.destroy()
        ad = null
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        sink = null
        pending.clear()
        InstanceRegistry.remove(id)
    }

    /**
     * SDK ad-listener callbacks may arrive off the platform thread; marshal to
     * main so EventSink delivery (and sink/pending access) stays on one thread.
     */
    private fun emit(event: Map<String, Any?>) {
        main.post {
            val s = sink
            if (s != null) s.success(event) else pending.add(event)
        }
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
