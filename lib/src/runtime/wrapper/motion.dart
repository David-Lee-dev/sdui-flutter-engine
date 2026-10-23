import 'dart:async';

import 'package:flutter/scheduler.dart';
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

  /// Marks the child so the visibility gate measures its laid-out box rather
  /// than the motion frame around it.
  final _childKey = GlobalKey();

  /// Ancestor scroll positions (nearest first) found on the last dependency
  /// check, each with the listener subscribed to it (for later removal).
  final Map<ScrollPosition, VoidCallback> _positionListeners = {};

  /// Ancestor scrollables (nearest first), kept for visibility checks.
  List<ScrollableState> _scrollables = const [];

  /// Last pixel sample per watched position, used to detect stillness
  /// between frame checks (covers `position.jumpTo` driven movement, which
  /// never sets `isScrollingNotifier`).
  final Map<ScrollPosition, double> _lastPixels = {};

  /// Last `isScrollingNotifier` sample per watched position, so a true→false
  /// transition can be trusted as an immediate settle signal (the driven
  /// activity's final pixel is already correct the moment it goes idle,
  /// without waiting for a second frame to confirm).
  final Map<ScrollPosition, bool> _lastScrolling = {};

  /// Whether a post-frame gate check is already pending, so notifications
  /// that arrive while one is in flight don't schedule duplicates.
  bool _checkScheduled = false;

  /// Whether the initial post-first-layout gate check has been scheduled.
  bool _initialCheckDone = false;

  /// Whether the start gate has been satisfied (or never applied). Once true
  /// it never flips back, per the "don't restart on scroll away/back" rule.
  bool _gatePassed = false;

  /// Whether the motion has actually been started at least once.
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _plan = widget.motion.plan(widget.params);
    _controller = AnimationController(vsync: this, duration: _plan.duration);
    _curved = CurvedAnimation(parent: _controller, curve: _plan.curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_gatePassed) return;
    _removeListeners();
    _scrollables = _findAncestorScrollables(context);
    _lastPixels.clear();
    _lastScrolling.clear();
    if (_scrollables.isEmpty) {
      _passGate();
      return;
    }
    for (final s in _scrollables) {
      final position = s.position;
      void listener() => _scheduleCheck();
      position.addListener(listener);
      position.isScrollingNotifier.addListener(listener);
      _positionListeners[position] = listener;
    }
    if (!_initialCheckDone) {
      _initialCheckDone = true;
      _scheduleCheck();
    }
  }

  /// Walks `Scrollable.maybeOf` upward from each found scrollable's own
  /// context, which sits just outside the `_ScrollableScope` it establishes
  /// for its descendants, so each step lands on the next ancestor scrollable.
  List<ScrollableState> _findAncestorScrollables(BuildContext context) {
    final result = <ScrollableState>[];
    BuildContext? current = context;
    for (var i = 0; i < 20; i++) {
      final scrollable = Scrollable.maybeOf(current!);
      if (scrollable == null) break;
      result.add(scrollable);
      current = scrollable.context;
    }
    return result;
  }

  void _removeListeners() {
    for (final entry in _positionListeners.entries) {
      entry.key.removeListener(entry.value);
      entry.key.isScrollingNotifier.removeListener(entry.value);
    }
    _positionListeners.clear();
  }

  /// Coalesces gate re-checks to at most one pending post-frame callback,
  /// so bursts of scroll notifications don't queue redundant checks.
  void _scheduleCheck() {
    if (_checkScheduled || _gatePassed) return;
    _checkScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      if (!mounted || _gatePassed) return;
      _evaluateGate();
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  void _evaluateGate() {
    var moving = false;
    for (final s in _scrollables) {
      final position = s.position;
      final scrolling = position.isScrollingNotifier.value;
      final wasScrolling = _lastScrolling[position] ?? false;
      _lastScrolling[position] = scrolling;
      if (scrolling) {
        moving = true;
      } else if (!wasScrolling) {
        final last = _lastPixels[position];
        if (last == null || last != position.pixels) moving = true;
      }
      _lastPixels[position] = position.pixels;
    }
    if (moving) {
      // Still settling (or first sample) — check again next frame.
      _scheduleCheck();
      return;
    }
    if (_isVisible()) _passGate();
    // Settled but not visible: stop checking and wait for the next
    // position notification, at zero cost while idle.
  }

  /// True when this widget's render box has non-zero overlap with every
  /// ancestor scrollable's viewport. A motion whose first frame shrinks that
  /// box to nothing (a reveal starts at width 0) is measured by its child
  /// instead, which keeps its laid-out size; otherwise the frame's own box is
  /// used, so a motion that starts its child off-screen still counts by the
  /// slot it lands in.
  bool _isVisible() {
    final own = context.findRenderObject() as RenderBox?;
    final box = own != null && own.hasSize && own.size.isEmpty
        ? _childKey.currentContext?.findRenderObject() as RenderBox?
        : own;
    if (box == null || !box.attached || box.size.isEmpty) return false;
    var rect = Offset.zero & box.size;
    for (final s in _scrollables) {
      final viewport = s.context.findRenderObject() as RenderBox?;
      if (viewport == null || !viewport.attached) return false;
      final transformed = MatrixUtils.transformRect(
        box.getTransformTo(viewport),
        rect,
      );
      final viewportRect = Offset.zero & viewport.size;
      if (!transformed.overlaps(viewportRect)) return false;
      rect = transformed;
    }
    return true;
  }

  void _passGate() {
    _gatePassed = true;
    _removeListeners();
    _lastPixels.clear();
    _lastScrolling.clear();
    if (!_started) {
      _started = true;
      _run();
    }
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
      // A trigger change always restarts immediately, bypassing the gate.
      _started = true;
      _passGate();
      _run();
    } else if (!next.repeat && next.reverse != prev.reverse) {
      next.reverse ? _controller.reverse() : _controller.forward();
    }
  }

  @override
  void dispose() {
    _removeListeners();
    _delayTimer?.cancel();
    _curved?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved!,
      child: KeyedSubtree(key: _childKey, child: widget.child),
      builder: (context, child) =>
          widget.motion.frame(context, _curved!.value, child!, widget.params),
    );
  }
}
