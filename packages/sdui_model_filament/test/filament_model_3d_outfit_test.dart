import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_model_filament/sdui_model_filament.dart';
import 'package:thermion_flutter/thermion_flutter.dart' as thermion;

import 'support/filament_fakes.dart';

void main() {
  testWidgets(
    'attached textured prop loads without replacing authored material',
    (tester) async {
      final native = Native();
      final paths = <String>[];
      final primary = glb({
        'asset': {'version': '2.0'},
        'nodes': [
          {'name': 'Head'},
        ],
      });
      final prop = glb({
        'asset': {'version': '2.0'},
        'nodes': [
          {'name': 'Hat', 'mesh': 0},
        ],
        'meshes': [
          {
            'primitives': [
              {'attributes': {}, 'material': 0},
            ],
          },
        ],
        'materials': [
          {
            'pbrMetallicRoughness': {
              'baseColorTexture': {'index': 0},
            },
          },
        ],
        'textures': [
          {'source': 0},
        ],
        'images': [
          {'uri': 'skin.png'},
        ],
      });
      final source = FilamentModel3dSource(
        keepAlive: Duration.zero,
        client: MockClient((request) async {
          paths.add(request.url.path);
          return http.Response.bytes(
            request.url.path == '/primary/model.glb' ? primary : prop,
            200,
          );
        }),
        baseUrl: Uri.parse('http://host/'),
        diskCache: false,
        platform: Platform(native),
      );
      final model =
          await source.controllerFor(
                const Model3dRequest(src: '/primary/model.glb'),
              )
              as FilamentModel3dController;
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(attach: const {'Head': '/props/hat.glb'}),
      );
      await finishLoad(model.initialize());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pumpAndSettle();
      expect(paths, contains('/props/hat.glb'));
      expect(native.assets, hasLength(2));
      expect(native.swaps, isEmpty);
      expect(paths, isNot(contains('/primary/skin.png')));
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets('outfit colour changes preserve authored material instances', (
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
                'attributes': {'COLOR_0': 0},
                'material': 0,
              },
              {'attributes': {}},
            ],
          },
        ],
        'materials': [
          {
            'name': 'Skin',
            'alphaMode': 'MASK',
            'alphaCutoff': 0.3,
            'pbrMetallicRoughness': {
              'baseColorFactor': [0.2, 0.3, 0.4, 0.5],
              'baseColorTexture': {'index': 0},
            },
          },
        ],
        'textures': [
          {'source': 0},
        ],
        'images': [
          {'uri': 'data:image/png;base64,AA=='},
        ],
      }),
    );
    await tester.pumpAndSettle();
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        colors: const {'Skin': Color(0xffff0000)},
        transition: Model3dOutfitTransition.cut,
      ),
    );
    await tester.pumpAndSettle();
    (model as Model3dLookController).setLook(const Model3dLook());
    await tester.pumpAndSettle();
    expect(native.swaps, isEmpty);
    expect(native.materialColors[(101, 0)], [1, 0, 0, 1]);
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('preserves unparseable model bytes', (tester) async {
    final original = boxGlb(boxDocument());
    final length = ByteData.sublistView(original).getUint32(12, Endian.little);
    final fixtures = <Uint8List>[];
    for (final prefix in [
      <int>[],
      <int>[0xef, 0xbb, 0xbf],
    ]) {
      // A full extra padding word ensures the NUL follows complete JSON.
      final bytes = Uint8List(original.length + 4 + prefix.length);
      bytes.setRange(0, 20, original);
      bytes.setRange(20, 20 + prefix.length, prefix);
      bytes.setRange(
        20 + prefix.length,
        20 + prefix.length + length,
        original.sublist(20, 20 + length),
      );
      bytes.setRange(
        24 + prefix.length + length,
        bytes.length,
        original.sublist(20 + length),
      );
      final header = ByteData.sublistView(bytes);
      header.setUint32(8, bytes.length, Endian.little);
      header.setUint32(12, length + prefix.length + 4, Endian.little);
      fixtures.add(bytes);
    }
    for (final (offset, value) in [(12, original.length), (4, 1), (16, 0)]) {
      final bytes = Uint8List.fromList(original);
      ByteData.sublistView(bytes).setUint32(offset, value, Endian.little);
      fixtures.add(bytes);
    }
    final invalidUtf8 = Uint8List.fromList(original)..[20] = 0xff;
    fixtures.add(invalidUtf8);
    final invalidJson = Uint8List.fromList(original)..[20] = 0x21;
    fixtures.add(invalidJson);
    for (final (index, bytes) in fixtures.indexed) {
      for (final withOutfit in [false, true]) {
        final native = Native();
        final source = FilamentModel3dSource(
          keepAlive: Duration.zero,
          client: MockClient((_) async => http.Response.bytes(bytes, 200)),
          baseUrl: Uri.parse('http://host/'),
          diskCache: false,
          platform: Platform(native),
        );
        final model = await source.controllerFor(
          const Model3dRequest(src: '/fixture.glb'),
        );
        if (withOutfit) {
          (model as Model3dOutfitController).setOutfit(
            Model3dOutfit(hide: ['missing']),
          );
        }
        Object? error;
        try {
          await finishLoad(model.initialize());
        } catch (failure) {
          error = failure;
        }
        await model.dispose();
        expect(error, isNull, reason: 'fixture $index outfit $withOutfit');
        final loads = native.calls.where(
          (c) => c.memberName == #loadGltfFromBuffer,
        );
        expect(
          loads,
          hasLength(1),
          reason: 'fixture $index outfit $withOutfit',
        );
        expect(loads.single.positionalArguments.first, orderedEquals(bytes));
        await tester.pump(const Duration(seconds: 1));
      }
    }
  });

  testWidgets('waits for pending prop materials', (tester) async {
    final native = Native();
    final primary = boxDocument();
    primary['nodes'][0]['name'] = 'Head';
    final prop = boxDocument();
    prop['materials'] = [
      <String, dynamic>{'name': 'hat'},
    ];
    prop['meshes'] = [
      {
        'primitives': [
          <String, dynamic>{
            'attributes': {'POSITION': 0},
            'material': 0,
          },
        ],
      },
    ];
    final slow = Completer<void>();
    final source = FilamentModel3dSource(
      keepAlive: Duration.zero,
      client: MockClient((request) async {
        if (request.url.path == '/hat.glb') {
          await slow.future;
          return http.Response.bytes(boxGlb(prop), 200);
        }
        return http.Response.bytes(boxGlb(primary), 200);
      }),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      platform: Platform(native),
    );
    final model =
        await source.controllerFor(const Model3dRequest(src: '/primary.glb'))
            as FilamentModel3dController;
    await finishLoad(model.initialize());
    final previous = debugPrint;
    final messages = <String?>[];
    debugPrint = (String? message, {int? wrapWidth}) => messages.add(message);
    try {
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(
          attach: {'Head': '/hat.glb'},
          colors: {
            'hat': const Color(0xFFFF0000),
            'missing': const Color(0xFF000000),
          },
          transition: Model3dOutfitTransition.cut,
        ),
      );
      await tester.pump();
      expect(messages.where((m) => m!.contains('material')), isEmpty);
      // A second snapshot while the same slot is pending must also wait.
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(
          attach: {'Head': '/hat.glb'},
          colors: {
            'hat': const Color(0xFF00FF00),
            'missing': const Color(0xFF000000),
          },
          transition: Model3dOutfitTransition.cut,
        ),
      );
      await tester.pump();
      expect(messages.where((m) => m!.contains('material')), isEmpty);
      slow.complete();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
      expect(
        messages,
        isNot(contains('[sdui_model_filament] outfit material "hat" ignored')),
      );
      expect(
        messages,
        contains('[sdui_model_filament] outfit material "missing" ignored'),
      );
      expect(native.assets, hasLength(2));
      final propEntity = native.assets.last.entity + 1;
      expect(native.materialColors[(propEntity, 0)], [0, 1, 0, 1]);
    } finally {
      debugPrint = previous;
      if (!slow.isCompleted) slow.complete();
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    }
  });

  testWidgets('uses the nearest explicit ancestor', (tester) async {
    final native = Native();
    final doc = boxDocument();
    doc['nodes'] = [
      <String, dynamic>{
        'name': 'group',
        'children': [1],
      },
      <String, dynamic>{
        'name': 'shirt',
        'mesh': 0,
        'children': [2],
      },
      <String, dynamic>{'name': 'badge', 'mesh': 0},
    ];
    final model = await loadFixture(native, boxGlb(doc));
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        show: ['group'],
        hide: ['shirt'],
        transition: Model3dOutfitTransition.cut,
      ),
    );
    await tester.pump();
    expect(native.log, contains('hide 102'));
    expect(native.log, contains('hide 103'));
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        show: ['group', 'badge'],
        hide: ['shirt', 'badge'],
        transition: Model3dOutfitTransition.cut,
      ),
    );
    await tester.pump();
    expect(native.visible, isNot(contains(102)));
    expect(native.visible, contains(103));
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('flashes isolated parts and pulses the primary root', (
    tester,
  ) async {
    for (final type in [
      Model3dOutfitTransition.pop,
      Model3dOutfitTransition.drop,
      Model3dOutfitTransition.dissolve,
    ]) {
      final native = Native();
      final doc = boxDocument();
      doc['nodes'] = [
        <String, dynamic>{'name': 'shirt', 'mesh': 0, 'skin': 0},
        <String, dynamic>{'name': 'trousers', 'mesh': 0, 'skin': 0},
        <String, dynamic>{'name': 'joint'},
        <String, dynamic>{'name': 'rigid', 'mesh': 0},
      ];
      doc['skins'] = [
        {
          'joints': [2],
        },
      ];
      doc['scenes'] = [
        {
          'nodes': [0, 1, 2, 3],
        },
      ];
      doc['materials'] = [
        {
          'name': 'cloth',
          'emissiveFactor': [0.1, 0.2, 0.3],
        },
      ];
      doc['meshes'] = [
        {
          'primitives': [
            for (var i = 0; i < 2; i++)
              <String, dynamic>{
                'attributes': {'POSITION': 0},
                'material': 0,
              },
          ],
        },
      ];
      final model = await loadFixture(
        native,
        boxGlb(doc),
        initialOutfit: Model3dOutfit(hide: ['shirt', 'rigid']),
      );
      expect(native.hooks, isEmpty);
      expect(native.materialEmissives, isEmpty);
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(
          show: ['shirt', 'rigid'],
          transition: type,
          duration: const Duration(milliseconds: 100),
        ),
      );
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await native.frame();
      expect(native.materialEmissives[(101, 0)]?.first, greaterThan(0.1));
      expect(native.materialEmissives[(101, 1)]?.first, greaterThan(0.1));
      expect(native.materialEmissives.containsKey((102, 0)), isFalse);
      final root = native.parents[100]!;
      expect(native.parents[101], root);
      expect(native.parents[103], root); // Joints, not just mesh nodes, move.
      expect(
        native.transforms[root]!.entry(0, 0),
        allOf(greaterThan(1), lessThanOrEqualTo(1.04)),
      );
      final load = native.calls.firstWhere(
        (c) => c.memberName == #loadGltfFromBuffer,
      );
      final bytes = load.positionalArguments.first as Uint8List;
      final length = ByteData.sublistView(bytes).getUint32(12, Endian.little);
      final prepared =
          jsonDecode(utf8.decode(bytes.sublist(20, 20 + length))) as Map;
      final meshes = prepared['meshes'] as List;
      final nodes = prepared['nodes'] as List;
      expect(
        meshes[nodes[0]['mesh']]['primitives'][0]['material'],
        isNot(meshes[nodes[1]['mesh']]['primitives'][0]['material']),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 110)),
      );
      await native.frame();
      await tester.pump();
      expect(native.materialEmissives[(101, 0)], [0.1, 0.2, 0.3, 1]);
      expect(native.parents[100], isNull);
      expect(native.parents[103], isNull);
      expect(native.parents[104], isNull);
      expect(native.destroyedEntities, contains(root));
      expect(native.hooks, isEmpty);
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(
          hide: ['shirt', 'rigid'],
          duration: const Duration(milliseconds: 50),
        ),
      );
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 70)),
      );
      await native.frame();
      await tester.pump();
      expect(native.visible, isNot(contains(101)));
      expect(native.materialEmissives[(101, 0)], [0.1, 0.2, 0.3, 1]);
      expect(native.parents[104], isNull);
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(transition: Model3dOutfitTransition.cut),
      );
      await tester.pump();
      // Interrupt an exit: the old emissive and root placement must settle.
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(
          hide: ['shirt', 'rigid'],
          duration: const Duration(seconds: 10),
        ),
      );
      await tester.pump();
      final exitingRoot = native.parents[100]!;
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(transition: Model3dOutfitTransition.cut),
      );
      await tester.pump();
      expect(native.visible, contains(101));
      expect(native.materialEmissives[(101, 0)], [0.1, 0.2, 0.3, 1]);
      expect(native.destroyedEntities, contains(exitingRoot));
      // Disposal also settles an in-flight flash without leaking a root.
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(
          hide: ['shirt', 'rigid'],
          duration: const Duration(seconds: 10),
        ),
      );
      await tester.pump();
      final disposingRoot = native.parents[100]!;
      await model.dispose();
      expect(native.materialEmissives[(101, 0)], [0.1, 0.2, 0.3, 1]);
      expect(native.destroyedEntities, contains(disposingRoot));
      expect(native.hooks, isEmpty);
      await tester.pump(const Duration(seconds: 1));
    }
  });

  testWidgets('BLEND dissolve keeps fading and cut is immediate', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    doc['nodes'] = [
      <String, dynamic>{'name': 'shirt', 'mesh': 0, 'skin': 0},
      <String, dynamic>{'name': 'joint'},
    ];
    doc['skins'] = [
      {
        'joints': [1],
      },
    ];
    doc['materials'] = [
      {'name': 'cloth', 'alphaMode': 'BLEND'},
    ];
    doc['meshes'] = [
      {
        'primitives': [
          <String, dynamic>{
            'attributes': {'POSITION': 0},
            'material': 0,
          },
        ],
      },
    ];
    final model = await loadFixture(
      native,
      boxGlb(doc),
      initialOutfit: Model3dOutfit(hide: ['shirt']),
    );
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        show: ['shirt'],
        transition: Model3dOutfitTransition.dissolve,
        duration: const Duration(milliseconds: 100),
      ),
    );
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await native.frame();
    expect(
      native.materialColors[(101, 0)]![3],
      allOf(greaterThan(0), lessThan(1)),
    );
    expect(native.materialEmissives, isEmpty);
    expect(native.parents[100], isNull);
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(hide: ['shirt'], transition: Model3dOutfitTransition.cut),
    );
    await tester.pump();
    expect(native.hooks, isEmpty);
    expect(native.visible, isNot(contains(101)));
    expect(native.materialColors[(101, 0)], [1, 1, 1, 1]);
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('updates loaded and exiting props', (tester) async {
    final native = Native();
    final doc = boxDocument();
    doc['nodes'][0]['name'] = 'Head';
    final model = await loadFixture(native, boxGlb(doc));
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        attach: {'Head': '/hat.glb'},
        transition: Model3dOutfitTransition.cut,
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
    final prop = native.assets.last;
    prop.calls.clear();
    (model as Model3dLookController).setLook(
      const Model3dLook(
        light: Model3dLight(),
        shadow: Model3dShadow(type: Model3dShadowType.cast),
      ),
    );
    await tester.pump();
    for (final name in [#setCastShadows, #setReceiveShadows]) {
      expect(
        prop.calls
            .where((c) => c.memberName == name)
            .map((c) => c.positionalArguments.single),
        contains(true),
      );
    }
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(duration: const Duration(seconds: 10)),
    );
    await tester.pump();
    prop.calls.clear();
    (model as Model3dLookController).setLook(const Model3dLook());
    await tester.pump();
    for (final name in [#setCastShadows, #setReceiveShadows]) {
      expect(
        prop.calls
            .where((c) => c.memberName == name)
            .map((c) => c.positionalArguments.single),
        contains(false),
      );
    }
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('keeps drop in primary world units', (tester) async {
    for (final scale in [0.01, 3.0]) {
      final native = Native();
      final doc = boxDocument();
      doc['nodes'][0]['name'] = 'shirt';
      final model = await loadFixture(
        native,
        boxGlb(doc),
        initialOutfit: Model3dOutfit(hide: ['shirt']),
      );
      native.parents[101] = 500;
      native.transforms[500] = thermion.Matrix4.rotationZ(math.pi / 2)
        ..scaleByDouble(scale, scale, scale, 1);
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(
          show: ['shirt'],
          transition: Model3dOutfitTransition.drop,
          duration: const Duration(seconds: 10),
        ),
      );
      await tester.pump();
      final placement = native.parents[101]!;
      final world = await App(native).getWorldTransform(placement);
      expect(world.getTranslation().x, closeTo(0, 1e-8));
      expect(world.getTranslation().y, closeTo(8, 1e-8));
      await model.dispose();
      expect(native.parents[101], 500);
      await tester.pump(const Duration(seconds: 1));
    }
  });

  testWidgets('converts RGB to linear and preserves alpha', (tester) async {
    final native = Native();
    final doc = boxDocument();
    doc['materials'] = [
      {
        'name': 'cloth',
        'pbrMetallicRoughness': {
          'baseColorFactor': [0.2, 0.3, 0.4, 0.8],
        },
      },
    ];
    doc['meshes'] = [
      {
        'primitives': [
          <String, dynamic>{
            'attributes': {'POSITION': 0},
            'material': 0,
          },
        ],
      },
    ];
    final model = await loadFixture(native, boxGlb(doc));
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        colors: {'cloth': const Color(0x808008FF)},
        transition: Model3dOutfitTransition.cut,
      ),
    );
    await tester.pump();
    final color = native.materialColors[(101, 0)]!;
    expect(color[0], closeTo(0.2158605001, 1e-8));
    expect(color[1], closeTo((8 / 255) / 12.92, 1e-8));
    expect(color[2], 1);
    expect(color[3], closeTo(128 / 255, 1e-8));
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(transition: Model3dOutfitTransition.cut),
    );
    await tester.pump();
    expect(native.materialColors[(101, 0)], [0.2, 0.3, 0.4, 0.8]);
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('named groups include descendants and show wins over hide', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    doc['nodes'] = [
      <String, dynamic>{
        'name': 'group',
        'children': [1],
      },
      <String, dynamic>{'name': 'shirt', 'mesh': 0},
    ];
    final model = await loadFixture(native, boxGlb(doc));
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(hide: ['group'], transition: Model3dOutfitTransition.cut),
    );
    await tester.pump();
    expect(native.log, contains('hide 102'));
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        hide: ['group'],
        show: ['shirt'],
        transition: Model3dOutfitTransition.cut,
      ),
    );
    await tester.pump();
    expect(native.visible, contains(102));
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(transition: Model3dOutfitTransition.cut),
    );
    await tester.pump();
    expect(native.visible, contains(102));
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('existing attached prop recolours without reloading', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'Head';
    doc['materials'] = [
      {'name': 'cloth'},
    ];
    doc['meshes'] = [
      {
        'primitives': [
          {
            'attributes': {'POSITION': 0},
            'material': 0,
          },
        ],
      },
    ];
    final model = await loadFixture(native, boxGlb(doc));
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        attach: {'Head': '/hat.glb'},
        transition: Model3dOutfitTransition.cut,
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump();
    final propEntity = native.assets.last.entity + 1;
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        attach: {'Head': '/hat.glb'},
        colors: {'cloth': const Color(0xFFFF0000)},
        transition: Model3dOutfitTransition.cut,
      ),
    );
    await tester.pump();
    expect(native.materialColors[(propEntity, 0)], [1, 0, 0, 1]);
    expect(native.assets, hasLength(2));
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('stale prop bytes never reach a removed or disposed viewer', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'Head';
    final slow = Completer<void>();
    final source = FilamentModel3dSource(
      keepAlive: Duration.zero,
      client: MockClient((request) async {
        if (request.url.path == '/slow.glb') await slow.future;
        return http.Response.bytes(boxGlb(doc), 200);
      }),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      platform: Platform(native),
    );
    final model =
        await source.controllerFor(const Model3dRequest(src: '/primary.glb'))
            as FilamentModel3dController;
    await finishLoad(model.initialize());
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(attach: {'Head': '/slow.glb'}),
    );
    await tester.pump();
    (model as Model3dOutfitController).setOutfit(Model3dOutfit());
    await tester.pump();
    await model.dispose();
    slow.complete();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(native.assets, hasLength(1));
    expect(native.hooks, isEmpty);
  });

  testWidgets(
    'opaque dissolve falls back to pop and interruption restores parents',
    (tester) async {
      final native = Native();
      final doc = boxDocument();
      (doc['nodes'] as List).first['name'] = 'shirt';
      final model = await loadFixture(
        native,
        boxGlb(doc),
        initialOutfit: Model3dOutfit(hide: ['shirt']),
      );
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(
          show: ['shirt'],
          transition: Model3dOutfitTransition.dissolve,
          duration: const Duration(seconds: 10),
        ),
      );
      await tester.pump();
      final parent = native.parents[101]!;
      expect(native.transforms[parent]!.entry(0, 0), closeTo(0, 1e-9));
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(hide: ['shirt'], transition: Model3dOutfitTransition.cut),
      );
      await tester.pump();
      expect(native.destroyedEntities, contains(parent));
      expect(native.parents[101], isNull);
      expect(native.visible, isNot(contains(101)));
      expect(native.hooks, isEmpty);
      expect(native.assets, hasLength(1));
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets('BLEND isolation preserves node indices and named lookup', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    doc['nodes'] = [
      <String, dynamic>{'name': 'shirt', 'mesh': 0},
      <String, dynamic>{'name': 'shirt', 'mesh': 0},
      <String, dynamic>{'mesh': 0},
    ];
    doc['scenes'] = [
      {
        'nodes': [0, 1, 2],
      },
    ];
    doc['materials'] = [
      {'name': 'cloth', 'alphaMode': 'BLEND'},
    ];
    doc['meshes'] = [
      {
        'primitives': [
          {
            'attributes': {'POSITION': 0},
            'material': 0,
          },
        ],
      },
    ];
    final model = await loadFixture(native, boxGlb(doc));
    final load = native.calls.firstWhere(
      (c) => c.memberName == #loadGltfFromBuffer,
    );
    final bytes = load.positionalArguments.first as Uint8List;
    final length = ByteData.sublistView(bytes).getUint32(12, Endian.little);
    final prepared =
        jsonDecode(utf8.decode(bytes.sublist(20, 20 + length))) as Map;
    final nodes = prepared['nodes'] as List;
    expect(nodes.first['name'], 'shirt');
    expect(nodes.map((n) => n['name']).toSet(), hasLength(3));
    expect((prepared['scenes'] as List).first['nodes'], [0, 1, 2]);
    final materials = [
      for (final node in nodes)
        (prepared['meshes'] as List)[node['mesh']]['primitives'][0]['material'],
    ];
    expect(materials.toSet(), hasLength(3));
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(hide: ['shirt'], transition: Model3dOutfitTransition.cut),
    );
    await tester.pump();
    expect(native.log.where((s) => s.startsWith('hide ')), ['hide 101']);
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('disposal releases active placements and attached props', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'Head';
    final model = await loadFixture(native, boxGlb(doc));
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        attach: {'Head': '/hat.glb'},
        transition: Model3dOutfitTransition.cut,
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
    final prop = native.assets.last;
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        hide: ['Head'],
        attach: {'Head': '/hat.glb'},
        duration: const Duration(seconds: 10),
      ),
    );
    await tester.pump();
    final transitionParent = native.parents[101]!;
    expect(native.hooks, isNotEmpty);
    await model.dispose();
    expect(native.hooks, isEmpty);
    expect(native.destroyedEntities, contains(transitionParent));
    expect(
      native.calls
          .where((c) => c.memberName == #destroyAsset)
          .map((c) => c.positionalArguments.single),
      contains(prop),
    );
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'first outfit cuts and later swaps animate placement parents and colors',
    (tester) async {
      for (final type in Model3dOutfitTransition.values) {
        final native = Native();
        final doc = boxDocument();
        (doc['nodes'] as List).first['name'] = 'shirt';
        doc['materials'] = [
          {'name': 'cloth', 'alphaMode': 'BLEND'},
        ];
        doc['meshes'] = [
          {
            'primitives': [
              <String, dynamic>{
                'attributes': {'POSITION': 0},
                'material': 0,
              },
            ],
          },
        ];
        final model = await loadFixture(
          native,
          boxGlb(doc),
          initialOutfit: Model3dOutfit(hide: ['shirt']),
        );
        expect(native.hooks, isEmpty);
        expect(native.transforms, isEmpty);
        (model as Model3dOutfitController).setOutfit(
          Model3dOutfit(
            show: ['shirt'],
            colors: {'cloth': const Color(0xFFFF0000)},
            transition: type,
            duration: const Duration(milliseconds: 100),
          ),
        );
        await tester.pump();
        if (type == Model3dOutfitTransition.cut) {
          expect(native.hooks, isEmpty);
          expect(native.materialColors[(101, 0)], [1, 0, 0, 1]);
        } else {
          expect(native.hooks, isNotEmpty);
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 25)),
          );
          await native.frame();
          final color = native.materialColors[(101, 0)]!;
          expect(color[1], allOf(greaterThan(0), lessThan(1)));
          if (type == Model3dOutfitTransition.dissolve) {
            expect(color[3], allOf(greaterThan(0), lessThan(1)));
          } else {
            final parent = native.parents[101]!;
            expect(
              native.transforms[parent],
              isNot(thermion.Matrix4.identity()),
            );
          }
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 110)),
          );
          await native.frame();
          await tester.pump();
          expect(native.hooks, isEmpty);
          expect(native.materialColors[(101, 0)], [1, 0, 0, 1]);
        }
        expect(native.visible, contains(101));
        await model.dispose();
        await tester.pump(const Duration(seconds: 1));
      }
    },
  );

  testWidgets(
    'attachments cache bytes and detach replace without primary reload',
    (tester) async {
      final native = Native();
      final doc = boxDocument();
      (doc['nodes'] as List).first['name'] = 'Head';
      var fetches = 0;
      final source = FilamentModel3dSource(
        keepAlive: Duration.zero,
        client: MockClient((_) async {
          fetches++;
          return http.Response.bytes(boxGlb(doc), 200);
        }),
        baseUrl: Uri.parse('http://host/'),
        diskCache: false,
        platform: Platform(native),
      );
      final model =
          await source.controllerFor(const Model3dRequest(src: '/primary.glb'))
              as FilamentModel3dController;
      await finishLoad(model.initialize());
      Future<void> apply(Map<String, String?> attach) async {
        (model as Model3dOutfitController).setOutfit(
          Model3dOutfit(
            attach: attach,
            transition: Model3dOutfitTransition.cut,
          ),
        );
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
        await tester.pump();
      }

      await apply({'Head': '/hat.glb'});
      expect(native.assets, hasLength(2));
      final hat = native.assets.last;
      final placement = native.parents[hat.entity];
      expect(native.parents[placement], 101);
      await apply({'Head': '/hat.glb'});
      expect(native.assets, hasLength(2));
      await apply({'Head': '/helmet.glb'});
      expect(native.assets, hasLength(3));
      expect(
        native.calls
            .where((c) => c.memberName == #destroyAsset)
            .map((c) => c.positionalArguments.single),
        contains(hat),
      );
      await apply({'Head': null});
      expect(native.destroyedEntities, contains(placement));
      await apply({'Head': '/hat.glb'});
      expect(fetches, 3); // Primary + each unique prop source.
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets(
    'recolours every primitive by material and restores authored factors',
    (tester) async {
      final native = Native();
      final doc = boxDocument();
      (doc['nodes'] as List).first['name'] = 'shirt';
      doc['materials'] = [
        {
          'name': 'cloth',
          'pbrMetallicRoughness': {
            'baseColorFactor': [0.2, 0.3, 0.4, 1],
          },
        },
      ];
      doc['meshes'] = [
        {
          'primitives': [
            for (var i = 0; i < 2; i++)
              <String, dynamic>{
                'attributes': {'POSITION': 0},
                'material': 0,
              },
          ],
        },
      ];
      final model = await loadFixture(native, boxGlb(doc));
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(
          colors: {'cloth': const Color(0xFFFF0000)},
          transition: Model3dOutfitTransition.cut,
        ),
      );
      await tester.pump();
      expect(native.materialColors[(101, 0)], [1, 0, 0, 1]);
      expect(native.materialColors[(101, 1)], [1, 0, 0, 1]);
      (model as Model3dOutfitController).setOutfit(
        Model3dOutfit(transition: Model3dOutfitTransition.cut),
      );
      await tester.pump();
      expect(native.materialColors[(101, 1)], [0.2, 0.3, 0.4, 1]);
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets('visibility resolves nodes and ignores unknown names', (
    tester,
  ) async {
    final native = Native();
    final doc = boxDocument();
    (doc['nodes'] as List).first['name'] = 'shirt';
    final model = await loadFixture(native, boxGlb(doc));
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        hide: ['shirt', 'missing'],
        transition: Model3dOutfitTransition.cut,
      ),
    );
    await tester.pump();
    expect(native.log, contains('hide 101'));
    (model as Model3dOutfitController).setOutfit(
      Model3dOutfit(
        show: ['shirt'],
        hide: ['shirt'],
        transition: Model3dOutfitTransition.cut,
      ),
    );
    await tester.pump();
    expect(native.visible, contains(101));
    expect(native.assets, hasLength(1));
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });
}
