import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/video_source.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/shared_element_widget.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/video_widget.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';
import 'package:sdui_engine/src/runtime/media/video_source_registry.dart';

/// Pure fake — the contract no longer forces a plugin type into tests.
final class _FakeController implements SduiVideoController {
  _FakeController({this.fail = false});

  final bool fail;
  bool? looping;
  double? volume;
  int playCalls = 0;
  bool _playing = false;

  @override
  Future<void> initialize() async {
    if (fail) throw StateError('init failed');
  }

  @override
  Future<void> setLooping(bool looping) async => this.looping = looping;

  @override
  Future<void> setVolume(double volume) async => this.volume = volume;

  @override
  Future<void> play() async {
    playCalls++;
    _playing = true;
  }

  @override
  Future<void> pause() async => _playing = false;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  VideoPlayback get playback => VideoPlayback(
    width: 320,
    height: 180,
    duration: const Duration(seconds: 2),
    position: Duration.zero,
    isPlaying: _playing,
  );

  @override
  Widget buildView() => const SizedBox.expand();

  @override
  Future<void> dispose() async {}
}

final class _RecordingVideoSource implements VideoSource {
  _RecordingVideoSource({this.fail = false});

  final bool fail;
  final requests = <VideoRequest>[];
  final controllers = <_FakeController>[];

  @override
  Future<SduiVideoController> controllerFor(VideoRequest request) async {
    requests.add(request);
    final controller = _FakeController(fail: fail);
    controllers.add(controller);
    return controller;
  }
}

final class _Sink implements ActionSink {
  final calls = <String>[];

  @override
  void handle(String actionId, {Object? event, ActionInvocation? invocation}) {
    calls.add(actionId);
  }

  @override
  Future<void> handleAwaitable(
    String actionId, {
    Object? event,
    ActionInvocation? invocation,
  }) async {
    handle(actionId);
  }
}

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  ActionSink? dispatch,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Builder(
        builder: (context) =>
            VideoWidget.build(context, props, const [], dispatch),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('VideoWidget', () {
    group('build', () {
      late _RecordingVideoSource source;

      setUp(() {
        VideoSourceRegistry.reset();
        source = _RecordingVideoSource();
        VideoSourceRegistry.install(source);
      });
      tearDown(VideoSourceRegistry.reset);

      testWidgets('untagged same-src videos both autoplay independently', (
        tester,
      ) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: List.generate(
                2,
                (_) => Expanded(
                  child: Builder(
                    builder: (context) => VideoWidget.build(
                      context,
                      const {'src': 'clip.mp4', 'autoplay': true},
                      const [],
                      null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(source.requests.map((r) => r.src), ['clip.mp4', 'clip.mp4']);
        expect(source.controllers, hasLength(2));
        expect(source.controllers[0], isNot(same(source.controllers[1])));
        expect(source.controllers.map((c) => c.playCalls), everyElement(1));
        expect(
          source.controllers.map((c) => c.playback.isPlaying),
          everyElement(isTrue),
        );
        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('src를 VideoSource 요청으로 전달한다', (tester) async {
        await _pump(tester, const {'src': 'clip.mp4'});

        expect(source.requests.single.src, 'clip.mp4');
      });

      testWidgets('재생 props 기본값을 적용한다', (tester) async {
        await _pump(tester, const {'src': 'clip.mp4'});

        final controller = source.controllers.single;
        expect(controller.looping, isTrue);
        expect(controller.volume, 1);
        expect(controller.playCalls, 1);
      });

      testWidgets('잘못된 prop 타입은 기본값으로 안전하게 해석한다', (tester) async {
        await _pump(tester, const {
          'src': 'clip.mp4',
          'loop': 'false',
          'muted': 1,
          'autoplay': 'false',
        });

        final controller = source.controllers.single;
        expect(controller.looping, isTrue);
        expect(controller.volume, 1);
        expect(controller.playCalls, 1);
      });

      testWidgets('빈 src는 source를 호출하지 않는다', (tester) async {
        await _pump(tester, const {'src': ''});

        expect(source.requests, isEmpty);
        expect(find.byType(SizedBox), findsOneWidget);
      });
    });

    group('on_ready / on_error', () {
      late _RecordingVideoSource source;

      setUp(() {
        VideoSourceRegistry.reset();
        source = _RecordingVideoSource();
        VideoSourceRegistry.install(source);
      });
      tearDown(VideoSourceRegistry.reset);

      testWidgets('A. initialize 성공 후 on_ready를 한 번만 디스패치한다', (tester) async {
        final sink = _Sink();
        await _pump(tester, const {
          'src': 'clip.mp4',
          'on_ready': 'ready',
        }, dispatch: sink);

        expect(sink.calls, ['ready']);
      });

      testWidgets('B. 같은 props로 재빌드해도 다시 디스패치하지 않는다', (tester) async {
        final sink = _Sink();
        await _pump(tester, const {
          'src': 'clip.mp4',
          'on_ready': 'ready',
        }, dispatch: sink);
        await _pump(tester, const {
          'src': 'clip.mp4',
          'on_ready': 'ready',
        }, dispatch: sink);

        expect(sink.calls, ['ready']);
      });

      testWidgets('C. src가 바뀌면 새 소스에 대해 다시 디스패치한다', (tester) async {
        final sink = _Sink();
        await _pump(tester, const {
          'src': 'clip.mp4',
          'on_ready': 'ready',
        }, dispatch: sink);
        await _pump(tester, const {
          'src': 'other.mp4',
          'on_ready': 'ready',
        }, dispatch: sink);

        expect(sink.calls, ['ready', 'ready']);
        expect(source.requests.map((r) => r.src), ['clip.mp4', 'other.mp4']);
      });

      testWidgets(
        'D. initialize가 실패하면 on_error를 한 번만 디스패치하고 on_ready는 디스패치하지 않는다',
        (tester) async {
          VideoSourceRegistry.reset();
          source = _RecordingVideoSource(fail: true);
          VideoSourceRegistry.install(source);
          final sink = _Sink();
          await _pump(tester, const {
            'src': 'clip.mp4',
            'on_ready': 'ready',
            'on_error': 'err',
          }, dispatch: sink);

          expect(sink.calls, ['err']);
        },
      );

      testWidgets('E. SharedVideoScope 경로에서도 on_ready/on_error를 한 번씩 디스패치한다', (
        tester,
      ) async {
        final readySink = _Sink();
        await tester.pumpWidget(
          MaterialApp(
            home: SharedElement(
              tag: 'shared-video',
              child: Builder(
                builder: (context) => VideoWidget.build(
                  context,
                  const {'src': 'clip.mp4', 'on_ready': 'ready'},
                  const [],
                  readySink,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(readySink.calls, ['ready']);

        VideoSourceRegistry.reset();
        source = _RecordingVideoSource(fail: true);
        VideoSourceRegistry.install(source);
        final errorSink = _Sink();
        await tester.pumpWidget(
          MaterialApp(
            home: SharedElement(
              tag: 'shared-video-error',
              child: Builder(
                builder: (context) => VideoWidget.build(
                  context,
                  const {
                    'src': 'clip.mp4',
                    'on_ready': 'ready',
                    'on_error': 'err',
                  },
                  const [],
                  errorSink,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(errorSink.calls, ['err']);
      });

      testWidgets('F. props가 없으면 디스패치도 없고 에러도 없다', (tester) async {
        final sink = _Sink();
        await _pump(tester, const {'src': 'clip.mp4'}, dispatch: sink);

        expect(sink.calls, isEmpty);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
