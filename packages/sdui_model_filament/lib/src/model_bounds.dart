import 'dart:typed_data';

import 'package:thermion_flutter/thermion_flutter.dart'
    show Aabb3, Matrix4, Quaternion, Vector3;

import 'model_glb.dart';

/// Initial-pose bounds in the selected glTF scene, before root normalization.
/// Unsupported or malformed geometry throws instead of returning a local box.
Aabb3 modelBounds(Uint8List bytes) {
  try {
    final glb = readGlb(bytes);
    return _Bounds(glb.document, glb.bin, bytes.length).compute();
  } on OutOfMemoryError {
    throw UnsupportedError('Accessor data exceeds available memory');
  } on ArgumentError catch (error) {
    throw FormatException('Invalid GLB range: $error');
  } on TypeError catch (error) {
    throw FormatException('Invalid GLB structure: $error');
  } on NoSuchMethodError catch (error) {
    throw FormatException('Invalid GLB structure: $error');
  }
}

/// Holds only one load's decoded scene and accessor data.
final class _Bounds {
  _Bounds(this.doc, this.bin, this.glbByteLength);
  final int glbByteLength;
  final Map<String, dynamic> doc;
  final Uint8List? bin;
  final world = <int, Matrix4>{};
  Vector3? min;
  Vector3? max;

  Map<String, dynamic> item(String key, int index) =>
      (doc[key] as List)[index] as Map<String, dynamic>;

  List<double> numbers(dynamic values) =>
      (values as List).map((v) => (v as num).toDouble()).toList();

  Matrix4 local(Map<String, dynamic> node) {
    if (node['matrix'] != null) {
      return Matrix4.fromList(numbers(node['matrix']));
    }
    final t = node['translation'] == null
        ? [0.0, 0.0, 0.0]
        : numbers(node['translation']);
    final r = node['rotation'] == null
        ? [0.0, 0.0, 0.0, 1.0]
        : numbers(node['rotation']);
    final s = node['scale'] == null ? [1.0, 1.0, 1.0] : numbers(node['scale']);
    return Matrix4.compose(
      Vector3.array(t),
      Quaternion(r[0], r[1], r[2], r[3]),
      Vector3.array(s),
    );
  }

  void visit(int index, Matrix4 parent, Set<int> path) {
    if (!path.add(index)) throw const FormatException('Cyclic node graph');
    final node = item('nodes', index);
    final matrix = parent * local(node);
    world[index] = matrix;
    for (final child in (node['children'] as List? ?? const [])) {
      visit(child as int, matrix, path);
    }
    path.remove(index);
  }

  void include(Vector3 point) {
    if (!point.storage.every((v) => v.isFinite)) {
      throw const FormatException('Non-finite position');
    }
    if (min == null) {
      min = point.clone();
      max = point.clone();
      return;
    }
    for (var i = 0; i < 3; i++) {
      if (point[i] < min![i]) min![i] = point[i];
      if (point[i] > max![i]) max![i] = point[i];
    }
  }

  bool validExtrema(Map<String, dynamic> accessor) {
    final lo = accessor['min'];
    final hi = accessor['max'];
    return lo is List &&
        hi is List &&
        lo.length == 3 &&
        hi.length == 3 &&
        List.generate(
          3,
          (i) =>
              lo[i] is num &&
              hi[i] is num &&
              (lo[i] as num).isFinite &&
              (hi[i] as num).isFinite &&
              (lo[i] as num) <= (hi[i] as num),
        ).every((v) => v);
  }

  final decoded = <int, List<double>>{};

