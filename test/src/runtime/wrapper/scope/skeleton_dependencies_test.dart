import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/presence_config.dart';
import 'package:sdui_engine/src/presentation/presentation.dart';
import 'package:sdui_engine/src/presentation/skeleton_style.dart';
import 'package:sdui_engine/src/runtime/engine_presentation.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/skeleton_scope.dart';

Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: MediaQuery(
    data: const MediaQueryData(),
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 300, height: 400, child: child),
    ),
  ),
);

Widget _slot({Key? key, Widget child = const Text('content')}) => SkeletonSlot(
  key: key,
  bones: const Text('bones'),
  boxed: true,
  path: 'test',
  presence: PresenceConfig.off,
  child: child,
);

/// The shimmer the slot under [key] gives its bones.
AnimationController _shimmerOf(WidgetTester tester, Key key) => tester
    .widget<SkeletonScope>(
      find.descendant(
        of: find.byKey(key),
        matching: find.byType(SkeletonScope),
      ),
    )
    .shimmer!;

class _Mount extends StatefulWidget {
  const _Mount(this.onMount);

  final VoidCallback onMount;

  @override
  State<_Mount> createState() => _MountState();
}

class _MountState extends State<_Mount> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  Widget build(BuildContext context) => const Text('content');
}

void main() {
  group('skeleton 은 바뀐 loading 과 옮겨 간 owner 를 다시 얻는다', () {
    // These cases cover the shared phase, which only an animating effect
    // runs; the engine default is a still tint.
    setUp(
      () => EnginePresentation.value = const SduiPresentation(
        skeleton: SkeletonStyle(effect: SkeletonEffect.shimmer),
      ),
    );
    tearDown(EnginePresentation.reset);

    testWidgets('SkeletonScope 의 notifier 를 바꾸면 새 것을 듣고 옛 것은 놓는다', (
      tester,
    ) async {
      final a = ValueNotifier(true);
      final b = ValueNotifier(false);
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      Widget tree(ValueNotifier<bool> loading) => _host(
        SkeletonScope(
          loading: loading,
          skeleton: const Text('bones'),
          presence: PresenceConfig.off,
          child: const Text('content'),
        ),
      );
      await tester.pumpWidget(tree(a));
      expect(find.text('content'), findsNothing);

      await tester.pumpWidget(tree(b));
      await tester.pump();

      expect(find.text('content'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      a.value = false;
      expect(tester.takeException(), isNull);
    });

    testWidgets('LoadingScope 가 notifier 를 바꿔도 bones 를 든 slot 이 따라간다', (
      tester,
    ) async {
      final a = ValueNotifier(true);
      final b = ValueNotifier(true);
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      final slot = _slot();
      Widget tree(ValueNotifier<bool> loading) =>
          _host(LoadingScope(loading: loading, child: slot));
      await tester.pumpWidget(tree(a));
      await tester.pumpWidget(tree(b));

      b.value = false;
      await tester.pump();

      expect(find.text('content'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('사라진 owner 에서 옮겨 간 slot 은 새 owner 의 load 와 shimmer 를 쓴다', (
      tester,
    ) async {
      final a = ValueNotifier(true);
      final b = ValueNotifier(true);
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      final moving = GlobalKey();
      const staying = ValueKey('staying');
      Widget tree({required bool moved}) => _host(
        Column(
          children: [
            if (!moved)
              LoadingScope(
                key: const ValueKey('a'),
                loading: a,
                child: _slot(key: moving),
              ),
            LoadingScope(
              key: const ValueKey('b'),
              loading: b,
              child: Column(
                children: [
                  if (moved) _slot(key: moving),
                  _slot(key: staying, child: const Text('other')),
                ],
              ),
            ),
          ],
        ),
      );
      await tester.pumpWidget(tree(moved: false));
      final shimmerA = _shimmerOf(tester, moving);

      await tester.pumpWidget(tree(moved: true));

      final shimmer = _shimmerOf(tester, moving);
      expect(shimmer, isNot(same(shimmerA)));
      expect(shimmer, same(_shimmerOf(tester, staying)));
      b.value = false;
      await tester.pump();
      expect(find.text('content'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('slot 이 떠난 owner 는 남은 slot 이 없으면 shimmer 를 멈춘다', (
      tester,
    ) async {
      final a = ValueNotifier(true);
      final b = ValueNotifier(true);
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      final moving = GlobalKey();
      Widget tree({required bool moved}) => _host(
        Column(
          children: [
            LoadingScope(
              key: const ValueKey('a'),
              loading: a,
              child: moved ? const SizedBox() : _slot(key: moving),
            ),
            LoadingScope(
              key: const ValueKey('b'),
              loading: b,
              child: moved ? _slot(key: moving) : const SizedBox(),
            ),
          ],
        ),
      );
      await tester.pumpWidget(tree(moved: false));
      final shimmerA = _shimmerOf(tester, moving);
      expect(shimmerA.isAnimating, isTrue);

      await tester.pumpWidget(tree(moved: true));

      expect(shimmerA.isAnimating, isFalse);
      expect(_shimmerOf(tester, moving).isAnimating, isTrue);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('끝난 slot 을 끝난 owner 로 옮겨도 다시 mount 하지 않는다', (tester) async {
      final a = ValueNotifier(true);
      final b = ValueNotifier(false);
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      final key = GlobalKey();
      var mounts = 0;
      Widget slot() => _slot(key: key, child: _Mount(() => mounts++));
      Widget tree({required bool moved}) => _host(
        Column(
          children: [
            LoadingScope(
              key: const ValueKey('a'),
              loading: a,
              child: moved ? const SizedBox() : slot(),
            ),
            LoadingScope(
              key: const ValueKey('b'),
              loading: b,
              child: moved ? slot() : const SizedBox(),
            ),
          ],
        ),
      );
      await tester.pumpWidget(tree(moved: false));
      a.value = false;
      await tester.pump();
      expect(mounts, 1);

      await tester.pumpWidget(tree(moved: true));

      expect(mounts, 1);
      expect(find.text('content'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
