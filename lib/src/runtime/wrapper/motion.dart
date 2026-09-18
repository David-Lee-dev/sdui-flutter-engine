import 'dart:async';

import 'package:flutter/widgets.dart';

import '../motion/_base.dart';

/// Owns the controller and lifecycle that turn a declarative [MotionPlan] into frames.
class MotionWrapper extends StatefulWidget {
  const MotionWrapper({
    super.key,
    required this.motion,
    required this.params,
    required this.child,
  });

  final Motion motion;
  final MotionParams params;
  final Widget child;

  @override
  State<MotionWrapper> createState() => _MotionWrapperState();
}

class _MotionWrapperState extends State<MotionWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  CurvedAnimation? _curved;
  Timer? _delayTimer;
  late MotionPlan _plan;

  @override
  void initState() {
    super.initState();
    _plan = widget.motion.plan(widget.params);
    _controller = AnimationController(vsync: this, duration: _plan.duration);
    _curved = CurvedAnimation(parent: _controller, curve: _plan.curve);
    _run();
  }

  void _run() {
    _delayTimer?.cancel();
    void go() {
      if (!mounted) return;
      if (_plan.repeat) {
        _controller.repeat(reverse: _plan.reverse);
      } else {
        _controller.forward(from: 0);
      }
    }

    if (_plan.delay > Duration.zero) {
      _delayTimer = Timer(_plan.delay, go);
    } else {
      go();
    }
  }

  @override
  void didUpdateWidget(MotionWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    final prev = _plan;
    final next = widget.motion.plan(widget.params);
    _plan = next;

    if (next.duration != prev.duration) _controller.duration = next.duration;
    if (next.curve != prev.curve) {
      _curved?.dispose();
      _curved = CurvedAnimation(parent: _controller, curve: next.curve);
    }

    if (next.trigger != prev.trigger) {
      _run();
    } else if (!next.repeat && next.reverse != prev.reverse) {
      next.reverse ? _controller.reverse() : _controller.forward();
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _curved?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved!,
      child: widget.child,
      builder: (context, child) =>
          widget.motion.frame(context, _curved!.value, child!, widget.params),
    );
  }
}
