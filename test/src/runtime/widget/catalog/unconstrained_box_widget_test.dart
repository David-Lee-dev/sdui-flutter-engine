import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/unconstrained_box_widget.dart';

void main() {
  testWidgets('renders its child and resolves constrained_axis', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => UnconstrainedBoxWidget.build(
            context,
            const {'constrained_axis': 'vertical'},
            const [Text('child')],
          ),
        ),
      ),
    );
    expect(find.text('child'), findsOneWidget);
    expect(
      tester
          .widget<UnconstrainedBox>(find.byType(UnconstrainedBox))
          .constrainedAxis,
      Axis.vertical,
    );
  });
}
