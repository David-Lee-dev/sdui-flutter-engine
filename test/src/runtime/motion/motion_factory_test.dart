import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/blur.dart';
import 'package:sdui_engine/src/runtime/motion/atom/reveal.dart';
import 'package:sdui_engine/src/runtime/motion/atom/saturate.dart';
import 'package:sdui_engine/src/runtime/motion/atom/shimmer.dart';
import 'package:sdui_engine/src/runtime/motion/atom/tint.dart';
import 'package:sdui_engine/src/runtime/motion/motion_factory.dart';

/// 테스트용 motion — `Motion` 상속 + type·plan·frame만 채우면 찍힌다는 것 자체가 구조의 증거.
class _TagMotion extends Motion {
  const _TagMotion();

  @override
  String get type => 'tag';

  @override
  MotionPlan plan(MotionParams params) =>
      const MotionPlan(duration: Duration(milliseconds: 100));

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) =>
      child;
}

void main() {
  group('MotionFactory', () {
    tearDown(MotionFactory.reset);

    test('register한 motion을 type으로 resolve한다', () {
      MotionFactory.register(const _TagMotion());
      expect(MotionFactory.resolve('tag'), isA<_TagMotion>());
    });

    test('미등록 type은 StateError', () {
      expect(() => MotionFactory.resolve('nope'), throwsStateError);
    });

    test('reset이 등록을 빌트인만 남긴다', () {
      MotionFactory.register(const _TagMotion());
      MotionFactory.reset();
      expect(() => MotionFactory.resolve('tag'), throwsStateError);
    });

    test('clip·color·blur·mask ATOM 5종이 빌트인으로 등록돼 있다', () {
      expect(MotionFactory.resolve('reveal'), isA<RevealMotion>());
      expect(MotionFactory.resolve('tint'), isA<TintMotion>());
      expect(MotionFactory.resolve('blur'), isA<BlurMotion>());
      expect(MotionFactory.resolve('shimmer'), isA<ShimmerMotion>());
      expect(MotionFactory.resolve('saturate'), isA<SaturateMotion>());
    });
  });
}
