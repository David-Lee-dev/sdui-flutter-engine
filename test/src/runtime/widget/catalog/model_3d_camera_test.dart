import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/model_3d_source.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';
import 'package:sdui_engine/src/runtime/media/model_3d_source_registry.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/model_3d/model_3d_widget.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/model_3d/model_3d_camera_rig.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/model_3d/model_3d_progress.dart';

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

  testWidgets('controller without scene capability ignores extras', (
    tester,
  ) async {
    final source = RecordingModel3dSource();
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'scene': [
        {'src': 'extra.glb'},
      ],
    });
    expect(source.controllers.single, isNot(isA<Model3dSceneController>()));
    expect(source.controllers.single.scenes, isEmpty);
    expect(source.controllers.single.initializations, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('absent scene target pan keeps default calls', (tester) async {
    final source = RecordingModel3dSource();
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {'src': 'char.glb'});
    expect(source.controllers.single.scenes, isEmpty);
    expect(source.controllers.single.cameras, [const Model3dCamera()]);
  });

  testWidgets('two pointer pan clamps and returns without zoom or inertia', (
    tester,
  ) async {
    final source = RecordingModel3dSource();
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'width': 200,
      'height': 200,
      'controls': {
        'rotate': 'free',
        'pan': true,
        'max_pan': 0.25,
        'return_duration': 300,
      },
    });
    var layer = tester.widget<GestureDetector>(
      find.byType(GestureDetector).first,
    );
    expect(layer.onScaleStart, isNotNull);
    layer.onScaleStart!(ScaleStartDetails(pointerCount: 2));
    layer.onScaleUpdate!(
      ScaleUpdateDetails(
        pointerCount: 2,
        focalPointDelta: const Offset(200, 200),
      ),
    );
    final dynamic camera = source.controllers.single.cameras.last;
    expect(camera.pan.distance, closeTo(0.25, 1e-8));
    expect(camera.zoom, 1);
    expect(camera.yaw, 0);
    layer.onScaleEnd!(ScaleEndDetails(pointerCount: 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(
      (source.controllers.single.cameras.last as dynamic).pan.distance,
      lessThan(0.25),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      (source.controllers.single.cameras.last as dynamic).pan,
      Offset.zero,
    );
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'width': 200,
      'height': 200,
      'controls': {'rotate': 'free', 'pan': true, 'min_zoom': 1, 'max_zoom': 3},
    });
    layer = tester.widget<GestureDetector>(find.byType(GestureDetector).first);
    layer.onScaleStart!(ScaleStartDetails(pointerCount: 2));
    layer.onScaleUpdate!(
      ScaleUpdateDetails(
        pointerCount: 2,
        scale: 2,
        focalPointDelta: const Offset(10, 0),
      ),
    );
    expect(source.controllers.single.cameras.last.zoom, 2);
    final panned = source.controllers.single.cameras.last;
    layer.onScaleEnd!(
      ScaleEndDetails(
        velocity: const Velocity(pixelsPerSecond: Offset(1000, 1000)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(source.controllers.single.cameras.last, panned);
  });

  testWidgets('camera targets parse ease and retarget continuously', (
    tester,
  ) async {
    final source = RecordingModel3dSource();
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'camera': {
        'target': [1, 2, 3],
      },
    });
    expect(
      source.controllers.single.cameras.last,
      isNot(const Model3dCamera()),
    );
    dynamic target = (source.controllers.single.cameras.last as dynamic).target;
    expect(target.point, (1.0, 2.0, 3.0));
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'camera': {'target': 'Head', 'duration': 1000},
    });
    await tester.pump(const Duration(milliseconds: 400));
    final dynamic blend =
        (source.controllers.single.cameras.last as dynamic).target;
    expect(blend.weights, hasLength(2));
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'camera': {'target': 'Hand', 'duration': 1000},
    });
    expect((source.controllers.single.cameras.last as dynamic).target, blend);
    await tester.pump(const Duration(milliseconds: 500));
    target = (source.controllers.single.cameras.last as dynamic).target;
    expect(target.weights, hasLength(3));
    await tester.pump(const Duration(seconds: 1));
    target = (source.controllers.single.cameras.last as dynamic).target;
    expect(target.node, 'Hand');
    expect(target.weights, hasLength(1));
    for (final bad in [
      [1, 2],
      [0, double.nan, 2],
      '',
    ]) {
      expect(parseModel3dCamera({'target': bad}).$1, const Model3dCamera());
    }
  });

  test('includes target and pan diagnostics', () {
    const camera = Model3dCamera(
      yaw: 10,
      pitch: 20,
      zoom: 2,
      target: Model3dTarget.node('Head'),
      pan: Offset(0.1, 0.2),
    );
    expect(camera.toString(), contains('target:'));
    expect(camera.toString(), contains('Head'));
    expect(camera.toString(), contains('pan: ${camera.pan}'));
    expect(
      const Model3dCamera(target: Model3dTarget.point((1, 2, 3))).toString(),
      isNot(const Model3dCamera().toString()),
    );
    expect(
      Model3dCamera(
        target: Model3dTarget.lerp(
          const Model3dTarget.node('Head'),
          const Model3dTarget.point((1, 2, 3)),
          0.5,
        ),
      ).toString(),
      allOf(contains('Head'), contains('(1.0, 2.0, 3.0)'), contains('0.5')),
    );
  });

  group('camera', () {
    Model3dCamera last(RecordingModel3dSource source) =>
        source.controllers.single.cameras.last;

    Future<RecordingModel3dSource> ready(
      WidgetTester tester,
      Map<String, Object?> props, {
      bool settle = true,
    }) async {
      final source = RecordingModel3dSource();
      Model3dSourceRegistry.install(source);
      await pumpModel3d(tester, {
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
      final source = RecordingModel3dSource();
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

    testWidgets('free는 세로 드래그로 기울고 min_pitch·max_pitch 에서 멈춘다', (tester) async {
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

    testWidgets('가려진 동안은 auto_rotate가 멈추고 다시 보이면 그 자리에서 이어 돈다', (tester) async {
      const props = {
        'src': 'char.glb',
        'width': 200,
        'height': 200,
        'auto_rotate': 90,
      };
      final source = await ready(tester, props, settle: false);
      await tester.pump(const Duration(milliseconds: 100));
      await pumpModel3d(tester, props, shown: false);
      final hidden = last(source).yaw;

      await tester.pump(const Duration(seconds: 5));
      expect(last(source).yaw, hidden);

      await pumpModel3d(tester, props);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(last(source).yaw - hidden, closeTo(90, 2));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('camera가 바뀌면 duration 동안 옮겨 간다', (tester) async {
      final source = await ready(tester, const {
        'camera': {'yaw': 0, 'duration': 400},
      });

      await pumpModel3d(tester, const {
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
