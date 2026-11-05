import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:sdui_engine/sdui_engine.dart';
import 'package:thermion_flutter/thermion_flutter.dart' hide Texture, View;

import 'filament_platform.dart';
import 'load_stats.dart';
import 'model_bytes.dart';
import 'model_disk_cache.dart';
import 'render_gate.dart';

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
    AssetBundle? bundle,
    int cachedModels = 4,
    bool diskCache = true,
    this.debugOverlay = const bool.fromEnvironment('SDUI_MODEL_DEBUG'),
    @visibleForTesting FilamentPlatform platform = const FilamentPlatform(),
  }) : _platform = platform,
       _models = ModelBytesCache(
         baseUrl: baseUrl,
         client: client,
         bundle: bundle,
         maxEntries: cachedModels,
         disk: diskCache ? ModelDiskCache() : null,
       );

  /// Model srcs loaded into memory during [warmUp].
  final List<String> prefetch;

  /// How long a model may take to load before the widget falls back to its
  /// poster.
  final Duration loadTimeout;

  /// Brightness of the bundled studio image-based light.
  final double iblIntensity;

  /// Paints [ModelDebugOverlay] over every view.
  final bool debugOverlay;

  final FilamentPlatform _platform;
  final ModelBytesCache _models;

  /// Filament's neutral studio environment (`lightroom_ibl.ktx`, Apache-2.0).
  static const iblAsset =
      'asset://packages/sdui_model_filament/assets/lightroom_ibl.ktx';

  int _mounts = 0;
  int? _warmUpMs;

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
      ModelLoadStats(src: src, mount: ++_mounts, warmUpMs: _warmUpMs);

  @override
  Future<void> warmUp() async {
    final clock = Stopwatch()..start();
    final loads = [for (final src in prefetch) _models.load(src)];
    // The first viewer creates the engine and render thread, which outlive
    // it; later viewers attach to them.
    final viewer = await _platform.createViewer();
    await viewer.dispose();
    _gate.settle();
    await Future.wait(loads);
    _warmUpMs = clock.elapsedMilliseconds;
    debugPrint('[sdui_model_filament] warm-up took ${_warmUpMs}ms');
  }
}

/// Drives one Filament viewer for the engine's `model_3d` widget.
///
/// Native calls on the viewer run one after another ([_native]), so
/// [dispose] destroys the viewer only after the call in flight and no later
/// call reaches it. Each [play] takes a run number that a later play, stop,
/// pose of the playing clip or dispose moves on, so a superseded play's late
/// work never changes [playback].
final class FilamentModel3dController implements SduiModel3dController {
  FilamentModel3dController(this._request, this._source)
    : stats = _source._statsFor(_request.src);

  final Model3dRequest _request;
  final FilamentModel3dSource _source;

  /// This view's load timeline, also painted when
  /// [FilamentModel3dSource.debugOverlay] is on.
  final ModelLoadStats stats;

  /// Set once the viewer exists, so the view allocates its texture while the
  /// model is still loading.
  final _viewer = ValueNotifier<ThermionViewer?>(null);
  final _listeners = <VoidCallback>[];
  Future<void>? _loading;
  ThermionAsset? _asset;
  double? _framedAspect;
  Model3dCamera _camera = const Model3dCamera();

  /// Camera distance that frames the model at zoom 1; set once the asset is
  /// loaded and the view's aspect is known.
  double? _distance;
  bool _placing = false;
  bool _placeAgain = false;
  Timer? _clipEnd;

  /// The model's clips by name, with their native animation index.
  Map<String, ({int index, Duration duration})> _clips = const {};
  List<String> _clipNames = const [];

  /// The clip index a [play] started, until [stop] or a pose of that clip.
  int? _playing;

  /// The current play's number; see [_endPlay].
  int _run = 0;
  (String, Duration)? _pose;
  bool _posing = false;
  bool _poseAgain = false;
  Model3dPlayback _playback = const Model3dPlayback();
  bool _disposed = false;
  Widget? _view;

  /// The tail of the native calls queued on the viewer.
  Future<void> _lane = Future.value();

  /// Radius the camera keeps in frame; the asset is scaled so its largest
  /// extent spans -1..1.
  static const _frameRadius = 1.15;

  @override
  Future<void> initialize() =>
      (_loading ??= _load()).timeout(_source.loadTimeout);

