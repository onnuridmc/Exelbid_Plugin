package com.exelbid.flutter.mediation.nativead

import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.text.TextUtils
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.res.ResourcesCompat

/**
 * Host rendering surface for a mediated native ad. A transparent [FrameLayout]
 * whose children are slot views (TextView/ImageView) positioned at the exact
 * rects Flutter measured for each slot widget. Implements [NativeAdRendering] so
 * adapters can wire the network SDK's tracking to these views.
 *
 * Slot views get a generated id (via [View.generateViewId]) so ExelBid's
 * `NativeViewBinder` (which maps by view id) can find them inside [container].
 *
 * Rects/styles arrive from Dart in logical pixels (dp); converted to px here.
 */
class SlotNativeRenderingView(context: Context) : FrameLayout(context), NativeAdRendering {

    private val density = resources.displayMetrics.density

    private var titleLabel: TextView? = null
    private var bodyLabel: TextView? = null
    // CTA is a Button (not a plain TextView): AdFit's `setCallToActionButton`
    // is strictly typed to `Button`. `Button` is a `TextView`, so AdMob/FAN
    // (any View) and ExelBid's in-house binder (by id) accept it unchanged.
    private var ctaButton: Button? = null
    private var sponsoredLabel: TextView? = null
    private var displayUrlLabel: TextView? = null
    private var iconImage: ImageView? = null
    private var mediaSlot: FrameLayout? = null
    private var mediaImage: ImageView? = null
    private var logoImage: ImageView? = null
    private var privacyImage: ImageView? = null

    init {
        setBackgroundColor(0x00000000)
    }

    // MARK: - Slot setters (called from the per-view MethodChannel)

    fun setTitleView(args: Map<*, *>) {
        titleLabel = ensureText(titleLabel); place(titleLabel, args)
    }

    fun setDescriptionView(args: Map<*, *>) {
        bodyLabel = ensureText(bodyLabel); place(bodyLabel, args)
    }

    fun setCallToActionView(args: Map<*, *>) {
        ctaButton = ensureButton(ctaButton); place(ctaButton, args)
    }

    fun setSponsoredView(args: Map<*, *>) {
        sponsoredLabel = ensureText(sponsoredLabel, singleLine = true); place(sponsoredLabel, args)
    }

    fun setDisplayUrlView(args: Map<*, *>) {
        displayUrlLabel = ensureText(displayUrlLabel, singleLine = true); place(displayUrlLabel, args)
    }

    fun setIconImageView(args: Map<*, *>) {
        iconImage = ensureImage(iconImage); place(iconImage, args)
    }

    fun setMediaView(args: Map<*, *>) {
        ensureMedia()
        // Box style (bg/cornerRadius) goes on the container; the image-only
        // `contentMode` must reach the inner ImageView (in-house main image).
        place(mediaSlot, args)
        (args["style"] as? Map<*, *>)?.let { s ->
            (s["contentMode"] as? String)?.let { mediaImage?.scaleType = scaleTypeFor(it) }
        }
    }

    fun setLogoImageView(args: Map<*, *>) {
        logoImage = ensureImage(logoImage); place(logoImage, args)
    }

    fun setPrivacyInformationIconImage(args: Map<*, *>) {
        privacyImage = ensureImage(privacyImage); place(privacyImage, args)
    }

    /** True once at least the title or media slot has been positioned. */
    fun hasAnySlot(): Boolean =
        titleLabel != null || mediaSlot != null || bodyLabel != null

    // MARK: - NativeAdRendering

    override val container: ViewGroup get() = this
    override fun titleView() = titleLabel
    override fun bodyView() = bodyLabel
    override fun callToActionView() = ctaButton
    override fun callToActionButton() = ctaButton
    override fun sponsoredView() = sponsoredLabel
    override fun displayUrlView() = displayUrlLabel
    override fun iconView() = iconImage
    override fun logoView() = logoImage
    override fun privacyView() = privacyImage
    override fun mediaContainer(): ViewGroup? = mediaSlot
    override fun mainImageView() = mediaImage

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

    /**
     * Creates the CTA [Button] once, stripped of the platform button chrome
     * (background, all-caps, elevation, min size, padding) so it renders like the
     * other text slots — the host draws the visible CTA and the style map from
     * Dart supplies any background/corner. Kept a [Button] only so AdFit's
     * `setCallToActionButton(Button)` can register it; the explicit width/height
     * from [place] overrides the default button min size.
     */
    private fun ensureButton(existing: Button?): Button {
        if (existing != null) return existing
        return Button(context).also {
            it.id = View.generateViewId()
            it.includeFontPadding = false
            it.maxLines = 1
            it.setAllCaps(false)
            it.background = null
            it.stateListAnimator = null
            it.minWidth = 0
            it.minHeight = 0
            it.minimumWidth = 0
            it.minimumHeight = 0
            it.setPadding(0, 0, 0, 0)
            it.gravity = Gravity.CENTER
            addView(it)
        }
    }

    private fun ensureImage(existing: ImageView?): ImageView {
        if (existing != null) return existing
        return ImageView(context).also {
            it.id = View.generateViewId()
            it.scaleType = ImageView.ScaleType.FIT_CENTER
            it.adjustViewBounds = false
            addView(it)
        }
    }

    /**
     * Creates the media slot once: a [FrameLayout] container holding a full-bleed
     * inner [ImageView]. The container is the single home for the main creative
     * ([mediaContainer]); the inner image backs ExelBid's in-house
     * `mainImageId` ([mainImageView]) for static images.
     */
    private fun ensureMedia() {
        if (mediaSlot != null) return
        val container = FrameLayout(context).also {
            it.id = View.generateViewId()
            addView(it)
        }
        val image = ImageView(context).also {
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
        mediaSlot = container
        mediaImage = image
    }

    private fun place(view: View?, args: Map<*, *>) {
        view ?: return
        val x = px(args["x"])
        val y = px(args["y"])
        val w = px(args["width"])
        val h = px(args["height"])
        val lp = FrameLayout.LayoutParams(w, h, Gravity.TOP or Gravity.START)
        lp.leftMargin = x
        lp.topMargin = y
        view.layoutParams = lp
        (args["style"] as? Map<*, *>)?.let { applyStyle(view, it) }
    }

    private fun applyStyle(view: View, s: Map<*, *>) {
        // Box styling (any slot).
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
            (s["fontSize"] as? Number)?.let {
                view.setTextSize(TypedValue.COMPLEX_UNIT_DIP, it.toFloat())
            }
            // 커스텀 폰트(res/font) + weight 적용. fontFamily가 해석되면 그
            // typeface를, 아니면 기존 typeface를 베이스로 bold/normal만 토글한다.
            val family = (s["fontFamily"] as? String)?.takeIf { it.isNotEmpty() }?.let { fontFor(it) }
            val weight = (s["fontWeight"] as? Number)?.toInt()
            if (family != null || weight != null) {
                val style = if ((weight ?: 400) >= 600) android.graphics.Typeface.BOLD else android.graphics.Typeface.NORMAL
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

    // MARK: - Helpers

    private fun px(value: Any?): Int {
        val v = (value as? Number)?.toDouble() ?: 0.0
        return (v * density).toInt()
    }

    /**
     * Resolves a host-app font by resource name (a `res/font/<name>.xml` family
     * or a single font file) to a [android.graphics.Typeface]. Returns null when
     * the name isn't a registered font resource, so the caller falls back to the
     * default typeface (the "unregistered font → system font" contract).
     */
    private fun fontFor(family: String): android.graphics.Typeface? {
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
        "left" -> Gravity.START or Gravity.CENTER_VERTICAL
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
