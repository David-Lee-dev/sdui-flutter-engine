import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_curve.dart';

void main() {
  test('지원하는 9개 이름을 같은 Curve로 해석한다', () {
    const expected = <String, Curve>{
      'linear': Curves.linear,
      'ease': Curves.ease,
      'ease_in': Curves.easeIn,
      'ease_out': Curves.easeOut,
      'ease_in_out': Curves.easeInOut,
      'fast_out_slow_in': Curves.fastOutSlowIn,
      'bounce_out': Curves.bounceOut,
      'elastic_out': Curves.elasticOut,
      'decelerate': Curves.decelerate,
    };

    for (final entry in expected.entries) {
      expect(EngineCurve.resolve(entry.key), entry.value, reason: entry.key);
    }
  });

  test('미지 이름과 null은 호출부 fallback을 따른다', () {
    expect(EngineCurve.resolve('unknown'), Curves.linear);
    expect(EngineCurve.resolve(null), Curves.linear);
    expect(
      EngineCurve.resolve('unknown', fallback: Curves.bounceIn),
      Curves.bounceIn,
    );
    expect(EngineCurve.resolve(null, fallback: Curves.easeIn), Curves.easeIn);
  });
}
