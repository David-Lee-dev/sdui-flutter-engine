import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/badge_widget.dart';

void main() {
  testWidgets('renders its child and label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => BadgeWidget.build(
            context,
            const {'label': '3'},
            const [Icon(Icons.mail)],
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.mail), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });
}
