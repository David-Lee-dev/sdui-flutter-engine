import 'dart:async';

import 'package:flutter/foundation.dart';

/// Runs the process-wide Filament frame loop only while some view needs
/// frames, so a still model costs nothing.
///
/// Filament renders every vsync while its loop runs, and Flutter composites
/// each of those frames, even when nothing on screen changed. Views [touch]
/// the gate on every change (a camera move, a pose, a load) and [hold] it
/// while a clip plays; the loop pauses [linger] after the last of them. The
/// last rendered frame stays on screen while the loop is paused.
final class RenderGate {
  RenderGate({
    required this.resume,
    required this.pause,
    this.linger = const Duration(milliseconds: 300),
  });

  final VoidCallback resume;
  final VoidCallback pause;

  /// How long frames keep running after a change, so the change reaches the
  /// screen and released render targets (freed a few frames later) go.
  final Duration linger;

  final _holding = <Object>{};
  final _lingering = <Object, Timer>{};
  final _released = Object();

  /// The loop runs once Filament creates its engine.
  bool _running = true;

  bool get running => _running;

  /// [view] changed: runs frames for [linger].
  void touch(Object view) {
    _lingering[view]?.cancel();
    _lingering[view] = Timer(linger, () {
      _lingering.remove(view);
      settle();
    });
    _run();
  }

  /// While [playing], [view] needs every frame; afterwards it lingers.
  void hold(Object view, {required bool playing}) {
    if (playing) {
      _holding.add(view);
      _run();
    } else if (_holding.remove(view)) {
      touch(view);
    }
  }

  /// [view] is gone; frames run for [linger] more to free its resources.
  void release(Object view) {
    _holding.remove(view);
    _lingering.remove(view)?.cancel();
    touch(_released);
  }

  /// Pauses the loop when no view needs frames.
  void settle() {
    if (!_running || _holding.isNotEmpty || _lingering.isNotEmpty) return;
    _running = false;
    pause();
  }

  void _run() {
    if (_running) return;
    _running = true;
    resume();
  }
}