  /// Reads packed/interleaved accessors and applies sparse values before use.
  List<double> read(int index, String type) {
    final accessor = item('accessors', index);
    if (accessor['type'] != type) {
      throw const FormatException('Accessor type mismatch');
    }
    if (decoded.containsKey(index)) return decoded[index]!;
    final width = switch (type) {
      'VEC3' => 3,
      'VEC4' => 4,
      'MAT4' => 16,
      _ => throw UnsupportedError('Accessor type $type'),
    };
    final count = accessor['count'] as int;
    if (count < 1) throw const FormatException('Empty accessor');
    final component = accessor['componentType'] as int;
    final normalized = accessor['normalized'] == true;
    if (accessor['bufferView'] == null && count > glbByteLength ~/ width) {
      throw const FormatException('Accessor count exceeds GLB byte budget');
    }
    final values = accessor['bufferView'] == null
        ? Float64List(count * width)
        : fill(
            accessor['bufferView'] as int,
            accessor['byteOffset'] as int? ?? 0,
            count,
            width,
            component,
            normalized,
          );
    final sparse = accessor['sparse'] as Map?;
    if (sparse != null) {
      final size = sparse['count'] as int;
      if (size < 0 || size > count) {
        throw const FormatException('Invalid sparse count');
      }
      final indices = sparse['indices'] as Map;
      final component = indices['componentType'] as int;
      if (component != 5121 && component != 5123 && component != 5125) {
        throw const FormatException('Invalid sparse index type');
      }
      final offsets = fill(
        indices['bufferView'] as int,
        indices['byteOffset'] as int? ?? 0,
        size,
        1,
        component,
        false,
        packed: true,
      );
      final source = sparse['values'] as Map;
      final replacements = fill(
        source['bufferView'] as int,
        source['byteOffset'] as int? ?? 0,
        size,
        width,
        accessor['componentType'] as int,
        normalized,
        packed: true,
      );
      var previous = -1;
      for (var i = 0; i < size; i++) {
        final target = offsets[i].toInt();
        if (target <= previous || target >= count) {
          throw const FormatException('Invalid sparse index');
        }
        values.setRange(
          target * width,
          (target + 1) * width,
          replacements,
          i * width,
        );
        previous = target;
      }
    }
    if (!values.every((v) => v.isFinite)) {
      throw const FormatException('Non-finite accessor');
    }
    return decoded[index] = values;
  }

  Float64List fill(
    int viewIndex,
    int offset,
    int count,
    int width,
    int component,
    bool normalized, {
    bool packed = false,
  }) {
    final view = item('bufferViews', viewIndex);
    if ((view['extensions'] as Map?)?.containsKey('EXT_meshopt_compression') ??
        false) {
      throw UnsupportedError('Meshopt geometry');
    }
    if (view['buffer'] != 0 ||
        bin == null ||
        item('buffers', 0)['uri'] != null) {
      throw UnsupportedError('External accessor buffer');
    }
    final size = switch (component) {
      5120 || 5121 => 1,
      5122 || 5123 => 2,
      5125 || 5126 => 4,
      _ => throw UnsupportedError('Component $component'),
    };
    final stride = packed
        ? width * size
        : view['byteStride'] as int? ?? width * size;
    final length = view['byteLength'] as int;
    final start = view['byteOffset'] as int? ?? 0;
    if (stride < width * size ||
        offset < 0 ||
        start < 0 ||
        length < 0 ||
        start > bin!.length ||
        length > bin!.length - start ||
        offset > length ||
        (count > 0 &&
            (length - offset < width * size ||
                count - 1 > (length - offset - width * size) ~/ stride))) {
      throw const FormatException('Accessor outside buffer view');
    }
    final target = Float64List(count * width);
    final bytes = ByteData.sublistView(bin!);
    for (var i = 0; i < count; i++) {
      for (var c = 0; c < width; c++) {
        final at = start + offset + i * stride + c * size;
        var value = switch (component) {
          5120 => bytes.getInt8(at).toDouble(),
          5121 => bytes.getUint8(at).toDouble(),
          5122 => bytes.getInt16(at, Endian.little).toDouble(),
          5123 => bytes.getUint16(at, Endian.little).toDouble(),
          5125 => bytes.getUint32(at, Endian.little).toDouble(),
          5126 => bytes.getFloat32(at, Endian.little),
          _ => throw UnsupportedError('Component $component'),
        };
        if (normalized) {
          value = switch (component) {
            5120 => (value / 127).clamp(-1, 1),
            5121 => value / 255,
            5122 => (value / 32767).clamp(-1, 1),
            5123 => value / 65535,
            _ => throw const FormatException('Invalid normalized component'),
          };
        }
        target[i * width + c] = value;
      }
    }
    return target;
  }

