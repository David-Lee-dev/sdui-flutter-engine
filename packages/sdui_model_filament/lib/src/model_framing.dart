import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/widgets.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:thermion_flutter/thermion_flutter.dart' hide Texture, View;

import 'model_bounds.dart';
import 'native_lane.dart';

final class ModelFraming {
  ModelFraming({
    required this.lane,
    required this.getViewer,
    required this.getAsset,
    required this.touch,
  });
  final NativeLane lane;
  final ThermionViewer? Function() getViewer;
  final ThermionAsset? Function() getAsset;
  final VoidCallback touch;
  Vector3? cameraPosition;

  /// Camera distance that frames the model at zoom 1; set once the asset is
  /// loaded and the view's aspect is known.
  double? distance;
  bool placing = false;
  bool placeAgain = false;
  Aabb3? bounds;
  double? framedAspect;
  Model3dCamera camera = const Model3dCamera();

  Future<(Aabb3?, Object?, StackTrace?)> computeBounds(Uint8List bytes) async {
    final clock = Stopwatch()..start();
    try {
      return (await compute(modelBounds, bytes), null, null);
    } catch (error, stack) {
      if (error is FormatException || error is UnsupportedError) {
        debugPrint('[sdui_model_filament] Bounds fallback: $error');
        return (null, null, null);
      }
      return (null, error, stack);
    } finally {
      debugPrint(
        '[sdui_model_filament] Initial bounds took ${clock.elapsedMicroseconds / 1000}ms',
      );
    }
  }

  Future<void> resolveBounds(ThermionAsset asset, Aabb3? known) async {
    bounds = known;
    if (bounds != null) return;
    final native = await asset.getBoundingBox();
    final extent = native.max - native.min;
    final largest = math.max(extent.x, math.max(extent.y, extent.z));
    final normalized = extent * (largest > 0 ? 2 / largest : 1.0);
    await asset.transformToUnitCube();
    bounds = Aabb3.minMax(-normalized / 2, normalized / 2);
  }

  /// Sets the zoom-1 distance so the model fits the narrower field of
  /// view, then places the camera.
  Future<void> frame(double aspect) async {
    framedAspect = aspect;
    final viewer = getViewer();
    if (viewer == null || getAsset() == null || lane.disposed) return;
    distance = await lane.run(() async {
      final camera = await viewer.getActiveCamera();
      final focalLength = await camera.getFocalLength();
      // Filament's lens projection assumes a 24mm-tall sensor.
      final vertical = 2 * math.atan(12 / focalLength);
      final horizontal = 2 * math.atan(math.tan(vertical / 2) * aspect);
      final fov = math.min(vertical, horizontal);
      final extent = bounds!.max - bounds!.min;
      final diagonal = extent.length;
      final radius = diagonal.isFinite && diagonal > 0 ? diagonal / 2 : 1.0;
      return radius / math.sin(fov / 2);
    });
    await place();
  }

  /// Orbits the camera to [camera]. Calls arrive every frame while the
  /// camera moves; while one placement is in flight, later ones collapse
  /// into a single follow-up with the latest camera.
  Future<void> place() async {
    final viewer = getViewer();
    final distance = this.distance;
    if (viewer == null || distance == null || lane.disposed) return;
    if (placing) {
      placeAgain = true;
      return;
    }
    placing = true;
    try {
      do {
        placeAgain = false;
        final target = camera;
        final yaw = target.yaw * math.pi / 180;
        // Straight up or down has no defined "up" for lookAt.
        final pitch = target.pitch.clamp(-89.0, 89.0) * math.pi / 180;
        final zoom = target.zoom.isFinite && target.zoom > 0 ? target.zoom : 1;
        final d = distance / zoom;
        final bounds = this.bounds!;
        final extent = bounds.max - bounds.min;
        final largest = math.max(extent.x, math.max(extent.y, extent.z));
        final halfExtent = largest > 0 ? largest / 2 : 1.0;
        await lane.run(() async {
          final camera = await viewer.getActiveCamera();
          final focalLength = await camera.getFocalLength();
          final near = 0.1 * halfExtent;
          final far = math.max(
            100 * halfExtent,
            d + extent.length / 2 + halfExtent,
          );
          await camera.setLensProjection(
            near: near,
            far: math.max(far, near + halfExtent),
            aspect: framedAspect ?? 1,
            focalLength: focalLength,
          );
          final center = await resolveTarget(target.target);
          final size = extent.length.isFinite && extent.length > 0
              ? extent.length
              : 2.0;
          final right = Vector3(math.cos(yaw), 0, -math.sin(yaw));
          final up = Vector3(
            -math.sin(pitch) * math.sin(yaw),
            math.cos(pitch),
            -math.sin(pitch) * math.cos(yaw),
          );
          center.add(right * (-target.pan.dx * size));
          center.add(up * (target.pan.dy * size));
          cameraPosition =
              center +
              Vector3(
                d * math.cos(pitch) * math.sin(yaw),
                d * math.sin(pitch),
                d * math.cos(pitch) * math.cos(yaw),
              );
          await camera.lookAt(cameraPosition!, focus: center);
        });
        touch();
      } while (placeAgain && !lane.disposed);
    } finally {
      placing = false;
    }
  }

  /// Resolves weighted leaves on the native lane, so animated node transforms
  /// are sampled again instead of being baked into a previous transition.
  Future<Vector3> resolveTarget(Model3dTarget target) async {
    final center = (bounds!.min + bounds!.max) / 2;
    final resolved = Vector3.zero();
    for (final (leaf, weight) in target.weights) {
      var point = center;
      if (leaf.point case final pointValue?) {
        point = Vector3(pointValue.$1, pointValue.$2, pointValue.$3);
      } else if (leaf.node case final node?) {
        final entity = await getAsset()!.getChildEntity(node);
        if (entity != null) {
          point = (await getAsset()!.getWorldTransform(
            entity: entity,
          )).getTranslation();
        }
      }
      resolved.add(point * weight);
    }
    return resolved;
  }

  bool get tracksNode =>
      camera.target.weights.any((leaf) => leaf.$1.node != null);
}
