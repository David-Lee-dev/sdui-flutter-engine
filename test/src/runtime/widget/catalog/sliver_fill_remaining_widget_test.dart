import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/sliver_fill_remaining_widget.dart';
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
      child: CustomScrollView(
        slivers: [
          Builder(
            builder: (context) =>
                SliverFillRemainingWidget.build(context, props, children),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  group('SliverFillRemainingWidget', () {
    group('build', () {
      testWidgets('hasScrollBody 기본은 true', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        expect(
          tester
              .widget<SliverFillRemaining>(find.byType(SliverFillRemaining))
              .hasScrollBody,
          isTrue,
        );
      });

      testWidgets('hasScrollBody: false를 읽는다', (tester) async {
        await _pump(
          tester,
          const {'has_scroll_body': false},
          children: [const Text('a')],
        );
        expect(
          tester
              .widget<SliverFillRemaining>(find.byType(SliverFillRemaining))
              .hasScrollBody,
          isFalse,
        );
      });
    });
  });
}
