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
 * Native taps for `sys_haptic` patterns: a support check and one click primitive.
 * Timing and ordering stay on the Dart side.
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

    private fun defaultVibrator(context: Context): Vibrator? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            context.getSystemService(VibratorManager::class.java)?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }
}
