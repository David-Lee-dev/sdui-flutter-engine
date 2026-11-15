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

  testWidgets('point parsing preserves coercing look-at and invalid defaults', (
    tester,
  ) async {
    for (final input in <(Object?, bool)>[
      ([1, 2, 3], true),
      (['1', '2', '3'], true),
      ([1, 2], false),
      ([1, double.nan, 3], false),
      ([1, 'Infinity', 3], false),
      ([1, false, 3], false),
    ]) {
      final source = RecordingModel3dSource(motionSupported: true);
      Model3dSourceRegistry.install(source);
      await pumpModel3d(tester, {
        'src': 'char.glb',
        'look_at': {'target': input.$1},
      });
      final controller = source.controllers.single as MotionModel3dController;
      if (input.$2) {
        expect(controller.gaze.last.target, Model3dLookAtTarget.point);
        expect(controller.gaze.last.point, (1.0, 2.0, 3.0));
      } else {
        expect(controller.gaze, isEmpty);
      }
      await tester.pumpWidget(const SizedBox());
    }
    Model3dSourceRegistry.reset();
  });

  testWidgets('resumes pending motion after hidden props clear', (
    tester,
  ) async {
    for (final motion in <Map<String, Object?>>[
      {
        'look_at': {'target': 'camera'},
      },
      {
        'layer': {'clip': 'Wave'},
      },
      {
        'look_at': {'target': 'camera'},
        'layer': {'clip': 'Wave'},
      },
    ]) {
      final source = RecordingModel3dSource(motionSupported: true);
      Model3dSourceRegistry.install(source);
      final props = {'src': 'char.glb', ...motion};
      await pumpModel3d(tester, props);
      final c = source.controllers.single as MotionModel3dController;
      expect(c.motionActive.last, isTrue);
      await pumpModel3d(tester, props, shown: false);
      expect(c.motionActive.last, isFalse);
      await pumpModel3d(tester, const {'src': 'char.glb'}, shown: false);
      expect(c.motionActive.last, isFalse);
      if (motion.containsKey('look_at')) expect(c.gaze.last, isNull);
      if (motion.containsKey('layer')) expect(c.layers.last, isNull);
      await pumpModel3d(tester, const {'src': 'char.glb'});
      expect(
        c.motionActive.last,
        isTrue,
        reason: 'pending transitions must resume after clearing $motion',
      );
      expect(source.controllers, hasLength(1));
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('blink disabled while hidden restores an interrupted pulse', (
    tester,
  ) async {
    final source = RecordingModel3dSource(motionSupported: true, frameRate: 60);
    Model3dSourceRegistry.install(source);
    const props = {
      'src': 'char.glb',
      'blink': {'every': 100, 'duration': 200},
    };
    await pumpModel3d(tester, props);
    final c = source.controllers.single as MotionModel3dController;
    for (
      var i = 0;
      i < 20 && (c.morphs.isEmpty || (c.morphs.last['blink'] ?? 0) == 0);
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(c.morphs.last['blink'], greaterThan(0));
    await pumpModel3d(tester, props, shown: false);
    await pumpModel3d(tester, const {'src': 'char.glb'}, shown: false);
    await pumpModel3d(tester, const {'src': 'char.glb'});
    expect(c.morphs.last['blink'], 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('absent motion and implements controllers remain compatible', (
    tester,
  ) async {
    final source = RecordingModel3dSource(motionSupported: true);
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {'src': 'char.glb'});
    final c = source.controllers.single as MotionModel3dController;
    expect(c.morphs, isEmpty);
    expect(c.gaze, isEmpty);
    expect(c.layers, isEmpty);
    expect(c.motionActive, isEmpty);
    final SduiModel3dController legacy = FakeModel3dController();
    legacy.setMorphs({'a': 1});
    legacy.setLookAt(const Model3dLookAt());
    legacy.setLayer(const Model3dLayer(clip: 'Wave'));
    legacy.setMotionActive(false);
    expect(legacy.layerCompletions, 0);
  });

  testWidgets('layer changes clear and completion action', (tester) async {
    final source = RecordingModel3dSource(motionSupported: true);
    Model3dSourceRegistry.install(source);
    final sink = Model3dSink();
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'layer': {'clip': 'Wave', 'loop': false, 'weight': 0.7},
      'on_layer_end': 'done',
    }, dispatch: sink);
    final c = source.controllers.single as MotionModel3dController;
    expect(c.layers, hasLength(1));
    expect(c.layers.last.clip, 'Wave');
    expect(c.layers.last.loop, false);
    expect(c.layers.last.weight, 0.7);
    c.finishLayer();
    await tester.pump();
    expect(sink.calls, hasLength(1));
    expect(sink.calls.single.$1, 'done');
    expect(sink.calls.single.$2, {'clip': 'Wave'});
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'layer': {'clip': 'Jump', 'loop': true},
      'crossfade_duration': 400,
    }, dispatch: sink);
    expect(c.layers.last.clip, 'Jump');
    expect(c.layerFades.last, const Duration(milliseconds: 400));
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'crossfade_duration': 400,
    });
    expect(c.layers.last, isNull);
    expect(c.layerFades.last, const Duration(milliseconds: 400));
    expect(source.controllers, hasLength(1));
  });

  testWidgets('preserves renderer through ready and target changes', (
    tester,
  ) async {
    final gate = Completer<void>();
    final source = RecordingModel3dSource(gate: gate);
    Model3dSourceRegistry.install(source);
    final props = <String, Object?>{
      'src': 'char.glb',
      'width': 200,
      'height': 200,
      'look_at': {'target': 'pointer'},
    };
    await pumpModel3d(tester, props);
    final view = tester.element(find.byKey(const Key('model-view')));
    gate.complete();
    await tester.pump();
    await tester.pump();
    expect(tester.element(find.byKey(const Key('model-view'))), same(view));
    for (final target in ['camera', 'pointer', null, 'pointer']) {
      await pumpModel3d(tester, {
        ...props,
        'look_at': target == null ? null : {'target': target},
      });
      expect(tester.element(find.byKey(const Key('model-view'))), same(view));
    }
    expect(source.controllers, hasLength(1));
  });

  testWidgets('look-at parses and pointer release returns to rest', (
    tester,
  ) async {
    final source = RecordingModel3dSource(motionSupported: true);
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'height': 200,
      'width': 200,
      'look_at': {
        'target': [1, 2, 3],
        'bone': 'neck',
        'max_yaw': 40,
        'max_pitch': 20,
        'weight': 0.5,
        'duration': 250,
      },
    });
    final c = source.controllers.single as MotionModel3dController;
    expect(c.gaze, isNotEmpty);
    expect(c.gaze.last.bone, 'neck');
    expect(c.gaze.last.target, Model3dLookAtTarget.point);
    expect(c.gaze.last.point, (1.0, 2.0, 3.0));
    expect(c.gaze.last.maxYaw, 40);
    expect(c.gaze.last.maxPitch, 20);
    expect(c.gaze.last.weight, 0.5);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'height': 200,
      'width': 200,
      'look_at': {'target': 'camera'},
    });
    expect(c.gaze.last.target, Model3dLookAtTarget.camera);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'height': 200,
      'width': 200,
      'look_at': {'target': 'pointer', 'duration': 250},
    });
    final box = tester.getRect(find.byKey(const Key('model-view')));
    final gesture = await tester.startGesture(
      box.center + const Offset(40, -20),
    );
    await tester.pump();
    expect(c.gaze.last.target, Model3dLookAtTarget.pointer);
    expect(c.gaze.last.point.$1, closeTo(0.4, 0.001));
    expect(c.gaze.last.point.$2, closeTo(0.2, 0.001));
    expect(c.gaze.last.weight, 1);
    await gesture.moveBy(const Offset(20, 20));
    expect(c.gaze.last.point.$1, closeTo(0.6, 0.001));
    await gesture.up();
    expect(c.gaze.last.weight, 0);
    expect(c.gaze.last.duration, const Duration(milliseconds: 250));
    await pumpModel3d(tester, const {'src': 'char.glb'});
    expect(c.gaze.last, isNull);
    expect(source.controllers, hasLength(1));
  });

  testWidgets('blink jitter pulses and stops when hidden or disabled', (
    tester,
  ) async {
    final source = RecordingModel3dSource(motionSupported: true, frameRate: 60);
    Model3dSourceRegistry.install(source);
    const props = {'src': 'char.glb', 'blink': true};
    await pumpModel3d(tester, props);
    final c = source.controllers.single as MotionModel3dController;
    await tester.pump(const Duration(milliseconds: 2790));
    expect(c.morphs, isEmpty);
    for (var i = 0; i < 170; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(c.morphs.any((m) => (m['blink'] ?? 0) > 0), isTrue);
    expect(c.morphs.last['blink'], 0);
    await pumpModel3d(tester, props, shown: false);
    final count = c.morphs.length;
    await tester.pump(const Duration(seconds: 12));
    expect(c.morphs.length, count);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'blink': {'target': 'eyes', 'every': 100, 'duration': 100},
    });
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(c.morphs.any((m) => (m['eyes'] ?? 0) > 0), isTrue);
    await pumpModel3d(tester, const {'src': 'char.glb'});
    await tester.pump(const Duration(milliseconds: 200));
    final stopped = c.morphs.length;
    await tester.pump(const Duration(seconds: 12));
    expect(c.morphs.length, stopped);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('morphs ease and reject invalid weights without reload', (
    tester,
  ) async {
    final source = RecordingModel3dSource(motionSupported: true, frameRate: 60);
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'morphs': {'smile': 1, 'bad': 2, 'no': 'x'},
      'morph_duration': 200,
    });
    final c = source.controllers.single as MotionModel3dController;
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.morphs, isNotEmpty);
    expect(c.morphs.last['smile'], inExclusiveRange(0, 1));
    expect(c.morphs.last.keys, ['smile']);
    await tester.pump(const Duration(milliseconds: 120));
    expect(c.morphs.last['smile'], 1);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'morphs': {'smile': 0},
      'morph_duration': 200,
    });
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.morphs.last['smile'], inExclusiveRange(0, 1));
    await tester.pump(const Duration(milliseconds: 120));
    expect(c.morphs.last['smile'], 0);
    expect(source.controllers, hasLength(1));
    await tester.pumpWidget(const SizedBox());
  });
}
