import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/driver/toast_driver.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/engine_host.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';

class _NoState implements StateWriter {
  @override
  void commit(Map<String, Object?> changes) {}
}

// 토스트 핸들을 마운트 host로 주입해 검증한다(전역 EngineToast 폐기 — 이제 EngineHost.toast).
ToastHandle? _toast;

DriverContext _ctx(Map<String, Object?> params) => DriverContext(
  params: params,
  state: _NoState(),
  isCancelled: () => false,
  host: _toast == null ? null : EngineHost(toast: _toast),
);

void main() {
  group('ToastDriver', () {
    String? message;
    String? variant;

    setUp(() {
      message = null;
      variant = null;
      _toast = ToastHandle((m, v) {
        message = m;
        variant = v;
      });
    });
    tearDown(() => _toast = null);

    group('run', () {
      test('message와 variant를 핸들로 넘긴다', () async {
        await const ToastDriver().run(
          _ctx({'message': '저장됐어요', 'variant': 'success'}),
        );
        expect(message, '저장됐어요');
        expect(variant, 'success');
      });

      test('variant 없으면 info 기본', () async {
        await const ToastDriver().run(_ctx({'message': 'hi'}));
        expect(variant, 'info');
      });

      test('잘못된 variant는 info로 폴백', () async {
        await const ToastDriver().run(
          _ctx({'message': 'hi', 'variant': 'nonsense'}),
        );
        expect(variant, 'info');
      });

      test('message 없으면 빈 문자열', () async {
        await const ToastDriver().run(_ctx(const {}));
        expect(message, '');
      });

      test('핸들 미연결이면 무동작', () async {
        _toast = null;
        expect(await const ToastDriver().run(_ctx({'message': 'x'})), isNull);
      });
    });
  });
}
