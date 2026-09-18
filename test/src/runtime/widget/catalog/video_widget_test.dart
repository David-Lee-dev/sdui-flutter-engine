import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/dependency/video_source.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/video_widget.dart';
import 'package:sdui_engine/src/runtime/media/video_source_registry.dart';
import 'package:video_player/video_player.dart';

final class _FakeController extends VideoPlayerController {
  _FakeController()
    : super.networkUrl(Uri.parse('https://example.com/video.mp4'));

  bool? looping;
  double? volume;
  int playCalls = 0;

  @override
  Future<void> initialize() async {
    value = value.copyWith(
      duration: const Duration(seconds: 2),
      size: const Size(320, 180),
      isInitialized: true,
    );
  }

  @override
  Future<void> setLooping(bool looping) async => this.looping = looping;

  @override
  Future<void> setVolume(double volume) async => this.volume = volume;

  @override
  Future<void> play() async {
    playCalls++;
  }
}

final class _RecordingVideoSource implements VideoSource {
  final requests = <VideoRequest>[];
  final controllers = <_FakeController>[];

  @override
  Future<VideoPlayerController> controllerFor(VideoRequest request) async {
    requests.add(request);
    final controller = _FakeController();
    controllers.add(controller);
    return controller;
  }
}

Future<void> _pump(WidgetTester tester, Map<String, Object?> props) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Builder(
        builder: (context) => VideoWidget.build(context, props, const [], null),
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
  });
}
