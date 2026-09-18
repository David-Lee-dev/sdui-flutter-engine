import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/engine_registries.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/anchor_scope_widget.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/anchor_widget.dart';

// Center gives loose constraints so a probed child sizes to itself rather
// than being forced to the 800x600 test viewport (see swipe_layout_widget_test.dart).
Widget _wrap(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(child: child),
);

Widget _scoped(
  EngineRegistries registries,
  Map<String, Object?> props,
  Widget child,
) => _wrap(
  EngineRegistryScope(
    registries: registries,
    child: Builder(
      builder: (context) => AnchorScopeWidget.build(context, props, [child]),
    ),
  ),
);

void main() {
  group('AnchorScopeWidget', () {
    group('레이아웃 투명성', () {
      testWidgets('감싸도 안 감싸도 같은 크기로 측정된다', (tester) async {
        const probe = Key('probe');
        Widget content() => const SizedBox(key: probe, width: 123, height: 45);

        await tester.pumpWidget(_wrap(content()));
        final bare = tester.getSize(find.byKey(probe));

        await tester.pumpWidget(
          _scoped(EngineRegistries(), const {'id': 'x'}, content()),
        );
        final wrapped = tester.getSize(find.byKey(probe));

        expect(wrapped, bare);
      });
    });

    group('register', () {
      testWidgets('id로 AnchorScopeRegistry에 컨트롤러를 등록한다', (tester) async {
        final registries = EngineRegistries();
        await tester.pumpWidget(
          _scoped(registries, const {'id': 'rewards'}, const SizedBox()),
        );

        expect(registries.anchorScopes.resolve('rewards'), isNotNull);
      });

      testWidgets('dispose하면 등록을 해제한다', (tester) async {
        final registries = EngineRegistries();
        await tester.pumpWidget(
          _scoped(registries, const {'id': 'rewards'}, const SizedBox()),
        );
        expect(registries.anchorScopes.resolve('rewards'), isNotNull);

        await tester.pumpWidget(_wrap(const SizedBox()));
        expect(registries.anchorScopes.resolve('rewards'), isNull);
      });
    });

    group('controller', () {
      testWidgets('hasItem은 items에 선언된 키만 알아본다', (tester) async {
        final registries = EngineRegistries();
        await tester.pumpWidget(
          _scoped(registries, {
            'id': 'rewards',
            'items': {
              'coin': {'_type': 'sizedbox', 'width': 10.0, 'height': 10.0},
            },
          }, const SizedBox()),
        );

        final controller = registries.anchorScopes.resolve('rewards')!;
        expect(controller.hasItem('coin'), isTrue);
        expect(controller.hasItem('nope'), isFalse);
      });

      testWidgets('rectFor는 스코프 로컬 좌표로 등록된 anchor의 rect를 돌려준다', (tester) async {
        final registries = EngineRegistries();
        await tester.pumpWidget(
          _scoped(
            registries,
            const {'id': 'rewards'},
            Builder(
              builder: (context) => AnchorWidget.build(
                context,
                const {'id': 'target'},
                const [SizedBox(width: 40, height: 20)],
              ),
            ),
          ),
        );

        final controller = registries.anchorScopes.resolve('rewards')!;
        final rect = controller.rectFor('target');
        expect(rect, isNotNull);
        expect(rect!.size, const Size(40, 20));

        expect(controller.rectFor('nope'), isNull); // 미등록 anchor
      });
    });
  });
}
