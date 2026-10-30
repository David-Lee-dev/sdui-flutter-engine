import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/transform_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
  double scale = 1.0,
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: scale,
      child: Builder(
        builder: (context) => TransformWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('TransformWidget', () {
    group('build', () {
      testWidgets('translate를 matrix4 디코더로 전달한다', (tester) async {
        await _pump(tester, const {
          'translate': [10, 20],
        }, scale: 0.5);
        final t = tester
            .widget<Transform>(find.byType(Transform))
            .transform
            .getTranslation();
        expect(t.x, 10);
        expect(t.y, 20);
      });

      testWidgets('offset은 EngineMetrics로 scale되고 translate에 더해진다', (
        tester,
      ) async {
        await _pump(tester, const {
          'offset': [10, 20],
        }, scale: 0.5);
        var t = tester
            .widget<Transform>(find.byType(Transform))
            .transform
            .getTranslation();
        expect([t.x, t.y], [5, 10]);

        await _pump(tester, const {
          'offset': [10, 20],
          'translate': [1, 2],
        }, scale: 0.5);
        t = tester
            .widget<Transform>(find.byType(Transform))
            .transform
            .getTranslation();
        expect([t.x, t.y], [6, 12]);
      });

      testWidgets('scale은 배수라 그대로', (tester) async {
        await _pump(tester, const {'scale': 2});
        final m = tester.widget<Transform>(find.byType(Transform)).transform;
        expect(m.entry(0, 0), 2);
        expect(m.entry(1, 1), 2);
      });

      testWidgets('비균일 scale로 X축을 뒤집는다', (tester) async {
        await _pump(tester, const {
          'scale': [-1, 1],
        });
        final m = tester.widget<Transform>(find.byType(Transform)).transform;
        expect(m.entry(0, 0), -1);
        expect(m.entry(1, 1), 1);
      });

      testWidgets('자식을 감싼다', (tester) async {
        await _pump(tester, const {'rotate': 0.5}, children: [const Text('a')]);
        expect(find.text('a'), findsOneWidget);
      });
    });
  });
}
