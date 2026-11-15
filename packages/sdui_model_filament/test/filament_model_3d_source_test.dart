import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_model_filament/sdui_model_filament.dart';
import 'package:sdui_model_filament/src/load_stats.dart' show ModelDebugOverlay;
import 'package:thermion_flutter/thermion_flutter.dart' as thermion;

import 'support/filament_fakes.dart';

void main() {
  Future<FilamentModel3dController> controller({
    bool debugOverlay = false,
  }) async =>
      await FilamentModel3dSource(
            keepAlive: Duration.zero,
            client: MockClient((_) async => http.Response('', 404)),
            baseUrl: Uri.parse('http://host/'),
            debugOverlay: debugOverlay,
          ).controllerFor(const Model3dRequest(src: '/a.glb'))
          as FilamentModel3dController;

  testWidgets('default source applies 60fps to every viewer before use', (
    tester,
  ) async {
    final native = Native();
    final source = FilamentModel3dSource(
      keepAlive: Duration.zero,
      client: MockClient((_) async => http.Response.bytes([1], 200)),
      baseUrl: Uri.parse('http://host/'),
      diskCache: false,
      platform: Platform(native),
    );
    expect(source.frameRate, 60);
    await source.warmUp();
    expect(
      native.log.indexOf('createViewer'),
      lessThan(native.log.indexOf('frameRate 60')),
    );
    expect(
      native.log.indexOf('frameRate 60'),
      lessThan(native.log.indexOf('setRendering')),
    );
    for (var i = 0; i < 2; i++) {
      native.log.clear();
      final model = await source.controllerFor(
        const Model3dRequest(src: '/a.glb'),
      );
      await finishLoad(model.initialize());
      if (i == 0) {
        expect(native.log, isNot(contains('createViewer')));
      } else {
        expect(
          native.log.indexOf('createViewer'),
          lessThan(native.log.indexOf('frameRate 60')),
        );
        expect(
          native.log.indexOf('frameRate 60'),
          lessThan(native.log.indexOf('setBackgroundColor')),
        );
      }
      await model.dispose();
    }
    await tester.pump(const Duration(seconds: 1));
  });

  for (final rate in <int?>[null, 30]) {
    testWidgets(
      'explicit frameRate $rate applies to warmup and loaded viewer',
      (tester) async {
        final native = Native();
        final source = FilamentModel3dSource(
          keepAlive: Duration.zero,
          client: MockClient((_) async => http.Response.bytes([1], 200)),
          baseUrl: Uri.parse('http://host/'),
          diskCache: false,
          frameRate: rate,
          platform: Platform(native),
        );
        expect(source.frameRate, rate);
        await source.warmUp();
        expect(
          native.log.indexOf('createViewer'),
          lessThan(native.log.indexOf('frameRate ${rate ?? 0}')),
        );
        expect(
          native.log.indexOf('frameRate ${rate ?? 0}'),
          lessThan(native.log.indexOf('setRendering')),
        );
        native.log.clear();
        final model = await source.controllerFor(
          const Model3dRequest(src: '/a.glb'),
        );
        await finishLoad(model.initialize());
        expect(native.log, isNot(contains('createViewer')));
        await model.dispose();
        await tester.pump(const Duration(seconds: 1));
      },
    );
  }

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

    Future<FilamentModel3dController> loaded(WidgetTester tester) async {
      final model = await controller();
      bytes.complete();
      await finishLoad(model.initialize());
      return model;
    }

    testWidgets('계약: 투명 배경과 지정한 IBL을 모델보다 먼저 설정한다', (tester) async {
      final model = await controller(iblIntensity: 12345);
      bytes.complete();
      await finishLoad(model.initialize());

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
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));

      final animation = native.calls
          .where((call) => nameOf(call).contains('GltfAnimation'))
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

    testWidgets('모델을 받는 중에 버리면 뷰어를 풀고 그 뒤로는 뷰어를 건드리지 않는다', (tester) async {
      final model = await controller();
      final loading = model.initialize();
      await tester.pump();

      await model.dispose();
      expect(native.log.last, 'release');
      final released = native.log.length;
      bytes.complete();
      await finishLoad(loading);

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
      await finishLoad(loading);

      expect(
        native.log.indexOf('release'),
        greaterThan(native.log.indexOf('loadIbl done')),
      );
      expect(native.log.sublist(native.log.indexOf('release')), ['release']);
      expect(native.log, isNot(contains('loadGltfFromBuffer')));
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
      await finishLoad(model.initialize());

      expect(model.clips, ['Wave', 'Jump']);
      expect(model.clipDuration('Wave'), const Duration(seconds: 1));
      expect(model.clipDuration('Jump'), const Duration(seconds: 2));

      await model.play('Jump', loop: true);
      model.setPose('Jump', const Duration(milliseconds: 500));
      await tester.pump();
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));
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
      await native.frame();
      await tester.pump(const Duration(milliseconds: 2));

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
