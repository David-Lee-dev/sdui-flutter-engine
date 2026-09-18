import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/intrinsic_height_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: 1.0,
      child: Builder(
        builder: (context) =>
            IntrinsicHeightWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('IntrinsicHeightWidget', () {
    group('build', () {
      testWidgets('자식을 감싼다', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        expect(find.byType(IntrinsicHeight), findsOneWidget);
        expect(find.text('a'), findsOneWidget);
      });

      testWidgets('자식이 여럿이면 첫 번째만', (tester) async {
        await _pump(
          tester,
          const {},
          children: [const Text('a'), const Text('b')],
        );
        expect(
          (tester.widget<IntrinsicHeight>(find.byType(IntrinsicHeight)).child
                  as Text)
              .data,
          'a',
        );
      });
    });
  });
}
