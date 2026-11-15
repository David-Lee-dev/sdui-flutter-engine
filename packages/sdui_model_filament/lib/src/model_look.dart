import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:thermion_flutter/thermion_flutter.dart'
    as thermion
    show Texture;
import 'package:thermion_flutter/thermion_flutter.dart' hide Texture, View;

import 'filament_platform.dart';
import 'native_lane.dart';

final class ModelLook {
  ModelLook({
    required this.lane,
    required this.platform,
    required this.getViewer,
    required this.getAsset,
    required this.touch,
    required this.getBounds,
    required this.iblIntensity,
    required this.extraAssets,
  });
  final NativeLane lane;
  final FilamentPlatform platform;
  final ThermionViewer? Function() getViewer;
  final ThermionAsset? Function() getAsset;
  final VoidCallback touch;
  final Aabb3? Function() getBounds;
  final double iblIntensity;
  final Iterable<ThermionAsset> Function() extraAssets;
  Model3dLook look = const Model3dLook();
  Model3dLook appliedLook = const Model3dLook();
  bool looking = false;
  bool lookAgain = false;
  ThermionEntity? light;
  ColorGrading? grading;
  ThermionAsset? contact;
  MaterialInstance? contactMaterial;
  thermion.Texture? contactTexture;
  TextureSampler? contactSampler;

  void setLook(Model3dLook look) {
    if (lane.disposed) return;
    this.look = look;
    lane.observe(applyLook());
  }

  /// Serializes look changes with model work, collapsing in-flight updates.
  Future<void> applyLook() async {
    final viewer = getViewer();
    if (getAsset() == null || viewer == null || lane.disposed) return;
    if (looking) {
      lookAgain = true;
      return;
    }
    looking = true;
    try {
      do {
        lookAgain = false;
        final target = look;
        if (target == appliedLook) continue;
        await lane.run(() => writeLook(target));
        touch();
      } while (lookAgain && !lane.disposed);
    } finally {
      looking = false;
    }
  }

  /// Direct native work, also used by reuse while already on the lane.
  Future<void> writeLook(Model3dLook target, {bool force = false}) async {
    final viewer = getViewer()!;
    final previous = appliedLook;
    final environmentChanged =
        force || target.environment != previous.environment;
    if (environmentChanged) {
      await viewer.loadIbl(
        studioIblAsset,
        intensity: iblIntensity * target.environment,
      );
    }
    if (environmentChanged ||
        target.environmentRotation != previous.environmentRotation) {
      await viewer.rotateIbl(
        Matrix3.rotationY(target.environmentRotation * math.pi / 180),
      );
    }
    final casts =
        target.shadow.type == Model3dShadowType.cast && target.light != null;
    final castBefore =
        previous.shadow.type == Model3dShadowType.cast &&
        previous.light != null;
    if (force || casts != castBefore) {
      await viewer.setShadowsEnabled(casts);
      await getAsset()?.setCastShadows(casts);
      await getAsset()?.setReceiveShadows(casts);
      for (final asset in extraAssets()) {
        await asset.setCastShadows(casts);
        await asset.setReceiveShadows(casts);
      }
    }
    if (target.shadow.type != Model3dShadowType.none) {
      await ensureContactShadow(viewer);
    }
    if (contactMaterial != null &&
        (force || target.shadow != previous.shadow)) {
      await contactMaterial!.setParameterFloat4(
        'baseColorFactor',
        1,
        1,
        1,
        target.shadow.type == Model3dShadowType.none
            ? 0
            : target.shadow.opacity,
      );
    }
    if (force || target.light != previous.light || casts != castBefore) {
      if (this.light != null) {
        await viewer.removeLight(this.light!);
        this.light = null;
      }
      final light = target.light;
      if (light != null) {
        final yaw = light.yaw * math.pi / 180;
        final pitch = light.pitch * math.pi / 180;
        this.light = await viewer.addDirectLight(
          DirectLight.sun(
            direction: Vector3(
              -math.cos(pitch) * math.sin(yaw),
              -math.sin(pitch),
              -math.cos(pitch) * math.cos(yaw),
            ),
            intensity: 100000 * light.intensity,
            color: LinearColor(
              srgbToLinear(light.color.r),
              srgbToLinear(light.color.g),
              srgbToLinear(light.color.b),
            ),
            castShadows: casts,
          ),
        );
      }
    }
    if (force || target.quality != previous.quality) {
      final high = target.quality == Model3dQuality.high;
      await viewer.view.setAntiAliasing(high, true, false);
      await viewer.view.setRenderQuality(switch (target.quality) {
        Model3dQuality.low => QualityLevel.LOW,
        Model3dQuality.medium => QualityLevel.MEDIUM,
        Model3dQuality.high => QualityLevel.HIGH,
      });
      await viewer.view.setAmbientOcclusionOptions(
        AmbientOcclusionOptions(enabled: high),
      );
      await viewer.setShadowType(high ? ShadowType.PCSS : ShadowType.PCF);
    }
    if (target.exposure != previous.exposure || (force && grading != null)) {
      ColorGrading? next;
      if (target.exposure != 0) {
        final builder = await viewer.view.createColorGradingBuilder();
        try {
          next = await builder.exposure(target.exposure).build();
        } finally {
          await builder.dispose();
        }
      }
      try {
        await viewer.view.setColorGrading(next);
      } catch (_) {
        await next?.dispose();
        rethrow;
      }
      final old = grading;
      grading = next;
      await old?.dispose();
    }
    appliedLook = target;
  }

