import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/environment/map_environment.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_environment.dart';

void main() {
  group('ScopeEnvironment', () {
    group('listen', () {
      test('같은 키셋은 같은 구독 객체를 돌려준다(memoize·정렬 무관)', () {
        final env = ScopeEnvironment({'a': 1, 'b': 2});
        expect(identical(env.listen({'a'}), env.listen({'a'})), isTrue);
        expect(
          identical(env.listen({'a', 'b'}), env.listen({'b', 'a'})),
          isTrue,
        );
      });

      test('공백 포함 키가 있어도 캐시 키가 충돌하지 않는다', () {
        // {'a b'}(단일 키)와 {'a','b'}(두 키)가 같은 캐시 슬롯을 쓰면 안 된다.
        final env = ScopeEnvironment({'a b': 0, 'a': 1, 'b': 2});
        expect(identical(env.listen({'a b'}), env.listen({'a', 'b'})), isFalse);
      });

      test('부모도 없는 미선언 키 구독은 null', () {
        final env = ScopeEnvironment({'a': 1});
        expect(env.listen({'nope'}), isNull);
      });

      test('parent가 바뀌어도 지역 구독은 재사용된다 (store에 중복 구독 누적 금지)', () {
        // parent 교체는 병합 캐시만 낡게 한다 — 지역 키의 store 구독까지 새로 만들면
        // scope가 reparent될 때마다 store 구독 리스트에 죽은 구독이 쌓인다.
        final env = ScopeEnvironment({'a': 1});
        final before = env.listen({'a'});
        env.parent = const MapEnvironment({'x': 0});
        final after = env.listen({'a'});
        expect(identical(before, after), isTrue);
      });
    });
  });
}
