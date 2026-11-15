import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:thermion_flutter/thermion_flutter.dart' hide Texture, View;

import 'filament_platform.dart';
import 'model_glb.dart';
import 'native_lane.dart';

final class ModelMotion {
  ModelMotion({
    required this.lane,
    required this.platform,
    required this.getViewer,
    required this.getAsset,
    required this.touch,
    required this.getBounds,
    required this.clock,
    required this.changed,
    required this.getCamera,
    required this.getCameraPosition,
    required this.getDistance,
  });
  final NativeLane lane;
  final FilamentPlatform platform;
  final ThermionViewer? Function() getViewer;
  final ThermionAsset? Function() getAsset;
  final VoidCallback touch;
  final Aabb3? Function() getBounds;
  final Stopwatch clock;
  final VoidCallback changed;
  final Model3dCamera Function() getCamera;
  final Vector3? Function() getCameraPosition;
  final double? Function() getDistance;
  final _listeners = <VoidCallback>[];
  Timer? clipEnd;

  /// The model's clipTable by name, with their native animation index.
  Map<String, ({int index, Duration duration})> clipTable = const {};
  List<String> clipNames = const [];

  /// The clip index a [play] started, until [stop] or a pose of that clip.
  int? playing;

  /// The current play's number; see [endPlay].
  int run = 0;
  (String, Duration)? pose;
  Model3dPlayback _playback = const Model3dPlayback();
  Map<String, double> morphs = const {};
  List<MorphTargetSet>? morphSets;
  Model3dLookAt? lookAt;
  Model3dLookAt? posedLookAt;
  Model3dLayer? layer;
  LayerPose? layerPose;
  LayerPose? leavingLayer;
  final layerBase = <ThermionEntity, Matrix4>{};

  bool motionActive = true;
  bool driven = false;
  int? baseIndex;
  bool baseLoop = false;
  double baseTime = 0;
  Duration baseBegan = Duration.zero;
  ThermionEntity? lookBone;
  Matrix4? lookBase;
  (double, double) gaze = (0, 0);
  bool gazeMoving = false;
  double gazeSide = 0;
  Duration? motionFrame;
  Duration? layerFrame;

  bool pendingPose = false;
  bool pendingConfiguration = false;
  Duration? pendingLayer;
  Future<void> Function()? pendingReset;

  void requestPose() {
    if (lane.disposed) return;
    pendingPose = true;
    motionFrame ??= clock.elapsed;
    changed();
    touch();
  }

  bool get motionFrames =>
      motionActive &&
      (pendingPose ||
          pendingConfiguration ||
          pendingLayer != null ||
          pendingReset != null ||
          (driven &&
              (playing != null ||
                  gazeMoving ||
                  (layerPose?.moving ?? false) ||
                  leavingLayer != null)));

  int _layerCompletions = 0;
  int get layerCompletions => _layerCompletions;

  void setMorphs(Map<String, double> weights) {
    if (lane.disposed) return;
    morphs = Map.unmodifiable({
      for (final e in weights.entries)
        if (e.value.isFinite && e.value >= 0 && e.value <= 1) e.key: e.value,
    });
    lane.observe(applyMorphs());
  }

  Future<void> writeMorphs(ThermionAsset asset) async {
    if (morphs.isEmpty) return;
    final sets = morphSets ??= await asset.getMorphTargetSets();
    for (final set in sets) {
      for (final target in set.targets) {
        final value = morphs[target.name];
        if (target.name != null && value != null) {
          await set.setWeight(target.name!, value);
        }
      }
    }
  }

  Future<void> applyMorphs() async => requestPose();

  void setLookAt(Model3dLookAt? lookAt) {
    if (lane.disposed) return;
    this.lookAt = lookAt;
    lane.observe(configureMotion());
  }

  void setLayer(Model3dLayer? layer, {Duration crossfade = Duration.zero}) {
    if (lane.disposed) return;
    if (this.layer == layer) return;
    this.layer = layer;
    lane.observe(configureLayer(crossfade));
  }

