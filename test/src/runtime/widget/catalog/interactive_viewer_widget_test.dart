import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/interactive_viewer_widget.dart';

void main() {
  testWidgets('renders its child and resolves scale limits', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => InteractiveViewerWidget.build(
            context,
            const {'min_scale': 0.5, 'max_scale': 4},
            const [Text('child')],
          ),
        ),
      ),
    );
    expect(find.text('child'), findsOneWidget);
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.minScale, 0.5);
    expect(viewer.maxScale, 4);
  });
}
