import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/text_widget.dart';
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
        builder: (context) => TextWidget.build(context, props, const []),
      ),
    ),
  ),
);

void main() {
  group('TextWidget', () {
    group('build', () {
      testWidgets('value가 없으면 빈 문자열', (tester) async {
        await _pump(tester, const {});
        expect(tester.widget<Text>(find.byType(Text)).data, '');
      });

      testWidgets('숫자 value도 문자열로(상태값이 자주 숫자라 toString)', (tester) async {
        await _pump(tester, const {'value': 0});
        expect(tester.widget<Text>(find.byType(Text)).data, '0');
      });

      testWidgets('style 없으면 style null', (tester) async {
        await _pump(tester, const {'value': 'hi'});
        expect(tester.widget<Text>(find.byType(Text)).style, isNull);
      });

      testWidgets('semanticsLabel을 전달한다', (tester) async {
        await _pump(tester, const {'semantics_label': '인사'});
        expect(tester.widget<Text>(find.byType(Text)).semanticsLabel, '인사');
      });

      testWidgets('style은 fontSize가 scale된다', (tester) async {
        await _pump(tester, const {
          'value': 'hi',
          'style': {'font_size': 20, 'color': '#ff0000'},
        }, scale: 0.5);
        final text = tester.widget<Text>(find.byType(Text));
        expect(text.style?.fontSize, 10);
        expect(text.style?.color, const Color(0xffff0000));
      });

      testWidgets('textAlign·maxLines·overflow·softWrap·textDirection', (
        tester,
      ) async {
        await _pump(tester, const {
          'value': 'hi',
          'text_align': 'center',
          'max_lines': 2,
          'overflow': 'ellipsis',
          'soft_wrap': false,
          'text_direction': 'rtl',
        });
        final text = tester.widget<Text>(find.byType(Text));
        expect(text.textAlign, TextAlign.center);
        expect(text.maxLines, 2);
        expect(text.overflow, TextOverflow.ellipsis);
        expect(text.softWrap, false);
        expect(text.textDirection, TextDirection.rtl);
      });
    });
  });
}
