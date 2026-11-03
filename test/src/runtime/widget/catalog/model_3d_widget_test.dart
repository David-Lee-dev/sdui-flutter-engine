import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/image_source.dart';
import 'package:sdui_engine/src/contract/model_3d_source.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';
import 'package:sdui_engine/src/runtime/media/model_3d_source_registry.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/model_3d_widget.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';
import 'package:sdui_engine/src/runtime/widget/model_3d/model_3d_camera_rig.dart';
import 'package:sdui_engine/src/runtime/widget/model_3d/model_3d_progress.dart';

import '../../../../support/engine_harness.dart';

final class _Play {
  const _Play(this.clip, this.loop, this.crossfade);

  final String clip;
  final bool loop;
  final Duration crossfade;
}

final class _FakeController implements SduiModel3dController {
  _FakeController({this.fail = false, this.gate});

  final bool fail;

  /// Holds [initialize] open until completed, to observe the loading phase.
  final Completer<void>? gate;
  @override
  final List<String> clips = const ['Idle', 'Jump', 'Wave'];
  final plays = <_Play>[];
  final cameras = <Model3dCamera>[];
  final poses = <(String, Duration)>[];
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
  void setCamera(Model3dCamera camera) => cameras.add(camera);

  /// Every clip lasts a second, except `Wave` at six.
  @override
  Duration? clipDuration(String clip) =>
      !clips.contains(clip) ? null : Duration(seconds: clip == 'Wave' ? 6 : 1);

  @override
  void setPose(String clip, Duration time) => poses.add((clip, time));

  double get seconds =>
      poses.last.$2.inMicroseconds / Duration.microsecondsPerSecond;

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  @override
  Model3dPlayback get playback =>
      Model3dPlayback(clip: _clip, isPlaying: true, completions: _completions);

  @override
  Widget buildView() => const SizedBox.expand(key: Key('model-view'));

  @override
  Future<void> dispose() async => disposed = true;
}

final class _RecordingModel3dSource extends Model3dSource {
  _RecordingModel3dSource({this.fail = false, this.gate});

  final bool fail;
  final Completer<void>? gate;
  final requests = <Model3dRequest>[];
  final controllers = <_FakeController>[];

