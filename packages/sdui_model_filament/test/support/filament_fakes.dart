import 'dart:async';
// Thermion omits AnimationManager from its public barrel.
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:thermion_dart/src/filament/src/interface/animation_manager.dart'
    show AnimationManager;
// Thermion omits Scene from its public barrel.
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:thermion_dart/src/filament/src/interface/scene.dart'
    as native_scene
    show Scene;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_model_filament/sdui_model_filament.dart';
import 'package:sdui_model_filament/src/filament_platform.dart';
import 'package:thermion_flutter/thermion_flutter.dart' as thermion;

/// Every native call the fakes see, in order; a held call logs `name done`
/// once released.
final class Native {
  final log = <String>[];
  final calls = <Invocation>[];
  final assets = <Asset>[];
  final parents = <int, int?>{};
  final transforms = <int, thermion.Matrix4>{};
  final destroyedEntities = <int>[];
  final hooks = <Future Function()>[];
  final visible = <int>{};
  final swaps = <(int, int, thermion.MaterialInstance)>[];
  final createdMaterials = <Material>[];
  final materialColors = <(int, int), List<double>>{};
  final materialEmissives = <(int, int), List<double>>{};
  final nodePositions = <String, thermion.Vector3>{};
  final componentClips = <int>{};
  final clipPoses = <int, Map<int, thermion.Matrix4>>{};
  final animationPose = <int, thermion.Matrix4>{};
  final morphWeights = <(int, String), double>{};
  int nextEntity = 1000;
  bool processingHooks = false;
  final outsidePoseWrites = <String>[];
  void poseWrite(String name) {
    if (!processingHooks) outsidePoseWrites.add(name);
  }

  int? pickedEntity = 101;
  bool completePick = true;
  void Function(thermion.PickResult)? pendingPick;
  Future<void> frame() async {
    processingHooks = true;
    try {
      for (final hook in [...hooks]) {
        await hook();
      }
    } finally {
      processingHooks = false;
    }
  }

  /// The model's clips in native order: name and seconds.
  thermion.Aabb3 bounds = thermion.Aabb3.minMax(
    thermion.Vector3(-0.5, -1, -0.25),
    thermion.Vector3(0.5, 1, 0.25),
  );
  List<(String, double)> clips = const [('Wave', 1.0), ('Jump', 1.0)];

  /// The native index of each other animation call, as `name index`.
  final indices = <String>[];
  final _holds = <String, Completer<void>>{};
  String? fail;

  /// Holds the next call to [name] until [release].
  void hold(String name) => _holds[name] = Completer<void>();

  void release(String name) => _holds.remove(name)!.complete();

  Future<T> call<T>(String name, T result) {
    log.add(name);
    if (fail == name) {
      fail = null;
      return Future<T>.error(StateError('native failure: $name'));
    }
    final hold = _holds[name];
    if (hold == null) return Future.value(result);
    return hold.future.then((_) {
      log.add('$name done');
      return result;
    });
  }
}

String nameOf(Invocation invocation) =>
    invocation.memberName.toString().split('"')[1];

final class Viewer implements thermion.ThermionViewer {
  Viewer(this.native);

  final Native native;

  @override
  thermion.View get view => View(native);

  @override
  Future<thermion.Camera> getActiveCamera() =>
      native.call<thermion.Camera>('getActiveCamera', Camera(native));

  Asset _assetFromBytes(Uint8List bytes) {
    try {
      final size = ByteData.sublistView(bytes).getUint32(12, Endian.little);
      final doc = jsonDecode(utf8.decode(bytes.sublist(20, 20 + size))) as Map;
      return Asset(
        native,
        names: [
          for (final node in (doc['nodes'] as List? ?? []))
            (node as Map)['name'] as String? ?? '',
        ],
      );
    } catch (_) {
      return Asset(native);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    native.calls.add(invocation);
    return switch (nameOf(invocation)) {
      // Its parameters change across thermion versions; match it by name.
      'createGeometry' => native.call<thermion.ThermionAsset>(
        'createGeometry',
        Asset(native),
      ),
      'addDirectLight' => native.call<thermion.ThermionEntity>(
        'addDirectLight',
        42,
      ),
      'loadGltfFromBuffer' => native.call<thermion.ThermionAsset>(
        'loadGltfFromBuffer',
        _assetFromBytes(invocation.positionalArguments.first as Uint8List),
      ),
      'setBackgroundColor' => native.call<thermion.Skybox>(
        'setBackgroundColor',
        Skybox(),
      ),
      final name => native.call<void>(name, null),
    };
  }
}

final class FakeScene implements native_scene.Scene {
  FakeScene(this.native);
  final Native native;
  @override
  Future addEntity(int entity) async {
    native.visible.add(entity);
    native.log.add('show $entity');
  }

