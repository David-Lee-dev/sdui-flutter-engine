import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_model_filament/sdui_model_filament.dart';

import 'support/filament_fakes.dart';

void main() {
  // RF-R1: every primary load path omits accessible geometry while picks remain supported.
  testWidgets(
    'warmup prefetch cold and reused loads omit geometry capabilities',
    (tester) async {
      final native = Native();
      final bytes = glb({
        'asset': {'version': '2.0'},
        'nodes': [
          {'name': 'Body', 'mesh': 0},
        ],
        'meshes': [
          {
            'primitives': [
              {'attributes': {}},
            ],
          },
        ],
      });
      final source = FilamentModel3dSource(
        client: MockClient((_) async => http.Response.bytes(bytes, 200)),
        baseUrl: Uri.parse('http://host/'),
        diskCache: false,
        prefetch: ['/warm.glb', '/prefetch.glb'],
        platform: Platform(native),
      );
      await source.warmUp();
      final models = <SduiModel3dController>[];
      for (final src in ['/warm.glb', '/prefetch.glb', '/cold.glb']) {
        final model = await source.controllerFor(Model3dRequest(src: src));
        await finishLoad(model.initialize());
        native.pickedEntity = native.assets[models.length].entity + 1;
        expect(
          (await (model as Model3dTapController).hitTest(Offset.zero))?.node,
          'Body',
        );
        models.add(model);
      }
      await models.first.dispose();
      final reused = await source.controllerFor(
        const Model3dRequest(src: '/warm.glb'),
      );
      await finishLoad(reused.initialize());
      expect(native.log.where((n) => n == 'loadGltfFromBuffer'), hasLength(3));
      for (final call in native.calls.where(
        (c) => c.memberName == #loadGltfFromBuffer,
      )) {
        expect(
          call.namedArguments[#requiredGeometryCapabilities] ?? const {},
          isEmpty,
        );
      }
      await reused.dispose();
      for (final model in models.skip(1)) {
        await model.dispose();
      }
      tester.binding.handleMemoryPressure();
      await tester.pump(const Duration(seconds: 11));
    },
  );

  testWidgets('uses the view MediaQuery scale', (tester) async {
    final native = Native();
    final source = FilamentModel3dSource(
      keepAlive: Duration.zero,
      client: MockClient(
        (_) async => http.Response.bytes(
          glb({
            'asset': {'version': '2.0'},
            'nodes': [
              {'name': 'Head', 'mesh': 0},
            ],
            'meshes': [
              {
                'primitives': [
                  {'attributes': {}},
                ],
              },
            ],
          }),
          200,
        ),
      ),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      platform: Platform(native),
    );
    final model =
        await source.controllerFor(const Model3dRequest(src: '/fixture.glb'))
            as FilamentModel3dController;
    // Mount before viewer creation to exercise the public view without a native texture.
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(devicePixelRatio: 2),
        child: model.buildView(),
      ),
    );
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(devicePixelRatio: 3),
        child: model.buildView(),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    await finishLoad(model.initialize());
    expect(
      (await (model as Model3dTapController).hitTest(
        const Offset(100, 100),
      ))?.node,
      'Head',
    );
    expect(native.log, contains('pick 300 300'));
    await (model as Model3dTapController).hitTest(const Offset(12.4, 34.6));
    expect(native.log, contains('pick 37 104'));
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('disposal resolves a pending pick while native work drains', (
    tester,
  ) async {
    final native = Native();
    final model = await loadFixture(
      native,
      glb({
        'asset': {'version': '2.0'},
        'nodes': [
          {'name': 'Head', 'mesh': 0},
        ],
        'meshes': [
          {
            'primitives': [
              {'attributes': {}},
            ],
          },
        ],
      }),
    );
    native.completePick = false;
    final pick = (model as Model3dTapController).hitTest(Offset.zero);
    Object? error;
    Model3dHit? hit;
    final observed = pick.then(
      (value) {
        hit = value;
      },
      onError: (Object e) {
        error = e;
      },
    );
    await tester.pump();
    native.hold('loadIbl');
    (model as Model3dLookController).setLook(const Model3dLook(environment: 2));
    await tester.pump();
    final disposed = model.dispose();
    native.pendingPick!((
      entity: 101,
      x: 0,
      y: 0,
      depth: 1.0,
      fragX: 0.0,
      fragY: 0.0,
      fragZ: 0.0,
    ));
    await tester.pump();
    native.release('loadIbl');
    await disposed;
    await observed;
    expect(error, isNull, reason: 'disposed picks must resolve as misses');
    expect(hit, isNull);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('unnamed renderable and ambiguous material stay null', (
    tester,
  ) async {
    final native = Native();
    final model = await loadFixture(
      native,
      glb({
        'asset': {'version': '2.0'},
        'nodes': [
          {'mesh': 0},
        ],
        'meshes': [
          {
            'primitives': [
              {'attributes': {}, 'material': 0},
              {'attributes': {}},
            ],
          },
        ],
        'materials': [
          {'name': 'Skin'},
        ],
      }),
    );
    final hit = await (model as Model3dTapController).hitTest(Offset.zero);
    expect(hit, isNotNull);
    expect(hit!.node, isNull);
    expect(hit.material, isNull);
    final load = native.calls.firstWhere(
      (c) => c.memberName == #loadGltfFromBuffer,
    );
    expect(
      load.namedArguments[#requiredGeometryCapabilities] ?? const {},
      isEmpty,
    );
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('pick maps names, miss, bounded completion and dispose', (
    tester,
  ) async {
    final native = Native();
    final model = await loadFixture(
      native,
      glb({
        'asset': {'version': '2.0'},
        'nodes': [
          {'name': 'Head', 'mesh': 0},
        ],
        'meshes': [
          {
            'primitives': [
              {
                'attributes': {'POSITION': 0},
                'material': 0,
              },
            ],
          },
        ],
        'materials': [
          {'name': 'Skin'},
        ],
      }),
    );
    final hit = await (model as Model3dTapController).hitTest(
      const Offset(12, 34),
    );
    expect(hit?.node, 'Head');
    expect(hit?.material, 'Skin');
    expect(native.log, contains('pick 12 34'));
    native.pickedEntity = null;
    expect(await (model as Model3dTapController).hitTest(Offset.zero), isNull);
    native.completePick = false;
    final pending = (model as Model3dTapController).hitTest(Offset.zero);
    await tester.pump(const Duration(seconds: 1));
    expect(await pending, isNull);
    final lateHandler = native.pendingPick!;
    await model.dispose();
    lateHandler((
      entity: 101,
      x: 0,
      y: 0,
      depth: 1.0,
      fragX: 0.0,
      fragY: 0.0,
      fragZ: 0.0,
    ));
    expect(await (model as Model3dTapController).hitTest(Offset.zero), isNull);
    await tester.pump(const Duration(seconds: 1));
  });
}
