package com.exelbid.flutter.mediation.adapter

/**
 * Adapter → orchestrator callbacks for one load attempt.
 *
 * Mirrors the iOS adapter contract: the adapter only reports success/failure and
 * ad interactions; the orchestrator owns waterfall fallback, timeout, and
 * eventing. Exactly one of [onLoaded] / [onFailed] must be called per load.
 */
interface MediationAdCallback {
    /** Load succeeded. Banner: the view is now available via `adapter.view()`. */
    fun onLoaded()

    /** Load failed — orchestrator advances to the next network. */
    fun onFailed(reason: String)

    fun onClicked() {}
    fun onLeaveApp() {}
    fun onClickFinish() {}

    // Native impression lifecycle (best-effort; not all networks report 50/100).
    fun onImpression() {}
    fun onImpression50() {}
    fun onImpression100() {}

    // Full-screen (interstitial/video) presentation lifecycle.
    fun onWillAppear() {}
    fun onDidAppear() {}
    fun onWillDisappear() {}
    fun onDidDisappear() {}
}