  @override
  Future removeEntity(int entity) async {
    native.visible.remove(entity);
    native.log.add('hide $entity');
  }

  @override
  dynamic noSuchMethod(Invocation call) => super.noSuchMethod(call);
}

final class Skybox implements thermion.Skybox {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class View implements thermion.View {
  View(this.native);

  final Native native;

  @override
  Future<native_scene.Scene> getScene() async => FakeScene(native);

  @override
  Future pick(int x, int y, void Function(thermion.PickResult) handler) async {
    native.log.add('pick $x $y');
    native.pendingPick = handler;
    if (native.completePick) {
      handler((
        entity: native.pickedEntity ?? 0,
        x: x,
        y: y,
        depth: 1.0,
        fragX: x.toDouble(),
        fragY: y.toDouble(),
        fragZ: 0.0,
      ));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    native.calls.add(invocation);
    if (invocation.memberName == #createColorGradingBuilder) {
      return native.call<thermion.ColorGradingBuilder>(
        'createColorGradingBuilder',
        GradingBuilder(native),
      );
    }
    return native.call<void>(nameOf(invocation), null);
  }
}

final class Camera implements thermion.Camera {
  Camera(this.native);

  final Native native;

  @override
  Future<double> getFocalLength() => native.call('getFocalLength', 28.0);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    native.calls.add(invocation);
    return native.call<void>(nameOf(invocation), null);
  }
}

/// A model with [Native.clips], by default a one-second `Wave` and `Jump`.
final class Asset implements thermion.ThermionAsset {
  Asset(this.native, {this.names = const []})
    : entity = 100 + native.assets.length * 10 {
    native.assets.add(this);
  }
  @override
  final int entity;
  final calls = <Invocation>[];
  final List<String> names;
  @override
  Future<List<int>> getChildEntities() async => [
    for (var i = 0; i < math.max(2, names.length); i++) entity + 1 + i,
  ];
  @override
  Future<int?> getChildEntity(String name) async => names.contains(name)
      ? entity + 1 + names.indexOf(name)
      : native.nodePositions.containsKey(name)
      ? entity + 1
      : null;
  @override
  Future<thermion.Matrix4> getWorldTransform({int? entity}) async =>
      thermion.Matrix4.translation(native.nodePositions.values.first);

  final Native native;

  @override
  Future<List<thermion.MorphTargetSet>> getMorphTargetSets() async => [
    Morphs(native, entity + 1, ['smile', 'blink']),
    Morphs(native, entity + 2, ['smile']),
  ];

  @override
  Future<thermion.Aabb3> getBoundingBox() async => native.bounds;

  @override
  Future<List<String>> getGltfAnimationNames() => native.call(
    'getGltfAnimationNames',
    [for (final (name, _) in native.clips) name],
  );

