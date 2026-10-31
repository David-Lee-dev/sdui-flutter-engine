import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_model_viewer/sdui_model_viewer.dart';

void main() {
  group('ModelLoadStats', () {
    test('summary는 마운트 순번, 워밍업, 단계별 시간, 모델 경로를 싣는다', () {
      final stats = ModelLoadStats(src: '/a.glb', mount: 2, warmUpMs: 800)
        ..mark('webview')
        ..served(bytes: 3 * 1024 * 1024, cached: true, ms: 4)
        ..mark('ready');

      expect(
        stats.summary(),
        matches(
          RegExp(
            r'^#2 warm-up 800ms /a\.glb: webview \d+ms, model \d+ms, '
            r'ready \d+ms \(3\.0MB cache 4ms\)$',
          ),
        ),
      );
      expect(stats.isReady, isTrue);
    });

    test('워밍업 전 마운트와 실패를 표시한다', () {
      final stats = ModelLoadStats(src: '/a.glb', mount: 1)..fail('timeout');

      expect(stats.summary(), contains('#1 warm-up pending'));
      expect(stats.summary(), endsWith('error: timeout'));
      expect(stats.isReady, isFalse);
    });
  });

  test('FrameStats는 예산을 넘은 프레임과 최악 값을 센다', () {
    final frames = FrameStats(budgetMs: 16.7)
      ..addMs(8)
      ..addMs(20)
      ..addMs(33.3);

    expect(frames.toString(), 'frames 3, >16.7ms 2 (66%), worst 33.3ms');
    frames.reset();
    expect(frames.toString(), 'frames 0, >16.7ms 0 (0%), worst 0.0ms');
  });

  testWidgets('ModelDebugOverlay는 뷰 위에 로딩 상태를 그리고 ready 후 프레임을 센다', (
    tester,
  ) async {
    final stats = ModelLoadStats(src: '/assets/egg.glb', mount: 1);
    await tester.pumpWidget(
      ModelDebugOverlay(stats: stats, child: const SizedBox.expand()),
    );

    expect(find.textContaining('#1 warm-up pending egg.glb'), findsOneWidget);
    expect(find.textContaining('loading'), findsOneWidget);

    stats.mark('ready');
    await tester.pump();
    expect(find.textContaining('since ready: frames'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  test('ModelBytesCache.contains는 받는 중이거나 받은 src를 안다', () async {
    final cache = ModelBytesCache(bundle: _Bundle());
    expect(cache.contains('a'), isFalse);
    final load = cache.load('a');
    expect(cache.contains('a'), isTrue);
    await load;
    expect(cache.contains('a'), isTrue);
  });
}

final class _Bundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => ByteData(1);
}
