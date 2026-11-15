import 'dart:async';

import 'package:flutter/scheduler.dart';

/// Schedules model motion at the renderer rate without requesting Flutter
/// frames, or preserves vsync timing when no positive rate is supplied.
final class Model3dFrameClock {
  Model3dFrameClock({
    required TickerProvider vsync,
    required int? rate,
    required void Function(Duration elapsed) onTick,
  }) : _onTick = onTick,
       _period = rate == null || rate <= 0
           ? null
           : Duration(
               microseconds: (Duration.microsecondsPerSecond / rate).round(),
             ) {
    if (_period == null) _ticker = vsync.createTicker(onTick);
  }

  final void Function(Duration elapsed) _onTick;
  final Duration? _period;
  Ticker? _ticker;
  Timer? _timer;
  bool _started = false;
  bool _muted = false;

  bool get isActive => _ticker?.isActive ?? _started;

  void start() {
    if (isActive) return;
    final ticker = _ticker;
    if (ticker != null) {
      ticker.start();
      return;
    }
    _started = true;
    _startTimer();
  }

  void _startTimer() {
    if (_muted || !_started) return;
    final period = _period!;
    _timer = Timer.periodic(period, (timer) => _onTick(period * timer.tick));
  }

  void stop() {
    _ticker?.stop();
    _started = false;
    _timer?.cancel();
    _timer = null;
  }

  set muted(bool value) {
    if (_muted == value) return;
    _muted = value;
    final ticker = _ticker;
    if (ticker != null) {
      ticker.muted = value;
    } else if (value) {
      _timer?.cancel();
      _timer = null;
    } else {
      _startTimer();
    }
  }

  void dispose() {
    stop();
    _ticker?.dispose();
  }
}
