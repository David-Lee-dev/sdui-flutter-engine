import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/physical_model_widget.dart';

void main() {
  testWidgets('renders its child and resolves elevation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => PhysicalModelWidget.build(
            context,
            const {'elevation': 6},
            const [Text('child')],
          ),
        ),
      ),
    );
    expect(find.text('child'), findsOneWidget);
    expect(
      tester.widget<PhysicalModel>(find.byType(PhysicalModel)).elevation,
      6,
    );
  });
}
