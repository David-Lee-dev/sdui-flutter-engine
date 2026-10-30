package dev.davidlee.sdui_engine

/**
 * Chooses which Android vibration primitive best approximates an iOS Core
 * Haptics tap at a given `intensity`, since `PRIMITIVE_CLICK` alone (even
 * scaled to 1.0) feels weak next to iOS. Sharpness has no Android
 * counterpart for taps and stays ignored.
 */
internal enum class TapPrimitiveId { TICK, CLICK }

/** What a tap should play, chosen from its `intensity` and device support. */
internal sealed class TapPlan {
    /** A composition primitive at [scale] (0–1). */
    data class Primitive(val id: TapPrimitiveId, val scale: Float) : TapPlan()

    /** The predefined `EFFECT_HEAVY_CLICK`; not scalable. */
    data object PredefinedHeavyClick : TapPlan()

    /** `intensity <= 0`: play nothing. */
    data object Silent : TapPlan()
}

/** Whether the device supports the primitives/effects a [tapPlan] may choose. */
internal data class TapCapabilities(
    val tickSupported: Boolean,
    val heavyClickSupported: Boolean,
)

/*
 * Tiers come from the AOSP haptics HAL targets (source.android.com,
 * "Implement constants and primitives"): `PRIMITIVE_TICK` peaks at 1 G (half a
 * CLICK) and `PRIMITIVE_CLICK` at 2 G; `EFFECT_HEAVY_CLICK` is heavier than
 * CLICK (no published number). Vendors tune their actuators to these targets,
 * so the tiers are derived from them rather than fitted to one device.
 *
 * `intensity` maps linearly to a target peak acceleration that reaches a full
 * CLICK (2 G) at [heavyClickFloor]; each primitive's `scale` is that target
 * divided by the primitive's own peak, assuming scale is linear in amplitude.
 * The result is one straight line from 0 to 2 G with no kink at a tier change.
 */

/** AOSP target peak of `PRIMITIVE_TICK`, in G. */
private const val tickPeakG = 1f

/** AOSP target peak of `PRIMITIVE_CLICK`, in G. */
private const val clickPeakG = 2f

/** From here up, a tap plays `EFFECT_HEAVY_CLICK` — iOS's top quarter is its strongest tap. */
private const val heavyClickFloor = 0.75f

/** Target peak acceleration (G) of a tap at [intensity]. */
private fun targetG(intensity: Float): Float = intensity * (clickPeakG / heavyClickFloor)

/**
 * Picks a tap tier purely from [intensity] and [capabilities], so the
 * decision is unit-testable without a real `Vibrator`. `tap()` turns the
 * result into a [android.os.VibrationEffect].
 */
internal fun tapPlan(
    intensity: Float,
    capabilities: TapCapabilities,
): TapPlan {
    if (intensity <= 0f) return TapPlan.Silent
    if (intensity >= heavyClickFloor) {
        return if (capabilities.heavyClickSupported) {
            TapPlan.PredefinedHeavyClick
        } else {
            TapPlan.Primitive(TapPrimitiveId.CLICK, 1f)
        }
    }

    val g = targetG(intensity)
    val click = TapPlan.Primitive(TapPrimitiveId.CLICK, (g / clickPeakG).coerceIn(0f, 1f))
    if (g >= tickPeakG || !capabilities.tickSupported) return click
    return TapPlan.Primitive(TapPrimitiveId.TICK, (g / tickPeakG).coerceIn(0f, 1f))
}
