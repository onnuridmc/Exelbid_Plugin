package com.motivi.exelbid_plugin

import android.content.Context
import android.graphics.Color
import android.graphics.Rect
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.util.Log
import android.text.TextUtils
import android.util.TypedValue
import androidx.core.content.res.ResourcesCompat
import android.view.Gravity
import android.view.View
import android.view.ViewOutlineProvider
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
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

    init {
        clipChildren = true
        clipToPadding = true
    }

    fun setTitleView(call: MethodCall) {
        if (titleView == null) {
            titleView = TextView(context).apply {
                id = View.generateViewId()
                maxLines = 1
                ellipsize = TextUtils.TruncateAt.END
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
                maxLines = 10
                ellipsize = TextUtils.TruncateAt.END
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
                clipChildren = true
                clipToPadding = true
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
                maxLines = 1
                ellipsize = TextUtils.TruncateAt.END
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

            view.scaleType = if (objectFit.equals("crop", true)) ImageView.ScaleType.CENTER_CROP else ImageView.ScaleType.FIT_CENTER

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
            val fontFamily = styles["font_family"] as? String
            val fontWeight = styles["font_weight"] as? String

            var typeface: Typeface? = null

            if (fontFamily != null) {
                val fontResId = context.resources.getIdentifier(
                    fontFamily,
                    "font",
                    context.packageName
                )

                if (fontResId != 0) {
                    typeface = ResourcesCompat.getFont(context, fontResId)
                }
            }

            val weight = fontWeightToInt(fontWeight)

            if (typeface != null || fontWeight != null) {
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
                    view.typeface = Typeface.create(typeface, weight, false)
                } else {
                    val style = if (weight >= 700) Typeface.BOLD else Typeface.NORMAL
                    view.setTypeface(typeface ?: Typeface.defaultFromStyle(style), style)
                }
            }

            if (fontSize != null) {
                view.setTextSize(TypedValue.COMPLEX_UNIT_SP, fontSize.toFloat())
            }

            val maxLines = styles["max_lines"] as? Int
            if (maxLines != null) {
                view.maxLines = maxLines
            }

            val textOverflow = styles["text_overflow"] as? String
            if (textOverflow != null) {
                view.ellipsize = when (textOverflow) {
                    "ellipsis" -> TextUtils.TruncateAt.END
                    "fade" -> TextUtils.TruncateAt.MARQUEE
                    "clip" -> null
                    "visible" -> null
                    else -> TextUtils.TruncateAt.END
                }
            }
        }
    }

    private fun fontWeightToInt(fontWeight: String?): Int {
        return when (fontWeight) {
            "ultraLight" -> 100
            "thin" -> 200
            "light" -> 300
            "regular" -> 400
            "medium" -> 500
            "semibold" -> 600
            "bold" -> 700
            "heavy" -> 800
            "black" -> 900
            else -> 400
        }
    }

    private fun getStyles(call: MethodCall): Map<String, Any>? {
        return (call.arguments as? Map<String?, Any?>)?.get("styles") as? Map<String, Any>
    }
}