  Future<void> configureLayer(Duration crossfade) async {
    pendingLayer = crossfade;
    requestPose();
  }

  Future<void> _configureLayer(Duration crossfade) async {
    final asset = getAsset();
    if (asset == null || lane.disposed) return;
    layerFrame = clock.elapsed;
    final old = layerPose;
    final layer = this.layer;
    final clip = clipTable[layer?.clip];
    final sameCursor =
        old != null &&
        layer != null &&
        clip != null &&
        old.index == clip.index &&
        old.model.loop == layer.loop;
    if (sameCursor) {
      old.model = layer;
      old.fadeFrom = old.weight;
      old.fadeTo = layer.weight;
      old.fadeTime = 0;
      old.fadeDuration =
          crossfade.inMicroseconds / Duration.microsecondsPerSecond;
      if (crossfade <= Duration.zero) old.weight = layer.weight;
      pendingConfiguration = true;
      return;
    }
    if (old != null && crossfade > Duration.zero) {
      old.fadeFrom = old.weight;
      old.fadeTo = 0;
      old.fadeTime = 0;
      old.fadeDuration =
          crossfade.inMicroseconds / Duration.microsecondsPerSecond;
      leavingLayer = old;
    } else {
      leavingLayer = null;
    }
    layerPose = layer == null || clip == null
        ? null
        : LayerPose(
            layer,
            clip.index,
            clip.duration.inMicroseconds / Duration.microsecondsPerSecond,
            crossfade,
          );
    if (layerPose != null && layerBase.isEmpty) {
      final app = platform.appFor(getViewer()!);
      for (final entity in {asset.entity, ...await asset.getChildEntities()}) {
        layerBase[entity] = await app.getLocalTransform(entity);
      }
    }
    pendingConfiguration = true;
  }

  void setMotionActive(bool active) {
    if (lane.disposed) return;
    if (motionActive == active) return;
    motionActive = active;
    motionFrame = null;
    layerFrame = null;
    changed();
  }

  /// Schedules a motion reconfiguration for the next frame hook.
  Future<void> configureMotion() async {
    pendingConfiguration = true;
    requestPose();
  }

  /// Moves the primary animation out of Thermion's component update so its
  /// subsequent update cannot overwrite the pose produced by our frame hook.
  Future<void> _configureMotion() async {
    final asset = getAsset();
    final viewer = getViewer();
    if (asset == null || viewer == null || lane.disposed) return;
    final app = platform.appFor(viewer);
    if (lookBone != null && lookBase != null) {
      await app.setTransform(lookBone!, lookBase!);
    }
    final previousBone = lookBone;
    final nextBone = lookAt == null
        ? null
        : await asset.getChildEntity(lookAt!.bone);
    final returning = lookAt == null && gaze != (0.0, 0.0);
    if (!returning) {
      lookBone = nextBone;
      posedLookAt = lookAt;
      if (lookBone != previousBone || lookBone == null) {
        gaze = (0, 0);
        gazeSide = 0;
        motionFrame = clock.elapsed;
      }
    }
    lookBase = null;
    final driven =
        lookBone != null || layerPose != null || leavingLayer != null;
    if (!driven && layerBase.isNotEmpty) {
      for (final e in layerBase.entries) {
        await app.setTransform(e.key, e.value);
      }
      layerBase.clear();
    }
    if (driven != this.driven) {
      this.driven = driven;
      final index = playing;
      if (driven) {
        // An outgoing crossfade can still own another component. Stop all
        // primary clips so the post-hook animation update has no writer.
        for (final clip in clipTable.values) {
          await asset.stopGltfAnimation(clip.index);
        }
      } else if (index != null) {
        await asset.playGltfAnimation(
          index,
          loop: baseLoop,
          startOffset: basePosition(),
        );
      }
    }
    motionFrame ??= clock.elapsed;
    gazeMoving = lookBone != null;
  }

