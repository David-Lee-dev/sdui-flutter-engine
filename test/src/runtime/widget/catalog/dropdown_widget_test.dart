import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/dropdown_widget.dart';

void main() {
  testWidgets('reflects bound value and emits changes', (tester) async {
    Object? changed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => DropdownWidget.build(
              context,
              const {
                'options': [
                  {'value': 'a', 'label': 'Alpha'},
                  {'value': 'b', 'label': 'Beta'},
                ],
              },
              'a',
              (value) => changed = value,
              null,
            ),
          ),
        ),
      ),
    );
    final dropdown = tester.widget<DropdownButton<Object?>>(
      find.byType(DropdownButton<Object?>),
    );
    expect(dropdown.value, 'a');
    dropdown.onChanged!('b');
    expect(changed, 'b');
  });
}
