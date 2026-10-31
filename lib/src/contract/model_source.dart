import 'package:flutter/widgets.dart';

/// Defines the policy for creating 3D model controllers.
///
/// The contract carries no renderer types: implementations decide the backing
/// renderer (a webview `<model-viewer>`, Filament, SceneKit), source
/// resolution, formats, and caching — everything beyond the surface the
/// engine's `model` widget drives. The package ships no renderer; without an
/// installed source the widget shows its `poster`.
abstract class ModelSource {
  /// Creates a controller for [request] without loading the model.
  Future<SduiModelController> controllerFor(ModelRequest request);

  /// Prepares the renderer ahead of the first `model` mount (e.g. spins up a
  /// hidden webview). Called once in the background after engine boot; the
  /// default does nothing.
  Future<void> warmUp() async {}
}

/// Carries resolved model props to a [ModelSource].
final class ModelRequest {
  const ModelRequest({required this.src});

  final String src;
}

/// Where the camera sits: an orbit around the model's centre.
///
/// The engine owns the camera — it turns gestures, auto-rotation and the
/// template's `camera` into one of these per frame — so every renderer moves
/// the same way for the same template. A renderer only places its camera.
@immutable
final class ModelCamera {
  const ModelCamera({this.yaw = 0, this.pitch = 0, this.zoom = 1});

  /// Degrees around the vertical axis. 0 looks at the model's front (+Z);
  /// positive moves the camera toward the model's right (+X).
  final double yaw;

  /// Degrees above the horizon; positive looks down on the model.
  final double pitch;

  /// Magnification of the framed view: 1 fits the whole model, 2 is twice
  /// as close.
  final double zoom;

  @override
  bool operator ==(Object other) =>
      other is ModelCamera &&
      other.yaw == yaw &&
      other.pitch == pitch &&
      other.zoom == zoom;

  @override
  int get hashCode => Object.hash(yaw, pitch, zoom);

  @override
  String toString() => 'ModelCamera(yaw: $yaw, pitch: $pitch, zoom: $zoom)';
}

/// The animation surface the engine's `model` widget drives — the whole
/// coupling between the engine and whatever renderer the app installs.
abstract class SduiModelController {
  /// Loads the model; must complete before [clips] and [play] are used.
  Future<void> initialize();

  /// Animation clip names the loaded model carries (empty for a static model).
  List<String> get clips;

  /// Plays [clip], blending from the current clip over [crossfade]. A
  /// non-looping clip holds its last frame and increments
  /// [ModelPlayback.completions] when it finishes.
  Future<void> play(
    String clip, {
    required bool loop,
    Duration crossfade = Duration.zero,
  });

  /// Stops animation playback.
  Future<void> stop();

  /// Places the camera. The engine calls this once right after creation and
  /// then on every frame the camera moves, before and after [initialize]; a
  /// renderer keeps the latest value and applies it once the model is
  /// loaded, and may drop intermediate values while one is being applied.
  void setCamera(ModelCamera camera);

  /// [listener] fires on any playback-state change ([playback]).
  void addListener(VoidCallback listener);

  void removeListener(VoidCallback listener);

  /// The current playback snapshot.
  ModelPlayback get playback;

  /// The rendered model surface, unsized — the engine sizes and clips it.
  /// It never receives pointer events: the engine handles gestures above it
  /// and drives the camera through [setCamera].
  ///
  /// The engine mounts this view as soon as the controller exists, before
  /// and during [initialize], hidden under the poster — so a renderer that
  /// loads inside its view (a webview) can complete [initialize] from there.
  /// It stays mounted across the ready transition.
  Widget buildView();

  Future<void> dispose();
}

/// One immutable snapshot of model playback state.
final class ModelPlayback {
  const ModelPlayback({
    this.clip,
    this.isPlaying = false,
    this.completions = 0,
  });

  /// The clip last passed to [SduiModelController.play], or null.
  final String? clip;

  final bool isPlaying;

  /// Monotonic count of finished non-looping plays — the engine detects a
  /// clip end by this counter advancing.
  final int completions;
}
