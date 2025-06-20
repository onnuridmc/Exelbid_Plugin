package com.motivi.exelbid_plugin

import android.content.Context
import android.graphics.Color
import android.graphics.Rect
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.ViewOutlineProvider
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import com.onnuridmc.exelbid.lib.vast.NativeVideoView
import io.flutter.plugin.common.MethodCall

class EBPNativeView(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0) : FrameLayout(context, attrs, defStyleAttr) {

    var titleView: TextView? = null
    var descriptionView: TextView? = null
    var mainImageView: ImageView? = null
    var mainVideoView: NativeVideoView? = null
    var iconImageView: ImageView? = null
    var callToActionView: Button? = null
    var privacyInformationIconImageView: ImageView? = null

    fun setTitleView(call: MethodCall) {
        if (titleView == null) {
            titleView = TextView(context).apply {
                id = View.generateViewId()
            }
            addView(titleView)
        }

        titleView?.let { view ->
            updateNativeView(view, call)
            updateStylesTextView(view, call)
        }
    }

    fun setDescriptionView(call: MethodCall) {
        if (descriptionView == null) {
            descriptionView = TextView(context).apply {
                id = View.generateViewId()
            }
            addView(descriptionView)
        }

        descriptionView?.let { view ->
            updateNativeView(view, call)
            updateStylesTextView(view, call)
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
            updateNativeView(view, call)
            updateStylesImageView(view, call)
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
            updateNativeView(view, call)
            updateStylesView(view, call)
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
            updateNativeView(view, call)
            updateStylesImageView(view, call)
        }
    }

    fun setCallToActionView(call: MethodCall) {
        if (callToActionView == null) {
            callToActionView = Button(context).apply {
                id = View.generateViewId()
            }
            addView(callToActionView)
        }

        callToActionView?.let { view ->
            updateNativeView(view, call)
            updateStylesTextView(view, call)
            updateStylesView(view, call)
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
            updateNativeView(view, call)
            updateStylesImageView(view, call)
        }
    }

    private fun getRect(call: MethodCall): Rect {
        val x = call.argument<Int>("x") ?: 0
        val y = call.argument<Int>("y") ?: 0
        val width = call.argument<Int>("width") ?: 0
        val height = call.argument<Int>("height") ?: 0

        return Rect(x, y, x + width, y + height)
    }

    private fun updateNativeView(view: View, call: MethodCall) {
        val rect = getRect(call)
        val params = LayoutParams(rect.width(), rect.height()).apply {
            leftMargin = rect.left
            topMargin = rect.top
        }

        this.updateViewLayout(view, params)
    }

    private fun updateStylesImageView(view: ImageView, call: MethodCall) {
        getStyles(call)?.let { styles ->
            val backgroundColor = styles["background_color"] as String?
            val borderRadius = styles["border_radius"] as Double?
            val objectFit = styles["object_fit"] as String?

            view.scaleType = if (objectFit.equals("fill", true)) ImageView.ScaleType.CENTER_CROP else ImageView.ScaleType.FIT_CENTER

            val drawable = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                backgroundColor?.let {
                    setColor(Color.parseColor(it))
                }
                borderRadius.let {
                    cornerRadius = it?.toFloat() ?: 0f
                }
            }

            view.apply {
                clipChildren = true
                clipToPadding = true
                outlineProvider = ViewOutlineProvider.BACKGROUND
                clipToOutline = true
                background = drawable
            }
        }
    }

    private fun updateStylesView(view: View, call: MethodCall) {
        getStyles(call)?.let { styles ->
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

            view.apply {
                clipChildren = true
                clipToPadding = true
                outlineProvider = ViewOutlineProvider.BACKGROUND
                clipToOutline = true
                background = drawable
            }
        }
    }

    private fun updateStylesTextView(view: TextView, call: MethodCall) {
        getStyles(call)?.let { styles ->
            val color = styles["color"] as? String
            color?.let {
                view.setTextColor(Color.parseColor(it))
            }

            val backgroundColor = styles["background_color"] as? String
            backgroundColor?.let {
                view.setBackgroundColor(Color.parseColor(it))
            }

            val fontSize = styles["font_size"] as? Double
            fontSize?.let {
                view.setTextSize(TypedValue.COMPLEX_UNIT_SP, it.toFloat())
            }

            val fontWeight = styles["font_weight"] as? String
            fontWeight?.let {
                val typeface = if (fontWeight.equals("bold", true)) Typeface.BOLD else Typeface.NORMAL
                view.setTypeface(null, typeface)
            }
        }
    }

    private fun getStyles(call: MethodCall): Map<String, Any>? {
        return (call.arguments as? Map<String?, Any?>)?.get("styles") as? Map<String, Any>
    }
}
