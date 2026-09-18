import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/dependency/image_source.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';

class _CaptureImageSource implements ImageSource {
  const _CaptureImageSource(this.onResolve);
  final void Function(ImageRequest request) onResolve;
  @override
  ImageResult resolve(ImageRequest request) {
    onResolve(request);
    return const NoImage();
  }
}

/// `image` named slot end-to-end — parser·compiler·NodeBuilder의 SlotSpec 분기가 작성된
/// `loading`·`error` 자식을 미리 지어 이미지 공급 정책까지 전달해야 통과한다.
void main() {
  group('image (named-slot 위젯 — _slots)', () {
    setUp(ImageSourceRegistry.reset);
    tearDown(ImageSourceRegistry.reset);

    testWidgets('loading·error 슬롯이 ImageRequest로 전달된다', (tester) async {
      ImageRequest? seen;
      ImageSourceRegistry.install(_CaptureImageSource((r) => seen = r));
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EngineRunner(
              template: {
                '_type': 'image',
                'src': 'https://example.com/a.png',
                '_slots': {
                  'loading': {'_type': 'container'},
                  'error': {'_type': 'container'},
                },
              },
            ),
          ),
        ),
      );

      expect(seen?.loading, isNotNull);
      expect(seen?.error, isNotNull);
      await tester.pump();
    });
  });
}
