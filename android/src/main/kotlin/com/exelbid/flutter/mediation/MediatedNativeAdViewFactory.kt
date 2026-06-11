package com.exelbid.flutter.mediation

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/** Factory for the mediated native PlatformView. */
class MediatedNativeAdViewFactory(
    private val messenger: BinaryMessenger,
    private val activityProvider: () -> Activity?,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?>
        return MediatedNativeAdPlatformView(
            context = context,
            viewId = viewId.toLong(),
            args = params,
            messenger = messenger,
            activityProvider = activityProvider,
        )
    }
}
