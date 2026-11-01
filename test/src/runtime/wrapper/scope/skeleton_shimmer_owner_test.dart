import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/presence_config.dart';
import 'package:sdui_engine/src/presentation/presentation.dart';
import 'package:sdui_engine/src/presentation/skeleton_style.dart';
import 'package:sdui_engine/src/runtime/engine_presentation.dart';
import 'package:sdui_engine/src/runtime/wrapper/presence.dart';
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

Widget _slot({
  Key? key,
  PresenceConfig presence = PresenceConfig.off,
  Widget child = const Text('content'),
}) => SkeletonSlot(
  key: key,
  bones: const Text('bones'),
  boxed: true,
  path: 'test',
  presence: presence,
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

void main() {
  group('shimmer 는 bones 가 그려지는 동안만 owner 를 붙든다', () {
    // These cases cover the shared phase, which only an animating effect
    // runs; the engine default is a still tint.
    setUp(
      () => EnginePresentation.value = const SduiPresentation(
        skeleton: SkeletonStyle(effect: SkeletonEffect.shimmer),
      ),
    );
    tearDown(EnginePresentation.reset);

    testWidgets('끝난 slot 을 loading 중인 owner 로 옮겨도 shimmer 를 켜지 않는다', (
      tester,
    ) async {
      final a = ValueNotifier(true);
      final b = ValueNotifier(true);
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      final key = GlobalKey();
      Widget tree({required bool moved}) => _host(
        Column(
          children: [
            LoadingScope(
              key: const ValueKey('a'),
              loading: a,
              child: moved ? const SizedBox() : _slot(key: key),
            ),
            LoadingScope(
              key: const ValueKey('b'),
              loading: b,
              child: moved ? _slot(key: key) : const SizedBox(),
            ),
          ],
        ),
      );
      await tester.pumpWidget(tree(moved: false));
      a.value = false;
      await tester.pump();
      expect(find.text('content'), findsOneWidget);

      await tester.pumpWidget(tree(moved: true));

      expect(find.text('content'), findsOneWidget);
      expect(_shimmerOf(tester, key).isAnimating, isFalse);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('바깥 presence 로 퇴장하는 bones 는 퇴장이 끝날 때까지 shimmer 를 쓴다', (
      tester,
    ) async {
      final loading = ValueNotifier(true);
      addTearDown(loading.dispose);
      const key = ValueKey('slot');
      Widget tree({required bool shown}) => _host(
        LoadingScope(
          loading: loading,
          child: PresenceGroup.single(
            config: const PresenceConfig(),
            childKey: 'slot',
            child: shown ? _slot(key: key) : null,
          ),
        ),
      );
      await tester.pumpWidget(tree(shown: true));
      await tester.pump(const Duration(milliseconds: 300));
      final shimmer = _shimmerOf(tester, key);
      expect(shimmer.isAnimating, isTrue);

      await tester.pumpWidget(tree(shown: false));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('bones'), findsOneWidget);
      expect(shimmer.isAnimating, isTrue);
      await tester.pumpAndSettle();
      expect(find.text('bones'), findsNothing);
      expect(shimmer.isAnimating, isFalse);
    });
  });
}
