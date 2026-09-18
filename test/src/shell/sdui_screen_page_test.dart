import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sdui_engine/src/dependency/screen_loader.dart';
import 'package:sdui_engine/src/shell/screen_page.dart';

final class _FakeLoader implements ScreenLoader {
  _FakeLoader(this._results);

  final List<Future<LoadedScreen> Function()> _results;
  int calls = 0;

  @override
  Future<LoadedScreen> load(String screenId) {
    final result = _results[calls.clamp(0, _results.length - 1)];
    calls += 1;
    return result();
  }
}

LoadedScreen _screen(String text) =>
    (template: {'_type': 'text', 'value': text}, modals: const {});

Future<void> _pumpPage(
  WidgetTester tester,
  ScreenLoader loader, {
  SduiLoadingBuilder? loadingBuilder,
  SduiErrorBuilder? errorBuilder,
}) {
  final router = GoRouter(
    initialLocation: '/s',
    routes: [
      GoRoute(
        path: '/s',
        builder: (context, state) => SduiScreenPage(
          screenId: 's',
          loader: loader,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
        ),
      ),
    ],
  );
  return tester.pumpWidget(MaterialApp.router(routerConfig: router));
}

void main() {
  group('SduiScreenPage', () {
    group('build', () {
      testWidgets('renders the loaded template', (tester) async {
        await _pumpPage(tester, _FakeLoader([() async => _screen('hello')]));
        await tester.pumpAndSettle();
        expect(find.text('hello'), findsOneWidget);
      });

      testWidgets('shows the default loading surface until load completes', (
        tester,
      ) async {
        final completer = Completer<LoadedScreen>();
        await _pumpPage(tester, _FakeLoader([() => completer.future]));
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        completer.complete(_screen('done'));
        await tester.pumpAndSettle();
        expect(find.text('done'), findsOneWidget);
      });

      testWidgets('loadingBuilder overrides the default surface', (
        tester,
      ) async {
        final completer = Completer<LoadedScreen>();
        await _pumpPage(
          tester,
          _FakeLoader([() => completer.future]),
          loadingBuilder: (context) => const Text('custom-loading'),
        );
        await tester.pump();
        expect(find.text('custom-loading'), findsOneWidget);

        completer.complete(_screen('done'));
        await tester.pumpAndSettle();
      });

      testWidgets('errorBuilder receives the error and a working retry', (
        tester,
      ) async {
        final loader = _FakeLoader([
          () async => throw Exception('boom'),
          () async => _screen('recovered'),
        ]);
        await _pumpPage(
          tester,
          loader,
          errorBuilder: (context, error, retry) =>
              TextButton(onPressed: retry, child: Text('err: $error')),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('boom'), findsOneWidget);

        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        expect(find.text('recovered'), findsOneWidget);
        expect(loader.calls, 2);
      });

      testWidgets('default error surface retries on tap', (tester) async {
        final loader = _FakeLoader([
          () async => throw Exception('boom'),
          () async => _screen('recovered'),
        ]);
        await _pumpPage(tester, loader);
        await tester.pumpAndSettle();
        expect(find.textContaining('Failed to load'), findsOneWidget);

        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        expect(find.text('recovered'), findsOneWidget);
      });
    });
  });
}
