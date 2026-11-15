import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show listEquals, mapEquals;

/// Defines the policy for creating 3D model controllers.
///
/// The contract carries no renderer types: implementations decide the backing
/// renderer (a webview `<model-viewer>`, Filament, SceneKit), source
/// resolution, formats, and caching — everything beyond the surface the
/// engine's `model_3d` widget drives. The package ships no renderer; without an
/// installed source the widget shows its `poster`.
abstract class Model3dSource {
  /// Renderer frames per second; null uses the display rate.
  int? get frameRate => null;

  /// Creates a controller for [request] without loading the model.
  Future<SduiModel3dController> controllerFor(Model3dRequest request);

  /// Prepares the renderer ahead of the first `model_3d` mount (e.g. spins up a
  /// hidden webview). Called once in the background after engine boot; the
  /// default does nothing.
  Future<void> warmUp() async {}
}

/// A renderable hit. Unnamed nodes and ambiguous materials remain null.
@immutable
final class Model3dHit {
  const Model3dHit({this.node, this.material});
  final String? node;
  final String? material;
}

/// Picking is optional so implements-based host controllers stay compatible.
abstract interface class Model3dTapController {
  Future<Model3dHit?> hitTest(Offset localPosition);
}

extension Model3dTapExtension on SduiModel3dController {
  Future<Model3dHit?> hitTest(Offset localPosition) async {
    final Object controller = this;
    return controller is Model3dTapController
        ? controller.hitTest(localPosition)
        : null;
  }
}

/// Carries resolved model props to a [Model3dSource].
final class Model3dRequest {
  const Model3dRequest({required this.src});

  final String src;
}

/// Immutable dress-up state. Unmentioned parts retain their authored values.
@immutable
final class Model3dOutfit {
  Model3dOutfit({
    List<String> show = const [],
    List<String> hide = const [],
    Map<String, Color> colors = const {},
    Map<String, String?> attach = const {},
    this.transition = Model3dOutfitTransition.pop,
    this.duration = const Duration(milliseconds: 300),
  }) : show = List.unmodifiable(show),
       hide = List.unmodifiable(hide),
       colors = Map.unmodifiable(colors),
       attach = Map.unmodifiable(attach);

  final List<String> show;
  final List<String> hide;
  final Map<String, Color> colors;
  final Map<String, String?> attach;
  final Model3dOutfitTransition transition;
  final Duration duration;

