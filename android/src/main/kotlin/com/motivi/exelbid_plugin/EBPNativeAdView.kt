package com.motivi.exelbid_plugin

import android.content.Context
import android.graphics.BitmapFactory
import android.util.Log
import android.view.View
import android.widget.ImageView
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import com.onnuridmc.exelbid.ExelBidNative
import com.onnuridmc.exelbid.common.ExelBidError
import com.onnuridmc.exelbid.common.NativeAsset
import com.onnuridmc.exelbid.common.NativeViewBinder
import com.onnuridmc.exelbid.common.OnAdNativeListener
import io.flutter.plugin.common.MethodCall
import java.net.HttpURLConnection
import java.net.URL

class EBPNativeAdView(private val context: Context, id: Int, creationParams: Map<String?, Any?>?, messenger: BinaryMessenger) : PlatformView {
    private val channel: MethodChannel = MethodChannel(messenger, "${METHOD_CHANNEL_NATIVE_VIEW_ID}_${id}")
    private var nativeAdView: EBPNativeView = EBPNativeView(context)
    private lateinit var nativeAd: ExelBidNative

    init {
        channel.setMethodCallHandler { call, result ->
            Log.d("Test", ">>> EBPNativeAdView : " + call.method);
            when (call.method) {
                "setTitleView" -> {
                    nativeAdView.setTitleView(call)
                    result.success(null)
                }
                "setDescriptionView" -> {
                    nativeAdView.setDescriptionView(call)
                    result.success(null)
                }
                "setMainImageView" -> {
                    nativeAdView.setMainImageView(call)
                    result.success(null)
                }
                "setMainVideoView" -> {
                    nativeAdView.setMainVideoView(call)
                    result.success(null)
                }
                "setIconImageView" -> {
                    nativeAdView.setIconImageView(call)
                    result.success(null)
                }
                "setCallToActionView" -> {
                    nativeAdView.setCallToActionView(call)
                    result.success(null)
                }
                "setPrivacyInformationIconImage" -> {
                    nativeAdView.setPrivacyInformationIconImage(call)
                    result.success(null)
                }
                "loadAd" -> {
                    loadAd(call)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun getView(): View = nativeAdView

    override fun dispose() {
        nativeAd.onDestroy()
    }

    private fun loadAd(call: MethodCall) {
        val adUnitId = call.argument<String>("ad_unit_id") ?: ""
        val coppa = call.argument<Boolean>("coppa") ?: false
        val isTest = call.argument<Boolean>("is_test") ?: false
        val assets = call.argument<List<String>>("native_assets") ?: listOf()

        nativeAd = ExelBidNative(context, adUnitId, object :  OnAdNativeListener {
            override fun onFailed(error: ExelBidError, statusCode: Int) {
                Log.d(javaClass.name, "onFailed: ${error.toString()}")

                channel.invokeMethod("onFailAd", mapOf("error_message" to error.errorMessage))
            }

            override fun onShow() {
                Log.d(javaClass.name, "onShow")
            }

            override fun onClick() {
                Log.d(javaClass.name, "onClick")

                channel.invokeMethod("onClickAd", null)
            }

            override fun onLoaded() {
                Log.d(javaClass.name, "onLoaded : " + nativeAd.isReady())

                nativeAdView.visibility = View.VISIBLE

                // Handling separation of display and tracking (for cases like view pagers)
                nativeAd.show()
                // Tracking real view exposure
                nativeAd.imp()

                val nativeData = nativeAd.getNativeAdData()

                channel.invokeMethod("onLoadAd", mapOf("native_data" to mapOf(
                    "title" to nativeData.title,
                    "desc" to nativeData.text,
                    "main" to nativeData.main,
                    "icon" to nativeData.icon,
                    "ctatext" to nativeData.ctatext
                )))
            }
        })

        nativeAd.setCoppa(coppa)
        nativeAd.setTestMode(isTest)

        val nativeBuilder = NativeViewBinder.Builder(nativeAdView)
        nativeAdView.titleView?.let { view -> nativeBuilder.titleTextViewId(view.id) }
        nativeAdView.descriptionView?.let { view -> nativeBuilder.textTextViewId(view.id) }
        nativeAdView.mainImageView?.let { view -> nativeBuilder.mainImageId(view.id) }
        nativeAdView.mainVideoView?.let { view -> nativeBuilder.mediaViewId(view.id) }
        nativeAdView.iconImageView?.let { view -> nativeBuilder.iconImageId(view.id) }
        nativeAdView.callToActionView?.let { view -> nativeBuilder.callToActionButtonId(view.id) }
        nativeAdView.privacyInformationIconImageView?.let { view -> nativeBuilder.adInfoImageId(view.id) }

        nativeAd.setNativeViewBinder(nativeBuilder.build())

        nativeAd.setRequiredAsset(convertListToNativeAssetArray(assets))

        nativeAdView.visibility = View.GONE

        nativeAd.loadAd()
    }

    private fun convertListToNativeAssetArray(strings: List<String>): Array<NativeAsset> {
        return strings.mapNotNull { str -> NativeAsset.values().firstOrNull { it.name == str } }.toTypedArray()
    }

    fun loadImageWithThread(imageView: ImageView, url: String) {
        Thread {
            try {
                val connection = URL(url).openConnection() as HttpURLConnection
                connection.doInput = true
                connection.connect()
                val inputStream = connection.inputStream
                val bitmap = BitmapFactory.decodeStream(inputStream)

                imageView.post {
                    imageView.setImageBitmap(bitmap)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }.start()
    }
}
