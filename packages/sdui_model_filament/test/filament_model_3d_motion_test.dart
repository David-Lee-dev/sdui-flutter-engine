import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:thermion_flutter/thermion_flutter.dart' as thermion;

import 'support/filament_fakes.dart';

void main() {
  testWidgets('GZ-1 pose requests only write inside the frame hook', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'head';
    final model = await loadFixture(native, boxGlb(doc));
    native.outsidePoseWrites.clear();
    model.setLookAt(const Model3dLookAt(duration: Duration.zero));
    model.setMorphs({'smile': 0.5});
    model.setPose('Wave', Duration.zero);
    model.setLayer(const Model3dLayer(clip: 'Jump', weight: 0.5));
    await tester.pump();
    expect(native.outsidePoseWrites, isEmpty);
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump();
    expect(native.indices, contains('setGltfAnimationTime 0'));
    expect(native.morphWeights.values, contains(0.5));
    native.outsidePoseWrites.clear();
    final before = native.log.where((s) => s == 'updateBoneMatrices').length;
    model.setCamera(const Model3dCamera(yaw: 30));
    await tester.pump();
    expect(native.outsidePoseWrites, isEmpty);
    expect(native.log.where((s) => s == 'updateBoneMatrices').length, before);
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(
      native.log.where((s) => s == 'updateBoneMatrices').length,
      greaterThan(before),
    );
    expect(native.outsidePoseWrites, isEmpty);
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });
  testWidgets('GZ-2 orbit gaze holds its side within the angular speed limit', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'head';
    final model = await loadFixture(native, boxGlb(doc));
    final head = native.assets.first.entity + 1;
    native.transforms[head] = thermion.Matrix4.translationValues(12, 24, 31);
    await model.play('Wave', loop: true);
    model.setLookAt(const Model3dLookAt(duration: Duration.zero));
    await tester.pump();
    final clock = Stopwatch()..start();
    var last = clock.elapsedMicroseconds;
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    double yaw() => math.atan2(
      native.transforms[head]!.storage[8],
      native.transforms[head]!.storage[10],
    );
    var previous = yaw();
    for (var angle = 10; angle <= 360; angle += 10) {
      model.setCamera(Model3dCamera(yaw: angle.toDouble(), pitch: 0));
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 75)),
      );
      final frameStart = clock.elapsedMicroseconds;
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      final now = clock.elapsedMicroseconds;
      final current = yaw();
      expect(
        (current - previous).abs(),
        lessThanOrEqualTo(math.pi * (now - last) / 1000000 + 0.005),
        reason: 'orbit $angle must not snap, even with duration zero',
      );
      if (angle < 300) {
        expect(
          current,
          greaterThanOrEqualTo(0),
          reason: 'orbit $angle must keep the exit side until cone reentry',
        );
      }
      if (angle >= 90 && angle < 300) {
        expect(
          current,
          closeTo(math.pi / 3, 0.000001),
          reason:
              'orbit $angle must hold the +60 degree clamp behind the model',
        );
      }
      previous = current;
      last = frameStart;
    }
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('GZ-3 max yaw 180 orbit holds its side across the rear seam', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'head';
    final model = await loadFixture(native, boxGlb(doc));
    final head = native.assets.first.entity + 1;
    native.transforms[head] = thermion.Matrix4.translationValues(12, 24, 31);
    await model.play('Wave', loop: true);
    model.setLookAt(const Model3dLookAt(maxYaw: 180, duration: Duration.zero));
    await tester.pump();
    final clock = Stopwatch()..start();
    var last = clock.elapsedMicroseconds;
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    double yaw() => math.atan2(
      native.transforms[head]!.storage[8],
      native.transforms[head]!.storage[10],
    );
    var previous = yaw();
    final angles = [
      for (var angle = 10; angle <= 180; angle += 10) angle,
      179,
      181,
      179,
      181,
      for (var angle = 190; angle <= 360; angle += 10) angle,
    ];
    for (final angle in angles) {
      model.setCamera(Model3dCamera(yaw: angle.toDouble(), pitch: 0));
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 75)),
      );
      final frameStart = clock.elapsedMicroseconds;
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      final now = clock.elapsedMicroseconds;
      final current = yaw();
      expect(
        (current - previous).abs(),
        lessThanOrEqualTo(math.pi * (now - last) / 1000000 + 0.005),
        reason: 'orbit $angle must not snap, even with duration zero',
      );
      if (angle < 190) {
        expect(
          current,
          greaterThanOrEqualTo(0),
          reason: 'orbit $angle must keep the exit side until cone reentry',
        );
      }
      if (angle >= 170 && angle < 190) {
        expect(
          current,
          closeTo(170 * math.pi / 180, 0.000001),
          reason:
              'orbit $angle must hold the +170 degree rear seam clamp behind the model',
        );
      }
      previous = current;
      last = frameStart;
    }
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('GZ-3 rear target holds its exit side until cone reentry', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'head';
    final model = await loadFixture(native, boxGlb(doc));
    final head = native.assets.first.entity + 1;
    native.transforms[head] = thermion.Matrix4.identity();
    await model.play('Wave', loop: true);
    for (final degrees in [45, 100, 179, -179, 179, -100, -45]) {
      final angle = degrees * math.pi / 180;
      model.setLookAt(
        Model3dLookAt(
          target: Model3dLookAtTarget.point,
          point: (10 * math.sin(angle), 0, 10 * math.cos(angle)),
          duration: Duration.zero,
        ),
      );
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 750)),
      );
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      final yaw = math.atan2(
        native.transforms[head]!.storage[8],
        native.transforms[head]!.storage[10],
      );
      final expected = degrees == 45
          ? 45
          : degrees == -45
          ? -45
          : 60;
      expect(
        yaw,
        closeTo(expected * math.pi / 180, 0.000001),
        reason: 'target $degrees degrees',
      );
    }
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('GZ-4 moving targets follow continuously from the current gaze', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'head';
    final model = await loadFixture(native, boxGlb(doc));
    final head = native.assets.first.entity + 1;
    native.transforms[head] = thermion.Matrix4.identity();
    await model.play('Wave', loop: true);
    model.setLookAt(
      const Model3dLookAt(target: Model3dLookAtTarget.point, point: (0, 0, 10)),
    );
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    var previous = 0.0;
    for (var degrees = 5; degrees <= 40; degrees += 5) {
      final angle = degrees * math.pi / 180;
      model.setLookAt(
        Model3dLookAt(
          target: Model3dLookAtTarget.point,
          point: (10 * math.sin(angle), 0, 10 * math.cos(angle)),
        ),
      );
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)),
      );
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      final yaw = math.atan2(
        native.transforms[head]!.storage[8],
        native.transforms[head]!.storage[10],
      );
      expect(yaw, greaterThan(previous));
      expect(yaw, lessThanOrEqualTo(angle));
      previous = yaw;
    }
    expect(
      previous,
      greaterThan(20 * math.pi / 180),
      reason: 'repeated target changes must make steady progress',
    );
    model.setMotionActive(false);
    await tester.pump();
    final paused = native.transforms[head]!.clone();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.transforms[head]!.storage, orderedEquals(paused.storage));
    model.setMotionActive(true);
    model.setLookAt(null);
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.transforms[head]!.storage[8], closeTo(0, 0.000001));
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'GZ-1 initialization and in-flight requests keep their next hook',
    (tester) async {
      final native = Native();
      final model = await loadFixture(
        native,
        boxGlb(boxDocument()),
        beforeLoad: (model) {
          model.setPose('Wave', const Duration(milliseconds: 250));
          model.setMorphs({'smile': 0.2});
        },
      );
      expect(native.outsidePoseWrites, isEmpty);
      expect(
        native.indices.where((c) => c.startsWith('setGltfAnimationTime')),
        isEmpty,
      );
      await tester.pump();
      native.hold('updateBoneMatrices');
      final frame = native.frame();
      await tester.pump();
      model.setPose('Jump', const Duration(milliseconds: 500));
      model.setMorphs({'smile': 0.8});
      native.release('updateBoneMatrices');
      await frame;
      await tester.pump(const Duration(milliseconds: 2));
      expect(
        native.hooks,
        isNotEmpty,
        reason: 'requests made during an await remain pending',
      );
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      expect(native.indices.last, 'setGltfAnimationTime 1');
      final pose = native.calls.lastWhere(
        (c) => c.memberName == #setGltfAnimationTime,
      );
      expect(pose.positionalArguments, [1, 0.5]);
      expect(native.morphWeights.values, everyElement(0.8));
      expect(native.outsidePoseWrites, isEmpty);
      expect(
        native.hooks,
        isEmpty,
        reason: 'one-shot work releases the frame hook',
      );
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    },
  );

  // RF-R3: a weight retarget must preserve an independently outgoing cursor.
  testWidgets('weight retarget preserves a separately leaving layer', (
    tester,
  ) async {
    final native = Native();
    final model = await loadFixture(native, boxGlb(boxDocument()));
    model.setLayer(const Model3dLayer(clip: 'Wave', loop: true, weight: 0.4));
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    model.setLayer(
      const Model3dLayer(clip: 'Jump', loop: true, weight: 0.4),
      crossfade: const Duration(seconds: 1),
    );
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    model.setLayer(
      const Model3dLayer(clip: 'Jump', loop: true, weight: 0.8),
      crossfade: const Duration(milliseconds: 200),
    );
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    native.indices.clear();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.indices, [
      'setGltfAnimationTime 0',
      'setGltfAnimationTime 1',
    ]);
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'layer weight retargets its envelope without restarting playback',
    (tester) async {
      final native = Native()..clips = [('Wave', 1), ('Jump', 0.08)];
      final doc = boxDocument();
      (doc['nodes'] as List).first['name'] = 'arm';
      final model = await loadFixture(native, boxGlb(doc));
      final arm = native.assets.first.entity + 1;
      final base = thermion.Matrix4.identity();
      native.transforms[arm] = base.clone();
      native.clipPoses[1] = {arm: base.clone()..rotateX(1)};
      model.setLayer(const Model3dLayer(clip: 'Jump', weight: 0.4));
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      double position() =>
          native.calls
                  .lastWhere(
                    (c) =>
                        c.memberName == #setGltfAnimationTime &&
                        c.positionalArguments.first == 1,
                  )
                  .positionalArguments[1]
              as double;
      final before = position();
      expect(before, greaterThan(0));
      model.setLayer(
        const Model3dLayer(clip: 'Jump', weight: 0.8),
        crossfade: const Duration(milliseconds: 60),
      );
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      expect(position(), greaterThanOrEqualTo(before));
      expect(
        native.transforms[arm]!.storage[6],
        closeTo(math.sin(0.4), 0.000001),
        reason: 'the envelope starts at the current effective weight',
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 110)),
      );
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      expect(model.layerCompletions, 1);
      expect(
        native.transforms[arm]!.storage[6],
        closeTo(math.sin(0.8), 0.000001),
      );
      model.setLayer(const Model3dLayer(clip: 'Jump', weight: 0.2));
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      expect(position(), closeTo(0.08, 0.000001));
      expect(
        model.layerCompletions,
        1,
        reason: 'completed cursor must not report a second completion',
      );
      model.setLayer(const Model3dLayer(clip: 'Jump', loop: true, weight: 0.2));
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      expect(position(), 0, reason: 'loop changes restart');
      model.setLayer(const Model3dLayer(clip: 'Wave', weight: 0.2));
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      final last = native.calls.lastWhere(
        (c) => c.memberName == #setGltfAnimationTime,
      );
      expect(last.positionalArguments, [
        0,
        0.0,
      ], reason: 'clip changes restart');
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets('entering driven pose stops outgoing crossfade components too', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'head';
    final model = await loadFixture(native, boxGlb(doc));
    await model.play('Wave', loop: true);
    await model.play(
      'Jump',
      loop: true,
      crossfade: const Duration(milliseconds: 200),
    );
    expect(native.componentClips, {0, 1});
    final SduiModel3dController controller = model;
    (controller as Model3dMotionController).setLookAt(
      const Model3dLookAt(
        target: Model3dLookAtTarget.point,
        point: (0, 0, 10),
        duration: Duration.zero,
      ),
    );
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(
      native.componentClips,
      isEmpty,
      reason:
          'no Thermion component may overwrite the renderer-driven pose after the hook',
    );
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('follows screen axes at every orbit', (tester) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'head';
    final model = await loadFixture(native, boxGlb(doc));
    final SduiModel3dController controller = model;
    final head = native.assets.first.entity + 1;
    // The fixture declares accessor bounds [10,20,30] through [14,28,32].
    final size = thermion.Vector3(4, 8, 2).length / 2;
    for (final orbit in [
      (0.0, 0.0),
      (180.0, 0.0),
      (90.0, 35.0),
      (-60.0, -30.0),
    ]) {
      (controller as Model3dMotionController).setLookAt(null);
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      native.transforms[head] = thermion.Matrix4.identity();
      controller.setCamera(
        Model3dCamera(
          yaw: orbit.$1,
          pitch: orbit.$2,
          pan: const Offset(0.1, -0.1),
        ),
      );
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      final call = native.calls.lastWhere((c) => c.memberName == #lookAt);
      final position = call.positionalArguments.first as thermion.Vector3;
      final focus = call.namedArguments[#focus] as thermion.Vector3;
      final forward = (focus - position)..normalize();
      final right = forward.cross(thermion.Vector3(0, 1, 0))..normalize();
      final up = right.cross(forward)..normalize();
      final depth = (-position).dot(forward) - size;
      final target =
          position + forward * depth + right * (0.4 * size) + up * (0.2 * size);
      final yaw = math
          .atan2(target.x, target.z)
          .clamp(-math.pi / 3, math.pi / 3);
      final pitch = math
          .atan2(target.y, math.sqrt(target.x * target.x + target.z * target.z))
          .clamp(-math.pi / 6, math.pi / 6);
      (controller as Model3dMotionController).setLookAt(
        const Model3dLookAt(
          target: Model3dLookAtTarget.pointer,
          point: (0.4, 0.2, 0),
          duration: Duration.zero,
        ),
      );
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 750)),
      );
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      final expected = thermion.Matrix4.identity()
        ..rotateY(yaw)
        ..rotateX(-pitch);
      for (var i = 0; i < 16; i++) {
        expect(
          native.transforms[head]!.storage[i],
          closeTo(expected.storage[i], 0.000001),
          reason: 'camera orbit $orbit, matrix entry $i',
        );
      }
    }
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('clears smoothly and re-enables from rest', (tester) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'head';
    (doc['nodes'] as List).add({'name': 'neck'});
    final model = await loadFixture(native, boxGlb(doc));
    final SduiModel3dController controller = model;
    final head = native.assets.first.entity + 1;
    native.transforms[head] = thermion.Matrix4.identity();
    const look = Model3dLookAt(
      target: Model3dLookAtTarget.point,
      point: (10, 0, 10),
      duration: Duration(milliseconds: 150),
    );
    (controller as Model3dMotionController).setLookAt(look);
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 900)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    final turned = native.transforms[head]!.storage[8];
    expect(turned, closeTo(math.sin(math.pi / 4), 0.000001));
    (controller as Model3dMotionController).setLookAt(null);
    await tester.pump();
    expect(
      native.transforms[head]!.storage[8],
      closeTo(turned, 0.000001),
      reason: 'clearing starts a return transition instead of snapping',
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.transforms[head]!.storage[8], inExclusiveRange(0, turned));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 900)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump(const Duration(milliseconds: 5));
    expect(native.transforms[head]!.storage[8], closeTo(0, 0.000001));
    expect(native.hooks, isEmpty);
    (controller as Model3dMotionController).setLookAt(look);
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.transforms[head]!.storage[8], closeTo(0, 0.000001));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.transforms[head]!.storage[8], inExclusiveRange(0, turned));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 900)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump(const Duration(milliseconds: 5));
    (controller as Model3dMotionController).setLookAt(
      const Model3dLookAt(
        bone: 'neck',
        target: Model3dLookAtTarget.point,
        point: (10, 0, 10),
        duration: Duration(milliseconds: 150),
      ),
    );
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.transforms[head]!.storage[8], closeTo(0, 0.000001));
    expect(
      native.transforms[head + 1]!.storage[8],
      closeTo(0, 0.000001),
      reason: 'a different bone must not inherit the previous gaze',
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(
      native.transforms[head + 1]!.storage[8],
      inExclusiveRange(0, turned),
    );
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('static look-at eases weight and releases idle frames', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'head';
    final model = await loadFixture(native, boxGlb(doc));
    final SduiModel3dController controller = model;
    final head = native.assets.first.entity + 1;
    native.transforms[head] = thermion.Matrix4.identity();
    (controller as Model3dMotionController).setLookAt(
      const Model3dLookAt(
        target: Model3dLookAtTarget.point,
        point: (10, 0, 10),
        duration: Duration(milliseconds: 150),
      ),
    );
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.transforms[head]!.storage[8], 0);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(
      native.transforms[head]!.storage[8],
      inExclusiveRange(0, math.sin(math.pi / 4)),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 900)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump(const Duration(milliseconds: 5));
    expect(
      native.transforms[head]!.storage[8],
      closeTo(math.sin(math.pi / 4), 0.000001),
    );
    expect(native.hooks, isEmpty);
    (controller as Model3dMotionController).setLookAt(
      const Model3dLookAt(
        target: Model3dLookAtTarget.point,
        point: (10, 0, 10),
        weight: 0,
        duration: Duration(milliseconds: 100),
      ),
    );
    await tester.pump();
    expect(
      native.transforms[head]!.storage[8],
      closeTo(math.sin(math.pi / 4), 0.000001),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 900)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump(const Duration(milliseconds: 5));
    expect(native.transforms[head]!.storage[8], closeTo(0, 0.000001));
    expect(native.hooks, isEmpty);
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('layer poses after base fades clears and reports end', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'arm';
    final model = await loadFixture(native, boxGlb(doc));
    final SduiModel3dController controller = model;
    final arm = native.assets.first.entity + 1;
    final base = thermion.Matrix4.translationValues(1, 2, 3);
    native.transforms[arm] = base.clone();
    native.clipPoses[0] = {arm: base};
    native.clipPoses[1] = {arm: base.clone()..rotateX(0.5)};
    await model.play('Wave', loop: true);
    (controller as Model3dMotionController).setLayer(
      const Model3dLayer(clip: 'Jump', loop: false, weight: 0.5),
    );
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.hooks, isNotEmpty);
    native.indices.clear();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.indices, [
      'setGltfAnimationTime 0',
      'setGltfAnimationTime 1',
    ]);
    final weighted = base.clone()..rotateX(0.25);
    for (var i = 0; i < 16; i++) {
      expect(
        native.transforms[arm]!.storage[i],
        closeTo(weighted.storage[i], 0.000001),
      );
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1050)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect((controller as Model3dMotionController).layerCompletions, 1);
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect((controller as Model3dMotionController).layerCompletions, 1);
    (controller as Model3dMotionController).setLayer(
      null,
      crossfade: const Duration(milliseconds: 80),
    );
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.hooks, isNotEmpty);
    expect(
      native.transforms[arm]!.storage[6].abs(),
      inExclusiveRange(0, weighted.storage[6].abs()),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.hooks, isEmpty);
    expect(native.transforms[arm]!.storage, orderedEquals(base.storage));
    expect(native.indices, contains('playGltfAnimation 0'));
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'look-at composes fresh animated pose clamps weights and clears',
    (tester) async {
      final native = Native();
      final doc = boxDocument();
      (doc['nodes'] as List).first['name'] = 'head';
      final model = await loadFixture(native, boxGlb(doc));
      final SduiModel3dController controller = model;
      final head = native.assets.first.entity + 1;
      final base = thermion.Matrix4.translationValues(1, 2, 3)..rotateZ(0.3);
      native.animationPose[head] = base;
      native.transforms[head] = base.clone();
      await model.play('Wave', loop: true);
      (controller as Model3dMotionController).setLookAt(
        const Model3dLookAt(
          target: Model3dLookAtTarget.point,
          point: (100, 100, 100),
          maxYaw: 20,
          maxPitch: 10,
          weight: 0.5,
          duration: Duration.zero,
        ),
      );
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      expect(native.hooks, isNotEmpty);
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      final first = native.transforms[head]!.clone();
      final expected = base.clone()
        ..rotateY(10 * math.pi / 180)
        ..rotateX(-5 * math.pi / 180);
      expect(first.storage, orderedEquals(expected.storage));
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      expect(
        native.transforms[head]!.storage,
        orderedEquals(first.storage),
        reason: 'look-at must not accumulate on its previous rotation',
      );
      expect(native.log, contains('updateBoneMatrices'));
      expect(native.indices, contains('stopGltfAnimation 0'));
      expect(native.indices, contains('setGltfAnimationTime 0'));
      (controller as Model3dMotionController).setMotionActive(false);
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      expect(native.hooks, isEmpty);
      (controller as Model3dMotionController).setMotionActive(true);
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      expect(native.hooks, isNotEmpty);
      (controller as Model3dMotionController).setLookAt(null);
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      expect(native.hooks, isEmpty);
      expect(native.transforms[head]!.storage, orderedEquals(base.storage));
      (controller as Model3dMotionController).setLookAt(
        const Model3dLookAt(bone: 'missing'),
      );
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
      expect(native.hooks, isEmpty);
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets('morph weights reach every matching mesh and ignore unknown', (
    tester,
  ) async {
    final native = Native();
    final model = await loadFixture(native, boxGlb(boxDocument()));
    final SduiModel3dController controller = model;
    (controller as Model3dMotionController).setMorphs({
      'smile': 0.7,
      'unknown': 1,
      'invalid': double.nan,
    });
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    final asset = native.assets.first;
    expect(native.morphWeights[(asset.entity + 1, 'smile')], 0.7);
    expect(native.morphWeights[(asset.entity + 2, 'smile')], 0.7);
    expect(native.morphWeights.keys.any((k) => k.$2 == 'unknown'), false);
    (controller as Model3dMotionController).setMorphs({
      'blink': 1,
      'smile': 0.2,
    });
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.morphWeights[(asset.entity + 1, 'blink')], 1);
    expect(native.morphWeights[(asset.entity + 2, 'smile')], 0.2);
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });
}
