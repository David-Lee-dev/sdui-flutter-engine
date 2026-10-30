import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/media/shader_registry.dart';
import 'package:sdui_engine/testing.dart';

final class _ImageSource implements ImageSource {
  @override
  ImageResult resolve(ImageRequest request) => const NoImage();
}

final class _VideoSource implements VideoSource {
  @override
  Future<SduiVideoController> controllerFor(VideoRequest request) =>
      throw UnimplementedError();
}

final class _AppStorage implements AppStorage {
  @override
  Object? get(String key) => null;
  @override
  Future<void> set(String key, Object? value) async {}
}

final class _SecureStorage implements SecureStorage {
  @override
  Future<String?> read(String key) async => null;
  @override
  Future<void> write(String key, String value) async {}
  @override
  Future<void> delete(String key) async {}
}

final class _NetworkClient implements NetworkClient {
  @override
  Future<NetworkResult> send(NetworkRequest request) async =>
      const NetworkResult();
}

final class _Loader implements ScreenLoader {
  @override
  Future<LoadedScreen> load(String screenId) async =>
      (template: <String, Object?>{}, modals: const <String, Object?>{});
}

void main() {
  setUp(ShaderRegistry.reset);
  tearDown(resetEngineForTest);

  group('ShaderRegistry', () {
    testWidgets('warmUp 전에는 쓸 수 없고, 뒤에는 SDF 프로그램을 준다', (tester) async {
      expect(ShaderRegistry.available, isFalse);
      expect(ShaderRegistry.sdfShapes.value, isNull);
      await tester.runAsync(ShaderRegistry.warmUp);
      expect(ShaderRegistry.available, isTrue);
      expect(ShaderRegistry.sdfShapes.value, isNotNull);
    });

    testWidgets('warmUp은 한 번만 불러온다', (tester) async {
      final first = ShaderRegistry.warmUp();
      expect(ShaderRegistry.warmUp(), same(first));
      await tester.runAsync(() => first);
      final program = ShaderRegistry.sdfShapes.value;
      await tester.runAsync(ShaderRegistry.warmUp);
      expect(ShaderRegistry.sdfShapes.value, same(program));
    });

    testWidgets('불러오면 sdfShapes 구독자에게 알린다', (tester) async {
      var notified = 0;
      void listener() => notified++;
      ShaderRegistry.sdfShapes.addListener(listener);
      addTearDown(() => ShaderRegistry.sdfShapes.removeListener(listener));
      await tester.runAsync(ShaderRegistry.warmUp);
      expect(notified, 1);
    });

    testWidgets('reset은 캐시를 비운다', (tester) async {
      await tester.runAsync(ShaderRegistry.warmUp);
      ShaderRegistry.reset();
      expect(ShaderRegistry.available, isFalse);
    });

    testWidgets('Sdui.initialize가 warm-up을 시작한다', (tester) async {
      Sdui.initialize(
        screenLoader: _Loader(),
        networkClient: _NetworkClient(),
        imageSource: _ImageSource(),
        videoSource: _VideoSource(),
        appStorage: _AppStorage(),
        secureStorage: _SecureStorage(),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      expect(ShaderRegistry.available, isTrue);
    });

    testWidgets('Engine.initialize만으로도 warm-up을 시작한다', (tester) async {
      Engine.initialize(
        networkClient: _NetworkClient(),
        imageSource: _ImageSource(),
        videoSource: _VideoSource(),
        appStorage: _AppStorage(),
        secureStorage: _SecureStorage(),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      expect(ShaderRegistry.available, isTrue);
    });

    testWidgets('Sdui.initialize도 warm-up을 한 번만 시작한다', (tester) async {
      Sdui.initialize(
        screenLoader: _Loader(),
        networkClient: _NetworkClient(),
        imageSource: _ImageSource(),
        videoSource: _VideoSource(),
        appStorage: _AppStorage(),
        secureStorage: _SecureStorage(),
      );
      final started = ShaderRegistry.warmUp();
      await tester.runAsync(() => started);
      final program = ShaderRegistry.sdfShapes.value;
      expect(program, isNotNull);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      expect(ShaderRegistry.sdfShapes.value, same(program));
    });
  });
}
