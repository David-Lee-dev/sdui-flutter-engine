import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../log/engine_log.dart';
import '../motion/_base.dart';
import 'presence.dart';

/// Owns the controller and lifecycle that turn a declarative [MotionPlan] into frames.
///
/// A throw from the motion's `plan()` or `frame()` turns this layer off for
/// good: [child] is drawn at rest as if the layer were absent, and the
/// failure is only debug-logged, never reported.
///
/// When the platform asks to reduce motion (`MediaQuery.disableAnimations`)
/// the layer draws its end state (t = 1) without running. A repeating layer
/// isolates [child] in a [RepaintBoundary] unless [repaintBoundary] is false
/// (a sliver child); a one-shot layer adds nothing.
///
/// [phase] (`on:`) places the layer in its nearest presence slot: an `enter`
/// layer runs as above; an `exit` layer rests at its end state and plays
/// backwards (t 1 → 0) when the slot removes its content; `both` does both.
class MotionWrapper extends StatefulWidget {
  const MotionWrapper({
    super.key,
    required this.motion,
    required this.params,
    required this.child,
    this.path,
    this.repaintBoundary = true,
    this.phase = MotionPhase.enter,
  });

  final Motion motion;
  final MotionParams params;
  final Widget child;

  /// Template path of the owning node, for diagnostics.
  final String? path;

  /// Whether a repeating layer may isolate [child]; false for a sliver.
  final bool repaintBoundary;

  /// The presence phases this layer plays in.
  final MotionPhase phase;

  @override
  State<MotionWrapper> createState() => _MotionWrapperState();
}

