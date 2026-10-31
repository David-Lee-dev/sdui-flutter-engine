import 'dart:async';

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
  _FakeController({this.fail = false, this.gate});

  final bool fail;

  /// Holds [initialize] open until completed, to observe the loading phase.
  final Completer<void>? gate;
  @override
  final List<String> clips = const ['Idle', 'Jump', 'Wave'];
  final plays = <_Play>[];
  final cameras = <ModelCamera>[];
  final _listeners = <VoidCallback>[];
  bool disposed = false;
  String? _clip;
  int _completions = 0;

  @override
  Future<void> initialize() async {
    await gate?.future;
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
  void setCamera(ModelCamera camera) => cameras.add(camera);

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
  _RecordingModelSource({this.fail = false, this.gate});

  final bool fail;
  final Completer<void>? gate;
  final requests = <ModelRequest>[];
  final controllers = <_FakeController>[];

  @override
  Future<SduiModelController> controllerFor(ModelRequest request) async {
    requests.add(request);
    final controller = _FakeController(fail: fail, gate: gate);
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

double _posterOpacity(WidgetTester tester) =>
    tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

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
        expect(_posterOpacity(tester), 0);
        expect(sink.calls.map((c) => c.$1), ['ready']);
        final play = source.controllers.single.plays.single;
        expect(play.clip, 'Idle');
        expect(play.loop, isTrue);
        expect(play.crossfade, Duration.zero);
      });

      testWidgets('로드 중에도 뷰를 poster 아래에 붙여 두고 제스처는 막는다', (tester) async {
        final gate = Completer<void>();
        ModelSourceRegistry.install(_RecordingModelSource(gate: gate));

        await _pump(tester, const {
          'src': 'char.glb',
          'poster': 'char.png',
          'height': 100,
          'interactive': true,
        });
        await tester.pump();

        expect(find.byKey(const Key('model-view')), findsOneWidget);
        expect(_posterOpacity(tester), 1);
        final ignore = tester.widget<IgnorePointer>(
          find
              .ancestor(
                of: find.byKey(const Key('model-view')),
                matching: find.byType(IgnorePointer),
              )
              .first,
        );
        expect(ignore.ignoring, isTrue);

        gate.complete();
        await tester.pumpAndSettle();
        expect(_posterOpacity(tester), 0);
      });

      testWidgets('렌더러 뷰는 포인터를 받지 않고 요청에는 src만 싣는다', (tester) async {
        final source = _RecordingModelSource();
        ModelSourceRegistry.install(source);

        await _pump(tester, const {
          'src': 'char.glb',
          'height': 100,
          'interactive': true,
        });
        await tester.pumpAndSettle();

        expect(source.requests.single.src, 'char.glb');
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

    group('camera', () {
      ModelCamera last(_RecordingModelSource source) =>
          source.controllers.single.cameras.last;

      Future<_RecordingModelSource> ready(
        WidgetTester tester,
        Map<String, Object?> props, {
        bool settle = true,
      }) async {
        final source = _RecordingModelSource();
        ModelSourceRegistry.install(source);
        await _pump(tester, {
          'src': 'char.glb',
          'width': 200,
          'height': 200,
          ...props,
        });
        if (settle) {
          await tester.pumpAndSettle();
        } else {
          await tester.pump();
        }
        return source;
      }

      final view = find.byKey(const Key('model-view'));

      testWidgets('만들자마자 camera를 보낸다 (없으면 정면, 배율 1)', (tester) async {
        final plain = await ready(tester, const {});
        expect(plain.controllers.single.cameras.first, const ModelCamera());

        await tester.pumpWidget(const SizedBox());
        final framed = await ready(tester, const {
          'camera': {'yaw': 30, 'pitch': 15, 'zoom': 1.2},
        });
        expect(
          framed.controllers.single.cameras.first,
          const ModelCamera(yaw: 30, pitch: 15, zoom: 1.2),
        );
      });

      testWidgets('controls가 없으면 드래그해도 카메라가 그대로다', (tester) async {
        final source = await ready(tester, const {});

        await tester.drag(view, const Offset(100, 50));
        await tester.pumpAndSettle();

        expect(last(source), const ModelCamera());
      });

      testWidgets('horizontal은 가로 드래그로 돌고 세로 드래그는 부모 스크롤로 간다', (tester) async {
        final source = _RecordingModelSource();
        ModelSourceRegistry.install(source);
        final scroll = ScrollController();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: ListView(
              controller: scroll,
              children: [
                Builder(
                  builder: (context) => ModelWidget.build(
                    context,
                    const {
                      'src': 'char.glb',
                      'height': 200,
                      'controls': {'rotate': 'horizontal', 'inertia': false},
                    },
                    const [],
                    null,
                  ),
                ),
                const SizedBox(height: 2000),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.drag(view, const Offset(100, 0));
        await tester.pumpAndSettle();
        final turned = last(source);
        // Dragging right turns the front to the right: the camera moves left.
        expect(turned.yaw, lessThan(-30));
        expect(turned.pitch, 0);

        await tester.drag(view, const Offset(0, -100));
        await tester.pumpAndSettle();
        expect(scroll.offset, greaterThan(0));
        expect(last(source), turned);
      });

      testWidgets('free는 세로 드래그로 기울고 pitch 범위에서 멈춘다', (tester) async {
        final source = await ready(tester, const {
          'controls': {
            'rotate': 'free',
            'pitch': [-10, 20],
            'inertia': false,
          },
        });

        await tester.drag(view, const Offset(0, 30));
        await tester.pumpAndSettle();
        expect(last(source).pitch, greaterThan(0));

        await tester.drag(view, const Offset(0, 400));
        await tester.pumpAndSettle();
        expect(last(source).pitch, 20);

        await tester.drag(view, const Offset(0, -800));
        await tester.pumpAndSettle();
        expect(last(source).pitch, -10);
      });

      testWidgets('interactive: true는 free 회전의 줄임말이다', (tester) async {
        final source = await ready(tester, const {'interactive': true});

        await tester.drag(view, const Offset(60, 60));
        await tester.pumpAndSettle();

        expect(last(source).yaw, lessThan(0));
        expect(last(source).pitch, greaterThan(0));
      });

      testWidgets('return_ms가 있으면 놓은 뒤 camera로 돌아온다', (tester) async {
        final source = await ready(tester, const {
          'camera': {'yaw': 10},
          'controls': {'rotate': 'horizontal', 'return_ms': 300},
        });

        await tester.drag(view, const Offset(100, 0));
        await tester.pump();
        expect(last(source).yaw, lessThan(0));

        await tester.pumpAndSettle();
        expect(last(source).yaw, 10);
      });

      testWidgets('inertia면 던진 뒤에도 잠시 더 돌고, 끄면 바로 멈춘다', (tester) async {
        final coasting = await ready(tester, const {
          'controls': {'rotate': 'horizontal'},
        });
        await tester.fling(view, const Offset(100, 0), 1000);
        await tester.pump();
        final released = last(coasting).yaw;
        await tester.pumpAndSettle();
        expect(last(coasting).yaw, lessThan(released));

        await tester.pumpWidget(const SizedBox());
        final stopped = await ready(tester, const {
          'controls': {'rotate': 'horizontal', 'inertia': false},
        });
        await tester.fling(view, const Offset(100, 0), 1000);
        await tester.pump();
        final atRelease = last(stopped).yaw;
        await tester.pumpAndSettle();
        expect(last(stopped).yaw, atRelease);
      });

      testWidgets('zoom 범위 안에서 핀치로 확대한다', (tester) async {
        final source = await ready(tester, const {
          'controls': {
            'rotate': 'free',
            'zoom': [0.5, 2],
            'inertia': false,
          },
        });
        final center = tester.getCenter(view);

        final a = await tester.startGesture(center - const Offset(20, 0));
        final b = await tester.startGesture(
          center + const Offset(20, 0),
          pointer: 2,
        );
        await tester.pump();
        await a.moveBy(const Offset(-40, 0));
        await b.moveBy(const Offset(40, 0));
        await tester.pump();
        await a.moveBy(const Offset(-200, 0));
        await b.moveBy(const Offset(200, 0));
        await tester.pump();
        await a.up();
        await b.up();
        await tester.pumpAndSettle();

        expect(last(source).zoom, 2);
      });

      testWidgets('auto_rotate는 초당 그 각도만큼 돈다 (true는 30)', (tester) async {
        // A running auto-rotation never settles.
        final source = await ready(tester, const {
          'auto_rotate': 90,
        }, settle: false);
        await tester.pump(const Duration(milliseconds: 100));
        final start = last(source).yaw;

        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(last(source).yaw - start, closeTo(90, 2));
        await tester.pumpWidget(const SizedBox());

        final flagged = await ready(tester, const {
          'auto_rotate': true,
        }, settle: false);
        await tester.pump(const Duration(milliseconds: 100));
        final from = last(flagged).yaw;
        await tester.pump(const Duration(seconds: 1));
        expect(last(flagged).yaw - from, closeTo(30, 2));
        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('camera가 바뀌면 duration_ms 동안 옮겨 간다', (tester) async {
        final source = await ready(tester, const {
          'camera': {'yaw': 0, 'duration_ms': 400},
        });

        await _pump(tester, const {
          'src': 'char.glb',
          'width': 200,
          'height': 200,
          'camera': {'yaw': 90, 'duration_ms': 400},
        });
        await tester.pump(const Duration(milliseconds: 200));
        final halfway = last(source).yaw;
        expect(halfway, greaterThan(0));
        expect(halfway, lessThan(90));

        await tester.pumpAndSettle();
        expect(last(source).yaw, 90);
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
