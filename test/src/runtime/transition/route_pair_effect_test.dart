import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/page_transition.dart';
import 'package:sdui_engine/src/runtime/transition/transition_factory.dart';

void main() {
  for (final type in ['fade_through', 'shared_axis']) {
    test('$type defaults to 220ms push and 180ms pop', () {
      final effect = PageTransitionFactory.resolve(type);
      final spec = PageTransitionSpec(type: type);
      expect(effect.duration(spec), const Duration(milliseconds: 220));
      expect(effect.reverseDuration(spec), const Duration(milliseconds: 180));
    });
  }

  for (final (type, axis) in [
    ('fade_through', 'x'),
    ('shared_axis', 'x'),
    ('shared_axis', 'y'),
    ('shared_axis', 'z'),
  ]) {
    for (final custom in [false, true]) {
      for (final rtl in [false, true]) {
        testWidgets('$type $axis custom=$custom rtl=$rtl push/pop halves', (
          tester,
        ) async {
          final effect = PageTransitionFactory.resolve(type);
          final threshold = custom ? 0.6 : 0.35;
          final distance = custom ? 80.0 : 30.0;
          final spec = PageTransitionSpec(
            type: type,
            params: type == 'fade_through'
                ? (custom ? {'threshold': threshold} : {})
                : {'axis': axis, if (custom) 'distance': distance},
          );
          final controller = AnimationController(
            vsync: tester,
            duration: const Duration(milliseconds: 1000),
          );
          addTearDown(controller.dispose);
          const incomingKey = ValueKey('incoming');
          const outgoingKey = ValueKey('outgoing');
          await tester.pumpWidget(
            Directionality(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 100,
                  child: Builder(
                    builder: (context) => Stack(
                      fit: StackFit.expand,
                      children: [
                        effect.buildOutgoing(
                          context,
                          controller,
                          const SizedBox.expand(key: outgoingKey),
                          spec,
                        )!,
                        effect.build(
                          context,
                          controller,
                          const AlwaysStoppedAnimation(0),
                          const SizedBox.expand(key: incomingKey),
                          spec,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          final origin = tester.getTopLeft(find.byType(Stack));
          for (final reverse in [false, true]) {
            controller.value = reverse ? 1 : 0;
            reverse ? controller.reverse() : controller.forward();
            await tester.pump();
            final times = <double>{0, 0.35, 0.5, threshold, 1}.toList()..sort();
            final ordered = reverse ? times.reversed.toList() : times;
            var previous = ordered.first;
            for (final t in ordered) {
              await tester.pump(
                Duration(milliseconds: ((t - previous).abs() * 1000).round()),
              );
              previous = t;
              expect(controller.value, closeTo(t, 1e-6));
              double opacity(Key key) => tester
                  .widget<FadeTransition>(
                    find
                        .ancestor(
                          of: find.byKey(key),
                          matching: find.byType(FadeTransition),
                        )
                        .first,
                  )
                  .opacity
                  .value;
              final incoming = type == 'fade_through'
                  ? ((t - threshold) / (1 - threshold)).clamp(0.0, 1.0)
                  : t;
              final outgoing = type == 'fade_through'
                  ? 1 - (t / threshold).clamp(0.0, 1.0)
                  : 1 - t;
              expect(opacity(incomingKey), closeTo(incoming, 1e-6));
              expect(opacity(outgoingKey), closeTo(outgoing, 1e-6));
              final incomingBox = tester.renderObject<RenderBox>(
                find.byKey(incomingKey),
              );
              final outgoingBox = tester.renderObject<RenderBox>(
                find.byKey(outgoingKey),
              );
              if (type == 'fade_through' || axis == 'z') {
                expect(
                  incomingBox.getTransformTo(null).entry(0, 0),
                  closeTo(
                    type == 'fade_through'
                        ? 0.92 + 0.08 * incoming
                        : 0.8 + 0.2 * t,
                    1e-6,
                  ),
                );
                expect(
                  outgoingBox.getTransformTo(null).entry(0, 0),
                  closeTo(
                    axis == 'z' && type == 'shared_axis' ? 1 + 0.1 * t : 1,
                    1e-6,
                  ),
                );
              } else {
                final direction = rtl && axis == 'x' ? -1 : 1;
                final enter =
                    tester.getTopLeft(find.byKey(incomingKey)) - origin;
                final exit =
                    tester.getTopLeft(find.byKey(outgoingKey)) - origin;
                expect(
                  enter.dx,
                  closeTo(
                    axis == 'x' ? direction * distance * (1 - t) : 0,
                    1e-6,
                  ),
                );
                expect(
                  enter.dy,
                  closeTo(axis == 'y' ? distance * (1 - t) : 0, 1e-6),
                );
                expect(
                  exit.dx,
                  closeTo(axis == 'x' ? -direction * distance * t : 0, 1e-6),
                );
                expect(exit.dy, closeTo(axis == 'y' ? -distance * t : 0, 1e-6));
              }
            }
            controller.stop();
          }
        });
      }
    }
  }

  for (final threshold in [0.0, 1.0]) {
    testWidgets('fade_through threshold endpoint $threshold stays finite', (
      tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Placeholder(),
        ),
      );
      final context = tester.element(find.byType(Placeholder));
      final effect = PageTransitionFactory.resolve('fade_through');
      final spec = PageTransitionSpec(
        type: 'fade_through',
        params: {'threshold': threshold},
      );
      for (final t in [0.0, 0.35, 0.5, 1.0]) {
        final animation = AlwaysStoppedAnimation(t);
        final enter =
            effect.build(
                  context,
                  animation,
                  const AlwaysStoppedAnimation(0),
                  const Placeholder(),
                  spec,
                )
                as FadeTransition;
        final exit =
            effect.buildOutgoing(context, animation, const Placeholder(), spec)
                as FadeTransition;
        expect(enter.opacity.value, threshold == 0 ? t : (t == 1 ? 1 : 0));
        expect(exit.opacity.value, threshold == 0 ? (t == 0 ? 1 : 0) : 1 - t);
      }
    });
  }
}
