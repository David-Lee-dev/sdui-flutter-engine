import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';
import 'package:sdui_engine/src/runtime/media/model_3d_source_registry.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';

import 'model_3d/fixtures.dart';

void main() {
  setUp(() {
    Model3dSourceRegistry.reset();
    ImageSourceRegistry.reset();
    ImageSourceRegistry.install(const TextModel3dImageSource());
  });
  tearDown(() {
    Model3dSourceRegistry.reset();
    ImageSourceRegistry.reset();
  });

  group('progress', () {
    /// The clip of every `on_progress_end` dispatch.
    List<Object?> ends(Model3dSink sink) => [
      for (final (action, event) in sink.calls)
        if (action == 'done') (event! as Map)['clip'],
    ];

    /// Every `on_progress_arrive` payload.
    List<Object?> arrivals(Model3dSink sink) => [
      for (final (action, event) in sink.calls)
        if (action == 'arrived') event,
    ];

    Map<String, Object?> props(
      Map<String, Object?> progress, {
      String? onEnd = 'done',
      String? onArrive,
    }) => {
      'src': 'char.glb',
      'height': 100,
      'progress': {'clip': 'Wave', ...progress},
      'on_progress_end': ?onEnd,
      'on_progress_arrive': ?onArrive,
    };

    Future<FakeModel3dController> ready(
      WidgetTester tester,
      Map<String, Object?> progress, {
      ActionSink? sink,
    }) async {
      final source = RecordingModel3dSource();
      Model3dSourceRegistry.install(source);
      await pumpModel3d(tester, props(progress), dispatch: sink);
      await tester.pumpAndSettle();
      return source.controllers.single;
    }

    testWidgets('로드 후 첫 목표는 재생 없이 그 자리에 바로 보인다', (tester) async {
      final sink = Model3dSink();
      final controller = await ready(tester, const {'at': 3000}, sink: sink);

      expect(controller.poses, [('Wave', const Duration(seconds: 3))]);
      expect(controller.plays, isEmpty);
      expect(sink.calls, isEmpty);
    });

    testWidgets('목표가 바뀌면 클립 속도로 재생해 가서 멈춘다', (tester) async {
      final controller = await ready(tester, const {'at': 1000});

      await pumpModel3d(tester, props(const {'at': 3000}));
      await tester.pump(const Duration(seconds: 1));
      expect(controller.seconds, closeTo(2, 0.05));

      await tester.pumpAndSettle();
      expect(controller.seconds, 3);
      final count = controller.poses.length;
      await tester.pump(const Duration(seconds: 1));
      expect(controller.poses.length, count);
    });

    testWidgets('가려졌다 다시 보이면 가려진 동안의 시간을 건너뛰지 않고 멈춘 자리에서 이어 간다', (
      tester,
    ) async {
      final sink = Model3dSink();
      final controller = await ready(tester, const {'at': 0}, sink: sink);
      final moving = props(const {'value': 1});

      await pumpModel3d(tester, moving, dispatch: sink);
      await tester.pump(const Duration(milliseconds: 1800));
      expect(controller.seconds, closeTo(1.8, 0.05)); // 30%
      await pumpModel3d(tester, moving, dispatch: sink, shown: false);
      final paused = controller.seconds;
      await tester.pump(const Duration(seconds: 10));
      expect(controller.seconds, paused);

      await pumpModel3d(tester, moving, dispatch: sink);
      expect(controller.seconds, paused);
      await tester.pump(const Duration(seconds: 1));
      expect(controller.seconds, closeTo(paused + 1, 0.05));
      expect(ends(sink), isEmpty);
    });

    testWidgets('재생 중에 목표가 더 멀어지면 끊기지 않고 이어 간다', (tester) async {
      final controller = await ready(tester, const {'at': 0});

      await pumpModel3d(tester, props(const {'at': 1000}));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpModel3d(tester, props(const {'at': 4000}));
      await tester.pumpAndSettle();

      final times = [for (final (_, time) in controller.poses) time];
      for (var i = 1; i < times.length; i++) {
        expect(times[i], greaterThan(times[i - 1]));
      }
      expect(controller.seconds, 4);
    });

    testWidgets('목표가 앞으로 돌아가면 거꾸로 재생하고 speed는 속도를 바꾼다', (tester) async {
      final controller = await ready(tester, const {'at': 4000, 'speed': 2});

      await pumpModel3d(tester, props(const {'at': 2000, 'speed': 2}));
      await tester.pump(const Duration(milliseconds: 500));
      expect(controller.seconds, closeTo(3, 0.05));
      await tester.pumpAndSettle();
      expect(controller.seconds, 2);

      await pumpModel3d(tester, props(const {'at': 5000, 'speed': 0}));
      await tester.pump();
      expect(controller.poses.last, ('Wave', const Duration(seconds: 5)));
    });

    testWidgets('value는 비율이고 끝에 도착하면 on_progress_end를 한 번 보낸다', (tester) async {
      final sink = Model3dSink();
      final controller = await ready(tester, const {'value': 0.5}, sink: sink);
      expect(controller.seconds, 3);

      await pumpModel3d(tester, props(const {'value': 1}), dispatch: sink);
      await tester.pumpAndSettle();
      expect(controller.seconds, 6);
      expect(ends(sink), ['Wave']);

      // A target past the end is clamped there: the playhead stays put.
      await pumpModel3d(tester, props(const {'value': 1.5}), dispatch: sink);
      await tester.pumpAndSettle();
      expect(sink.calls, hasLength(1));
    });

    testWidgets('처음부터 끝에 있으면 on_progress_end를 보내지 않는다', (tester) async {
      final sink = Model3dSink();
      final controller = await ready(tester, const {'value': 1}, sink: sink);

      expect(controller.seconds, 6);
      expect(sink.calls, isEmpty);
    });

    testWidgets('로딩 중에 끝으로 바뀌면 붙자마자 끝 모습으로 보이고 on_progress_end를 보낸다', (
      tester,
    ) async {
      final gate = Completer<void>();
      final source = RecordingModel3dSource(gate: gate);
      Model3dSourceRegistry.install(source);
      final sink = Model3dSink();

      await pumpModel3d(tester, props(const {'at': 0}), dispatch: sink);
      await pumpModel3d(tester, props(const {'at': 6000}), dispatch: sink);
      gate.complete();
      await tester.pumpAndSettle();

      expect(source.controllers.single.poses, [
        ('Wave', const Duration(seconds: 6)),
      ]);
      expect(ends(sink), ['Wave']);
    });

    testWidgets('렌더러가 없거나 클립이 없으면 value 끝은 바로 on_progress_end를 보낸다', (
      tester,
    ) async {
      final sink = Model3dSink();
      await pumpModel3d(tester, props(const {'value': 0.2}), dispatch: sink);
      await pumpModel3d(tester, props(const {'value': 1}), dispatch: sink);
      await tester.pumpAndSettle();
      expect(ends(sink), ['Wave']);

      await tester.pumpWidget(const SizedBox());
      sink.calls.clear();
      final source = RecordingModel3dSource();
      Model3dSourceRegistry.install(source);
      Map<String, Object?> missing(Object value) => {
        ...props(const {}),
        'progress': {'clip': 'Dance', 'value': value},
      };
      await pumpModel3d(tester, missing(0), dispatch: sink);
      await tester.pumpAndSettle();
      await pumpModel3d(tester, missing(1), dispatch: sink);
      await tester.pumpAndSettle();
      expect(source.controllers.single.poses, isEmpty);
      expect(ends(sink), ['Dance']);
    });

    testWidgets('목표에 도착하면 on_progress_arrive를 한 번 보내고 첫 목표는 보내지 않는다', (
      tester,
    ) async {
      final sink = Model3dSink();
      final source = RecordingModel3dSource();
      Model3dSourceRegistry.install(source);
      Map<String, Object?> at(num seconds) =>
          props({'at': seconds * 1000}, onEnd: null, onArrive: 'arrived');

      await pumpModel3d(tester, at(1), dispatch: sink);
      await tester.pumpAndSettle();
      expect(arrivals(sink), isEmpty);

      await pumpModel3d(tester, at(3), dispatch: sink);
      await tester.pump(const Duration(seconds: 1));
      expect(arrivals(sink), isEmpty);
      await tester.pumpAndSettle();
      expect(arrivals(sink), [
        {'clip': 'Wave', 'at': 3000},
      ]);

      // A target replaced mid-way does not arrive; only the last one does.
      await pumpModel3d(tester, at(4), dispatch: sink);
      await tester.pump(const Duration(milliseconds: 500));
      await pumpModel3d(tester, at(5), dispatch: sink);
      await tester.pumpAndSettle();
      expect(arrivals(sink), [
        {'clip': 'Wave', 'at': 3000},
        {'clip': 'Wave', 'at': 5000},
      ]);
    });

    testWidgets('끝에 도착하면 on_progress_end 다음에 on_progress_arrive를 보낸다', (
      tester,
    ) async {
      final sink = Model3dSink();
      await ready(tester, const {'at': 5000}, sink: sink);

      await pumpModel3d(
        tester,
        props(const {'at': 6000}, onArrive: 'arrived'),
        dispatch: sink,
      );
      await tester.pumpAndSettle();

      expect(sink.calls.map((call) => call.$1), ['done', 'arrived']);
    });

    testWidgets('바로 옮기거나 움직일 게 없으면 바로 도착한다', (tester) async {
      final sink = Model3dSink();
      final controller = await ready(tester, const {'at': 2000}, sink: sink);
      Map<String, Object?> target(Map<String, Object?> progress) =>
          props(progress, onEnd: null, onArrive: 'arrived');

      // speed 0 jumps.
      await pumpModel3d(
        tester,
        target(const {'at': 4000, 'speed': 0}),
        dispatch: sink,
      );
      // Only the speed changes: the playhead already holds the target.
      await pumpModel3d(
        tester,
        target(const {'at': 4000, 'speed': 2}),
        dispatch: sink,
      );
      // A new clip is shown at its target at once.
      await pumpModel3d(tester, {
        ...target(const {}),
        'progress': {'clip': 'Jump', 'value': 0.5},
      }, dispatch: sink);
      await tester.pump();

      expect(controller.poses.last, (
        'Jump',
        const Duration(milliseconds: 500),
      ));
      expect(arrivals(sink), [
        {'clip': 'Wave', 'at': 4000},
        {'clip': 'Wave', 'at': 4000},
        {'clip': 'Jump', 'at': 500},
      ]);
    });

    testWidgets('렌더러가 없거나 클립이 없으면 목표가 바뀔 때마다 바로 도착한다', (tester) async {
      final sink = Model3dSink();
      Map<String, Object?> missing(Object at) => {
        ...props(const {}, onEnd: null, onArrive: 'arrived'),
        'progress': {'clip': 'Dance', 'at': at},
      };

      await pumpModel3d(tester, missing(0), dispatch: sink);
      await pumpModel3d(tester, missing(1), dispatch: sink);
      await tester.pumpAndSettle();
      expect(arrivals(sink), [
        {'clip': 'Dance', 'at': null},
      ]);

      await tester.pumpWidget(const SizedBox());
      sink.calls.clear();
      Model3dSourceRegistry.install(RecordingModel3dSource());
      await pumpModel3d(tester, missing(0), dispatch: sink);
      await tester.pumpAndSettle();
      await pumpModel3d(tester, missing(1), dispatch: sink);
      await tester.pumpAndSettle();
      expect(arrivals(sink), [
        {'clip': 'Dance', 'at': null},
      ]);
    });

    testWidgets('로딩 중에 목표가 바뀌면 붙자마자 도착한다', (tester) async {
      final gate = Completer<void>();
      Model3dSourceRegistry.install(RecordingModel3dSource(gate: gate));
      final sink = Model3dSink();
      Map<String, Object?> at(num seconds) =>
          props({'at': seconds * 1000}, onEnd: null, onArrive: 'arrived');

      await pumpModel3d(tester, at(0), dispatch: sink);
      await pumpModel3d(tester, at(2), dispatch: sink);
      expect(arrivals(sink), isEmpty);
      gate.complete();
      await tester.pumpAndSettle();

      expect(arrivals(sink), [
        {'clip': 'Wave', 'at': 2000},
      ]);
    });

    testWidgets('클립이 바뀌면 새 클립의 목표로 바로 옮긴다', (tester) async {
      final controller = await ready(tester, const {'at': 3000});

      await pumpModel3d(tester, {
        ...props(const {}),
        'progress': {'clip': 'Jump', 'value': 0.5},
      });
      await tester.pump();
      expect(controller.poses.last, (
        'Jump',
        const Duration(milliseconds: 500),
      ));
    });
  });
}
