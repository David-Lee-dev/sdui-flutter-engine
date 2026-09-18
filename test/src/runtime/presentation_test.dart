import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/driver/modal/modal_frame.dart';
import 'package:sdui_engine/src/runtime/engine_subtree.dart';
import 'package:sdui_engine/src/runtime/presentation.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/runtime/wrapper/tap_effect.dart';

void main() {
  WidgetFactory.ensureRegistered();
  DriverRegistry.ensureRegistered();
  EngineSubtree.builder ??= (request) =>
      EngineRunner(template: request.template, rootData: request.rootData);

  tearDown(EnginePresentation.reset);

  group('EnginePresentation', () {
    group('tapEffect', () {
      testWidgets('주입한 스타일이 피드백 렌더러에 반영된다', (tester) async {
        EnginePresentation.value = const SduiPresentation(
          tapEffect: TapEffectStyle(tint: Color(0xFF123456), tintOpacity: 0.5),
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: TapEffect(onTap: () {}, child: const SizedBox(width: 10)),
          ),
        );
        await tester.press(find.byType(TapEffect));
        await tester.pump(const Duration(milliseconds: 200));

        final feedback = tester.widget<PressFeedback>(
          find.byType(PressFeedback),
        );
        expect(feedback.tint, const Color(0xFF123456));
        expect(feedback.tintOpacity, 0.5);
      });
    });

    group('modal', () {
      testWidgets('barrier 색과 모서리 반경이 주입 스타일을 따른다', (tester) async {
        EnginePresentation.value = const SduiPresentation(
          modal: ModalStyle(barrierColor: Color(0x55FF0000), borderRadius: 32),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ModalFrame(
              content: const {'_type': 'text', 'value': 'body'},
              variant: ModalVariant.bottomSheet,
              controller: ModalCloseController(),
              onClosed: (_, __) {},
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is ColoredBox && widget.color == const Color(0x55FF0000),
          ),
          findsOneWidget,
        );

        final surface = tester.widget<Material>(
          find
              .ancestor(of: find.text('body'), matching: find.byType(Material))
              .first,
        );
        expect(
          surface.borderRadius,
          const BorderRadius.vertical(top: Radius.circular(32)),
        );
      });
    });
  });
}
