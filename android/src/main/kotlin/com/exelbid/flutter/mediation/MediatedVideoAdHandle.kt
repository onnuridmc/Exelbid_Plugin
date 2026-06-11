package com.exelbid.flutter.mediation

import android.app.Activity
import android.content.Context
import com.exelbid.flutter.ChannelNames
import com.exelbid.flutter.InstanceRegistry
import com.exelbid.flutter.mappers.AdErrorMapper
import com.exelbid.flutter.mediation.adapter.VideoMediationAdapter
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * 미디에이션 전체화면 비디오의 인스턴스별 핸들. 인스턴스별 MethodChannel
 * (load/isReady/present/stop/dispose)과 EventChannel, 그리고 VIDEO 워터폴을
 * 실행하는 [WaterfallOrchestrator]를 소유한다.
 *
 * 2단계: `load()`가 워터폴을 실행(낙찰자가 ready 상태가 됨)하고, `present()`가
 * 현재 Activity에 낙찰자를 노출한다. 라이프사이클/상호작용 이벤트는 오케스트레이터의
 * 어댑터 콜백을 통해 이 핸들의 sink로 흐른다.
 *
 * `dispose`까지 [InstanceRegistry]가 보유한다. [MediatedInterstitialAdHandle]과
 * 동일 구조이며, 비디오는 `OnInterstitialAdListener`에 진행률 콜백이 없어
 * `onProgress`는 발행되지 않는다(단독 비디오와 동일).
 */
class MediatedVideoAdHandle(
    private val id: String,
    private val adUnitId: String,
    private val options: Map<String, Any?>?,
    private val perNetworkTimeoutMs: Long?,
    private val applicationContext: Context,
    messenger: BinaryMessenger,
    private val activityProvider: () -> Activity?,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val methodChannel =
        MethodChannel(messenger, ChannelNames.MediatedVideo.method(id))
    private val eventChannel =
        EventChannel(messenger, ChannelNames.MediatedVideo.events(id))

    private var sink: EventChannel.EventSink? = null
    private val pending = ArrayList<Map<String, Any?>>()

    private var orchestrator: WaterfallOrchestrator? = null
    private var adapter: VideoMediationAdapter? = null
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

        // 비디오는 Activity 컨텍스트를 선호한다(ExelBid.show()가 사용).
        val loadContext: Context = activityProvider() ?: applicationContext

        val orch = WaterfallOrchestrator(
            format = AdFormat.VIDEO,
            unitId = adUnitId,
            context = loadContext,
            activity = activityProvider(),
            options = options,
            perNetworkTimeoutMs = perNetworkTimeoutMs,
            emit = ::emit,
            onWon = { won, _ ->
                adapter = won as? VideoMediationAdapter
                ready = adapter != null
            },
        )
        orchestrator = orch
        orch.start()
    }

    private fun present() {
        val a = adapter
        if (a == null || !a.isReady()) {
            emit(mapOf("event" to "onFail", "error" to AdErrorMapper.encode(9, "Video not ready")))
            return
        }
        val activity = activityProvider()
        if (activity == null) {
            emit(mapOf("event" to "onFail", "error" to AdErrorMapper.encode(9, "No activity to present video")))
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

    /** 메인 스레드에서 호출된다(오케스트레이터가 마샬링하며, 메서드 콜은 메인). */
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
