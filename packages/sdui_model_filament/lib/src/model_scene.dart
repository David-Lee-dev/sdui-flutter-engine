import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:thermion_flutter/thermion_flutter.dart' hide Texture, View;

import 'filament_platform.dart';
import 'model_bytes.dart';
import 'model_glb.dart';
import 'native_lane.dart';

final class ModelScene {
  ModelScene({
    required this.lane,
    required this.platform,
    required this.getViewer,
    required this.getAsset,
    required this.touch,
    required this.models,
    required this.changed,
    required this.getLook,
  });
  final NativeLane lane;
  final FilamentPlatform platform;
  final ThermionViewer? Function() getViewer;
  final ThermionAsset? Function() getAsset;
  final VoidCallback touch;
  final ModelBytesCache models;
  final VoidCallback changed;
  final Model3dLook Function() getLook;
  List<SceneSlot> scene = [];
  final ownedSlots = <SceneSlot>{};
  bool sceneActive = true;

  void setScene(List<Model3dSceneItem> scene, {bool active = true}) {
    if (lane.disposed) return;
    final previous = this.scene;
    sceneActive = active;
    this.scene = [
      for (var i = 0; i < scene.length; i++)
        if (i < previous.length && previous[i].item.src == scene[i].src)
          previous[i]..item = scene[i]
        else
          SceneSlot(scene[i]),
    ];
    final viewer = getViewer();
    if (viewer != null) {
      for (final slot in previous) {
        if (!this.scene.contains(slot)) {
          lane.observe(lane.run(() => releaseExtra(viewer, slot)));
        }
      }
    }
    reconcileScene();
    changed();
  }

  bool currentSlot(SceneSlot slot) => !lane.disposed && scene.contains(slot);

  void reconcileScene() {
    if (getAsset() == null || lane.disposed) return;
    for (final slot in scene) {
      if (slot.asset != null) {
        lane.observe(lane.run(() => applyExtra(slot)));
      } else if (!slot.loading) {
        slot.loading = true;
        lane.observe(loadExtra(slot));
      }
    }
  }

  Future<void> loadExtra(SceneSlot slot) async {
    final viewer = getViewer()!;
    try {
      final bytes = await models.load(slot.item.src);
      if (!currentSlot(slot)) return;
      await lane.run(() async {
        if (!currentSlot(slot)) return;
        final prepared = PreparedModelAsset.read(bytes);
        slot.asset = await viewer.loadGltfFromBuffer(prepared.bytes);
        ownedSlots.add(slot);
        if (!currentSlot(slot)) {
          await releaseExtra(viewer, slot);
          return;
        }
        final app = platform.appFor(viewer);
        slot.placement = await app.createEntity();
        final asset = slot.asset!;
        // Some glTF assets have a synthetic root. Attach all actual roots,
        // keeping every authored local transform beneath the placement.
        final entities = {asset.entity, ...await asset.getChildEntities()};
        for (final entity in entities) {
          final parent = await app.getParent(entity);
          if (parent == null || !entities.contains(parent)) {
            await app.setParent(entity, slot.placement);
          }
        }
        slot.clips = await asset.getGltfAnimationNames();
        final casts =
            getLook().shadow.type == Model3dShadowType.cast &&
            getLook().light != null;
        await asset.setCastShadows(casts);
        await asset.setReceiveShadows(casts);
        if (!currentSlot(slot)) {
          await releaseExtra(viewer, slot);
          return;
        }
        await applyExtra(slot);
      });
    } catch (error) {
      if (error is! NativeDisposed) {
        debugPrint(
          '[sdui_model_filament] scene "${slot.item.src}" skipped: $error',
        );
        if (!lane.disposed) await lane.run(() => releaseExtra(viewer, slot));
      }
    }
  }

  /// Applies current slot values on the native lane; byte loads remain separate.
  Future<void> applyExtra(SceneSlot slot) async {
    final viewer = getViewer();
    final asset = slot.asset;
    if (!currentSlot(slot) ||
        viewer == null ||
        asset == null ||
        slot.placement == null) {
      return;
    }
    final item = slot.item;
    final wanted = sceneActive && item.clip != null
        ? slot.clips.indexOf(item.clip!)
        : -1;
    if (slot.playingClip != (wanted >= 0 ? wanted : null)) {
      if (slot.playingClip != null) {
        await asset.stopGltfAnimation(slot.playingClip!);
      }
      slot.playingClip = null;
      if (wanted >= 0) {
        await asset.playGltfAnimation(wanted, loop: true);
        slot.playingClip = wanted;
      }
    }
    final rotation = item.rotation;
    final matrix =
        Matrix4.translationValues(
            item.position.$1,
            item.position.$2,
            item.position.$3,
          )
          ..rotateY(rotation.yaw * math.pi / 180)
          ..rotateX(rotation.pitch * math.pi / 180)
          ..rotateZ(rotation.roll * math.pi / 180)
          ..scaleByDouble(item.scale, item.scale, item.scale, 1);
    switch (item.spin?.axis) {
      case 'x':
        matrix.rotateX(slot.angle);
      case 'y':
        matrix.rotateY(slot.angle);
      case 'z':
        matrix.rotateZ(slot.angle);
    }
    await platform.appFor(viewer).setTransform(slot.placement!, matrix);
    changed();
    touch();
  }

  Future<void> releaseExtra(ThermionViewer viewer, SceneSlot slot) async {
    final asset = slot.asset;
    final placement = slot.placement;
    slot.asset = null;
    slot.placement = null;
    slot.playingClip = null;
    try {
      if (asset != null) {
        await viewer.destroyAsset(asset);
      }
    } finally {
      if (placement != null) {
        await platform.appFor(viewer).destroyEntity(placement);
      }
      ownedSlots.remove(slot);
    }
    changed();
  }

  bool get playingFrames =>
      sceneActive && scene.any((slot) => slot.playingClip != null);
  Iterable<ThermionAsset> get assets => [
    for (final slot in scene)
      if (slot.asset != null) slot.asset!,
  ];

  /// Called directly inside the facade's queued frame operation.
  Future<void> frame(double dt) async {
    for (final slot in scene) {
      final speed = slot.item.spin?.speed ?? 0;
      if (slot.placement == null || speed == 0 || !sceneActive) {
        continue;
      }
      slot.angle = (slot.angle + speed * dt * math.pi / 180) % (2 * math.pi);
      await applyExtra(slot);
    }
  }

  Future<void> dispose(ThermionViewer viewer) async {
    for (final slot in [...ownedSlots]) {
      await releaseExtra(viewer, slot);
    }
    scene = [];
  }

  bool get spinning =>
      sceneActive &&
      scene.any(
        (slot) => slot.placement != null && (slot.item.spin?.speed ?? 0) != 0,
      );
}

/// One independently replaceable extra. Native ownership outlives slot removal
/// until its queued cleanup finishes.
final class SceneSlot {
  SceneSlot(this.item);
  Model3dSceneItem item;
  ThermionAsset? asset;
  ThermionEntity? placement;
  List<String> clips = const [];
  int? playingClip;
  bool loading = false;
  double angle = 0;
}
