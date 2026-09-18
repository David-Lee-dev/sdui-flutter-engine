import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/linear_progress_indicator_widget.dart';

void main() {
  testWidgets('resolves value and minimum height', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => LinearProgressIndicatorWidget.build(
            context,
            const {'value': 0.7, 'min_height': 5},
            const [],
          ),
        ),
      ),
    );
    final indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, 0.7);
    expect(indicator.minHeight, 5);
  });
}
