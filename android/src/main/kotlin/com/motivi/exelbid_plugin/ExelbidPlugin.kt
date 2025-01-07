package com.motivi.exelbid_plugin

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.onnuridmc.exelbid.ExelBidInterstitial
import com.onnuridmc.exelbid.common.ExelBidError
import com.onnuridmc.exelbid.common.OnInterstitialAdListener

const val METHOD_CHANNEL_ID = "exelbid_plugin"
const val METHOD_CHANNEL_VIEW_ID = "exelbid_plugin/banner_ad"

public class ExelbidPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {

    companion object {
        lateinit var channel : MethodChannel
    }

    private lateinit var context : Context
    private lateinit var interstitial : ExelBidInterstitial

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_ID)
        channel.setMethodCallHandler(this)

        context = flutterPluginBinding.applicationContext
        flutterPluginBinding.platformViewRegistry.registerViewFactory(METHOD_CHANNEL_VIEW_ID, EBPBannerAdViewFactory(flutterPluginBinding.binaryMessenger))
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "loadInterstitial") {
            val arguments = call.arguments as? Map<String?, Any?>
            if (arguments != null) {
                var adUnitId = arguments.get("ad_unit_id") as? String ?: ""
                var coppa = arguments.get("coppa") as? Boolean ?: true
                var yob = arguments.get("yob") as? String ?: ""
                var gender = arguments.get("gender") as? Boolean ?: true
                var keywords = arguments.get("keywords") as? Map<String, String>
                var isTest = arguments.get("is_test") as? Boolean ?: false

                interstitial = ExelBidInterstitial(context, adUnitId)

                interstitial.setCoppa(coppa)
                interstitial.setYob(yob)
                interstitial.setGender(gender)
                interstitial.setTestMode(isTest)

                keywords?.forEach { (key, value) ->
                    interstitial.addKeyword(key, value)
                }

                interstitial.setInterstitialAdListener(object : OnInterstitialAdListener {
                    override fun onInterstitialLoaded() {
                        channel?.invokeMethod("onLoadAd", null)
                    }

                    override fun onInterstitialFailed(errorCode: ExelBidError?, statusCode: Int) {
                        channel?.invokeMethod("onFailAd", null)
                    }

                    override fun onInterstitialShow() {
                        channel?.invokeMethod("onInterstitialShow", null)
                    }

                    override fun onInterstitialDismiss() {
                        channel?.invokeMethod("onInterstitialDismiss", null)
                    }

                    override fun onInterstitialClicked() {
                        channel?.invokeMethod("onClickAd", null)
                    }                    
                })

                interstitial.load()

                result.success(null)
            }
        } else if (call.method == "showInterstitial") {
            if (interstitial.isReady()) {
                interstitial.show()

                result.success(null)
            } else {
                result.success(null)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.let {
            it.setMethodCallHandler(null)
        }
        interstitial?.let {
            it.destroy()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }
    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
}
