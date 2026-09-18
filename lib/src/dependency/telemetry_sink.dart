/// Receives user-activity observations produced by the engine and the app shell.
///
/// The engine only *observes*; it owns none of the delivery concerns. Identity
/// (`session_id`, `install_id`, `seq`), ordering, durability, batching, auth and
/// transport all belong to the app-side implementation, which is injected at boot
/// exactly like [ApiClient] and [AppStorage]. Keeping that split is what lets
/// `lib/core/**` stay free of app packages.
///
/// See `_docs/engine-v3/TELEMETRY.md` for the event taxonomy and the identity model.
library;

/// One observation, before the sink stamps it with session identity and ordering.
///
/// [screenViewId] ties every event of one screen visit together; the app issues it
/// per activation and the engine merely carries it. [correlationId] ties a user
/// action to the commands and server rows it caused — it is the value sent as the
/// `x-event-id` header.
class TelemetryEvent {
  const TelemetryEvent({
    required this.event,
    this.screenId,
    this.screenViewId,
    this.correlationId,
    this.properties = const {},
  });

  /// The event name from the taxonomy — `screen_view`, `command`, and so on.
  ///
  /// The server derives `category` from this name and rejects unknown names, so
  /// it must match the taxonomy exactly.
  final String event;

  /// The screen this observation belongs to, or `null` outside any screen.
  final String? screenId;

  /// The screen-visit this observation belongs to.
  final String? screenViewId;

  /// The action invocation that caused this observation, when there was one.
  final String? correlationId;

  /// Event-specific fields. Values must already be free of user-entered text —
  /// masking is the caller's responsibility, not the sink's.
  final Map<String, Object?> properties;
}

/// A sequence slot reserved before an operation runs, completed after it ends.
///
/// Reservation exists because commands within one action batch run concurrently:
/// numbering them on completion would record them out of their true start order,
/// and numbering them in memory would leave no durable trace if the app dies
/// mid-flight. See TELEMETRY.md §4.
abstract class TelemetryReservation {
  /// Completes the reserved event, merging [properties] into what was reserved.
  ///
  /// Safe to call at most once; later calls are ignored rather than throwing,
  /// because callers run inside driver error handling where a throw would be
  /// mistaken for a driver failure.
  void complete({Map<String, Object?> properties});
}

/// Accepts observations and takes over responsibility for delivering them.
abstract class TelemetrySink {
  /// Records [event].
  ///
  /// Called from build and gesture paths, so it must return immediately and must
  /// never throw — a telemetry fault may not surface as a UI fault. Implementations
  /// swallow and count their own failures.
  void record(TelemetryEvent event);

  /// Reserves a slot for [event] and returns once the reservation is durable.
  ///
  /// Callers await this *before* starting the operation being measured, then call
  /// [TelemetryReservation.complete] with the outcome. A caller that dies in
  /// between leaves a reserved-but-incomplete record, which is the signal that the
  /// operation never finished.
  Future<TelemetryReservation> reserve(TelemetryEvent event);
}
