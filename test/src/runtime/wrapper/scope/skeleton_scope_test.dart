import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/skeleton_scope.dart';

const _skeletonKey = ValueKey('skeleton');
const _childKey = ValueKey('child');

Widget _subject(ValueNotifier<bool> loading) => Directionality(
  textDirection: TextDirection.ltr,
  child: SkeletonScope(
    loading: loading,
    skeleton: const SizedBox(key: _skeletonKey),
    child: const SizedBox(key: _childKey),
  ),
);

void main() {
  group('SkeletonScope', () {
    testWidgets('keeps the first-frame skeleton invisible while reserving it', (
      tester,
    ) async {
      final loading = ValueNotifier(true);
      addTearDown(loading.dispose);

      await tester.pumpWidget(_subject(loading));

      expect(find.byKey(_skeletonKey), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byKey(_skeletonKey),
          matching: find.byWidgetPredicate(
            (widget) => widget is Opacity && widget.opacity == 0,
          ),
        ),
        findsOneWidget,
      );
      expect(find.byKey(_childKey), findsNothing);
    });

    testWidgets('keeps the skeleton height throughout the grace window', (
      tester,
    ) async {
      final loading = ValueNotifier(true);
      addTearDown(loading.dispose);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topCenter,
            child: SkeletonScope(
              loading: loading,
              skeleton: const SizedBox(
                key: _skeletonKey,
                width: 100,
                height: 120,
              ),
              child: const SizedBox(key: _childKey, width: 100, height: 40),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(SkeletonScope)).height, 120);
    });

    testWidgets('reveals the shimmering skeleton when loading outlasts grace', (
      tester,
    ) async {
      final loading = ValueNotifier(true);
      addTearDown(loading.dispose);

      await tester.pumpWidget(_subject(loading));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.ancestor(
          of: find.byKey(_skeletonKey),
          matching: find.byType(ShaderMask),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.byKey(_skeletonKey),
          matching: find.byWidgetPredicate(
            (widget) => widget is Opacity && widget.opacity == 0,
          ),
        ),
        findsNothing,
      );
      expect(find.byKey(_childKey), findsNothing);
    });

    testWidgets(
      'skips skeleton painting and fade when loading finishes quickly',
      (tester) async {
        final loading = ValueNotifier(true);
        addTearDown(loading.dispose);

        await tester.pumpWidget(_subject(loading));
        await tester.pump(const Duration(milliseconds: 150));
        expect(
          find.ancestor(
            of: find.byKey(_skeletonKey),
            matching: find.byWidgetPredicate(
              (widget) => widget is Opacity && widget.opacity == 0,
            ),
          ),
          findsOneWidget,
        );

        loading.value = false;
        await tester.pump();

        expect(find.byKey(_childKey), findsOneWidget);
        expect(find.byKey(_skeletonKey), findsNothing);
        expect(find.byType(ShaderMask), findsNothing);
        expect(find.byType(FadeTransition), findsNothing);
      },
    );

    testWidgets('fades the skeleton after loading finishes beyond grace', (
      tester,
    ) async {
      final loading = ValueNotifier(true);
      addTearDown(loading.dispose);

      await tester.pumpWidget(_subject(loading));
      await tester.pump(const Duration(milliseconds: 300));

      loading.value = false;
      await tester.pump();
      expect(find.byKey(_childKey), findsOneWidget);
      expect(find.byKey(_skeletonKey), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byKey(_childKey), findsOneWidget);
      expect(find.byKey(_skeletonKey), findsNothing);
    });

    testWidgets('keeps the child mounted across fade completion', (
      tester,
    ) async {
      final loading = ValueNotifier(true);
      addTearDown(loading.dispose);
      var mounts = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SkeletonScope(
            loading: loading,
            skeleton: const SizedBox(key: _skeletonKey),
            child: _MountCounter(onMount: () => mounts++),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      loading.value = false;
      await tester.pump();
      expect(mounts, 1);

      await tester.pumpAndSettle();
      expect(mounts, 1);
      expect(find.byKey(_childKey), findsOneWidget);
    });

    testWidgets('shows only content when loading is already complete', (
      tester,
    ) async {
      final loading = ValueNotifier(false);
      addTearDown(loading.dispose);

      await tester.pumpWidget(_subject(loading));

      expect(find.byKey(_skeletonKey), findsNothing);
      expect(find.byKey(_childKey), findsOneWidget);
    });

    testWidgets('cancels the grace timer when disposed before reveal', (
      tester,
    ) async {
      final loading = ValueNotifier(true);
      addTearDown(loading.dispose);

      await tester.pumpWidget(_subject(loading));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SkeletonScope), findsNothing);
    });
  });
}

/// Counts how many times its element is mounted (initState), to prove the
/// skeleton reveal does not remount the content.
class _MountCounter extends StatefulWidget {
  const _MountCounter({required this.onMount});

  final VoidCallback onMount;

  @override
  State<_MountCounter> createState() => _MountCounterState();
}

class _MountCounterState extends State<_MountCounter> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(key: _childKey);
}
