import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_model_filament/src/model_glb.dart';
import 'support/filament_fakes.dart';

void main() {
  test('metadata preparation preserves binary and unknown chunks', () {
    final source = glb({
      'asset': {'version': '2.0'},
      'nodes': [{}],
    }, Uint8List.fromList([1, 2, 3, 4]));
    final bytes = Uint8List(source.length + 12)
      ..setRange(0, source.length, source);
    final header = ByteData.sublistView(bytes);
    header.setUint32(8, bytes.length, Endian.little);
    header.setUint32(source.length, 4, Endian.little);
    header.setUint32(source.length + 4, 0x12345678, Endian.little);
    bytes.setRange(source.length + 8, bytes.length, [5, 6, 7, 8]);
    final prepared = PreparedModelAsset.read(bytes);
    expect(prepared.names, [null]);
    expect(prepared.document['nodes'][0]['name'], isA<String>());
    expect(readGlb(prepared.bytes).bin, [1, 2, 3, 4]);
    expect(
      prepared.bytes.sublist(prepared.bytes.length - 12),
      bytes.sublist(source.length),
    );
  });

  test(
    'malformed chunk ranges reject bounds parsing and preserve original metadata bytes',
    () {
      final bytes = glb({
        'asset': {'version': '2.0'},
        'nodes': [{}],
      });
      ByteData.sublistView(bytes).setUint32(12, bytes.length, Endian.little);
      expect(() => readGlb(bytes), throwsFormatException);
      expect(identical(PreparedModelAsset.read(bytes).bytes, bytes), isTrue);
    },
  );
}
