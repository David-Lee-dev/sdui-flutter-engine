import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:thermion_flutter/thermion_flutter.dart' hide Texture, View;

import 'filament_platform.dart';
import 'model_bytes.dart';
import 'model_glb.dart';
import 'model_look.dart' show srgbToLinear;
import 'native_lane.dart';

final class ModelOutfit {
  ModelOutfit({
    required this.lane,
    required this.platform,
    required this.getViewer,
    required this.getAsset,
    required this.touch,
    required this.getBounds,
    required this.models,
    required this.clock,
    required this.changed,
    required this.getLook,
  });
  final NativeLane lane;
  final FilamentPlatform platform;
  final ThermionViewer? Function() getViewer;
  final ThermionAsset? Function() getAsset;
  final VoidCallback touch;
  final Aabb3? Function() getBounds;
  final ModelBytesCache models;
  final Stopwatch clock;
  final VoidCallback changed;
  final Model3dLook Function() getLook;
  Model3dOutfit outfit = Model3dOutfit();
  Model3dOutfit? appliedOutfit;
  final outfitNodes = <String, OutfitNode>{};
  final outfitBindings = <OutfitNode>[];
  final outfitProps = <String, OutfitProp>{};
  final ownedOutfitProps = <OutfitProp>{};
  final outfitTransitions = <OutfitTransition>[];

  void setOutfit(Model3dOutfit outfit) {
    if (lane.disposed) return;
    this.outfit = outfit;
    lane.observe(reconcileOutfit());
  }

  Future<List<OutfitNode>> bindOutfitAsset(
    ThermionAsset asset,
    PreparedModelAsset prepared,
  ) async {
    final bindings = await bindOutfitNodes(asset, prepared);
    outfitBindings.addAll(bindings);
    for (var i = 0; i < bindings.length; i++) {
      final name = prepared.names[i];
      if (name != null) outfitNodes.putIfAbsent(name, () => bindings[i]);
    }
    return bindings;
  }