  double basePosition() {
    if (playing == null) return baseTime;
    final seconds =
        (clock.elapsed - baseBegan).inMicroseconds /
        Duration.microsecondsPerSecond;
    final clip = clipTable[playback.clip];
    final length =
        (clip?.duration.inMicroseconds ?? 0) / Duration.microsecondsPerSecond;
    if (length <= 0) return 0;
    return baseLoop ? seconds % length : seconds.clamp(0, length);
  }

  /// Runs on the native lane, always from a fresh animated local transform.
  Future<void> poseMotion(double dt, double layerDt) async {
    final asset = getAsset()!;
    final app = platform.appFor(getViewer()!);
    if (lookBone != null && lookBase != null) {
      await app.setTransform(lookBone!, lookBase!);
    }
    for (final e in layerBase.entries) {
      await app.setTransform(e.key, e.value);
    }
    final pose = this.pose;
    if (pose != null) {
      final index = clipTable[pose.$1]?.index;
      if (index != null) {
        await asset.setGltfAnimationTime(
          index,
          pose.$2.inMicroseconds / Duration.microsecondsPerSecond,
        );
      }
    } else if (baseIndex != null) {
      await asset.setGltfAnimationTime(baseIndex!, basePosition());
    }
    if (layerBase.isNotEmpty) {
      for (final entity in layerBase.keys.toList()) {
        layerBase[entity] = await app.getLocalTransform(entity);
      }
    }
    for (final layer in [leavingLayer, layerPose]) {
      if (layer == null) continue;
      layer.advance(layerDt);
      if (layer.weight > 0) {
        final before = <ThermionEntity, Matrix4>{};
        for (final entity in layerBase.keys) {
          before[entity] = await app.getLocalTransform(entity);
        }
        await asset.setGltfAnimationTime(layer.index, layer.position);
        if (layer.weight < 1) {
          for (final e in before.entries) {
            final after = await app.getLocalTransform(e.key);
            if (e.value != after) {
              await app.setTransform(
                e.key,
                _blendModelPose(e.value, after, layer.weight),
              );
            }
          }
        }
      }
      if (identical(layer, layerPose) &&
          !layer.model.loop &&
          layer.position >= layer.length &&
          !layer.reported) {
        layer.reported = true;
        _layerCompletions++;
        update(playback);
      }
    }
    if (leavingLayer?.weight == 0) leavingLayer = null;
    await writeMorphs(asset);
    final look = posedLookAt;
    final bone = lookBone;
    if (look != null && bone != null) {
      final local = await app.getLocalTransform(bone);
      lookBase = local.clone();
      Vector3 target;
      final point = look.point;
      if (look.target == Model3dLookAtTarget.pointer) {
        final size = (getBounds()!.max - getBounds()!.min).length / 2;
        final world = await app.getWorldTransform(bone);
        final yaw = getCamera().yaw * math.pi / 180;
        final pitch = getCamera().pitch.clamp(-89.0, 89.0) * math.pi / 180;
        final right = Vector3(math.cos(yaw), 0, -math.sin(yaw));
        final up = Vector3(
          -math.sin(pitch) * math.sin(yaw),
          math.cos(pitch),
          -math.sin(pitch) * math.cos(yaw),
        );
        final forward = up.cross(right);
        final position =
            getCameraPosition() ?? Vector3(0, 0, getDistance() ?? 1);
        final depth = (world.getTranslation() - position).dot(forward) - size;
        target =
            position +
            forward * depth +
            right * ((point?.$1 ?? 0) * size) +
            up * ((point?.$2 ?? 0) * size);
      } else if (look.target == Model3dLookAtTarget.point && point != null) {
        target = Vector3(point.$1, point.$2, point.$3);
      } else {
        target =
            getCameraPosition()?.clone() ?? Vector3(0, 0, getDistance() ?? 1);
      }
      final inverse = Matrix4.inverted(await app.getWorldTransform(bone));
      final direction = inverse.transform3(target);
      final weight = lookAt == null ? 0.0 : look.weight.clamp(0.0, 1.0);
      final rawYaw = math.atan2(direction.x, direction.z);
      // Keep a rear cone even at maxYaw 180 so atan2 cannot flip the held side.
      final limit = math.min(look.maxYaw, 170) * math.pi / 180;
      if (rawYaw.abs() <= limit || gazeSide == 0) {
        gazeSide = rawYaw.sign;
      }
      final yaw = (rawYaw.abs() > limit ? gazeSide * limit : rawYaw) * weight;
      final pitch =
          math
              .atan2(
                direction.y,
                math.sqrt(
                  direction.x * direction.x + direction.z * direction.z,
                ),
              )
              .clamp(
                -look.maxPitch * math.pi / 180,
                look.maxPitch * math.pi / 180,
              ) *
          weight;
      final duration =
          look.duration.inMicroseconds / Duration.microsecondsPerSecond;
      final response = duration <= 0 ? 1.0 : 1 - math.exp(-4 * dt / duration);
      final dy = yaw - gaze.$1;
      final dp = pitch - gaze.$2;
      final distance = math.sqrt(dy * dy + dp * dp);
      // Bound the combined angular change, including zero-duration requests.
      final step = math.min(distance * response, math.pi * math.max(0, dt));
      final fraction = distance == 0 ? 1.0 : step / distance;
      gaze = (gaze.$1 + dy * fraction, gaze.$2 + dp * fraction);
      gazeMoving = distance - step > 0.000001;
      if (!gazeMoving) gaze = (yaw, pitch);
      await app.setTransform(
        bone,
        local
          ..rotateY(gaze.$1)
          ..rotateX(-gaze.$2),
      );
      if (lookAt == null && !gazeMoving) {
        lookBone = null;
        lookBase = null;
        posedLookAt = null;
        gaze = (0, 0);
      }
    }
    if (driven &&
        lookBone == null &&
        layerPose == null &&
        leavingLayer == null) {
      await _configureMotion();
    }
    await app.animationManager.updateBoneMatrices(asset);
  }

