import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/engine_registries.dart';

void main() {
  group('AnchorRegistry', () {
    late AnchorRegistry registry;

    setUp(() => registry = AnchorRegistry());

    group('register / keyFor', () {
      test('등록한 id로 키를 돌려준다', () {
        final key = GlobalKey();
        registry.register('section', key);
        expect(registry.keyFor('section'), same(key));
      });

      test('미등록 id는 null', () {
        expect(registry.keyFor('nope'), isNull);
      });

      test('같은 id 재등록은 최신으로 덮는다', () {
        final k1 = GlobalKey();
        final k2 = GlobalKey();
        registry.register('section', k1);
        registry.register('section', k2);
        expect(registry.keyFor('section'), same(k2));
      });
    });

    group('unregister (owner-guard)', () {
      test('등록한 주인이 해제하면 제거된다', () {
        final key = GlobalKey();
        registry.register('section', key);
        registry.unregister('section', key);
        expect(registry.keyFor('section'), isNull);
      });

      test('현재 주인이 아니면 해제해도 남는다 (위젯 swap 레이스 방지)', () {
        final old = GlobalKey();
        final current = GlobalKey();
        registry.register('section', old);
        registry.register('section', current); // 새 인스턴스가 덮음
        registry.unregister('section', old); // 옛 인스턴스가 뒤늦게 dispose
        expect(registry.keyFor('section'), same(current)); // 새 등록 살아남음
      });
    });
  });

  group('AnchorScopeRegistry', () {
    late AnchorScopeRegistry registry;

    setUp(() => registry = AnchorScopeRegistry());

    group('register / resolve', () {
      test('등록한 id로 컨트롤러를 돌려준다', () {
        final controller = _FakeController();
        registry.register('rewards', controller);
        expect(registry.resolve('rewards'), same(controller));
      });

      test('미등록 id는 null', () {
        expect(registry.resolve('nope'), isNull);
      });

      test('같은 id 재등록은 최신으로 덮는다', () {
        final c1 = _FakeController();
        final c2 = _FakeController();
        registry.register('rewards', c1);
        registry.register('rewards', c2);
        expect(registry.resolve('rewards'), same(c2));
      });

      test('id 없이 resolve하면 스코프가 하나일 때만 그것을 돌려준다', () {
        final only = _FakeController();
        registry.register('rewards', only);
        expect(registry.resolve(null), same(only));
      });

      test('id 없이 resolve했는데 스코프가 없으면 null', () {
        expect(registry.resolve(null), isNull);
      });

      test('id 없이 resolve했는데 스코프가 여럿이면 null (템플릿이 지목해야 함)', () {
        registry.register('a', _FakeController());
        registry.register('b', _FakeController());
        expect(registry.resolve(null), isNull);
      });
    });

    group('unregister (owner-guard)', () {
      test('등록한 주인이 해제하면 제거된다', () {
        final controller = _FakeController();
        registry.register('rewards', controller);
        registry.unregister('rewards', controller);
        expect(registry.resolve('rewards'), isNull);
      });

      test('현재 주인이 아니면 해제해도 남는다 (위젯 swap 레이스 방지)', () {
        final old = _FakeController();
        final current = _FakeController();
        registry.register('rewards', old);
        registry.register('rewards', current);
        registry.unregister('rewards', old);
        expect(registry.resolve('rewards'), same(current));
      });
    });
  });

  group('FocusRegistry', () {
    group('register / nodeFor', () {
      test('등록한 노드를 id로 찾는다', () {
        final registry = FocusRegistry();
        final node = FocusNode();
        addTearDown(node.dispose);

        registry.register('email', node);

        expect(registry.nodeFor('email'), same(node));
      });

      test('미등록 id는 null', () {
        expect(FocusRegistry().nodeFor('nope'), isNull);
      });
    });

    group('unregister', () {
      test('현재 소유자일 때만 해제한다(교체 순서 안전)', () {
        final registry = FocusRegistry();
        final oldNode = FocusNode();
        final newNode = FocusNode();
        addTearDown(oldNode.dispose);
        addTearDown(newNode.dispose);

        registry.register('f', oldNode);
        registry.register('f', newNode); // 같은 위치 교체 — 새 인스턴스 먼저 등록
        registry.unregister('f', oldNode); // 옛 인스턴스 뒤늦은 해제

        expect(registry.nodeFor('f'), same(newNode)); // owner 가드
      });

      test('소유자면 해제된다', () {
        final registry = FocusRegistry();
        final node = FocusNode();
        addTearDown(node.dispose);

        registry.register('f', node);
        registry.unregister('f', node);

        expect(registry.nodeFor('f'), isNull);
      });
    });
  });
}

class _FakeController implements AnchorScopeController {
  @override
  Rect? rectFor(String anchorId) => null;

  @override
  bool hasItem(String item) => false;

  @override
  Future<void> launch({
    required String item,
    required Offset from,
    required Offset to,
    required Duration duration,
    required Curve curve,
  }) => Future<void>.value();
}
