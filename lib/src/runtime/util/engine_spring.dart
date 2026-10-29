import 'package:flutter/physics.dart';

import 'package:sdui_engine/src/ir/model/engine_spring.dart';

/// Resolves a compiled `_morph._spring` into Flutter spring physics.
final class EngineSpring {
  const EngineSpring._();

  /// Longest time one simulation may run before it snaps to its target.
  static const timeout = Duration(seconds: 5);

  /// The [SpringDescription] for [spec].
  static SpringDescription describe(EngineSpringSpec spec) =>
      SpringDescription.withDampingRatio(
        mass: spec.mass,
        stiffness: spec.stiffness,
        ratio: spec.dampingRatio,
      );

  /// A simulation from [from] to [to] that starts with [velocity].
  ///
  /// It settles within a tolerance proportional to the travelled distance and
  /// ends exactly on [to], at the latest after [timeout].
  static Simulation simulate(
    EngineSpringSpec spec, {
    required double from,
    required double to,
    required double velocity,
  }) {
    final scale = (to - from).abs().clamp(1e-3, double.infinity);
    return _SnappingSimulation(
      SpringSimulation(
        describe(spec),
        from,
        to,
        velocity,
        tolerance: Tolerance(distance: scale * 1e-3, velocity: scale * 1e-2),
      ),
      to,
      timeout.inMicroseconds / Duration.microsecondsPerSecond,
    );
  }
}

/// Wraps [inner] so that it reports [end] once it is done or [cap] seconds
/// have passed.
class _SnappingSimulation extends Simulation {
  _SnappingSimulation(this.inner, this.end, this.cap);

  final Simulation inner;
  final double end;
  final double cap;

  @override
  double x(double time) => isDone(time) ? end : inner.x(time);

  @override
  double dx(double time) => isDone(time) ? 0 : inner.dx(time);

  @override
  bool isDone(double time) => time >= cap || inner.isDone(time);
}
