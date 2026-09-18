import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/image_filtered_widget.dart';

void main() {
  testWidgets('renders its child and resolves enabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ImageFilteredWidget.build(
            context,
            const {'blur': 3, 'enabled': false},
            const [Text('child')],
          ),
        ),
      ),
    );
    expect(find.text('child'), findsOneWidget);
    expect(
      tester.widget<ImageFiltered>(find.byType(ImageFiltered)).enabled,
      isFalse,
    );
  });
}
