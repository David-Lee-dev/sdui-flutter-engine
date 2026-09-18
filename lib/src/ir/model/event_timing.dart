/// How an `_on` event's dispatch is rate-limited.
enum EventTimingMode {
  /// Leading edge: the first event in a window fires immediately; further events
  /// are dropped until the window elapses.
  throttle,

  /// Trailing edge: only the last event fires, after a quiet period — "react to
  /// the last event only".
  debounce,
}

/// Per-event dispatch timing declared as an `_on` option
/// (`{ do: <action>, throttle | debounce: <ms> }`).
class EventTiming {
  const EventTiming.throttle(this.duration) : mode = EventTimingMode.throttle;
  const EventTiming.debounce(this.duration) : mode = EventTimingMode.debounce;

  final EventTimingMode mode;
  final Duration duration;
}
