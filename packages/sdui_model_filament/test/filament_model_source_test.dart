import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_model_filament/sdui_model_filament.dart';

void main() {
  // The Filament engine is native; these cover the Dart surface the `model`
  // widget sees before a viewer exists.
  Future<FilamentModelController> controller({
    bool interactive = false,
    bool debugOverlay = false,
  }) async =>
      await FilamentModelSource(
            debugOverlay: debugOverlay,
          ).controllerFor(ModelRequest(src: '/a.glb', interactive: interactive))
          as FilamentModelController;

  testWidgets('뷰어가 생기기 전에도 뷰를 그린다', (tester) async {
    final model = await controller();

    await tester.pumpWidget(
      SizedBox(width: 300, height: 200, child: model.buildView()),
    );

    expect(model.clips, isEmpty);
    expect(model.playback.isPlaying, isFalse);
    expect(find.byType(GestureDetector), findsNothing);
    await model.dispose();
  });

  testWidgets('interactive면 가로 드래그만 잡아 세로 스크롤은 부모로 간다', (tester) async {
    final model = await controller(interactive: true);
    var scrolled = 0.0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (n) {
            scrolled += n.scrollDelta ?? 0;
            return false;
          },
          child: ListView(
            children: [
              SizedBox(height: 200, child: model.buildView()),
              const SizedBox(height: 2000),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(GestureDetector), findsWidgets);
    await tester.drag(find.byType(SizedBox).first, const Offset(0, -100));
    expect(scrolled, greaterThan(0));
    await model.dispose();
  });

  testWidgets('debugOverlay면 측정 오버레이를 씌운다', (tester) async {
    final model = await controller(debugOverlay: true);

    await tester.pumpWidget(
      SizedBox(width: 300, height: 200, child: model.buildView()),
    );

    expect(find.byType(ModelDebugOverlay), findsOneWidget);
    expect(model.stats.renderer, 'filament');
    expect(model.stats.mount, 1);
    await tester.pumpWidget(const SizedBox());
    await model.dispose();
  });

  test('로드 전에 재생해도 상태만 바꾸고 실패하지 않는다', () async {
    final model = await controller();
    var notified = 0;
    model.addListener(() => notified++);

    await model.play('Wave', loop: false);
    await model.stop();

    expect(model.playback.clip, 'Wave');
    expect(model.playback.isPlaying, isFalse);
    expect(notified, 2);
    await model.dispose();
  });
}
