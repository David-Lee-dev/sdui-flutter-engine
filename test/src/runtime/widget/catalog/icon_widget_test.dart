import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/icon_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  double scale = 1.0,
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: scale,
      child: Builder(
        builder: (context) => IconWidget.build(context, props, const []),
      ),
    ),
  ),
);

void main() {
  group('IconWidget', () {
    group('build', () {
      testWidgets('이름으로 아이콘을 찾고 size(scale)·color를 읽는다', (tester) async {
        await _pump(tester, const {
          'name': 'home',
          'size': 40,
          'color': '#FF0000',
        }, scale: 0.5);
        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.icon?.codePoint, 0xe318); // Icons.home
        expect(icon.size, 20); // scale 적용
        expect(icon.color, const Color(0xFFFF0000));
      });

      testWidgets('미지 이름은 SizedBox.shrink로 관대하게', (tester) async {
        await _pump(tester, const {'name': '존재하지않는아이콘'});
        expect(find.byType(Icon), findsNothing);
        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('semanticLabel을 전달한다', (tester) async {
        await _pump(tester, const {'name': 'home', 'semantic_label': '홈'});
        expect(tester.widget<Icon>(find.byType(Icon)).semanticLabel, '홈');
      });
    });
  });
}