  List<String> get clips => clipNames;

  Duration? clipDuration(String clip) => clipTable[clip]?.duration;

  void setPose(String clip, Duration time) {
    pose = (clip, time);
    final asset = getAsset();
    final index = clipTable[clip]?.index ?? -1;
    // A playing clip would overwrite the pose on its next frame.
    if (asset != null && index >= 0 && index == playing) {
      endPlay();
      lane.observe(lane.run(() => asset.stopGltfAnimation(index)));
    }
    requestPose();
  }

  Model3dPlayback get playback => _playback;

  Future<void> play(
    String clip, {
    required bool loop,
    Duration crossfade = Duration.zero,
  }) async {
    final run = ++this.run;
    clipEnd?.cancel();
    update(
      Model3dPlayback(
        clip: clip,
        isPlaying: true,
        completions: playback.completions,
      ),
    );
    final asset = getAsset();
    final index = clipTable[clip]?.index ?? -1;
    if (asset == null || index < 0) return;
    playing = index;
    baseIndex = index;
    baseLoop = loop;
    baseTime = 0;
    baseBegan = clock.elapsed;
    pose = null;
    changed();
    final double? seconds;
    try {
      seconds = await lane.run(() async {
        if (driven) {
          await asset.stopGltfAnimation(index);
          requestPose();
        } else {
          await asset.playGltfAnimation(
            index,
            loop: loop,
            crossfade:
                crossfade.inMicroseconds / Duration.microsecondsPerSecond,
          );
        }
        // Filament reports no end event: a non-looping clip ends after its
        // duration and holds its last frame.
        return loop ? null : await asset.getGltfAnimationDuration(index);
      });
    } on NativeDisposed {
      return;
    } catch (_) {
      if (run == this.run) endPlay();
      rethrow;
    }
    if (seconds == null || run != this.run) return;
    clipEnd = Timer(
      Duration(
        microseconds: (seconds * Duration.microsecondsPerSecond).round(),
      ),
      () {
        if (run != this.run) return;
        baseTime = seconds!;
        playing = null;
        if (driven) requestPose();
        changed();
        update(
          Model3dPlayback(
            clip: clip,
            isPlaying: false,
            completions: playback.completions + 1,
          ),
        );
      },
    );
  }

