package com.motivi.exelbid_plugin

import android.app.Activity;
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.util.Pair
import com.google.android.gms.ads.identifier.AdvertisingIdClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.BinaryMessenger
import com.onnuridmc.exelbid.ExelBid
import com.onnuridmc.exelbid.ExelBidInterstitial
import com.onnuridmc.exelbid.common.ExelBidError
import com.onnuridmc.exelbid.common.OnInterstitialAdListener
import com.onnuridmc.exelbid.common.OnMediationOrderResultListener
import com.onnuridmc.exelbid.lib.ads.mediation.MediationOrderResult
import com.onnuridmc.exelbid.lib.ads.mediation.MediationType

const val METHOD_CHANNEL_ID = "exelbid_plugin/channel"
const val METHOD_CHANNEL_VIEW_ID = "exelbid_plugin/banner_ad"
const val METHOD_CHANNEL_NATIVE_VIEW_ID = "exelbid_plugin/native_ad"
const val METHOD_CHANNEL_MEDIATION_ID = "exelbid_plugin/mediation"

class ExelbidPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {

    companion object {
        lateinit var channel : MethodChannel
    }

    private lateinit var context: Context
    private lateinit var messenger: BinaryMessenger
    private var activity: Activity? = null
    private var interstitial: ExelBidInterstitial? = null
    private var interstitialVideo: ExelBidInterstitial? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var mediations: MutableMap<String, EBPMediation> = mutableMapOf()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        messenger = flutterPluginBinding.binaryMessenger

        channel = MethodChannel(messenger, METHOD_CHANNEL_ID)
        channel.setMethodCallHandler(this)

        context = flutterPluginBinding.applicationContext

