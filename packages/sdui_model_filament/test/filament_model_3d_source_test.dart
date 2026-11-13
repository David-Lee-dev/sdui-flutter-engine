import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_model_filament/sdui_model_filament.dart';
import 'package:sdui_model_filament/src/filament_platform.dart';
import 'package:sdui_model_filament/src/load_stats.dart' show ModelDebugOverlay;
import 'package:thermion_flutter/thermion_flutter.dart' as thermion;

/// Every native call the fakes see, in order; a held call logs `name done`
/// once released.
final class _Native {
  final log = <String>[];
  final calls = <Invocation>[];

  /// The model's clips in native order: name and seconds.
  List<(String, double)> clips = const [('Wave', 1.0), ('Jump', 1.0)];

  /// The native index of each other animation call, as `name index`.
  final indices = <String>[];
  final _holds = <String, Completer<void>>{};

  /// Holds the next call to [name] until [release].
  void hold(String name) => _holds[name] = Completer<void>();

  void release(String name) => _holds.remove(name)!.complete();

  Future<T> call<T>(String name, T result) {
    log.add(name);
    final hold = _holds[name];
    if (hold == null) return Future.value(result);
    return hold.future.then((_) {
      log.add('$name done');
      return result;
    });
  }
}

String _nameOf(Invocation invocation) =>
    invocation.memberName.toString().split('"')[1];

final class _Viewer implements thermion.ThermionViewer {
  _Viewer(this.native);

  final _Native native;
  late final _asset = _Asset(native);

  @override
  thermion.View get view => _View(native);

  @override
  Future<thermion.Camera> getActiveCamera() =>
      native.call<thermion.Camera>('getActiveCamera', _Camera(native));

  @override
  dynamic noSuchMethod(Invocation invocation) {
    native.calls.add(invocation);
    return switch (_nameOf(invocation)) {
      // Its parameters change across thermion versions; match it by name.
      'loadGltfFromBuffer' => native.call<thermion.ThermionAsset>(
        'loadGltfFromBuffer',
        _asset,
      ),
      'setBackgroundColor' => native.call<thermion.Skybox>(
        'setBackgroundColor',
        _Skybox(),
      ),
      final name => native.call<void>(name, null),
    };
  }
}

final class _Skybox implements thermion.Skybox {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _View implements thermion.View {
  _View(this.native);

  final _Native native;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    native.calls.add(invocation);
    return native.call<void>(_nameOf(invocation), null);
  }
}

final class _Camera implements thermion.Camera {
  _Camera(this.native);

  final _Native native;

  @override
  Future<double> getFocalLength() => native.call('getFocalLength', 28.0);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    native.calls.add(invocation);
    return native.call<void>(_nameOf(invocation), null);
  }
}

/// A model with [_Native.clips], by default a one-second `Wave` and `Jump`.
final class _Asset implements thermion.ThermionAsset {
  _Asset(this.native);

  final _Native native;

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
    final name = _nameOf(invocation);
    if (name.contains('GltfAnimation')) {
      native.indices.add('$name ${invocation.positionalArguments.first}');
    }
    return native.call<void>(name, null);
  }
}

final class _Platform extends FilamentPlatform {
  _Platform(this.native);

  final _Native native;

  @override
  Future<thermion.ThermionViewer> createViewer() async => _Viewer(native);

  @override
  Future<void> releaseViewer(thermion.ThermionViewer viewer) async =>
      native.log.add('release');

  @override
  void resumeFrames() {}

  @override
  void pauseFrames() {}
}

