import CoreHaptics
import Flutter
import UIKit

/// Native haptics for `sys_haptic`: transient taps whose timing stays on the
/// Dart side, and continuous presets played as one Core Haptics pattern.
public class SduiEnginePlugin: NSObject, FlutterPlugin {
  /// Core Haptics may reject longer parameter curves, so they are split.
  private static let maxCurvePoints = 16

  private var engine: CHHapticEngine?
  private var running = false
  private var continuousPlayer: CHHapticPatternPlayer?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "sdui_engine/haptic", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(SduiEnginePlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported", "isContinuousSupported":
      result(CHHapticEngine.capabilitiesForHardware().supportsHaptics)
    case "tap":
      let args = call.arguments as? [String: Any]
      let intensity = (args?["intensity"] as? Double) ?? 1.0
      let sharpness = (args?["sharpness"] as? Double) ?? 0.5
      tap(intensity: Float(intensity), sharpness: Float(sharpness))
      result(nil)
    case "play":
      let args = call.arguments as? [String: Any]
      play(
        taps: Self.rows(args?["taps"]),
        intensity: Self.rows(args?["intensity"]),
        sharpness: Self.rows(args?["sharpness"]))
      result(nil)
    case "stop":
      stop()
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

  /// One continuous event at full intensity / zero sharpness shaped by the
  /// intensity and sharpness control curves, plus a transient per tap — the
  /// same composition as Pulsar. Best effort like [tap].
  ///
  /// - Parameters:
  ///   - taps: rows of [ms from start, intensity, sharpness]
  ///   - intensity: rows of [ms from start, value]
  ///   - sharpness: rows of [ms from start, value]
  private func play(taps: [[Double]], intensity: [[Double]], sharpness: [[Double]]) {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

    let intensityPoints = Self.controlPoints(intensity)
    let sharpnessPoints = Self.controlPoints(sharpness)
    let duration = (intensityPoints + sharpnessPoints).map(\.relativeTime).max() ?? 0

    var events: [CHHapticEvent] = []
    if !intensityPoints.isEmpty {
      events.append(
        CHHapticEvent(
          eventType: .hapticContinuous,
          parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.0),
          ],
          relativeTime: 0,
          duration: duration))
    }
    for row in taps where row.count >= 3 {
      events.append(
        CHHapticEvent(
          eventType: .hapticTransient,
          parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: Self.unit(row[1])),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: Self.unit(row[2])),
          ],
          relativeTime: row[0] / 1000.0))
    }
    guard !events.isEmpty else { return }

    let curves =
      Self.curves(.hapticIntensityControl, intensityPoints)
      + Self.curves(.hapticSharpnessControl, sharpnessPoints)

    do {
      let pattern = try CHHapticPattern(events: events, parameterCurves: curves)
      let player = try startedEngine().makePlayer(with: pattern)
      try? continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
      continuousPlayer = player
      try player.start(atTime: CHHapticTimeImmediate)
    } catch {
      running = false
    }
  }

  private func stop() {
    try? continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
    continuousPlayer = nil
  }

  /// Seconds and clamped values; a curve starting after 0 gets its first value
  /// at 0, as in Pulsar's CurveLineModifier.
  private static func controlPoints(_ rows: [[Double]]) -> [CHHapticParameterCurve.ControlPoint] {
    var points: [CHHapticParameterCurve.ControlPoint] = []
    for row in rows where row.count >= 2 {
      let time = row[0] / 1000.0
      let value = unit(row[1])
      if points.isEmpty && time > 0 {
        points.append(.init(relativeTime: 0, value: value))
      }
      points.append(.init(relativeTime: time, value: value))
    }
    return points
  }

  /// Consecutive curves of at most [maxCurvePoints] points, each starting at
  /// its first point's time with point times relative to that start. Each
  /// curve begins with the previous one's last point so no segment is lost.
  private static func curves(
    _ parameter: CHHapticDynamicParameter.ID,
    _ points: [CHHapticParameterCurve.ControlPoint]
  ) -> [CHHapticParameterCurve] {
    guard !points.isEmpty else { return [] }

    var curves: [CHHapticParameterCurve] = []
    var start = 0
    repeat {
      let end = min(start + maxCurvePoints, points.count)
      let origin = points[start].relativeTime
      curves.append(
        CHHapticParameterCurve(
          parameterID: parameter,
          controlPoints: points[start..<end].map {
            .init(relativeTime: $0.relativeTime - origin, value: $0.value)
          },
          relativeTime: origin))
      start = end - 1
    } while start < points.count - 1
    return curves
  }

  private static func rows(_ value: Any?) -> [[Double]] {
    guard let list = value as? [Any] else { return [] }
    return list.compactMap { row in
      (row as? [Any])?.compactMap { ($0 as? NSNumber)?.doubleValue }
    }
  }

  private static func unit(_ value: Double) -> Float { Float(min(max(value, 0), 1)) }

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