  Future<void> stop() async {
    final asset = getAsset();
    final index = clipTable[playback.clip]?.index ?? -1;
    endPlay();
    if (asset == null || index < 0) return;
    try {
      await lane.run(() => asset.stopGltfAnimation(index));
    } on NativeDisposed {
      return;
    }
    touch();
  }

  /// Ends the current play the moment it is superseded: its late native
  /// work and timer see a newer [run] and leave [playback] alone.
  void endPlay() {
    run++;
    clipEnd?.cancel();
    baseTime = basePosition();
    playing = null;
    changed();
    update(
      Model3dPlayback(
        clip: playback.clip,
        isPlaying: false,
        completions: playback.completions,
      ),
    );
  }

  bool get playingFrames => motionActive && playing != null;

  Future<void> loadClips(ThermionAsset asset) async {
    final names = await asset.getGltfAnimationNames();
    final loadedClips = <String, ({int index, Duration duration})>{};
    for (var i = 0; i < names.length; i++) {
      // glTF does not require unique names; a name plays its first clip.
      if (loadedClips.containsKey(names[i])) {
        debugPrint(
          '[sdui_model_filament] clip "${names[i]}" #$i ignored: '
          '"${names[i]}" is clip #${loadedClips[names[i]]!.index}',
        );
        continue;
      }
      loadedClips[names[i]] = (
        index: i,
        duration: Duration(
          microseconds:
              (await asset.getGltfAnimationDuration(i) *
                      Duration.microsecondsPerSecond)
                  .round(),
        ),
      );
    }
    clipTable = Map.unmodifiable(loadedClips);
    clipNames = List.unmodifiable(loadedClips.keys);
  }

  /// Called directly inside the facade's queued frame operation.
  Future<bool> frame(Duration now) async {
    if (!motionFrames) return false;
    final requested = pendingPose;
    pendingPose = false;
    final reset = pendingReset;
    pendingReset = null;
    if (reset != null) await reset();
    final crossfade = pendingLayer;
    pendingLayer = null;
    if (crossfade != null) await _configureLayer(crossfade);
    if (pendingConfiguration) {
      pendingConfiguration = false;
      await _configureMotion();
    }
    final last = motionFrame;
    final lastLayer = layerFrame;
    motionFrame = now;
    layerFrame = now;
    await poseMotion(
      last == null
          ? 0
          : math.max(
              0,
              (now - last).inMicroseconds / Duration.microsecondsPerSecond,
            ),
      lastLayer == null
          ? 0
          : math.max(
              0,
              (now - lastLayer).inMicroseconds / Duration.microsecondsPerSecond,
            ),
    );
    return requested && (pose != null || reset != null);
  }

  Future<void> cameraChanged() async {
    if (!driven || lane.disposed) return;
    gazeMoving = lookBone != null;
    requestPose();
  }

  void settleFrame() {
    if (!motionFrames) {
      motionFrame = null;
      layerFrame = null;
    }
    changed();
  }

  void invalidate() {
    run++;
    clipEnd?.cancel();
    _listeners.clear();
  }

  Future<void> resetForReuse(
    ThermionAsset asset,
    Map<ThermionEntity, Matrix4> transforms,
    PreparedModelAsset prepared,
  ) async {
    pendingReset = () => _resetForReuse(asset, transforms, prepared);
    requestPose();
  }

