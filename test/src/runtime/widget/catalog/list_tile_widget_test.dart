import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/list_tile_widget.dart';

void main() {
  testWidgets('renders named slots and resolves selected', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Builder(
            builder: (context) => ListTileWidget.build(
              context,
              const {'selected': true},
              const {
                'leading': Icon(Icons.person),
                'title': Text('Title'),
                'subtitle': Text('Subtitle'),
                'trailing': Icon(Icons.chevron_right),
              },
            ),
          ),
        ),
      ),
    );
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Subtitle'), findsOneWidget);
    expect(tester.widget<ListTile>(find.byType(ListTile)).selected, isTrue);
  });
}
