import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/vertical_divider_widget.dart';

void main() {
  testWidgets('resolves width', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            Builder(
              builder: (context) => VerticalDividerWidget.build(context, const {
                'width': 12,
              }, const []),
            ),
          ],
        ),
      ),
    );
    expect(
      tester.widget<VerticalDivider>(find.byType(VerticalDivider)).width,
      12,
    );
  });
}
