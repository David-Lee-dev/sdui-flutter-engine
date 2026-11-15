import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/model_3d_source.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';
import 'package:sdui_engine/src/runtime/media/model_3d_source_registry.dart';

import 'model_3d/fixtures.dart';

void main() {
  setUp(() {
    Model3dSourceRegistry.reset();
    ImageSourceRegistry.reset();
    ImageSourceRegistry.install(const TextModel3dImageSource());
  });
  tearDown(() {
    Model3dSourceRegistry.reset();
    ImageSourceRegistry.reset();
  });

  testWidgets('0.28 implements controller mounts without optional members', (
    tester,
  ) async {
    final controller = LegacyModel3dController();
    Model3dSourceRegistry.install(FixedModel3dSource(controller));
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'exposure': 2,
      'scene': [
        {'src': 'extra.glb'},
      ],
      'outfit': {
        'show': ['Head'],
      },
      'morphs': {'smile': 1},
      'look_at': {'target': 'camera'},
      'layer': {'clip': 'Wave'},
    });
    final SduiModel3dController legacy = controller;
    legacy.setLook(const Model3dLook());
    legacy.setScene(const []);
    legacy.setOutfit(Model3dOutfit());
    legacy.setMorphs(const {'smile': 1});
    legacy.setLookAt(const Model3dLookAt());
    legacy.setLayer(const Model3dLayer(clip: 'Wave'));
    legacy.setMotionActive(false);
    expect(legacy.layerCompletions, 0);
    expect(await legacy.hitTest(Offset.zero), isNull);
    expect(controller.initializations, 1);
    expect(find.byKey(const Key('model-view')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    Model3dSourceRegistry.reset();
  });

  testWidgets('look dispatch requires the advertised capability', (
    tester,
  ) async {
    final controller = UnadvertisedLookController();
    Model3dSourceRegistry.install(FixedModel3dSource(controller));
    await pumpModel3d(tester, const {'src': 'char.glb', 'exposure': 2});
    expect(controller.initializations, 1);
    expect(controller.looks, isEmpty);
    Model3dSourceRegistry.reset();
  });

  testWidgets('parses look fields and defaults invalid values', (tester) async {
    final source = RecordingModel3dSource();
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'lighting': {
        'environment': 0.3,
        'environment_rotation': 90,
        'light': {'yaw': 20, 'pitch': 60, 'intensity': 2, 'color': '#FF0000'},
      },
      'shadow': {'type': 'cast', 'opacity': 0.7},
      'quality': 'high',
      'exposure': -1,
    });
    expect(
      source.controllers.single.looks.single,
      const Model3dLook(
        environment: 0.3,
        environmentRotation: 90,
        light: Model3dLight(
          yaw: 20,
          pitch: 60,
          intensity: 2,
          color: Color(0xFFFF0000),
        ),
        shadow: Model3dShadow(type: Model3dShadowType.cast, opacity: 0.7),
        quality: Model3dQuality.high,
        exposure: -1,
      ),
    );
    await tester.pumpWidget(const SizedBox());
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'lighting': {
        'environment': -1,
        'environment_rotation': double.nan,
        'light': false,
      },
      'shadow': {'type': 'oops', 'opacity': 3},
      'quality': 'oops',
      'exposure': double.infinity,
    });
    expect(source.controllers.last.looks.single, const Model3dLook());
    for (final quality in Model3dQuality.values) {
      await tester.pumpWidget(const SizedBox());
      await pumpModel3d(tester, {
        'src': 'char.glb',
        'quality': quality.name,
        'shadow': 'contact',
        'lighting': {'light': <String, Object?>{}},
      });
      expect(
        source.controllers.last.looks.single,
        Model3dLook(
          quality: quality,
          light: const Model3dLight(),
          shadow: const Model3dShadow(type: Model3dShadowType.contact),
        ),
      );
    }
  });

  testWidgets('malformed nested fields use individual defaults', (
    tester,
  ) async {
    final source = RecordingModel3dSource();
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'lighting': {
        'environment': 'bad',
        'environment_rotation': false,
        'light': {
          'yaw': double.infinity,
          'pitch': 'bad',
          'intensity': -1,
          'color': '#oops',
        },
      },
      'shadow': {'type': 'contact', 'opacity': -1},
      'quality': false,
      'exposure': 'bad',
    });
    expect(
      source.controllers.single.looks.single,
      const Model3dLook(
        light: Model3dLight(),
        shadow: Model3dShadow(type: Model3dShadowType.contact),
      ),
    );
    for (final shadow in Model3dShadowType.values) {
      await tester.pumpWidget(const SizedBox());
      await pumpModel3d(tester, {
        'src': 'char.glb',
        'shadow': shadow.name,
        'lighting': false,
      });
      expect(
        source.controllers.last.looks.single,
        Model3dLook(shadow: Model3dShadow(type: shadow)),
      );
    }
  });

  testWidgets('updates look while initialization is pending', (tester) async {
    final gate = Completer<void>();
    final source = RecordingModel3dSource(gate: gate);
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {'src': 'char.glb'});
    final controller = source.controllers.single;
    expect(controller.looks, [const Model3dLook()]);
    await pumpModel3d(tester, const {'src': 'char.glb', 'quality': 'high'});
    expect(controller.looks, [
      const Model3dLook(),
      const Model3dLook(quality: Model3dQuality.high),
    ]);
    gate.complete();
    await tester.pump();
    expect(source.controllers, [controller]);
    expect(controller.initializations, 1);
    expect(controller.looks, hasLength(2));
  });

  testWidgets('runtime look changes reuse controller and initialize', (
    tester,
  ) async {
    final source = RecordingModel3dSource();
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {'src': 'char.glb'});
    final controller = source.controllers.single;
    await pumpModel3d(tester, const {'src': 'char.glb', 'exposure': 2});
    expect(source.controllers, [controller]);
    expect(controller.initializations, 1);
    expect(controller.looks, [
      const Model3dLook(),
      const Model3dLook(exposure: 2),
    ]);
    await pumpModel3d(tester, const {'src': 'char.glb', 'exposure': 2});
    expect(controller.looks, hasLength(2));
  });

  testWidgets('default look delivered once before initialize', (tester) async {
    final source = RecordingModel3dSource();
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {'src': 'char.glb'});
    expect(source.controllers.single.looks, [const Model3dLook()]);
    expect(source.controllers.single.cameras, hasLength(1));
  });
}
