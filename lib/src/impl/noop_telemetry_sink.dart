import '../contract/telemetry_sink.dart';

/// Default [TelemetrySink] — the bare minimum: observe nothing.
///
/// Events are dropped and reservations complete into the void, so an app that
/// wires no telemetry pays nothing and breaks nothing. Provide your own sink
/// to `Sdui.initialize(telemetry: ...)` to actually collect; toggle delivery
/// at runtime with `Sdui.telemetryEnabled`.
class NoopTelemetrySink implements TelemetrySink {
  const NoopTelemetrySink();

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
