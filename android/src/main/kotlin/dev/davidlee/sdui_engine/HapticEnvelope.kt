// Ported from Software Mansion Pulsar
// (https://github.com/software-mansion/pulsar, commit
// abdee706282598ab0194ba739dce835dc828f164): types/Points.kt,
// haptics/ValueLineBuilder.kt, PeakLineBuilder.kt, ConfigLineBuilder.kt,
// ControlLineBuilder.kt (getLinearPoints only) and HapticBuilder.buildControlLine.
// Only what the basic envelope path needs is kept.
//
// MIT License
//
// Copyright (c) 2025 Krzysztof Piaskowy
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

package dev.davidlee.sdui_engine

/**
 * @param intensity should be value from [0-1].
 * @param sharpness should be value from [0-1].
 * @param duration transition time in ms.
 */
internal data class ControlPoint(
    val intensity: Float,
    val sharpness: Float,
    val duration: Long,
)

/**
 * @param time transition time in ms.
 * @param value should be value from [0-1].
 */
internal data class ValuePoint(
    val time: Long,
    val value: Float,
)

/**
 * @param time relative time in ms.
 * @param amplitude value from range [0-1].
 * @param frequency value from range [0-1].
 */
internal data class ConfigPoint(
    val time: Long,
    val amplitude: Float,
    val frequency: Float,
)

/**
 * Turns a preset into the control line the envelope consumes: the discrete
 * taps become short peaks merged into both curves.
 */
internal fun buildControlLine(
    amplitude: List<ValuePoint>,
    frequency: List<ValuePoint>,
    taps: List<ConfigPoint>,
    minTransitionDuration: Long,
): ControlLineBuilder {
    val amplitudeLine = ValueLineBuilder(amplitude)
    val frequencyLine = ValueLineBuilder(frequency)

    val peakLineBuilder = PeakLineBuilder(minTransitionDuration)
    val discreteAmplitudeLine = peakLineBuilder.convertToContinuousPatternOfAmplitude(taps, amplitudeLine)
    val discreteFrequencyLine = peakLineBuilder.convertToContinuousPatternOfFrequency(taps, frequencyLine)

    amplitudeLine.mergeLine(discreteAmplitudeLine)
    frequencyLine.mergeLine(discreteFrequencyLine)

    val configLine = ConfigLineBuilder(amplitudeLine, frequencyLine)

    return ControlLineBuilder(configLine)
}

internal class ValueLineBuilder(initialList: List<ValuePoint>? = null) {
    var points = ArrayList<ValuePoint>()

    init {
        initialList?.forEach {
            pushPoint(ValuePoint(it.time, it.value))
        }
    }

    fun pushPoint(point: ValuePoint) {
        if (points.isEmpty() || point.time >= points.last().time) {
            points.add(point)
            return
        }

        val insertIndex = points.indexOfFirst { it.time > point.time }
        points.add(insertIndex, point)
    }

    fun valueForX(x: Long): Float {
        if (points.isEmpty()) return 0f
        if (points.any { it.time == x }) return points.first { it.time == x }.value
        if (points.size == 1) return points[0].value
        if (x <= points.first().time) return 0f
        if (x >= points.last().time) return 0f

        val nextPointIndex = points.indexOfFirst { it.time > x }
        val prevPoint = points[nextPointIndex - 1]
        val nextPoint = points[nextPointIndex]

        val timeDiff = nextPoint.time - prevPoint.time
        val valueDiff = nextPoint.value - prevPoint.value
        val progress = (x - prevPoint.time).toFloat() / timeDiff

        return prevPoint.value + valueDiff * progress
    }

    fun mergeLine(linePattern: ValueLineBuilder) {
        for (i in 0 until linePattern.points.size step 4) {
            val minTime = linePattern.points[i].time
            val maxTime = linePattern.points[i + 3].time

            points.removeAll { point -> point.time in minTime..maxTime }

            pushPoint(linePattern.points[i])
            pushPoint(linePattern.points[i + 1])
            pushPoint(linePattern.points[i + 2])
            pushPoint(linePattern.points[i + 3])
        }
    }
}

internal class PeakLineBuilder(private val minTransitionDuration: Long = 15L) {
    fun convertToContinuousPatternOfAmplitude(
        pattern: List<ConfigPoint>,
        baseline: ValueLineBuilder
    ): ValueLineBuilder {
        return convertToContinuousPattern(pattern, baseline, true)
    }

    fun convertToContinuousPatternOfFrequency(
        pattern: List<ConfigPoint>,
        baseline: ValueLineBuilder
    ): ValueLineBuilder {
        return convertToContinuousPattern(pattern, baseline, false)
    }

    private fun convertToContinuousPattern(
        pattern: List<ConfigPoint>,
        baseline: ValueLineBuilder,
        useAmplitude: Boolean
    ): ValueLineBuilder {
        val line = ValueLineBuilder()
        pattern.forEach {
            val value = if (useAmplitude) { it.amplitude } else { it.frequency }
            val timings = peakTiming(it.time)
            val startPeak = ValuePoint(timings[0], baseline.valueForX(timings[0]))
            val reachMax = ValuePoint(timings[1], value)
            val leaveMax = ValuePoint(timings[2], value)
            val endPeak = ValuePoint(timings[3], baseline.valueForX(timings[3]))
            line.pushPoint(startPeak)
            line.pushPoint(reachMax)
            line.pushPoint(leaveMax)
            line.pushPoint(endPeak)
        }
        return line
    }

    private fun peakTiming(time: Long): List<Long> {
        val halfPeakDuration = (minTransitionDuration * 0.25 / 2).toLong()
        val slopeDuration = minTransitionDuration - 2 * halfPeakDuration
        return listOf(
            time - slopeDuration - halfPeakDuration,
            time - halfPeakDuration,
            time + halfPeakDuration,
            time + halfPeakDuration + 1L,
        )
    }
}

internal class ConfigLineBuilder(amplitudeLine: ValueLineBuilder, frequencyLine: ValueLineBuilder) {
    val points = ArrayList<ConfigPoint>()

    init {
        points.clear()

        val timestamps = (amplitudeLine.points.map { it.time } + frequencyLine.points.map { it.time })
            .toSet()
            .toList()
            .sorted()

        timestamps.forEach { time ->
            val amplitude = amplitudeLine.valueForX(time)
            val frequency = frequencyLine.valueForX(time)
            points.add(ConfigPoint(time = time, amplitude = amplitude, frequency = frequency))
        }
    }
}

internal class ControlLineBuilder(val configLine: ConfigLineBuilder) {
    fun getLinearPoints(): ArrayList<ControlPoint> {
        val points = ArrayList<ControlPoint>()
        for (i in 0..<configLine.points.size) {
            val point = configLine.points[i]
            var duration = maxOf(1L, point.time)
            if (i > 0) {
                duration = point.time - configLine.points[i - 1].time
            }
            points.add(
                ControlPoint(
                    point.amplitude.coerceIn(0f, 1f),
                    point.frequency.coerceIn(0f, 1f),
                    duration,
                )
            )
        }
        return points
    }
}
