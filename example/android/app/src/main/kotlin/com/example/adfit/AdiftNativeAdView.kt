package com.example

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import com.kakao.adfit.ads.na.AdFitAdInfoIconPosition
import com.kakao.adfit.ads.na.AdFitNativeAdBinder
import com.kakao.adfit.ads.na.AdFitNativeAdLayout
import com.kakao.adfit.ads.na.AdFitNativeAdLoader
import com.kakao.adfit.ads.na.AdFitNativeAdRequest
import com.kakao.adfit.ads.na.AdFitVideoAutoPlayPolicy
import io.flutter.plugin.common.MethodCall

class AdiftNativeAdView(private val context: Context, id: Int, creationParams: Map<String?, Any?>?, messenger: BinaryMessenger) : PlatformView,
    AdFitNativeAdLoader.AdLoadListener {
    private val channel: MethodChannel
    private var nativeAdLayout: AdFitNativeAdLayout? = null
    private var nativeAdLoader: AdFitNativeAdLoader? = null
    private var nativeAdBinder: AdFitNativeAdBinder? = null
    private val bannerView: LinearLayout = LinearLayout(context)

    init {
        val clientId = creationParams?.get("client_id") as? String ?: ""

        channel = MethodChannel(messenger, "${METHOD_CHANNEL_NATIVE_VIEW_ID}_${id}")
        channel.setMethodCallHandler(this::onMethodCall)

        nativeAdLoader = AdFitNativeAdLoader.create(getActivityContext(context) ?: context, clientId)
    }

    private fun getActivityContext(context: Context): Activity? {
        return when (context) {
            is Activity -> context
            is ContextWrapper -> {
                var baseContext = context.baseContext
                while (baseContext is ContextWrapper && baseContext !is Activity) {
                    baseContext = baseContext.baseContext
                }
                baseContext as? Activity
            }
            else -> null
        }
    }

    override fun getView(): View = bannerView

    override fun dispose() {
        nativeAdBinder?.unbind()
        nativeAdBinder = null
        nativeAdLoader = null
    }

    private fun loadAd(call: MethodCall) {
        val request = AdFitNativeAdRequest.Builder()
            .setAdInfoIconPosition(AdFitAdInfoIconPosition.RIGHT_TOP)
            .setVideoAutoPlayPolicy(AdFitVideoAutoPlayPolicy.WIFI_ONLY)
            .build()

        nativeAdLoader?.loadAd(request, this)
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadAd" -> {
                loadAd(call)
            }
            "" -> {
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onAdLoaded(binder: AdFitNativeAdBinder) {
        if (nativeAdLoader == null) {
            return
        }

        var nativeAdLayout = nativeAdLayout
        if (nativeAdLayout == null) {
            val nativeAdView = LayoutInflater.from(context).inflate(R.layout.adfit_native_ad, bannerView, false)
            bannerView.addView(nativeAdView)

            nativeAdLayout = AdFitNativeAdLayout.Builder(nativeAdView.findViewById(R.id.containerView)) // 네이티브 광고 영역 (광고 아이콘이 배치 됩니다)
                .setContainerViewClickable(false) // 광고 영역 클릭 가능 여부 (기본값: false)
                .setTitleView(nativeAdView.findViewById(R.id.titleTextView)) // 광고 제목 (필수)
                .setBodyView(nativeAdView.findViewById(R.id.bodyTextView)) // 광고 홍보문구
                .setProfileIconView(nativeAdView.findViewById(R.id.profileIconView)) // 광고주 아이콘 (브랜드 로고)
                .setProfileNameView(nativeAdView.findViewById(R.id.profileNameTextView)) // 광고주 이름 (브랜드명)
                .setMediaView(nativeAdView.findViewById(R.id.mediaView)) // 광고 미디어 소재 (이미지, 비디오) (필수)
                .setCallToActionButton(nativeAdView.findViewById(R.id.callToActionButton)) // 행동유도버튼 (알아보기, 바로가기 등)
                .build()

            this.nativeAdLayout = nativeAdLayout
        } else {
            // 이전에 노출 중인 광고가 있으면 해제
            this.nativeAdBinder?.unbind()
        }

        // 광고 노출
        nativeAdBinder = binder
        binder.bind(nativeAdLayout)
    }

    override fun onAdLoadError(errorCode: Int) {

    }
}

