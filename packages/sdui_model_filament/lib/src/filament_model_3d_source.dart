import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:sdui_engine/sdui_engine.dart';
import 'package:thermion_flutter/thermion_flutter.dart' hide Texture, View;

import 'filament_platform.dart';
import 'load_stats.dart';
import 'model_bytes.dart';
import 'model_disk_cache.dart';
import 'model_framing.dart';
import 'model_glb.dart';
import 'model_look.dart';
import 'model_motion.dart';
import 'model_outfit.dart';
import 'model_scene.dart';
import 'native_lane.dart';
import 'render_gate.dart';
import 'viewer_pool.dart';

/// A [Model3dSource] that renders each `model_3d` natively with Filament (through
/// `thermion_flutter`) into a Flutter `Texture`.
///
/// ```dart
/// Sdui.initialize(
///   model3dSource: FilamentModel3dSource(
///     client: gateway.httpClient,       // the app's gateway client
///     baseUrl: Uri.parse(apiUrl),       // the gateway origin for `/assets/...`
///     prefetch: ['/assets/character.glb'],
///   ),
///   ...
/// );
/// ```
///
/// The view is an ordinary Flutter widget: it clips, transforms and fades
/// with its parent. The engine owns gestures and auto-rotation and orbits
/// the camera through [FilamentModel3dController.setCamera].
/// [warmUp] creates the Filament engine ahead of the first mount. Frames
/// render only while some model changes or plays ([RenderGate]).
///
/// Models are fetched through `client`, the app's gateway client, and only
/// from `baseUrl`'s origin, so they take the same pinned, authenticated route
/// as the app's other requests; there is no default client.
///
/// Fetched models persist in the app's cache directory ([ModelDiskCache]),
/// so a model seen once opens without the network on later launches;
/// `diskCache: false` keeps them in memory only.
///
/// [debugOverlay] (default: `--dart-define=SDUI_MODEL_DEBUG=true`) paints each
/// view's load timeline, app memory and frame times over it for measurement.
final class FilamentModel3dSource extends Model3dSource {
  FilamentModel3dSource({
    required http.Client client,
    required Uri baseUrl,
    this.prefetch = const [],
    this.loadTimeout = const Duration(seconds: 30),
    this.iblIntensity = 30000,
    this.frameRate = 60,
    this.keepAlive = const Duration(seconds: 10),
    AssetBundle? bundle,
    int cachedModels = 4,
    bool diskCache = true,
    this.debugOverlay = const bool.fromEnvironment('SDUI_MODEL_DEBUG'),
    @visibleForTesting this._platform = const FilamentPlatform(),
  }) : _models = ModelBytesCache(
         baseUrl: baseUrl,
         client: client,
         bundle: bundle,
         maxEntries: cachedModels,
         disk: diskCache ? ModelDiskCache() : null,
       );

  /// Models parsed ahead during [warmUp], bounded by cachedModels.
  final List<String> prefetch;

  /// How long a model may take to load before the widget falls back to its
  /// poster.
  final Duration loadTimeout;

  /// Brightness of the bundled studio image-based light.
  final double iblIntensity;

  /// Renderer frames per second, also used for engine camera and progress
  /// motion. Null uses the display rate.
  @override
  final int? frameRate;

  /// Paints [ModelDebugOverlay] over every view.
  final bool debugOverlay;

  /// How long disposed viewers remain reusable; zero releases immediately.
  final Duration keepAlive;

  final FilamentPlatform _platform;
  final ModelBytesCache _models;

  late final _pool = ViewerPool(
    platform: _platform,
    models: _models,
    frameRate: frameRate,
    keepAlive: keepAlive,
    prefetch: prefetch,
    settle: _gate.settle,
  );

  @override
  Future<void> warmUp() => _pool.warmUp();

  /// Filament's neutral studio environment (`lightroom_ibl.ktx`, Apache-2.0).
  static const iblAsset = studioIblAsset;

  int _mounts = 0;

