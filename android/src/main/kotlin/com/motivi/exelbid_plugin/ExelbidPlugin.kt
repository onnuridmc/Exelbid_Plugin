package com.motivi.exelbid_plugin

import android.content.Context
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

const val METHOD_CHANNEL_ID = "exelbid_plugin"
const val METHOD_CHANNEL_VIEW_ID = "exelbid_plugin/banner_ad"
const val METHOD_CHANNEL_NATIVE_VIEW_ID = "exelbid_plugin/native_ad"
const val METHOD_CHANNEL_MEDIATION_ID = "exelbid_plugin/mediation"

class ExelbidPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {

    companion object {
        lateinit var channel : MethodChannel
    }

    private lateinit var context: Context
    private lateinit var messenger: BinaryMessenger
    private lateinit var interstitial: ExelBidInterstitial
    private var mediations: MutableMap<String, EBPMediation> = mutableMapOf()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        messenger = flutterPluginBinding.binaryMessenger

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_ID)
        channel.setMethodCallHandler(this)

        context = flutterPluginBinding.applicationContext

        // Exelbid View Factory
        flutterPluginBinding.platformViewRegistry.registerViewFactory(METHOD_CHANNEL_VIEW_ID, EBPBannerAdViewFactory(flutterPluginBinding.binaryMessenger))
        flutterPluginBinding.platformViewRegistry.registerViewFactory(METHOD_CHANNEL_NATIVE_VIEW_ID, EBPNativeAdViewFactory(flutterPluginBinding.binaryMessenger))
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "requestTrackingAuthorization") {
            // 광고식별자 상태 처리  (3: Authorized, 2: Denied)
            try {
                val adInfo = AdvertisingIdClient.getAdvertisingIdInfo(context)
                if (!adInfo.isLimitAdTrackingEnabled) {
                    result.success(3)
                } else {
                    result.success(2)
                }
            } catch (e: Exception) {
                result.success(2)
            }
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
            if (this::interstitial.isInitialized && interstitial.isReady()) {
                showInterstitial()   
            }

            result.success(null)
        } else if (call.method == "initMediation") {
            val arguments = call.arguments as? Map<*, *>
            if (arguments != null) {
                (arguments["mediation_unit_id"] as? String)?.let { unitId ->
                    (arguments["mediation_types"] as? List<String>)?.let { types ->
                        mediations[unitId] = EBPMediation(context, unitId, types, messenger)
                    }
                }
            }

            result.success(null)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)

        if (this::interstitial.isInitialized) {
            interstitial.destroy()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }
    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    fun loadInterstitial(adUnitId: String, coppa: Boolean = false, isTest: Boolean = false) {
        interstitial = ExelBidInterstitial(context, adUnitId)

        interstitial.setCoppa(coppa)
        interstitial.setTestMode(isTest)

        interstitial.setInterstitialAdListener(object : OnInterstitialAdListener {
            override fun onInterstitialLoaded() {
                channel?.invokeMethod("onInterstitialLoadAd", null)
            }

            override fun onInterstitialFailed(errorCode: ExelBidError?, statusCode: Int) {
                channel?.invokeMethod("onInterstitialFailAd", null)
            }

            override fun onInterstitialShow() {
                channel?.invokeMethod("onInterstitialShow", null)
            }

            override fun onInterstitialDismiss() {
                channel?.invokeMethod("onInterstitialDismiss", null)
            }

            override fun onInterstitialClicked() {
                channel?.invokeMethod("onInterstitialClickAd", null)
            }                    
        })

        interstitial.load()
    }

    fun showInterstitial() {
        if (this::interstitial.isInitialized) {
            interstitial.show()
        }
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
                else -> result.notImplemented()
            }
        }
    }

    private fun loadMediation(result: Result) {
        ExelBid.getMediationData(context, unitId, convertToEnumList(types), object: OnMediationOrderResultListener {
            override fun onMediationOrderResult(orderResult: MediationOrderResult) {
                if(orderResult != null && orderResult.getSize() > 0) {
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
        return types.mapNotNull { type -> MediationType.values().firstOrNull { it.name == type } }.toCollection(ArrayList())
    }
}
