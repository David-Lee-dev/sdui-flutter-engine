import 'package:flutter_test/flutter_test.dart';

import '../support/engine_harness.dart';

/// Route/query parameters (`rootData`) must land in the ROOT scope's state so
/// templates read them with plain `${key}` bindings — and must OVERRIDE a
/// declared `_state` default for the same key. A screen navigated to as
/// `/detail?id=1` typically declares `id: null` in `_state`; before the merge
/// that default shadowed the incoming value.
void main() {
  group('EngineRunner', () {
    group('rootData', () {
      testWidgets('rootData overrides a root-state default with the same key', (
        tester,
      ) async {
        await pumpEngineTemplate(
          tester,
          {
            '_type': 'text',
            'value': r'id=${id}',
            '_scope': {
              '_state': {'id': null},
            },
          },
          rootData: const {'id': '42'},
        );
        await tester.pumpAndSettle();

        expect(find.text('id=42'), findsOneWidget);
      });

      testWidgets('rootData keys undeclared in state stay readable', (
        tester,
      ) async {
        await pumpEngineTemplate(
          tester,
          {
            '_type': 'text',
            'value': r'tab=${tab}',
            '_scope': {
              '_state': {'other': 1},
            },
          },
          rootData: const {'tab': 'home'},
        );
        await tester.pumpAndSettle();

        expect(find.text('tab=home'), findsOneWidget);
      });

      testWidgets('declared defaults survive when rootData omits the key', (
        tester,
      ) async {
        await pumpEngineTemplate(tester, {
          '_type': 'text',
          'value': r'id=${id}',
          '_scope': {
            '_state': {'id': 'default'},
          },
        });
        await tester.pumpAndSettle();

        expect(find.text('id=default'), findsOneWidget);
      });

      testWidgets('rootData state can be rewritten by set like any state', (
        tester,
      ) async {
        await pumpEngineTemplate(
          tester,
          {
            '_type': 'text',
            'value': r'id=${id}',
            '_on': {'tap': 'bump'},
            '_scope': {
              '_state': {'id': null},
              '_action': {
                'bump': {'_type': 'set', 'id': 'changed'},
              },
            },
          },
          rootData: const {'id': '42'},
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('id=42'));
        await tester.pumpAndSettle();
        expect(find.text('id=changed'), findsOneWidget);
      });
    });
  });
}
