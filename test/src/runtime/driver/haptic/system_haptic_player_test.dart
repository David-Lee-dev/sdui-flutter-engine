import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/driver/haptic/haptic_driver.dart';

const _channel = MethodChannel('sdui_engine/haptic');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(_channel, null));

  group('SystemHapticPlayer', () {
    group('supportsTaps', () {
      test('기기에 한 번만 묻고 답을 기억한다', () async {
        var asked = 0;
        messenger.setMockMethodCallHandler(_channel, (call) async {
          if (call.method == 'isSupported') asked++;
          return true;
        });
        final player = SystemHapticPlayer();

        expect(await player.supportsTaps(), isTrue);
        expect(await player.supportsTaps(), isTrue);
        expect(await player.supportsTaps(), isTrue);
        expect(asked, 1);
      });

      test('플랫폼 오류는 미지원', () async {
        messenger.setMockMethodCallHandler(
          _channel,
          (call) async => throw PlatformException(code: 'boom'),
        );

        expect(await SystemHapticPlayer().supportsTaps(), isFalse);
      });

      test('plugin이 없으면(MissingPluginException) 미지원', () async {
        expect(await SystemHapticPlayer().supportsTaps(), isFalse);
      });
    });

    group('supportsContinuous', () {
      test('isContinuousSupported를 한 번만 묻고 답을 기억한다', () async {
        var asked = 0;
        messenger.setMockMethodCallHandler(_channel, (call) async {
          if (call.method == 'isContinuousSupported') asked++;
          return true;
        });
        final player = SystemHapticPlayer();

        expect(await player.supportsContinuous(), isTrue);
        expect(await player.supportsContinuous(), isTrue);
        expect(asked, 1);
      });

      test('플랫폼 오류는 미지원', () async {
        messenger.setMockMethodCallHandler(
          _channel,
          (call) async => throw PlatformException(code: 'boom'),
        );

        expect(await SystemHapticPlayer().supportsContinuous(), isFalse);
      });

      test('plugin이 없으면(MissingPluginException) 미지원', () async {
        expect(await SystemHapticPlayer().supportsContinuous(), isFalse);
      });
    });

    test('play는 tap 절대 시각과 두 곡선을 채널로 보낸다', () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(_channel, (call) async {
        calls.add(call);
        return null;
      });

      await SystemHapticPlayer().play(
        const HapticPattern(
          taps: [
            HapticPulse(intensity: 1, sharpness: 0.15),
            HapticPulse(
              intensity: 0.5,
              sharpness: 0.2,
              delay: Duration(milliseconds: 80),
            ),
            HapticPulse(
              intensity: 0.3,
              sharpness: 0.4,
              delay: Duration(milliseconds: 20),
            ),
          ],
          intensity: [(0, 0.0), (5, 1.0), (500, 0.0)],
          sharpness: [(0, 0.12), (500, 0.08)],
        ),
      );

      expect(calls.single.method, 'play');
      expect(calls.single.arguments, {
        'taps': [
          [0, 1, 0.15],
          [80, 0.5, 0.2],
          [100, 0.3, 0.4],
        ],
        'intensity': [
          [0, 0.0],
          [5, 1.0],
          [500, 0.0],
        ],
        'sharpness': [
          [0, 0.12],
          [500, 0.08],
        ],
      });
    });

    test('stop은 stop을 채널로 보낸다', () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(_channel, (call) async {
        calls.add(call);
        return null;
      });

      await SystemHapticPlayer().stop();

      expect(calls.single.method, 'stop');
    });

    test('tap은 세기와 날카로움을 채널로 보낸다', () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(_channel, (call) async {
        calls.add(call);
        return null;
      });

      await SystemHapticPlayer().tap(0.4, 0.7);

      expect(calls.single.method, 'tap');
      expect(calls.single.arguments, {'intensity': 0.4, 'sharpness': 0.7});
    });
  });
}
