import 'dart:convert';
import 'dart:typed_data';

/// GLB node identities are made unique without changing index-based references.
final class PreparedModelAsset {
  PreparedModelAsset(this.bytes, this.document, this.names);
  final Uint8List bytes;
  final Map<String, dynamic> document;
  final List<String?> names;

  static PreparedModelAsset read(Uint8List bytes) {
    if (bytes.length < 20) return PreparedModelAsset(bytes, {}, []);
    try {
      final glb = readGlb(bytes);
      final length = glb.jsonLength;
      final document = glb.document;
      final nodes = document['nodes'] as List? ?? const [];
      final names = <String?>[];
      final used = <String>{
        for (final node in nodes)
          if ((node as Map)['name'] is String) node['name'] as String,
      };
      final seen = <String>{};
      for (var i = 0; i < nodes.length; i++) {
        final node = nodes[i] as Map;
        final name = node['name'] as String?;
        names.add(name);
        if (name != null && name.isNotEmpty && seen.add(name)) continue;
        var identity = '__sdui_outfit_$i';
        while (used.contains(identity)) {
          identity += '_';
        }
        used.add(identity);
        node['name'] = identity;
      }
      final meshes = document['meshes'] as List? ?? [];
      final materials = document['materials'] as List? ?? [];
      for (final raw in nodes) {
        final node = raw as Map;
        final index = node['mesh'];
        if (index is! int || index < 0 || index >= meshes.length) continue;
        final mesh = meshes[index] as Map;
        final primitives = mesh['primitives'] as List? ?? [];
        var changed = false;
        final isolated = <Map>[];
        for (final rawPrimitive in primitives) {
          final primitive = Map<String, dynamic>.from(rawPrimitive as Map);
          final material = primitive['material'];
          if (material is int &&
              material >= 0 &&
              material < materials.length &&
              ((materials[material] as Map)['alphaMode'] == 'BLEND' ||
                  node['skin'] != null)) {
            primitive['material'] = materials.length;
            materials.add(
              Map<String, dynamic>.from(materials[material] as Map),
            );
            changed = true;
          }
          isolated.add(primitive);
        }
        if (changed) {
          node['mesh'] = meshes.length;
          meshes.add({...mesh, 'primitives': isolated});
        }
      }
      final json = utf8.encode(jsonEncode(document));
      final size = (json.length + 3) & ~3;
      final tail = bytes.sublist(20 + length);
      final result = Uint8List(20 + size + tail.length);
      result.setRange(0, 20, bytes);
      final resultHeader = ByteData.sublistView(result);
      resultHeader.setUint32(8, result.length, Endian.little);
      resultHeader.setUint32(12, size, Endian.little);
      result.fillRange(20, 20 + size, 32);
      result.setRange(20, 20 + json.length, json);
      result.setRange(20 + size, result.length, tail);
      return PreparedModelAsset(result, document, names);
    } catch (error) {
      if (error is! FormatException &&
          error is! RangeError &&
          error is! TypeError) {
        rethrow;
      }
      // Optional outfit metadata must not reject bytes the native loader accepts.
      return PreparedModelAsset(bytes, {}, []);
    }
  }
}

/// Strict container parsing shared by optional metadata and bounds decoding.
/// Unknown chunks are validated and retained by the preparation rewrite.
GlbData readGlb(Uint8List bytes) {
  if (bytes.length < 20) throw const FormatException('Not a GLB 2 container');
  final header = ByteData.sublistView(bytes);
  if (header.getUint32(0, Endian.little) != 0x46546c67 ||
      header.getUint32(4, Endian.little) != 2 ||
      header.getUint32(8, Endian.little) != bytes.length) {
    throw const FormatException('Not a GLB 2 container');
  }
  Map<String, dynamic>? document;
  Uint8List? bin;
  var jsonLength = 0;
  for (var offset = 12; offset < bytes.length;) {
    if (bytes.length - offset < 8) {
      throw const FormatException('Truncated GLB chunk');
    }
    final length = header.getUint32(offset, Endian.little);
    final type = header.getUint32(offset + 4, Endian.little);
    if (length % 4 != 0 || length > bytes.length - offset - 8) {
      throw const FormatException('Invalid GLB chunk length');
    }
    if (offset == 12 && type != 0x4e4f534a) {
      throw const FormatException('Missing first GLB JSON');
    }
    final chunk = Uint8List.sublistView(bytes, offset + 8, offset + 8 + length);
    if (type == 0x4e4f534a) {
      if (document != null) throw const FormatException('Duplicate GLB JSON');
      final value = jsonDecode(utf8.decode(chunk));
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid GLB JSON');
      }
      document = value;
      jsonLength = length;
    } else if (type == 0x004e4942) {
      if (bin != null) throw const FormatException('Duplicate GLB BIN');
      bin = chunk;
    }
    offset += length + 8;
  }
  if (document == null) throw const FormatException('Missing GLB JSON');
  return GlbData(document, bin, jsonLength);
}

final class GlbData {
  GlbData(this.document, this.bin, this.jsonLength);
  final Map<String, dynamic> document;
  final Uint8List? bin;
  final int jsonLength;
}
