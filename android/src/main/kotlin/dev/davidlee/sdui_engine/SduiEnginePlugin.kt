package dev.davidlee.sdui_engine

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Native haptics for `sys_haptic`: click-primitive taps whose timing stays on
 * the Dart side, and continuous presets played as one basic envelope.
 *
 * There is deliberately no waveform, amplitude, one-shot or timing fallback:
 * a device without envelope effects plays no continuous preset.
 */
class SduiEnginePlugin :
    FlutterPlugin,
    MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var vibrator: Vibrator? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        vibrator = defaultVibrator(binding.applicationContext)
        channel = MethodChannel(binding.binaryMessenger, "sdui_engine/haptic")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "isSupported" -> result.success(supportedVibrator() != null)
            "tap" -> {
                val intensity = call.argument<Double>("intensity") ?: 1.0
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    supportedVibrator()?.let { tap(it, intensity.toFloat()) }
                }
                result.success(null)
            }
            "isContinuousSupported" -> result.success(envelopeVibrator() != null)
            "play" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.BAKLAVA) {
                    envelopeVibrator()?.let {
                        play(
                            it,
                            amplitude = valuePoints(call.argument("intensity")),
                            frequency = valuePoints(call.argument("sharpness")),
                            taps = configPoints(call.argument("taps")),
                        )
                    }
                }
                result.success(null)
            }
            "stop" -> {
                vibrator?.cancel()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        vibrator = null
    }

    /** The vibrator when it can play the click primitive (API 30+), else null. */
    private fun supportedVibrator(): Vibrator? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return null
        val v = vibrator ?: return null
        val canClick = v.hasVibrator() &&
            v.areAllPrimitivesSupported(VibrationEffect.Composition.PRIMITIVE_CLICK)
        return if (canClick) v else null
    }

    @RequiresApi(Build.VERSION_CODES.R)
    private fun tap(vibrator: Vibrator, scale: Float) {
        val effect = VibrationEffect.startComposition()
            .addPrimitive(VibrationEffect.Composition.PRIMITIVE_CLICK, scale.coerceIn(0f, 1f))
            .compose()
        vibrator.vibrate(effect)
    }

    /** The vibrator when it can play envelope effects (API 36+), else null. */
    private fun envelopeVibrator(): Vibrator? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.BAKLAVA) return null
        val v = vibrator ?: return null
        return if (v.hasVibrator() && v.areEnvelopeEffectsSupported()) v else null
    }

    /**
     * Converts the preset to control points as Pulsar does and plays them as a
     * basic envelope; an effect the device rejects plays nothing.
     */
    @RequiresApi(Build.VERSION_CODES.BAKLAVA)
    private fun play(
        vibrator: Vibrator,
        amplitude: List<ValuePoint>,
        frequency: List<ValuePoint>,
        taps: List<ConfigPoint>,
    ) {
        val minDuration = vibrator.envelopeEffectInfo.minControlPointDurationMillis
        val points = buildControlLine(
            amplitude,
            frequency,
            taps,
            minTransitionDuration = if (minDuration > 0) minDuration else 15L,
        ).getLinearPoints()
        if (points.isEmpty()) return

        val effect = try {
            val builder = VibrationEffect.BasicEnvelopeBuilder()
            val initialSharpness = points.first().sharpness
            points.forEach {
                builder
                    .setInitialSharpness(initialSharpness)
                    .addControlPoint(it.intensity, it.sharpness, it.duration)
            }
            builder.build()
        } catch (e: IllegalArgumentException) {
            return
        } catch (e: IllegalStateException) {
            return
        }
        vibrator.vibrate(effect)
    }

    /** Rows of [ms, value]. */
    private fun valuePoints(rows: List<List<Number>>?): List<ValuePoint> =
        rows.orEmpty().filter { it.size >= 2 }.map {
            ValuePoint(time = it[0].toLong(), value = it[1].toFloat())
        }

    /** Rows of [ms, intensity, sharpness]. */
    private fun configPoints(rows: List<List<Number>>?): List<ConfigPoint> =
        rows.orEmpty().filter { it.size >= 3 }.map {
            ConfigPoint(time = it[0].toLong(), amplitude = it[1].toFloat(), frequency = it[2].toFloat())
        }

    private fun defaultVibrator(context: Context): Vibrator? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            context.getSystemService(VibratorManager::class.java)?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }
}
