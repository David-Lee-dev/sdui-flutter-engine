import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_model_support/sdui_model_support.dart';

/// A `.glb` with only a JSON chunk, padded to four bytes as glTF requires.
Uint8List _glb(Map<String, Object?> json) {
  final text = utf8.encode(jsonEncode(json));
  final chunk = Uint8List((text.length + 3) & ~3)
    ..fillRange(0, (text.length + 3) & ~3, 0x20)
    ..setAll(0, text);
  final header = ByteData(20)
    ..setUint32(0, 0x46546C67, Endian.little)
    ..setUint32(4, 2, Endian.little)
    ..setUint32(8, 20 + chunk.length, Endian.little)
    ..setUint32(12, chunk.length, Endian.little)
    ..setUint32(16, 0x4E4F534A, Endian.little);
  return Uint8List.fromList([...header.buffer.asUint8List(), ...chunk]);
}

void main() {
  group('gltfClipDurations', () {
    test('클립 길이는 샘플러 입력 accessor의 max 중 가장 늦은 값이다', () {
      final durations = gltfClipDurations(
        _glb({
          'accessors': [
            {
              'max': [6.2],
            },
            {
              'max': [3.6],
            },
            {
              'max': [1.5],
            },
          ],
          'animations': [
            {
              'name': 'Sequence',
              'samplers': [
                {'input': 1},
                {'input': 0},
              ],
            },
            {
              'samplers': [
                {'input': 2},
              ],
            },
          ],
        }),
      );

      expect(durations, {
        'Sequence': const Duration(milliseconds: 6200),
        'animation_1': const Duration(milliseconds: 1500),
      });
    });

    test('애니메이션이 없거나 glb가 아니면 빈 맵이다', () {
      expect(gltfClipDurations(_glb({'accessors': <Object>[]})), isEmpty);
      expect(gltfClipDurations(Uint8List.fromList(utf8.encode('{}'))), isEmpty);
      expect(gltfClipDurations(Uint8List(0)), isEmpty);
    });
  });
}
