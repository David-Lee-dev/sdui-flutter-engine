import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/aspect_ratio_widget.dart';
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
        builder: (context) => AspectRatioWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('AspectRatioWidget', () {
    group('build', () {
      testWidgets('aspectRatio 기본은 1.0(배수라 스케일 대상 아님)', (tester) async {
        await _pump(tester, const {});
        expect(
          tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio,
          1.0,
        );
      });

      testWidgets('aspectRatio를 읽는다', (tester) async {
        await _pump(tester, const {'aspect_ratio': 1.777});
        expect(
          tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio,
          1.777,
        );
      });
    });
  });
}
