import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_model_filament/src/model_bounds.dart';

import 'support/filament_fakes.dart';

void main() {
  // RF-R4: the budget applies to every decoded width, before allocation.
  test('zero-base accessor counts exceed the original GLB budget', () {
    for (final width in ['VEC3', 'VEC4', 'MAT4']) {
      final doc = boxDocument();
      final accessor = doc['accessors'][0] as Map;
      accessor.remove('min');
      accessor.remove('max');
      accessor['count'] = 1 << 60;
      if (width != 'VEC3') {
        accessor['count'] = 2;
        (doc['nodes'] as List).first['skin'] = 0;
        doc['skins'] = [
          {
            'joints': [0],
            if (width == 'MAT4') 'inverseBindMatrices': 1,
          },
        ];
        (doc['accessors'] as List).add({
          'type': width,
          'componentType': 5126,
          'count': 1 << 60,
        });
        if (width == 'VEC4') {
          final attributes =
              doc['meshes'][0]['primitives'][0]['attributes'] as Map;
          attributes['JOINTS_0'] = 1;
          attributes['WEIGHTS_0'] = 1;
        }
      }
      expect(
        () => modelBounds(glb(doc)),
        throwsA(isA<FormatException>()),
        reason: '$width must reject before allocating',
      );
    }
  });

  test('rejects oversized counts before allocation', () {
    for (final hasView in [true, false]) {
      final doc = boxDocument();
      final bytes = boxGlb(doc);
      final accessor = doc['accessors'][0] as Map;
      accessor.remove('min');
      accessor.remove('max');
      accessor['count'] = 1 << 60;
      if (!hasView) accessor.remove('bufferView');
      expect(
        () => modelBounds(
          glb(doc, Uint8List.sublistView(bytes, bytes.length - 24)),
        ),
        throwsA(anyOf(isA<FormatException>(), isA<UnsupportedError>())),
      );
    }
  });

  test('preserves zero and sparse bases', () {
    final doc = boxDocument();
    final accessor = doc['accessors'][0] as Map;
    accessor.remove('min');
    accessor.remove('max');
    var bounds = modelBounds(glb(doc));
    expect(bounds.min.storage, orderedEquals([0, 0, 0]));
    expect(bounds.max.storage, orderedEquals([0, 0, 0]));
    doc['buffers'] = [
      {'byteLength': 16},
    ];
    doc['bufferViews'] = [
      {'buffer': 0, 'byteLength': 1},
      {'buffer': 0, 'byteOffset': 4, 'byteLength': 12},
    ];
    accessor['sparse'] = {
      'count': 1,
      'indices': {'bufferView': 0, 'componentType': 5121},
      'values': {'bufferView': 1},
    };
    final data = ByteData(16)..setUint8(0, 1);
    for (var i = 0; i < 3; i++) {
      data.setFloat32(4 + i * 4, (i + 1).toDouble(), Endian.little);
    }
    bounds = modelBounds(glb(doc, data.buffer.asUint8List()));
    expect(bounds.min.storage, orderedEquals([0, 0, 0]));
    expect(bounds.max.storage, orderedEquals([1, 2, 3]));
  });
}
