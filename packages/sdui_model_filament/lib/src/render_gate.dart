import 'dart:async';

import 'package:flutter/foundation.dart';

/// Renders a view only while it changes or plays, and runs the process-wide
/// Filament frame loop only while some view renders, so a still model costs
/// nothing.
///
/// Filament renders every attached view on every frame its loop runs, even
/// views whose picture did not change. Views [touch] the gate on every change
/// (a camera move, a pose, a load) and [hold] it while a clip plays; [render]
/// adds a view to the frames for [linger] after its last change and then
/// leaves it out, so one moving model never redraws a still one. The loop
/// pauses once no view renders. A view left out keeps its last frame on
/// screen.
final class RenderGate {
  RenderGate({
    required this.resume,
    required this.pause,
    this.render = _ignore,
    this.linger = const Duration(milliseconds: 300),
  });

  final VoidCallback resume;
  final VoidCallback pause;

  /// Adds [view] to the frames the loop renders, or leaves it out.
  final void Function(Object view, bool rendering) render;

  /// How long a view keeps rendering after a change, so the change reaches
  /// the screen and released render targets (freed a few frames later) go.
  final Duration linger;

  final _views = <Object>{};
  final _rendering = <Object>{};
  final _holding = <Object>{};
  final _lingering = <Object, Timer>{};
  final _released = Object();

  /// The loop runs once Filament creates its engine.
  bool _running = true;

  bool get running => _running;

  /// [view] changed: renders it for [linger].
  void touch(Object view) {
    _views.add(view);
    _linger(view);
  }

  /// While [playing], [view] renders every frame; afterwards it lingers.
  void hold(Object view, {required bool playing}) {
    if (playing) {
      _views.add(view);
      _holding.add(view);
      _start(view);
    } else if (_holding.remove(view)) {
      touch(view);
    }
  }

  /// [view] is gone; the remaining views render for [linger] more so its
  /// resources are freed.
  void release(Object view) {
    _views.remove(view);
    _holding.remove(view);
    _lingering.remove(view)?.cancel();
    _rendering.remove(view);
    wake();
  }

  /// Renders every view for [linger], e.g. after the platform recreated
  /// their surfaces.
  void wake() {
    for (final view in [..._views]) {
      _linger(view);
    }
    _linger(_released);
  }

  /// Pauses the loop when no view renders.
  void settle() {
    if (!_running || _holding.isNotEmpty || _lingering.isNotEmpty) return;
    _running = false;
    pause();
  }

  void _linger(Object view) {
    _lingering[view]?.cancel();
    _lingering[view] = Timer(linger, () {
      _lingering.remove(view);
      _stop(view);
    });
    _start(view);
  }

  void _start(Object view) {
    if (view != _released && _rendering.add(view)) render(view, true);
    if (_running) return;
    _running = true;
    resume();
  }

  void _stop(Object view) {
    if (!_holding.contains(view) &&
        !_lingering.containsKey(view) &&
        _rendering.remove(view)) {
      render(view, false);
    }
    settle();
  }

  static void _ignore(Object view, bool rendering) {}
}
