import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/safe_area_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
  double scale = 1.0,
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: EngineMetrics(
        scale: scale,
        child: Builder(
          builder: (context) => SafeAreaWidget.build(context, props, children),
        ),
      ),
    ),
  ),
);

void main() {
  group('SafeAreaWidget', () {
    group('build', () {
      testWidgets('변별 토글과 minimum(scale)을 읽는다', (tester) async {
        await _pump(
          tester,
          const {'top': false, 'minimum': 20},
          children: [const Text('a')],
          scale: 0.5,
        );
        final area = tester.widget<SafeArea>(find.byType(SafeArea));
        expect(area.top, isFalse);
        expect(area.minimum, const EdgeInsets.all(10));
      });

      testWidgets('변 토글 기본은 전부 true', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        final area = tester.widget<SafeArea>(find.byType(SafeArea));
        expect(area.top, isTrue);
        expect(area.bottom, isTrue);
        expect(area.left, isTrue);
        expect(area.right, isTrue);
      });

      testWidgets('maintainBottomViewPadding을 전달한다', (tester) async {
        await _pump(
          tester,
          const {'maintain_bottom_view_padding': true},
          children: [const Text('a')],
        );
        expect(
          tester
              .widget<SafeArea>(find.byType(SafeArea))
              .maintainBottomViewPadding,
          isTrue,
        );
      });
    });
  });
}
