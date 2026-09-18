import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/color_filtered_widget.dart';

void main() {
  testWidgets('renders its child with a resolved color filter', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ColorFilteredWidget.build(
            context,
            const {'color': '#336699'},
            const [Text('child')],
          ),
        ),
      ),
    );
    expect(find.text('child'), findsOneWidget);
    expect(find.byType(ColorFiltered), findsOneWidget);
  });
}
