import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_model_support/sdui_model_support.dart';
import 'package:thermion_flutter/thermion_flutter.dart' hide Texture, View;

import 'render_gate.dart';

/// A [ModelSource] that renders each `model` natively with Filament (through
/// `thermion_flutter`) into a Flutter `Texture`.
///
/// ```dart
/// Sdui.initialize(
///   modelSource: FilamentModelSource(
///     baseUrl: Uri.parse(apiUrl),       // resolves `/assets/...` srcs
///     prefetch: ['/assets/character.glb'],
///   ),
///   ...
/// );
/// ```
///
/// The view is an ordinary Flutter widget: it clips, transforms and fades
/// with its parent. The engine owns gestures and auto-rotation and orbits
/// the camera through [FilamentModelController.setCamera].
/// [warmUp] creates the Filament engine ahead of the first mount. Frames
/// render only while some model changes or plays ([RenderGate]).
///
/// [debugOverlay] (default: `--dart-define=SDUI_MODEL_DEBUG=true`) paints each
/// view's load timeline, app memory and frame times over it for measurement.
final class FilamentModelSource extends ModelSource {
  FilamentModelSource({
    Uri? baseUrl,
    this.prefetch = const [],
    this.loadTimeout = const Duration(seconds: 30),
    this.iblIntensity = 30000,
    http.Client? client,
    AssetBundle? bundle,
    int cachedModels = 4,
    this.debugOverlay = const bool.fromEnvironment('SDUI_MODEL_DEBUG'),
  }) : models = ModelBytesCache(
         baseUrl: baseUrl,
         client: client,
         bundle: bundle,
         maxEntries: cachedModels,
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

  final ModelBytesCache models;

  /// Filament's neutral studio environment (`lightroom_ibl.ktx`, Apache-2.0).
  static const iblAsset =
      'asset://packages/sdui_model_filament/assets/lightroom_ibl.ktx';

  int _mounts = 0;
  int? _warmUpMs;

  /// Pauses Filament's frame loop while every model is still. A surface the
  /// platform recreated while the app was hidden gets a frame on resume.
  late final RenderGate _gate = () {
    AppLifecycleListener(onResume: () => _gate.touch(this));
    return RenderGate(
      resume: ThermionFlutterPlugin.instance.resumeFrameScheduler,
      pause: ThermionFlutterPlugin.instance.pauseFrameScheduler,
    );
  }();

  @override
  Future<SduiModelController> controllerFor(ModelRequest request) async =>
      FilamentModelController(request, this);

  ModelLoadStats _statsFor(String src) => ModelLoadStats(
    src: src,
    mount: ++_mounts,
    warmUpMs: _warmUpMs,
    renderer: 'filament',
  );

  @override
  Future<void> warmUp() async {
    final clock = Stopwatch()..start();
    final loads = [for (final src in prefetch) models.load(src)];
    // The first viewer creates the engine and render thread, which outlive
    // it; later viewers attach to them.
    final viewer = await ThermionFlutterPlugin.createViewer();
    await viewer.dispose();
    _gate.settle();
    await Future.wait(loads);
    _warmUpMs = clock.elapsedMilliseconds;
    debugPrint('[sdui_model_filament] warm-up took ${_warmUpMs}ms');
  }
}

/// Drives one Filament viewer for the engine's `model` widget.
final class FilamentModelController implements SduiModelController {
  FilamentModelController(this._request, this._source)
    : stats = _source._statsFor(_request.src);

  final ModelRequest _request;
  final FilamentModelSource _source;

  /// This view's load timeline, also painted when
  /// [FilamentModelSource.debugOverlay] is on.
  final ModelLoadStats stats;

  /// Set once the viewer exists, so the view allocates its texture while the
  /// model is still loading.
  final _viewer = ValueNotifier<ThermionViewer?>(null);
  final _listeners = <VoidCallback>[];
  Future<void>? _loading;
  ThermionAsset? _asset;
  double? _framedAspect;
  ModelCamera _camera = const ModelCamera();

  /// Camera distance that frames the model at zoom 1; set once the asset is
  /// loaded and the view's aspect is known.
  double? _distance;
  bool _placing = false;
  bool _placeAgain = false;
  Timer? _clipEnd;
  List<String> _clips = const [];
  Map<String, Duration> _durations = const {};

  /// The clip index a [play] started, until [stop] or a pose of that clip.
  int? _playing;
  (String, Duration)? _pose;
  bool _posing = false;
  bool _poseAgain = false;
  ModelPlayback _playback = const ModelPlayback();
  bool _disposed = false;
  Widget? _view;

  /// Radius the camera keeps in frame; the asset is scaled so its largest
  /// extent spans -1..1.
  static const _frameRadius = 1.15;

  @override
  Future<void> initialize() =>
      (_loading ??= _load()).timeout(_source.loadTimeout);

