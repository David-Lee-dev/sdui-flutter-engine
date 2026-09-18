import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/backdrop_filter_widget.dart';

void main() {
  testWidgets('renders its child and resolves blend_mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => BackdropFilterWidget.build(
            context,
            const {'blur': 5, 'blend_mode': 'multiply'},
            const [Text('child')],
          ),
        ),
      ),
    );
    expect(find.text('child'), findsOneWidget);
    expect(
      tester.widget<BackdropFilter>(find.byType(BackdropFilter)).blendMode,
      BlendMode.multiply,
    );
  });
}
