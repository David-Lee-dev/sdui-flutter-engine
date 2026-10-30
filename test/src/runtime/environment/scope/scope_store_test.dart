import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/environment/_base.dart';
import 'package:sdui_engine/src/runtime/environment/scope/commit_scheduler.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_store.dart';

/// 전달을 붙잡아두는(즉시 flush 안 하는) 테스트 스케줄러 — `immediate` 우회를 관찰하기 위해.
class _HoldingScheduler implements CommitScheduler {
  void Function(Set<String>)? _held;
  Set<String>? _keys;

  @override
  void schedule(Set<String> changedKeys, void Function(Set<String>) flush) {
    _keys = changedKeys;
    _held = flush;
  }

  void release() => _held?.call(_keys!);

  @override
  void dispose() {}
}

void main() {
  group('ScopeStore', () {
    group('commit', () {
      test('다중키 커밋이 값들을 함께 발행한다', () {
        final store = ScopeStore({
          'loading': true,
          'data': null,
          'error': null,
        });
        store.commit({'loading': false, 'data': 'ok'});
        expect(store.read('loading'), false);
        expect(store.read('data'), 'ok');
        expect(store.read('error'), isNull);
      });

      test('미선언 키면 StateError, 전체 미커밋', () {
        final store = ScopeStore({'a': 1});
        expect(() => store.commit({'a': 2, 'nope': 9}), throwsStateError);
        expect(store.read('a'), 1); // a도 안 바뀐다(전체 abort)
      });

      test('비유한 double 값이면 throw, 전체 미커밋', () {
        final store = ScopeStore({'a': 1, 'b': 2});
        expect(
          () => store.commit({'a': 5, 'b': double.nan}),
          throwsArgumentError,
        );
        expect(store.read('a'), 1);
      });

      test('같은 값 재커밋은 no-op (스냅샷 그대로)', () {
        final store = ScopeStore({'a': 1});
        final before = store.snapshot;
        store.commit({'a': 1});
        expect(identical(store.snapshot, before), isTrue);
      });

      test('원본 컬렉션을 나중에 바꿔도 read에 안 샌다', () {
        final store = ScopeStore({'items': <Object?>[]});
        final input = <Object?>[1, 2];
        store.commit({'items': input});
        input.add(3);
        expect((store.read('items') as List), [1, 2]);
      });

      test('read로 받은 컬렉션은 불변', () {
        final store = ScopeStore({
          'items': <Object?>[1],
        });
        expect(
          () => (store.read('items') as List).add(2),
          throwsUnsupportedError,
        );
      });

      test('dispose 뒤 커밋은 조용히 드롭', () {
        final store = ScopeStore({'a': 1});
        store.dispose();
        expect(() => store.commit({'a': 2}), returnsNormally);
      });
    });

    group('subscribe / 전달', () {
      test('{a} 구독자는 {b} 커밋에 안 깨어난다', () {
        final store = ScopeStore({'a': 1, 'b': 2});
        var calls = 0;
        store.subscribe({'a'}).addListener(() => calls++);
        store.commit({'b': 9});
        expect(calls, 0);
      });

      test('{a} 구독자는 {a} 커밋에 한 번 깨어난다', () {
        final store = ScopeStore({'a': 1, 'b': 2});
        var calls = 0;
        store.subscribe({'a'}).addListener(() => calls++);
        store.commit({'a': 9});
        expect(calls, 1);
      });

      test('{a,b} 구독자는 다중키 커밋에도 정확히 1회', () {
        final store = ScopeStore({'a': 1, 'b': 2});
        var calls = 0;
        store.subscribe({'a', 'b'}).addListener(() => calls++);
        store.commit({'a': 9, 'b': 8});
        expect(calls, 1);
      });

      test('두 독립 구독이 각자 해당될 때 1회씩', () {
        final store = ScopeStore({'a': 1, 'b': 2});
        var aCalls = 0, bCalls = 0;
        store.subscribe({'a'}).addListener(() => aCalls++);
        store.subscribe({'b'}).addListener(() => bCalls++);
        store.commit({'a': 9});
        expect(aCalls, 1);
        expect(bCalls, 0);
      });

      test('no-op 커밋은 통지 없음', () {
        final store = ScopeStore({'a': 1});
        var calls = 0;
        store.subscribe({'a'}).addListener(() => calls++);
        store.commit({'a': 1}); // 같은 값
        expect(calls, 0);
      });
    });

    group('immediate 플래그', () {
      test('기본은 스케줄러 경유(붙잡히면 통지 안 옴), immediate는 즉시 통지', () {
        final scheduler = _HoldingScheduler();
        final store = ScopeStore({'a': 1, 'b': 2}, scheduler: scheduler);
        var calls = 0;
        store.subscribe({'a', 'b'}).addListener(() => calls++);

        store.commit({'a': 9}); // 스케줄러가 붙잡음
        expect(calls, 0);
        scheduler.release();
        expect(calls, 1);

        store.commit({'b': 8}, immediate: true); // 우회 → 즉시
        expect(calls, 2);
      });
    });

    group('pend (자동 skeleton 대기)', () {
      test('pend는 선언 키를 pending으로 두고 구독자에게 알린다', () {
        final store = ScopeStore({'a': null, 'b': null});
        var calls = 0;
        store.subscribe({'a'}).addListener(() => calls++);

        store.pend({'a', 'nope'});

        expect(store.pendOf('a'), PendState.pending);
        expect(store.pendOf('b'), PendState.none);
        expect(store.pendOf('nope'), PendState.none);
        expect(calls, 1);
      });

      test('release 커밋은 같은 값이어도 풀고 알린다', () {
        final store = ScopeStore({'a': null});
        var calls = 0;
        store.subscribe({'a'}).addListener(() => calls++);
        store.pend({'a'});
        calls = 0;

        store.commit({'a': null}, release: true);

        expect(store.pendOf('a'), PendState.settled);
        expect(calls, 1);
      });

      test('release 없는 커밋(syncState 경로)은 pending을 유지한다', () {
        final store = ScopeStore({'a': null});
        store.pend({'a'});

        store.commit({'a': 1}, immediate: true);

        expect(store.pendOf('a'), PendState.pending);
      });

      test('settle은 남은 pending만 한 번 풀고, 다시 pend해도 돌아가지 않는다', () {
        final store = ScopeStore({'a': null, 'b': null});
        var calls = 0;
        store.subscribe({'a', 'b'}).addListener(() => calls++);
        store.pend({'a', 'b'});
        store.commit({'a': 1}, release: true);
        calls = 0;

        store.settle({'a', 'b'});
        expect(store.pendOf('b'), PendState.settled);
        expect(calls, 1);

        store.settle({'a', 'b'});
        store.pend({'a', 'b'});
        expect(calls, 1);
        expect(store.pendOf('a'), PendState.settled);
        expect(store.pendOf('b'), PendState.settled);
      });

      test('전역 pending 키 수는 pend·release·settle·dispose를 따른다', () {
        final base = ScopeStore.pendingKeys;
        final store = ScopeStore({'a': null, 'b': null, 'c': null});

        store.pend({'a', 'b', 'c'});
        store.pend({'a'});
        expect(ScopeStore.pendingKeys, base + 3);

        store.commit({'a': 1}, release: true);
        expect(ScopeStore.pendingKeys, base + 2);

        store.settle({'a', 'b'});
        expect(ScopeStore.pendingKeys, base + 1);

        store.dispose();
        expect(ScopeStore.pendingKeys, base);
        store.dispose();
        expect(ScopeStore.pendingKeys, base);
      });

      test('pendAll 스토어는 선언 키 전부를 pending으로 세고 dispose에 푼다', () {
        final base = ScopeStore.pendingKeys;
        final store = ScopeStore({'item': null, 'index': 0}, pendAll: true);

        expect(store.pendOf('item'), PendState.pending);
        expect(store.pendOf('index'), PendState.pending);
        expect(ScopeStore.pendingKeys, base + 2);

        store.dispose();
        expect(ScopeStore.pendingKeys, base);
      });
    });
  });
}
