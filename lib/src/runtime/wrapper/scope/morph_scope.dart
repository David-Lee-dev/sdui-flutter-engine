import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../environment/_base.dart';
import '../../environment/map_environment.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import '../../interpreter/expression_evaluator.dart';
import '../../util/engine_curve.dart';
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
  double _start = 0;
  double _target = 0;
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
      _lastTrigger = d.trigger == null
          ? null
          : ExpressionEvaluator.evaluate(d.trigger!, _parent);
      final target =
          _num(ExpressionEvaluator.evaluate(d.to, _parent))?.toDouble() ?? 0;
      final from = d.from == null
          ? target
          : (_num(ExpressionEvaluator.evaluate(d.from!, _parent))?.toDouble() ??
                target);
      _run(from, target, delayed: true);
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
        : ExpressionEvaluator.evaluate(d.trigger!, _parent);
    final triggerFired = d.trigger != null && newTrigger != _lastTrigger;
    final newTarget =
        _num(ExpressionEvaluator.evaluate(d.to, _parent))?.toDouble() ??
        _target;
    if (triggerFired) {
      _lastTrigger = newTrigger;
      final from = d.from == null
          ? _current()
          : (_num(ExpressionEvaluator.evaluate(d.from!, _parent))?.toDouble() ??
                _current());
      _run(from, newTarget);
    } else if (newTarget != _target) {
      _run(_current(), newTarget);
    }
  }

  double _current() => _start + (_target - _start) * _curved.value;

  void _run(double from, double to, {bool delayed = false}) {
    _delayTimer?.cancel();
    _start = from;
    _target = to;
    _controller.reset();
    void go() {
      if (!mounted) return;
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

  static num? _num(Object? v) => v is num && v.isFinite ? v : null;
}

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
  final double Function() valueOf;

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
