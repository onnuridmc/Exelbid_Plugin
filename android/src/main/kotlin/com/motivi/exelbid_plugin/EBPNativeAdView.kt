package com.motivi.exelbid_plugin

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.View
import android.view.ViewOutlineProvider
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import com.onnuridmc.exelbid.ExelBidNative
import com.onnuridmc.exelbid.common.ExelBidError
import com.onnuridmc.exelbid.common.NativeAsset
import com.onnuridmc.exelbid.common.NativeViewBinder
import com.onnuridmc.exelbid.common.OnAdNativeListener
import io.flutter.plugin.common.MethodCall

class EBPNativeAdView(private val context: Context, id: Int, creationParams: Map<String?, Any?>?, messenger: BinaryMessenger) : PlatformView {
    private val channel: MethodChannel = MethodChannel(messenger, "${METHOD_CHANNEL_NATIVE_VIEW_ID}_${id}")
    private var nativeAdView: EBPNativeView = EBPNativeView(context)
    private lateinit var nativeAd: ExelBidNative

    init {
        channel.setMethodCallHandler(this::onMethodCall)

        (creationParams?.get("styles") as? Map<String, Any>)?.let { styles ->
            val backgroundColor = styles["background_color"] as String?
            val borderRadius = styles["border_radius"] as Double?

            val drawable = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                backgroundColor?.let {
                    setColor(Color.parseColor(it))
                }
                borderRadius.let {
                    cornerRadius = it?.toFloat() ?: 0f
                }
            }

            nativeAdView.apply {
                clipChildren = true
                clipToPadding = true
                outlineProvider = ViewOutlineProvider.BACKGROUND
                clipToOutline = true
                background = drawable
            }
        }
    }

    override fun getView(): View {
        return nativeAdView
    }

    override fun dispose() {
        if (this::nativeAd.isInitialized) {
            nativeAd.onDestroy()
        }
        nativeAdView.removeAllViews()
        channel.setMethodCallHandler(null)
    }

    private fun loadAd(call: MethodCall) {
        val adUnitId = call.argument<String>("ad_unit_id") ?: ""
        val coppa = call.argument<Boolean>("coppa") ?: false
        val isTest = call.argument<Boolean>("is_test") ?: false
        val assets = call.argument<List<String>>("native_assets") ?: listOf()

        nativeAd = ExelBidNative(context, adUnitId, object :  OnAdNativeListener {
            override fun onFailed(error: ExelBidError, statusCode: Int) {
                channel.invokeMethod("onFailAd", mapOf("error_code" to error.errorCode,"error_message" to error.errorMessage))
            }

            override fun onShow() {
            }

            override fun onClick() {
                channel.invokeMethod("onClickAd", null)
            }

            override fun onLoaded() {
                nativeAdView.visibility = View.VISIBLE

                // Handling separation of display and tracking (for cases like view pagers)
                nativeAd.show()
                // Tracking real view exposure
                nativeAd.imp()

                val nativeData = nativeAd.nativeAdData

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

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
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
