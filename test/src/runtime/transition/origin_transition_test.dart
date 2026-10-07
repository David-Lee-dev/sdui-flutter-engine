import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/page_transition.dart';
import 'package:sdui_engine/src/runtime/transition/transition_factory.dart';
import 'package:sdui_engine/src/runtime/transition/transition_origin.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/transition_source_widget.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/shared_element_widget.dart';
import 'package:sdui_engine/src/shell/sdui_transition_page.dart';

const _sourceKey = ValueKey('source-box');
const _destinationKey = ValueKey('destination');

Future<(ValueNotifier<List<Page<void>>>, NavigatorState)> _mount(
  WidgetTester tester, {
  bool ios = false,
  bool shared = false,
  bool legacy = false,
}) async {
  final pages = ValueNotifier<List<Page<void>>>([]);
  addTearDown(pages.dispose);
  final key = GlobalKey<NavigatorState>();
  Widget source = const SizedBox(
    key: _sourceKey,
    width: 120,
    height: 80,
    child: ColoredBox(color: Colors.red),
  );
  if (shared) source = SharedElement(tag: 'nested', child: source);
  final child = Stack(
    children: [
      Positioned(
        left: 30,
        top: 60,
        child: TransitionSource(radius: 16, child: source),
      ),
      const Positioned(left: 30, top: 160, child: Text('outside capture')),
    ],
  );
  pages.value = [
    legacy
        ? MaterialPage(key: const ValueKey('base'), child: child)
        : sduiTransitionPage(
            key: const ValueKey('base'),
            spec: PageTransitionSpec(type: 'none'),
            child: child,
          ),
  ];
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        platform: ios ? TargetPlatform.iOS : TargetPlatform.android,
      ),
      home: ValueListenableBuilder<List<Page<void>>>(
        valueListenable: pages,
        builder: (_, value, _) => Navigator(
          key: key,
          pages: value,
          onDidRemovePage: (page) =>
              pages.value = [...pages.value]..remove(page),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (pages, key.currentState!);
}

Future<TransitionOrigin> _capture(
  WidgetTester tester,
  NavigatorState navigator,
) async {
  await tester.tap(find.byKey(_sourceKey));
  final origin = TransitionOrigins.of(navigator).consume().source;
  expect(origin, isNotNull);
  return origin!;
}

void main() {
  testWidgets(
    'transition_source captures only its wrapped box and consumes once',
    (tester) async {
      final (_, navigator) = await _mount(tester);
      await tester.tap(find.byKey(_sourceKey));
      final captured = TransitionOrigins.of(navigator).consume();
      final origin = captured.source!;
      addTearDown(origin.dispose);
      expect(origin.rect, const Rect.fromLTWH(30, 60, 120, 80));
      expect(origin.image.width, 120);
      expect(origin.image.height, 80);
      expect(origin.radius, 16);
      expect(captured.point, const Offset(90, 100));
      expect(TransitionOrigins.of(navigator).consume().source, isNull);
      final pixels = await tester.runAsync(() => origin.image.toByteData());
      expect(
        pixels!.getUint32(0),
        0xf44336ff,
      ); // Colors.red RGBA, no outside text
    },
  );

  testWidgets('transition_source drops unmounted and stale origins', (
    tester,
  ) async {
    final (pages, navigator) = await _mount(tester);
    await tester.tap(find.byKey(_sourceKey));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1050)),
    );
    expect(TransitionOrigins.of(navigator).consume(), (
      source: null,
      point: null,
    ));
    await tester.tap(find.byKey(_sourceKey));
    pages.value = [
      const MaterialPage(key: ValueKey('other'), child: SizedBox()),
    ];
    await tester.pumpAndSettle();
    expect(TransitionOrigins.of(navigator).consume().source, isNull);
  });

  testWidgets('origins are isolated between Navigators', (tester) async {
    final (_, navigator) = await _mount(tester);
    await tester.tap(find.byKey(_sourceKey));
    final other = NavigatorState();
    expect(TransitionOrigins.of(other).consume().source, isNull);
    TransitionOrigins.of(navigator).consume().source!.dispose();
  });

  testWidgets(
    'container_transform geometry radius and fade-through retrace push/pop',
    (tester) async {
      final (_, navigator) = await _mount(tester);
      final source = await _capture(tester, navigator);
      addTearDown(source.dispose);
      final controller = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 250),
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: TransitionOriginScope(
            source: source,
            child: Builder(
              builder: (context) =>
                  PageTransitionFactory.resolve('container_transform').build(
                    context,
                    controller,
                    const AlwaysStoppedAnimation(0),
                    const SizedBox.expand(key: _destinationKey),
                    PageTransitionSpec(type: 'container_transform'),
                  ),
            ),
          ),
        ),
      );
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
            await tester.pump(Duration(milliseconds: reverse ? 125 : 150));
          }
          final clip = tester.widget<ClipPath>(find.byType(ClipPath));
          final bounds = clip.clipper!
              .getClip(const Size(800, 600))
              .getBounds();
          expect(
            bounds,
            Rect.lerp(source.rect, const Rect.fromLTWH(0, 0, 800, 600), t),
          );
          expect(
            tester.widget<ClipRRect>(find.byType(ClipRRect)).borderRadius,
            BorderRadius.circular(16 * (1 - t)),
          );
          final opacity = tester
              .widgetList<Opacity>(find.byType(Opacity))
              .toList();
          expect(
            opacity[0].opacity,
            closeTo(((t - 0.35) / 0.65).clamp(0, 1), 1e-6),
          );
          expect(opacity[1].opacity, closeTo((1 - t / 0.35).clamp(0, 1), 1e-6));
        }
        controller.stop();
      }
    },
  );

  testWidgets('container_transform without capture falls back to fade', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) =>
              PageTransitionFactory.resolve('container_transform').build(
                context,
                const AlwaysStoppedAnimation(0.5),
                const AlwaysStoppedAnimation(0),
                const SizedBox.expand(),
                PageTransitionSpec(type: 'container_transform'),
              ),
        ),
      ),
    );
    expect(
      tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value,
      0.5,
    );
    expect(find.byType(RawImage), findsNothing);
  });

  for (final legacy in [false, true]) {
    testWidgets('card_stack incoming and outgoing push/pop legacy=$legacy', (
      tester,
    ) async {
      final (pages, navigator) = await _mount(tester, legacy: legacy);
      pages.value = [
        ...pages.value,
        sduiTransitionPage(
          key: const ValueKey('top'),
          spec: PageTransitionSpec(type: 'card_stack'),
          child: const SizedBox.expand(key: _destinationKey),
        ),
      ];
      await tester.pump();
      for (final reverse in [false, true]) {
        if (reverse) {
          navigator.pop();
          await tester.pump();
        }
        for (final t in reverse ? [1.0, 0.5] : [0.0, 0.5, 1.0]) {
          if (t == 0.5 || (!reverse && t == 1)) {
            await tester.pump(Duration(milliseconds: reverse ? 150 : 175));
          }
          final slide = tester.widget<SlideTransition>(
            find
                .ancestor(
                  of: find.byKey(_destinationKey),
                  matching: find.byType(SlideTransition),
                )
                .first,
          );
          expect(slide.position.value.dy, closeTo(1 - t, 1e-6));
          if (!legacy) {
            final transform = tester.widget<Transform>(
              find
                  .ancestor(
                    of: find.byKey(_sourceKey, skipOffstage: false),
                    matching: find.byType(Transform, skipOffstage: false),
                  )
                  .first,
            );
            expect(
              transform.transform.entry(0, 0),
              closeTo(1 - 0.06 * t, 1e-6),
            );
            final clips = tester
                .widgetList<ClipRRect>(
                  find.ancestor(
                    of: find.byKey(_sourceKey, skipOffstage: false),
                    matching: find.byType(ClipRRect, skipOffstage: false),
                  ),
                )
                .toList();
            expect(clips.last.borderRadius, BorderRadius.circular(12 * t));
            final overlay = tester
                .widgetList<ColoredBox>(
                  find.byType(ColoredBox, skipOffstage: false),
                )
                .where((box) => box.color.r == 0)
                .last;
            expect(overlay.color.a, closeTo(0.2 * t, 1e-6));
          }
        }
      }
      await tester.pumpAndSettle();
      expect(find.byKey(_destinationKey), findsNothing);
    });
  }

  for (final point in <Offset?>[null, const Offset(50, 25)]) {
    testWidgets('tap_zoom tap alignment and reverse point=$point', (
      tester,
    ) async {
      final controller = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 250),
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 200,
              height: 100,
              child: TransitionOriginScope(
                point: point,
                child: Builder(
                  builder: (context) =>
                      PageTransitionFactory.resolve('tap_zoom').build(
                        context,
                        controller,
                        const AlwaysStoppedAnimation(0),
                        const SizedBox.expand(key: _destinationKey),
                        PageTransitionSpec(type: 'tap_zoom'),
                      ),
                ),
              ),
            ),
          ),
        ),
      );
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
            await tester.pump(Duration(milliseconds: reverse ? 125 : 150));
          }
          final transform = tester.widget<Transform>(find.byType(Transform));
          expect(
            transform.alignment,
            point == null ? Alignment.center : const Alignment(-0.5, -0.5),
          );
          expect(transform.transform.entry(0, 0), closeTo(0.1 + 0.9 * t, 1e-6));
          expect(
            tester.widget<Opacity>(find.byType(Opacity)).opacity,
            closeTo(t, 1e-6),
          );
        }
        controller.stop();
      }
    });
  }

  for (final outcome in ['back', 'cancel', 'commit', 'remove']) {
    testWidgets(
      'container source restored after $outcome and nested Hero is suppressed',
      (tester) async {
        final (pages, navigator) = await _mount(
          tester,
          ios: true,
          shared: true,
        );
        final source = await _capture(tester, navigator);
        pages.value = [
          ...pages.value,
          sduiTransitionPage(
            key: const ValueKey('top'),
            spec: PageTransitionSpec(type: 'container_transform'),
            origin: source,
            child: const SharedElement(
              tag: 'nested',
              child: SizedBox.expand(key: _destinationKey),
            ),
          ),
        ];
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        expect(source.hidden.value, isTrue);
        expect(
          TransitionOrigins.of(navigator).suppresses((navigator, 'nested')),
          isTrue,
        );
        expect(tester.widgetList<RawImage>(find.byType(RawImage)).length, 1);
        await tester.pumpAndSettle();
        expect(source.hidden.value, isFalse);
        if (outcome == 'back') {
          navigator.pop();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 125));
          expect(source.hidden.value, isTrue);
        } else {
          final gesture = await tester.startGesture(const Offset(5, 300));
          await gesture.moveBy(const Offset(30, 0));
          await tester.pump();
          await gesture.moveBy(Offset(outcome == 'commit' ? 550 : 150, 0));
          await tester.pump();
          expect(source.hidden.value, isTrue);
          if (outcome == 'remove') {
            pages.value = [pages.value.first];
            await tester.pumpAndSettle();
          }
          await gesture.up();
        }
        await tester.pumpAndSettle();
        expect(source.hidden.value, isFalse);
        if (outcome == 'cancel') {
          expect(find.byKey(_destinationKey), findsOneWidget);
          navigator.pop();
          await tester.pumpAndSettle();
        }
        expect(
          TransitionOrigins.of(navigator).suppresses((navigator, 'nested')),
          isFalse,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
