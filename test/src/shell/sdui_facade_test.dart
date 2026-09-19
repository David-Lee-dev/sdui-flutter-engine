import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sdui_engine/testing.dart';

final class _FakeImageSource implements ImageSource {
  @override
  ImageResult resolve(ImageRequest request) => const NoImage();
}

final class _FakeVideoSource implements VideoSource {
  @override
  Future<SduiVideoController> controllerFor(VideoRequest request) =>
      throw UnimplementedError();
}

final class _FakeAppStorage implements AppStorage {
  final _values = <String, Object?>{};
  @override
  Object? get(String key) => _values[key];
  @override
  Future<void> set(String key, Object? value) async => _values[key] = value;
}

final class _FakeSecureStorage implements SecureStorage {
  @override
  Future<String?> read(String key) async => null;
  @override
  Future<void> write(String key, String value) async {}
  @override
  Future<void> delete(String key) async {}
}

final class _FakeNetworkClient implements NetworkClient {
  @override
  Future<NetworkResult> send(NetworkRequest request) async =>
      const NetworkResult();
}

final class _FakeService extends SduiService {
  int registered = 0;

  @override
  List<ExternalCommand> get commands => [_FakeServiceCommand()];

  @override
  void onRegister() => registered += 1;
}

final class _FakeServiceCommand extends ExternalCommand {
  @override
  String get type => 'fake_service_cmd';

  @override
  Future<Object?> run(CommandInvocation invocation) async => null;
}

final class _FakeLoader implements ScreenLoader {
  final requested = <String>[];

  @override
  Future<LoadedScreen> load(String screenId) async {
    requested.add(screenId);
    return (
      template: <String, Object?>{'_type': 'text', 'value': 'screen:$screenId'},
      modals: const <String, Object?>{},
    );
  }
}

void main() {
  tearDown(resetEngineForTest);

  group('Sdui', () {
    group('initialize', () {
      test('required seams are kept; the rest defaults', () {
        final loader = _FakeLoader();
        Sdui.initialize(
          screenLoader: loader,
          networkClient: _FakeNetworkClient(),
          imageSource: _FakeImageSource(),
          videoSource: _FakeVideoSource(),
          appStorage: _FakeAppStorage(),
          secureStorage: _FakeSecureStorage(),
        );
        expect(Sdui.screenLoader, same(loader));
        // Default system drivers and the api command register automatically.
        expect(DriverRegistry.knows('sys_haptic'), isTrue);
        expect(DriverRegistry.knows('net'), isTrue);
      });

      test('screenLoader before initialize throws', () {
        expect(() => Sdui.screenLoader, throwsStateError);
      });
    });

    group('services', () {
      test('registers service commands and runs onRegister once', () {
        final service = _FakeService();
        Sdui.initialize(
          screenLoader: _FakeLoader(),
          networkClient: _FakeNetworkClient(),
          imageSource: _FakeImageSource(),
          videoSource: _FakeVideoSource(),
          appStorage: _FakeAppStorage(),
          secureStorage: _FakeSecureStorage(),
          services: [service],
        );
        expect(service.registered, 1);
        expect(DriverRegistry.knows('fake_service_cmd'), isTrue);
        // The data plane rides the same path: 'net' is a service command now.
        expect(DriverRegistry.knows('net'), isTrue);
      });
    });

    group('telemetryEnabled', () {
      test('toggles delivery at runtime and defaults to on', () {
        expect(Sdui.telemetryEnabled, isTrue);
        Sdui.telemetryEnabled = false;
        expect(Sdui.telemetryEnabled, isFalse);
        Sdui.telemetryEnabled = true;
        expect(Sdui.telemetryEnabled, isTrue);
      });
    });

    group('router', () {
      testWidgets('serves any screen id via the generic route '
          'and forwards query params', (tester) async {
        final loader = _FakeLoader();
        Sdui.initialize(
          screenLoader: loader,
          networkClient: _FakeNetworkClient(),
          imageSource: _FakeImageSource(),
          videoSource: _FakeVideoSource(),
          appStorage: _FakeAppStorage(),
          secureStorage: _FakeSecureStorage(),
        );

        final router = Sdui.router(initialLocation: '/screens/home?tab=a');
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('screen:home'), findsOneWidget);
        expect(loader.requested, ['home']);
        final page = tester.widget<SduiScreenPage>(
          find.byType(SduiScreenPage),
        );
        expect(page.params, {'tab': 'a'});
      });

      testWidgets('app routes are matched before the generic route', (
        tester,
      ) async {
        Sdui.initialize(
          screenLoader: _FakeLoader(),
          networkClient: _FakeNetworkClient(),
          imageSource: _FakeImageSource(),
          videoSource: _FakeVideoSource(),
          appStorage: _FakeAppStorage(),
          secureStorage: _FakeSecureStorage(),
        );
        final router = Sdui.router(
          initialLocation: '/native',
          routes: [
            GoRoute(
              path: '/native',
              builder: (context, state) => const Text(
                'native-page',
                textDirection: TextDirection.ltr,
              ),
            ),
          ],
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();
        expect(find.text('native-page'), findsOneWidget);
      });
    });
  });
}
