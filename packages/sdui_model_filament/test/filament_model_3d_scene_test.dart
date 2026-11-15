import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_model_filament/sdui_model_filament.dart';
import 'package:thermion_flutter/thermion_flutter.dart' as thermion;

import 'support/filament_fakes.dart';

void main() {
  testWidgets('late loads hidden scenes and disposal preserve ownership', (
    tester,
  ) async {
    final native = Native();
    final slow = Completer<void>();
    final source = FilamentModel3dSource(
      keepAlive: Duration.zero,
      client: MockClient((request) async {
        if (request.url.path == '/slow.glb') await slow.future;
        return http.Response.bytes(boxGlb(boxDocument()), 200);
      }),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      platform: Platform(native),
    );
    final model =
        await source.controllerFor(const Model3dRequest(src: '/primary.glb'))
            as FilamentModel3dController;
    (model as Model3dSceneController).setScene([
      const Model3dSceneItem(src: '/slow.glb'),
    ]);
    await finishLoad(model.initialize());
    expect(model.stats.isReady, true); // Extra bytes are still pending.
    const current = Model3dSceneItem(
      src: '/current.glb',
      clip: 'Wave',
      spin: (axis: 'y', speed: 10),
    );
    (model as Model3dSceneController).setScene([current]);
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();
    expect(native.assets, hasLength(2));
    slow.complete();
    await tester.pump();
    expect(
      native.assets,
      hasLength(2),
    ); // Stale bytes never reach native loading.
    final placement = native.parents[native.assets.last.entity]!;
    await native.frame();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await native.frame();
    final before = native.transforms[placement]!.clone();
    (model as Model3dSceneController).setScene([current], active: false);
    await tester.pump();
    expect(native.hooks, isEmpty);
    await tester.pump(const Duration(seconds: 1));
    expect(
      native.calls
          .where((c) => c.memberName == #setRendering)
          .last
          .positionalArguments,
      [false],
    );
    expect(native.assets, hasLength(2));
    (model as Model3dSceneController).setScene([current]);
    await tester.pump();
    expect(native.hooks, hasLength(1));
    await native.frame();
    expect(native.transforms[placement], before); // Hidden time does not spin.
    native.hold('loadGltfFromBuffer');
    (model as Model3dSceneController).setScene([
      const Model3dSceneItem(src: '/native-pending.glb'),
    ]);
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    expect(native.assets, hasLength(3));
    final disposed = model.dispose();
    native.release('loadGltfFromBuffer');
    await disposed;
    expect(native.hooks, isEmpty);
    expect(native.destroyedEntities, [placement]);
    expect(native.log.where((name) => name == 'destroyAsset'), hasLength(2));
    expect(native.log.last, 'release');
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('bounding sphere frames wide boxy and degenerate primaries', (
    tester,
  ) async {
    for (final extent in [
      [8.0, 8.0, 8.0],
      [20.0, 2.0, 4.0],
      [2.0, 12.0, 2.0],
      [0.0, 0.0, 0.0],
    ]) {
      final doc = boxDocument();
      doc['accessors'][0]['min'] = [0, 0, 0];
      doc['accessors'][0]['max'] = extent;
      final native = Native();
      final model = await loadFixture(native, boxGlb(doc));
      final view = native.calls.singleWhere((c) => c.memberName == #lookAt);
      final focus = view.namedArguments[#focus] as thermion.Vector3;
      final eye = view.positionalArguments.first as thermion.Vector3;
      final diagonal = thermion.Vector3.array(extent).length;
      final radius = diagonal > 0 ? diagonal / 2 : 1.0;
      expect(
        (eye - focus).length,
        closeTo(radius / math.sin(math.atan(12 / 28)), 1e-8),
      );
      expect((eye - focus).length, greaterThan(radius));
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    }
  });

  testWidgets('resolves points nodes fallback blends pan and animated nodes', (
    tester,
  ) async {
    final native = Native();
    native.nodePositions['Head'] = thermion.Vector3(10, 20, 30);
    final model = await loadFixture(native, boxGlb(boxDocument()));
    thermion.Vector3 focus() =>
        native.calls
                .lastWhere((c) => c.memberName == #lookAt)
                .namedArguments[#focus]
            as thermion.Vector3;
    final centre = focus().clone();
    model.setCamera(
      const Model3dCamera(target: Model3dTarget.point((1, 2, 3))),
    );
    await tester.pump();
    expect(focus().storage, [1, 2, 3]);
    model.setCamera(const Model3dCamera(target: Model3dTarget.node('Head')));
    await tester.pump();
    expect(focus().storage, [10, 20, 30]);
    model.setCamera(
      Model3dCamera(
        target: Model3dTarget.lerp(
          const Model3dTarget.point((0, 0, 0)),
          const Model3dTarget.node('Head'),
          0.5,
        ),
      ),
    );
    await tester.pump();
    expect(focus().storage, [5, 10, 15]);
    model.setCamera(const Model3dCamera(target: Model3dTarget.node('missing')));
    await tester.pump();
    expect(focus().storage, centre.storage);
    model.setCamera(
      const Model3dCamera(
        target: Model3dTarget.point((0, 0, 0)),
        pan: Offset(0.1, -0.2),
      ),
    );
    await tester.pump();
    // Fixture bounds [10,20,30]..[14,28,32], diagonal sqrt(84).
    expect(focus().x, closeTo(-math.sqrt(84) * 0.1, 1e-8));
    expect(focus().y, closeTo(-math.sqrt(84) * 0.2, 1e-8));
    model.setCamera(const Model3dCamera(target: Model3dTarget.node('Head')));
    await model.play('Wave', loop: true);
    await tester.pump();
    expect(native.hooks, hasLength(1));
    native.nodePositions['Head'] = thermion.Vector3(40, 50, 60);
    await native.frame();
    expect(focus().storage, [40, 50, 60]);
    await model.stop();
    native.nodePositions['Head'] = thermion.Vector3(70, 80, 90);
    model.setPose('Wave', const Duration(milliseconds: 500));
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(focus().storage, [70, 80, 90]);
    await model.dispose();
    expect(native.hooks, isEmpty);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('content follows drag in the camera plane', (tester) async {
    final native = Native();
    final model = await loadFixture(native, boxGlb(boxDocument()));
    final size = math.sqrt(84);
    for (final yaw in [0.0, 90.0, -45.0]) {
      for (final pitch in [0.0, 30.0]) {
        final y = yaw * math.pi / 180;
        final p = pitch * math.pi / 180;
        final right = thermion.Vector3(math.cos(y), 0, -math.sin(y));
        final up = thermion.Vector3(
          -math.sin(p) * math.sin(y),
          math.cos(p),
          -math.sin(p) * math.cos(y),
        );
        for (final pan in [const Offset(0.1, 0.2), const Offset(-0.1, -0.2)]) {
          model.setCamera(
            Model3dCamera(
              yaw: yaw,
              pitch: pitch,
              target: const Model3dTarget.point((0, 0, 0)),
              pan: pan,
            ),
          );
          await tester.pump();
          final view = native.calls.lastWhere((c) => c.memberName == #lookAt);
          final focus = view.namedArguments[#focus] as thermion.Vector3;
          // The stationary model shifts opposite the camera's translation.
          expect(-focus.dot(right), closeTo(pan.dx * size, 1e-8));
          expect(focus.dot(up), closeTo(pan.dy * size, 1e-8));
        }
      }
    }
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'extras reconcile slots preserve authored roots spin and release',
    (tester) async {
      final native = Native();
      final requests = <String>[];
      final source = FilamentModel3dSource(
        keepAlive: Duration.zero,
        client: MockClient((request) async {
          requests.add(request.url.path);
          return request.url.path == '/bad.glb'
              ? http.Response('bad', 404)
              : http.Response.bytes(boxGlb(boxDocument()), 200);
        }),
        baseUrl: Uri.parse('http://host/'),
        diskCache: false,
        platform: Platform(native),
      );
      final model =
          await source.controllerFor(const Model3dRequest(src: '/primary.glb'))
              as FilamentModel3dController;
      const planet = Model3dSceneItem(
        src: '/planet.glb',
        position: (1, 2, 3),
        rotation: (yaw: 90, pitch: 0, roll: 0),
        scale: 2,
        clip: 'Wave',
        spin: (axis: 'x', speed: 90),
      );
      (model as Model3dSceneController).setScene([
        planet,
        const Model3dSceneItem(src: '/planet.glb'),
        const Model3dSceneItem(src: '/bad.glb'),
      ]);
      await finishLoad(model.initialize());
      await tester.runAsync(() async {
        for (var i = 0; i < 40 && native.assets.length < 3; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 2));
        }
      });
      await tester.pump();
      expect(native.assets, hasLength(3));
      expect(requests.where((p) => p == '/planet.glb'), hasLength(1));
      final extra = native.assets[1];
      expect(
        extra.calls.where(
          (c) =>
              c.memberName == #transformToUnitCube ||
              c.memberName == #setTransform,
        ),
        isEmpty,
      );
      final placement = native.parents[extra.entity]!;
      expect(native.parents[extra.entity + 1], placement);
      expect(native.parents[extra.entity + 2], placement);
      expect(native.transforms[placement]!.getTranslation().storage, [1, 2, 3]);
      expect(
        extra.calls
            .where((c) => c.memberName == #playGltfAnimation)
            .single
            .namedArguments[#loop],
        true,
      );
      expect(native.hooks, hasLength(1));
      await native.frame();
      final initial = native.transforms[placement]!.clone();
      await tester.pump(const Duration(milliseconds: 500));
      await native.frame();
      expect(native.transforms[placement], isNot(initial));
      await model.play('Jump', loop: false);
      await tester.pump(const Duration(seconds: 2));
      expect(
        native.calls.where(
          (c) =>
              c.memberName == #setRendering &&
              c.positionalArguments.first == false,
        ),
        isEmpty,
      );
      (model as Model3dSceneController).setScene([
        const Model3dSceneItem(
          src: '/planet.glb',
          position: (4, 5, 6),
          clip: 'Wave',
          spin: (axis: 'y', speed: 45),
        ),
        const Model3dSceneItem(src: '/planet.glb'),
      ]);
      await tester.pump();
      expect(native.assets, hasLength(3));
      expect(native.transforms[placement]!.getTranslation().storage, [4, 5, 6]);
      (model as Model3dLookController).setLook(
        const Model3dLook(
          light: Model3dLight(),
          shadow: Model3dShadow(type: Model3dShadowType.cast),
        ),
      );
      await tester.pump();
      expect(
        extra.calls
            .where((c) => c.memberName == #setCastShadows)
            .last
            .positionalArguments,
        [true],
      );
      (model as Model3dSceneController).setScene([
        const Model3dSceneItem(src: '/new.glb'),
      ]);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await tester.pump();
      expect(requests, contains('/new.glb'));
      expect(requests.where((p) => p == '/primary.glb'), hasLength(1));
      expect(native.destroyedEntities, contains(placement));
      await model.dispose();
      expect(native.hooks, isEmpty);
      expect(native.destroyedEntities, hasLength(3));
      expect(
        native.log.where((s) => s == 'destroyAsset'),
        hasLength(4),
      ); // 3 extras + contact
      await tester.pump(const Duration(seconds: 1));
    },
  );
}
