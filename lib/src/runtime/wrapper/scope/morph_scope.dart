import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../environment/_base.dart';
import '../../environment/map_environment.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import '../../interpreter/expression_evaluator.dart';
import '../../log/engine_log.dart';
import '../../util/engine_curve.dart';
import '../../util/engine_spring.dart';
import 'scope.dart';

/// Exposes an animated numeric value as a reactive environment entry.
class MorphScope extends StatefulWidget {
  const MorphScope({super.key, required this.directive, required this.child});

  final MorphDirective directive;
  final Widget child;

  @override
  State<MorphScope> createState() => _MorphScopeState();
}

class _MorphScopeState extends State<MorphScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;

  /// Both `null` until `_to` or `_from` yields a finite number.
  double? _start;
  double? _target;
  Environment _parent = MapEnvironment.empty;
  Listenable? _dep;
  Object? _lastTrigger;
  bool _started = false;
  Timer? _delayTimer;

  MorphDirective get d => widget.directive;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: d.durationMs),
    );
    _curved = CurvedAnimation(
      parent: _controller,
      curve: EngineCurve.resolve(d.curve, fallback: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebind(Scope.envOf(context) ?? MapEnvironment.empty);
    if (!_started) {
      _started = true;
      _lastTrigger = d.trigger == null ? null : _read(d.trigger!);
      final from = _from();
      final target = _eval(d.to) ?? from;
      _run(from ?? target, target, delayed: true);
    }
  }

  void _rebind(Environment env) {
    _parent = env;
    _dep?.removeListener(_onDep);
    _dep = env.listen({...d.to.roots, ...?d.trigger?.roots});
    _dep?.addListener(_onDep);
  }

  void _onDep() {
    final newTrigger = d.trigger == null
        ? null
        : _read(d.trigger!, _lastTrigger);
    final triggerFired = d.trigger != null && newTrigger != _lastTrigger;
    final newTarget = _eval(d.to) ?? _target;
    if (triggerFired) {
      _lastTrigger = newTrigger;
      _run(_from() ?? _current(), newTarget);
    } else if (newTarget != _target) {
      _run(_current() ?? newTarget, newTarget);
    }
  }

  /// The value now: `null` until a finite target was ever seen.
  double? _current() {
    final start = _start;
    final target = _target;
    if (start == null || target == null) return target;
    return start + (target - start) * _curved.value;
  }

  double? _from() => d.from == null ? null : _eval(d.from!);

  double? _eval(Expression expression) => _finite(_read(expression));

  Object? _read(Expression expression, [Object? orElse]) =>
      _readSafely(this, d, expression, _parent, orElse);

  void _run(double? from, double? to, {bool delayed = false}) {
    _delayTimer?.cancel();
    _start = from;
    _target = to;
    _controller.reset();
    void go() {
      if (!mounted || to == null) return;
      if (d.repeat) {
        _controller.repeat(reverse: d.reverse);
      } else {
        _controller.forward();
      }
    }

    if (delayed && d.delayMs > 0) {
      _delayTimer = Timer(Duration(milliseconds: d.delayMs), go);
    } else {
      go();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _dep?.removeListener(_onDep);
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final env = _MorphEnvironment(
      parent: _parent,
      name: d.as,
      animation: _curved,
      valueOf: _current,
    );
    return Scope.provideEnv(env: env, child: widget.child);
  }
}

/// Exposes a spring-driven numeric value as a reactive environment entry.
///
/// A target change starts a new simulation from the current value, carrying
/// the current velocity unless the spring is an effect spring. Reduced motion
/// jumps straight to the target.
class SpringMorphScope extends StatefulWidget {
  const SpringMorphScope({
    super.key,
    required this.directive,
    required this.child,
  });

  final MorphDirective directive;
  final Widget child;

  @override
  State<SpringMorphScope> createState() => _SpringMorphScopeState();
}

class _SpringMorphScopeState extends State<SpringMorphScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// `null` until `_to` or `_from` yields a finite number.
  double? _target;
  Environment _parent = MapEnvironment.empty;
  Listenable? _dep;
  Object? _lastTrigger;
  bool _started = false;
  bool _reduceMotion = false;
  Timer? _delayTimer;

  /// Incremented on every retarget and on dispose; a delayed start belonging
  /// to an older generation is dropped.
  int _generation = 0;

  MorphDirective get d => widget.directive;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations == true;
    _rebind(Scope.envOf(context) ?? MapEnvironment.empty);
    if (!_started) {
      _started = true;
      _lastTrigger = d.trigger == null ? null : _read(d.trigger!);
      final from = _from();
      final target = _eval(d.to) ?? from;
      if (target != null) {
        _run(from ?? target, target, velocity: 0, delayed: true);
      }
    }
  }

  void _rebind(Environment env) {
    _parent = env;
    _dep?.removeListener(_onDep);
    _dep = env.listen({...d.to.roots, ...?d.trigger?.roots});
    _dep?.addListener(_onDep);
  }

  void _onDep() {
    final newTrigger = d.trigger == null
        ? null
        : _read(d.trigger!, _lastTrigger);
    final triggerFired = d.trigger != null && newTrigger != _lastTrigger;
    if (triggerFired) _lastTrigger = newTrigger;
    final newTarget = _eval(d.to) ?? _target;
    if (newTarget == null) return;
    final current = _target == null ? newTarget : _controller.value;
    if (triggerFired) {
      final from = _from();
      _run(
        from ?? current,
        newTarget,
        velocity: from == null ? _handoffVelocity() : 0,
      );
    } else if (newTarget != _target) {
      _run(current, newTarget, velocity: _handoffVelocity());
    }
  }

  double _handoffVelocity() =>
      d.spring!.carriesVelocity && _controller.isAnimating
      ? _controller.velocity
      : 0;

  double? _from() => d.from == null ? null : _eval(d.from!);

  double? _eval(Expression expression) => _finite(_read(expression));

  Object? _read(Expression expression, [Object? orElse]) =>
      _readSafely(this, d, expression, _parent, orElse);

  void _run(
    double from,
    double to, {
    required double velocity,
    bool delayed = false,
  }) {
    _delayTimer?.cancel();
    final generation = ++_generation;
    _target = to;
    if (_reduceMotion) {
      _controller.value = to;
      return;
    }
    _controller.value = from;
    void go() {
      if (!mounted || generation != _generation) return;
      _controller.animateWith(
        EngineSpring.simulate(
          d.spring!,
          from: from,
          to: to,
          velocity: velocity,
        ),
      );
    }

    if (delayed && d.delayMs > 0) {
      _delayTimer = Timer(Duration(milliseconds: d.delayMs), go);
    } else {
      go();
    }
  }

  @override
  void dispose() {
    _generation++;
    _delayTimer?.cancel();
    _dep?.removeListener(_onDep);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final env = _MorphEnvironment(
      parent: _parent,
      name: d.as,
      animation: _controller,
      valueOf: () => _target == null ? null : _controller.value,
    );
    return Scope.provideEnv(env: env, child: widget.child);
  }
}

/// Evaluates a morph [expression] in [env]. Any failure reads as [orElse]
/// and is logged once for [owner], so a morph never takes its subtree down.
Object? _readSafely(
  Object owner,
  MorphDirective directive,
  Expression expression,
  Environment env,
  Object? orElse,
) {
  try {
    return ExpressionEvaluator.evaluate(expression, env);
  } catch (error) {
    EngineLog.widget.stilled(
      owner,
      directive.path,
      '_morph expression failed: ${error.runtimeType}',
    );
    return orElse;
  }
}

double? _finite(Object? v) => v is num && v.isFinite ? v.toDouble() : null;

class _MorphEnvironment extends Environment {
  _MorphEnvironment({
    required this.parent,
    required this.name,
    required this.animation,
    required this.valueOf,
  });

  @override
  final Environment? parent;
  final String name;
  final Animation<double> animation;
  final double? Function() valueOf;

  @override
  bool has(String n) => n == name;

  @override
  Object? read(String n) => n == name ? valueOf() : null;

  @override
  Listenable? listen(Set<String> keys) {
    if (!keys.contains(name)) return parent?.listen(keys);
    final rest = parent?.listen(keys.difference({name}));
    return rest == null ? animation : Listenable.merge([animation, rest]);
  }
}
