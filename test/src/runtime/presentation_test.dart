import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/driver/modal/modal_frame.dart';
import 'package:sdui_engine/src/runtime/engine_subtree.dart';
import 'package:sdui_engine/src/contract/tap_feedback.dart';
import 'package:sdui_engine/src/presentation/modal_style.dart';
import 'package:sdui_engine/src/presentation/presentation.dart';
import 'package:sdui_engine/src/runtime/engine_presentation.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

void main() {
  WidgetFactory.ensureRegistered();
  DriverRegistry.ensureRegistered();
  EngineSubtree.builder ??= (request) =>
      EngineRunner(template: request.template, rootData: request.rootData);

  tearDown(EnginePresentation.reset);

  group('EnginePresentation', () {
    group('tapFeedback', () {
      testWidgets('주입한 구현이 기본 리플을 대체한다', (tester) async {
        EnginePresentation.value = const SduiPresentation(
          tapFeedback: _MarkerFeedback(),
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) => EnginePresentation.tapFeedback.wrap(
                context,
                const SizedBox(width: 10),
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('marker-feedback')), findsOneWidget);
        expect(find.byType(InkWell), findsNothing);
      });

      testWidgets('미주입 시 기본은 잉크 리플이다', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => EnginePresentation.tapFeedback.wrap(
                context,
                const SizedBox(width: 10),
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byType(InkWell), findsOneWidget);
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
              onClosed: (_, _) {},
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

final class _MarkerFeedback extends TapFeedback {
  const _MarkerFeedback();
  @override
  Widget wrap(
    BuildContext context,
    Widget child, {
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    VoidCallback? onDoubleTap,
  }) => KeyedSubtree(key: const Key('marker-feedback'), child: child);
}
