import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/image_source.dart';
import 'package:sdui_engine/src/contract/model_source.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';
import 'package:sdui_engine/src/runtime/media/model_source_registry.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/model_widget.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';

import '../../../../support/engine_harness.dart';

final class _Play {
  const _Play(this.clip, this.loop, this.crossfade);

  final String clip;
  final bool loop;
  final Duration crossfade;
}

final class _FakeController implements SduiModelController {
  _FakeController({this.fail = false});

  final bool fail;
  @override
  final List<String> clips = const ['Idle', 'Jump', 'Wave'];
  final plays = <_Play>[];
  final _listeners = <VoidCallback>[];
  bool disposed = false;
  String? _clip;
  int _completions = 0;

  @override
  Future<void> initialize() async {
    if (fail) throw StateError('load failed');
  }

  @override
  Future<void> play(
    String clip, {
    required bool loop,
    Duration crossfade = Duration.zero,
  }) async {
    plays.add(_Play(clip, loop, crossfade));
    _clip = clip;
  }

  /// Simulates the renderer reporting the end of a non-looping clip.
  void finish() {
    _completions++;
    for (final listener in [..._listeners]) {
      listener();
    }
  }

  @override
  Future<void> stop() async {}

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  @override
  ModelPlayback get playback =>
      ModelPlayback(clip: _clip, isPlaying: true, completions: _completions);

  @override
  Widget buildView() => const SizedBox.expand(key: Key('model-view'));

  @override
  Future<void> dispose() async => disposed = true;
}

final class _RecordingModelSource extends ModelSource {
  _RecordingModelSource({this.fail = false});

  final bool fail;
  final requests = <ModelRequest>[];
  final controllers = <_FakeController>[];

  @override
  Future<SduiModelController> controllerFor(ModelRequest request) async {
    requests.add(request);
    final controller = _FakeController(fail: fail);
    controllers.add(controller);
    return controller;
  }
}

final class _TextImageSource implements ImageSource {
  const _TextImageSource();

  @override
  ImageResult resolve(ImageRequest request) =>
      ReadyImage(Text('poster:${request.src}'));
}

final class _Sink implements ActionSink {
  final calls = <(String, Object?)>[];

  @override
  void handle(String action, {Object? event, ActionInvocation? invocation}) {
    calls.add((action, event));
  }

  @override
  Future<void> handleAwaitable(
    String action, {
    Object? event,
    ActionInvocation? invocation,
  }) async => handle(action, event: event);
}

