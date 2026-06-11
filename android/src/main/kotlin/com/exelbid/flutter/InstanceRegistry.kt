package com.exelbid.flutter

/**
 * Thread-safe registry holding a strong reference to each live full-screen ad
 * handle (mediated/regular interstitial, video) until Dart disposes it. Mirrors
 * iOS `InstanceRegistry`.
 */
object InstanceRegistry {
    private val handles = HashMap<String, Any>()

    @Synchronized
    fun put(id: String, handle: Any) {
        handles[id] = handle
    }

    @Synchronized
    fun remove(id: String) {
        handles.remove(id)
    }
}
