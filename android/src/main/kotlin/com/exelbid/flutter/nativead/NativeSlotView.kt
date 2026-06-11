package com.exelbid.flutter.nativead

import android.content.Context
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.text.TextUtils
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.res.ResourcesCompat

/**
 * Host rendering surface for a standalone (non-mediated) ExelBid native ad.
 *
 * A transparent [FrameLayout] whose children are slot views (TextView/ImageView)
 * positioned at the rects Flutter measured for each slot widget. Each view gets a
 * generated id so ExelBid's `NativeViewBinder` (which maps by view id) can find
 * them inside this container.
 *
 * Self-contained — no mediation dependencies. Rects/styles arrive from Dart in
 * logical pixels (dp); converted to px here.
 */
class NativeSlotView(context: Context) : FrameLayout(context) {

    private val density = resources.displayMetrics.density

    var titleView: TextView? = null
        private set
    var bodyView: TextView? = null
        private set
    var ctaView: TextView? = null
        private set
    var sponsoredView: TextView? = null
        private set
    var displayUrlView: TextView? = null
        private set
    var iconView: ImageView? = null
        private set

    /** Media slot container — the single home for the main creative (image/video). */
    var mediaContainer: FrameLayout? = null
        private set

    /** Inner image inside [mediaContainer] for the in-house `mainImageId` (static). */
    var mainImageView: ImageView? = null
        private set
    var logoView: ImageView? = null
        private set
    var privacyView: ImageView? = null
        private set

    init {
        setBackgroundColor(0x00000000)
    }

    fun setTitleView(args: Map<*, *>) {
        titleView = ensureText(titleView); place(titleView, args)
    }

    fun setDescriptionView(args: Map<*, *>) {
        bodyView = ensureText(bodyView); place(bodyView, args)
    }

    fun setCallToActionView(args: Map<*, *>) {
        ctaView = ensureText(ctaView, singleLine = true); place(ctaView, args)
    }

    fun setSponsoredView(args: Map<*, *>) {
        sponsoredView = ensureText(sponsoredView, singleLine = true); place(sponsoredView, args)
    }

    fun setDisplayUrlView(args: Map<*, *>) {
        displayUrlView = ensureText(displayUrlView, singleLine = true); place(displayUrlView, args)
    }

    fun setIconImageView(args: Map<*, *>) {
        iconView = ensureImage(iconView); place(iconView, args)
    }

    fun setMediaView(args: Map<*, *>) {
        ensureMedia()
        // Box style (bg/cornerRadius) goes on the container; the image-only
        // `contentMode` must reach the inner ImageView the SDK fills.
        place(mediaContainer, args)
        (args["style"] as? Map<*, *>)?.let { s ->
            (s["contentMode"] as? String)?.let { mainImageView?.scaleType = scaleTypeFor(it) }
        }
    }

    fun setLogoImageView(args: Map<*, *>) {
        logoView = ensureImage(logoView); place(logoView, args)
    }

    fun setPrivacyInformationIconImage(args: Map<*, *>) {
        privacyView = ensureImage(privacyView); place(privacyView, args)
    }

    /** True once at least the title or media slot has been positioned. */
    fun hasAnySlot(): Boolean =
        titleView != null || mediaContainer != null || bodyView != null

    // MARK: - View creation / placement

    private fun ensureText(existing: TextView?, singleLine: Boolean = false): TextView {
        if (existing != null) return existing
        return TextView(context).also {
            it.id = View.generateViewId()
            it.includeFontPadding = false
            if (singleLine) it.maxLines = 1
            addView(it)
        }
    }

    private fun ensureImage(existing: ImageView?): ImageView {
        if (existing != null) return existing
        return ImageView(context).also {
            it.id = View.generateViewId()
            it.scaleType = ImageView.ScaleType.FIT_CENTER
            addView(it)
        }
    }

