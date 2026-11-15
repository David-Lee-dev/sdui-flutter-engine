import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_model_filament/sdui_model_filament.dart';
import 'package:thermion_flutter/thermion_flutter.dart' as thermion;

import 'support/filament_fakes.dart';

void main() {
  group('네이티브 자원', () {
    late Native native;
    late Completer<void> bytes;

    Future<FilamentModel3dController> controller({
      double iblIntensity = 30000,
    }) async {
      native = Native();
      bytes = Completer<void>();
      return await FilamentModel3dSource(
            keepAlive: Duration.zero,
            client: MockClient((_) async {
              await bytes.future;
              return http.Response.bytes([1], 200);
            }),
            baseUrl: Uri.parse('http://host/'),
            diskCache: false,
            iblIntensity: iblIntensity,
            platform: Platform(native),
          ).controllerFor(const Model3dRequest(src: '/a.glb'))
          as FilamentModel3dController;
    }

    Future<FilamentModel3dController> loaded(WidgetTester tester) async {
      final model = await controller();
      bytes.complete();
      await finishLoad(model.initialize());
      return model;
    }

    testWidgets(
      'light and environment updates map direction intensity and colour',
      (tester) async {
        final model = await loaded(tester);
        native.calls.clear();
        (model as Model3dLookController).setLook(
          const Model3dLook(
            environment: 0.4,
            environmentRotation: 90,
            light: Model3dLight(
              yaw: 90,
              pitch: 0,
              intensity: 2,
              color: Color(0xFFFF0000),
            ),
          ),
        );
        await tester.pump();
        final lights = native.calls
            .where((c) => c.memberName == #addDirectLight)
            .toList();
        expect(lights, hasLength(1));
        final light =
            lights.single.positionalArguments.single as thermion.DirectLight;
        expect(light.direction.x, closeTo(-1, 1e-9));
        expect(light.direction.y, closeTo(0, 1e-9));
        expect(light.direction.z, closeTo(0, 1e-9));
        expect(light.intensity, 200000);
        expect(light.color, const thermion.LinearColor(1, 0, 0));
        expect(
          native.calls
              .lastWhere((c) => c.memberName == #loadIbl)
              .namedArguments[#intensity],
          12000,
        );
        expect(
          native.calls.where((c) => c.memberName == #rotateIbl),
          hasLength(1),
        );
        native.calls.clear();
        (model as Model3dLookController).setLook(
          const Model3dLook(environment: 0.6, environmentRotation: 90),
        );
        await tester.pump();
        expect(
          native.calls
              .singleWhere((c) => c.memberName == #removeLight)
              .positionalArguments,
          [42],
        );
        expect(
          native.calls.where((c) => c.memberName == #rotateIbl),
          hasLength(1),
        );
        await model.dispose();
        await tester.pump(const Duration(seconds: 1));
      },
    );

    testWidgets('contact quad reused and cast mode updates both asset flags', (
      tester,
    ) async {
      final model = await loaded(tester);
      native.calls.clear();
      (model as Model3dLookController).setLook(
        const Model3dLook(
          shadow: Model3dShadow(type: Model3dShadowType.contact),
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump();
      expect(
        native.calls.where((c) => c.memberName == #createGeometry),
        hasLength(1),
      );
      final material = native.calls.singleWhere(
        (c) => c.memberName == #createUbershaderMaterialInstance,
      );
      expect(material.namedArguments[#unlit], true);
      expect(material.namedArguments[#alphaMode], thermion.AlphaMode.BLEND);
      expect(material.namedArguments[#hasBaseColorTexture], true);
      expect(
        native.calls.where((c) => c.memberName == #decodeImage),
        hasLength(1),
      );
      final transform =
          native.calls
                  .singleWhere((c) => c.memberName == #setTransform)
                  .positionalArguments
                  .single
              as thermion.Matrix4;
      expect(transform.getTranslation().y, closeTo(-0.999, 1e-9));
      (model as Model3dLookController).setLook(
        const Model3dLook(
          light: Model3dLight(),
          shadow: Model3dShadow(type: Model3dShadowType.cast, opacity: 0.8),
        ),
      );
      await tester.pump();
      expect(
        native.calls
            .lastWhere((c) => c.memberName == #setShadowsEnabled)
            .positionalArguments,
        [true],
      );
      expect(
        native.calls
            .lastWhere((c) => c.memberName == #setCastShadows)
            .positionalArguments,
        [true],
      );
      expect(
        native.calls
            .lastWhere((c) => c.memberName == #setReceiveShadows)
            .positionalArguments,
        [true],
      );
      expect(
        (native.calls
                    .lastWhere((c) => c.memberName == #addDirectLight)
                    .positionalArguments
                    .single
                as thermion.DirectLight)
            .castShadows,
        true,
      );
      (model as Model3dLookController).setLook(
        const Model3dLook(
          light: Model3dLight(),
          shadow: Model3dShadow(type: Model3dShadowType.contact),
        ),
      );
      await tester.pump();
      expect(
        native.calls
            .lastWhere((c) => c.memberName == #setCastShadows)
            .positionalArguments,
        [false],
      );
      expect(
        native.calls
            .lastWhere((c) => c.memberName == #setReceiveShadows)
            .positionalArguments,
        [false],
      );
      (model as Model3dLookController).setLook(
        const Model3dLook(shadow: Model3dShadow(type: Model3dShadowType.cast)),
      );
      await tester.pump();
      expect(
        native.calls
            .lastWhere((c) => c.memberName == #setShadowsEnabled)
            .positionalArguments,
        [false],
      );
      expect(
        native.calls.where((c) => c.memberName == #createGeometry),
        hasLength(1),
      );
      (model as Model3dLookController).setLook(const Model3dLook());
      await tester.pump();
      expect(
        native.calls
            .lastWhere((c) => c.memberName == #setParameterFloat4)
            .positionalArguments
            .last,
        0,
      );
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('quality AA AO soft shadows and exposure reset', (
      tester,
    ) async {
      final model = await loaded(tester);
      native.calls.clear();
      (model as Model3dLookController).setLook(
        const Model3dLook(quality: Model3dQuality.high, exposure: 1.5),
      );
      await tester.pump();
      expect(
        native.calls
            .where((c) => c.memberName == #setRenderQuality)
            .map((c) => c.positionalArguments),
        [
          [thermion.QualityLevel.HIGH],
        ],
      );
      expect(
        native.calls
            .lastWhere((c) => c.memberName == #setAntiAliasing)
            .positionalArguments,
        [true, true, false],
      );
      expect(
        (native.calls
                    .lastWhere(
                      (c) => c.memberName == #setAmbientOcclusionOptions,
                    )
                    .positionalArguments
                    .single
                as thermion.AmbientOcclusionOptions)
            .enabled,
        true,
      );
      expect(
        native.calls
            .lastWhere((c) => c.memberName == #setShadowType)
            .positionalArguments,
        [thermion.ShadowType.PCSS],
      );
      expect(native.log, contains('exposure 1.5'));
      expect(
        native.calls
            .lastWhere((c) => c.memberName == #setColorGrading)
            .positionalArguments
            .single,
        isA<thermion.ColorGrading>(),
      );
      expect(native.log, contains('builder.dispose'));
      for (final quality in [Model3dQuality.low, Model3dQuality.medium]) {
        (model as Model3dLookController).setLook(Model3dLook(quality: quality));
        await tester.pump();
        expect(
          native.calls
              .lastWhere((c) => c.memberName == #setRenderQuality)
              .positionalArguments,
          [
            quality == Model3dQuality.low
                ? thermion.QualityLevel.LOW
                : thermion.QualityLevel.MEDIUM,
          ],
        );
        expect(
          native.calls
              .lastWhere((c) => c.memberName == #setAntiAliasing)
              .positionalArguments,
          [false, true, false],
        );
        expect(
          (native.calls
                      .lastWhere(
                        (c) => c.memberName == #setAmbientOcclusionOptions,
                      )
                      .positionalArguments
                      .single
                  as thermion.AmbientOcclusionOptions)
              .enabled,
          false,
        );
      }
      expect(
        native.calls
            .lastWhere((c) => c.memberName == #setColorGrading)
            .positionalArguments,
        [null],
      );
      expect(native.log, contains('grading.dispose'));
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets(
      'latest loading look applied and resources released before viewer',
      (tester) async {
        final model = await controller();
        (model as Model3dLookController).setLook(
          const Model3dLook(environment: 0.2),
        );
        final loading = model.initialize();
        await tester.pump();
        (model as Model3dLookController).setLook(
          const Model3dLook(
            light: Model3dLight(),
            exposure: 2,
            shadow: Model3dShadow(type: Model3dShadowType.contact),
          ),
        );
        bytes.complete();
        await finishLoad(loading);
        expect(
          native.calls.where((c) => c.memberName == #addDirectLight),
          hasLength(1),
        );
        expect(
          native.calls.where((c) => c.memberName == #loadIbl),
          hasLength(1),
        );
        expect(
          native.calls.where((c) => c.memberName == #createGeometry),
          hasLength(1),
        );
        await model.dispose();
        expect(
          native.log,
          containsAllInOrder([
            'removeLight',
            'destroyAsset',
            'material.destroy',
            'texture.destroy',
            'sampler.dispose',
            'setColorGrading',
            'grading.dispose',
            'release',
          ]),
        );
        final released = native.log.length;
        (model as Model3dLookController).setLook(const Model3dLook());
        await tester.pump(const Duration(seconds: 1));
        expect(native.log, hasLength(released));
      },
    );

    testWidgets('contact uses unit-cube space for offset large models', (
      tester,
    ) async {
      final model = await controller();
      native.bounds = thermion.Aabb3.minMax(
        thermion.Vector3(10, 20, 30),
        thermion.Vector3(14, 28, 32),
      );
      bytes.complete();
      await finishLoad(model.initialize());
      (model as Model3dLookController).setLook(
        const Model3dLook(
          shadow: Model3dShadow(type: Model3dShadowType.contact),
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump();
      final transform =
          native.calls
                  .singleWhere((c) => c.memberName == #setTransform)
                  .positionalArguments
                  .single
              as thermion.Matrix4;
      expect(transform.getTranslation().x, 0);
      expect(transform.getTranslation().y, closeTo(-0.999, 1e-9));
      expect(transform.getTranslation().z, 0);
      final geometry =
          native.calls
                  .singleWhere((c) => c.memberName == #createGeometry)
                  .positionalArguments
                  .single
              as thermion.Geometry;
      expect(geometry.vertices[0], closeTo(-0.6, 1e-6));
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('all resources released after material destroy fails', (
      tester,
    ) async {
      final model = await loaded(tester);
      (model as Model3dLookController).setLook(
        const Model3dLook(
          exposure: 1,
          shadow: Model3dShadow(type: Model3dShadowType.contact),
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump();
      native.fail = 'material.destroy';
      await expectLater(model.dispose(), throwsStateError);
      expect(
        native.log,
        containsAllInOrder([
          'material.destroy',
          'texture.destroy',
          'sampler.dispose',
          'grading.dispose',
          'release',
        ]),
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('disposal waits for contact allocation before releasing', (
      tester,
    ) async {
      final model = await loaded(tester);
      native.hold('createTexture');
      (model as Model3dLookController).setLook(
        const Model3dLook(
          shadow: Model3dShadow(type: Model3dShadowType.contact),
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump();
      expect(native.log, contains('createTexture'));
      final disposing = model.dispose();
      await tester.pump();
      expect(native.log, isNot(contains('release')));
      native.release('createTexture');
      await tester.runAsync(() async {
        await disposing;
      });
      expect(
        native.log,
        containsAllInOrder([
          'createTexture done',
          'destroyAsset',
          'material.destroy',
          'texture.destroy',
          'release',
        ]),
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('native updates collapse to latest look', (tester) async {
      final model = await loaded(tester);
      native.calls.clear();
      native.hold('loadIbl');
      (model as Model3dLookController).setLook(
        const Model3dLook(environment: 0.2),
      );
      await tester.pump();
      (model as Model3dLookController).setLook(
        const Model3dLook(environment: 0.3, light: Model3dLight()),
      );
      (model as Model3dLookController).setLook(
        const Model3dLook(
          environment: 0.7,
          environmentRotation: 70,
          light: Model3dLight(yaw: 90),
        ),
      );
      native.release('loadIbl');
      await tester.pump();
      expect(
        native.calls
            .where((c) => c.memberName == #loadIbl)
            .map((c) => c.namedArguments[#intensity]),
        [6000, 21000],
      );
      expect(
        native.calls.where((c) => c.memberName == #addDirectLight),
        hasLength(1),
      );
      final light =
          native.calls
                  .lastWhere((c) => c.memberName == #addDirectLight)
                  .positionalArguments
                  .single
              as thermion.DirectLight;
      expect(light.direction.x, closeTo(-0.70710678, 1e-7));
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('partial contact allocation is cleaned on failure', (
      tester,
    ) async {
      final model = await loaded(tester);
      native.fail = 'createGeometry';
      (model as Model3dLookController).setLook(
        const Model3dLook(
          shadow: Model3dShadow(type: Model3dShadowType.contact),
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump();
      expect(
        native.log,
        containsAllInOrder([
          'createGeometry',
          'material.destroy',
          'texture.destroy',
          'sampler.dispose',
        ]),
      );
      final count = native.log.where((n) => n == 'texture.destroy').length;
      await model.dispose();
      expect(native.log.where((n) => n == 'texture.destroy'), hasLength(count));
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('defaults preserve IBL and FXAA with shadows off', (
      tester,
    ) async {
      final model = await loaded(tester);
      expect(
        native.calls.where((c) => c.memberName == #addDirectLight),
        isEmpty,
      );
      expect(
        native.calls
            .singleWhere((c) => c.memberName == #loadIbl)
            .namedArguments[#intensity],
        30000,
      );
      expect(
        native.calls
            .lastWhere((c) => c.memberName == #setAntiAliasing)
            .positionalArguments,
        [false, true, false],
      );
      expect(
        native.calls.where((c) => c.memberName == #setColorGrading),
        isEmpty,
      );
      expect(
        native.calls
            .where((c) => c.memberName == #setShadowsEnabled)
            .map((c) => c.positionalArguments),
        [
          [false],
        ],
      );
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
