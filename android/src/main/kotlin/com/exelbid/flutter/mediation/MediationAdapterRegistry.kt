package com.exelbid.flutter.mediation

import com.exelbid.flutter.mediation.adapter.MediationAdapter

/**
 * Process-wide registry mapping (networkId, format) → adapter factory.
 *
 * Mirrors iOS `EBMediationRegistry` / `ExelBidMediationKit.register(modules:)`.
 * Built-in adapters self-register at plugin attach; the registry's keys also
 * drive the `useList` passed to `ExelBid.getMediationData` (only registered
 * networks are requested from the server).
 */
object MediationAdapterRegistry {

    fun interface AdapterFactory {
        fun create(): MediationAdapter
    }

    private val factories = HashMap<Pair<String, AdFormat>, AdapterFactory>()

    @Synchronized
    fun register(networkId: String, format: AdFormat, factory: AdapterFactory) {
        factories[networkId to format] = factory
    }

    @Synchronized
    fun create(networkId: String, format: AdFormat): MediationAdapter? =
        factories[networkId to format]?.create()

    /** networkIds registered for [format] — used to build the waterfall useList. */
    @Synchronized
    fun registeredNetworks(format: AdFormat): List<String> =
        factories.keys.filter { it.second == format }.map { it.first }
}
