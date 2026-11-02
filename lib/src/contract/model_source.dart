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
  const ModelRequest({
    required this.src,
    this.interactive = false,
    this.autoRotate = false,
  });

  final String src;

  /// Whether the view should handle camera gestures (orbit, zoom) itself.
  final bool interactive;

  /// Whether the camera slowly orbits the model on its own.
  final bool autoRotate;
}

/// The animation surface the engine's `model` widget drives — the whole
/// coupling between the engine and whatever renderer the app installs.
abstract class SduiModelController {
  /// Loads the model; must complete before [clips] and [buildView] are used.
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

  /// [listener] fires on any playback-state change ([playback]).
  void addListener(VoidCallback listener);

  void removeListener(VoidCallback listener);

  /// The current playback snapshot.
  ModelPlayback get playback;

  /// The rendered model surface, unsized — the engine sizes and clips it.
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
