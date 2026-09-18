import 'dart:math';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/dependency/telemetry_sink.dart';

import '../log/engine_log.dart';

/// Process-wide holder for the installed [TelemetrySink].
///
/// Mirrors [ImageSourceRegistry] (`core/runtime/media/image_source_registry.dart`):
/// a static no-op default keeps the engine usable when no sink is installed
/// — most engine tests mount bare and must stay green — and the app installs
/// its real implementation once at boot via `Engine.initialize`, exactly like
/// [ApiClient] or [AppStorage]. Installing the sink itself is app-side
/// wiring, not engine code; this class only holds and forwards to it.
///
/// Every entry point is exception-isolated: a throwing sink must never
/// propagate into engine build/gesture code. Failures are swallowed and, in
/// debug builds, surfaced through [EngineLog] instead of a new logging path.
final class Telemetry {
  const Telemetry._();

  static TelemetrySink _sink = const _NoopTelemetrySink();

  static bool _enabled = true;

  /// Whether observations are currently delivered to the installed sink.
  static bool get enabled => _enabled;

  /// Turns delivery on or off at runtime (e.g. a user privacy opt-out).
  ///
  /// While disabled, [record] drops events and [reserve] hands back no-op
  /// reservations; the installed sink is kept, so re-enabling needs no rewire.
  static void setEnabled(bool value) => _enabled = value;

  static final Random _random = Random.secure();

  /// Installs [sink] as the process-wide telemetry destination.
  static void install(TelemetrySink sink) => _sink = sink;

  /// Restores the no-op default and re-enables delivery. Test-only —
  /// production installs once at boot.
  static void reset() {
    _sink = const _NoopTelemetrySink();
    _enabled = true;
  }

  /// Records [event], building a [TelemetryEvent] from the given fields.
  ///
  /// See [TelemetrySink.record] for the delivery contract. Never throws.
  static void record(
    String event, {
    String? screenId,
    String? screenViewId,
    String? correlationId,
    Map<String, Object?> properties = const {},
  }) {
    if (!_enabled) return;
    try {
      _sink.record(
        TelemetryEvent(
          event: event,
          screenId: screenId,
          screenViewId: screenViewId,
          correlationId: correlationId,
          properties: properties,
        ),
      );
    } catch (error, stack) {
      _reportSinkFailure(error, stack);
    }
  }

  /// Reserves a slot for [event] before the measured operation starts.
  ///
  /// See [TelemetrySink.reserve]. Never throws — a sink failure resolves to a
  /// reservation whose [TelemetryReservation.complete] is a no-op, so callers
  /// do not need a separate failure branch around the reservation itself.
  static Future<TelemetryReservation> reserve(
    String event, {
    String? screenId,
    String? screenViewId,
    String? correlationId,
    Map<String, Object?> properties = const {},
  }) async {
    if (!_enabled) return const _NoopReservation();
    try {
      return await _sink.reserve(
        TelemetryEvent(
          event: event,
          screenId: screenId,
          screenViewId: screenViewId,
          correlationId: correlationId,
          properties: properties,
        ),
      );
    } catch (error, stack) {
      _reportSinkFailure(error, stack);
      return const _NoopReservation();
    }
  }

  /// Generates a random v4 UUID for a new screen visit, action invocation, or
  /// similar per-occurrence identifier (TELEMETRY.md §2).
  ///
  /// Implemented locally with [Random.secure] rather than the `uuid` package:
  /// `uuid` is only a transitive dependency here (pulled in by unrelated
  /// plugins), and this task must not promote it to a declared dependency.
  static String newId() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10xx
    String hex(int start, int end) => bytes
        .sublist(start, end)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
  }

  static void _reportSinkFailure(Object error, StackTrace stack) {
    if (kDebugMode) EngineLog.error(error, stack, tag: 'telemetry');
  }
}

class _NoopTelemetrySink implements TelemetrySink {
  const _NoopTelemetrySink();

  @override
  void record(TelemetryEvent event) {}

  @override
  Future<TelemetryReservation> reserve(TelemetryEvent event) async =>
      const _NoopReservation();
}

class _NoopReservation implements TelemetryReservation {
  const _NoopReservation();

  @override
  void complete({Map<String, Object?> properties = const {}}) {}
}

/// Propagates the active screen visit's identity to descendants.
///
/// Modeled on `TabBranchScope` (`lib/app/routing/main_shell.dart`). Later
/// phases (action/command instrumentation) read [screenId]/[screenViewId]
/// from context instead of threading them through every constructor.
class TelemetryScope extends InheritedWidget {
  const TelemetryScope({
    super.key,
    required this.screenId,
    required this.screenViewId,
    required super.child,
  });

  /// The screen this subtree belongs to.
  final String screenId;

  /// The current visit's identifier — fresh per [screenId] activation.
  final String screenViewId;

  static TelemetryScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TelemetryScope>();

  @override
  bool updateShouldNotify(TelemetryScope oldWidget) =>
      oldWidget.screenId != screenId || oldWidget.screenViewId != screenViewId;
}
