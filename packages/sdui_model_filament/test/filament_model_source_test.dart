import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_model_filament/sdui_model_filament.dart';

void main() {
  // The Filament engine is native; these cover the Dart surface the `model`
  // widget sees before a viewer exists.
  Future<FilamentModelController> controller({
    bool debugOverlay = false,
  }) async =>
      await FilamentModelSource(
            debugOverlay: debugOverlay,
          ).controllerFor(const ModelRequest(src: '/a.glb'))
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

  testWidgets('뷰는 제스처를 잡지 않고, 로드 전 카메라 변경은 보관만 한다', (tester) async {
    final model = await controller();

    await tester.pumpWidget(
      SizedBox(width: 300, height: 200, child: model.buildView()),
    );
    model.setCamera(const ModelCamera(yaw: 45, pitch: 10, zoom: 1.5));
    await tester.pump();

    expect(find.byType(GestureDetector), findsNothing);
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

  test('로드 전에는 클립 길이가 없고 포즈는 실패 없이 무시한다', () async {
    final model = await controller();

    expect(model.clipDuration('Wave'), isNull);
    model.setPose('Wave', const Duration(seconds: 1));
    await model.dispose();
  });
}
