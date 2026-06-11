package com.exelbid.flutter.mediation

import com.onnuridmc.exelbid.lib.ads.mediation.MediationType

/**
 * Network identifier strings — kept identical to iOS so the Dart `WaterfallEvent`
 * / `onWinningNetwork` values match across platforms.
 *
 * iOS emits each adapter's `static networkID`, which equals the lowercase of the
 * `MediationType` name and the mediation server's `id` field:
 * `EXELBID→"exelbid"`, `ADMOB→"admob"`, `FAN→"fan"`, `ADFIT→"adfit"`,
 * `DT→"dt"`, `PANGLE→"pangle"`, `APPLOVIN→"applovin"`, `TNK→"tnk"`.
 *
 * Using `name.lowercase()` keeps this correct for any future `MediationType`
 * value without an exhaustive `when`.
 */
fun MediationType.networkId(): String = name.lowercase()

/** Inverse of [networkId]; null if the id has no matching [MediationType]. */
fun mediationTypeOf(networkId: String): MediationType? =
    try {
        MediationType.valueOf(networkId.uppercase())
    } catch (e: IllegalArgumentException) {
        null
    }