  @override
  Future<SduiModel3dController> controllerFor(Model3dRequest request) async {
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
              Model3dWidget.build(context, props, const [], dispatch),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Model3dWidget', () {
    setUp(() {
      Model3dSourceRegistry.reset();
      ImageSourceRegistry.reset();
      ImageSourceRegistry.install(const _TextImageSource());
    });
    tearDown(() {
      Model3dSourceRegistry.reset();
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
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
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
        Model3dSourceRegistry.install(_RecordingModel3dSource(gate: gate));

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
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);

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
      testWidgets('state가 바뀌면 그 클립을 crossfade_duration으로 섞어 튼다', (
        tester,
      ) async {
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        const base = {
          'src': 'char.glb',
          'height': 100,
          'states': _states,
          'crossfade_duration': 300,
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
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        final sink = _Sink();

        await _pump(tester, const {
          'src': 'char.glb',
          'height': 100,
          'state': 'jump',
          'states': _states,
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
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        final sink = _Sink();

        await _pump(tester, const {
          'src': 'char.glb',
          'height': 100,
          'state': 'idle',
          'states': _states,
          'on_state_end': 'never',
        }, dispatch: sink);
        await tester.pumpAndSettle();
        source.controllers.single.finish();
        await tester.pump();

        expect(sink.calls, isEmpty);
      });

      testWidgets('state_trigger가 바뀌면 같은 state를 다시 재생한다', (tester) async {
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        const base = {
          'src': 'char.glb',
          'height': 100,
          'state': 'wave',
          'states': _states,
        };

        await _pump(tester, {...base, 'state_trigger': 1});
        await tester.pumpAndSettle();
        await _pump(tester, {...base, 'state_trigger': 1});
        await _pump(tester, {...base, 'state_trigger': 2});

        expect(source.controllers.single.plays.map((p) => p.clip), [
          'Wave',
          'Wave',
        ]);
      });

      testWidgets('로드 중에 받은 state는 준비된 뒤에 재생한다', (tester) async {
        final source = _RecordingModel3dSource();
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
          'on_state_end': 'landed',
        }, dispatch: sink);
        await tester.pump();

        expect(sink.calls.map((c) => c.$1), ['landed']);
        expect(find.text('poster:char.png'), findsOneWidget);
      });

      testWidgets('로드에 실패하면 on_error를 보내고 poster를 유지하며 state를 끝낸다', (
        tester,
      ) async {
        final source = _RecordingModel3dSource(fail: true);
        Model3dSourceRegistry.install(source);
        final sink = _Sink();

        await _pump(tester, const {
          'src': 'char.glb',
          'poster': 'char.png',
          'height': 100,
          'state': 'jump',
          'states': _states,
          'on_error': 'failed',
          'on_state_end': 'landed',
        }, dispatch: sink);
        await tester.pumpAndSettle();

        expect(sink.calls.map((c) => c.$1), ['failed', 'landed']);
        expect(find.text('poster:char.png'), findsOneWidget);
        expect(find.byKey(const Key('model-view')), findsNothing);
        expect(source.controllers.single.disposed, isTrue);
      });

      testWidgets('모델에 없는 클립이면 재생하지 않고 state를 끝낸다', (tester) async {
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        final sink = _Sink();

        await _pump(tester, const {
          'src': 'char.glb',
          'height': 100,
          'state': 'dance',
          'states': _states,
          'on_state_end': 'danced',
        }, dispatch: sink);
        await tester.pumpAndSettle();

        expect(source.controllers.single.clips, isNot(contains('Dance')));
        expect(source.controllers.single.plays, isEmpty);
        expect(sink.calls.map((c) => c.$1), ['danced']);
      });
    });

    group('camera', () {
      Model3dCamera last(_RecordingModel3dSource source) =>
          source.controllers.single.cameras.last;

      Future<_RecordingModel3dSource> ready(
        WidgetTester tester,
        Map<String, Object?> props, {
        bool settle = true,
      }) async {
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
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
        expect(plain.controllers.single.cameras.first, const Model3dCamera());

        await tester.pumpWidget(const SizedBox());
        final framed = await ready(tester, const {
          'camera': {'yaw': 30, 'pitch': 15, 'zoom': 1.2},
        });
        expect(
          framed.controllers.single.cameras.first,
          const Model3dCamera(yaw: 30, pitch: 15, zoom: 1.2),
        );
      });

      testWidgets('controls가 없으면 드래그해도 카메라가 그대로다', (tester) async {
        final source = await ready(tester, const {});

        await tester.drag(view, const Offset(100, 50));
        await tester.pumpAndSettle();

        expect(last(source), const Model3dCamera());
      });

      testWidgets('horizontal은 가로 드래그로 돌고 세로 드래그는 부모 스크롤로 간다', (tester) async {
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        final scroll = ScrollController();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: ListView(
              controller: scroll,
              children: [
                Builder(
                  builder: (context) => Model3dWidget.build(
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

      testWidgets('free는 세로 드래그로 기울고 min_pitch·max_pitch 에서 멈춘다', (
        tester,
      ) async {
        final source = await ready(tester, const {
          'controls': {
            'rotate': 'free',
            'min_pitch': -10,
            'max_pitch': 20,
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

      testWidgets('return_duration이 있으면 놓은 뒤 camera로 돌아온다', (tester) async {
        final source = await ready(tester, const {
          'camera': {'yaw': 10},
          'controls': {'rotate': 'horizontal', 'return_duration': 300},
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

      testWidgets('min_zoom·max_zoom 안에서 핀치로 확대한다', (tester) async {
        final source = await ready(tester, const {
          'controls': {
            'rotate': 'free',
            'min_zoom': 0.5,
            'max_zoom': 2,
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

      testWidgets('camera가 바뀌면 duration 동안 옮겨 간다', (tester) async {
        final source = await ready(tester, const {
          'camera': {'yaw': 0, 'duration': 400},
        });

        await _pump(tester, const {
          'src': 'char.glb',
          'width': 200,
          'height': 200,
          'camera': {'yaw': 90, 'duration': 400},
        });
        await tester.pump(const Duration(milliseconds: 200));
        final halfway = last(source).yaw;
        expect(halfway, greaterThan(0));
        expect(halfway, lessThan(90));

        await tester.pumpAndSettle();
        expect(last(source).yaw, 90);
      });
    });

    group('progress', () {
      /// The clip of every `on_progress_end` dispatch.
      List<Object?> ends(_Sink sink) => [
        for (final (action, event) in sink.calls)
          if (action == 'done') (event! as Map)['clip'],
      ];

      /// Every `on_progress_arrive` payload.
      List<Object?> arrivals(_Sink sink) => [
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

      Future<_FakeController> ready(
        WidgetTester tester,
        Map<String, Object?> progress, {
        ActionSink? sink,
      }) async {
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        await _pump(tester, props(progress), dispatch: sink);
        await tester.pumpAndSettle();
        return source.controllers.single;
      }

      testWidgets('로드 후 첫 목표는 재생 없이 그 자리에 바로 보인다', (tester) async {
        final sink = _Sink();
        final controller = await ready(tester, const {'at': 3000}, sink: sink);

        expect(controller.poses, [('Wave', const Duration(seconds: 3))]);
        expect(controller.plays, isEmpty);
        expect(sink.calls, isEmpty);
      });

      testWidgets('목표가 바뀌면 클립 속도로 재생해 가서 멈춘다', (tester) async {
        final controller = await ready(tester, const {'at': 1000});

        await _pump(tester, props(const {'at': 3000}));
        await tester.pump(const Duration(seconds: 1));
        expect(controller.seconds, closeTo(2, 0.05));

        await tester.pumpAndSettle();
        expect(controller.seconds, 3);
        final count = controller.poses.length;
        await tester.pump(const Duration(seconds: 1));
        expect(controller.poses.length, count);
      });

      testWidgets('재생 중에 목표가 더 멀어지면 끊기지 않고 이어 간다', (tester) async {
        final controller = await ready(tester, const {'at': 0});

        await _pump(tester, props(const {'at': 1000}));
        await tester.pump(const Duration(milliseconds: 500));
        await _pump(tester, props(const {'at': 4000}));
        await tester.pumpAndSettle();

        final times = [for (final (_, time) in controller.poses) time];
        for (var i = 1; i < times.length; i++) {
          expect(times[i], greaterThan(times[i - 1]));
        }
        expect(controller.seconds, 4);
      });

      testWidgets('목표가 앞으로 돌아가면 거꾸로 재생하고 speed는 속도를 바꾼다', (tester) async {
        final controller = await ready(tester, const {'at': 4000, 'speed': 2});

        await _pump(tester, props(const {'at': 2000, 'speed': 2}));
        await tester.pump(const Duration(milliseconds: 500));
        expect(controller.seconds, closeTo(3, 0.05));
        await tester.pumpAndSettle();
        expect(controller.seconds, 2);

        await _pump(tester, props(const {'at': 5000, 'speed': 0}));
        await tester.pump();
        expect(controller.poses.last, ('Wave', const Duration(seconds: 5)));
      });

      testWidgets('value는 비율이고 끝에 도착하면 on_progress_end를 한 번 보낸다', (
        tester,
      ) async {
        final sink = _Sink();
        final controller = await ready(tester, const {
          'value': 0.5,
        }, sink: sink);
        expect(controller.seconds, 3);

        await _pump(tester, props(const {'value': 1}), dispatch: sink);
        await tester.pumpAndSettle();
        expect(controller.seconds, 6);
        expect(ends(sink), ['Wave']);

        // A target past the end is clamped there: the playhead stays put.
        await _pump(tester, props(const {'value': 1.5}), dispatch: sink);
        await tester.pumpAndSettle();
        expect(sink.calls, hasLength(1));
      });

      testWidgets('처음부터 끝에 있으면 on_progress_end를 보내지 않는다', (tester) async {
        final sink = _Sink();
        final controller = await ready(tester, const {'value': 1}, sink: sink);

        expect(controller.seconds, 6);
        expect(sink.calls, isEmpty);
      });

      testWidgets('로딩 중에 끝으로 바뀌면 붙자마자 끝 모습으로 보이고 on_progress_end를 보낸다', (
        tester,
      ) async {
        final gate = Completer<void>();
        final source = _RecordingModel3dSource(gate: gate);
        Model3dSourceRegistry.install(source);
        final sink = _Sink();

        await _pump(tester, props(const {'at': 0}), dispatch: sink);
        await _pump(tester, props(const {'at': 6000}), dispatch: sink);
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
        final sink = _Sink();
        await _pump(tester, props(const {'value': 0.2}), dispatch: sink);
        await _pump(tester, props(const {'value': 1}), dispatch: sink);
        await tester.pumpAndSettle();
        expect(ends(sink), ['Wave']);

        await tester.pumpWidget(const SizedBox());
        sink.calls.clear();
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        Map<String, Object?> missing(Object value) => {
          ...props(const {}),
          'progress': {'clip': 'Dance', 'value': value},
        };
        await _pump(tester, missing(0), dispatch: sink);
        await tester.pumpAndSettle();
        await _pump(tester, missing(1), dispatch: sink);
        await tester.pumpAndSettle();
        expect(source.controllers.single.poses, isEmpty);
        expect(ends(sink), ['Dance']);
      });

      testWidgets('목표에 도착하면 on_progress_arrive를 한 번 보내고 첫 목표는 보내지 않는다', (
        tester,
      ) async {
        final sink = _Sink();
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);
        Map<String, Object?> at(num seconds) =>
            props({'at': seconds * 1000}, onEnd: null, onArrive: 'arrived');

        await _pump(tester, at(1), dispatch: sink);
        await tester.pumpAndSettle();
        expect(arrivals(sink), isEmpty);

        await _pump(tester, at(3), dispatch: sink);
        await tester.pump(const Duration(seconds: 1));
        expect(arrivals(sink), isEmpty);
        await tester.pumpAndSettle();
        expect(arrivals(sink), [
          {'clip': 'Wave', 'at': 3000},
        ]);

        // A target replaced mid-way does not arrive; only the last one does.
        await _pump(tester, at(4), dispatch: sink);
        await tester.pump(const Duration(milliseconds: 500));
        await _pump(tester, at(5), dispatch: sink);
        await tester.pumpAndSettle();
        expect(arrivals(sink), [
          {'clip': 'Wave', 'at': 3000},
          {'clip': 'Wave', 'at': 5000},
        ]);
      });

      testWidgets('끝에 도착하면 on_progress_end 다음에 on_progress_arrive를 보낸다', (
        tester,
      ) async {
        final sink = _Sink();
        await ready(tester, const {'at': 5000}, sink: sink);

        await _pump(
          tester,
          props(const {'at': 6000}, onArrive: 'arrived'),
          dispatch: sink,
        );
        await tester.pumpAndSettle();

        expect(sink.calls.map((call) => call.$1), ['done', 'arrived']);
      });

      testWidgets('바로 옮기거나 움직일 게 없으면 바로 도착한다', (tester) async {
        final sink = _Sink();
        final controller = await ready(tester, const {'at': 2000}, sink: sink);
        Map<String, Object?> target(Map<String, Object?> progress) =>
            props(progress, onEnd: null, onArrive: 'arrived');

        // speed 0 jumps.
        await _pump(
          tester,
          target(const {'at': 4000, 'speed': 0}),
          dispatch: sink,
        );
        // Only the speed changes: the playhead already holds the target.
        await _pump(
          tester,
          target(const {'at': 4000, 'speed': 2}),
          dispatch: sink,
        );
        // A new clip is shown at its target at once.
        await _pump(tester, {
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
        final sink = _Sink();
        Map<String, Object?> missing(Object at) => {
          ...props(const {}, onEnd: null, onArrive: 'arrived'),
          'progress': {'clip': 'Dance', 'at': at},
        };

        await _pump(tester, missing(0), dispatch: sink);
        await _pump(tester, missing(1), dispatch: sink);
        await tester.pumpAndSettle();
        expect(arrivals(sink), [
          {'clip': 'Dance', 'at': null},
        ]);

        await tester.pumpWidget(const SizedBox());
        sink.calls.clear();
        Model3dSourceRegistry.install(_RecordingModel3dSource());
        await _pump(tester, missing(0), dispatch: sink);
        await tester.pumpAndSettle();
        await _pump(tester, missing(1), dispatch: sink);
        await tester.pumpAndSettle();
        expect(arrivals(sink), [
          {'clip': 'Dance', 'at': null},
        ]);
      });

      testWidgets('로딩 중에 목표가 바뀌면 붙자마자 도착한다', (tester) async {
        final gate = Completer<void>();
        Model3dSourceRegistry.install(_RecordingModel3dSource(gate: gate));
        final sink = _Sink();
        Map<String, Object?> at(num seconds) =>
            props({'at': seconds * 1000}, onEnd: null, onArrive: 'arrived');

        await _pump(tester, at(0), dispatch: sink);
        await _pump(tester, at(2), dispatch: sink);
        expect(arrivals(sink), isEmpty);
        gate.complete();
        await tester.pumpAndSettle();

        expect(arrivals(sink), [
          {'clip': 'Wave', 'at': 2000},
        ]);
      });

      testWidgets('클립이 바뀌면 새 클립의 목표로 바로 옮긴다', (tester) async {
        final controller = await ready(tester, const {'at': 3000});

        await _pump(tester, {
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

    group('lifecycle', () {
      testWidgets('src가 바뀌면 이전 컨트롤러를 버리고 새로 만든다', (tester) async {
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);

        await _pump(tester, const {'src': 'a.glb', 'height': 100});
        await tester.pumpAndSettle();
        await _pump(tester, const {'src': 'b.glb', 'height': 100});
        await tester.pumpAndSettle();

        expect(source.requests.map((r) => r.src), ['a.glb', 'b.glb']);
        expect(source.controllers.first.disposed, isTrue);
        expect(source.controllers.last.disposed, isFalse);
      });

      testWidgets('위젯이 사라지면 컨트롤러를 버린다', (tester) async {
        final source = _RecordingModel3dSource();
        Model3dSourceRegistry.install(source);

        await _pump(tester, const {'src': 'a.glb', 'height': 100});
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox());

        expect(source.controllers.single.disposed, isTrue);
      });
    });

    group('template', () {
      testWidgets(
        '탭 → set → state_trigger 변화로 같은 state를 다시 재생하고 끝나면 액션이 state를 되돌린다',
        (tester) async {
          final source = _RecordingModel3dSource();
          Model3dSourceRegistry.install(source);

          await pumpEngineTemplate(tester, {
            '_type': 'model_3d',
            'src': 'char.glb',
            'height': 100,
            'state': r'${mood}',
            'state_trigger': r'${taps}',
            'states': _states,
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
        final source = _RecordingModel3dSource();
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
        final source = _RecordingModel3dSource();
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

  group('Model3dWidget 속성 해석', () {
    test('controls 의 범위는 min_·max_ 짝으로 받고, 뒤집혀 오면 바로잡는다', () {
      final controls = Model3dControls.parse(const {
        'min_pitch': 30,
        'max_pitch': -10,
        'min_zoom': 0.5,
        'max_zoom': 2,
      }, interactive: false);

      expect((controls.minPitch, controls.maxPitch), (-10, 30));
      expect((controls.minZoom, controls.maxZoom), (0.5, 2));
      expect(controls.zooms, isTrue);
    });

    test('줌 한쪽만 주면 나머지는 1이고 핀치가 켜진다', () {
      final out = Model3dControls.parse(const {
        'max_zoom': 2,
      }, interactive: false);
      expect((out.minZoom, out.maxZoom, out.zooms), (1, 2, true));

      final none = Model3dControls.parse(const {}, interactive: false);
      expect(none.zooms, isFalse);
    });

    test('시간은 밀리초: return_duration·camera duration·progress at', () {
      final controls = Model3dControls.parse(const {
        'return_duration': 400,
      }, interactive: false);
      expect(controls.returnAfter, const Duration(milliseconds: 400));

      final (_, ease) = parseModel3dCamera(const {'duration': 250});
      expect(ease, const Duration(milliseconds: 250));

      final progress = Model3dProgress.parse(const {
        'clip': 'Wave',
        'at': 2340,
      });
      expect(progress!.at, closeTo(2.34, 1e-9));
    });
  });
}
