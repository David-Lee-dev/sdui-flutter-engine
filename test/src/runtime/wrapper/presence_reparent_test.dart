import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/presence_config.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/fade.dart';
import 'package:sdui_engine/src/runtime/wrapper/motion.dart';
import 'package:sdui_engine/src/runtime/wrapper/presence.dart';

const _timing = PresenceConfig(durationMs: 1000, curve: 'linear');

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

/// A group showing a focusable 'old' while [show], under [key] if given.
Widget _focusGroup(FocusNode node, {required bool show, Key? key}) =>
    PresenceGroup.single(
      key: key,
      childKey: show ? 'old' : null,
      config: _timing,
      child: show ? Focus(focusNode: node, child: const Text('old')) : null,
    );

void main() {
  group('presence 가 빌린 것은 위치가 바뀌거나 끝날 때 다시 얻고 돌려준다', () {
    testWidgets('퇴장 중 TickerMode(false) 아래로 옮겨지면 바로 끝난다', (tester) async {
      final key = GlobalKey();
      Widget group(bool show) => PresenceGroup.single(
        key: key,
        childKey: show ? 'old' : null,
        config: _timing,
        child: show ? const Text('old') : null,
      );
      Widget tree({required bool moved, required bool show}) => _host(
        Row(
          children: [
            TickerMode(
              enabled: true,
              child: moved ? const SizedBox() : group(show),
            ),
            TickerMode(
              enabled: false,
              child: moved ? group(show) : const SizedBox(),
            ),
          ],
        ),
      );
      await tester.pumpWidget(tree(moved: false, show: true));
      await tester.pumpWidget(tree(moved: false, show: false));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('old'), findsOneWidget);

      await tester.pumpWidget(tree(moved: true, show: false));
      await tester.pump();

      expect(find.text('old'), findsNothing);
    });

    testWidgets('퇴장이 끝나면 외부 FocusNode 의 플래그를 돌려준다', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        _host(FocusScope(child: _focusGroup(node, show: true))),
      );
      await tester.pumpWidget(
        _host(FocusScope(child: _focusGroup(node, show: false))),
      );
      await tester.pump();
      expect(node.canRequestFocus, isFalse);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpWidget(
        _host(
          FocusScope(
            child: Focus(focusNode: node, child: const Text('reuse')),
          ),
        ),
      );

      expect(node.canRequestFocus, isTrue);
      expect(node.skipTraversal, isFalse);
      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isTrue);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('퇴장 중 그룹이 사라져도 플래그를 돌려준다', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        _host(FocusScope(child: _focusGroup(node, show: true))),
      );
      await tester.pumpWidget(
        _host(FocusScope(child: _focusGroup(node, show: false))),
      );
      await tester.pump();
      expect(node.canRequestFocus, isFalse);

      await tester.pumpWidget(const SizedBox());

      expect(node.canRequestFocus, isTrue);
      expect(node.skipTraversal, isFalse);
    });

    testWidgets('퇴장 중 옮겨진 그룹은 옮긴 뒤에도 떠나는 노드를 잡아 둔다', (tester) async {
      final key = GlobalKey();
      final node = FocusNode();
      addTearDown(node.dispose);
      Widget tree({required bool moved, required bool show}) => _host(
        Row(
          children: [
            FocusScope(
              key: const ValueKey('left'),
              child: moved
                  ? const SizedBox()
                  : _focusGroup(node, show: show, key: key),
            ),
            FocusScope(
              key: const ValueKey('right'),
              child: moved
                  ? _focusGroup(node, show: show, key: key)
                  : const SizedBox(),
            ),
          ],
        ),
      );
      await tester.pumpWidget(tree(moved: false, show: true));
      await tester.pumpWidget(tree(moved: false, show: false));
      await tester.pump();
      expect(node.canRequestFocus, isFalse);

      await tester.pumpWidget(tree(moved: true, show: false));
      await tester.pump();

      expect(node.canRequestFocus, isFalse);
      await tester.pumpWidget(const SizedBox());
      expect(node.canRequestFocus, isTrue);
    });

    testWidgets('다른 entry 로 옮겨진 exit motion 은 새 entry 의 퇴장에서 재생된다', (
      tester,
    ) async {
      final key = GlobalKey();
      Widget motion() => MotionWrapper(
        key: key,
        motion: const FadeMotion(),
        params: const MotionParams({'duration': 1000}),
        phase: MotionPhase.exit,
        child: const Text('moving'),
      );
      Widget group(String id, {required bool show, required bool holds}) =>
          PresenceGroup.single(
            key: ValueKey(id),
            childKey: show ? id : null,
            config: const PresenceConfig(space: false),
            child: show ? (holds ? motion() : Text(id)) : null,
          );
      Widget tree({required bool moved, bool a = true, bool b = true}) => _host(
        Row(
          children: [
            group('a', show: a, holds: !moved),
            group('b', show: b, holds: moved),
          ],
        ),
      );
      await tester.pumpWidget(tree(moved: false));
      await tester.pumpWidget(tree(moved: true));
      // Entry a leaves at once: it no longer holds the motion.
      await tester.pumpWidget(tree(moved: true, a: false));
      expect(find.text('a'), findsNothing);

      await tester.pumpWidget(tree(moved: true, a: false, b: false));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('moving'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('moving'), findsNothing);
    });
  });
}
