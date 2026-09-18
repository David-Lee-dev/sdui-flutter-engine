import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/default_tab_controller_widget.dart';
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
            DefaultTabControllerWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('DefaultTabControllerWidget', () {
    group('build', () {
      testWidgets('length·initialIndex를 읽는다', (tester) async {
        await _pump(
          tester,
          const {'length': 3, 'initial_index': 1},
          children: [const Text('a')],
        );
        final c = tester.widget<DefaultTabController>(
          find.byType(DefaultTabController),
        );
        expect(c.length, 3);
        expect(c.initialIndex, 1);
      });

      testWidgets('length 기본은 1', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        expect(
          tester
              .widget<DefaultTabController>(find.byType(DefaultTabController))
              .length,
          1,
        );
      });
    });
  });
}
