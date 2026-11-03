import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../util/props_resolver.dart';

/// The `progress` prop of a `model_3d`: one clip held at a playhead the
/// template sets, e.g. a tap counter stepping through a long animation.
@immutable
final class Model3dProgress {
  const Model3dProgress({
    required this.clip,
    this.at,
    this.value,
    this.speed = 1,
  });

  final String clip;

  /// Target in seconds into the clip; wins over [value].
  final double? at;

  /// Target as a fraction of the clip, 0 to 1.
  final double? value;

  /// Clip seconds played per second while the playhead moves toward the
  /// target, in either direction; 0 jumps.
  final double speed;

  /// Parses `progress`; null without a `clip`.
  static Model3dProgress? parse(Object? raw) {
    if (raw is! Map) return null;
    final clip = PropsResolver.text(raw['clip']);
    if (clip == null || clip.isEmpty) return null;
    final speed = PropsResolver.number(raw['speed']);
    return Model3dProgress(
      clip: clip,
      at: PropsResolver.number(raw['at']),
      value: PropsResolver.number(raw['value']),
      speed: speed == null || !speed.isFinite || speed < 0 ? 1 : speed,
    );
  }

  /// The target in seconds for a clip [duration] seconds long.
  double target(double duration) {
    final at = this.at;
    final value = this.value;
    final seconds = at ?? (value == null ? 0 : value * duration);
    return seconds.isFinite ? seconds.clamp(0, duration).toDouble() : 0;
  }

  /// Whether the target is the clip's end, judged without the clip: only a
  /// [value] of 1 or more is known to be the end.
  bool get endsWithoutClip => at == null && (value ?? 0) >= 1;

  @override
  bool operator ==(Object other) =>
      other is Model3dProgress &&
      other.clip == clip &&
      other.at == at &&
      other.value == value &&
      other.speed == speed;

  @override
  int get hashCode => Object.hash(clip, at, value, speed);
}

/// Moves a `progress` clip's playhead toward the template's target at the
/// clip's own pace and hands each pose to the renderer.
///
/// The playhead shows the first target of a loaded clip at once, so a model
/// that mounts mid-way (the server sent `taps: 3`) appears there without
/// replaying. Later targets play toward from wherever the playhead is, so a
/// target that moves on mid-way (fast taps) continues without a jump.
final class Model3dPlayhead {
  Model3dPlayhead({
    required TickerProvider vsync,
    required this.onPose,
    required this.onEnd,
    required this.onArrive,
  }) {
    _ticker = vsync.createTicker(_tick);
  }

  /// Receives the clip and time to show; called once per moved frame.
  final void Function(String clip, Duration time) onPose;

  /// Fires when the playhead arrives at the clip's end by moving there.
  final VoidCallback onEnd;

  /// Fires when the playhead settles at a [retarget]ed target: after
  /// playing there, at once for speed 0 or a target it already holds. A
  /// target replaced mid-way never arrives; only the last one does.
  final VoidCallback onArrive;

  late final Ticker _ticker;
  Duration _last = Duration.zero;

  Model3dProgress? _progress;

  /// Clip length in seconds; null while no clip is attached.
  double? _duration;
  double _position = 0;
  double _target = 0;
  (String, double)? _sent;

  /// Whether a loaded clip is attached.
  bool get attached => _duration != null;

  /// Seconds into the clip the playhead shows.
  double get position => _position;

  /// Attaches [progress]'s loaded clip of [duration] and shows its target at
  /// once; with [endIfThere], a target at the clip's end fires [onEnd]. A
  /// null [duration] (no such clip) detaches.
  void attach(
    Model3dProgress progress,
    Duration? duration, {
    bool endIfThere = false,
  }) {
    _ticker.stop();
    _progress = progress;
    _sent = null;
    if (duration == null) {
      _duration = null;
      return;
    }
    final seconds = duration.inMicroseconds / Duration.microsecondsPerSecond;
    _duration = seconds;
    _target = progress.target(seconds);
    _position = _target;
    _emit();
    if (endIfThere && _atEnd) onEnd();
  }

  void detach() {
    _ticker.stop();
    _progress = null;
    _duration = null;
    _sent = null;
  }

  /// Moves toward [progress]'s target on the attached clip.
  void retarget(Model3dProgress progress) {
    _progress = progress;
    final duration = _duration;
    if (duration == null) return;
    final target = progress.target(duration);
    if (target == _target && target == _position) {
      onArrive();
      return;
    }
    _target = target;
    if (progress.speed == 0) {
      _arrive();
      return;
    }
    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  bool get _atEnd {
    final duration = _duration;
    return duration != null && _position >= duration;
  }

  void _tick(Duration elapsed) {
    final dt =
        (elapsed - _last).inMicroseconds / Duration.microsecondsPerSecond;
    _last = elapsed;
    final progress = _progress;
    if (dt <= 0 || progress == null) return;
    final step = progress.speed * dt;
    final gap = _target - _position;
    if (gap.abs() <= step) {
      _arrive();
      return;
    }
    _position += step * gap.sign;
    _emit();
  }

  void _arrive() {
    _ticker.stop();
    final moved = _position != _target;
    _position = _target;
    _emit();
    if (moved && _atEnd) onEnd();
    onArrive();
  }

  void _emit() {
    final clip = _progress?.clip;
    if (clip == null) return;
    final pose = (clip, _position);
    if (pose == _sent) return;
    _sent = pose;
    onPose(
      clip,
      Duration(
        microseconds: math.max(
          0,
          (_position * Duration.microsecondsPerSecond).round(),
        ),
      ),
    );
  }

  void dispose() => _ticker.dispose();
}
