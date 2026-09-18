import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/radio_widget.dart';

void main() {
  testWidgets('reflects bound value and emits the option value', (
    tester,
  ) async {
    Object? changed;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Builder(
            builder: (context) => RadioWidget.build(
              context,
              const {'value': 'pro'},
              'pro',
              (value) => changed = value,
              null,
            ),
          ),
        ),
      ),
    );
    final radio = tester.widget<Radio<Object?>>(find.byType(Radio<Object?>));
    // ignore: deprecated_member_use
    expect(radio.groupValue, 'pro');
    // ignore: deprecated_member_use
    radio.onChanged!('pro');
    expect(changed, 'pro');
  });
}
