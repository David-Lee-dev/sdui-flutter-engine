import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/visibility_widget.dart';
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
        builder: (context) => VisibilityWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('VisibilityWidget', () {
    group('build', () {
      testWidgets('visible 기본은 true — 자식이 보인다', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        expect(
          tester.widget<Visibility>(find.byType(Visibility)).visible,
          isTrue,
        );
        expect(find.text('a'), findsOneWidget);
      });

      testWidgets('visible: false면 숨긴다', (tester) async {
        await _pump(
          tester,
          const {'visible': false},
          children: [const Text('a')],
        );
        expect(
          tester.widget<Visibility>(find.byType(Visibility)).visible,
          isFalse,
        );
        expect(find.text('a'), findsNothing);
      });

      testWidgets('maintainSize는 필요한 상태·애니메이션 유지도 활성화한다', (tester) async {
        await _pump(tester, const {'visible': false, 'maintain_size': true});
        final visibility = tester.widget<Visibility>(find.byType(Visibility));
        expect(visibility.maintainSize, isTrue);
        expect(visibility.maintainState, isTrue);
        expect(visibility.maintainAnimation, isTrue);
      });
    });
  });
}
