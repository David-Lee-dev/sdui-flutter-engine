import 'dart:async';

import 'package:sdui_engine/src/ir/model/event_timing.dart';

/// Applies per-event [EventTiming] (throttle / debounce) to action dispatch.
///
/// One controller per interaction wrapper instance; keyed by event name so
/// different events on the same node time independently. Dispose to cancel any
/// pending timers.
class EventTimingController {
  final Map<String, Timer> _timers = {};

  /// Runs [fire] for [event] subject to [timing] (null → fire immediately).
  ///
  /// - throttle: fires now unless a window is open, then opens one (leading).
  /// - debounce: cancels any pending fire and schedules this one; only the last
  ///   survives the quiet period (trailing).
  void run(String event, EventTiming? timing, void Function() fire) {
    if (timing == null) {
      fire();
      return;
    }
    switch (timing.mode) {
      case EventTimingMode.throttle:
        if (_timers[event]?.isActive ?? false) return; // within window → drop
        fire();
        _timers[event] = Timer(timing.duration, () => _timers.remove(event));
      case EventTimingMode.debounce:
        _timers[event]?.cancel();
        _timers[event] = Timer(timing.duration, () {
          _timers.remove(event);
          fire();
        });
    }
  }

  /// Cancels all pending timers.
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}
