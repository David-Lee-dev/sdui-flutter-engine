import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_environment.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/driver/set_driver.dart';
import 'package:sdui_engine/src/runtime/log/logging_driver.dart';

/// 테스트용 driver — `Driver` 상속 + `type`·`run`만 채우면 끝이라는 것 자체가 구조의 증거.
class _EchoDriver extends Driver {
  const _EchoDriver();

  @override
  String get type => 'echo';

  @override
  Future<Object?> run(DriverContext ctx) async => ctx.params['value'];
}

/// 임의 type을 흉내내는 driver — 엔진 소유 type 잠금 검증용.
class _TypedDriver extends Driver {
  const _TypedDriver(this._type);
  final String _type;
  @override
  String get type => _type;
  @override
  Future<Object?> run(DriverContext ctx) async => null;
}

/// 'set' 이름을 가로채려는 driver — 등록이 거부돼야 한다.
class _FakeSetDriver extends Driver {
  const _FakeSetDriver();

  @override
  String get type => 'set';

  @override
  Future<Object?> run(DriverContext ctx) async => null;
}

void main() {
  group('DriverRegistry', () {
    // 전역 static이라 등록 뒤엔 되돌린다.
    tearDown(DriverRegistry.reset);

    test('register한 driver를 type으로 resolve한다', () {
      DriverRegistry.register(const _EchoDriver());
      final driver = DriverRegistry.resolve('echo');
      expect(driver, isA<LoggingDriver>());
      expect(driver.type, 'echo');
    });

    test('미등록 type은 StateError', () {
      expect(() => DriverRegistry.resolve('nope'), throwsStateError);
    });

    test('기본 제공 driver는 등록 없이 resolve된다', () {
      for (final type in const [
        'api',
        'sys_haptic',
        'app_storage',
        'secure_storage',
        'scroll',
        'navigate',
        'toast',
        'modal',
      ]) {
        expect(DriverRegistry.resolve(type), isA<LoggingDriver>());
      }
    });

    test('vendor driver는 기본 제공하지 않는다 — 앱이 service로 붙인다', () {
      expect(
        () => DriverRegistry.resolve('sys_channel_talk'),
        throwsStateError,
      );
    });

    test("'set' driver는 logging decorator로 감싸지 않는다", () {
      expect(DriverRegistry.resolve('set'), isA<SetDriver>());
    });

    test('엔진 소유 type은 전부 재등록 불가 — ArgumentError', () {
      for (final type in const ['navigate', 'toast', 'modal', 'scroll']) {
        expect(
          () => DriverRegistry.register(_TypedDriver(type)),
          throwsArgumentError,
          reason: type,
        );
      }
    });

    test('installEngineOwned는 엔진 소유 type만 받는다', () {
      expect(
        () => DriverRegistry.installEngineOwned(_TypedDriver('app_storage')),
        returnsNormally,
      );
      expect(
        () => DriverRegistry.installEngineOwned(_TypedDriver('echo')),
        throwsArgumentError,
      );
      expect(
        () => DriverRegistry.installEngineOwned(_TypedDriver('set')),
        throwsArgumentError,
      );
    });

    test("'set'은 엔진 소유 — 재등록은 ArgumentError (R4)", () {
      // validator가 set의 쓰기 의미를 컴파일 타임에 전제한다(쓰기 키 정적 검사).
      // 앱이 set을 다른 의미로 덮어쓰면 그 전제가 깨지므로 등록 자체를 거부한다.
      expect(
        () => DriverRegistry.register(const _FakeSetDriver()),
        throwsArgumentError,
      );
    });

    test('reset이 등록을 비운다', () {
      DriverRegistry.register(const _EchoDriver());
      DriverRegistry.reset();
      expect(() => DriverRegistry.resolve('echo'), throwsStateError);
    });

    test('resolve한 driver가 DriverContext의 params로 run된다', () async {
      DriverRegistry.register(const _EchoDriver());
      final result = await DriverRegistry.resolve('echo').run(
        DriverContext(
          params: const {'value': 42},
          state: ScopeEnvironment(const {}),
          isCancelled: () => false,
        ),
      );
      expect(result, 42);
    });
  });
}
