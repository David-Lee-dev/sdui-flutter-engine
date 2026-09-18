import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/sliver_to_box_adapter_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

/// 슬라이버는 [CustomScrollView] 안에서만 레이아웃되므로 뷰포트로 감싸 pump한다.
Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: 1.0,
      child: CustomScrollView(
        slivers: [
          Builder(
            builder: (context) =>
                SliverToBoxAdapterWidget.build(context, props, children),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  group('SliverToBoxAdapterWidget', () {
    group('build', () {
      testWidgets('box 자식을 sliver로 감싼다', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        expect(find.byType(SliverToBoxAdapter), findsOneWidget);
        expect(find.text('a'), findsOneWidget);
      });
    });
  });
}
