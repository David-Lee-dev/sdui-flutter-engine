import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/circular_progress_indicator_widget.dart';

void main() {
  testWidgets('resolves value and stroke width', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => CircularProgressIndicatorWidget.build(
            context,
            const {'value': 0.4, 'stroke_width': 6},
            const [],
          ),
        ),
      ),
    );
    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.value, 0.4);
    expect(indicator.strokeWidth, 6);
  });
}
