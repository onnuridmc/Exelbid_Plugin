package com.motivi.exelbid_plugin

import android.content.Context
import android.graphics.Rect
import android.util.AttributeSet
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import com.onnuridmc.exelbid.lib.vast.NativeVideoView
import io.flutter.plugin.common.MethodCall

class EBPNativeView(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0) : FrameLayout(context, attrs, defStyleAttr) {

    var titleView: FrameLayout? = null
    var descriptionView: FrameLayout? = null
    var mainImageView: ImageView? = null
    var mainVideoView: NativeVideoView? = null
    var iconImageView: ImageView? = null
    var callToActionView: TextView? = null
    var privacyInformationIconImageView: ImageView? = null

    fun setTitleView(call: MethodCall) {
        if (titleView == null) {
            titleView = FrameLayout(context).apply {
                id = View.generateViewId()
            }
            addView(titleView)
        }

        titleView?.let { view ->
            updateNativeView(view, getRect(call))
        }
    }

    fun setDescriptionView(call: MethodCall) {
        if (descriptionView == null) {
            descriptionView = FrameLayout(context).apply {
                id = View.generateViewId()
            }
            addView(descriptionView)
        }

        descriptionView?.let { view ->
            updateNativeView(view, getRect(call))
        }
    }

    fun setMainImageView(call: MethodCall) {
        if (mainImageView == null) {
            mainImageView = ImageView(context).apply {
                id = View.generateViewId()
            }
            addView(mainImageView)
        }

        mainImageView?.let { view ->
            updateNativeView(view, getRect(call))
        }
    }

    fun setMainVideoView(call: MethodCall) {
        if (mainVideoView == null) {
            mainVideoView = NativeVideoView(context).apply {
                id = View.generateViewId()
                gravity = Gravity.CENTER_HORIZONTAL
            }
            addView(mainVideoView)
        }

        mainVideoView?.let { view ->
            updateNativeView(view, getRect(call))
        }
    }

    fun setIconImageView(call: MethodCall) {
        if (iconImageView == null) {
            iconImageView = ImageView(context).apply {
                id = View.generateViewId()
            }
            addView(iconImageView)
        }

        iconImageView?.let { view ->
            updateNativeView(view, getRect(call))
        }
    }

    fun setCallToActionView(call: MethodCall) {
        if (callToActionView == null) {
            callToActionView = TextView(context).apply {
                id = View.generateViewId()
                alpha = 0f
            }
            addView(callToActionView)
        }

        callToActionView?.let { view ->
            updateNativeView(view, getRect(call))
        }
    }

    fun setPrivacyInformationIconImage(call: MethodCall) {
        if (privacyInformationIconImageView == null) {
            privacyInformationIconImageView = ImageView(context).apply {
                id = View.generateViewId()
            }
            addView(privacyInformationIconImageView)
        }

        privacyInformationIconImageView?.let { view ->
            updateNativeView(view, getRect(call))
        }
    }

    private fun getRect(call: MethodCall): Rect {
        val x = call.argument<Int>("x") ?: 0
        val y = call.argument<Int>("y") ?: 0
        val width = call.argument<Int>("width") ?: 0
        val height = call.argument<Int>("height") ?: 0

        return Rect(x, y, x + width, y + height)
    }

    private fun updateNativeView(view: View, rect: Rect) {
        val params = FrameLayout.LayoutParams(rect.width(), rect.height()).apply {
            leftMargin = rect.left
            topMargin = rect.top
        }

        this.updateViewLayout(view, params)
    }
}
