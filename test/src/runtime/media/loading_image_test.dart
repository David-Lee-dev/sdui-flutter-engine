import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sdui_engine/src/runtime/media/loading_image.dart';

void main() {
  group('shimmerPlaceholder', () {
    testWidgets('known dimensions build a matching skeleton bone', (
      tester,
    ) async {
      // Skeletonizer reads its shimmer config from the ambient Theme, so mount
      // under a MaterialApp (as real screens are) rather than a bare Directionality.
      await tester.pumpWidget(
        MaterialApp(
          home: Center(child: shimmerPlaceholder(width: 120, height: 80)),
        ),
      );

      // A shimmer Bone at the requested size holds the space. (Skeletonizer.zone
      // does not expose a `Skeletonizer`-typed node, so assert on the Bone.)
      final bone = find.byWidgetPredicate((widget) => widget is Bone);
      expect(bone, findsOneWidget);
      expect(tester.getSize(bone), const Size(120, 80));
    });

    test('missing dimensions return an empty box', () {
      expect(shimmerPlaceholder(), isA<SizedBox>());
      expect(shimmerPlaceholder(width: 120), isA<SizedBox>());
      expect(shimmerPlaceholder(height: 80), isA<SizedBox>());
    });
  });

  group('loadingImageTransition', () {
    const placeholder = ColoredBox(
      color: Colors.red,
      child: SizedBox(width: 10, height: 10),
    );
    const image = ColoredBox(
      color: Colors.green,
      child: SizedBox(width: 10, height: 10),
    );

    Widget frame(bool loaded, {Widget? placeholderOverride}) => MaterialApp(
      home: loadingImageTransition(
        loaded: loaded,
        placeholder: placeholderOverride ?? placeholder,
        image: image,
      ),
    );

    testWidgets(
      'rapid loaded toggles that outlive the fade duration do not collide AnimatedSwitcher keys',
      (tester) async {
        await tester.pumpWidget(frame(false));
        await tester.pump(const Duration(milliseconds: 300));
        for (var i = 0; i < 6; i++) {
          await tester.pumpWidget(frame(i.isEven));
          await tester.pump(const Duration(milliseconds: 20));
          // Drain per-iteration: an undrained exception from an earlier
          // iteration collapses later ones into an opaque "multiple
          // exceptions" failure that hides which pump actually threw.
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      'same loaded state with a different child updates in place instead of starting a new fade',
      (tester) async {
        await tester.pumpWidget(frame(false));
        await tester.pump(const Duration(milliseconds: 300));

        const replacementPlaceholder = ColoredBox(
          color: Colors.blue,
          child: SizedBox(width: 20, height: 20),
        );
        await tester.pumpWidget(
          frame(false, placeholderOverride: replacementPlaceholder),
        );
        await tester.pump();

        final stack = tester.widgetList<Stack>(find.byType(Stack)).single;
        expect(stack.children, hasLength(1));
        expect(
          find.byWidgetPredicate(
            (widget) => widget is ColoredBox && widget.color == Colors.blue,
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
