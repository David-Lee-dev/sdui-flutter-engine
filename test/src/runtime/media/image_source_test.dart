import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/image_source.dart';
import 'package:sdui_engine/src/runtime/media/asset_image_source.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';

final class _TestImageSource implements ImageSource {
  const _TestImageSource();

  @override
  ImageResult resolve(ImageRequest request) =>
      const ReadyImage(SizedBox.shrink());
}

void main() {
  group('ImageSource', () {
    group('install / freeze', () {
      setUp(ImageSourceRegistry.reset);
      tearDown(ImageSourceRegistry.reset);

      test('install이 current를 교체한다', () {
        const source = _TestImageSource();
        ImageSourceRegistry.install(source);
        expect(ImageSourceRegistry.current, same(source));
      });

      test('freeze 뒤 install은 StateError를 던진다', () {
        ImageSourceRegistry.freeze();
        expect(
          () => ImageSourceRegistry.install(const _TestImageSource()),
          throwsStateError,
        );
      });

      test('reset은 기본 정책을 복원하고 freeze를 푼다', () {
        ImageSourceRegistry.install(const _TestImageSource());
        ImageSourceRegistry.freeze();

        ImageSourceRegistry.reset();

        expect(ImageSourceRegistry.current, isA<AssetImageSource>());
        expect(
          () => ImageSourceRegistry.install(const _TestImageSource()),
          returnsNormally,
        );
      });
    });

    group('AssetImageSource', () {
      group('resolve', () {
        test('빈 src는 NoImage', () {
          expect(
            const AssetImageSource().resolve(const ImageRequest(src: '')),
            isA<NoImage>(),
          );
        });

        test('src·크기·fit을 AssetImage로 전달한다', () {
          final result =
              const AssetImageSource().resolve(
                    const ImageRequest(
                      src: 'assets/logo.png',
                      width: 120,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                  as ReadyImage;
          final image = result.image as Image;

          expect(image.width, 120);
          expect(image.height, 80);
          expect(image.fit, BoxFit.cover);
          expect(image.image, isA<AssetImage>());
          expect((image.image as AssetImage).assetName, 'assets/logo.png');
        });

        test('error 슬롯이 있으면 errorBuilder를 만든다', () {
          const marker = SizedBox(key: Key('err'));
          final result =
              const AssetImageSource().resolve(
                    const ImageRequest(src: 'assets/logo.png', error: marker),
                  )
                  as ReadyImage;
          expect((result.image as Image).errorBuilder, isNotNull);
        });
      });
    });
  });
}