  Aabb3 compute() {
    for (final extension in (doc['extensionsRequired'] as List? ?? const [])) {
      if (extension == 'KHR_draco_mesh_compression' ||
          extension == 'EXT_meshopt_compression') {
        throw UnsupportedError('Compressed geometry: $extension');
      }
    }
    for (final view in doc['bufferViews'] as List? ?? const []) {
      if ((view['extensions'] as Map?)?.containsKey(
            'EXT_meshopt_compression',
          ) ??
          false) {
        throw UnsupportedError('Meshopt geometry');
      }
    }
    final scene = item('scenes', doc['scene'] as int? ?? 0);
    for (final root in scene['nodes'] as List? ?? const []) {
      visit(root as int, Matrix4.identity(), <int>{});
    }
    for (final entry in world.entries) {
      final node = item('nodes', entry.key);
      if (node['mesh'] == null) continue;
      final mesh = item('meshes', node['mesh'] as int);
      for (final primitive in mesh['primitives'] as List) {
        if ((primitive['extensions'] as Map?)?.containsKey(
              'KHR_draco_mesh_compression',
            ) ??
            false) {
          throw UnsupportedError('Draco geometry');
        }
        final position = (primitive['attributes'] as Map)['POSITION'] as int?;
        if (position == null) continue;
        final accessor = item('accessors', position);
        final weights = numbers(node['weights'] ?? mesh['weights'] ?? const []);
        final targets = primitive['targets'] as List? ?? const [];
        final morphed = List.generate(
          targets.length,
          (i) =>
              i < weights.length &&
              weights[i] != 0 &&
              targets[i]['POSITION'] != null,
        );
        if (node['skin'] == null &&
            accessor['normalized'] != true &&
            !morphed.any((v) => v) &&
            validExtrema(accessor)) {
          final lo = numbers(accessor['min']);
          final hi = numbers(accessor['max']);
          for (var corner = 0; corner < 8; corner++) {
            include(
              entry.value.transformed3(
                Vector3(
                  corner & 1 == 0 ? lo[0] : hi[0],
                  corner & 2 == 0 ? lo[1] : hi[1],
                  corner & 4 == 0 ? lo[2] : hi[2],
                ),
              ),
            );
          }
          continue;
        }
        final positions = read(position, 'VEC3');
        final deltas = <int, List<double>>{
          for (var i = 0; i < targets.length; i++)
            if (morphed[i]) i: read(targets[i]['POSITION'] as int, 'VEC3'),
        };
        if (deltas.values.any((v) => v.length != positions.length)) {
          throw const FormatException('Morph POSITION count mismatch');
        }
        final matrices = <Matrix4>[];
        final jointSets = <List<double>>[];
        final weightSets = <List<double>>[];
        if (node['skin'] != null) {
          final skin = item('skins', node['skin'] as int);
          final joints = skin['joints'] as List;
          final inverse = skin['inverseBindMatrices'] == null
              ? null
              : read(skin['inverseBindMatrices'] as int, 'MAT4');
          if (inverse != null && inverse.length != joints.length * 16) {
            throw const FormatException('Inverse bind count mismatch');
          }
          for (var i = 0; i < joints.length; i++) {
            final matrix = world[joints[i]];
            if (matrix == null) {
              throw const FormatException('Joint outside scene');
            }
            matrices.add(
              matrix *
                  (inverse == null
                      ? Matrix4.identity()
                      : Matrix4.fromList(inverse.sublist(i * 16, i * 16 + 16))),
            );
          }
          final attributes = primitive['attributes'] as Map;
          for (final key in attributes.keys.cast<String>()) {
            if (!key.startsWith('JOINTS_')) continue;
            final suffix = key.substring(7);
            final weight = attributes['WEIGHTS_$suffix'] as int?;
            if (weight == null) {
              throw const FormatException('Missing skin weights');
            }
            final joint = read(attributes[key] as int, 'VEC4');
            final values = read(weight, 'VEC4');
            if (joint.length != positions.length ~/ 3 * 4 ||
                joint.length != values.length) {
              throw const FormatException('Skin attribute count mismatch');
            }
            jointSets.add(joint);
            weightSets.add(values);
          }
          if (jointSets.isEmpty) {
            throw const FormatException('Missing skin joints');
          }
        }
        for (var vertex = 0; vertex < positions.length ~/ 3; vertex++) {
          final point = Vector3(
            positions[vertex * 3],
            positions[vertex * 3 + 1],
            positions[vertex * 3 + 2],
          );
          for (final delta in deltas.entries) {
            for (var axis = 0; axis < 3; axis++) {
              point[axis] +=
                  delta.value[vertex * 3 + axis] * weights[delta.key];
            }
          }
          if (matrices.isEmpty) {
            include(entry.value.transformed3(point));
            continue;
          }
          final posed = Vector3.zero();
          var total = 0.0;
          for (var set = 0; set < jointSets.length; set++) {
            for (var influence = 0; influence < 4; influence++) {
              final weight = weightSets[set][vertex * 4 + influence];
              if (!weight.isFinite || weight < 0) {
                throw const FormatException('Invalid skin weight');
              }
              if (weight == 0) continue;
              final joint = jointSets[set][vertex * 4 + influence];
              if (joint != joint.truncateToDouble() ||
                  joint < 0 ||
                  joint >= matrices.length) {
                throw const FormatException('Invalid joint index');
              }
              posed.add(
                matrices[joint.toInt()].transformed3(point)..scale(weight),
              );
              total += weight;
            }
          }
          if (total <= 0) throw const FormatException('Zero skin weights');
          include(posed..scale(1 / total));
        }
      }
    }
    if (min == null) {
      throw const FormatException('No geometry in selected scene');
    }
    return Aabb3.minMax(min!, max!);
  }
}
