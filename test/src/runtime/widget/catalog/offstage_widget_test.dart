import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/offstage_widget.dart';
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
        builder: (context) => OffstageWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('OffstageWidget', () {
    group('build', () {
      testWidgets('offstage 기본은 true(Flutter 기본과 동일)', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        expect(tester.widget<Offstage>(find.byType(Offstage)).offstage, isTrue);
      });

      testWidgets('offstage: false면 화면에 보인다', (tester) async {
        await _pump(
          tester,
          const {'offstage': false},
          children: [const Text('a')],
        );
        expect(
          tester.widget<Offstage>(find.byType(Offstage)).offstage,
          isFalse,
        );
      });
    });
  });
}