  Future<void> _load() async {
    try {
      final src = _request.src;
      final cached = _source.models.contains(src);
      final bytesStarted = stats.elapsedMs;
      final bytes = _source.models.load(src).then((data) {
        _ifAlive(
          () => stats.served(
            bytes: data.length,
            cached: cached,
            ms: stats.elapsedMs - bytesStarted,
          ),
        );
        return data;
      });

      final viewer = await ThermionFlutterPlugin.createViewer();
      if (_disposed) {
        await viewer.dispose();
        return;
      }
      _viewer.value = viewer;
      stats.mark('viewer');

      await viewer.setBackgroundColor(0, 0, 0, 0);
      await viewer.view.setBlendMode(BlendMode.transparent);
      await viewer.setPostProcessing(true);
      await viewer.setAntiAliasing(false, true, false);
      await viewer.loadIbl(
        FilamentModelSource.iblAsset,
        intensity: _source.iblIntensity,
      );

      final asset = await viewer.loadGltfFromBuffer(await bytes);
      if (_disposed) return;
      await asset.transformToUnitCube();
      _asset = asset;
      final clips = await asset.getGltfAnimationNames();
      _clips = List.unmodifiable(clips);
      _durations = {
        for (var i = 0; i < clips.length; i++)
          clips[i]: Duration(
            microseconds:
                (await asset.getGltfAnimationDuration(i) *
                        Duration.microsecondsPerSecond)
                    .round(),
          ),
      };
      stats.mark('asset');

      await _frame(_framedAspect ?? 1);
      await viewer.setRendering(true);
      _touch();
      _ifAlive(() => stats.mark('ready'));
      debugPrint('[sdui_model_filament] ${stats.summary()}, clips: $_clips');
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

  /// Sets the zoom-1 distance so [_frameRadius] fits the narrower field of
  /// view, then places the camera.
  Future<void> _frame(double aspect) async {
    _framedAspect = aspect;
    final viewer = _viewer.value;
    if (viewer == null || _asset == null || _disposed) return;
    final camera = await viewer.getActiveCamera();
    final focalLength = await camera.getFocalLength();
    // Filament's lens projection assumes a 24mm-tall sensor.
    final vertical = 2 * math.atan(12 / focalLength);
    final horizontal = 2 * math.atan(math.tan(vertical / 2) * aspect);
    final fov = math.min(vertical, horizontal);
    _distance = _frameRadius / math.sin(fov / 2);
    await _place();
  }

  @override
  void setCamera(ModelCamera camera) {
    _camera = camera;
    unawaited(_place());
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
        final camera = await viewer.getActiveCamera();
        await camera.lookAt(
          Vector3(
            d * math.cos(pitch) * math.sin(yaw),
            d * math.sin(pitch),
            d * math.cos(pitch) * math.cos(yaw),
          ),
        );
        _touch();
      } while (_placeAgain && !_disposed);
    } finally {
      _placing = false;
    }
  }

  @override
  List<String> get clips => _clips;

  @override
  Duration? clipDuration(String clip) => _durations[clip];

  @override
  void setPose(String clip, Duration time) {
    _pose = (clip, time);
    unawaited(_applyPose());
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
        final index = _clips.indexOf(clip);
        if (index < 0) continue;
        // A playing clip would overwrite the pose on its next frame.
        if (_playing == index) {
          _clipEnd?.cancel();
          _playing = null;
          _source._gate.hold(this, playing: false);
          await asset.stopGltfAnimation(index);
        }
        await asset.setGltfAnimationTime(
          index,
          time.inMicroseconds / Duration.microsecondsPerSecond,
        );
        _touch();
      } while (_poseAgain && !_disposed);
    } finally {
      _posing = false;
    }
  }

  @override
  ModelPlayback get playback => _playback;

  @override
  Future<void> play(
    String clip, {
    required bool loop,
    Duration crossfade = Duration.zero,
  }) async {
    final asset = _asset;
    final index = _clips.indexOf(clip);
    _clipEnd?.cancel();
    _update(
      ModelPlayback(
        clip: clip,
        isPlaying: true,
        completions: _playback.completions,
      ),
    );
    if (asset == null || index < 0) return;
    _playing = index;
    _source._gate.hold(this, playing: true);
    await asset.playGltfAnimation(
      index,
      loop: loop,
      crossfade: crossfade.inMicroseconds / Duration.microsecondsPerSecond,
    );
    if (loop) return;
    // Filament reports no end event: a non-looping clip ends after its
    // duration and holds its last frame.
    final seconds = await asset.getGltfAnimationDuration(index);
    _clipEnd = Timer(
      Duration(
        microseconds: (seconds * Duration.microsecondsPerSecond).round(),
      ),
      () {
        _source._gate.hold(this, playing: false);
        _update(
          ModelPlayback(
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
    _clipEnd?.cancel();
    final asset = _asset;
    final index = _clips.indexOf(_playback.clip ?? '');
    _playing = null;
    if (asset != null && index >= 0) await asset.stopGltfAnimation(index);
    if (_viewer.value != null) _source._gate.hold(this, playing: false);
    _touch();
    _update(
      ModelPlayback(
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

  void _update(ModelPlayback playback) {
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
    _clipEnd?.cancel();
    _listeners.clear();
    final viewer = _viewer.value;
    _viewer.value = null;
    _asset = null;
    if (viewer == null) return;
    _source._gate.release(this);
    try {
      // The texture's render target refers to the view; release it before
      // the viewer destroys the view.
      await ThermionFlutterPlugin.instance.destroyTextureForView(viewer.view);
    } finally {
      await viewer.dispose();
      await ThermionFlutterPlugin.instance.onViewerDisposed(viewer.view);
    }
  }
}

/// The Filament texture. It takes no pointers: the engine handles gestures
/// and moves the camera through [FilamentModelController.setCamera].
final class _FilamentView extends StatelessWidget {
  const _FilamentView({required this.controller});

  final FilamentModelController controller;

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
          unawaited(controller._frame(aspect));
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
