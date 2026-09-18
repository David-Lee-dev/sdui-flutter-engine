import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/driver/navigate_driver.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/engine_host.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';

class _NoState implements StateWriter {
  @override
  void commit(Map<String, Object?> changes) {}
}

// 라우터 핸들을 마운트 host로 주입해 검증한다(전역 EngineRouter 폐기 — 이제 EngineHost.navigate).
NavigateHandle? _navigate;

DriverContext _ctx(Map<String, Object?> params) => DriverContext(
  params: params,
  state: _NoState(),
  isCancelled: () => false,
  host: _navigate == null ? null : EngineHost(navigate: _navigate),
);

void main() {
  group('NavigateDriver', () {
    final calls = <String>[];
    Object? pushResult;

    setUp(() {
      calls.clear();
      pushResult = null;
      _navigate = NavigateHandle(
        push: (loc) async {
          calls.add('push:$loc');
          return pushResult;
        },
        go: (loc) => calls.add('go:$loc'),
        pop: ([r]) => calls.add('pop:$r'),
      );
    });
    tearDown(() => _navigate = null);

    group('run', () {
      test('기본 method는 push', () async {
        await const NavigateDriver().run(_ctx({'route': '/detail'}));
        expect(calls, ['push:/detail']);
      });

      test('push는 화면 결과를 \$data로 반환한다', () async {
        pushResult = {'picked': 7};
        final result = await const NavigateDriver().run(
          _ctx({'method': 'push', 'route': '/pick'}),
        );
        expect(result, {'picked': 7});
      });

      test('go는 스택을 치환한다', () async {
        await const NavigateDriver().run(
          _ctx({'method': 'go', 'route': '/home'}),
        );
        expect(calls, ['go:/home']);
      });

      test('pop은 result를 넘긴다', () async {
        await const NavigateDriver().run(
          _ctx({'method': 'pop', 'result': 'ok'}),
        );
        expect(calls, ['pop:ok']);
      });

      test('라우터 미연결이면 무동작', () async {
        _navigate = null;
        expect(await const NavigateDriver().run(_ctx({'route': '/x'})), isNull);
      });

      test('push/go에 route 없으면 throw', () async {
        await expectLater(
          const NavigateDriver().run(_ctx({'method': 'push'})),
          throwsArgumentError,
        );
      });

      test('미지 method는 throw', () async {
        await expectLater(
          const NavigateDriver().run(
            _ctx({'method': 'teleport', 'route': '/x'}),
          ),
          throwsArgumentError,
        );
      });
    });
  });
}
