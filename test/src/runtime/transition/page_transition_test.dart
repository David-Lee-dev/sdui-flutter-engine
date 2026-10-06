import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/engine_curve.dart';
import 'package:sdui_engine/src/ir/model/page_transition.dart';
import 'package:sdui_engine/src/runtime/transition/_base.dart';
import 'package:sdui_engine/src/runtime/transition/transition_factory.dart';
import 'package:sdui_engine/src/runtime/util/engine_curve.dart';
import 'package:sdui_engine/src/presentation/presentation.dart';

final class _TagTransition extends PageTransitionEffect {
  const _TagTransition(this.type);
  @override
  final String type;
  @override
  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  ) => child;
}

void main() {
  tearDown(PageTransitionFactory.reset);

  test(
    'factory has builtins, registers, freezes, resets, and rejects unknowns',
    () {
      expect(
        PageTransitionFactory.types(),
        containsAll(['platform', 'none', 'fade']),
      );
      PageTransitionFactory.register(const _TagTransition('tag'));
      PageTransitionFactory.registerAll([const _TagTransition('other')]);
      expect(PageTransitionFactory.resolve('tag'), isA<_TagTransition>());
      PageTransitionFactory.freeze();
      expect(
        () => PageTransitionFactory.register(const _TagTransition('late')),
        throwsStateError,
      );
      PageTransitionFactory.reset();
      expect(() => PageTransitionFactory.resolve('tag'), throwsStateError);
      expect(() => PageTransitionFactory.resolve('missing'), throwsStateError);
      expect(
        () => PageTransitionFactory.register(const _TagTransition('again')),
        returnsNormally,
      );
    },
  );

  testWidgets('effects resolve duration and fade uses the supplied animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Placeholder(),
      ),
    );
    final fade = PageTransitionFactory.resolve('fade');
    final none = PageTransitionFactory.resolve('none');
    final spec = PageTransitionSpec(
      type: 'fade',
      durationMs: 120,
      reverseDurationMs: 80,
    );
    expect(
      fade.duration(PageTransitionSpec(type: 'fade')),
      const Duration(milliseconds: 300),
    );
    expect(fade.duration(spec), const Duration(milliseconds: 120));
    expect(fade.reverseDuration(spec), const Duration(milliseconds: 80));
    expect(none.duration(PageTransitionSpec(type: 'none')), Duration.zero);
    expect(
      none.reverseDuration(PageTransitionSpec(type: 'none')),
      Duration.zero,
    );

    final controller = AnimationController(
      vsync: tester,
      duration: const Duration(milliseconds: 1),
    );
    addTearDown(controller.dispose);
    final child = fade.build(
      tester.element(find.byType(Placeholder)),
      controller,
      const AlwaysStoppedAnimation(0),
      const Text('fade'),
      PageTransitionSpec(type: 'fade'),
    );
    expect(child, isA<FadeTransition>());
    expect((child as FadeTransition).opacity, same(controller));
  });

  test('compile-side curves resolve at runtime', () {
    const sentinel = _SentinelCurve();
    for (final name in EngineCurveNames.all) {
      expect(
        EngineCurve.resolve(name, fallback: sentinel),
        isNot(same(sentinel)),
      );
    }
  });

  test('presentation transition defaults are conservative', () {
    final style = const SduiPresentation().transitions;
    expect(style.enabled, isFalse);
    expect(style.defaultType, 'platform');
    expect(style.preloadTimeout, const Duration(milliseconds: 300));
    expect(style.respectReducedMotion, isTrue);
  });
}

final class _SentinelCurve extends Curve {
  const _SentinelCurve();
  @override
  double transformInternal(double t) => t;
}
