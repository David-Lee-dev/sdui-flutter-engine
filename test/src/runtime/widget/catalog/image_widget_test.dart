import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/image_widget.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';
import 'package:sdui_engine/src/dependency/image_source.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

class _CaptureImageSource implements ImageSource {
  const _CaptureImageSource(this.onResolve);
  final void Function(ImageRequest request) onResolve;
  @override
  ImageResult resolve(ImageRequest request) {
    onResolve(request);
    return const NoImage();
  }
}

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  double scale = 1.0,
  Map<String, Widget> slots = const <String, Widget>{},
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: scale,
      child: Builder(
        builder: (context) => ImageWidget.build(context, props, slots),
      ),
    ),
  ),
);

void main() {
  group('ImageWidget', () {
    setUp(ImageSourceRegistry.reset);
    tearDown(ImageSourceRegistry.reset);

    group('build', () {
      testWidgets('src가 없으면 SizedBox.shrink로 접는다(네트워크 요청 없이)', (tester) async {
        await _pump(tester, const {});
        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(Image), findsNothing);
      });

      testWidgets('src가 빈 문자열이어도 접는다', (tester) async {
        await _pump(tester, const {'src': ''});
        expect(find.byType(Image), findsNothing);
      });

      testWidgets('src가 비문자열이어도 접는다', (tester) async {
        await _pump(tester, const {'src': 5});
        expect(find.byType(Image), findsNothing);
      });

      testWidgets('유효한 src는 Image.network로, width·height가 scale된다', (
        tester,
      ) async {
        await _pump(tester, const {
          'src': 'https://example.com/a.png',
          'width': 100,
          'height': 50,
          'fit': 'cover',
        }, scale: 0.5);
        final image = tester.widget<Image>(find.byType(Image));
        expect(image.width, 50);
        expect(image.height, 25);
        expect(image.fit, BoxFit.cover);
        // 테스트 환경은 실제 네트워크를 막아 400을 돌려준다 — 위젯 구성 자체(위 assert)만
        // 검증 대상이라 로드 실패 예외는 여기서 소비한다.
        expect(tester.takeException(), isNotNull);
      });

      testWidgets('작성된 loading 슬롯이 ImageRequest로 전달된다', (tester) async {
        ImageRequest? seen;
        ImageSourceRegistry.install(_CaptureImageSource((r) => seen = r));
        addTearDown(ImageSourceRegistry.reset);
        await _pump(
          tester,
          const {'src': 'https://example.com/a.png'},
          slots: {'loading': Container(key: const Key('load'))},
        );
        expect(seen?.loading, isNotNull);
      });

      testWidgets('작성된 error 슬롯을 errorBuilder로 전달한다', (tester) async {
        await _pump(
          tester,
          const {'src': 'https://example.com/a.png'},
          slots: {'error': Container(key: const Key('error'))},
        );
        expect(
          tester.widget<Image>(find.byType(Image)).errorBuilder,
          isNotNull,
        );
        await tester.pump();
      });

      testWidgets('cacheWidth·cacheHeight는 scale하지 않은 decode 힌트로 전달한다', (
        tester,
      ) async {
        await _pump(tester, const {
          'src': 'https://example.com/a.png',
          'cache_width': 200,
          'cache_height': 100,
        }, scale: 0.5);
        // cacheWidth/Height는 decode 다운샘플 힌트라 Image.network가 provider를 ResizeImage로
        // 감싼다 — 그 width/height가 scale(0.5) 없이 원값(200·100) 그대로면 "표시 크기와 무관한
        // 디코딩 치수"가 맞다(치수를 scale하면 저해상 디코딩됨).
        final provider =
            tester.widget<Image>(find.byType(Image)).image as ResizeImage;
        expect(provider.width, 200);
        expect(provider.height, 100);
        tester.takeException(); // 네트워크 차단 예외 소비(위 구성만 검증 대상).
      });

      testWidgets('alignment·colorBlendMode·repeat·semanticLabel을 전달한다', (
        tester,
      ) async {
        await _pump(tester, const {
          'src': 'https://example.com/a.png',
          'alignment': 'bottom_right',
          'color_blend_mode': 'multiply',
          'repeat': 'repeat_x',
          'semantic_label': '상품 이미지',
        });
        final image = tester.widget<Image>(find.byType(Image));
        expect(image.alignment, Alignment.bottomRight);
        expect(image.colorBlendMode, BlendMode.multiply);
        expect(image.repeat, ImageRepeat.repeatX);
        expect(image.semanticLabel, '상품 이미지');
        tester.takeException();
      });
    });
  });
}