  @override
  bool operator ==(Object other) =>
      other is Model3dOutfit &&
      listEquals(show, other.show) &&
      listEquals(hide, other.hide) &&
      mapEquals(colors, other.colors) &&
      mapEquals(attach, other.attach) &&
      transition == other.transition &&
      duration == other.duration;
  @override
  int get hashCode => Object.hash(
    Object.hashAll(show),
    Object.hashAll(hide),
    Object.hashAllUnordered(
      colors.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    Object.hashAllUnordered(
      attach.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    transition,
    duration,
  );
}

enum Model3dOutfitTransition { cut, pop, drop, dissolve }

/// Optional capability keeps existing implements-based controllers compatible.
abstract interface class Model3dOutfitController {
  void setOutfit(Model3dOutfit outfit);
}

extension Model3dOutfitExtension on SduiModel3dController {
  /// Keeps the latest snapshot before or after initialization.
  void setOutfit(Model3dOutfit outfit) {
    final Object controller = this;
    if (controller is Model3dOutfitController) {
      controller.setOutfit(outfit);
    }
  }
}

/// Optional expression and motion operations; base controllers remain compatible.
abstract interface class Model3dMotionController {
  void setMorphs(Map<String, double> weights);
  void setLookAt(Model3dLookAt? lookAt);
  void setMotionActive(bool active);
  void setLayer(Model3dLayer? layer, {Duration crossfade = Duration.zero});
  int get layerCompletions;
}

/// A secondary clip; its authored channels override the base pose.
@immutable
final class Model3dLayer {
  const Model3dLayer({required this.clip, this.loop = false, this.weight = 1});
  final String clip;
  final bool loop;
  final double weight;
  @override
  bool operator ==(Object other) =>
      other is Model3dLayer &&
      clip == other.clip &&
      loop == other.loop &&
      weight == other.weight;
  @override
  int get hashCode => Object.hash(clip, loop, weight);
}

enum Model3dLookAtTarget { camera, pointer, point }

/// Bone rotation added to the current pose; pointer points are view-normalized.
@immutable
final class Model3dLookAt {
  const Model3dLookAt({
    this.bone = 'head',
    this.target = Model3dLookAtTarget.camera,
    this.point,
    this.weight = 1,
    this.maxYaw = 60,
    this.maxPitch = 30,
    this.duration = const Duration(milliseconds: 150),
  });
  final String bone;
  final Model3dLookAtTarget target;
  final (double, double, double)? point;
  final double weight;
  final double maxYaw;
  final double maxPitch;
  final Duration duration;

  @override
  bool operator ==(Object other) =>
      other is Model3dLookAt &&
      bone == other.bone &&
      target == other.target &&
      point == other.point &&
      weight == other.weight &&
      maxYaw == other.maxYaw &&
      maxPitch == other.maxPitch &&
      duration == other.duration;
  @override
  int get hashCode =>
      Object.hash(bone, target, point, weight, maxYaw, maxPitch, duration);
}

extension Model3dMotionExtension on SduiModel3dController {
  int get layerCompletions {
    final Object controller = this;
    return controller is Model3dMotionController
        ? controller.layerCompletions
        : 0;
  }

  void setLayer(Model3dLayer? layer, {Duration crossfade = Duration.zero}) {
    final Object controller = this;
    if (controller is Model3dMotionController) {
      controller.setLayer(layer, crossfade: crossfade);
    }
  }

  void setLookAt(Model3dLookAt? lookAt) {
    final Object controller = this;
    if (controller is Model3dMotionController) controller.setLookAt(lookAt);
  }

  void setMotionActive(bool active) {
    final Object controller = this;
    if (controller is Model3dMotionController) {
      controller.setMotionActive(active);
    }
  }

  void setMorphs(Map<String, double> weights) {
    final Object controller = this;
    if (controller is Model3dMotionController) {
      controller.setMorphs(Map.unmodifiable(weights));
    }
  }
}

/// An extra model in primary glTF world units. Its list index is its identity.
@immutable
final class Model3dSceneItem {
  const Model3dSceneItem({
    required this.src,
    this.position = (0, 0, 0),
    this.rotation = (yaw: 0, pitch: 0, roll: 0),
    this.scale = 1,
    this.clip,
    this.spin,
  });

  final String src;
  final (double, double, double) position;
  final ({double yaw, double pitch, double roll}) rotation;
  final double scale;
  final String? clip;
  final ({String axis, double speed})? spin;

  @override
  bool operator ==(Object other) =>
      other is Model3dSceneItem &&
      src == other.src &&
      position == other.position &&
      rotation == other.rotation &&
      scale == other.scale &&
      clip == other.clip &&
      spin == other.spin;

  @override
  int get hashCode => Object.hash(src, position, rotation, scale, clip, spin);
}

/// Optional capability; adding members to the base controller breaks implements.
abstract interface class Model3dSceneController {
  void setScene(List<Model3dSceneItem> scene, {bool active = true});
}

extension Model3dSceneExtension on SduiModel3dController {
  /// Keeps a snapshot; hidden views pause extras without unloading them.
  void setScene(List<Model3dSceneItem> scene, {bool active = true}) {
    final Object controller = this;
    if (controller is Model3dSceneController) {
      controller.setScene(List.unmodifiable(scene), active: active);
    }
  }
}

/// A centre, point or primary node, with flattened weights during transitions.
@immutable
final class Model3dTarget {
  const Model3dTarget() : point = null, node = null, _weights = null;
  const Model3dTarget.point(this.point) : node = null, _weights = null;
  const Model3dTarget.node(this.node) : point = null, _weights = null;
  Model3dTarget._blend(List<(Model3dTarget, double)> weights)
    : point = null,
      node = null,
      _weights = List.unmodifiable(weights);

  final (double, double, double)? point;
  final String? node;
  final List<(Model3dTarget, double)>? _weights;

  /// Every entry is a leaf target; its weight contributes to the final centre.
  List<(Model3dTarget, double)> get weights => _weights ?? [(this, 1)];

  static Model3dTarget lerp(Model3dTarget from, Model3dTarget to, double t) {
    if (t <= 0 || from == to) return from;
    if (t >= 1) return to;
    final weights = <Model3dTarget, double>{};
    for (final (target, weight) in from.weights) {
      weights[target] = (weights[target] ?? 0) + weight * (1 - t);
    }
    for (final (target, weight) in to.weights) {
      weights[target] = (weights[target] ?? 0) + weight * t;
    }
    if (weights.length == 1) return weights.keys.single;
    return Model3dTarget._blend([
      for (final entry in weights.entries) (entry.key, entry.value),
    ]);
  }

  @override
  bool operator ==(Object other) =>
      other is Model3dTarget &&
      point == other.point &&
      node == other.node &&
      listEquals(_weights, other._weights);
  @override
  int get hashCode => Object.hash(
    point,
    node,
    _weights == null ? null : Object.hashAll(_weights),
  );

  @override
  String toString() {
    if (_weights != null) return 'Model3dTarget.blend($_weights)';
    if (point != null) return 'Model3dTarget.point($point)';
    if (node != null) return 'Model3dTarget.node($node)';
    return 'Model3dTarget()';
  }
}

/// Where the camera sits: an orbit around the model's centre.
///
/// The engine owns the camera — it turns gestures, auto-rotation and the
/// template's `camera` into one of these per frame — so every renderer moves
/// the same way for the same template. A renderer only places its camera.
@immutable
final class Model3dCamera {
  const Model3dCamera({
    this.yaw = 0,
    this.pitch = 0,
    this.zoom = 1,
    this.target = const Model3dTarget(),
    this.pan = Offset.zero,
  });

  /// Degrees around the vertical axis. 0 looks at the model's front (+Z);
  /// positive moves the camera toward the model's right (+X).
  final double yaw;

  /// Degrees above the horizon; positive looks down on the model.
  final double pitch;

  /// Magnification of the framed view: 1 fits the whole model, 2 is twice
  /// as close.
  final double zoom;
  final Model3dTarget target;

  /// Content displacement in the view plane relative to the primary framed
  /// size: positive x moves content right, positive y moves it down.
  final Offset pan;

  @override
  bool operator ==(Object other) =>
      other is Model3dCamera &&
      other.yaw == yaw &&
      other.pitch == pitch &&
      other.zoom == zoom &&
      other.target == target &&
      other.pan == pan;

  @override
  int get hashCode => Object.hash(yaw, pitch, zoom, target, pan);

  @override
  String toString() =>
      'Model3dCamera(yaw: $yaw, pitch: $pitch, zoom: $zoom, '
      'target: $target, pan: $pan)';
}

/// Optional appearance capability keeps implements-based controllers compatible.
abstract interface class Model3dLookController {
  void setLook(Model3dLook look);
}

extension Model3dLookExtension on SduiModel3dController {
  /// Keeps the latest look before or after initialization when supported.
  void setLook(Model3dLook look) {
    final Object controller = this;
    if (controller is Model3dLookController) controller.setLook(look);
  }
}

/// Renderer-neutral lighting, shadow and image quality for one model view.
@immutable
final class Model3dLook {
  const Model3dLook({
    this.environment = 1,
    this.environmentRotation = 0,
    this.light,
    this.shadow = const Model3dShadow(),
    this.quality = Model3dQuality.medium,
    this.exposure = 0,
  });

  final double environment;
  final double environmentRotation;
  final Model3dLight? light;
  final Model3dShadow shadow;
  final Model3dQuality quality;
  final double exposure;

  @override
  bool operator ==(Object other) =>
      other is Model3dLook &&
      environment == other.environment &&
      environmentRotation == other.environmentRotation &&
      light == other.light &&
      shadow == other.shadow &&
      quality == other.quality &&
      exposure == other.exposure;

  @override
  int get hashCode => Object.hash(
    environment,
    environmentRotation,
    light,
    shadow,
    quality,
    exposure,
  );
}

/// Direction the light comes from, in the camera's orbit frame, in degrees.
@immutable
final class Model3dLight {
  const Model3dLight({
    this.yaw = 45,
    this.pitch = 45,
    this.intensity = 1,
    this.color = const Color(0xFFFFFFFF),
  });

  final double yaw;
  final double pitch;
  final double intensity;
  final Color color;

  @override
  bool operator ==(Object other) =>
      other is Model3dLight &&
      yaw == other.yaw &&
      pitch == other.pitch &&
      intensity == other.intensity &&
      color == other.color;

  @override
  int get hashCode => Object.hash(yaw, pitch, intensity, color);
}

@immutable
final class Model3dShadow {
  const Model3dShadow({this.type = Model3dShadowType.none, this.opacity = 0.5});

  final Model3dShadowType type;
  final double opacity;

  @override
  bool operator ==(Object other) =>
      other is Model3dShadow && type == other.type && opacity == other.opacity;

  @override
  int get hashCode => Object.hash(type, opacity);
}

enum Model3dShadowType { none, contact, cast }

enum Model3dQuality { low, medium, high }

/// The animation surface the engine's `model_3d` widget drives — the whole
/// coupling between the engine and whatever renderer the app installs.
abstract class SduiModel3dController {
  /// Loads the model; must complete before [clips] and [play] are used. A
  /// failed load is final: the engine disposes the controller and creates a
  /// new one to try again.
  Future<void> initialize();

  /// Animation clip names the loaded model carries (empty for a static model).
  List<String> get clips;

  /// Plays [clip], blending from the current clip over [crossfade]. A
  /// non-looping clip holds its last frame and increments
  /// [Model3dPlayback.completions] once when it finishes. The returned future
  /// reports whether the clip started.
  ///
  /// A later [play] (of any clip, the same one included), [stop], [dispose]
  /// or [setPose] of the playing clip supersedes this play the moment it is
  /// called: the superseded play's late native work and timers never change
  /// [playback] again.
  Future<void> play(
    String clip, {
    required bool loop,
    Duration crossfade = Duration.zero,
  });

  /// Stops animation playback.
  Future<void> stop();

  /// The length of [clip] in the loaded model, or null when the model has no
  /// such clip or is not loaded.
  Duration? clipDuration(String clip);

  /// Holds [clip] at [time] without playing it: the engine owns the playhead
  /// of a `progress` clip and calls this on every frame it moves, after
  /// [initialize]. A renderer stops its own playback of [clip] first (its
  /// [playback] stops playing; [Model3dPlayback.completions] stays), keeps
  /// the latest value, and may drop intermediate values while one is being
  /// applied.
  void setPose(String clip, Duration time);

  /// Places the camera. The engine calls this once right after creation and
  /// then on every frame the camera moves, before and after [initialize]; a
  /// renderer keeps the latest value and applies it once the model is
  /// loaded, and may drop intermediate values while one is being applied.
  void setCamera(Model3dCamera camera);

  /// [listener] fires on any playback-state change ([playback]).
  void addListener(VoidCallback listener);

  void removeListener(VoidCallback listener);

  /// The current playback snapshot.
  Model3dPlayback get playback;

  /// The rendered model surface, unsized — the engine sizes and clips it.
  /// It never receives pointer events: the engine handles gestures above it
  /// and drives the camera through [setCamera].
  ///
  /// The engine mounts this view as soon as the controller exists, before
  /// and during [initialize], hidden under the poster — so a renderer that
  /// loads inside its view (a webview) can complete [initialize] from there.
  /// It stays mounted across the ready transition.
  Widget buildView();

  /// Releases the renderer's resources. It may come at any point, also while
  /// [initialize] or other calls are still in flight; none of their pending
  /// work may touch the released resources afterwards.
  Future<void> dispose();
}

/// One immutable snapshot of model playback state.
final class Model3dPlayback {
  const Model3dPlayback({
    this.clip,
    this.isPlaying = false,
    this.completions = 0,
  });

  /// The clip last passed to [SduiModel3dController.play], or null.
  final String? clip;

  final bool isPlaying;

  /// Monotonic count of finished non-looping plays — the engine detects a
  /// clip end by this counter advancing.
  final int completions;
}
