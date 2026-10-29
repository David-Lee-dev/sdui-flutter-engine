import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../log/engine_log.dart';

/// Process-wide cache of the engine's fragment programs.
///
/// Programs load once, off the first frame, and stay cached. A program that
/// cannot load leaves its feature on the Path fallback.
final class ShaderRegistry {
  const ShaderRegistry._();

  /// The program's asset key in an app that depends on the engine, then in
  /// the engine package itself (its own tests and examples).
  static const _sdfShapesAssets = [
    'packages/sdui_engine/shaders/sdf_shapes.frag',
    'shaders/sdf_shapes.frag',
  ];

  static final _sdfShapes = ValueNotifier<ui.FragmentProgram?>(null);
  static Future<void>? _loading;

  /// Bumped by [reset] so a load still in flight cannot land afterwards.
  static int _generation = 0;

  /// The `shape` smooth-union program, `null` until [warmUp] has loaded it or
  /// when it is unavailable. Listeners hear when it arrives.
  static ValueListenable<ui.FragmentProgram?> get sdfShapes => _sdfShapes;

  /// Whether [sdfShapes] is loaded.
  static bool get available => _sdfShapes.value != null;

  /// Starts loading the programs once; later calls return the same future,
  /// which never completes with an error.
  static Future<void> warmUp() => _loading ??= _load();

  static Future<void> _load() async {
    final generation = _generation;
    for (final asset in _sdfShapesAssets) {
      try {
        final program = await ui.FragmentProgram.fromAsset(asset);
        if (generation == _generation) _sdfShapes.value = program;
        return;
      } catch (_) {
        // Try the next key; the miss is reported once below.
      }
    }
    EngineLog.warn(
      'shape: shaders/sdf_shapes.frag could not be loaded; '
      'shapes paint with the hard Path union.',
      tag: 'widget',
    );
  }

  /// Drops the cache for test isolation.
  static void reset() {
    _generation++;
    _sdfShapes.value = null;
    _loading = null;
  }
}
