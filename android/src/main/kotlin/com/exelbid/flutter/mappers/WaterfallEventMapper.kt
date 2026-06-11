package com.exelbid.flutter.mappers

/**
 * Builds the `"waterfall"` payload maps for `onWaterfall` events.
 *
 * Unlike iOS (where the SDK emits a typed `EBWaterfallEvent` we encode), the
 * Android plugin runs the waterfall itself, so these are constructed directly.
 * The shape is byte-for-byte identical to iOS `WaterfallEventMapper` so the Dart
 * `WaterfallEvent.fromMap` sealed class decodes both platforms unchanged.
 */
object WaterfallEventMapper {

    fun fetching(): Map<String, Any?> = mapOf("type" to "fetching")

    fun fetched(networks: List<String>): Map<String, Any?> =
        mapOf("type" to "fetched", "networks" to networks)

    fun trying(network: String, unitId: String, position: Int, total: Int): Map<String, Any?> =
        mapOf(
            "type" to "trying",
            "network" to network,
            "unitId" to unitId,
            "position" to position,
            "total" to total,
        )

    fun won(network: String, position: Int, latencyMs: Long): Map<String, Any?> =
        mapOf(
            "type" to "won",
            "network" to network,
            "position" to position,
            "latencyMs" to latencyMs,
        )

    fun lost(network: String, position: Int, reason: String): Map<String, Any?> =
        mapOf(
            "type" to "lost",
            "network" to network,
            "position" to position,
            "reason" to reason,
        )

    fun noFill(): Map<String, Any?> = mapOf("type" to "noFill")
}
