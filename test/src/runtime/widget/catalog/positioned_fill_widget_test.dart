import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/positioned_fill_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

/// [Positioned.fill]은 [Stack] 안에서만 유효하므로 Stack으로 감싸 pump한다.
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
      child: Stack(
        children: [
          Builder(
            builder: (context) =>
                PositionedFillWidget.build(context, props, children),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  group('PositionedFillWidget', () {
    group('build', () {
      testWidgets('인셋 기본은 0(꽉 채움)', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        final p = tester.widget<Positioned>(find.byType(Positioned));
        expect(p.left, 0.0);
        expect(p.top, 0.0);
        expect(p.right, 0.0);
        expect(p.bottom, 0.0);
      });

      testWidgets('인셋을 읽고 scale 적용', (tester) async {
        await _pump(
          tester,
          const {'left': 20, 'top': 40},
          children: [const Text('a')],
          scale: 0.5,
        );
        final p = tester.widget<Positioned>(find.byType(Positioned));
        expect(p.left, 10);
        expect(p.top, 20);
      });

      testWidgets('음수 인셋을 보존한다', (tester) async {
        await _pump(
          tester,
          const {'top': -6, 'right': -6},
          children: [const Text('a')],
        );
        final p = tester.widget<Positioned>(find.byType(Positioned));
        expect(p.top, -6);
        expect(p.right, -6);
      });
    });
  });
}
