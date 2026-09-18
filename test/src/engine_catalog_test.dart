import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/engine_catalog.dart';
import 'package:sdui_engine/src/runtime/util/function_registry.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/runtime/media/asset_image_source.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';
import 'package:sdui_engine/src/runtime/media/asset_video_source.dart';
import 'package:sdui_engine/src/runtime/media/video_source_registry.dart';

class _D extends Driver {
  const _D();
  @override
  String get type => 'dummy';
  @override
  Future<Object?> run(DriverContext ctx) async => null;
}

/// EngineCatalog.freeze(⑥) — 부팅 후 카탈로그를 잠가 프로덕션 의미가 도중에 안 바뀌게 한다.
void main() {
  group('EngineCatalog.freeze (⑥)', () {
    tearDown(() {
      WidgetFactory.reset();
      DriverRegistry.reset();
      FunctionRegistry.reset();
      ImageSourceRegistry.reset();
      VideoSourceRegistry.reset();
    });

    test('freeze 뒤 위젯·driver·function·image source register는 던진다', () {
      EngineCatalog.freeze();
      expect(
        () => WidgetFactory.register(
          'x',
          EagerSpec((c, p, ch) => const SizedBox()),
        ),
        throwsStateError,
      );
      expect(() => DriverRegistry.register(const _D()), throwsStateError);
      expect(
        () => FunctionRegistry.register('f', (a) => null),
        throwsStateError,
      );
      expect(
        () => ImageSourceRegistry.install(const AssetImageSource()),
        throwsStateError,
      );
      expect(
        () => VideoSourceRegistry.install(const AssetVideoSource()),
        throwsStateError,
      );
    });

    test('reset이 freeze를 푼다 (테스트 격리)', () {
      EngineCatalog.freeze();
      WidgetFactory.reset();
      expect(
        () => WidgetFactory.register(
          'x',
          EagerSpec((c, p, ch) => const SizedBox()),
        ),
        returnsNormally,
      );
    });
  });
}
