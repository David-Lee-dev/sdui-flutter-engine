import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('point parsing preserves numeric-only camera and scene inputs', (
    tester,
  ) async {
    for (final input in <(Object?, bool)>[
      ([1, 2, 3], true),
      (['1', '2', '3'], false),
      ([1, 2], false),
      ([1, double.nan, 3], false),
      ([1, double.infinity, 3], false),
      ([1, false, 3], false),
    ]) {
      final source = RecordingModel3dSource(sceneSupported: true);
      Model3dSourceRegistry.install(source);
      await pumpModel3d(tester, {
        'src': 'char.glb',
        'camera': {'target': input.$1},
        'scene': [
          {'src': 'extra.glb', 'position': input.$1},
        ],
      });
      final controller = source.controllers.single;
      expect(
        controller.cameras.last.target.point,
        input.$2 ? (1.0, 2.0, 3.0) : null,
      );
      if (input.$2) {
        expect(controller.scenes.last.single.position, (1.0, 2.0, 3.0));
      } else {
        expect(controller.scenes, isEmpty);
      }
      await tester.pumpWidget(const SizedBox());
    }
    Model3dSourceRegistry.reset();
  });

  testWidgets('extras update independently and pause while hidden', (
    tester,
  ) async {
    final source = RecordingModel3dSource(sceneSupported: true);
    Model3dSourceRegistry.install(source);
    const props = {
      'src': 'char.glb',
      'scene': [
        {'src': 'planet.glb'},
      ],
    };
    await pumpModel3d(tester, props);
    final controller = source.controllers.single;
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'scene': [
        {'src': 'planet.glb', 'scale': 2},
      ],
    });
    expect(controller.scenes, hasLength(2));
    expect(controller.scenes.last.single.scale, 2);
    expect(controller.initializations, 1);
    expect(source.requests, hasLength(1));
    await pumpModel3d(tester, props, shown: false);
    expect(controller.sceneActive.last, false);
    await pumpModel3d(tester, props);
    expect(controller.sceneActive.last, true);
    await pumpModel3d(tester, const {'src': 'char.glb'});
    expect(controller.scenes.last, isEmpty);
  });

  testWidgets('scene parsing drops invalid entries and snapshots values', (
    tester,
  ) async {
    final source = RecordingModel3dSource(sceneSupported: true);
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, {
      'src': 'char.glb',
      'scene': [
        {
          'src': 'planet.glb',
          'position': [1, 2, 3],
          'rotation': {'yaw': 90, 'pitch': 20, 'roll': 10},
          'scale': 2,
          'clip': 'Walk',
          'spin': {'axis': 'y', 'speed': 30},
        },
        {'src': 'default.glb'},
        {'src': ''},
        {'src': 'bad', 'scale': 0},
        {'src': 'bad', 'scale': '2'},
        {
          'src': 'bad',
          'rotation': {'yaw': '90'},
        },
        {
          'src': 'bad',
          'spin': {'axis': 'y', 'speed': '30'},
        },

        {
          'src': 'bad',
          'position': [1, 2],
        },
        {
          'src': 'bad',
          'rotation': {'yaw': double.nan},
        },
        {
          'src': 'bad',
          'spin': {'axis': 'q', 'speed': 1},
        },
        {
          'src': 'bad',
          'spin': {'axis': 'x', 'speed': double.infinity},
        },
      ],
    });
    final controller = source.controllers.single;
    expect(controller.scenes, hasLength(1));
    final scene = controller.scenes.single;
    expect(scene, hasLength(2));
    expect(scene[0].src, 'planet.glb');
    expect(scene[0].position, (1.0, 2.0, 3.0));
    expect(scene[0].rotation, (yaw: 90.0, pitch: 20.0, roll: 10.0));
    expect(scene[0].spin, (axis: 'y', speed: 30.0));
    expect(scene[0].scale, 2);
    expect(scene[0].clip, 'Walk');
    expect(scene[1].position, (0.0, 0.0, 0.0));
    expect(() => scene.clear(), throwsUnsupportedError);
  });
}
