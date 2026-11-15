import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';
import 'package:sdui_engine/src/runtime/media/model_3d_source_registry.dart';

import '../../../../support/engine_harness.dart';

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

  testWidgets('renderer rate paces auto rotation without Flutter frames', (
    tester,
  ) async {
    final source = RecordingModel3dSource(frameRate: 30);
    Model3dSourceRegistry.install(source);
    await pumpEngineTemplate(tester, const {
      '_type': 'model_3d',
      'src': 'char.glb',
      'width': 200,
      'height': 200,
      'auto_rotate': 30,
    });
    await tester.pump(const Duration(milliseconds: 400));
    // Let the first clock tick establish the baseline after mounting.
    await tester.pump(const Duration(microseconds: 33333));
    final controller = source.controllers.single;
    final start = controller.cameras.last.yaw;
    controller.cameras.clear();
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(microseconds: 8334));
    }
    expect(controller.cameras.length, inInclusiveRange(29, 31));
    expect(controller.cameras.last.yaw - start, closeTo(30, 0.1));
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('renderer rate paces progress and keeps clip speed', (
    tester,
  ) async {
    final source = RecordingModel3dSource(frameRate: 30);
    Model3dSourceRegistry.install(source);
    Map<String, Object?> props(double at) => {
      'src': 'char.glb',
      'width': 200,
      'height': 200,
      'progress': {'clip': 'Wave', 'at': at},
    };
    await pumpModel3d(tester, props(0));
    await tester.pumpAndSettle();
    await pumpModel3d(tester, props(1000));
    // Both clocks establish their baseline on the first tick.
    await tester.pump(const Duration(microseconds: 33333));
    final controller = source.controllers.single;
    controller.poses.clear();
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(microseconds: 8333));
    }
    expect(controller.poses.length, inInclusiveRange(28, 30));
    expect(controller.seconds, closeTo(1, 0.04));
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.seconds, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('hidden renderer clocks pause and resume without jumps', (
    tester,
  ) async {
    final source = RecordingModel3dSource(frameRate: 30);
    Model3dSourceRegistry.install(source);
    Map<String, Object?> props(double at) => {
      'src': 'char.glb',
      'width': 200,
      'height': 200,
      'auto_rotate': 30,
      'progress': {'clip': 'Wave', 'at': at},
    };
    await pumpModel3d(tester, props(0));
    await tester.pump(const Duration(milliseconds: 400));
    await pumpModel3d(tester, props(5000));
    await tester.pump(const Duration(milliseconds: 400));
    await pumpModel3d(tester, props(5000), shown: false);
    final controller = source.controllers.single;
    final yaw = controller.cameras.last.yaw;
    final position = controller.seconds;
    final cameras = controller.cameras.length;
    final poses = controller.poses.length;
    await tester.pump(const Duration(seconds: 5));
    expect(controller.cameras.length, cameras);
    expect(controller.poses.length, poses);
    await pumpModel3d(tester, props(5000));
    await tester.pump(const Duration(microseconds: 33333));
    expect(controller.cameras.last.yaw, yaw);
    expect(controller.seconds, position);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(microseconds: 33333));
    }
    expect(controller.cameras.last.yaw - yaw, closeTo(30, 0.1));
    expect(controller.seconds - position, closeTo(1, 0.01));
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(const SizedBox());
  });
}