  Future<void> resetDefaults() async {
    final viewer = getViewer()!;
    await viewer.setBackgroundColor(0, 0, 0, 0);
    await viewer.view.setBlendMode(BlendMode.transparent);
    await viewer.setPostProcessing(true);
    await writeLook(const Model3dLook(), force: true);
  }

  Future<void> dispose(ThermionViewer viewer) async {
    try {
      if (light != null) {
        await viewer.removeLight(light!);
        light = null;
      }
    } finally {
      try {
        await releaseContact(viewer);
      } finally {
        if (grading != null) {
          await viewer.view.setColorGrading(null);
          await grading!.dispose();
          grading = null;
        }
      }
    }
  }

  /// Creates the unlit ground ellipse once; all allocations stay on the lane.
  Future<void> ensureContactShadow(ThermionViewer viewer) async {
    if (contact != null) return;
    final app = platform.appFor(viewer);
    try {
      contactMaterial = await app.createUbershaderMaterialInstance(
        unlit: true,
        doubleSided: true,
        alphaMode: AlphaMode.BLEND,
        hasBaseColorTexture: true,
        baseColorUV: 0,
      );
      final bytes = await rootBundle.load(
        'packages/sdui_model_filament/assets/contact_shadow.png',
      );
      final image = await app.decodeImage(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        requireAlpha: true,
      );
      try {
        contactTexture = await app.createTexture(
          await image.getWidth(),
          await image.getHeight(),
          textureFormat: TextureFormat.RGBA32F,
          flags: {
            TextureUsage.TEXTURE_USAGE_SAMPLEABLE,
            TextureUsage.TEXTURE_USAGE_UPLOADABLE,
          },
        );
        await contactTexture!.setLinearImage(
          image,
          PixelDataFormat.RGBA,
          PixelDataType.FLOAT,
        );
      } finally {
        await image.destroy();
      }
      contactSampler = await app.createTextureSampler();
      await contactMaterial!.setParameterTexture(
        'baseColorMap',
        contactTexture!,
        contactSampler!,
      );
      await contactMaterial!.setParameterInt('baseColorIndex', 0);
      await contactMaterial!.setParameterFloat4('baseColorFactor', 1, 1, 1, 0);
      final bounds = getBounds()!;
      final extent = bounds.max - bounds.min;
      final center = (bounds.min + bounds.max) / 2;
      final largest = math.max(extent.x, math.max(extent.y, extent.z));
      final halfExtent = largest > 0 ? largest / 2 : 1.0;
      contact = await viewer.createGeometry(
        GeometryUtils.plane(
          width: math.max(extent.x * 1.2, 0.2 * halfExtent),
          height: math.max(extent.z * 1.2, 0.2 * halfExtent),
        ),
        materialInstances: [contactMaterial!],
      );
      await contact!.setCastShadows(false);
      await contact!.setReceiveShadows(false);
      await contact!.setTransform(
        Matrix4.translationValues(
          center.x,
          bounds.min.y + 0.001 * halfExtent,
          center.z,
        ),
      );
    } catch (_) {
      await releaseContact(viewer);
      rethrow;
    }
  }

  Future<void> releaseContact(ThermionViewer viewer) async {
    final contact = this.contact;
    final material = contactMaterial;
    final texture = contactTexture;
    final sampler = contactSampler;
    this.contact = null;
    contactMaterial = null;
    contactTexture = null;
    contactSampler = null;
    (Object, StackTrace)? failure;
    for (final release in <Future<void> Function()>[
      if (contact != null)
        () async {
          await viewer.destroyAsset(contact);
        },
      if (material != null)
        () async {
          await material.destroy();
        },
      if (texture != null)
        () async {
          await texture.destroy();
        },
      if (sampler != null)
        () async {
          await sampler.dispose();
        },
    ]) {
      try {
        await release();
      } catch (error, stack) {
        failure ??= (error, stack);
      }
    }
    if (failure != null) Error.throwWithStackTrace(failure.$1, failure.$2);
  }
}

const studioIblAsset =
    'asset://packages/sdui_model_filament/assets/lightroom_ibl.ktx';

double srgbToLinear(double channel) => channel <= 0.04045
    ? channel / 12.92
    : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
