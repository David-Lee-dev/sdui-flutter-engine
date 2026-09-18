import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/engine_registries.dart';
import 'package:sdui_engine/src/runtime/widget/anchor_scope/anchor_scope_anchors.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/anchor_widget.dart';

Widget _wrap(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  group('AnchorScope', () {
    late AnchorRegistry registry;

    setUp(() => registry = AnchorRegistry());

    testWidgets('mount하면 id→키를 등록하고 키가 살아있는 context를 가리킨다', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AnchorScope(
            id: 'section',
            registry: registry,
            child: const Text('x'),
          ),
        ),
      );

      final key = registry.keyFor('section');
      expect(key, isNotNull);
      expect(key!.currentContext, isNotNull); // 스크롤 타깃으로 쓸 수 있는 실 context
    });

    testWidgets('dispose하면 등록을 해제한다', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AnchorScope(
            id: 'section',
            registry: registry,
            child: const Text('x'),
          ),
        ),
      );
      expect(registry.keyFor('section'), isNotNull);

      await tester.pumpWidget(_wrap(const SizedBox()));
      expect(registry.keyFor('section'), isNull);
    });

    testWidgets('id가 바뀌면 옛 등록을 걷고 새 id로 재등록한다', (tester) async {
      await tester.pumpWidget(
        _wrap(AnchorScope(id: 'a', registry: registry, child: const Text('x'))),
      );
      final key = registry.keyFor('a');

      await tester.pumpWidget(
        _wrap(AnchorScope(id: 'b', registry: registry, child: const Text('x'))),
      );

      expect(registry.keyFor('a'), isNull);
      expect(registry.keyFor('b'), same(key)); // 같은 State·같은 키, id만 이동
    });
  });

  group('AnchorWidget.build', () {
    // 회귀 방어 — `anchor_scope`를 얹기 전 tukguri `today` 앵커가 의존하던
    // 전역 등록 경로. anchor_scope 유무와 무관하게 항상 유지돼야 한다.
    testWidgets('스코프가 없으면 전역 레지스트리에만 등록한다', (tester) async {
      final global = EngineRegistries();
      await tester.pumpWidget(
        _wrap(
          EngineRegistryScope(
            registries: global,
            child: Builder(
              builder: (context) => AnchorWidget.build(
                context,
                const {'id': 'today'},
                const [SizedBox()],
              ),
            ),
          ),
        ),
      );

      expect(global.anchors.keyFor('today'), isNotNull);
    });

    testWidgets('스코프 안이면 전역과 스코프 레지스트리 양쪽에 등록한다', (tester) async {
      final global = EngineRegistries();
      final scoped = AnchorRegistry();
      await tester.pumpWidget(
        _wrap(
          EngineRegistryScope(
            registries: global,
            child: AnchorScopeAnchors(
              anchors: scoped,
              child: Builder(
                builder: (context) => AnchorWidget.build(
                  context,
                  const {'id': 'coin'},
                  const [SizedBox()],
                ),
              ),
            ),
          ),
        ),
      );

      expect(global.anchors.keyFor('coin'), isNotNull); // scroll 드라이버 무영향
      expect(scoped.keyFor('coin'), isNotNull); // anchoring 드라이버가 쓸 스코프 로컬 등록
    });

    testWidgets('dispose하면 전역·스코프 등록을 모두 해제한다', (tester) async {
      final global = EngineRegistries();
      final scoped = AnchorRegistry();
      Widget mounted() => _wrap(
        EngineRegistryScope(
          registries: global,
          child: AnchorScopeAnchors(
            anchors: scoped,
            child: Builder(
              builder: (context) => AnchorWidget.build(
                context,
                const {'id': 'coin'},
                const [SizedBox()],
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(mounted());
      expect(global.anchors.keyFor('coin'), isNotNull);
      expect(scoped.keyFor('coin'), isNotNull);

      await tester.pumpWidget(_wrap(const SizedBox()));
      expect(global.anchors.keyFor('coin'), isNull);
      expect(scoped.keyFor('coin'), isNull);
    });
  });
}