  Future<List<OutfitNode>> bindOutfitNodes(
    ThermionAsset asset,
    PreparedModelAsset prepared,
  ) async {
    final bindings = <OutfitNode>[];
    final app = platform.appFor(getViewer()!);
    final nodes = prepared.document['nodes'] as List? ?? const [];
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i] as Map;
      final entity = await asset.getChildEntity(node['name'] as String);
      final binding = OutfitNode(entity, node);
      final meshes = prepared.document['meshes'] as List? ?? const [];
      final materials = prepared.document['materials'] as List? ?? const [];
      final mesh = node['mesh'];
      if (entity != null && mesh is int && mesh < meshes.length) {
        final primitives =
            (meshes[mesh] as Map)['primitives'] as List? ?? const [];
        for (var primitive = 0; primitive < primitives.length; primitive++) {
          final index = (primitives[primitive] as Map)['material'];
          final metadata =
              index is int && index >= 0 && index < materials.length
              ? materials[index] as Map
              : const <String, dynamic>{};
          final material = await app.renderableManager.getMaterialInstanceAt(
            entity,
            primitive,
          );
          if (material == null) continue;
          final pbr = metadata['pbrMetallicRoughness'] as Map?;
          final factor =
              (pbr?['baseColorFactor'] as List? ?? const [1, 1, 1, 1])
                  .map((v) => (v as num).toDouble())
                  .toList();
          final extensions = metadata['extensions'] as Map?;
          final emissive =
              extensions?['KHR_materials_emissive_strength'] as Map?;
          final strength =
              (emissive?['emissiveStrength'] as num?)?.toDouble() ?? 1;
          binding.materials.add(
            OutfitMaterial(
              material,
              metadata['name'] as String?,
              factor,
              metadata['alphaMode'] == 'BLEND',
              (metadata['emissiveFactor'] as List? ?? const [0, 0, 0])
                  .map((v) => (v as num).toDouble())
                  .toList(),
              strength,
            ),
          );
        }
      }
      bindings.add(binding);
    }
    return bindings;
  }

  Future<void> reconcileOutfit() async {
    final viewer = getViewer();
    if (getAsset() == null || viewer == null || lane.disposed) return;
    await lane.run(() async {
      final target = outfit;
      if (target == appliedOutfit) return;
      // An interrupted request settles its previous exact target before the new
      // snapshot is reconciled; delayed prop loads still check slot identity.
      for (final transition in [...outfitTransitions]) {
        await transition.apply(1);
        await transition.finish();
        outfitTransitions.remove(transition);
      }
      final animate =
          appliedOutfit != null &&
          target.transition != Model3dOutfitTransition.cut &&
          target.duration > Duration.zero;
      final scene = await viewer.view.getScene();
      for (final name in {...target.hide, ...target.show}) {
        if (!outfitNodes.containsKey(name)) {
          debugPrint('[sdui_model_filament] outfit node "$name" ignored');
        }
      }
      final desired = <OutfitNode, bool>{};
      final overrides = <OutfitNode, bool>{};
      for (final name in target.hide) {
        final node = outfitNodes[name];
        if (node != null) overrides[node] = false;
      }
      for (final name in target.show) {
        final node = outfitNodes[name];
        if (node != null) overrides[node] = true;
      }
      final children = <int>{
        for (final node in outfitBindings)
          for (final index in node.metadata['children'] as List? ?? const [])
            if (index is int) index,
      };
      void visit(OutfitNode node, bool? inherited) {
        final shown = overrides[node] ?? inherited;
        if (shown != null) desired[node] = shown;
        for (final index in node.metadata['children'] as List? ?? const []) {
          if (index is int && index >= 0 && index < outfitBindings.length) {
            visit(outfitBindings[index], shown);
          }
        }
      }

      for (var i = 0; i < outfitBindings.length; i++) {
        if (!children.contains(i)) visit(outfitBindings[i], null);
      }
      final pulse =
          animate &&
          outfitBindings.any((node) {
            final changed = (desired[node] ?? true) != node.shown;
            final dissolves =
                target.transition == Model3dOutfitTransition.dissolve &&
                node.materials.isNotEmpty &&
                node.materials.every((m) => m.blend);
            return changed && node.metadata['skin'] != null && !dissolves;
          });
      final rootTransition = pulse ? await pulseOutfitRoot(target) : null;
      for (final node in outfitBindings) {
        final shown = desired[node] ?? true;
        final changed = shown != node.shown;
        if (node.entity == null || node.metadata['mesh'] == null) continue;
        if (changed && shown) await scene.addEntity(node.entity!);
        await transitionOutfitPart(
          node.entity!,
          node.materials,
          changed ? shown : null,
          target,
          animate,
          () async {
            if (changed && !shown) await scene.removeEntity(node.entity!);
          },
          skinned: node.metadata['skin'] != null,
        );
        node.shown = shown;
      }
      if (rootTransition != null) {
        // Restore part parents before removing the hierarchy they animate under.
        outfitTransitions.add(
          OutfitTransition(
            clock.elapsed,
            target.duration,
            rootTransition.apply,
            rootTransition.finish,
          ),
        );
      }
      for (final entry in [...outfitProps.entries]) {
        if (target.attach[entry.key] == entry.value.src) {
          final slot = entry.value;
          if (slot.placement != null) {
            await transitionOutfitPart(
              slot.placement!,
              slot.materials,
              null,
              target,
              animate,
              () async {},
            );
          }
          continue;
        }
        outfitProps.remove(entry.key);
        final slot = entry.value;
        if (slot.placement == null) {
          await releaseOutfitProp(viewer, slot);
        } else {
          await transitionOutfitPart(
            slot.placement!,
            slot.materials,
            false,
            target,
            animate,
            () => releaseOutfitProp(viewer, slot),
          );
        }
      }
      for (final entry in target.attach.entries) {
        final src = entry.value;
        if (src == null || outfitProps.containsKey(entry.key)) continue;
        final node = outfitNodes[entry.key];
        if (node?.entity == null) {
          debugPrint(
            '[sdui_model_filament] outfit socket "${entry.key}" ignored',
          );
          continue;
        }
        final slot = OutfitProp(entry.key, src, node!.entity!, animate);
        outfitProps[entry.key] = slot;
        lane.observe(loadOutfitProp(slot));
      }
      logUnknownOutfitMaterials(target);
      appliedOutfit = target;
      changed();
      touch();
    });
  }

  bool currentOutfitProp(OutfitProp slot) =>
      !lane.disposed && identical(outfitProps[slot.name], slot);

  void logUnknownOutfitMaterials(Model3dOutfit target) {
    if (outfitProps.values.any((slot) => slot.loading)) return;
    final known = {
      for (final node in outfitBindings)
        for (final material in node.materials) material.name,
      for (final prop in outfitProps.values)
        for (final material in prop.materials) material.name,
    };
    for (final name in target.colors.keys) {
      if (!known.contains(name)) {
        debugPrint('[sdui_model_filament] outfit material "$name" ignored');
      }
    }
  }

  Future<void> loadOutfitProp(OutfitProp slot) async {
    final viewer = getViewer()!;
    try {
      final bytes = await models.load(slot.src);
      if (!currentOutfitProp(slot)) return;
      await lane.run(() async {
        if (!currentOutfitProp(slot)) return;
        final prepared = PreparedModelAsset.read(bytes);
        slot.asset = await viewer.loadGltfFromBuffer(prepared.bytes);
        ownedOutfitProps.add(slot);
        if (!currentOutfitProp(slot)) {
          await releaseOutfitProp(viewer, slot);
          return;
        }
        final bindings = await bindOutfitNodes(slot.asset!, prepared);
        slot.materials.addAll([for (final node in bindings) ...node.materials]);
        if (!currentOutfitProp(slot)) {
          await releaseOutfitProp(viewer, slot);
          return;
        }
        final app = platform.appFor(viewer);
        slot.placement = await app.createEntity();
        await app.setParent(slot.placement!, slot.socket);
        final asset = slot.asset!;
        final entities = {asset.entity, ...await asset.getChildEntities()};
        for (final entity in entities) {
          final parent = await app.getParent(entity);
          if (parent == null || !entities.contains(parent)) {
            await app.setParent(entity, slot.placement);
          }
        }
        final casts =
            getLook().shadow.type == Model3dShadowType.cast &&
            getLook().light != null;
        await asset.setCastShadows(casts);
        await asset.setReceiveShadows(casts);
        if (!currentOutfitProp(slot)) {
          await releaseOutfitProp(viewer, slot);
          return;
        }
        await transitionOutfitPart(
          slot.placement!,
          slot.materials,
          true,
          outfit,
          slot.animate &&
              outfit.transition != Model3dOutfitTransition.cut &&
              outfit.duration > Duration.zero,
          () async {},
        );
        changed();
        touch();
      });
    } catch (error) {
      if (error is NativeDisposed) return;
      debugPrint(
        '[sdui_model_filament] outfit prop "${slot.src}" skipped: $error',
      );
      if (!lane.disposed) await lane.run(() => releaseOutfitProp(viewer, slot));
    } finally {
      slot.loading = false;
      if (currentOutfitProp(slot)) logUnknownOutfitMaterials(outfit);
    }
  }

  Future<void> releaseOutfitProp(ThermionViewer viewer, OutfitProp slot) async {
    final asset = slot.asset;
    final placement = slot.placement;
    slot.asset = null;
    slot.placement = null;
    try {
      if (asset != null) {
        await viewer.destroyAsset(asset);
      }
    } finally {
      if (placement != null) {
        await platform.appFor(viewer).destroyEntity(placement);
      }
      ownedOutfitProps.remove(slot);
    }
  }

  /// Moves the whole primary hierarchy, including skin joints, once per swap.
  Future<OutfitTransition> pulseOutfitRoot(Model3dOutfit target) async {
    final app = platform.appFor(getViewer()!);
    final asset = getAsset()!;
    final entities = {asset.entity, ...await asset.getChildEntities()};
    final roots = <ThermionEntity, ThermionEntity?>{};
    final placement = await app.createEntity();
    for (final entity in entities) {
      final parent = await app.getParent(entity);
      if (parent == null || !entities.contains(parent)) {
        roots[entity] = parent;
        await app.setParent(entity, placement);
      }
    }
    Future<void> apply(double t) async {
      final scale = 1 + 0.04 * math.sin(math.pi * t);
      await app.setTransform(
        placement,
        Matrix4.diagonal3Values(scale, scale, scale),
      );
    }

    await apply(0);
    return OutfitTransition(clock.elapsed, target.duration, apply, () async {
      for (final entry in roots.entries) {
        await app.setParent(entry.key, entry.value);
      }
      await app.destroyEntity(placement);
    });
  }

  /// Rigid parts use placement parents; skinned parts pulse isolated emissive.
  Future<void> transitionOutfitPart(
    ThermionEntity entity,
    List<OutfitMaterial> materials,
    bool? entering,
    Model3dOutfit target,
    bool animate,
    Future<void> Function() finish, {
    bool skinned = false,
  }) async {
    final from = [
      for (final material in materials) List<double>.of(material.color),
    ];
    final to = [
      for (final material in materials)
        if (target.colors[material.name] case final color?)
          [
            srgbToLinear(color.r),
            srgbToLinear(color.g),
            srgbToLinear(color.b),
            color.a,
          ]
        else
          material.authored,
    ];
    final recolors = List.generate(
      materials.length,
      (i) => !listEquals(from[i], to[i]),
    ).any((v) => v);
    if (!animate || entering == null && !recolors) {
      for (var i = 0; i < materials.length; i++) {
        await materials[i].setColor(to[i]);
      }
      await finish();
      return;
    }
    final app = platform.appFor(getViewer()!);
    final dissolve =
        entering != null &&
        target.transition == Model3dOutfitTransition.dissolve &&
        materials.isNotEmpty &&
        materials.every((m) => m.blend);
    final flash = entering != null && skinned && !dissolve;
    ThermionEntity? placement;
    ThermionEntity? parent;
    if (entering != null && !dissolve && !flash) {
      parent = await app.getParent(entity);
      placement = await app.createEntity();
      await app.setParent(placement, parent);
      await app.setParent(entity, placement);
    }
    Future<void> apply(double t) async {
      final eased = 1 - math.pow(1 - t, 3).toDouble();
      for (var i = 0; i < materials.length; i++) {
        final color = List<double>.generate(
          4,
          (c) => from[i][c] + (to[i][c] - from[i][c]) * eased,
        );
        if (dissolve) color[3] *= entering ? eased : 1 - eased;
        await materials[i].setColor(color);
        if (flash) {
          await materials[i].setEmissive(math.sin(math.pi * t));
        }
      }
      if (placement != null) {
        final matrix = Matrix4.identity();
        double scale = 1;
        if (entering == false) {
          scale = 1 - eased;
        } else if (target.transition == Model3dOutfitTransition.drop) {
          final height = getBounds() == null
              ? 1.0
              : (getBounds()!.max.y - getBounds()!.min.y).abs();
          final offset = Vector3(
            0,
            height * ((1 - eased) - 0.08 * math.sin(math.pi * t)),
            0,
          );
          if (parent != null) {
            // The fall is world-up even under scaled or rotated bone chains.
            final inverse = await app.getWorldTransform(parent);
            if (inverse.invert() != 0) {
              inverse.rotate3(offset);
            } else {
              offset.setZero();
            }
          }
          matrix.setTranslation(offset);
        } else {
          const overshoot = 1.70158;
          final u = t - 1;
          scale = 1 + (overshoot + 1) * u * u * u + overshoot * u * u;
        }
        matrix.scaleByDouble(scale, scale, scale, 1);
        await app.setTransform(placement!, matrix);
      }
    }

    final transition = OutfitTransition(
      clock.elapsed,
      target.duration,
      apply,
      () async {
        if (placement != null) {
          await app.setParent(entity, parent);
          await app.destroyEntity(placement!);
        }
        for (var i = 0; i < materials.length; i++) {
          await materials[i].setColor(to[i]);
          if (flash) await materials[i].setEmissive(0);
        }
        await finish();
      },
    );
    outfitTransitions.add(transition);
    await apply(0);
  }

  bool get needsFrames => outfitTransitions.isNotEmpty;
  Iterable<ThermionAsset> get assets => [
    for (final slot in ownedOutfitProps)
      if (slot.asset != null) slot.asset!,
  ];

  Future<void> resetForReuse() async {
    final scene = await getViewer()!.view.getScene();
    for (final binding in outfitBindings) {
      if (binding.entity == null) continue;
      if (binding.metadata['mesh'] != null) {
        await scene.addEntity(binding.entity!);
      }
      for (final material in binding.materials) {
        await material.setColor(material.authored);
        await material.setEmissive(0);
      }
    }
  }

  Future<void> dispose(ThermionViewer viewer) async {
    for (final transition in [...outfitTransitions]) {
      await transition.finish();
    }
    outfitTransitions.clear();
    for (final slot in [...ownedOutfitProps]) {
      await releaseOutfitProp(viewer, slot);
    }
    outfitProps.clear();
  }

  Future<void> advanceOutfit(Duration elapsed) async {
    for (final transition in [...outfitTransitions]) {
      final t =
          ((elapsed - transition.started).inMicroseconds /
                  transition.duration.inMicroseconds)
              .clamp(0.0, 1.0);
      await transition.apply(t);
      if (t >= 1) {
        await transition.finish();
        outfitTransitions.remove(transition);
      }
    }
    changed();
  }
}