  @override
  Future<double> getGltfAnimationDuration(int animationIndex) =>
      native.call('getGltfAnimationDuration', native.clips[animationIndex].$2);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    native.calls.add(invocation);
    calls.add(invocation);
    final name = nameOf(invocation);
    if (name == 'playGltfAnimation') {
      if ((invocation.namedArguments[#replaceActive] as bool? ?? true) &&
          (invocation.namedArguments[#crossfade] as double? ?? 0) == 0) {
        native.componentClips.clear();
      }
      native.componentClips.add(invocation.positionalArguments.first as int);
    } else if (name == 'stopGltfAnimation') {
      native.componentClips.remove(invocation.positionalArguments.first);
    }
    if (name == 'setGltfAnimationTime') {
      native.poseWrite(name);
      for (final e
          in (native.clipPoses[invocation.positionalArguments.first] ??
                  native.animationPose)
              .entries) {
        native.transforms[e.key] = e.value.clone();
      }
    }
    if (name.contains('GltfAnimation')) {
      native.indices.add('$name ${invocation.positionalArguments.first}');
    }
    return native.call<void>(name, null);
  }
}

final class Morphs implements thermion.MorphTargetSet {
  Morphs(this.native, this.entity, this.names);
  final Native native;
  @override
  final int entity;
  final List<String> names;
  @override
  List<thermion.MorphTarget> get targets => [
    for (var i = 0; i < names.length; i++)
      thermion.MorphTarget(index: i, name: names[i]),
  ];
  @override
  Future<void> setWeight(String name, double weight) async {
    if (!names.contains(name)) throw ArgumentError(name);
    native.poseWrite('morph');
    native.morphWeights[(entity, name)] = weight;
  }

  @override
  Future<void> setWeightAt(int index, double weight) =>
      setWeight(names[index], weight);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class Platform extends FilamentPlatform {
  Platform(this.native);

  final Native native;

  @override
  Future<thermion.ThermionViewer> createViewer() async {
    native.log.add('createViewer');
    return Viewer(native);
  }

  @override
  thermion.FilamentApp appFor(thermion.ThermionViewer viewer) => App(native);

  @override
  void setTargetFramerate(int fps) => native.log.add('frameRate $fps');

  @override
  Future<void> releaseViewer(thermion.ThermionViewer viewer) async =>
      native.log.add('release');

  @override
  void resumeFrames() {}

  @override
  void pauseFrames() {}
}

final class GradingBuilder implements thermion.ColorGradingBuilder {
  GradingBuilder(this.native);
  final Native native;
  @override
  thermion.ColorGradingBuilder exposure(double value) {
    native.log.add('exposure $value');
    return this;
  }

  @override
  Future<thermion.ColorGrading> build() =>
      native.call<thermion.ColorGrading>('buildGrading', Grading(native));
  @override
  dynamic noSuchMethod(Invocation call) =>
      native.call<void>('builder.${nameOf(call)}', null);
}

final class Grading implements thermion.ColorGrading {
  Grading(this.native);
  final Native native;
  @override
  dynamic noSuchMethod(Invocation call) =>
      native.call<void>('grading.${nameOf(call)}', null);
}

final class App implements thermion.FilamentApp {
  App(this.native);
  final Native native;
  @override
  thermion.RenderableManager get renderableManager => Renderables(native);
  @override
  AnimationManager get animationManager => Animations(native);
  @override
  Future<thermion.Matrix4> getLocalTransform(int entity) async =>
      native.transforms[entity]?.clone() ?? thermion.Matrix4.identity();
  @override
  Future<int> createEntity({bool createTransformComponent = true}) async =>
      native.nextEntity++;
  @override
  Future<int?> getParent(int entity) async => native.parents[entity];
  @override
  Future<thermion.Matrix4> getWorldTransform(int entity) async {
    final local =
        native.transforms[entity]?.clone() ?? thermion.Matrix4.identity();
    final parent = native.parents[entity];
    if (parent == null) return local;
    return (await getWorldTransform(parent))..multiply(local);
  }

  @override
  Future setParent(
    int child,
    int? parent, {
    bool preserveScaling = false,
  }) async {
    native.parents[child] = parent;
  }

  @override
  Future setTransform(int entity, thermion.Matrix4 transform) async {
    native.poseWrite('transform');
    native.transforms[entity] = transform.clone();
  }

  @override
  Future destroyEntity(int entity) async {
    native.destroyedEntities.add(entity);
  }

  @override
  Future registerRequestFrameHook(Future Function() hook) async {
    while (native.processingHooks) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    native.hooks.add(hook);
  }

  @override
  Future unregisterRequestFrameHook(Future Function() hook) async {
    while (native.processingHooks) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    native.hooks.remove(hook);
  }

  @override
  dynamic noSuchMethod(Invocation call) {
    native.calls.add(call);
    return switch (nameOf(call)) {
      'createUbershaderMaterialInstance' =>
        native.call<thermion.MaterialInstance>('createMaterial', () {
          final material = Material(native);
          native.createdMaterials.add(material);
          return material;
        }()),
      'decodeImage' => native.call<thermion.LinearImage>(
        'decodeImage',
        Image(native),
      ),
      'createTexture' => native.call<thermion.Texture>(
        'createTexture',
        Texture(native),
      ),
      'createTextureSampler' => native.call<thermion.TextureSampler>(
        'createSampler',
        Sampler(native),
      ),
      final name => native.call<void>(name, null),
    };
  }
}

final class Animations implements AnimationManager {
  Animations(this.native);
  final Native native;
  @override
  Future<bool> updateBoneMatrices(thermion.ThermionAsset asset) =>
      native.call('updateBoneMatrices', true);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class Renderables implements thermion.RenderableManager {
  Renderables(this.native);
  final Native native;
  @override
  Future<thermion.MaterialInstance?> getMaterialInstanceAt(
    int entity,
    int primitiveIndex,
  ) async => PartMaterial(native, (entity, primitiveIndex));
  @override
  Future<bool> setMaterialInstanceAt(
    int entity,
    int primitiveIndex,
    thermion.MaterialInstance material,
  ) async {
    native.swaps.add((entity, primitiveIndex, material));
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation call) => super.noSuchMethod(call);
}

final class PartMaterial implements thermion.MaterialInstance {
  PartMaterial(this.native, this.key);
  final Native native;
  final (int, int) key;
  @override
  Future setParameterFloat4(
    String name,
    double x,
    double y,
    double z,
    double w,
  ) async {
    if (name == 'emissiveFactor') {
      native.materialEmissives[key] = [x, y, z, w];
    } else {
      native.materialColors[key] = [x, y, z, w];
    }
  }

  @override
  dynamic noSuchMethod(Invocation call) => super.noSuchMethod(call);
}

final class Material implements thermion.MaterialInstance {
  Material(this.native);
  final Native native;
  @override
  dynamic noSuchMethod(Invocation call) {
    native.calls.add(call);
    return native.call<void>('material.${nameOf(call)}', null);
  }
}

final class Image implements thermion.LinearImage {
  Image(this.native);
  final Native native;
  @override
  dynamic noSuchMethod(Invocation call) => switch (nameOf(call)) {
    'getWidth' || 'getHeight' => Future.value(64),
    'getChannels' => Future.value(4),
    final name => native.call<void>('image.$name', null),
  };
}

final class Texture implements thermion.Texture {
  Texture(this.native);
  final Native native;
  @override
  dynamic noSuchMethod(Invocation call) =>
      native.call<void>('texture.${nameOf(call)}', null);
}

final class Sampler implements thermion.TextureSampler {
  Sampler(this.native);
  final Native native;
  @override
  dynamic noSuchMethod(Invocation call) =>
      native.call<void>('sampler.${nameOf(call)}', null);
}

// Minimal self-contained GLB fixtures exercise the controller load boundary.
Uint8List glb(Map<String, dynamic> document, [Uint8List? bin]) {
  final json = utf8.encode(jsonEncode(document));
  final jsonSize = (json.length + 3) & ~3;
  final binSize = ((bin?.length ?? 0) + 3) & ~3;
  final result = Uint8List(20 + jsonSize + (bin == null ? 0 : 8 + binSize));
  final data = ByteData.sublistView(result);
  data.setUint32(0, 0x46546c67, Endian.little);
  data.setUint32(4, 2, Endian.little);
  data.setUint32(8, result.length, Endian.little);
  data.setUint32(12, jsonSize, Endian.little);
  data.setUint32(16, 0x4e4f534a, Endian.little);
  result.fillRange(20, 20 + jsonSize, 32);
  result.setRange(20, 20 + json.length, json);
  if (bin != null) {
    data.setUint32(20 + jsonSize, binSize, Endian.little);
    data.setUint32(24 + jsonSize, 0x004e4942, Endian.little);
    result.setRange(28 + jsonSize, 28 + jsonSize + bin.length, bin);
  }
  return result;
}

Map<String, dynamic> boxDocument({Map<String, dynamic> transform = const {}}) =>
    {
      'asset': {'version': '2.0'},
      'scene': 0,
      'scenes': [
        {
          'nodes': [0],
        },
      ],
      'nodes': [
        {'mesh': 0, ...transform},
      ],
      'meshes': [
        {
          'primitives': [
            {
              'attributes': {'POSITION': 0},
            },
          ],
        },
      ],
      'accessors': [
        {
          'componentType': 5126,
          'type': 'VEC3',
          'count': 2,
          'min': [10, 20, 30],
          'max': [14, 28, 32],
        },
      ],
    };

Uint8List boxGlb(Map<String, dynamic> doc) {
  final accessor = doc['accessors'][0] as Map<String, dynamic>;
  final data = ByteData(24);
  final values = [...accessor['min'] as List, ...accessor['max'] as List];
  for (var i = 0; i < values.length; i++) {
    data.setFloat32(i * 4, (values[i] as num).toDouble(), Endian.little);
  }
  accessor['bufferView'] = 0;
  doc['buffers'] = [
    {'byteLength': 24},
  ];
  doc['bufferViews'] = [
    {'buffer': 0, 'byteLength': 24},
  ];
  return glb(doc, data.buffer.asUint8List());
}

Uint8List stridedFixture() {
  final data = ByteData(72);
  final positions = [10.0, 20.0, 30.0, 14.0, 28.0, 32.0];
  for (var i = 0; i < positions.length; i++) {
    data.setFloat32(
      8 + (i ~/ 3) * 16 + (i % 3) * 4,
      positions[i],
      Endian.little,
    );
  }
  data.setUint16(40, 1, Endian.little);
  for (var i = 0; i < 3; i++) {
    data.setFloat32(44 + i * 4, [18.0, 24.0, 34.0][i], Endian.little);
    data.setFloat32(56 + i * 4, [4.0, 0.0, 0.0][i], Endian.little);
  }
  return glb({
    'asset': {'version': '2.0'},
    'scene': 1,
    'scenes': [
      {
        'nodes': [2],
      },
      {
        'nodes': [0],
      },
    ],
    'nodes': [
      {
        'scale': [2, 2, 2],
        'children': [1],
      },
      {
        'mesh': 0,
        'translation': [5, 0, 0],
        'weights': [0.5],
      },
      {
        'mesh': 0,
        'translation': [10000, 0, 0],
      },
    ],
    'meshes': [
      {
        'weights': [1],
        'primitives': [
          {
            'attributes': {'POSITION': 0},
            'targets': [
              {'POSITION': 1},
            ],
          },
        ],
      },
    ],
    'buffers': [
      {'byteLength': 72},
    ],
    'bufferViews': [
      {'buffer': 0, 'byteOffset': 4, 'byteLength': 32, 'byteStride': 16},
      {'buffer': 0, 'byteOffset': 40, 'byteLength': 2},
      {'buffer': 0, 'byteOffset': 44, 'byteLength': 12},
      {'buffer': 0, 'byteOffset': 56, 'byteLength': 12},
    ],
    'accessors': [
      {
        'bufferView': 0,
        'byteOffset': 4,
        'componentType': 5126,
        'type': 'VEC3',
        'count': 2,
        'sparse': {
          'count': 1,
          'indices': {'bufferView': 1, 'componentType': 5123},
          'values': {'bufferView': 2},
        },
      },
      {
        'componentType': 5126,
        'type': 'VEC3',
        'count': 2,
        'sparse': {
          'count': 1,
          'indices': {'bufferView': 1, 'componentType': 5123},
          'values': {'bufferView': 3},
        },
      },
    ],
  }, data.buffer.asUint8List());
}

Uint8List skinnedFixture() {
  final doc = <String, dynamic>{
    'asset': {'version': '2.0'},
    'scene': 0,
    'scenes': [
      {
        'nodes': [0, 1, 2, 3, 4],
      },
    ],
    'nodes': [
      {
        'mesh': 0,
        'skin': 0,
        'scale': [0.0001, 0.0001, 0.0001],
      },
      {
        'translation': [10, 0, 0],
      },
      {
        'translation': [14, 0, 0],
      },
      {
        'mesh': 1,
        'skin': 1,
        'translation': [-1000, 0, 0],
      },
      {
        'translation': [20, 0, 0],
      },
      {
        'mesh': 0,
        'translation': [10000, 0, 0],
      }, // inactive scene node
    ],
    'meshes': [],
    'skins': [],
    'accessors': [],
    'bufferViews': [],
  };
  final binary = BytesBuilder();
  int accessor(
    List<double> values,
    String type,
    int size, {
    bool bytes = false,
  }) {
    final padding = (4 - binary.length % 4) % 4;
    binary.add(Uint8List(padding));
    final offset = binary.length;
    final data = ByteData(values.length * (bytes ? 1 : 4));
    for (var i = 0; i < values.length; i++) {
      if (bytes) {
        data.setUint8(i, values[i].toInt());
      } else {
        data.setFloat32(i * 4, values[i], Endian.little);
      }
    }
    binary.add(data.buffer.asUint8List());
    final index = (doc['accessors'] as List).length;
    (doc['bufferViews'] as List).add({
      'buffer': 0,
      'byteOffset': offset,
      'byteLength': data.lengthInBytes,
    });
    (doc['accessors'] as List).add({
      'bufferView': index,
      'componentType': bytes ? 5121 : 5126,
      'count': values.length ~/ size,
      'type': type,
      if (bytes) 'normalized': false,
    });
    return index;
  }

  final positions = accessor([0, 0, 0, 2, 4, 0], 'VEC3', 3);
  final joints = accessor([0, 1, 0, 0, 0, 1, 0, 0], 'VEC4', 4, bytes: true);
  final weights = accessor(
    [64, 192, 0, 0, 64, 192, 0, 0],
    'VEC4',
    4,
    bytes: true,
  );
  doc['accessors'][weights]['normalized'] = true;
  final delta = accessor([2, 0, 0, 2, 0, 0], 'VEC3', 3);
  final inverse = accessor(
    [
      ...thermion.Matrix4.identity().storage,
      ...thermion.Matrix4.translationValues(-2, 0, 0).storage,
    ],
    'MAT4',
    16,
  );
  final joints2 = accessor([0, 0, 0, 0, 0, 0, 0, 0], 'VEC4', 4, bytes: true);
  final weights2 = accessor([1, 0, 0, 0, 1, 0, 0, 0], 'VEC4', 4);
  doc['meshes'] = [
    {
      'weights': [1],
      'primitives': [
        {
          'attributes': {
            'POSITION': positions,
            'JOINTS_0': joints,
            'WEIGHTS_0': weights,
          },
          'targets': [
            {'POSITION': delta},
          ],
        },
      ],
    },
    {
      'primitives': [
        {
          'attributes': {
            'POSITION': positions,
            'JOINTS_0': joints2,
            'WEIGHTS_0': weights2,
          },
        },
      ],
    },
  ];
  doc['skins'] = [
    {
      'joints': [1, 2],
      'inverseBindMatrices': inverse,
    },
    {
      'joints': [4],
    },
  ];
  doc['buffers'] = [
    {'byteLength': binary.length},
  ];
  return glb(doc, binary.takeBytes());
}

// Isolate replies need real event-loop turns; native fakes stay in the widget
// test's fake zone so subsequent held calls and playback timers remain pumpable.
Future<void> finishLoad(Future<void> loading) async {
  var done = false;
  unawaited(
    loading.then(
      (_) {
        done = true;
      },
      onError: (Object _) {
        done = true;
      },
    ),
  );
  final clock = Stopwatch()..start();
  final binding = TestWidgetsFlutterBinding.instance;
  while (!done && clock.elapsed < const Duration(seconds: 10)) {
    await binding.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1)),
    );
    await binding.pump();
  }
  expect(done, isTrue, reason: 'Model initialization did not settle');
  await loading;
}

Future<FilamentModel3dController> loadFixture(
  Native native,
  Uint8List bytes, {
  Model3dOutfit? initialOutfit,
  Model3dLook? initialLook,
  void Function(FilamentModel3dController)? beforeLoad,
}) async {
  final source = FilamentModel3dSource(
    keepAlive: Duration.zero,
    client: MockClient((_) async => http.Response.bytes(bytes, 200)),
    baseUrl: Uri.parse('http://host/'),
    diskCache: false,
    platform: Platform(native),
  );
  final model =
      await source.controllerFor(const Model3dRequest(src: '/fixture.glb'))
          as FilamentModel3dController;
  if (initialOutfit != null) {
    (model as Model3dOutfitController).setOutfit(initialOutfit);
  }
  if (initialLook != null) {
    (model as Model3dLookController).setLook(initialLook);
  }
  beforeLoad?.call(model);
  await finishLoad(model.initialize());
  return model;
}
