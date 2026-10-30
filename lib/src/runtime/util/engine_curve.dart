import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/engine_spring.dart';
import 'engine_spring.dart';

/// Resolves a template curve to a Flutter [Curve].
///
/// Names are snake_case (the v3 template convention) and map to the matching
/// [Curves] constant, a Material 3 easing, or a spring preset normalized to
/// 0 -> 1. A `[x1, y1, x2, y2]` list is a cubic bezier. Unknown names and
/// malformed lists fall back to the given default so a bad value degrades to
/// the default motion rather than throwing.
final class EngineCurve {
  const EngineCurve._();

  static const Map<String, Curve> _curves = {
    'linear': Curves.linear,
    'ease': Curves.ease,
    'ease_in': Curves.easeIn,
    'ease_out': Curves.easeOut,
    'ease_in_out': Curves.easeInOut,
    'fast_out_slow_in': Curves.fastOutSlowIn,
    'bounce_out': Curves.bounceOut,
    'elastic_out': Curves.elasticOut,
    'decelerate': Curves.decelerate,
    'emphasized': Curves.easeInOutCubicEmphasized,
    'emphasized_decelerate': Cubic(0.05, 0.7, 0.1, 1),
    'emphasized_accelerate': Cubic(0.3, 0, 0.8, 0.15),
    'standard': Cubic(0.2, 0, 0, 1),
    'standard_decelerate': Cubic(0, 0, 0, 1),
    'standard_accelerate': Cubic(0.3, 0, 1, 1),
  };

  /// Largest magnitude a bezier y control point may take; beyond it the
  /// curve would throw the motion far outside its range.
  static const _maxBezierY = 10.0;

  static final Map<String, _SpringCurve> _springs = {};

  /// The [Curve] for [value], or [fallback] when it is unknown, null or
  /// malformed.
  static Curve resolve(Object? value, {Curve fallback = Curves.linear}) =>
      switch (value) {
        final String name => _curves[name] ?? _spring(name) ?? fallback,
        final List<Object?> list => _bezier(list) ?? fallback,
        _ => fallback,
      };

  /// How long the spring curve [value] takes to settle, or `null` when
  /// [value] is not a spring curve name.
  static Duration? settleDuration(Object? value) =>
      value is String ? _spring(value)?.settle : null;

  static Curve? _bezier(List<Object?> list) {
    if (list.length != 4) return null;
    final values = <double>[];
    for (final v in list) {
      if (v is! num || !v.isFinite) return null;
      values.add(v.toDouble());
    }
    final [x1, y1, x2, y2] = values;
    if (y1.abs() > _maxBezierY || y2.abs() > _maxBezierY) return null;
    return Cubic(x1.clamp(0, 1), y1, x2.clamp(0, 1), y2);
  }

  static _SpringCurve? _spring(String name) {
    final spec = EngineSpringNames.presets[name];
    if (spec == null) return null;
    return _springs[name] ??= _SpringCurve(spec);
  }
}

/// A spring from 0 to 1 at rest, stretched so its settle time maps to t = 1.
final class _SpringCurve extends Curve {
  _SpringCurve(EngineSpringSpec spec)
    : _simulation = SpringSimulation(
        EngineSpring.describe(spec),
        0,
        1,
        0,
        tolerance: const Tolerance(distance: 1e-3, velocity: 1e-2),
      ) {
    settle = _settleOf(_simulation);
  }

  final SpringSimulation _simulation;

  late final Duration settle;

  static const _step = Duration(milliseconds: 1);

  /// The first millisecond at which [simulation] is done, at most
  /// [EngineSpring.timeout].
  static Duration _settleOf(Simulation simulation) {
    var time = _step;
    while (time < EngineSpring.timeout &&
        !simulation.isDone(time.inMicroseconds / 1e6)) {
      time += _step;
    }
    return time;
  }

  @override
  double transformInternal(double t) =>
      _simulation.x(t * settle.inMicroseconds / 1e6);
}