    /**
     * Creates the media slot once: a [FrameLayout] container with a full-bleed
     * inner [ImageView]. The container backs the in-house `mediaViewId` (video);
     * the inner image backs `mainImageId` (static).
     */
    private fun ensureMedia() {
        if (mediaContainer != null) return
        val container = FrameLayout(context).also {
            it.id = View.generateViewId()
            addView(it)
        }
        mainImageView = ImageView(context).also {
            it.id = View.generateViewId()
            it.scaleType = ImageView.ScaleType.FIT_CENTER
            container.addView(
                it,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT,
                ),
            )
        }
        mediaContainer = container
    }

    private fun place(view: View?, args: Map<*, *>) {
        view ?: return
        val lp = FrameLayout.LayoutParams(px(args["width"]), px(args["height"]), Gravity.TOP or Gravity.START)
        lp.leftMargin = px(args["x"])
        lp.topMargin = px(args["y"])
        view.layoutParams = lp
        (args["style"] as? Map<*, *>)?.let { applyStyle(view, it) }
    }

    private fun applyStyle(view: View, s: Map<*, *>) {
        val bg = colorOf(s["backgroundColor"])
        val radius = (s["cornerRadius"] as? Number)?.toFloat()?.let { it * density }
        if (bg != null || radius != null) {
            view.background = GradientDrawable().apply {
                if (bg != null) setColor(bg)
                if (radius != null) cornerRadius = radius
            }
            view.clipToOutline = radius != null
        }

        if (view is TextView) {
            colorOf(s["textColor"])?.let { view.setTextColor(it) }
            (s["fontSize"] as? Number)?.let { view.setTextSize(TypedValue.COMPLEX_UNIT_DIP, it.toFloat()) }
            // 커스텀 폰트(res/font) + weight 적용. fontFamily가 해석되면 그
            // typeface를, 아니면 기존 typeface를 베이스로 bold/normal만 토글한다.
            val family = (s["fontFamily"] as? String)?.takeIf { it.isNotEmpty() }?.let { fontFor(it) }
            val weight = (s["fontWeight"] as? Number)?.toInt()
            if (family != null || weight != null) {
                val style = if ((weight ?: 400) >= 600) Typeface.BOLD else Typeface.NORMAL
                view.setTypeface(family ?: view.typeface, style)
            }
            (s["maxLines"] as? Number)?.toInt()?.let { if (it > 0) view.maxLines = it }
            (s["textAlign"] as? String)?.let { view.gravity = gravityFor(it) }
            (s["overflow"] as? String)?.let { applyOverflow(view, it) }
            (s["padding"] as? Map<*, *>)?.let {
                view.setPadding(px(it["left"]), px(it["top"]), px(it["right"]), px(it["bottom"]))
            }
        } else if (view is ImageView) {
            (s["contentMode"] as? String)?.let { view.scaleType = scaleTypeFor(it) }
        }
    }

    private fun px(value: Any?): Int {
        val v = (value as? Number)?.toDouble() ?: 0.0
        return (v * density).toInt()
    }

    /**
     * Resolves a host-app font by resource name (a `res/font/<name>.xml` family
     * or a single font file) to a [Typeface]. Returns null when the name isn't a
     * registered font resource, so the caller falls back to the default typeface
     * (the "unregistered font → system font" contract).
     */
    private fun fontFor(family: String): Typeface? {
        val id = resources.getIdentifier(family, "font", context.packageName)
        if (id == 0) return null
        return runCatching { ResourcesCompat.getFont(context, id) }.getOrNull()
    }

    /** Decodes a Dart ARGB int (0xAARRGGBB), which may arrive as Int or Long. */
    private fun colorOf(value: Any?): Int? {
        val n = value as? Number ?: return null
        return (n.toLong() and 0xFFFFFFFFL).toInt()
    }

    /**
     * Maps a Dart `TextOverflow` name to a [TextView]'s truncation. `visible`
     * has no native equivalent (the view clips to bounds) → treated like `clip`.
     */
    private fun applyOverflow(view: TextView, name: String) {
        when (name) {
            "ellipsis" -> {
                view.ellipsize = TextUtils.TruncateAt.END
                view.isHorizontalFadingEdgeEnabled = false
            }
            "fade" -> {
                view.ellipsize = null
                view.isHorizontalFadingEdgeEnabled = true
            }
            else -> { // "clip" / "visible"
                view.ellipsize = null
                view.isHorizontalFadingEdgeEnabled = false
            }
        }
    }

    private fun gravityFor(align: String): Int = when (align) {
        "right" -> Gravity.END or Gravity.CENTER_VERTICAL
        "center" -> Gravity.CENTER
        else -> Gravity.START or Gravity.CENTER_VERTICAL
    }

    private fun scaleTypeFor(mode: String): ImageView.ScaleType = when (mode) {
        "fill" -> ImageView.ScaleType.FIT_XY
        "cover" -> ImageView.ScaleType.CENTER_CROP
        "contain" -> ImageView.ScaleType.FIT_CENTER
        "center" -> ImageView.ScaleType.CENTER
        else -> ImageView.ScaleType.FIT_CENTER
    }
}