void main() {
  // The Filament engine is native; these cover the Dart surface the `model_3d`
  // widget sees before a viewer exists.
  Future<FilamentModel3dController> controller({
    bool debugOverlay = false,
  }) async =>
      await FilamentModel3dSource(
            client: MockClient((_) async => http.Response('', 404)),
            baseUrl: Uri.parse('http://host/'),
            debugOverlay: debugOverlay,
          ).controllerFor(const Model3dRequest(src: '/a.glb'))
          as FilamentModel3dController;

  testWidgets('뷰어가 생기기 전에도 뷰를 그린다', (tester) async {
    final model = await controller();

    await tester.pumpWidget(
      SizedBox(width: 300, height: 200, child: model.buildView()),
    );

    expect(model.clips, isEmpty);
    expect(model.playback.isPlaying, isFalse);
    expect(find.byType(GestureDetector), findsNothing);
    await model.dispose();
  });

  testWidgets('뷰는 제스처를 잡지 않고, 로드 전 카메라 변경은 보관만 한다', (tester) async {
    final model = await controller();

    await tester.pumpWidget(
      SizedBox(width: 300, height: 200, child: model.buildView()),
    );
    model.setCamera(const Model3dCamera(yaw: 45, pitch: 10, zoom: 1.5));
    await tester.pump();

    expect(find.byType(GestureDetector), findsNothing);
    await model.dispose();
  });

  testWidgets('debugOverlay면 측정 오버레이를 씌운다', (tester) async {
    final model = await controller(debugOverlay: true);

    await tester.pumpWidget(
      SizedBox(width: 300, height: 200, child: model.buildView()),
    );

    expect(find.byType(ModelDebugOverlay), findsOneWidget);
    expect(model.stats.mount, 1);
    await tester.pumpWidget(const SizedBox());
    await model.dispose();
  });

  test('로드 전에 재생해도 상태만 바꾸고 실패하지 않는다', () async {
    final model = await controller();
    var notified = 0;
    model.addListener(() => notified++);

    await model.play('Wave', loop: false);
    await model.stop();

    expect(model.playback.clip, 'Wave');
    expect(model.playback.isPlaying, isFalse);
    expect(notified, 2);
    await model.dispose();
  });

  test('로드 전에는 클립 길이가 없고 포즈는 실패 없이 무시한다', () async {
    final model = await controller();

    expect(model.clipDuration('Wave'), isNull);
    model.setPose('Wave', const Duration(seconds: 1));
    await model.dispose();
  });

  group('네이티브 자원', () {
    late _Native native;
    late Completer<void> bytes;

    Future<FilamentModel3dController> controller({
      double iblIntensity = 30000,
    }) async {
      native = _Native();
      bytes = Completer<void>();
      return await FilamentModel3dSource(
            client: MockClient((_) async {
              await bytes.future;
              return http.Response.bytes([1], 200);
            }),
            baseUrl: Uri.parse('http://host/'),
            diskCache: false,
            iblIntensity: iblIntensity,
            platform: _Platform(native),
          ).controllerFor(const Model3dRequest(src: '/a.glb'))
          as FilamentModel3dController;
    }

    Future<FilamentModel3dController> loaded(WidgetTester tester) async {
      final model = await controller();
      bytes.complete();
      await model.initialize();
      return model;
    }

    testWidgets('계약: 투명 배경과 지정한 IBL을 모델보다 먼저 설정한다', (tester) async {
      final model = await controller(iblIntensity: 12345);
      bytes.complete();
      await model.initialize();

      final background = native.calls.singleWhere(
        (call) => call.memberName == #setBackgroundColor,
      );
      expect(background.positionalArguments, [0, 0, 0, 0]);
      final blend = native.calls.singleWhere(
        (call) => call.memberName == #setBlendMode,
      );
      expect(blend.positionalArguments, [thermion.BlendMode.transparent]);
      final ibl = native.calls.singleWhere(
        (call) => call.memberName == #loadIbl,
      );
      expect(ibl.positionalArguments, [FilamentModel3dSource.iblAsset]);
      expect(ibl.namedArguments[#intensity], 12345);
      expect(
        native.log,
        containsAllInOrder([
          'setBackgroundColor',
          'setBlendMode',
          'loadIbl',
          'loadGltfFromBuffer',
          'transformToUnitCube',
          'getGltfAnimationNames',
        ]),
      );
      expect(model.stats.error, isNull);
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('계약: loop와 crossfade를 초 단위로 전달한다', (tester) async {
      final model = await loaded(tester);
      await model.play(
        'Wave',
        loop: true,
        crossfade: const Duration(microseconds: 125000),
      );
      await model.play(
        'Jump',
        loop: false,
        crossfade: const Duration(milliseconds: 250),
      );

      final plays = native.calls
          .where((call) => call.memberName == #playGltfAnimation)
          .toList();
      expect(plays.map((call) => call.positionalArguments), [
        [0],
        [1],
      ]);
      expect(plays.map((call) => call.namedArguments[#loop]), [true, false]);
      expect(plays.map((call) => call.namedArguments[#crossfade]), [
        0.125,
        0.25,
      ]);
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('계약: 재생을 멈춘 뒤 포즈의 마이크로초를 초로 전달한다', (tester) async {
      final model = await loaded(tester);
      await model.play('Wave', loop: true);
      native.calls.clear();
      model.setPose('Wave', const Duration(microseconds: 123456));
      await tester.pump();

      final animation = native.calls
          .where((call) => _nameOf(call).contains('GltfAnimation'))
          .toList();
      expect(animation.map((call) => call.memberName), [
        #stopGltfAnimation,
        #setGltfAnimationTime,
      ]);
      expect(animation.last.positionalArguments, [0, 0.123456]);
      expect(model.playback.isPlaying, isFalse);
      expect(model.playback.completions, 0);
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('계약: 로드 전과 호출 중 변경한 최신 카메라를 적용한다', (tester) async {
      final model = await controller();
      model.setCamera(const Model3dCamera(yaw: 90, zoom: 2));
      bytes.complete();
      await model.initialize();
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

    testWidgets('모델을 받는 중에 버리면 뷰어를 풀고 그 뒤로는 뷰어를 건드리지 않는다', (tester) async {
      final model = await controller();
      final loading = model.initialize();
      await tester.pump();

      await model.dispose();
      expect(native.log.last, 'release');
      final released = native.log.length;
      bytes.complete();
      await loading;

      expect(native.log.length, released);
      expect(native.log, isNot(contains('loadGltfFromBuffer')));
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('네이티브 호출 도중에 버리면 그 호출이 끝난 뒤에 뷰어를 푼다', (tester) async {
      final model = await controller();
      native.hold('loadIbl');
      final loading = model.initialize();
      await tester.pump();
      expect(native.log.last, 'loadIbl');

      final disposing = model.dispose();
      await tester.pump();
      expect(native.log, isNot(contains('release')));

      native.release('loadIbl');
      await disposing;
      bytes.complete();
      await loading;

      expect(native.log.sublist(native.log.indexOf('loadIbl done')), [
        'loadIbl done',
        'release',
      ]);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('늦게 끝난 이전 재생은 새 재생을 끝내지 않는다', (tester) async {
      final model = await loaded(tester);
      native.hold('playGltfAnimation');
      final wave = model.play('Wave', loop: false);
      await tester.pump();

      unawaited(model.play('Jump', loop: true));
      native.release('playGltfAnimation');
      await wave;
      await tester.pump(const Duration(seconds: 2));

      expect(model.playback.clip, 'Jump');
      expect(model.playback.isPlaying, isTrue);
      expect(model.playback.completions, 0);
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('늦게 끝난 stop은 그 뒤에 시작한 재생을 멈춤으로 덮지 않는다', (tester) async {
      final model = await loaded(tester);
      await model.play('Wave', loop: true);
      native.hold('stopGltfAnimation');
      final stopping = model.stop();
      await tester.pump();

      unawaited(model.play('Jump', loop: false));
      native.release('stopGltfAnimation');
      await stopping;
      await tester.pump();
      expect(model.playback.clip, 'Jump');
      expect(model.playback.isPlaying, isTrue);

      await tester.pump(const Duration(seconds: 1));
      expect(model.playback.isPlaying, isFalse);
      expect(model.playback.completions, 1);
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('이름이 겹치면 첫 클립을 쓰고, 뒤 클립은 원래 번호로 재생하고 포즈를 잡는다', (tester) async {
      final model = await controller();
      native.clips = const [('Wave', 1.0), ('Wave', 3.0), ('Jump', 2.0)];
      bytes.complete();
      await model.initialize();

      expect(model.clips, ['Wave', 'Jump']);
      expect(model.clipDuration('Wave'), const Duration(seconds: 1));
      expect(model.clipDuration('Jump'), const Duration(seconds: 2));

      await model.play('Jump', loop: true);
      model.setPose('Jump', const Duration(milliseconds: 500));
      await tester.pump();
      await model.play('Wave', loop: true);
      await model.stop();

      expect(native.indices, [
        'playGltfAnimation 2',
        'stopGltfAnimation 2',
        'setGltfAnimationTime 2',
        'playGltfAnimation 0',
        'stopGltfAnimation 0',
      ]);
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('재생 중인 클립의 포즈를 잡으면 재생을 끝내고 멈춘 뒤에 시간을 맞춘다', (tester) async {
      final model = await loaded(tester);
      await model.play('Wave', loop: false);
      native.log.clear();

      model.setPose('Wave', const Duration(milliseconds: 500));
      expect(model.playback.isPlaying, isFalse);
      await tester.pump(const Duration(seconds: 2));

      expect(model.playback.completions, 0);
      expect(native.log.where((call) => call.contains('GltfAnimation')), [
        'stopGltfAnimation',
        'setGltfAnimationTime',
      ]);
      await model.dispose();
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
