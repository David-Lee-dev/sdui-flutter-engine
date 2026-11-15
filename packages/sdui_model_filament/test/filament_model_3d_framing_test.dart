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
  // RF-R4: FormatException enters the existing native-bounds fallback.
  testWidgets('oversized zero-base geometry falls back to native bounds', (
    tester,
  ) async {
    final doc = boxDocument();
    final accessor = doc['accessors'][0] as Map;
    accessor.remove('min');
    accessor.remove('max');
    accessor['count'] = 1 << 60;
    final native = Native();
    final model = await loadFixture(native, glb(doc));
    expect(native.log, contains('transformToUnitCube'));
    expect(model.clips, ['Wave', 'Jump']);
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'frames transformed positive-only bounds without including origin',
    (tester) async {
      final native = Native();
      final doc = boxDocument(
        transform: {
          'scale': [0.01, 0.01, 0.01],
          'rotation': [0, 0, 0.7071067811865476, 0.7071067811865476],
        },
      );
      final model = await loadFixture(native, boxGlb(doc));
      expect(native.calls.where((c) => c.memberName == #setTransform), isEmpty);
      final view = native.calls.singleWhere((c) => c.memberName == #lookAt);
      final focus = view.namedArguments[#focus] as thermion.Vector3;
      final position = view.positionalArguments.first as thermion.Vector3;
      expect(focus.x, closeTo(-0.24, 1e-8));
      expect(focus.y, closeTo(0.12, 1e-8));
      expect(focus.z, closeTo(0.31, 1e-8));
      final distance = math.sqrt(21) * 0.01 / math.sin(math.atan(12 / 28));
      expect(position.x, closeTo(focus.x, 1e-8));
      expect(position.y, closeTo(focus.y, 1e-8));
      expect(position.z, closeTo(focus.z + distance, 1e-8));
      final lens = native.calls.singleWhere(
        (c) => c.memberName == #setLensProjection,
      );
      expect(lens.namedArguments[#near], closeTo(0.004, 1e-10));
      expect(lens.namedArguments[#far], closeTo(4, 1e-8));
      expect(lens.namedArguments[#focalLength], 28);
      expect(lens.namedArguments[#aspect], 1);
      expect(native.log, isNot(contains('transformToUnitCube')));
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    },
  );
  testWidgets('identity nodes retain the original picture', (tester) async {
    final native = Native();
    final doc = boxDocument();
    doc['accessors'][0]['min'] = [-2, -4, -1];
    doc['accessors'][0]['max'] = [2, 4, 1];
    final model = await loadFixture(native, boxGlb(doc));
    expect(native.calls.where((c) => c.memberName == #setTransform), isEmpty);
    final view = native.calls.singleWhere((c) => c.memberName == #lookAt);
    final focus = view.namedArguments[#focus] as thermion.Vector3;
    final position = view.positionalArguments.first as thermion.Vector3;
    expect(focus.storage, orderedEquals([0, 0, 0]));
    // Scaling the mesh and its bounding sphere by 1/4 scales the camera equally.
    expect(
      position.z / 4,
      closeTo((math.sqrt(21) / 4) / math.sin(math.atan(12 / 28)), 1e-8),
    );
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });
  testWidgets(
    'weighted joints inverse binds morph defaults and multiple skins',
    (tester) async {
      final native = Native();
      final model = await loadFixture(native, skinnedFixture());
      expect(native.calls.where((c) => c.memberName == #setTransform), isEmpty);
      final view = native.calls.singleWhere((c) => c.memberName == #lookAt);
      final focus = view.namedArguments[#focus] as thermion.Vector3;
      final position = view.positionalArguments.first as thermion.Vector3;
      // First mesh: x 13.5..15.5, second: x 20..22; y 0..4.
      expect(focus.storage, orderedEquals([17.75, 2, 0]));
      expect(position.x, 17.75);
      expect(position.y, 2);
      expect(
        position.z,
        closeTo(math.sqrt(22.0625) / math.sin(math.atan(12 / 28)), 1e-8),
      );
      expect(native.log, isNot(contains('transformToUnitCube')));
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    },
  );
  testWidgets('contact and cast ground use the framed extent once', (
    tester,
  ) async {
    final native = Native();
    final model = await loadFixture(
      native,
      boxGlb(
        boxDocument(
          transform: {
            'scale': [0.01, 0.01, 0.01],
            'rotation': [0, 0, 0.7071067811865476, 0.7071067811865476],
          },
        ),
      ),
    );
    (model as Model3dLookController).setLook(
      const Model3dLook(shadow: Model3dShadow(type: Model3dShadowType.contact)),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();
    final transforms = native.calls
        .where((c) => c.memberName == #setTransform)
        .toList();
    expect(transforms, hasLength(1));
    final ground =
        transforms.single.positionalArguments.single as thermion.Matrix4;
    expect(ground.getTranslation().x, closeTo(-0.24, 1e-8));
    expect(ground.getTranslation().y, closeTo(0.10004, 1e-8));
    expect(ground.getTranslation().z, closeTo(0.31, 1e-8));
    final geometry =
        native.calls
                .singleWhere((c) => c.memberName == #createGeometry)
                .positionalArguments
                .single
            as thermion.Geometry;
    expect(geometry.vertices[0], closeTo(-0.048, 1e-6));
    (model as Model3dLookController).setLook(
      const Model3dLook(
        light: Model3dLight(),
        shadow: Model3dShadow(type: Model3dShadowType.cast),
      ),
    );
    await tester.pump();
    expect(
      native.calls.where((c) => c.memberName == #createGeometry),
      hasLength(1),
    );
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });
  testWidgets('scaled twins point bounds and zoom-aware clipping', (
    tester,
  ) async {
    final distance = math.sqrt(21) / math.sin(math.atan(12 / 28));
    for (final scale in [0.01, 1.0, 100.0]) {
      final native = Native();
      final doc = boxDocument(
        transform: {
          'scale': [scale, scale, scale],
          'rotation': [0, 0, 0.7071067811865476, 0.7071067811865476],
        },
      );
      final model = await loadFixture(native, boxGlb(doc));
      var view = native.calls.lastWhere((c) => c.memberName == #lookAt);
      final focus = view.namedArguments[#focus] as thermion.Vector3;
      var position = view.positionalArguments.first as thermion.Vector3;
      expect(focus.x / scale, closeTo(-24, 1e-8));
      expect(focus.y / scale, closeTo(12, 1e-8));
      expect(focus.z / scale, closeTo(31, 1e-8));
      expect((position - focus).length / scale, closeTo(distance, 1e-8));
      for (final zoom in [0.001, 0.0, -1.0, double.infinity, double.nan]) {
        model.setCamera(Model3dCamera(yaw: 90, pitch: 100, zoom: zoom));
        await tester.pump();
        view = native.calls.lastWhere((c) => c.memberName == #lookAt);
        position = view.positionalArguments.first as thermion.Vector3;
        final d = distance * scale / (zoom == 0.001 ? zoom : 1);
        expect((position - focus).length, closeTo(d, d * 1e-8));
        expect(
          position.y - focus.y,
          closeTo(d * math.sin(89 * math.pi / 180), d * 1e-8),
        );
        final lens = native.calls.lastWhere(
          (c) => c.memberName == #setLensProjection,
        );
        expect(lens.namedArguments[#near], closeTo(0.4 * scale, 1e-8));
        // Extents of the rotated box are 8,4,2: half diagonal is sqrt(21).
        expect(
          lens.namedArguments[#far] as double,
          greaterThan(d + math.sqrt(21) * scale),
        );
      }
      expect(native.calls.where((c) => c.memberName == #setTransform), isEmpty);
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    }
    final native = Native();
    final doc = boxDocument();
    doc['accessors'][0]['min'] = [0, 0, 0];
    doc['accessors'][0]['max'] = [0, 0, 0];
    final model = await loadFixture(native, boxGlb(doc));
    final view = native.calls.singleWhere((c) => c.memberName == #lookAt);
    final position = view.positionalArguments.first as thermion.Vector3;
    expect(position.z, closeTo(1 / math.sin(math.atan(12 / 28)), 1e-8));
    final lens = native.calls.singleWhere(
      (c) => c.memberName == #setLensProjection,
    );
    expect(lens.namedArguments[#near], 0.1);
    expect(lens.namedArguments[#far], 100);
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'bounds overlap native loading and errors settle after early failure',
    (tester) async {
      final previous = debugPrint;
      var computed = Completer<void>();
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message?.contains('Initial bounds took') == true &&
            !computed.isCompleted) {
          computed.complete();
        }
      };
      try {
        for (final fail in [false, true]) {
          computed = Completer<void>();
          final native = Native();
          if (fail) {
            native.fail = 'loadGltfFromBuffer';
          } else {
            native.hold('loadGltfFromBuffer');
          }
          final source = FilamentModel3dSource(
            keepAlive: Duration.zero,
            client: MockClient(
              (_) async => http.Response.bytes(
                fail ? Uint8List.fromList([1]) : boxGlb(boxDocument()),
                200,
              ),
            ),
            baseUrl: Uri.parse('http://host/'),
            diskCache: false,
            platform: Platform(native),
          );
          final model =
              await source.controllerFor(
                    const Model3dRequest(src: '/async.glb'),
                  )
                  as FilamentModel3dController;
          final loading = model.initialize();
          Object? failure;
          final settled = loading.then(
            (_) {},
            onError: (Object error) {
              failure = error;
            },
          );
          await finishLoad(computed.future);
          expect(native.log, contains('loadGltfFromBuffer'));
          expect(model.stats.isReady, isFalse);
          if (!fail) native.release('loadGltfFromBuffer');
          await finishLoad(settled);
          if (fail) {
            expect(failure, isA<StateError>());
            expect(model.stats.error, contains('loadGltfFromBuffer'));
          } else {
            expect(failure, isNull);
            expect(model.stats.isReady, isTrue);
          }
          await model.dispose();
          await tester.pump(const Duration(seconds: 1));
        }
      } finally {
        debugPrint = previous;
      }
    },
  );

  testWidgets(
    'selected scene hierarchy offsets stride sparse and node morph weights',
    (tester) async {
      final native = Native();
      final model = await loadFixture(native, stridedFixture());
      expect(native.calls.where((c) => c.memberName == #setTransform), isEmpty);
      final view = native.calls.singleWhere((c) => c.memberName == #lookAt);
      final focus = view.namedArguments[#focus] as thermion.Vector3;
      final position = view.positionalArguments.first as thermion.Vector3;
      expect(focus.storage, orderedEquals([40, 44, 64]));
      expect(
        position.z - focus.z,
        closeTo(math.sqrt(132) / math.sin(math.atan(12 / 28)), 1e-8),
      );
      expect(native.log, isNot(contains('transformToUnitCube')));
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets('retains corrected framing', (tester) async {
    final doc = boxDocument(
      transform: {
        'scale': [0.01, 0.01, 0.01],
      },
    );
    final primitives = doc['meshes'][0]['primitives'] as List;
    primitives.insert(0, {'attributes': <String, int>{}});
    primitives.add({'attributes': <String, int>{}});
    final native = Native();
    final model = await loadFixture(native, boxGlb(doc));
    expect(native.log, isNot(contains('transformToUnitCube')));
    expect(native.calls.where((c) => c.memberName == #setTransform), isEmpty);
    final view = native.calls.singleWhere((c) => c.memberName == #lookAt);
    final focus = view.namedArguments[#focus] as thermion.Vector3;
    expect(focus.x, closeTo(0.12, 1e-8));
    expect(focus.y, closeTo(0.24, 1e-8));
    expect(focus.z, closeTo(0.31, 1e-8));
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('compressed and malformed models preserve native normalization', (
    tester,
  ) async {
    for (final bytes in [
      boxGlb(
        boxDocument()..['extensionsRequired'] = ['KHR_draco_mesh_compression'],
      ),
      boxGlb(
        boxDocument()..['extensionsRequired'] = ['EXT_meshopt_compression'],
      ),
      Uint8List.fromList([1, 2, 3]),
    ]) {
      final native = Native();
      final model = await loadFixture(native, bytes);
      expect(native.log.where((n) => n == 'transformToUnitCube'), hasLength(1));
      expect(native.calls.where((c) => c.memberName == #setTransform), isEmpty);
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    }
  });
  testWidgets('malformed dynamic objects preserve native normalization', (
    tester,
  ) async {
    final morph = jsonDecode(jsonEncode(boxDocument())) as Map<String, dynamic>;
    morph['meshes'][0]['weights'] = [1];
    morph['meshes'][0]['primitives'][0]['targets'] = [42];
    final bufferView = boxDocument()..['bufferViews'] = [42];
    for (final doc in [morph, bufferView]) {
      final native = Native();
      final model = await loadFixture(native, glb(doc));
      expect(native.log.where((n) => n == 'transformToUnitCube'), hasLength(1));
      expect(native.calls.where((c) => c.memberName == #setTransform), isEmpty);
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    }
  });
  testWidgets('normalized quantized positions use decoded units', (
    tester,
  ) async {
    final doc = boxDocument();
    doc['extensionsRequired'] = ['KHR_mesh_quantization'];
    doc['accessors'][0] = {
      'bufferView': 0,
      'componentType': 5122,
      'normalized': true,
      'type': 'VEC3',
      'count': 2,
      'min': [-32767, -16384, 0],
      'max': [32767, 16384, 0],
    };
    doc['buffers'] = [
      {'byteLength': 12},
    ];
    doc['bufferViews'] = [
      {'buffer': 0, 'byteLength': 12},
    ];
    final data = ByteData(12);
    final values = [-32767, -16384, 0, 32767, 16384, 0];
    for (var i = 0; i < values.length; i++) {
      data.setInt16(i * 2, values[i], Endian.little);
    }
    final native = Native();
    final model = await loadFixture(
      native,
      glb(doc, data.buffer.asUint8List()),
    );
    expect(native.calls.where((c) => c.memberName == #setTransform), isEmpty);
    final view = native.calls.singleWhere((c) => c.memberName == #lookAt);
    final focus = view.namedArguments[#focus] as thermion.Vector3;
    final position = view.positionalArguments.first as thermion.Vector3;
    expect(focus.storage, orderedEquals([0, 0, 0]));
    expect(
      position.z,
      closeTo(
        math.sqrt(1 + math.pow(16384 / 32767, 2)) /
            math.sin(math.atan(12 / 28)),
        1e-8,
      ),
    );
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('optional meshopt buffer view takes explicit fallback', (
    tester,
  ) async {
    final doc = boxDocument();
    final bytes = boxGlb(doc);
    doc['bufferViews'] = [
      <String, dynamic>{...doc['bufferViews'][0] as Map},
    ];
    doc['bufferViews'][0]['extensions'] = {
      'EXT_meshopt_compression': {'buffer': 0},
    };
    final native = Native();
    // Keep a valid local POSITION box; compressed bytes cannot be trusted by this decoder.
    final model = await loadFixture(
      native,
      glb(doc, Uint8List.sublistView(bytes, bytes.length - 24)),
    );
    expect(native.log.where((n) => n == 'transformToUnitCube'), hasLength(1));
    expect(native.calls.where((c) => c.memberName == #setTransform), isEmpty);
    await model.dispose();
    await tester.pump(const Duration(seconds: 1));
  });
  // The Filament engine is native; these cover the Dart surface the `model_3d`
  // widget sees before a viewer exists.
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

    testWidgets('계약: 로드 전과 호출 중 변경한 최신 카메라를 적용한다', (tester) async {
      final model = await controller();
      model.setCamera(const Model3dCamera(yaw: 90, zoom: 2));
      bytes.complete();
      await finishLoad(model.initialize());
      final first =
          native.calls
                  .lastWhere((call) => call.memberName == #lookAt)
                  .positionalArguments
                  .first
              as thermion.Vector3;
      expect(first.x, greaterThan(0));
      expect(first.y, closeTo(0, 1e-9));
      expect(first.z, closeTo(0, 1e-9));

      native.calls.clear();
      native.hold('lookAt');
      model.setCamera(const Model3dCamera(yaw: 0));
      await tester.pump();
      model.setCamera(const Model3dCamera(yaw: 45));
      model.setCamera(const Model3dCamera(yaw: -90, zoom: 2));
      native.release('lookAt');
      await tester.pump();

      final positions = native.calls
          .where((call) => call.memberName == #lookAt)
          .map((call) => call.positionalArguments.first as thermion.Vector3)
          .toList();
      expect(positions, hasLength(2));
      expect(positions.first.z, closeTo(first.x * 2, 1e-9));
      expect(positions.last.x, closeTo(-first.x, 1e-9));
      expect(positions.last.y, closeTo(0, 1e-9));
      expect(positions.last.z, closeTo(0, 1e-9));
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
