import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/wrapper/tap_effect.dart';

/// 누름 상태를 읽어오는 헬퍼 — 렌더 오브젝트가 유일한 관찰 지점이다.
RenderPressFeedback _render(WidgetTester tester) =>
    tester.renderObject<RenderPressFeedback>(find.byType(PressFeedback));

Widget _host({VoidCallback? onTap, Size size = const Size(300, 80)}) =>
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: TapEffect(
          onTap: onTap,
          child: SizedBox(width: size.width, height: size.height),
        ),
      ),
    );

/// 탭 인식기의 데드라인(kPressTimeout)과 press-in을 함께 넘긴다.
Future<void> _settlePressIn(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump(const Duration(milliseconds: 150));
}

/// 캡처한 표면 중앙 픽셀의 RGB. 틴트가 실제로 픽셀에 닿는지 보는 유일한 방법이다.
Future<int> _centerRgb(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('probe')),
  );
  late int rgb;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final bytes = data!.buffer.asUint8List();
    final at = ((image.height ~/ 2) * image.width + (image.width ~/ 2)) * 4;
    rgb = (bytes[at] << 16) | (bytes[at + 1] << 8) | bytes[at + 2];
    image.dispose();
  });
  return rgb;
}

void main() {
  group('PressSpec', () {
    group('scaleFor', () {
      test('긴 변 기준 상수 인셋 — 넓은 카드는 1에 가깝다', () {
        // 320px 카드에서 3.5px 인셋 → 1 - 7/320
        expect(
          PressSpec.scaleFor(const Size(320, 88)),
          closeTo(0.978125, 1e-9),
        );
      });

      test('작은 타깃은 minScale에서 멈춘다', () {
        // 40px 아이콘에 비율을 그대로 적용하면 0.825까지 눌려 출렁인다.
        expect(PressSpec.scaleFor(const Size(40, 40)), PressSpec.minScale);
      });

      test('아주 큰 표면은 maxScale에서 멈춘다', () {
        expect(PressSpec.scaleFor(const Size(2000, 400)), PressSpec.maxScale);
      });

      test('크기를 모르면 눌리지 않은 쪽으로 기운다', () {
        expect(PressSpec.scaleFor(Size.zero), PressSpec.maxScale);
        expect(
          PressSpec.scaleFor(const Size(double.infinity, 10)),
          PressSpec.maxScale,
        );
      });
    });
  });

  group('TapEffect', () {
    testWidgets('누르지 않은 동안에는 압인도 틴트도 걸지 않는다', (tester) async {
      await tester.pumpWidget(_host());

      final render = _render(tester);
      expect(render.amount, 0);
      expect(render.scale, 1.0);
      expect(render.tintAlpha, 0);
      // 상시 saveLayer를 만들지 않는다는 계약.
      expect(render.alwaysNeedsCompositing, isFalse);
    });

    testWidgets('누르면 압인과 틴트가 함께 오른다', (tester) async {
      await tester.pumpWidget(_host());
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(TapEffect)),
      );
      await _settlePressIn(tester);

      final render = _render(tester);
      expect(render.amount, 1.0);
      expect(
        render.scale,
        closeTo(PressSpec.scaleFor(const Size(300, 80)), 1e-9),
      );
      expect(render.tintAlpha, closeTo(PressSpec.tintOpacity, 1e-9));
      expect(render.alwaysNeedsCompositing, isTrue);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('누른 채로 있으면 유지된다 — 혼자 재생되지 않는다', (tester) async {
      await tester.pumpWidget(_host());
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(TapEffect)),
      );
      await _settlePressIn(tester);
      await tester.pump(const Duration(seconds: 2));

      expect(_render(tester).amount, 1.0);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('떼면 out 시간에 걸쳐 되돌아온다', (tester) async {
      await tester.pumpWidget(_host());
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(TapEffect)),
      );
      await _settlePressIn(tester);
      await gesture.up();
      // 첫 pump는 티커 시작 시각만 잡는다. 경과는 그 다음 프레임부터.
      await tester.pump();

      // in(110ms)만큼 지난 시점 — out은 240ms라 아직 남아 있어야 한다.
      await tester.pump(const Duration(milliseconds: 110));
      expect(_render(tester).amount, greaterThan(0));

      await tester.pump(const Duration(milliseconds: 200));
      expect(_render(tester).amount, 0);
    });

    testWidgets('취소는 뗄 때보다 빠르게 되돌린다 — 스크롤에 뺏겨도 잔상이 없다', (tester) async {
      await tester.pumpWidget(_host());
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(TapEffect)),
      );
      await _settlePressIn(tester);
      await gesture.cancel();
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 130));
      expect(_render(tester).amount, 0);
    });

    testWidgets('칠해진 표면은 틴트 세기만큼 밝아진다', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: ValueKey('probe'),
              child: TapEffect(
                child: ColoredBox(
                  color: Color(0xFF2C2C2C),
                  child: SizedBox(width: 120, height: 120),
                ),
              ),
            ),
          ),
        ),
      );

      expect(await _centerRgb(tester), 0x2C2C2C);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(TapEffect)),
      );
      await _settlePressIn(tester);

      // 알파는 8비트로 양자화된다 — 0.10 → 26/255.
      // 0x2C(44) + (26/255) * (0xED(237) - 44) = 63.7 → 0x40
      expect(await _centerRgb(tester), 0x404040);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('칠하지 않은 표면은 틴트가 얹힐 곳이 없다 — 압인만 남는다', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: ValueKey('probe'),
              child: TapEffect(child: SizedBox(width: 120, height: 120)),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(TapEffect)),
      );
      await _settlePressIn(tester);

      // srcATop은 destination 알파를 그대로 쓴다 — 투명한 곳은 투명하게 남는다.
      expect(await _centerRgb(tester), 0x000000);
      expect(_render(tester).scale, lessThan(1));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('탭 콜백은 그대로 발화한다', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(onTap: () => taps++));

      await tester.tap(find.byType(TapEffect));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });
  });
}
