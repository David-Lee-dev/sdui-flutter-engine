import CoreHaptics
import Flutter
import UIKit

/// Native taps for `sys_haptic` patterns: a support check and one transient event.
/// Timing and ordering stay on the Dart side.
public class SduiEnginePlugin: NSObject, FlutterPlugin {
  private var engine: CHHapticEngine?
  private var running = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "sdui_engine/haptic", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(SduiEnginePlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
      result(CHHapticEngine.capabilitiesForHardware().supportsHaptics)
    case "tap":
      let args = call.arguments as? [String: Any]
      let intensity = (args?["intensity"] as? Double) ?? 1.0
      let sharpness = (args?["sharpness"] as? Double) ?? 0.5
      tap(intensity: Float(intensity), sharpness: Float(sharpness))
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Best effort, like platform feedback: a failed tap is dropped and the
  /// engine restarts on the next one.
  private func tap(intensity: Float, sharpness: Float) {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

    do {
      let event = CHHapticEvent(
        eventType: .hapticTransient,
        parameters: [
          CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
          CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
        ],
        relativeTime: 0)
      let pattern = try CHHapticPattern(events: [event], parameters: [])
      try startedEngine().makePlayer(with: pattern).start(atTime: CHHapticTimeImmediate)
    } catch {
      running = false
    }
  }

  private func startedEngine() throws -> CHHapticEngine {
    if let engine, running { return engine }

    let engine = try self.engine ?? makeEngine()
    try engine.start()
    self.engine = engine
    running = true
    return engine
  }

  private func makeEngine() throws -> CHHapticEngine {
    let engine = try CHHapticEngine()
    engine.playsHapticsOnly = true
    engine.resetHandler = { [weak self] in
      DispatchQueue.main.async { self?.running = false }
    }
    engine.stoppedHandler = { [weak self] _ in
      DispatchQueue.main.async { self?.running = false }
    }
    return engine
  }
}