  Future<void> _load() async {
    try {
      final src = _request.src;
      final cached = _source._models.contains(src);
      final bytesStarted = stats.elapsedMs;
      final bytes = _source._models.load(src).then((data) {
        _ifAlive(
          () => stats.served(
            bytes: data.length,
            cached: cached,
            ms: stats.elapsedMs - bytesStarted,
          ),
        );
        return data;
      });
      // A load that ends before awaiting the bytes leaves their error here.
      unawaited(bytes.then((_) {}, onError: (_) {}));

      final viewer = await _source._platform.createViewer();
      if (_disposed) {
        await viewer.dispose();
        return;
      }
      _viewer.value = viewer;
      stats.mark('viewer');

      await _native(() async {
        await viewer.setBackgroundColor(0, 0, 0, 0);
        await viewer.view.setBlendMode(BlendMode.transparent);
        await viewer.setPostProcessing(true);
        await viewer.setAntiAliasing(false, true, false);
        await viewer.loadIbl(
          FilamentModel3dSource.iblAsset,
          intensity: _source.iblIntensity,
        );
      });

      final data = await bytes;
      final asset = await _native(() => viewer.loadGltfFromBuffer(data));
      final clips = await _native(() async {
        await asset.transformToUnitCube();
        final names = await asset.getGltfAnimationNames();
        final clips = <String, ({int index, Duration duration})>{};
        for (var i = 0; i < names.length; i++) {
          // glTF does not require unique names; a name plays its first clip.
          if (clips.containsKey(names[i])) {
            debugPrint(
              '[sdui_model_filament] clip "${names[i]}" #$i ignored: '
              '"${names[i]}" is clip #${clips[names[i]]!.index}',
            );
            continue;
          }
          clips[names[i]] = (
            index: i,
            duration: Duration(
              microseconds:
                  (await asset.getGltfAnimationDuration(i) *
                          Duration.microsecondsPerSecond)
                      .round(),
            ),
          );
        }
        return clips;
      });
      _asset = asset;
      _clips = Map.unmodifiable(clips);
      _clipNames = List.unmodifiable(clips.keys);
      stats.mark('asset');

      await _frame(_framedAspect ?? 1);
      _touch();
      _ifAlive(() => stats.mark('ready'));
      debugPrint(
        '[sdui_model_filament] ${stats.summary()}, clips: $_clipNames',
      );
    } on _Disposed {
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

  /// Runs [call] on the viewer after the native calls queued before it, or
  /// throws [_Disposed] once the view is disposed.
  Future<T> _native<T>(Future<T> Function() call) {
    final next = _lane.then(
      (_) => _disposed ? throw const _Disposed() : call(),
    );
    _lane = next.then((_) {}, onError: (_) {});
    return next;
  }

  /// Runs [work] unawaited: a disposed view drops it, and other failures are
  /// logged rather than left unhandled.
  void _quietly(Future<void> work) {
    unawaited(
      work.then(
        (_) {},
        onError: (Object error) {
          if (error is! _Disposed) debugPrint('[sdui_model_filament] $error');
        },
      ),
    );
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

  /// Sets the zoom-1 distance so [_frameRadius] fits the narrower field of
  /// view, then places the camera.
  Future<void> _frame(double aspect) async {
    _framedAspect = aspect;
    final viewer = _viewer.value;
    if (viewer == null || _asset == null || _disposed) return;
    _distance = await _native(() async {
      final camera = await viewer.getActiveCamera();
      final focalLength = await camera.getFocalLength();
      // Filament's lens projection assumes a 24mm-tall sensor.
      final vertical = 2 * math.atan(12 / focalLength);
      final horizontal = 2 * math.atan(math.tan(vertical / 2) * aspect);
      final fov = math.min(vertical, horizontal);
      return _frameRadius / math.sin(fov / 2);
    });
    await _place();
  }

  @override
  void setCamera(Model3dCamera camera) {
    _camera = camera;
    _quietly(_place());
  }

  /// Orbits the camera to [_camera]. Calls arrive every frame while the
  /// camera moves; while one placement is in flight, later ones collapse
  /// into a single follow-up with the latest camera.
  Future<void> _place() async {
    final viewer = _viewer.value;
    final distance = _distance;
    if (viewer == null || distance == null || _disposed) return;
    if (_placing) {
      _placeAgain = true;
      return;
    }
    _placing = true;
    try {
      do {
        _placeAgain = false;
        final target = _camera;
        final yaw = target.yaw * math.pi / 180;
        // Straight up or down has no defined "up" for lookAt.
        final pitch = target.pitch.clamp(-89.0, 89.0) * math.pi / 180;
        final d = distance / (target.zoom > 0 ? target.zoom : 1);
        await _native(() async {
          final camera = await viewer.getActiveCamera();
          await camera.lookAt(
            Vector3(
              d * math.cos(pitch) * math.sin(yaw),
              d * math.sin(pitch),
              d * math.cos(pitch) * math.cos(yaw),
            ),
          );
        });
        _touch();
      } while (_placeAgain && !_disposed);
    } finally {
      _placing = false;
    }
  }

  @override
  List<String> get clips => _clipNames;

  @override
  Duration? clipDuration(String clip) => _clips[clip]?.duration;

  @override
  void setPose(String clip, Duration time) {
    _pose = (clip, time);
    final asset = _asset;
    final index = _clips[clip]?.index ?? -1;
    // A playing clip would overwrite the pose on its next frame.
    if (asset != null && index >= 0 && index == _playing) {
      _endPlay();
      _quietly(_native(() => asset.stopGltfAnimation(index)));
    }
    _quietly(_applyPose());
  }

  /// Holds the asset at [_pose]. Like [_place], placements in flight
  /// collapse later poses into one follow-up with the latest.
  Future<void> _applyPose() async {
    final asset = _asset;
    if (asset == null || _disposed) return;
    if (_posing) {
      _poseAgain = true;
      return;
    }
    _posing = true;
    try {
      do {
        _poseAgain = false;
        final (clip, time) = _pose!;
        final index = _clips[clip]?.index ?? -1;
        if (index < 0) continue;
        await _native(
          () => asset.setGltfAnimationTime(
            index,
            time.inMicroseconds / Duration.microsecondsPerSecond,
          ),
        );
        _touch();
      } while (_poseAgain && !_disposed);
    } finally {
      _posing = false;
    }
  }

  @override
  Model3dPlayback get playback => _playback;

  @override
  Future<void> play(
    String clip, {
    required bool loop,
    Duration crossfade = Duration.zero,
  }) async {
    final run = ++_run;
    _clipEnd?.cancel();
    _update(
      Model3dPlayback(
        clip: clip,
        isPlaying: true,
        completions: _playback.completions,
      ),
    );
    final asset = _asset;
    final index = _clips[clip]?.index ?? -1;
    if (asset == null || index < 0) return;
    _playing = index;
    _source._gate.hold(this, playing: true);
    final double? seconds;
    try {
      seconds = await _native(() async {
        await asset.playGltfAnimation(
          index,
          loop: loop,
          crossfade: crossfade.inMicroseconds / Duration.microsecondsPerSecond,
        );
        // Filament reports no end event: a non-looping clip ends after its
        // duration and holds its last frame.
        return loop ? null : await asset.getGltfAnimationDuration(index);
      });
    } on _Disposed {
      return;
    } catch (_) {
      if (run == _run) _endPlay();
      rethrow;
    }
    if (seconds == null || run != _run) return;
    _clipEnd = Timer(
      Duration(
        microseconds: (seconds * Duration.microsecondsPerSecond).round(),
      ),
      () {
        if (run != _run) return;
        _source._gate.hold(this, playing: false);
        _update(
          Model3dPlayback(
            clip: clip,
            isPlaying: false,
            completions: _playback.completions + 1,
          ),
        );
      },
    );
  }

  @override
  Future<void> stop() async {
    final asset = _asset;
    final index = _clips[_playback.clip]?.index ?? -1;
    _endPlay();
    if (asset == null || index < 0) return;
    try {
      await _native(() => asset.stopGltfAnimation(index));
    } on _Disposed {
      return;
    }
    _touch();
  }

  /// Ends the current play the moment it is superseded: its late native
  /// work and timer see a newer [_run] and leave [playback] alone.
  void _endPlay() {
    _run++;
    _clipEnd?.cancel();
    _playing = null;
    if (_viewer.value != null) _source._gate.hold(this, playing: false);
    _update(
      Model3dPlayback(
        clip: _playback.clip,
        isPlaying: false,
        completions: _playback.completions,
      ),
    );
  }

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _update(Model3dPlayback playback) {
    if (_disposed) return;
    _playback = playback;
    for (final listener in [..._listeners]) {
      listener();
    }
  }

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
    _disposed = true;
    _run++;
    _clipEnd?.cancel();
    _listeners.clear();
    final viewer = _viewer.value;
    _viewer.value = null;
    _asset = null;
    if (viewer == null) return;
    _source._gate.release(this);
    // The call in flight finishes; every queued one throws [_Disposed].
    await _lane;
    await _source._platform.releaseViewer(viewer);
  }
}

/// Unwinds work queued on a disposed view before it reaches the viewer.
final class _Disposed implements Exception {
  const _Disposed();
}

/// The Filament texture. It takes no pointers: the engine handles gestures
/// and moves the camera through [FilamentModel3dController.setCamera].
final class _FilamentView extends StatelessWidget {
  const _FilamentView({required this.controller});

  final FilamentModel3dController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final aspect =
            constraints.hasBoundedWidth &&
                constraints.hasBoundedHeight &&
                constraints.maxHeight > 0
            ? constraints.maxWidth / constraints.maxHeight
            : 1.0;
        if (aspect != controller._framedAspect) {
          controller._quietly(controller._frame(aspect));
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
