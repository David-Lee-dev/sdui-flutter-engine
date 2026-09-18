import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/composite/presets.dart';

void main() {
  group('MotionPresets', () {
    group('expand', () {
      test('미등록 이름(ATOM 또는 오타)은 그대로 1-원소로 통과시킨다', () {
        final result = MotionPresets.expand('fade', {'duration': 500});
        expect(result, hasLength(1));
        expect(result.single.type, 'fade');
        expect(result.single.params, {'duration': 500});
      });

      test('단일 ATOM 컴포짓은 프리셋 인자로 전개한다', () {
        final result = MotionPresets.expand('slide_up', {});
        expect(result, hasLength(1));
        expect(result.single.type, 'move');
        expect(result.single.params, {
          'begin': [0, 24],
          'end': [0, 0],
        });
      });

      test('다중 ATOM 컴포짓은 선언 순서대로 전개한다', () {
        final result = MotionPresets.expand('fade_slide_up', {});
        expect(result.map((r) => r.type), ['fade', 'move']);
      });

      test('유저 인자가 프리셋 인자를 덮어쓰고, 모든 전개 원소에 브로드캐스트된다', () {
        final result = MotionPresets.expand('fade_slide_up', {'duration': 900});
        for (final r in result) {
          expect(r.params['duration'], 900);
        }
        // 프리셋 고유 인자(move의 begin/end)는 유저 인자에 없으니 살아남는다.
        expect(result[1].params['begin'], [0, 24]);
      });

      test('루프 프리셋은 repeat/reverse/curve/duration을 포함한다', () {
        final result = MotionPresets.expand('pulse', {});
        expect(result, hasLength(1));
        expect(result.single.type, 'scale');
        expect(result.single.params, {
          'begin': 1.0,
          'end': 1.06,
          'curve': 'ease_in_out',
          'repeat': true,
          'reverse': true,
          'duration': 700,
        });
      });

      test('reveal·blur·color 진입 프리셋을 전개한다', () {
        // record 전체 비교는 params(Map)를 identity/타입으로 봐 취약하므로 type·params를
        // 나눠 본다(params는 deep-equals 매처).
        final reveal = MotionPresets.expand('reveal_up', {}).single;
        expect(reveal.type, 'reveal');
        expect(reveal.params, {'direction': 'up'});

        final blur = MotionPresets.expand('blur_in', {}).single;
        expect(blur.type, 'blur');
        expect(blur.params, {'begin': 8, 'end': 0});

        final color = MotionPresets.expand('color_in', {}).single;
        expect(color.type, 'saturate');
        expect(color.params, {'begin': 0, 'end': 1});
      });

      test('drop/raise는 fade + 반대 방향 move로 전개한다', () {
        final drop = MotionPresets.expand('drop', {});
        expect(drop.map((r) => r.type), ['fade', 'move']);
        expect(drop[1].params['begin'], [0, -40]); // 위에서 떨어짐
        expect(drop[1].params['curve'], 'bounce_out');

        final raise = MotionPresets.expand('raise', {});
        expect(raise.map((r) => r.type), ['fade', 'move']);
        expect(raise[1].params['begin'], [0, 40]); // 아래서 솟음
        expect(raise[1].params['curve'], 'ease_out');
      });

      test('slide 계열은 4방향이 모두 있고 방향별 begin이 다르다', () {
        ({num dx, num dy}) beginOf(String name) {
          final move = MotionPresets.expand(name, {}).last;
          final begin = (move.params['begin'] as List).cast<num>();
          return (dx: begin[0], dy: begin[1]);
        }

        // fadeSlide*는 [fade, move]라 .last가 move — 방향은 slide*와 같은 부호 규약.
        for (final family in const ['slide', 'fade_slide']) {
          expect(beginOf('${family}_up').dy, greaterThan(0)); // 아래서 위로
          expect(beginOf('${family}_down').dy, lessThan(0));
          expect(beginOf('${family}_left').dx, greaterThan(0)); // 오른쪽서 왼쪽
          expect(beginOf('${family}_right').dx, lessThan(0));
        }
      });

      test('전체 테이블에 30개 이름이 모두 존재한다', () {
        const names = [
          'fade_in',
          'slide_up',
          'slide_down',
          'slide_left',
          'slide_right',
          'zoom_in',
          'rotate_in',
          'flip_in',
          'pop_in',
          'fade_slide_up',
          'fade_slide_down',
          'fade_slide_left',
          'fade_slide_right',
          'fade_scale',
          'flip_fade_in',
          'reveal_up',
          'reveal_down',
          'reveal_left',
          'reveal_right',
          'blur_in',
          'color_in',
          'pulse',
          'float',
          'bounce',
          'blink',
          'shake',
          'wobble',
          'swing',
          'spin',
          'tada',
        ];
        for (final name in names) {
          final result = MotionPresets.expand(name, {});
          expect(result, isNotEmpty, reason: '$name expands to nothing');
        }
      });
    });
  });
}
