import 'package:flutter/widgets.dart';

import '../util/engine_curve.dart';
import '../util/props_resolver.dart';

/// Reads typed motion options while replacing malformed dynamic input with safe defaults.
class MotionParams {
  const MotionParams(this._raw);

  final Map<String, Object?> _raw;

  /// Returns a finite numeric option or [fallback].
  num number(String key, num fallback) {
    final v = _raw[key];
    return v is num && v.isFinite ? v : fallback;
  }

  /// Returns a non-negative millisecond option or [fallback].
  Duration duration(String key, Duration fallback) {
    final v = _raw[key];
    return v is num && v.isFinite && v >= 0
        ? Duration(milliseconds: v.round())
        : fallback;
  }

  /// Resolves a named curve, using [fallback] for unsupported input.
  Curve curve(String key, Curve fallback) =>
      EngineCurve.resolve(text(key), fallback: fallback);

  /// Returns a boolean option or [fallback].
  bool flag(String key, {required bool fallback}) {
    final v = _raw[key];
    return v is bool ? v : fallback;
  }

  /// Returns a string option, or `null` when its value has another type.
  String? text(String key) {
    final v = _raw[key];
    return v is String ? v : null;
  }

  /// Resolves a color option or returns [fallback].
  Color color(String key, Color fallback) =>
      PropsResolver.color(_raw[key]) ?? fallback;

  /// Resolves a nine-direction alignment option or returns [fallback].
  Alignment alignment(String key, Alignment fallback) =>
      PropsResolver.alignment(_raw[key]) ?? fallback;

  /// Returns an option without coercion.
  Object? raw(String key) => _raw[key];

  /// Returns a finite two-number offset or [fallback].
  Offset offset(String key, Offset fallback) {
    final v = _raw[key];
    if (v is List &&
        v.length == 2 &&
        v[0] is num &&
        v[1] is num &&
        (v[0] as num).isFinite &&
        (v[1] as num).isFinite) {
      return Offset((v[0] as num).toDouble(), (v[1] as num).toDouble());
    }
    return fallback;
  }
}

/// Describes how a [MotionWrapper] schedules and advances a motion.
class MotionPlan {
  const MotionPlan({
    required this.duration,
    this.curve = Curves.linear,
    this.delay = Duration.zero,
    this.repeat = false,
    this.reverse = false,
    this.repeatDelay = Duration.zero,
    this.trigger,
  });

  final Duration duration;

  final Curve curve;

  final Duration delay;

  final bool repeat;

  final bool reverse;

  final Duration repeatDelay;

  final Object? trigger;

  /// Builds the common one-shot or repeating plan options from [p].
  factory MotionPlan.from(
    MotionParams p, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) => MotionPlan(
    duration: p.duration('duration', duration),
    curve: p.curve('curve', curve),
    delay: p.duration('delay', Duration.zero),
    repeat: p.flag('repeat', fallback: false),
    reverse: p.flag('reverse', fallback: false),
    trigger: p.raw('trigger'),
  );
}

/// Defines a stateless visual transform driven by normalized animation progress.
abstract class Motion {
  const Motion();

  /// Returns the template-facing name of this motion atom.
  String get type;

  /// Builds the scheduling plan for [params].
  MotionPlan plan(MotionParams params);

  /// Wraps [child] with the visual state represented by progress [t].
  Widget frame(
    BuildContext context,
    double t,
    Widget child,
    MotionParams params,
  );
}