  Future<void> _resetForReuse(
    ThermionAsset asset,
    Map<ThermionEntity, Matrix4> transforms,
    PreparedModelAsset prepared,
  ) async {
    final app = platform.appFor(getViewer()!);
    for (final e in transforms.entries) {
      await app.setTransform(e.key, e.value);
    }
    final nodes = prepared.document['nodes'] as List? ?? const [];
    final meshes = prepared.document['meshes'] as List? ?? const [];
    final morphs = await asset.getMorphTargetSets();
    for (final set in morphs) {
      var index = -1;
      for (var i = 0; i < nodes.length; i++) {
        final name = (nodes[i] as Map)['name'] as String?;
        if (name != null && await asset.getChildEntity(name) == set.entity) {
          index = i;
          break;
        }
      }
      final node = index < 0 || index >= nodes.length
          ? null
          : nodes[index] as Map;
      final meshIndex = node?['mesh'];
      final mesh =
          meshIndex is int && meshIndex >= 0 && meshIndex < meshes.length
          ? meshes[meshIndex] as Map
          : null;
      final weights =
          (node?['weights'] ?? mesh?['weights']) as List? ?? const [];
      for (final target in set.targets) {
        await set.setWeightAt(
          target.index,
          target.index < weights.length
              ? (weights[target.index] as num).toDouble()
              : 0,
        );
      }
    }
  }

  Future<void> dispose(ThermionAsset asset) async {
    for (final clip in clipTable.values) {
      await asset.stopGltfAnimation(clip.index);
    }
  }

  void addListener(VoidCallback listener) => _listeners.add(listener);

  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void update(Model3dPlayback playback) {
    if (lane.disposed) return;
    _playback = playback;
    for (final listener in [..._listeners]) {
      listener();
    }
  }
}

/// Secondary pose cursor and its independent entrance/exit weight envelope.
final class LayerPose {
  LayerPose(this.model, this.index, this.length, Duration fade)
    : fadeDuration = fade.inMicroseconds / Duration.microsecondsPerSecond,
      weight = fade > Duration.zero ? 0 : model.weight,
      fadeFrom = fade > Duration.zero ? 0 : model.weight,
      fadeTo = model.weight;
  Model3dLayer model;
  final int index;
  final double length;
  double position = 0;
  double weight;
  double fadeFrom;
  double fadeTo;
  double fadeTime = 0;
  double fadeDuration;
  bool reported = false;
  bool get moving =>
      fadeTime < fadeDuration ||
      (model.loop && length > 0) ||
      position < length;

  void advance(double dt) {
    position += dt;
    position = length <= 0
        ? 0
        : model.loop
        ? position % length
        : position.clamp(0, length);
    fadeTime += dt;
    final t = fadeDuration <= 0
        ? 1.0
        : (fadeTime / fadeDuration).clamp(0.0, 1.0);
    final ease = 1 - (1 - t) * (1 - t);
    weight = fadeFrom + (fadeTo - fadeFrom) * ease;
  }
}

/// Interpolates the local transforms produced by successive clip evaluations.
/// This is not Thermion's clip crossfade: only node TRS channels are blended.
Matrix4 _blendModelPose(Matrix4 from, Matrix4 to, double t) {
  final a = Vector3.zero(), b = Vector3.zero();
  final sa = Vector3.zero(), sb = Vector3.zero();
  final qa = Quaternion.identity(), qb = Quaternion.identity();
  from.decompose(a, qa, sa);
  to.decompose(b, qb, sb);
  var dot = qa.x * qb.x + qa.y * qb.y + qa.z * qb.z + qa.w * qb.w;
  if (dot < 0) {
    qb.scale(-1);
    dot = -dot;
  }
  final angle = math.acos(dot.clamp(-1.0, 1.0));
  final sinAngle = math.sin(angle);
  final wa = sinAngle.abs() < 0.00001
      ? 1 - t
      : math.sin((1 - t) * angle) / sinAngle;
  final wb = sinAngle.abs() < 0.00001 ? t : math.sin(t * angle) / sinAngle;
  final q = Quaternion(
    qa.x * wa + qb.x * wb,
    qa.y * wa + qb.y * wb,
    qa.z * wa + qb.z * wb,
    qa.w * wa + qb.w * wb,
  )..normalize();
  return Matrix4.compose(a + (b - a) * t, q, sa + (sb - sa) * t);
}
