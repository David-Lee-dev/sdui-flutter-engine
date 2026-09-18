import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/align_widget.dart';
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
        builder: (context) => AlignWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('AlignWidget', () {
    group('build', () {
      testWidgets('alignment 기본은 Alignment.center', (tester) async {
        await _pump(tester, const {});
        expect(
          tester.widget<Align>(find.byType(Align)).alignment,
          Alignment.center,
        );
      });

      testWidgets('alignment 이름을 읽는다', (tester) async {
        await _pump(tester, const {'alignment': 'top_left'});
        expect(
          tester.widget<Align>(find.byType(Align)).alignment,
          Alignment.topLeft,
        );
      });
    });
  });
}
