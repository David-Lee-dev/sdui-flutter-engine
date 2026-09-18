import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/rich_text_widget.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

void main() {
  testWidgets('spans를 인라인 혼합 스타일 TextSpan으로 만든다', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) => RichTextWidget.build(context, const {
            'spans': [
              {'value': 'a'},
              {
                'value': 'b',
                'style': {'font_weight': 'bold'},
              },
            ],
          }, const []),
        ),
      ),
    );

    final text = tester.widget<Text>(find.byType(Text));
    final root = text.textSpan! as TextSpan;
    expect(root.children, hasLength(2));
    expect((root.children![1] as TextSpan).style?.fontWeight, FontWeight.bold);
  });

  testWidgets('factory의 richText 빌트인으로 해석된다', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(
      WidgetFactory.build(context, 'rich_text', const {'spans': []}, const []),
      isA<Text>(),
    );
  });
}
