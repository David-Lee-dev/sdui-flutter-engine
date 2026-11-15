import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:thermion_flutter/thermion_flutter.dart' hide Texture, View;

import 'filament_platform.dart';
import 'model_bytes.dart';
import 'model_glb.dart';

final class ViewerPool with WidgetsBindingObserver {
  ViewerPool({
    required this.platform,
    required this.models,
    required this.frameRate,
    required this.keepAlive,
    required this.prefetch,
    required this.settle,
  });
  final FilamentPlatform platform;
  final ModelBytesCache models;
  final int? frameRate;
  final Duration keepAlive;
  final List<String> prefetch;
  final VoidCallback settle;
  int? warmUpMs;
  final _kept = <ViewerLease>[];
  ViewerLease? _warmViewer;
  final _prefetched = <String, ViewerLease>{};
  Future<void>? _warming;

  /// Applies the renderer rate as soon as each viewer creates its engine.
  Future<ThermionViewer> createViewer() async {
    final viewer = await platform.createViewer();
    platform.setTargetFramerate(frameRate ?? 0);
    return viewer;
  }

  ViewerLease? takeKept(String src) {
    final index = _kept.indexWhere((entry) => entry.src == src);
    if (index < 0) return null;
    final entry = _kept.removeAt(index);
    if (_kept.isEmpty && _warmViewer == null && _prefetched.isEmpty) {
      WidgetsBinding.instance.removeObserver(this);
    }
    entry.expiry?.cancel();
    return entry;
  }

  Future<void> keepOrRelease(ViewerLease entry) async {
    try {
      await entry.viewer.setRendering(false);
    } catch (_) {
      await platform.releaseViewer(entry.viewer);
      rethrow;
    }
    if (keepAlive <= Duration.zero) {
      await platform.releaseViewer(entry.viewer);
      return;
    }
    if (_kept.isEmpty && _warmViewer == null && _prefetched.isEmpty) {
      WidgetsBinding.instance.addObserver(this);
    }
    _kept.add(entry);
    entry.expiry = Timer(keepAlive, () {
      if (_kept.remove(entry)) {
        if (_kept.isEmpty && _warmViewer == null && _prefetched.isEmpty) {
          WidgetsBinding.instance.removeObserver(this);
        }
        unawaited(platform.releaseViewer(entry.viewer));
      }
    });
    if (_kept.length > 2) {
      final oldest = _kept.removeAt(0);
      oldest.expiry?.cancel();
      await platform.releaseViewer(oldest.viewer);
    }
  }

  @override
  void didHaveMemoryPressure() {
    final entries = [..._kept, ?_warmViewer, ..._prefetched.values];
    _prefetched.clear();
    _warmViewer = null;
    _kept.clear();
    WidgetsBinding.instance.removeObserver(this);
    for (final entry in entries) {
      entry.expiry?.cancel();
      unawaited(platform.releaseViewer(entry.viewer));
    }
  }

  Future<ViewerLease?> takeWarm(String src) async {
    try {
      if (_warming != null) await _warming;
    } catch (_) {
      // warmUp reports its error; mounting can still take the cold path.
      return null;
    }
    final prefetched = _prefetched.remove(src);
    if (prefetched != null) {
      if (_kept.isEmpty && _warmViewer == null && _prefetched.isEmpty) {
        WidgetsBinding.instance.removeObserver(this);
      }
      return prefetched;
    }
    final entry = _warmViewer;
    _warmViewer = null;
    if (_kept.isEmpty && _prefetched.isEmpty) {
      WidgetsBinding.instance.removeObserver(this);
    }
    if (entry?.asset != null && entry!.src != src) {
      try {
        await entry.viewer.destroyAsset(entry.asset!);
      } catch (_) {
        await platform.releaseViewer(entry.viewer);
        rethrow;
      }
      entry.asset = null;
      entry.prepared = null;
    }
    return entry;
  }

  Future<void> warmUp() => _warming ??= _warmUp();

  Future<void> _warmUp() async {
    final clock = Stopwatch()..start();
    final srcs = prefetch.toSet().take(math.max(0, models.maxEntries)).toList();
    final loads = {for (final src in srcs) src: models.load(src)};
    for (final load in loads.values) {
      load.ignore();
    }
    final viewer = await createViewer();
    final first = ViewerLease('', viewer);
    final entries = <ViewerLease>[first];
    try {
      await viewer.setRendering(false);
      for (var i = 0; i < srcs.length; i++) {
        final src = srcs[i];
        final entry = i == 0 ? first : ViewerLease(src, await createViewer());
        if (i > 0) entries.add(entry);
        await entry.viewer.setRendering(false);
        entry.src = src;
        entry.prepared = PreparedModelAsset.read(await loads[src]!);
        entry.asset = await entry.viewer.loadGltfFromBuffer(
          entry.prepared!.bytes,
        );
      }
    } catch (_) {
      for (final entry in entries) {
        await platform.releaseViewer(entry.viewer);
      }
      rethrow;
    }
    if (_kept.isEmpty) WidgetsBinding.instance.addObserver(this);
    _warmViewer = first;
    for (final entry in entries.skip(1)) {
      _prefetched[entry.src] = entry;
    }
    settle();
    warmUpMs = clock.elapsedMilliseconds;
    debugPrint('[sdui_model_filament] warm-up took ${warmUpMs}ms');
  }
}

/// A private viewer and its primary asset, transferred only after disposal.
final class ViewerLease {
  ViewerLease(this.src, this.viewer);
  String src;
  final ThermionViewer viewer;
  ThermionAsset? asset;
  PreparedModelAsset? prepared;
  Aabb3? bounds;
  final transforms = <ThermionEntity, Matrix4>{};
  Timer? expiry;
}
