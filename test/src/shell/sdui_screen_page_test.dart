import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sdui_engine/src/contract/screen_loader.dart';
import 'package:sdui_engine/src/contract/telemetry_sink.dart';
import 'package:sdui_engine/src/runtime/telemetry/telemetry.dart';
import 'package:sdui_engine/src/contract/error_observer.dart';
import 'package:sdui_engine/src/presentation/presentation.dart';
import 'package:sdui_engine/src/runtime/engine_errors.dart';
import 'package:sdui_engine/src/runtime/engine_presentation.dart';
import 'package:sdui_engine/src/shell/screen_page.dart';

final class _FakeSink implements TelemetrySink {
  final List<TelemetryEvent> recorded = [];

  @override
  void record(TelemetryEvent event) => recorded.add(event);

  @override
  Future<TelemetryReservation> reserve(TelemetryEvent event) async =>
      _FakeReservation();
}

final class _FakeReservation implements TelemetryReservation {
  @override
  void complete({Map<String, Object?> properties = const {}}) {}
}

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
      testWidgets('load 실패는 전역 loadErrorBuilder로 떨어지고 옵저버에 보고된다', (
        tester,
      ) async {
        final errors = <SduiError>[];
        EngineErrors.observer = _RecordingObserver(errors.add);
        EnginePresentation.value = SduiPresentation(
          loadErrorBuilder: (context, error, retry) =>
              Text('global:$error', textDirection: TextDirection.ltr),
        );
        addTearDown(EngineErrors.reset);
        addTearDown(EnginePresentation.reset);

        await _pumpPage(
          tester,
          _FakeLoader([() async => throw StateError('down')]),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('global:'), findsOneWidget);
        expect(errors.single.scope, SduiErrorScope.screenLoad);
        expect(errors.single.screenId, 's');
      });

      testWidgets('issues a screen_view per successful load and renews on retry', (
        tester,
      ) async {
        final sink = _FakeSink();
        Telemetry.install(sink);
        addTearDown(Telemetry.reset);

        var fail = true;
        await _pumpPage(
          tester,
          _FakeLoader([
            () async => fail ? throw StateError('down') : _screen('ok'),
            () async => _screen('ok'),
          ]),
        );
        await tester.pumpAndSettle();

        // Failed load: no visit issued.
        final views = () => sink.recorded.where((e) => e.event == 'screen_view');
        expect(views(), isEmpty);

        fail = false;
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        // The visit is owned by the page: screen_view carries the screen id
        // and a fresh view id, before the engine mounts.
        final view = views().single;
        expect(view.screenId, 's');
        expect(view.screenViewId, isNotNull);
        expect(view.properties['surface_type'], 'screen');
        expect(find.text('ok'), findsOneWidget);
      });

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

final class _RecordingObserver extends SduiErrorObserver {
  const _RecordingObserver(this._add);
  final void Function(SduiError) _add;
  @override
  void onError(SduiError error) => _add(error);
}