class _MotionWrapperState extends State<MotionWrapper>
    with SingleTickerProviderStateMixin
    implements PresenceMember {
  late final AnimationController _controller;
  CurvedAnimation? _curved;
  Timer? _delayTimer;
  late MotionPlan _plan;

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

  /// Whether a motion failure turned this layer off; it never turns back on.
  bool _off = false;

  /// Whether reduced motion holds this layer at its end state.
  bool _reduce = false;

  /// Incremented by every run; a repeat leg or pause from an older run stops.
  int _generation = 0;

  /// The run whose repeat legs are being counted, if any.
  int? _legRun;
  int _legIndex = 0;
  bool _legBackwards = false;

  /// Whether [MotionWrapper.child] sits in a [RepaintBoundary], fixed at
  /// mount so the child's subtree is never reparented.
  late final bool _isolate;

  /// The presence slot this layer registered with, if any.
  PresenceHandle? _presence;
  bool _registered = false;

  static const _restPlan = MotionPlan(duration: Duration.zero);

  @override
  void initState() {
    super.initState();
    _plan = _planned() ?? _restPlan;
    _isolate = _plan.repeat && widget.repaintBoundary;
    _controller = AnimationController(vsync: this, duration: _plan.duration)
      ..addStatusListener(_onStatus);
    _curved = CurvedAnimation(parent: _controller, curve: _plan.curve);
    if (widget.phase == MotionPhase.exit) _controller.value = 1;
  }

  /// The motion's plan, or `null` once it failed or cannot run (a repeat
  /// with no duration).
  MotionPlan? _planned() {
    if (_off) return null;
    final MotionPlan plan;
    try {
      plan = widget.motion.plan(widget.params);
    } catch (error) {
      _turnOff('plan failed: ${error.runtimeType}');
      return null;
    }
    if (plan.repeat && plan.duration <= Duration.zero) {
      _turnOff('repeat needs a positive duration');
      return null;
    }
    return plan;
  }

  void _turnOff(String reason) {
    _off = true;
    _delayTimer?.cancel();
    if (_started) _controller.stop();
    EngineLog.widget.stilled(
      this,
      widget.path ?? widget.motion.type,
      '_motion "${widget.motion.type}" $reason',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_registered) {
      _registered = true;
      _presence = PresenceScope.handleOf(context)?..add(this);
    }
    _reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_reduce) {
      _holdEnd();
      return;
    }
    if (widget.phase == MotionPhase.exit) {
      // An exit layer has no entrance: it rests at its end state.
      _gatePassed = true;
      _started = true;
    }
    if (_gatePassed) return;
    _removeListeners();
    _scrollables = _findAncestorScrollables(context);
    _lastPixels.clear();
    _lastScrolling.clear();
    if (_scrollables.isEmpty || _plan.startAtMount) {
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

  /// True when the slot this motion occupies has non-zero overlap with every
  /// ancestor scrollable's viewport. The slot is this widget's own box; when a
  /// motion's first frame collapses that box (a reveal starts at width or
  /// height 0, possibly inside other motions), the slot keeps this widget's
  /// position and takes the size of the first sized box beneath it, so the
  /// frame's own clipping and offsets never decide visibility. A sliver slot
  /// is visible when its viewport lays it out as visible.
  bool _isVisible() {
    final slot = context.findRenderObject();
    if (slot is RenderSliver) return slot.geometry?.visible ?? false;
    final box = slot as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return false;
    final size = box.size.isEmpty ? _contentSize(box) : box.size;
    if (size == null) return false;
    final rect = Offset.zero & size;
    for (final s in _scrollables) {
      final viewport = s.context.findRenderObject() as RenderBox?;
      if (viewport == null || !viewport.attached) return false;
      final transformed = MatrixUtils.transformRect(
        box.getTransformTo(viewport),
        rect,
      );
      final viewportRect = Offset.zero & viewport.size;
      if (!transformed.overlaps(viewportRect)) return false;
    }
    return true;
  }

  /// Size of the first laid-out, non-empty box below [root], depth first.
  static Size? _contentSize(RenderObject root) {
    Size? found;
    void visit(RenderObject child) {
      if (found != null) return;
      if (child is RenderBox && child.hasSize && !child.size.isEmpty) {
        found = child.size;
        return;
      }
      child.visitChildren(visit);
    }

    root.visitChildren(visit);
    return found;
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

  /// Stops any run and shows the end state (reduced motion); the gate no
  /// longer applies.
  void _holdEnd() {
    _gatePassed = true;
    _started = true;
    _removeListeners();
    _delayTimer?.cancel();
    _generation++;
    _controller.stop();
    _controller.value = 1;
  }

  void _run() {
    _delayTimer?.cancel();
    final generation = ++_generation;
    if (_off || _reduce) return;
    void go() {
      if (!mounted) return;
      final plan = _plan;
      if (!plan.repeat) {
        _controller.forward(from: 0);
      } else if (plan.repeatCount == null &&
          plan.repeatDelay <= Duration.zero) {
        _controller.repeat(reverse: plan.reverse);
      } else {
        _legRun = generation;
        _leg(0);
      }
    }

    final delay = _plan.delay + (_presence?.enterDelay ?? Duration.zero);
    if (delay > Duration.zero) {
      _delayTimer = Timer(delay, go);
    } else {
      go();
    }
  }

  /// Runs repeat leg [index], backwards on odd legs when reversing.
  void _leg(int index) {
    _legIndex = index;
    _legBackwards = _plan.reverse && index.isOdd;
    _legBackwards ? _controller.reverse(from: 1) : _controller.forward(from: 0);
  }

  /// Starts the next repeat leg, after `repeatDelay`, when the current one
  /// ends, until `repeatCount` legs ran. Restarting from inside the status
  /// notification keeps the next leg on the same frame.
  void _onStatus(AnimationStatus status) {
    final generation = _generation;
    if (_legRun != generation || _off) return;
    final ended = _legBackwards
        ? status == AnimationStatus.dismissed
        : status == AnimationStatus.completed;
    if (!ended) return;
    final next = _legIndex + 1;
    final count = _plan.repeatCount;
    if (count != null && next >= count) {
      _legRun = null;
      return;
    }
    final pause = _plan.repeatDelay;
    if (pause <= Duration.zero) {
      _leg(next);
      return;
    }
    _delayTimer = Timer(pause, () {
      if (mounted && generation == _generation) _leg(next);
    });
  }

  @override
  void didUpdateWidget(MotionWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    final prev = _plan;
    final next = _planned();
    if (next == null) return;
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
      if (_reduce) {
        _controller.value = next.reverse ? 0 : 1;
      } else {
        next.reverse ? _controller.reverse() : _controller.forward();
      }
    }
  }

  @override
  MotionPhase get phase => widget.phase;

  @override
  bool get affectsLayout => widget.motion.affectsLayout;

  @override
  Duration playExit() {
    if (widget.phase == MotionPhase.enter || _off || _reduce) {
      return Duration.zero;
    }
    _delayTimer?.cancel();
    _generation++;
    _legRun = null;
    final from = _controller.value;
    if (from <= 0) return Duration.zero;
    _controller.reverse(from: from);
    return _plan.duration * from;
  }

  @override
  void cancelExit() {
    if (widget.phase == MotionPhase.enter || _off || _reduce) return;
    _generation++;
    _controller.forward();
  }

  @override
  void dispose() {
    _presence?.remove(this);
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
      child: _isolate ? RepaintBoundary(child: widget.child) : widget.child,
      builder: (context, child) {
        if (_off) return child!;
        try {
          return widget.motion.frame(
            context,
            _curved!.value,
            child!,
            widget.params,
          );
        } catch (error) {
          _turnOff('frame failed: ${error.runtimeType}');
          return child!;
        }
      },
    );
  }
}
