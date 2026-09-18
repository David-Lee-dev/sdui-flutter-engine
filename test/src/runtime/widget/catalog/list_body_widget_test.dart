import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/list_body_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

/// [ListBody]는 주축이 무한한 뷰포트 안에서만 레이아웃되므로 [scroll] 방향의
/// [SingleChildScrollView]로 감싸 pump한다.
Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
  Axis scroll = Axis.vertical,
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: 1.0,
      child: SingleChildScrollView(
        scrollDirection: scroll,
        child: Builder(
          builder: (context) => ListBodyWidget.build(context, props, children),
        ),
      ),
    ),
  ),
);

void main() {
  group('ListBodyWidget', () {
    group('build', () {
      testWidgets('mainAxis를 읽는다', (tester) async {
        await _pump(
          tester,
          const {'main_axis': 'horizontal'},
          children: [const Text('a')],
          scroll: Axis.horizontal,
        );
        expect(
          tester.widget<ListBody>(find.byType(ListBody)).mainAxis,
          Axis.horizontal,
        );
      });

      testWidgets('mainAxis 기본은 vertical', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        expect(
          tester.widget<ListBody>(find.byType(ListBody)).mainAxis,
          Axis.vertical,
        );
      });
    });
  });
}