  /// Renders only the models that change or play, and pauses Filament's
  /// frame loop while every model is still. Surfaces the platform recreated
  /// while the app was hidden get a frame on resume.
  late final RenderGate _gate = () {
    AppLifecycleListener(onResume: () => _gate.wake());
    return RenderGate(
      resume: _platform.resumeFrames,
      pause: _platform.pauseFrames,
      render: (view, rendering) =>
          (view as FilamentModel3dController)._setRendering(rendering),
    );
  }();

  @override
  Future<SduiModel3dController> controllerFor(Model3dRequest request) async =>
      FilamentModel3dController(request, this);

  ModelLoadStats _statsFor(String src) =>
      ModelLoadStats(src: src, mount: ++_mounts, warmUpMs: _pool.warmUpMs);
}

/// Drives one Filament viewer for the engine's `model_3d` widget.
///
/// Native calls on the viewer run one after another ([_native]), so
/// [dispose] releases or keeps the viewer after the call in flight; no later
/// call reaches it. Each [play] takes a run number that a later play, stop,
/// pose of the playing clip or dispose moves on, so a superseded play's late
/// work never changes [playback].
final class FilamentModel3dController
    implements
        SduiModel3dController,
        Model3dLookController,
        Model3dSceneController,
        Model3dOutfitController,
        Model3dMotionController,
        Model3dTapController {
  FilamentModel3dController(this._request, this._source)
    : stats = _source._statsFor(_request.src);

  final Model3dRequest _request;
  final FilamentModel3dSource _source;

  /// This view's load timeline, also painted when
  /// [FilamentModel3dSource.debugOverlay] is on.
  @visibleForTesting
  final ModelLoadStats stats;

  /// Set once the viewer exists, so the view allocates its texture while the
  /// model is still loading.
  final _viewer = ValueNotifier<ThermionViewer?>(null);
  final _hits = <ThermionEntity, Model3dHit>{};
  double _devicePixelRatio = 1;
  final _picks = <Completer<ThermionEntity?>>{};
  @override
  Future<Model3dHit?> hitTest(Offset localPosition) async {
    final viewer = _viewer.value;
    if (_disposed ||
        viewer == null ||
        _asset == null ||
        !localPosition.dx.isFinite ||
        !localPosition.dy.isFinite) {
      return null;
    }
    final result = Completer<ThermionEntity?>();
    _picks.add(result);
    _syncRenderingHold();
    try {
      // Only submission uses the lane. Waiting there for the callback would
      // prevent the render work that produces the pick two or three frames later.
      _quietly(
        _native(() async {
          if (result.isCompleted) return;
          try {
            await viewer.view.pick(
              (localPosition.dx * _devicePixelRatio).round(),
              (localPosition.dy * _devicePixelRatio).round(),
              (hit) {
                if (!result.isCompleted) result.complete(hit.entity);
              },
            );
          } catch (error, stack) {
            if (!result.isCompleted) result.completeError(error, stack);
          }
        }),
      );
      final entity = await result.future.timeout(
        const Duration(milliseconds: 150),
        onTimeout: () => null,
      );
      final hit = _disposed ? null : _hits[entity];
      return _disposed ? null : hit;
    } on NativeDisposed {
      return null;
    } finally {
      if (!result.isCompleted) result.complete(null);
      _picks.remove(result);
      _syncRenderingHold();
    }
  }

  Future<void>? _loading;
  ThermionAsset? _asset;
  ViewerLease? _primary;
  bool _ready = false;
  final _nativeLane = NativeLane();
  bool get _disposed => _nativeLane.disposed;
  Widget? _view;

  final _sceneClock = Stopwatch()..start();
  int? _lastSceneFrame;
  Future<void> _hookLane = Future.value();
  bool _hookRegistered = false;

  /// Every producer shares this hold decision; stopping primary playback must
  /// never pause an extra clip or spin.
  void _syncRenderingHold() {
    if (_disposed || _viewer.value == null) return;
    _source._gate.hold(
      this,
      playing:
          _motion.playingFrames ||
          _motion.motionFrames ||
          _outfit.needsFrames ||
          _picks.isNotEmpty ||
          _scene.spinning ||
          _scene.playingFrames,
    );
    _syncFrameHook();
  }

  void _syncFrameHook() {
    // Thermion waits for running hooks during registration. Never await this
    // operation on the native lane: a running hook may itself need that lane.
    final next = _hookLane.then((_) async {
      final viewer = _viewer.value;
      if (viewer == null || _disposed) return;
      final needed =
          _ready &&
          (_outfit.needsFrames ||
              _scene.spinning ||
              _motion.motionFrames ||
              (_motion.playingFrames && _framing.tracksNode));
      if (needed == _hookRegistered) return;
      final app = _source._platform.appFor(viewer);
      _lastSceneFrame = null;
      if (needed) {
        await app.registerRequestFrameHook(_onSceneFrame);
      } else {
        await app.unregisterRequestFrameHook(_onSceneFrame);
      }
      _hookRegistered = needed;
    });
    _hookLane = next.then((_) {}, onError: (_) {});
    _quietly(next);
  }

  Future<void> _onSceneFrame() async {
    if (_disposed) return;
    final now = _sceneClock.elapsedMicroseconds;
    final last = _lastSceneFrame;
    _lastSceneFrame = now;
    final dt = last == null
        ? 0.0
        : (now - last) / Duration.microsecondsPerSecond;
    try {
      var posed = false;
      await _native(() async {
        posed = await _motion.frame(_sceneClock.elapsed);
        await _outfit.advanceOutfit(_sceneClock.elapsed);
        if (_scene.spinning) await _scene.frame(dt);
      });
      if ((posed || _motion.playing != null) && _framing.tracksNode) {
        await _framing.place();
      }
      _motion.settleFrame();
    } on NativeDisposed {
      return;
    }
  }

  @override
  Future<void> initialize() =>
      (_loading ??= _load()).timeout(_source.loadTimeout);

  Future<void> _load() async {
    try {
      final src = _request.src;
      final kept =
          _source._pool.takeKept(src) ?? await _source._pool.takeWarm(src);
      final reused = kept?.transforms.isNotEmpty ?? false;
      final cached = kept?.prepared != null || _source._models.contains(src);
      final bytesStarted = stats.elapsedMs;
      final bytes =
          (kept?.prepared == null
                  ? _source._models.load(src)
                  : Future.value(kept!.prepared!.bytes))
              .then((data) {
                _ifAlive(
                  () => stats.served(
                    bytes: data.length,
                    cached: cached,
                    ms: stats.elapsedMs - bytesStarted,
                  ),
                );
                return data;
              });
      // Observe both failures immediately, even if native loading ends early.
      final boundsFuture = kept?.bounds != null
          ? Future.value((kept!.bounds, null, null))
          : bytes.then(_framing.computeBounds);
      unawaited(boundsFuture.then((_) {}, onError: (_) {}));

      final viewer = kept?.viewer ?? await _source._pool.createViewer();
      if (_disposed) {
        await _source._platform.releaseViewer(viewer);
        return;
      }
      _primary = kept ?? ViewerLease(src, viewer);
      _primary!.src = src;
      _viewer.value = viewer;
      stats.mark('viewer');

      if (!reused) await _native(_look.resetDefaults);

      final data = await bytes;
      final prepared = _primary!.prepared ?? PreparedModelAsset.read(data);
      final asset =
          _primary!.asset ??
          await _native<ThermionAsset>(
            () => viewer.loadGltfFromBuffer(prepared.bytes),
          );
      await _native(() async {
        final bindings = await _outfit.bindOutfitAsset(asset, prepared);
        for (var i = 0; i < bindings.length; i++) {
          final binding = bindings[i];
          if (binding.entity == null || binding.materials.isEmpty) continue;
          final materials = binding.materials.map((m) => m.name).toSet();
          _hits[binding.entity!] = Model3dHit(
            node: prepared.names[i],
            material: materials.length == 1 ? materials.single : null,
          );
        }
      });
      await _native(() async {
        final (computed, error, stack) = await boundsFuture;
        if (error != null) Error.throwWithStackTrace(error, stack!);
        await _framing.resolveBounds(asset, _primary!.bounds ?? computed);
        await _motion.loadClips(asset);
      });
      _asset = asset;
      _primary!
        ..asset = asset
        ..prepared = prepared
        ..bounds = _framing.bounds;
      if (!reused) {
        final app = _source._platform.appFor(viewer);
        await _native(() async {
          for (final entity in {
            asset.entity,
            ...await asset.getChildEntities(),
          }) {
            _primary!.transforms[entity] = (await app.getLocalTransform(
              entity,
            )).clone();
          }
        });
      } else {
        await _native(() async {
          await _motion.resetForReuse(asset, _primary!.transforms, prepared);
          await _outfit.resetForReuse();
          await _look.resetDefaults();
        });
      }
      stats.mark('asset');

      await _outfit.reconcileOutfit();
      if (_motion.morphs.isNotEmpty) await _motion.applyMorphs();
      await _look.applyLook();
      await _framing.frame(_framing.framedAspect ?? 1);
      if (_motion.layer != null) {
        await _motion.configureLayer(Duration.zero);
      } else if (_motion.lookAt != null) {
        await _motion.configureMotion();
      }
      _touch();
      _ifAlive(() {
        _ready = true;
        stats.mark('ready');
      });
      _syncRenderingHold();
      _scene.reconcileScene();
      debugPrint(
        '[sdui_model_filament] ${stats.summary()}, clips: ${_motion.clipNames}',
      );
    } on NativeDisposed {
      return;
    } catch (error) {
      _ifAlive(() => stats.fail('$error'));
      debugPrint('[sdui_model_filament] ${stats.summary()}');
      rethrow;
    }
  }

  void _ifAlive(VoidCallback action) {
    if (!_disposed) action();
  }

  /// Runs frames so this view's change reaches the screen.
  void _touch() {
    if (!_disposed && _viewer.value != null) _source._gate.touch(this);
  }

  /// Adds this view to Filament's frames, or leaves it out ([RenderGate]).
  void _setRendering(bool rendering) {
    final viewer = _viewer.value;
    if (_disposed || viewer == null) return;
    _quietly(_native(() => viewer.setRendering(rendering)));
  }

  late final ModelFraming _framing = ModelFraming(
    lane: _nativeLane,
    getViewer: () => _viewer.value,
    getAsset: () => _asset,
    touch: _touch,
  );
  late final ModelMotion _motion = ModelMotion(
    lane: _nativeLane,
    platform: _source._platform,
    getViewer: () => _viewer.value,
    getAsset: () => _asset,
    touch: _touch,
    getBounds: () => _framing.bounds,
    clock: _sceneClock,
    changed: _syncRenderingHold,
    getCamera: () => _framing.camera,
    getCameraPosition: () => _framing.cameraPosition,
    getDistance: () => _framing.distance,
  );
  late final ModelOutfit _outfit = ModelOutfit(
    lane: _nativeLane,
    platform: _source._platform,
    getViewer: () => _viewer.value,
    getAsset: () => _asset,
    touch: _touch,
    getBounds: () => _framing.bounds,
    models: _source._models,
    clock: _sceneClock,
    changed: _syncRenderingHold,
    getLook: () => _look.look,
  );
  late final ModelScene _scene = ModelScene(
    lane: _nativeLane,
    platform: _source._platform,
    getViewer: () => _viewer.value,
    getAsset: () => _asset,
    touch: _touch,
    models: _source._models,
    changed: _syncRenderingHold,
    getLook: () => _look.look,
  );
  late final ModelLook _look = ModelLook(
    lane: _nativeLane,
    platform: _source._platform,
    getViewer: () => _viewer.value,
    getAsset: () => _asset,
    getBounds: () => _framing.bounds,
    iblIntensity: _source.iblIntensity,
    touch: _touch,
    extraAssets: () => [..._scene.assets, ..._outfit.assets],
  );

  @override
  void setCamera(Model3dCamera camera) {
    _framing.camera = camera;
    _syncFrameHook();
    _quietly(_framing.place().then((_) => _motion.cameraChanged()));
  }

  @override
  void setLook(Model3dLook look) => _look.setLook(look);
  @override
  void setOutfit(Model3dOutfit outfit) => _outfit.setOutfit(outfit);
  @override
  void setScene(List<Model3dSceneItem> scene, {bool active = true}) {
    _lastSceneFrame = null;
    _scene.setScene(scene, active: active);
  }

  @override
  void setMorphs(Map<String, double> weights) => _motion.setMorphs(weights);
  @override
  void setLookAt(Model3dLookAt? lookAt) => _motion.setLookAt(lookAt);
  @override
  void setLayer(Model3dLayer? layer, {Duration crossfade = Duration.zero}) =>
      _motion.setLayer(layer, crossfade: crossfade);
  @override
  void setMotionActive(bool active) => _motion.setMotionActive(active);
  @override
  int get layerCompletions => _motion.layerCompletions;
  @override
  List<String> get clips => _motion.clips;
  @override
  Duration? clipDuration(String clip) => _motion.clipDuration(clip);
  @override
  void setPose(String clip, Duration time) => _motion.setPose(clip, time);
  @override
  Model3dPlayback get playback => _motion.playback;
  @override
  Future<void> play(
    String clip, {
    required bool loop,
    Duration crossfade = Duration.zero,
  }) => _motion.play(clip, loop: loop, crossfade: crossfade);
  @override
  Future<void> stop() => _motion.stop();
  @override
  void addListener(VoidCallback listener) => _motion.addListener(listener);
  @override
  void removeListener(VoidCallback listener) =>
      _motion.removeListener(listener);

  Future<T> _native<T>(Future<T> Function() work) => _nativeLane.run(work);
  void _quietly(Future<void> work) => _nativeLane.observe(work);

  @override
  Widget buildView() {
    return _view ??= () {
      final view = _FilamentView(controller: this);
      return _source.debugOverlay
          ? ModelDebugOverlay(stats: stats, child: view)
          : view;
    }();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _nativeLane.disposed = true;
    for (final result in _picks) {
      if (!result.isCompleted) result.complete(null);
    }
    _motion.invalidate();
    final viewer = _viewer.value;
    if (viewer == null) return;
    await _hookLane;
    if (_hookRegistered) {
      await _source._platform
          .appFor(viewer)
          .unregisterRequestFrameHook(_onSceneFrame);
      _hookRegistered = false;
    }
    _viewer.value = null;
    _source._gate.release(this);
    // The call in flight finishes; every queued one throws [NativeDisposed].
    await _nativeLane.drain;
    _asset = null;
    var cleaned = false;
    try {
      if (_primary?.asset != null) await _motion.dispose(_primary!.asset!);
      try {
        await _outfit.dispose(viewer);
        await _scene.dispose(viewer);
      } finally {
        await _look.dispose(viewer);
      }
      cleaned = true;
    } finally {
      if (cleaned && _ready && _primary != null) {
        await _source._pool.keepOrRelease(_primary!);
      } else {
        await _source._platform.releaseViewer(viewer);
      }
    }
  }
}

/// The Filament texture. It takes no pointers: the engine handles gestures
/// and moves the camera through [FilamentModel3dController.setCamera].
final class _FilamentView extends StatelessWidget {
  const _FilamentView({required this.controller});

  final FilamentModel3dController controller;

  @override
  Widget build(BuildContext context) {
    controller._devicePixelRatio =
        MediaQuery.maybeDevicePixelRatioOf(context) ??
        View.of(context).devicePixelRatio;
    return LayoutBuilder(
      builder: (context, constraints) {
        final aspect =
            constraints.hasBoundedWidth &&
                constraints.hasBoundedHeight &&
                constraints.maxHeight > 0
            ? constraints.maxWidth / constraints.maxHeight
            : 1.0;
        if (aspect != controller._framing.framedAspect) {
          controller._quietly(controller._framing.frame(aspect));
        }
        // A new layout may recreate the texture, which needs a frame.
        controller._touch();
        return ValueListenableBuilder<ThermionViewer?>(
          valueListenable: controller._viewer,
          builder: (context, viewer, _) => viewer == null
              ? const SizedBox.expand()
              : ThermionWidget(viewer: viewer),
        );
      },
    );
  }
}
