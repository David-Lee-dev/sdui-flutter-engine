import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';
import 'package:sdui_engine/src/runtime/media/model_3d_source_registry.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/model_3d/model_3d_widget.dart';

import '../../../../support/engine_harness.dart';

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

  group('Model3dWidget', () {
    group('build', () {
      testWidgets('src와 poster가 모두 없으면 빈 박스를 그린다', (tester) async {
        await pumpModel3d(tester, const {});

        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byKey(const Key('model-view')), findsNothing);
      });

      testWidgets('렌더러가 없으면 poster만 그린다', (tester) async {
        await pumpModel3d(tester, const {
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
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        final sink = Model3dSink();

        await pumpModel3d(tester, const {
          'src': 'char.glb',
          'poster': 'char.png',
          'height': 100,
          'state': 'idle',
          'states': model3dStates,
          'on_ready': 'ready',
        }, dispatch: sink);
        await tester.pumpAndSettle();

        expect(source.requests.single.src, 'char.glb');
        expect(find.byKey(const Key('model-view')), findsOneWidget);
        expect(model3dPosterOpacity(tester), 0);
        expect(sink.calls.map((c) => c.$1), ['ready']);
        final play = source.controllers.single.plays.single;
        expect(play.clip, 'Idle');
        expect(play.loop, isTrue);
        expect(play.crossfade, Duration.zero);
      });

      testWidgets('로드 중에도 뷰를 poster 아래에 붙여 두고 제스처는 막는다', (tester) async {
        final gate = Completer<void>();
        Model3dSourceRegistry.install(RecordingModel3dSource(gate: gate));

        await pumpModel3d(tester, const {
          'src': 'char.glb',
          'poster': 'char.png',
          'height': 100,
          'interactive': true,
        });
        await tester.pump();

        expect(find.byKey(const Key('model-view')), findsOneWidget);
        expect(model3dPosterOpacity(tester), 1);
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
        expect(model3dPosterOpacity(tester), 0);
      });

      testWidgets('렌더러 뷰는 포인터를 받지 않고 요청에는 src만 싣는다', (tester) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);

        await pumpModel3d(tester, const {
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
      testWidgets('state가 바뀌면 그 클립을 crossfade_duration으로 섞어 튼다', (
        tester,
      ) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        const base = {
          'src': 'char.glb',
          'height': 100,
          'states': model3dStates,
          'crossfade_duration': 300,
        };

        await pumpModel3d(tester, {...base, 'state': 'idle'});
        await tester.pumpAndSettle();
        await pumpModel3d(tester, {...base, 'state': 'wave'});

        final plays = source.controllers.single.plays;
        expect(plays.map((p) => p.clip), ['Idle', 'Wave']);
        expect(plays.last.loop, isFalse);
        expect(plays.last.crossfade, const Duration(milliseconds: 300));
      });

      testWidgets('한 번 재생 클립이 끝나면 on_state_end를 보내고 next 상태로 넘어간다', (
        tester,
      ) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        final sink = Model3dSink();

        await pumpModel3d(tester, const {
          'src': 'char.glb',
          'height': 100,
          'state': 'jump',
          'states': model3dStates,
          'on_state_end': 'landed',
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
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        final sink = Model3dSink();

        await pumpModel3d(tester, const {
          'src': 'char.glb',
          'height': 100,
          'state': 'idle',
          'states': model3dStates,
          'on_state_end': 'never',
        }, dispatch: sink);
        await tester.pumpAndSettle();
        source.controllers.single.finish();
        await tester.pump();

        expect(sink.calls, isEmpty);
      });

      testWidgets('state_trigger가 바뀌면 같은 state를 다시 재생한다', (tester) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        const base = {
          'src': 'char.glb',
          'height': 100,
          'state': 'wave',
          'states': model3dStates,
        };

        await pumpModel3d(tester, {...base, 'state_trigger': 1});
        await tester.pumpAndSettle();
        await pumpModel3d(tester, {...base, 'state_trigger': 1});
        await pumpModel3d(tester, {...base, 'state_trigger': 2});

        expect(source.controllers.single.plays.map((p) => p.clip), [
          'Wave',
          'Wave',
        ]);
      });

      testWidgets('로드 중에 받은 state는 준비된 뒤에 재생한다', (tester) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) => Model3dWidget.build(
                context,
                const {
                  'src': 'char.glb',
                  'height': 100,
                  'state': 'wave',
                  'states': model3dStates,
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
        final sink = Model3dSink();

        await pumpModel3d(tester, const {
          'poster': 'char.png',
          'height': 100,
          'state': 'jump',
          'states': model3dStates,
          'on_state_end': 'landed',
        }, dispatch: sink);
        await tester.pump();

        expect(sink.calls.map((c) => c.$1), ['landed']);
        expect(find.text('poster:char.png'), findsOneWidget);
      });

      testWidgets('로드에 실패하면 on_error를 보내고 poster를 유지하며 state를 끝낸다', (
        tester,
      ) async {
        final source = RecordingModel3dSource(fail: true);
        Model3dSourceRegistry.install(source);
        final sink = Model3dSink();

        await pumpModel3d(tester, const {
          'src': 'char.glb',
          'poster': 'char.png',
          'height': 100,
          'state': 'jump',
          'states': model3dStates,
          'on_error': 'failed',
          'on_state_end': 'landed',
        }, dispatch: sink);
        await tester.pumpAndSettle();

        expect(sink.calls.map((c) => c.$1), ['failed', 'landed']);
        expect(find.text('poster:char.png'), findsOneWidget);
        expect(find.byKey(const Key('model-view')), findsNothing);
        expect(source.controllers.single.disposed, isTrue);
      });

      testWidgets('재생에 실패하면 한 번 재생 state를 끝내 흐름을 이어 간다', (tester) async {
        final source = RecordingModel3dSource(failPlay: true);
        Model3dSourceRegistry.install(source);
        final sink = Model3dSink();

        await pumpModel3d(tester, const {
          'src': 'char.glb',
          'height': 100,
          'state': 'jump',
          'states': model3dStates,
          'on_state_end': 'landed',
        }, dispatch: sink);
        await tester.pumpAndSettle();

        expect(sink.calls.map((c) => c.$1), ['landed']);
        expect(source.controllers.single.plays.map((p) => p.clip), [
          'Jump',
          'Idle',
        ]);
      });

      testWidgets('모델에 없는 클립이면 재생하지 않고 state를 끝낸다', (tester) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        final sink = Model3dSink();

        await pumpModel3d(tester, const {
          'src': 'char.glb',
          'height': 100,
          'state': 'dance',
          'states': model3dStates,
          'on_state_end': 'danced',
        }, dispatch: sink);
        await tester.pumpAndSettle();

        expect(source.controllers.single.clips, isNot(contains('Dance')));
        expect(source.controllers.single.plays, isEmpty);
        expect(sink.calls.map((c) => c.$1), ['danced']);
      });

      group('재생 없이 끝나는 next 순환', () {
        /// The states each `on_state_end` reported.
        List<Object?> ended(Model3dSink sink) => [
          for (final (action, event) in sink.calls)
            if (action == 'ended') (event! as Map)['state'],
        ];

        Map<String, Object?> cycle(String a, String b) => {
          'src': 'char.glb',
          'height': 100,
          'state': 'a',
          'states': {
            'a': {'clip': a, 'next': 'b'},
            'b': {'clip': b, 'next': 'a'},
          },
          'on_state_end': 'ended',
        };

        testWidgets('렌더러가 없으면 한 바퀴 돌고 멈춘다', (tester) async {
          final sink = Model3dSink();

          await pumpModel3d(tester, cycle('Jump', 'Wave'), dispatch: sink);
          await tester.pumpAndSettle();

          expect(ended(sink), ['a', 'b']);
        });

        testWidgets('로드에 실패하면 한 바퀴 돌고 멈춘다', (tester) async {
          Model3dSourceRegistry.install(RecordingModel3dSource(fail: true));
          final sink = Model3dSink();

          await pumpModel3d(tester, cycle('Jump', 'Wave'), dispatch: sink);
          await tester.pumpAndSettle();

          expect(ended(sink), ['a', 'b']);
        });

        testWidgets('모델에 클립이 없으면 한 바퀴 돌고 멈춘다', (tester) async {
          final source = RecordingModel3dSource();
          Model3dSourceRegistry.install(source);
          final sink = Model3dSink();

          await pumpModel3d(tester, cycle('Dance', 'Spin'), dispatch: sink);
          await tester.pumpAndSettle();

          expect(ended(sink), ['a', 'b']);
          expect(source.controllers.single.plays, isEmpty);
        });

        testWidgets('재생에 실패하면 한 바퀴 돌고 멈춘다', (tester) async {
          final source = RecordingModel3dSource(failPlay: true);
          Model3dSourceRegistry.install(source);
          final sink = Model3dSink();

          await pumpModel3d(tester, cycle('Jump', 'Wave'), dispatch: sink);
          await tester.pumpAndSettle();

          expect(ended(sink), ['a', 'b']);
          expect(source.controllers.single.plays.map((p) => p.clip), [
            'Jump',
            'Wave',
          ]);
        });

        testWidgets('재생되는 클립이 끼어 있으면 순환을 막지 않는다', (tester) async {
          final source = RecordingModel3dSource();
          Model3dSourceRegistry.install(source);
          final sink = Model3dSink();

          await pumpModel3d(tester, cycle('Dance', 'Jump'), dispatch: sink);
          await tester.pumpAndSettle();
          final controller = source.controllers.single;
          controller.finish();
          await tester.pumpAndSettle();
          controller.finish();
          await tester.pumpAndSettle();

          expect(ended(sink), ['a', 'b', 'a', 'b', 'a']);
          expect(controller.plays.map((p) => p.clip), ['Jump', 'Jump', 'Jump']);
        });
      });
    });

    group('retry', () {
      const idle = {
        'src': 'char.glb',
        'poster': 'char.png',
        'height': 100,
        'state': 'idle',
        'states': model3dStates,
      };

      testWidgets('실패한 모델은 다시 보일 때 새 컨트롤러로 다시 불러온다', (tester) async {
        final source = RecordingModel3dSource(fail: true);
        Model3dSourceRegistry.install(source);
        final sink = Model3dSink();
        final props = {...idle, 'on_ready': 'ready', 'on_error': 'failed'};

        await pumpModel3d(tester, props, dispatch: sink);
        await tester.pumpAndSettle();
        source.fail = false;
        await pumpModel3d(tester, props, dispatch: sink, shown: false);
        expect(source.controllers, hasLength(1));

        await pumpModel3d(tester, props, dispatch: sink);
        await tester.pumpAndSettle();

        expect(source.controllers, hasLength(2));
        expect(source.controllers.first.disposed, isTrue);
        expect(source.controllers.last.plays.map((p) => p.clip), ['Idle']);
        expect(model3dPosterOpacity(tester), 0);
        expect(sink.calls.map((c) => c.$1), ['failed', 'ready']);
      });

      testWidgets('실패한 모델은 앱이 돌아올 때 다시 불러온다', (tester) async {
        final source = RecordingModel3dSource(fail: true);
        Model3dSourceRegistry.install(source);

        await pumpModel3d(tester, idle);
        await tester.pumpAndSettle();
        source.fail = false;
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        await tester.pump();
        expect(source.controllers, hasLength(1));

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        expect(source.controllers, hasLength(2));
        expect(source.controllers.last.plays.map((p) => p.clip), ['Idle']);
      });

      testWidgets('가려진 동안 앱이 돌아오면 보일 때까지 기다린다', (tester) async {
        final source = RecordingModel3dSource(fail: true);
        Model3dSourceRegistry.install(source);

        await pumpModel3d(tester, idle, shown: false);
        await tester.pumpAndSettle();
        source.fail = false;
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        expect(source.controllers, hasLength(1));

        await pumpModel3d(tester, idle);
        await tester.pumpAndSettle();
        expect(source.controllers, hasLength(2));
      });

      testWidgets('불러온 모델은 다시 보이거나 앱이 돌아와도 다시 불러오지 않는다', (tester) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);

        await pumpModel3d(tester, idle);
        await tester.pumpAndSettle();
        await pumpModel3d(tester, idle, shown: false);
        await pumpModel3d(tester, idle);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        expect(source.controllers, hasLength(1));
      });
    });

    group('visibility', () {
      const idle = {
        'src': 'char.glb',
        'height': 100,
        'state': 'idle',
        'states': model3dStates,
      };

      testWidgets('가려지면 반복 클립을 멈추고 다시 보이면 다시 튼다', (tester) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);

        await pumpModel3d(tester, idle);
        await tester.pumpAndSettle();
        final controller = source.controllers.single;
        expect(controller.plays.map((p) => p.clip), ['Idle']);

        await pumpModel3d(tester, idle, shown: false);
        expect(controller.stops, 1);
        await pumpModel3d(tester, idle, shown: false);
        expect(controller.stops, 1);

        await pumpModel3d(tester, idle);
        expect(controller.plays.map((p) => p.clip), ['Idle', 'Idle']);
      });

      testWidgets('가려진 동안 들어온 반복 state는 보일 때 튼다', (tester) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        final wave = {...idle, 'state': 'wave'};

        await pumpModel3d(tester, wave);
        await tester.pumpAndSettle();
        await pumpModel3d(tester, idle, shown: false);
        final controller = source.controllers.single;
        expect(controller.plays.map((p) => p.clip), ['Wave']);

        await pumpModel3d(tester, idle);
        expect(controller.plays.map((p) => p.clip), ['Wave', 'Idle']);
      });

      testWidgets('한 번 재생 클립은 가려져도 끝까지 두고 끝나면 흐름을 잇는다', (tester) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        final sink = Model3dSink();
        final wave = {...idle, 'state': 'wave', 'on_state_end': 'waved'};

        await pumpModel3d(tester, wave, dispatch: sink);
        await tester.pumpAndSettle();
        await pumpModel3d(tester, wave, dispatch: sink, shown: false);
        final controller = source.controllers.single;
        expect(controller.stops, 0);

        controller.finish();
        await tester.pump();
        expect(sink.calls.map((c) => c.$1), ['waved']);
      });
    });

    group('lifecycle', () {
      testWidgets('src가 바뀌면 이전 컨트롤러를 버리고 새로 만든다', (tester) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);

        await pumpModel3d(tester, const {'src': 'a.glb', 'height': 100});
        await tester.pumpAndSettle();
        await pumpModel3d(tester, const {'src': 'b.glb', 'height': 100});
        await tester.pumpAndSettle();

        expect(source.requests.map((r) => r.src), ['a.glb', 'b.glb']);
        expect(source.controllers.first.disposed, isTrue);
        expect(source.controllers.last.disposed, isFalse);
      });

      testWidgets('위젯이 사라지면 컨트롤러를 버린다', (tester) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);

        await pumpModel3d(tester, const {'src': 'a.glb', 'height': 100});
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox());

        expect(source.controllers.single.disposed, isTrue);
      });
    });

    group('template', () {
      testWidgets(
        '탭 → set → state_trigger 변화로 같은 state를 다시 재생하고 끝나면 액션이 state를 되돌린다',
        (tester) async {
          final source = RecordingModel3dSource();
          Model3dSourceRegistry.install(source);

          await pumpEngineTemplate(tester, {
            '_type': 'model_3d',
            'src': 'char.glb',
            'height': 100,
            'state': r'${mood}',
            'state_trigger': r'${taps}',
            'states': model3dStates,
            'on_state_end': 'landed',
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

      testWidgets('탭 횟수로 progress를 한 칸씩 진행한다', (tester) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);

        await pumpEngineTemplate(tester, {
          '_type': 'model_3d',
          'src': 'char.glb',
          'height': 100,
          'progress': {
            'clip': 'Wave',
            'at': r'${[0, 2500, 6000][min(taps, 2)]}',
          },
          '_scope': {
            '_state': {'taps': 0},
            '_action': {
              'tap_egg': {'_type': 'set', 'taps': r'${taps + 1}'},
            },
          },
          '_on': {
            'tap': {'do': 'tap_egg', 'ripple': false},
          },
        });
        await tester.pumpAndSettle();
        final controller = source.controllers.single;
        expect(controller.seconds, 0);

        await tester.tap(find.byKey(const Key('model-view')));
        await tester.pumpAndSettle();
        expect(controller.seconds, 2.5);

        await tester.tap(find.byKey(const Key('model-view')));
        await tester.pumpAndSettle();
        expect(controller.seconds, 6);

        await tester.tap(find.byKey(const Key('model-view')));
        await tester.pumpAndSettle();
        expect(controller.seconds, 6);
      });

      testWidgets('움직이는 동안의 탭은 무시하고 도착한 뒤의 탭만 진행한다', (tester) async {
        final source = RecordingModel3dSource();
        Model3dSourceRegistry.install(source);

        await pumpEngineTemplate(tester, {
          '_type': 'model_3d',
          'src': 'char.glb',
          'height': 100,
          'progress': {
            'clip': 'Wave',
            'at': r'${[0, 2000, 6000][min(taps, 2)]}',
          },
          'on_progress_arrive': 'arrived',
          '_scope': {
            '_state': {'taps': 0, 'moving': false},
            '_action': {
              'tap_egg': {
                '_type': 'set',
                '_when': r'${not moving}',
                'taps': r'${taps + 1}',
                'moving': true,
              },
              'arrived': {'_type': 'set', 'moving': false},
            },
          },
          '_on': {
            'tap': {'do': 'tap_egg', 'ripple': false},
          },
        });
        await tester.pumpAndSettle();
        final controller = source.controllers.single;

        await tester.tap(find.byKey(const Key('model-view')));
        await tester.pump(const Duration(milliseconds: 500));
        // Mid-way to 2s: this tap is ignored.
        await tester.tap(find.byKey(const Key('model-view')));
        await tester.pumpAndSettle();
        expect(controller.seconds, 2);

        await tester.tap(find.byKey(const Key('model-view')));
        await tester.pumpAndSettle();
        expect(controller.seconds, 6);
      });
    });
  });
}
