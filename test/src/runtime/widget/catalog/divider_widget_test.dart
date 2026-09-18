import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/divider_widget.dart';

void main() {
  testWidgets('resolves thickness', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) =>
              DividerWidget.build(context, const {'thickness': 3}, const []),
        ),
      ),
    );
    expect(tester.widget<Divider>(find.byType(Divider)).thickness, 3);
  });
}
