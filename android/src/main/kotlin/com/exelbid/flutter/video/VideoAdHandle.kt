package com.exelbid.flutter.video

import android.app.Activity
import android.content.Context
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
 * Per-instance handle for a standalone (non-mediated) full-screen video ad.
 * ExelBid serves video through [ExelBidInterstitial] (interstitial-video), so
 * this mirrors [com.exelbid.flutter.interstitial.InterstitialAdHandle] on its
 * own `video` channel. Mirrors iOS `VideoAdHandle`.
 *
 * Note: `OnInterstitialAdListener` has no progress callback, so `onProgress` is
 * not emitted on Android.
 */
class VideoAdHandle(
    private val id: String,
    private val adUnitId: String,
    private val options: Map<String, Any?>?,
    private val applicationContext: Context,
    messenger: BinaryMessenger,
    private val activityProvider: () -> Activity?,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val methodChannel = MethodChannel(messenger, ChannelNames.Video.method(id))
    private val eventChannel = EventChannel(messenger, ChannelNames.Video.events(id))

    private var sink: EventChannel.EventSink? = null
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
        val ctx: Context = activityProvider() ?: applicationContext
        val video = ExelBidInterstitial(ctx, adUnitId)
        video.setInterstitialAdListener(object : OnInterstitialAdListener {
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
                            errorCode?.errorMessage ?: "Video failed ($statusCode)",
                        ),
                    ),
                )
            }

            override fun onInterstitialShow() = emit(mapOf("event" to "onDidAppear"))
            override fun onInterstitialDismiss() = emit(mapOf("event" to "onDidDisappear"))
            override fun onInterstitialClicked() = emit(mapOf("event" to "onClick"))
        })
        AdOptionsMapper.apply(video, options)
        // videoSkipMin → ExelBidInterstitial.setTimer(seconds): the skip timer.
        // (AdOptionsMapper operates on the base class `a`, which has no setTimer;
        // this is specific to the interstitial/video object.)
        (options?.get("videoSkipMin") as? Number)?.toInt()?.let { if (it > 0) video.setTimer(it) }
        ad = video
        video.load()
    }

    private fun present() {
        val current = ad
        if (current == null || !ready || !current.isReady()) {
            emit(mapOf("event" to "onFail", "error" to AdErrorMapper.encode(9, "Video not ready")))
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