        // Exelbid View Factory
        flutterPluginBinding.platformViewRegistry.registerViewFactory(METHOD_CHANNEL_VIEW_ID, EBPBannerAdViewFactory(messenger))
        flutterPluginBinding.platformViewRegistry.registerViewFactory(METHOD_CHANNEL_NATIVE_VIEW_ID, EBPNativeAdViewFactory(messenger))
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "requestTrackingAuthorization") {
            Thread {
                // 광고식별자 상태 처리  (3: Authorized, 2: Denied)
                try {
                    val adInfo = AdvertisingIdClient.getAdvertisingIdInfo(activity ?: context)
                    if (!adInfo.isLimitAdTrackingEnabled) {
                        result.success(3)
                    } else {
                        result.success(2)
                    }
                } catch (e: Exception) {
                    result.success(2)
                }
            }.start()
        } else if (call.method == "loadInterstitial") {
            val arguments = call.arguments as? Map<String?, Any?>
            if (arguments != null) {
                var adUnitId = arguments.get("ad_unit_id") as? String ?: ""
                var coppa = arguments.get("coppa") as? Boolean ?: true
                var isTest = arguments.get("is_test") as? Boolean ?: false

                loadInterstitial(adUnitId, coppa, isTest)                
            }

            result.success(null)
        } else if (call.method == "showInterstitial") {
            showInterstitial()
            result.success(null)
        } else if (call.method == "loadInterstitialVideo") {
            Log.d(javaClass.name, "[ExelbidPlugin] MethodChannel : loadInterstitialVideo")
            val arguments = call.arguments as? Map<String?, Any?>
            if (arguments != null) {
                var adUnitId = arguments.get("ad_unit_id") as? String ?: ""
                var timer = arguments.get("timer") as? Int ?: 0
                var coppa = arguments.get("coppa") as? Boolean ?: true
                var isTest = arguments.get("is_test") as? Boolean ?: false

                loadInterstitialVideo(adUnitId, timer, coppa, isTest)
            }

            result.success(null)
        } else if (call.method == "showInterstitialVideo") {
            showInterstitialVideo()
            result.success(null)
        } else if (call.method == "initMediation") {
            val arguments = call.arguments as? Map<*, *>
            if (arguments != null) {
                (arguments["mediation_unit_id"] as? String)?.let { unitId ->
                    (arguments["mediation_types"] as? List<String>)?.let { types ->
                        mediations[unitId] = EBPMediation(activity ?: context, unitId, types, messenger)
                    }
                }
            }

            result.success(null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        mediations.clear()

        interstitial?.destroy()
        interstitial = null
        interstitialVideo?.destroy()
        interstitialVideo = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    private fun loadInterstitial(adUnitId: String, coppa: Boolean = false, isTest: Boolean = false) {
        interstitial?.destroy()

        val newInterstitial = ExelBidInterstitial(activity ?: context, adUnitId)
        interstitial = newInterstitial

        newInterstitial.setCoppa(coppa)
        newInterstitial.setTestMode(isTest)

        newInterstitial.setInterstitialAdListener(object : OnInterstitialAdListener {
            override fun onInterstitialLoaded() {
                Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialLoaded")
                mainHandler.post {
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialLoaded post executing : ${interstitial !== newInterstitial}")
                    if (interstitial !== newInterstitial) {
                        return@post
                    }
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialLoaded identity OK, channel=${channel}")
                    try {
                        channel.invokeMethod("onInterstitialLoadAd", null)
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialLoaded invokeMethod Success")
                    } catch(e: Exception) {
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialLoaded invokeMethod Exception: $e")
                    } 
                }
            }

            override fun onInterstitialFailed(errorCode: ExelBidError?, statusCode: Int) {
                Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialFailed (${errorCode?.errorCode}:$statusCode) : ${errorCode?.errorMessage}")
                mainHandler.post {
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialFailed post executing : ${interstitial !== newInterstitial}")
                    if (interstitial !== newInterstitial) {
                        return@post
                    }
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialFailed identity OK, channel=${channel}")
                    
                    try {
                        channel.invokeMethod("onInterstitialFailAd", mapOf("error_message" to errorCode?.errorMessage))
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialFailed invokeMethod Success")
                    } catch(e: Exception) {
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialFailed invokeMethod Exception: $e")
                    }
                }
            }

            override fun onInterstitialShow() {
                Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialShow")
                mainHandler.post {
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialShow post executing : ${interstitial !== newInterstitial}")
                    if (interstitial !== newInterstitial) {
                        return@post
                    }
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialShow identity OK, channel=${channel}")

                    try {
                        channel.invokeMethod("onInterstitialShow", null)
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialShow invokeMethod Success")
                    } catch(e: Exception) {
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialShow invokeMethod Exception: $e")
                    }
                }
            }

            override fun onInterstitialDismiss() {
                Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialDismiss")
                mainHandler.post {
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialDismiss post executing : ${interstitial !== newInterstitial}")
                    if (interstitial !== newInterstitial) {
                        return@post
                    }
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialDismiss identity OK, channel=${channel}")
                    
                    try {
                        channel.invokeMethod("onInterstitialDismiss", null)
                        Log.d(javaClass.name, "[ExelbidPlugin]onInterstitialDismiss invokeMethod Success")
                    } catch(e: Exception) {
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialDismiss invokeMethod Exception: $e")
                    }
                }
            }

            override fun onInterstitialClicked() {
                Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialClicked")
                mainHandler.post {
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialClicked post executing : ${interstitial !== newInterstitial}")
                    if (interstitial !== newInterstitial) {
                        return@post
                    }
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialClicked identity OK, channel=${channel}")

                    try {
                        channel.invokeMethod("onInterstitialClickAd", null)
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialClicked invokeMethod Success")
                    } catch(e: Exception) {
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialClicked invokeMethod Exception: $e")
                    }
                }
            }
        })

        newInterstitial.load()
    }

    private fun showInterstitial() {
        interstitial?.takeIf { it.isReady() }?.show()
    }

    private fun loadInterstitialVideo(adUnitId: String, timer: Int = 0, coppa: Boolean = false, isTest: Boolean = false) {
        interstitialVideo?.destroy()

        val newInterstitial = ExelBidInterstitial(activity ?: context, adUnitId)
        interstitialVideo = newInterstitial

        newInterstitial.setCoppa(coppa)
        newInterstitial.setTestMode(isTest)
        newInterstitial.setTimer(timer)

        newInterstitial.setInterstitialAdListener(object : OnInterstitialAdListener {
            override fun onInterstitialLoaded() {
                Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialLoadedVideo")
                mainHandler.post {
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialLoadedVideo post executing : ${interstitial !== newInterstitial}")
                    if (interstitial !== newInterstitial) {
                        return@post
                    }
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialLoadedVideo identity OK, channel=${channel}")
                    
                    try {
                        channel.invokeMethod("onVideoLoadAd", null)
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialLoadedVideo invokeMethod Success")
                    } catch(e: Exception) {
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialLoadedVideo invokeMethod Exception: $e")
                    }
                }
            }

            override fun onInterstitialFailed(errorCode: ExelBidError?, statusCode: Int) {
                Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialFailedVideo (${errorCode?.errorCode}:$statusCode) : ${errorCode?.errorMessage}")
                mainHandler.post {
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialFailedVideo post executing : ${interstitial !== newInterstitial}")
                    if (interstitial !== newInterstitial) {
                        return@post
                    }
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialFailedVideo identity OK, channel=${channel}")

                    try {
                        channel.invokeMethod("onVideoFailAd", mapOf("error_message" to errorCode?.errorMessage))
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialFailedVideo invokeMethod Success")
                    } catch(e: Exception) {
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialFailedVideo invokeMethod Exception: $e")
                    }
                }
            }

            override fun onInterstitialShow() {
                Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialShowVideo")
                mainHandler.post {
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialShowVideo post executing : ${interstitial !== newInterstitial}")
                    if (interstitial !== newInterstitial) {
                        return@post
                    }
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialShowVideo identity OK, channel=${channel}")

                    try {
                        channel.invokeMethod("onVideoShow", null)
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialShowVideo invokeMethod Success")
                    } catch(e: Exception) {
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialShowVideo invokeMethod Exception: $e")
                    }
                }
            }

            override fun onInterstitialDismiss() {
                Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialDismissVideo")
                mainHandler.post {
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialDismissVideo post executing : ${interstitial !== newInterstitial}")
                    if (interstitial !== newInterstitial) {
                        return@post
                    }
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialDismissVideo identity OK, channel=${channel}")

                    try {
                        channel.invokeMethod("onVideoDismiss", null)
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialDismissVideo invokeMethod Success")
                    } catch(e: Exception) {
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialDismissVideo invokeMethod Exception: $e")
                    }
                }
            }

            override fun onInterstitialClicked() {
                Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialClickedVideo")
                mainHandler.post {
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialClickedVideo post executing : ${interstitial !== newInterstitial}")
                    if (interstitial !== newInterstitial) {
                        return@post
                    }
                    Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialClickedVideo identity OK, channel=${channel}")

                    try {
                        channel.invokeMethod("onVideoClickAd", null)
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialClickedVideo invokeMethod Success")
                    } catch(e: Exception) {
                        Log.d(javaClass.name, "[ExelbidPlugin] onInterstitialClickedVideo invokeMethod Exception: $e")
                    }
                }
            }
        })

        newInterstitial.loadAd()
    }

    private fun showInterstitialVideo() {
        interstitialVideo?.takeIf { it.isReady }?.show()
    }
}

class EBPMediation(
    private val context: Context,
    private val unitId: String,
    private val types: List<String>,
    binaryMessenger: BinaryMessenger
) {
    private val channel: MethodChannel
    private var mediationOrderResult: MediationOrderResult? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    init {
        channel = MethodChannel(binaryMessenger, "${METHOD_CHANNEL_MEDIATION_ID}_$unitId")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "loadMediation" -> {
                    loadMediation(result)
                }
                "nextMediation" -> {
                    nextMediation(result)
                }
            }
        }

        mainHandler.post {
            channel.invokeMethod("onInitMediation", null);
        }
    }

    private fun loadMediation(result: Result) {
        ExelBid.getMediationData(context, unitId, convertToEnumList(types), object: OnMediationOrderResultListener {
            override fun onMediationOrderResult(orderResult: MediationOrderResult) {
                if(orderResult.getSize() > 0) {
                    mediationOrderResult = orderResult;
                    result.success(true)
                } else {
                    result.success(false)
                }
            }

            override fun onMediationFail(errorCode: Int, errorMsg: String) {
                result.success(false)
            }
        });
    }

    private fun nextMediation(result: Result) {
        val currentMediationPair: Pair<MediationType, String>? = mediationOrderResult?.poll()

        currentMediationPair?.let { pair ->
            val networkId: MediationType = pair.first
            val unitId: String = pair.second

            result.success(mapOf("network_id" to networkId.toString(), "unit_id" to unitId))
        } ?: result.success(null)
    }

    private fun convertToEnumList(types: List<String>): ArrayList<MediationType> {
        return types.mapNotNull { type -> MediationType.values().firstOrNull { it.toString() == type } }.toCollection(ArrayList())
    }
}
