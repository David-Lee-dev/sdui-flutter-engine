import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/video_source.dart';
import 'package:sdui_engine/src/runtime/media/asset_video_source.dart';
import 'package:sdui_engine/src/runtime/media/video_source_registry.dart';
import 'package:video_player/video_player.dart';

final class _TestVideoSource implements VideoSource {
  const _TestVideoSource();

  @override
  Future<VideoPlayerController> controllerFor(VideoRequest request) async =>
      VideoPlayerController.networkUrl(Uri.parse(request.src));
}

void main() {
  group('VideoSource', () {
    group('install / freeze', () {
      setUp(VideoSourceRegistry.reset);
      tearDown(VideoSourceRegistry.reset);

      test('install이 current를 교체한다', () {
        const source = _TestVideoSource();

        VideoSourceRegistry.install(source);

        expect(VideoSourceRegistry.current, same(source));
      });

      test('freeze 뒤 install은 StateError를 던진다', () {
        VideoSourceRegistry.freeze();

        expect(
          () => VideoSourceRegistry.install(const _TestVideoSource()),
          throwsStateError,
        );
      });

      test('reset은 기본 정책을 복원하고 freeze를 푼다', () {
        VideoSourceRegistry.install(const _TestVideoSource());
        VideoSourceRegistry.freeze();

        VideoSourceRegistry.reset();

        expect(VideoSourceRegistry.current, isA<AssetVideoSource>());
        expect(
          () => VideoSourceRegistry.install(const _TestVideoSource()),
          returnsNormally,
        );
      });
    });
  });
}
