import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_model_filament/sdui_model_filament.dart';
import 'package:thermion_flutter/thermion_flutter.dart' as thermion;

import 'support/filament_fakes.dart';

void main() {
  testWidgets('concurrent views share bytes but own private assets', (
    tester,
  ) async {
    final native = Native();
    var fetches = 0;
    final source = FilamentModel3dSource(
      client: MockClient((_) async {
        fetches++;
        return http.Response.bytes([1], 200);
      }),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      platform: Platform(native),
    );
    final a = await source.controllerFor(const Model3dRequest(src: '/a.glb'));
    final b = await source.controllerFor(const Model3dRequest(src: '/a.glb'));
    await finishLoad(
      Future.wait([a.initialize(), b.initialize()]).then((_) {}),
    );
    expect(fetches, 1);
    expect(native.assets, hasLength(2));
    expect(native.log.where((n) => n == 'loadGltfFromBuffer'), hasLength(2));
    await a.dispose();
    await b.play('Wave', loop: true);
    expect(b.playback.isPlaying, isTrue);
    await b.dispose();
    await tester.pump(const Duration(seconds: 11));
  });

  testWidgets('remount reuses private viewer, disables rendering and expires', (
    tester,
  ) async {
    final native = Native();
    final source = FilamentModel3dSource(
      client: MockClient((_) async => http.Response.bytes([1], 200)),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      platform: Platform(native),
    );
    final a = await source.controllerFor(const Model3dRequest(src: '/a.glb'));
    await finishLoad(a.initialize());
    await a.dispose();
    expect(native.log.where((n) => n == 'release'), isEmpty);
    expect(
      native.calls
          .lastWhere((c) => c.memberName == #setRendering)
          .positionalArguments,
      [false],
    );
    final b = await source.controllerFor(const Model3dRequest(src: '/a.glb'));
    await finishLoad(b.initialize());
    expect(native.log.where((n) => n == 'createViewer'), hasLength(1));
    expect(native.log.where((n) => n == 'loadGltfFromBuffer'), hasLength(1));
    await b.dispose();
    await tester.pump(const Duration(seconds: 11));
    expect(native.log.where((n) => n == 'release'), hasLength(1));
    final c = await source.controllerFor(const Model3dRequest(src: '/a.glb'));
    await finishLoad(c.initialize());
    expect(native.log.where((n) => n == 'createViewer'), hasLength(2));
    await c.dispose();
    await tester.pump(const Duration(seconds: 11));
  });

  testWidgets('memory pressure releases kept viewers', (tester) async {
    final native = Native();
    final source = FilamentModel3dSource(
      client: MockClient((_) async => http.Response.bytes([1], 200)),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      platform: Platform(native),
    );
    final model = await source.controllerFor(
      const Model3dRequest(src: '/a.glb'),
    );
    await finishLoad(model.initialize());
    await model.dispose();
    tester.binding.handleMemoryPressure();
    await tester.pump();
    expect(native.log.where((n) => n == 'release'), hasLength(1));
    await tester.pump(const Duration(seconds: 11));
    expect(native.log.where((n) => n == 'release'), hasLength(1));
  });

  testWidgets('warm-up viewer is handed to first mount', (tester) async {
    final native = Native();
    final source = FilamentModel3dSource(
      client: MockClient((_) async => http.Response.bytes([1], 200)),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      platform: Platform(native),
    );
    await source.warmUp();
    final model = await source.controllerFor(
      const Model3dRequest(src: '/a.glb'),
    );
    await finishLoad(model.initialize());
    expect(native.log.where((n) => n == 'createViewer'), hasLength(1));
    expect(native.log, isNot(contains('dispose')));
    await model.dispose();
    await tester.pump(const Duration(seconds: 11));
  });

  testWidgets(
    'prefetch parses ahead within cachedModels and preserves warm handoff',
    (tester) async {
      final native = Native();
      final fetched = <String>[];
      final source = FilamentModel3dSource(
        client: MockClient((r) async {
          fetched.add(r.url.path);
          return http.Response.bytes([1], 200);
        }),
        baseUrl: Uri.parse('http://host/'),
        prefetch: ['/a.glb', '/b.glb', '/c.glb'],
        cachedModels: 2,
        diskCache: false,
        platform: Platform(native),
      );
      await source.warmUp();
      expect(native.log.where((n) => n == 'loadGltfFromBuffer'), hasLength(2));
      expect(fetched, ['/a.glb', '/b.glb']);
      final b = await source.controllerFor(const Model3dRequest(src: '/b.glb'));
      await finishLoad(b.initialize());
      expect(native.log.where((n) => n == 'loadGltfFromBuffer'), hasLength(2));
      final c = await source.controllerFor(const Model3dRequest(src: '/c.glb'));
      await finishLoad(c.initialize());
      expect(native.log.where((n) => n == 'createViewer'), hasLength(2));
      expect(native.log.where((n) => n == 'destroyAsset'), hasLength(1));
      expect(native.log.where((n) => n == 'loadGltfFromBuffer'), hasLength(3));
      await b.dispose();
      await c.dispose();
      await tester.pump(const Duration(seconds: 11));
    },
  );

  testWidgets('restores authored state and viewer look before reuse', (
    tester,
  ) async {
    final native = Native();
    final bytes = glb({
      'asset': {'version': '2.0'},
      'nodes': [
        {
          'name': 'Face',
          'mesh': 0,
          'weights': [0.25, 0.5],
        },
        {'name': 'Body', 'mesh': 1},
      ],
      'meshes': [
        {
          'primitives': [
            {'attributes': {}, 'material': 0},
          ],
          'weights': [0.9, 0.9],
        },
        {
          'primitives': [
            {'attributes': {}, 'material': 0},
          ],
          'weights': [0.75],
        },
      ],
      'materials': [
        {
          'name': 'paint',
          'pbrMetallicRoughness': {
            'baseColorFactor': [0.2, 0.3, 0.4, 1],
          },
        },
      ],
    });
    final source = FilamentModel3dSource(
      client: MockClient((_) async => http.Response.bytes(bytes, 200)),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      platform: Platform(native),
    );
    final a = await source.controllerFor(const Model3dRequest(src: '/a.glb'));
    await finishLoad(a.initialize());
    (a as Model3dMotionController).setMorphs({'smile': 1, 'blink': 1});
    (a as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        hide: ['Face'],
        colors: {'paint': Color(0xffff0000)},
        transition: Model3dOutfitTransition.cut,
      ),
    );
    (a as Model3dLookController).setLook(
      const Model3dLook(
        environment: 0.2,
        environmentRotation: 90,
        quality: Model3dQuality.high,
      ),
    );
    await tester.pump();
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    native.transforms[101] = thermion.Matrix4.translationValues(9, 8, 7);
    await a.dispose();
    final b = await source.controllerFor(const Model3dRequest(src: '/a.glb'));
    await finishLoad(b.initialize());
    expect(native.log.where((n) => n == 'loadGltfFromBuffer'), hasLength(1));
    await native.frame();
    await tester.pump(const Duration(milliseconds: 2));
    expect(native.transforms[101]!.getTranslation(), thermion.Vector3.zero());
    expect(native.morphWeights[(101, 'smile')], 0.25);
    expect(native.morphWeights[(101, 'blink')], 0.5);
    expect(native.morphWeights[(102, 'smile')], 0.75);
    expect(native.visible, contains(101));
    expect(native.materialColors[(101, 0)], [0.2, 0.3, 0.4, 1]);
    expect(
      native.calls
          .lastWhere((c) => c.memberName == #rotateIbl)
          .positionalArguments,
      [thermion.Matrix3.identity()],
    );
    expect(
      native.calls
          .lastWhere((c) => c.memberName == #setRenderQuality)
          .positionalArguments,
      [thermion.QualityLevel.MEDIUM],
    );
    expect(
      (native.calls
                  .lastWhere((c) => c.memberName == #setAmbientOcclusionOptions)
                  .positionalArguments
                  .single
              as thermion.AmbientOcclusionOptions)
          .enabled,
      isFalse,
    );
    expect(
      native.calls
          .lastWhere((c) => c.memberName == #loadIbl)
          .namedArguments[#intensity],
      source.iblIntensity,
    );
    await b.dispose();
    await tester.pump(const Duration(seconds: 11));
  });

  testWidgets('retains at most two disposed viewers', (tester) async {
    final native = Native();
    final source = FilamentModel3dSource(
      client: MockClient((_) async => http.Response.bytes([1], 200)),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      platform: Platform(native),
    );
    for (final src in ['/a.glb', '/b.glb', '/c.glb']) {
      final model = await source.controllerFor(Model3dRequest(src: src));
      await finishLoad(model.initialize());
      await model.dispose();
    }
    expect(native.log.where((n) => n == 'release'), hasLength(1));
    await tester.pump(const Duration(seconds: 11));
    expect(native.log.where((n) => n == 'release'), hasLength(3));
  });

  testWidgets('releases viewer if disabling rendering fails', (tester) async {
    final native = Native();
    final source = FilamentModel3dSource(
      client: MockClient((_) async => http.Response.bytes([1], 200)),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      platform: Platform(native),
    );
    final model = await source.controllerFor(
      const Model3dRequest(src: '/a.glb'),
    );
    await finishLoad(model.initialize());
    native.fail = 'setRendering';
    await expectLater(model.dispose(), throwsStateError);
    expect(native.log.where((n) => n == 'release'), hasLength(1));
    await tester.pump(const Duration(seconds: 11));
  });

  testWidgets('failed prefetch releases viewer and does not block mount', (
    tester,
  ) async {
    final native = Native()..fail = 'loadGltfFromBuffer';
    final source = FilamentModel3dSource(
      client: MockClient((_) async => http.Response.bytes([1], 200)),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      prefetch: ['/a.glb'],
      platform: Platform(native),
    );
    await expectLater(source.warmUp(), throwsStateError);
    expect(native.log.where((n) => n == 'release'), hasLength(1));
    final model = await source.controllerFor(
      const Model3dRequest(src: '/a.glb'),
    );
    await finishLoad(model.initialize());
    expect(native.log.where((n) => n == 'createViewer'), hasLength(2));
    await model.dispose();
    await tester.pump(const Duration(seconds: 11));
  });

  testWidgets('kept asset survives byte cache eviction', (tester) async {
    final native = Native();
    var fetches = 0;
    final source = FilamentModel3dSource(
      client: MockClient((_) async {
        fetches++;
        return http.Response.bytes([1], 200);
      }),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      cachedModels: 1,
      platform: Platform(native),
    );
    for (final src in ['/a.glb', '/b.glb', '/a.glb']) {
      final model = await source.controllerFor(Model3dRequest(src: src));
      await finishLoad(model.initialize());
      await model.dispose();
    }
    expect(fetches, 2);
    expect(native.log.where((n) => n == 'loadGltfFromBuffer'), hasLength(2));
    await tester.pump(const Duration(seconds: 11));
  });

  testWidgets(
    'memory pressure releases unused prefetch but preserves active viewers',
    (tester) async {
      final native = Native();
      final source = FilamentModel3dSource(
        client: MockClient((_) async => http.Response.bytes([1], 200)),
        baseUrl: Uri.parse('http://host/'),
        diskCache: false,
        prefetch: ['/a.glb', '/b.glb', '/c.glb'],
        platform: Platform(native),
      );
      await source.warmUp();
      final model = await source.controllerFor(
        const Model3dRequest(src: '/b.glb'),
      );
      await finishLoad(model.initialize());
      tester.binding.handleMemoryPressure();
      await tester.pump();
      expect(native.log.where((n) => n == 'release'), hasLength(2));
      await model.play('Wave', loop: true);
      expect(model.playback.isPlaying, isTrue);
      await model.dispose();
      tester.binding.handleMemoryPressure();
      await tester.pump(const Duration(seconds: 11));
      expect(native.log.where((n) => n == 'release'), hasLength(3));
    },
  );
}
