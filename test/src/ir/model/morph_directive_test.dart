import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/engine_spring.dart';

MorphDirective _morph({
  int? durationMs = 400,
  Object curve = 'ease_out',
  int delayMs = 0,
  bool repeat = false,
  bool reverse = false,
  EngineSpringSpec? spring,
  String to = 'x',
}) => MorphDirective(
  to: Expression.compile(to),
  as: 'v',
  child: const PlainDirective(
    type: 'text',
    props: {},
    children: [],
    roots: <String>{},
  ),
  path: 'test',
  durationMs: durationMs,
  curve: curve,
  delayMs: delayMs,
  repeat: repeat,
  reverse: reverse,
  spring: spring,
);

void main() {
  group('MorphDirective.sameTiming', () {
    test('타이밍 필드가 같으면 같은 애니메이션이다', () {
      expect(
        _morph(
          curve: [0.2, 0, 0, 1],
        ).sameTiming(_morph(curve: [0.2, 0, 0, 1], to: 'y')),
        isTrue,
      );
    });

    test('타이밍 필드 하나라도 다르면 다른 애니메이션이다', () {
      final base = _morph();
      for (final other in [
        _morph(durationMs: 300),
        _morph(durationMs: null),
        _morph(curve: 'linear'),
        _morph(curve: [0.2, 0, 0, 1]),
        _morph(repeat: true),
        _morph(reverse: true),
        _morph(spring: const EngineSpringSpec(stiffness: 1, dampingRatio: 1)),
      ]) {
        expect(base.sameTiming(other), isFalse);
      }
      expect(
        _morph(
          curve: [0.2, 0, 0, 1],
        ).sameTiming(_morph(curve: [0.2, 0, 0, 0.9])),
        isFalse,
      );
    });

    test('delay는 첫 실행에만 쓰이므로 비교하지 않는다', () {
      expect(_morph().sameTiming(_morph(delayMs: 200)), isTrue);
    });
  });
}
