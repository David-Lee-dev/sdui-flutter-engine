import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/tooltip_widget.dart';

void main() {
  testWidgets('renders its child and resolves message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TooltipWidget.build(
            context,
            const {'message': 'Save'},
            const [Icon(Icons.save)],
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.save), findsOneWidget);
    expect(tester.widget<Tooltip>(find.byType(Tooltip)).message, 'Save');
  });
}
