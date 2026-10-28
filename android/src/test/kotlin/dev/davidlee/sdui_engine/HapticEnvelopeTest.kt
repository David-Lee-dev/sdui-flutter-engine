package dev.davidlee.sdui_engine

import org.junit.Assert.assertEquals
import org.junit.Test

class HapticEnvelopeTest {
    private fun linear(
        amplitude: List<ValuePoint>,
        frequency: List<ValuePoint>,
        taps: List<ConfigPoint>,
    ) = buildControlLine(amplitude, frequency, taps, minTransitionDuration = 15L).getLinearPoints()

    private fun assertPoints(expected: List<ControlPoint>, actual: List<ControlPoint>) {
        assertEquals(expected.size, actual.size)
        expected.zip(actual).forEachIndexed { i, (e, a) ->
            assertEquals("intensity[$i]", e.intensity, a.intensity, 1e-5f)
            assertEquals("sharpness[$i]", e.sharpness, a.sharpness, 1e-5f)
            assertEquals("duration[$i]", e.duration, a.duration)
        }
    }

    @Test
    fun `a tap becomes a peak over both curves`() {
        // Peak timing for 15 ms: half 1, slope 13 -> 36, 49, 51, 52 around 50.
        val points = linear(
            amplitude = listOf(ValuePoint(0, 0f), ValuePoint(100, 1f)),
            frequency = listOf(ValuePoint(0, 0.5f), ValuePoint(100, 0.5f)),
            taps = listOf(ConfigPoint(50, 0.8f, 0.9f)),
        )

        assertPoints(
            listOf(
                ControlPoint(0f, 0.5f, 1),
                ControlPoint(0.36f, 0.5f, 36),
                ControlPoint(0.8f, 0.9f, 13),
                ControlPoint(0.8f, 0.9f, 2),
                ControlPoint(0.52f, 0.5f, 1),
                ControlPoint(1f, 0.5f, 48),
            ),
            points,
        )
    }

    @Test
    fun `a tap at the start replaces the curve points under its peak`() {
        // Peak for a tap at 0 spans -14..2; the curves' points at 0 are removed,
        // and the first duration is at least 1 ms.
        val points = linear(
            amplitude = listOf(ValuePoint(0, 0f), ValuePoint(10, 1f)),
            frequency = listOf(ValuePoint(0, 0.5f), ValuePoint(10, 0.5f)),
            taps = listOf(ConfigPoint(0, 1f, 1f)),
        )

        assertPoints(
            listOf(
                ControlPoint(0f, 0f, 1),
                ControlPoint(1f, 1f, 13),
                ControlPoint(1f, 1f, 2),
                ControlPoint(0.2f, 0.5f, 1),
                ControlPoint(1f, 0.5f, 8),
            ),
            points,
        )
    }

    @Test
    fun `curves without taps keep their points and clamp values`() {
        val points = linear(
            amplitude = listOf(ValuePoint(0, 0f), ValuePoint(20, 1.5f), ValuePoint(40, 0f)),
            frequency = listOf(ValuePoint(0, -0.2f), ValuePoint(40, 0.4f)),
            taps = emptyList(),
        )

        assertPoints(
            listOf(
                ControlPoint(0f, 0f, 1),
                ControlPoint(1f, 0.1f, 20),
                ControlPoint(0f, 0.4f, 20),
            ),
            points,
        )
    }
}