final class OutfitNode {
  OutfitNode(this.entity, this.metadata);
  final ThermionEntity? entity;
  final Map metadata;
  bool shown = true;
  final materials = <OutfitMaterial>[];
}

final class OutfitTransition {
  OutfitTransition(this.started, this.duration, this.apply, this.finish);
  final Duration started;
  final Duration duration;
  final Future<void> Function(double) apply;
  final Future<void> Function() finish;
}

final class OutfitProp {
  OutfitProp(this.name, this.src, this.socket, this.animate);
  final bool animate;
  bool loading = true;
  final materials = <OutfitMaterial>[];
  final String name;
  final String src;
  final ThermionEntity socket;
  ThermionAsset? asset;
  ThermionEntity? placement;
}

final class OutfitMaterial {
  OutfitMaterial(
    this.original,
    this.name,
    this.authored,
    this.blend,
    this.emissive,
    this.emissiveStrength,
  ) : color = List.of(authored);
  final MaterialInstance original;
  final String? name;
  final List<double> authored;
  final bool blend;
  final List<double> emissive;
  final double emissiveStrength;
  List<double> color;
  Future<void> setEmissive(double pulse) async {
    await original.setParameterFloat4(
      'emissiveFactor',
      emissive[0] + pulse,
      emissive[1] + pulse,
      emissive[2] + pulse,
      emissiveStrength,
    );
  }

  Future<void> setColor(List<double> value) async {
    await original.setParameterFloat4(
      'baseColorFactor',
      value[0],
      value[1],
      value[2],
      value[3],
    );
    color = List.of(value);
  }
}
