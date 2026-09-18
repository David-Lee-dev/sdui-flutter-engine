import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/schema/widget_schema.dart';
import 'package:sdui_engine/src/dependency/image_source.dart';
import 'package:sdui_engine/src/dependency/app_storage.dart';
import 'package:sdui_engine/src/dependency/secure_storage.dart';
import 'package:sdui_engine/src/dependency/video_source.dart';
import 'package:sdui_engine/src/contract/external_command.dart';
import 'package:sdui_engine/src/dependency/network_client.dart';
import 'package:sdui_engine/src/engine.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';
import 'package:sdui_engine/src/runtime/media/video_source_registry.dart';
import 'package:sdui_engine/src/runtime/motion/motion_factory.dart';
import 'package:sdui_engine/src/runtime/util/function_registry.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:video_player/video_player.dart';

class _ImageSource implements ImageSource {
  const _ImageSource();

  @override
  ImageResult resolve(ImageRequest request) => const NoImage();
}

class _VideoSource implements VideoSource {
  const _VideoSource();

  @override
  Future<VideoPlayerController> controllerFor(VideoRequest request) =>
      throw UnimplementedError();
}

class _AppStorage implements AppStorage {
  final Map<String, Object?> _values = {};

  @override
  Object? get(String key) => _values[key];

  @override
  Future<void> set(String key, Object? value) async => _values[key] = value;
}

class _SecureStorage implements SecureStorage {
  @override
  Future<void> delete(String key) async {}

  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> write(String key, String value) async {}
}

class _InjectedCommand implements ExternalCommand {
  @override
  String get type => 'injected';

  @override
  Future<Object?> run(CommandInvocation invocation) async => null;
}

class _NetworkClient implements NetworkClient {
  const _NetworkClient();

  @override
  Future<NetworkResult> send(NetworkRequest request) async =>
      const NetworkResult();
}

void main() {
  group('Engine', () {
    tearDown(() {
      WidgetFactory.reset();
      WidgetSchemaRegistry.reset();
      DriverRegistry.reset();
      FunctionRegistry.reset();
      MotionFactory.reset();
      ImageSourceRegistry.reset();
      VideoSourceRegistry.reset();
    });

    group('initialize', () {
      test('전달한 external command를 freeze 전에 등록해 resolve할 수 있다', () {
        Engine.initialize(
          networkClient: const _NetworkClient(),
          imageSource: const _ImageSource(),
          videoSource: const _VideoSource(),
          appStorage: _AppStorage(),
          secureStorage: _SecureStorage(),
          externalCommands: [_InjectedCommand()],
        );

        expect(DriverRegistry.resolve('injected').type, 'injected');
      });

      test('앱이 넘긴 위젯을 freeze 전에 등록해 템플릿이 그 _type을 쓸 수 있다', () {
        Engine.initialize(
          networkClient: const _NetworkClient(),
          imageSource: const _ImageSource(),
          videoSource: const _VideoSource(),
          appStorage: _AppStorage(),
          secureStorage: _SecureStorage(),
          widgets: {
            'app_owned': EagerSpec(
              (context, props, children) => const SizedBox.shrink(),
            ),
          },
        );

        expect(WidgetFactory.knows('app_owned'), isTrue);
        // 컴파일 검증도 같은 등록에서 스키마를 얻어야 한다 — 하나만 되면 기기에서 터진다.
        expect(WidgetSchemaRegistry.schemaFor('app_owned'), isNotNull);
      });
    });
  });
}
