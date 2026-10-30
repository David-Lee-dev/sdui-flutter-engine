package dev.davidlee.sdui_engine

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class HapticTapTest {
    private val fullSupport = TapCapabilities(tickSupported = true, heavyClickSupported = true)
    private val noTick = TapCapabilities(tickSupported = false, heavyClickSupported = true)
    private val noHeavyClick = TapCapabilities(tickSupported = true, heavyClickSupported = false)

    // Target G = intensity * 2 / 0.75; TICK peaks at 1 G, CLICK at 2 G (AOSP).
    private fun primitive(plan: TapPlan): TapPlan.Primitive {
        assertTrue("expected a primitive, got $plan", plan is TapPlan.Primitive)
        return plan as TapPlan.Primitive
    }

    private fun assertPrimitive(id: TapPrimitiveId, scale: Float, plan: TapPlan) {
        val p = primitive(plan)
        assertEquals(id, p.id)
        assertEquals(scale, p.scale, 1e-5f)
    }

    @Test
    fun `intensity 0 or below is silent`() {
        assertEquals(TapPlan.Silent, tapPlan(0f, fullSupport))
        assertEquals(TapPlan.Silent, tapPlan(-0.5f, fullSupport))
    }

    @Test
    fun `soft taps play TICK scaled to a 1 G peak`() {
        assertPrimitive(TapPrimitiveId.TICK, 0.2f * 2f / 0.75f, tapPlan(0.2f, fullSupport))
        assertPrimitive(TapPrimitiveId.TICK, 0.374f * 2f / 0.75f, tapPlan(0.374f, fullSupport))
    }

    @Test
    fun `from 1 G the tap plays CLICK at half scale with no jump`() {
        assertPrimitive(TapPrimitiveId.CLICK, 0.5f, tapPlan(0.375f, fullSupport))
    }

    @Test
    fun `just under the heavy-click floor plays CLICK near full scale`() {
        assertPrimitive(TapPrimitiveId.CLICK, 0.749f * 2f / 0.75f / 2f, tapPlan(0.749f, fullSupport))
    }

    @Test
    fun `from the heavy-click floor the tap plays the predefined effect`() {
        assertEquals(TapPlan.PredefinedHeavyClick, tapPlan(0.75f, fullSupport))
        assertEquals(TapPlan.PredefinedHeavyClick, tapPlan(1f, fullSupport))
    }

    @Test
    fun `without TICK support soft taps play CLICK at the same target`() {
        assertPrimitive(TapPrimitiveId.CLICK, 0.2f * 2f / 0.75f / 2f, tapPlan(0.2f, noTick))
    }

    @Test
    fun `without HEAVY_CLICK support the top tier plays full-scale CLICK`() {
        assertPrimitive(TapPrimitiveId.CLICK, 1f, tapPlan(0.9f, noHeavyClick))
    }
}
