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
        containsAll(['platform', 'none', 'fade', 'slide_up', 'zoom']),
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
      const Duration(milliseconds: 150),
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

  for (final (type, key, defaultBegin, customBegin) in [
    ('slide_up', 'distance', 0.08, 0.4),
    ('zoom', 'begin_scale', 0.94, 0.6),
  ]) {
    test('$type default and overridden durations', () {
      final effect = PageTransitionFactory.resolve(type);
      expect(
        effect.duration(PageTransitionSpec(type: type)),
        const Duration(milliseconds: 200),
      );
      expect(
        effect.reverseDuration(PageTransitionSpec(type: type)),
        const Duration(milliseconds: 160),
      );
      final spec = PageTransitionSpec(
        type: type,
        durationMs: 420,
        reverseDurationMs: 310,
      );
      expect(effect.duration(spec), const Duration(milliseconds: 420));
      expect(effect.reverseDuration(spec), const Duration(milliseconds: 310));
    });
    for (final custom in [false, true]) {
      testWidgets(
        '$type ${custom ? "custom" : "default"} push and pop geometry',
        (tester) async {
          final controller = AnimationController(
            vsync: tester,
            duration: const Duration(milliseconds: 280),
            reverseDuration: const Duration(milliseconds: 220),
          );
          addTearDown(controller.dispose);
          const childKey = ValueKey('geometry');
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 100,
                  child: Builder(
                    builder: (context) =>
                        PageTransitionFactory.resolve(type).build(
                          context,
                          controller,
                          const AlwaysStoppedAnimation(0),
                          const SizedBox.expand(key: childKey),
                          PageTransitionSpec(
                            type: type,
                            params: custom ? {key: customBegin} : const {},
                          ),
                        ),
                  ),
                ),
              ),
            ),
          );
          final begin = custom ? customBegin : defaultBegin;
          for (final reverse in [false, true]) {
            controller.value = reverse ? 1 : 0;
            if (reverse) {
              controller.reverse();
            } else {
              controller.forward();
            }
            await tester.pump();
            for (final t in reverse ? [1.0, 0.5, 0.0] : [0.0, 0.5, 1.0]) {
              if (t == 0.5 || (reverse ? t == 0 : t == 1)) {
                await tester.pump(Duration(milliseconds: reverse ? 110 : 140));
              }
              expect(controller.value, closeTo(t, 1e-6));
              final fade = tester.widget<FadeTransition>(
                find.byType(FadeTransition),
              );
              expect(fade.opacity.value, closeTo(t, 1e-6));
              final render = tester.renderObject<RenderBox>(
                find.byKey(childKey),
              );
              if (type == 'slide_up') {
                // SlideTransition's parent transform includes the fractional offset.
                final slide = tester.widget<SlideTransition>(
                  find.byType(SlideTransition),
                );
                expect(slide.position.value.dy, closeTo(begin * (1 - t), 1e-6));
                final origin = tester.getTopLeft(find.byType(SizedBox).first);
                expect(
                  tester.getTopLeft(find.byKey(childKey)).dy - origin.dy,
                  closeTo(100 * begin * (1 - t), 1e-6),
                );
              } else {
                final scale = tester.widget<ScaleTransition>(
                  find.byType(ScaleTransition),
                );
                expect(
                  scale.scale.value,
                  closeTo(begin + (1 - begin) * t, 1e-6),
                );
                final matrix = render.getTransformTo(null);
                expect(
                  matrix.entry(0, 0),
                  closeTo(begin + (1 - begin) * t, 1e-6),
                );
              }
            }
            controller.stop();
          }
        },
      );
    }
  }

  test('base duration is 200ms and fade reverse is 120ms', () {
    final custom = const _TagTransition('custom');
    final spec = PageTransitionSpec(type: 'custom');
    expect(custom.duration(spec), const Duration(milliseconds: 200));
    expect(custom.reverseDuration(spec), const Duration(milliseconds: 200));
    expect(
      PageTransitionFactory.resolve(
        'fade',
      ).reverseDuration(PageTransitionSpec(type: 'fade')),
      const Duration(milliseconds: 120),
    );
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
