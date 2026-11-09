import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/engine_harness.dart';

void main() {
  testWidgets('WAIT-AC14 covered route keeps waiting', (tester) async {
    await pumpEngineTemplate(tester, {
      '_requires': ['wait_v1'],
      '_type': 'text',
      '_scope': {
        '_state': {'x': 0},
        '_action': {
          'go': [
            {'_type': 'wait', 'duration': 1500},
            {'_type': 'set', 'x': 1},
          ],
        },
      },
      '_on': {'tap': 'go'},
      'value': r'${x}',
    });
    await tester.tap(find.text('0'));
    await tester.pump();
    final navigator = Navigator.of(tester.element(find.text('0')));
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('cover')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1499));
    expect(find.text('0', skipOffstage: false), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(find.text('1', skipOffstage: false), findsOneWidget);
    expect(find.text('cover'), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
