package com.exelbid.flutter.mediation.nativead

import android.view.View
import android.view.ViewGroup

/**
 * Wraps a host view inside a network container (e.g. AdMob `NativeAdView`)
 * without disturbing its position — the container takes the host view's slot in
 * the original parent and the host view becomes the container's child.
 *
 * Mirrors iOS `EBNativeAdContainerReparenter`. The host slot views live in a
 * FrameLayout (margin/LayoutParams based), so transferring layout params is
 * sufficient — no constraint remapping needed.
 */
object NativeContainerReparenter {

    /**
     * Moves every child of [from] into [into] (preserving each child's
     * LayoutParams), then adds [into] back into [from] as a full-bleed child.
     *
     * Used to slip a network container (e.g. AdMob `NativeAdView`, a FrameLayout
     * subclass) between the PlatformView root and the slot views, so the assets
     * become descendants of the network container — **without** reparenting the
     * PlatformView root itself (which Flutter owns).
     */
    fun reparentChildrenInto(from: ViewGroup, into: ViewGroup) {
        val children = ArrayList<View>(from.childCount)
        for (i in 0 until from.childCount) children.add(from.getChildAt(i))
        from.removeAllViews()
        for (c in children) into.addView(c, c.layoutParams)
        from.addView(into, matchParent())
    }

    fun wrap(view: View, container: ViewGroup) {
        val parent = view.parent as? ViewGroup
        if (parent == null) {
            container.addView(view, matchParent())
            return
        }
        val index = parent.indexOfChild(view)
        val lp = view.layoutParams
        parent.removeView(view)
        container.addView(view, matchParent())
        parent.addView(container, index, lp)
    }

    private fun matchParent() = ViewGroup.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.MATCH_PARENT,
    )
}