const _states = {
  'idle': {'clip': 'Idle', 'loop': true},
  'jump': {'clip': 'Jump', 'next': 'idle'},
  'wave': {'clip': 'Wave'},
  'dance': {'clip': 'Dance'},
};

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  ActionSink? dispatch,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: Builder(
          builder: (context) =>
              ModelWidget.build(context, props, const [], dispatch),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('ModelWidget', () {
    setUp(() {
      ModelSourceRegistry.reset();
      ImageSourceRegistry.reset();
      ImageSourceRegistry.install(const _TextImageSource());
    });
    tearDown(() {
      ModelSourceRegistry.reset();
      ImageSourceRegistry.reset();
    });

    group('build', () {
      testWidgets('src와 poster가 모두 없으면 빈 박스를 그린다', (tester) async {
        await _pump(tester, const {});

        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byKey(const Key('model-view')), findsNothing);
      });

      testWidgets('렌더러가 없으면 poster만 그린다', (tester) async {
        await _pump(tester, const {
          'src': 'char.glb',
          'poster': 'char.png',
          'width': 100,
          'height': 100,
        });

        expect(find.text('poster:char.png'), findsOneWidget);
        expect(find.byKey(const Key('model-view')), findsNothing);
      });

      testWidgets('로드가 끝나면 모델로 바꾸고 on_ready를 보내며 첫 클립은 crossfade 없이 튼다', (
        tester,
      ) async {
        final source = _RecordingModelSource();
        ModelSourceRegistry.install(source);
        final sink = _Sink();

        await _pump(tester, const {
          'src': 'char.glb',
          'poster': 'char.png',
          'height': 100,
          'state': 'idle',
          'states': _states,
          'on_ready': 'ready',
        }, dispatch: sink);
        await tester.pumpAndSettle();

        expect(source.requests.single.src, 'char.glb');
        expect(find.byKey(const Key('model-view')), findsOneWidget);
        expect(find.text('poster:char.png'), findsNothing);
        expect(sink.calls.map((c) => c.$1), ['ready']);
        final play = source.controllers.single.plays.single;
        expect(play.clip, 'Idle');
        expect(play.loop, isTrue);
        expect(play.crossfade, Duration.zero);
      });

      testWidgets('interactive가 false면 모델 뷰의 제스처를 부모로 넘긴다', (tester) async {
        ModelSourceRegistry.install(_RecordingModelSource());

        await _pump(tester, const {'src': 'char.glb', 'height': 100});
        await tester.pumpAndSettle();

        final ignore = tester.widget<IgnorePointer>(
          find
              .ancestor(
                of: find.byKey(const Key('model-view')),
                matching: find.byType(IgnorePointer),
              )
              .first,
        );
        expect(ignore.ignoring, isTrue);
      });

      testWidgets('interactive와 auto_rotate를 요청에 실어 보낸다', (tester) async {
        final source = _RecordingModelSource();
        ModelSourceRegistry.install(source);

        await _pump(tester, const {
          'src': 'char.glb',
          'height': 100,
          'interactive': true,
          'auto_rotate': true,
        });
        await tester.pumpAndSettle();

        expect(source.requests.single.interactive, isTrue);
        expect(source.requests.single.autoRotate, isTrue);
        final ignore = tester.widget<IgnorePointer>(
          find
              .ancestor(
                of: find.byKey(const Key('model-view')),
                matching: find.byType(IgnorePointer),
              )
              .first,
        );
        expect(ignore.ignoring, isFalse);
      });
    });

    group('states', () {
      testWidgets('state가 바뀌면 그 클립을 crossfade_ms로 섞어 튼다', (tester) async {
        final source = _RecordingModelSource();
        ModelSourceRegistry.install(source);
        const base = {
          'src': 'char.glb',
          'height': 100,
          'states': _states,
          'crossfade_ms': 300,
        };

        await _pump(tester, {...base, 'state': 'idle'});
        await tester.pumpAndSettle();
        await _pump(tester, {...base, 'state': 'wave'});

        final plays = source.controllers.single.plays;
        expect(plays.map((p) => p.clip), ['Idle', 'Wave']);
        expect(plays.last.loop, isFalse);
        expect(plays.last.crossfade, const Duration(milliseconds: 300));
      });

      testWidgets('한 번 재생 클립이 끝나면 on_state_end를 보내고 next 상태로 넘어간다', (
        tester,
      ) async {
        final source = _RecordingModelSource();
        ModelSourceRegistry.install(source);
        final sink = _Sink();

        await _pump(tester, const {
          'src': 'char.glb',
          'height': 100,
          'state': 'jump',
          'states': _states,
          'on_state_end': {'jump': 'landed'},
        }, dispatch: sink);
        await tester.pumpAndSettle();
        final controller = source.controllers.single;
        expect(controller.plays.map((p) => p.clip), ['Jump']);

        controller.finish();
        await tester.pump();

        expect(sink.calls.single.$1, 'landed');
        expect(sink.calls.single.$2, {'state': 'jump'});
        expect(controller.plays.map((p) => p.clip), ['Jump', 'Idle']);
      });

      testWidgets('반복 클립은 끝 신호가 와도 on_state_end를 보내지 않는다', (tester) async {
        final source = _RecordingModelSource();
        ModelSourceRegistry.install(source);
        final sink = _Sink();

        await _pump(tester, const {
          'src': 'char.glb',
          'height': 100,
          'state': 'idle',
          'states': _states,
          'on_state_end': {'idle': 'never'},
        }, dispatch: sink);
        await tester.pumpAndSettle();
        source.controllers.single.finish();
        await tester.pump();

        expect(sink.calls, isEmpty);
      });

      testWidgets('state_key가 바뀌면 같은 state를 다시 재생한다', (tester) async {
        final source = _RecordingModelSource();
        ModelSourceRegistry.install(source);
        const base = {
          'src': 'char.glb',
          'height': 100,
          'state': 'wave',
          'states': _states,
        };

        await _pump(tester, {...base, 'state_key': 1});
        await tester.pumpAndSettle();
        await _pump(tester, {...base, 'state_key': 1});
        await _pump(tester, {...base, 'state_key': 2});

        expect(source.controllers.single.plays.map((p) => p.clip), [
          'Wave',
          'Wave',
        ]);
      });

      testWidgets('로드 중에 받은 state는 준비된 뒤에 재생한다', (tester) async {
        final source = _RecordingModelSource();
        ModelSourceRegistry.install(source);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) => ModelWidget.build(
                context,
                const {
                  'src': 'char.glb',
                  'height': 100,
                  'state': 'wave',
                  'states': _states,
                },
                const [],
                null,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(source.controllers.single.plays.map((p) => p.clip), ['Wave']);
      });
    });

    group('fallback', () {
      testWidgets('렌더러가 없으면 한 번 재생 state를 바로 끝내 흐름을 이어 간다', (tester) async {
        final sink = _Sink();

        await _pump(tester, const {
          'poster': 'char.png',
          'height': 100,
          'state': 'jump',
          'states': _states,
          'on_state_end': {'jump': 'landed'},
        }, dispatch: sink);
        await tester.pump();

        expect(sink.calls.map((c) => c.$1), ['landed']);
        expect(find.text('poster:char.png'), findsOneWidget);
      });

      testWidgets('로드에 실패하면 on_error를 보내고 poster를 유지하며 state를 끝낸다', (
        tester,
      ) async {
        final source = _RecordingModelSource(fail: true);
        ModelSourceRegistry.install(source);
        final sink = _Sink();

        await _pump(tester, const {
          'src': 'char.glb',
          'poster': 'char.png',
          'height': 100,
          'state': 'jump',
          'states': _states,
          'on_error': 'failed',
          'on_state_end': {'jump': 'landed'},
        }, dispatch: sink);
        await tester.pumpAndSettle();

        expect(sink.calls.map((c) => c.$1), ['failed', 'landed']);
        expect(find.text('poster:char.png'), findsOneWidget);
        expect(find.byKey(const Key('model-view')), findsNothing);
        expect(source.controllers.single.disposed, isTrue);
      });

      testWidgets('모델에 없는 클립이면 재생하지 않고 state를 끝낸다', (tester) async {
        final source = _RecordingModelSource();
        ModelSourceRegistry.install(source);
        final sink = _Sink();

        await _pump(tester, const {
          'src': 'char.glb',
          'height': 100,
          'state': 'dance',
          'states': _states,
          'on_state_end': {'dance': 'danced'},
        }, dispatch: sink);
        await tester.pumpAndSettle();

        expect(source.controllers.single.clips, isNot(contains('Dance')));
        expect(source.controllers.single.plays, isEmpty);
        expect(sink.calls.map((c) => c.$1), ['danced']);
      });
    });

    group('lifecycle', () {
      testWidgets('src가 바뀌면 이전 컨트롤러를 버리고 새로 만든다', (tester) async {
        final source = _RecordingModelSource();
        ModelSourceRegistry.install(source);

        await _pump(tester, const {'src': 'a.glb', 'height': 100});
        await tester.pumpAndSettle();
        await _pump(tester, const {'src': 'b.glb', 'height': 100});
        await tester.pumpAndSettle();

        expect(source.requests.map((r) => r.src), ['a.glb', 'b.glb']);
        expect(source.controllers.first.disposed, isTrue);
        expect(source.controllers.last.disposed, isFalse);
      });

      testWidgets('위젯이 사라지면 컨트롤러를 버린다', (tester) async {
        final source = _RecordingModelSource();
        ModelSourceRegistry.install(source);

        await _pump(tester, const {'src': 'a.glb', 'height': 100});
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox());

        expect(source.controllers.single.disposed, isTrue);
      });
    });

    group('template', () {
      testWidgets(
        '탭 → set → state_key 변화로 같은 state를 다시 재생하고 끝나면 액션이 state를 되돌린다',
        (tester) async {
          final source = _RecordingModelSource();
          ModelSourceRegistry.install(source);

          await pumpEngineTemplate(tester, {
            '_type': 'model',
            'src': 'char.glb',
            'height': 100,
            'state': r'${mood}',
            'state_key': r'${taps}',
            'states': _states,
            'on_state_end': {'jump': 'landed'},
            '_scope': {
              '_state': {'mood': 'idle', 'taps': 0},
              '_action': {
                'hop': {'_type': 'set', 'mood': 'jump', 'taps': r'${taps + 1}'},
                'landed': {'_type': 'set', 'mood': 'idle'},
              },
            },
            '_on': {
              'tap': {'do': 'hop', 'ripple': false},
            },
          });
          await tester.pumpAndSettle();
          final controller = source.controllers.single;
          expect(controller.plays.map((p) => p.clip), ['Idle']);

          await tester.tap(find.byKey(const Key('model-view')));
          await tester.pumpAndSettle();
          expect(controller.plays.map((p) => p.clip), ['Idle', 'Jump']);

          await tester.tap(find.byKey(const Key('model-view')));
          await tester.pumpAndSettle();
          expect(controller.plays.map((p) => p.clip), ['Idle', 'Jump', 'Jump']);

          controller.finish();
          await tester.pumpAndSettle();
          expect(controller.plays.map((p) => p.clip), [
            'Idle',
            'Jump',
            'Jump',
            'Idle',
          ]);
        },
      );
    });
  });
}
