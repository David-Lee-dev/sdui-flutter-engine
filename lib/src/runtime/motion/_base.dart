import 'package:flutter/widgets.dart';

import '../util/engine_curve.dart';
import '../util/props_resolver.dart';

/// Reads typed motion options while replacing malformed dynamic input with safe defaults.
///
/// Numbers beyond ±[limit] count as malformed: finite but huge values would
/// overflow the frame's transformed bounds during layout or paint.
class MotionParams {
  const MotionParams(this._raw);

  final Map<String, Object?> _raw;

  /// Largest magnitude a numeric option (and a duration in ms) may take.
  static const limit = 1e6;

  static bool _sane(Object? v) => v is num && v.isFinite && v.abs() <= limit;

  /// Returns a finite numeric option within ±[limit] or [fallback].
  num number(String key, num fallback) {
    final v = _raw[key];
    return _sane(v) ? v as num : fallback;
  }

  /// Returns a millisecond option in [0, [limit]] or [fallback].
  Duration duration(String key, Duration fallback) {
    final v = _raw[key];
    return _sane(v) && (v as num) >= 0
        ? Duration(milliseconds: v.round())
        : fallback;
  }

  /// Resolves a curve name or `[x1, y1, x2, y2]` bezier, using [fallback]
  /// for unsupported input.
  Curve curve(String key, Curve fallback) =>
      EngineCurve.resolve(_raw[key], fallback: fallback);

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

  /// Returns a two-number offset within ±[limit] or [fallback].
  Offset offset(String key, Offset fallback) {
    final v = _raw[key];
    if (v is List && v.length == 2 && _sane(v[0]) && _sane(v[1])) {
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
    this.repeatCount,
    this.reverse = false,
    this.repeatDelay = Duration.zero,
    this.trigger,
    this.startAtMount = false,
  });

  final Duration duration;

  final Curve curve;

  final Duration delay;

  final bool repeat;

  /// How many legs a [repeat] runs before stopping at its end; `null`
  /// repeats until disposal.
  final int? repeatCount;

  final bool reverse;

  /// Pause between two repeated legs.
  final Duration repeatDelay;

  final Object? trigger;

  /// When true (`start: "mount"`), the motion skips the scroll-aware start
  /// gate and starts (counting [delay]) as soon as its layer mounts, exactly
  /// as if it had no ancestor `Scrollable`.
  final bool startAtMount;

  /// Builds the common one-shot or repeating plan options from [p].
  ///
  /// A spring curve name without a `duration` runs for its settle time.
  /// `repeat` is `true` (forever) or a leg count in 1..1000; anything else
  /// takes [repeat].
  factory MotionPlan.from(
    MotionParams p, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
    bool repeat = false,
  }) {
    final (:repeats, :count) = _repeatOf(p.raw('repeat'), repeat);
    return MotionPlan(
      duration: p.duration(
        'duration',
        EngineCurve.settleDuration(p.raw('curve')) ?? duration,
      ),
      curve: p.curve('curve', curve),
      delay: p.duration('delay', Duration.zero),
      repeat: repeats,
      repeatCount: count,
      reverse: p.flag('reverse', fallback: false),
      repeatDelay: p.duration('repeat_delay', Duration.zero),
      trigger: p.raw('trigger'),
      startAtMount: p.text('start') == 'mount',
    );
  }

  static const _maxRepeatCount = 1000;

  static ({bool repeats, int? count}) _repeatOf(Object? raw, bool fallback) =>
      switch (raw) {
        final bool flag => (repeats: flag, count: null),
        final num n
            when n.isFinite &&
                n == n.roundToDouble() &&
                n >= 1 &&
                n <= _maxRepeatCount =>
          (repeats: true, count: n.toInt()),
        _ => (repeats: fallback, count: null),
      };
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
