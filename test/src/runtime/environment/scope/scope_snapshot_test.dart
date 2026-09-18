import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/environment/scope/json_value.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_store.dart';

void main() {
  group('ScopeSnapshot', () {
    group('fromSeed / read', () {
      test('seed 값을 읽는다', () {
        final s = ScopeSnapshot.fromSeed(const {'count': 0, 'name': 'kim'});
        expect(s.read('count'), 0);
        expect(s.read('name'), 'kim');
      });

      test('결측 키와 선언된 null을 구분한다', () {
        final s = ScopeSnapshot.fromSeed(const {'n': null});
        expect(s.contains('n'), isTrue);
        expect(s.read('n'), isNull);
        expect(s.contains('missing'), isFalse);
        expect(s.read('missing'), isNull);
      });

      test('seed 값은 정규화돼 불변이다', () {
        final s = ScopeSnapshot.fromSeed({
          'items': <Object?>[1, 2],
        });
        expect(() => (s.read('items') as List).add(3), throwsUnsupportedError);
      });

      test('키 집합을 노출한다', () {
        final s = ScopeSnapshot.fromSeed(const {'a': 1, 'b': 2});
        expect(s.keys.toSet(), {'a', 'b'});
      });
    });

    group('applying', () {
      test('바뀐 키만 담은 새 스냅샷을 내고 원본은 그대로', () {
        final s0 = ScopeSnapshot.fromSeed(const {'a': 1, 'b': 2});
        final s1 = s0.applying(const {'a': 9});

        expect(s1.read('a'), 9);
        expect(s1.read('b'), 2);
        expect(s0.read('a'), 1); // 원본 불변
        expect(identical(s0, s1), isFalse);
      });

      test('여러 키를 한 번에 적용', () {
        final s0 = ScopeSnapshot.fromSeed(const {
          'loading': true,
          'data': null,
          'error': null,
        });
        final s1 = s0.applying(const {'loading': false, 'data': 'ok'});
        expect(s1.read('loading'), false);
        expect(s1.read('data'), 'ok');
        expect(s1.read('error'), isNull);
      });

      test('빈 변경은 같은 스냅샷 정체성 유지', () {
        final s0 = ScopeSnapshot.fromSeed(const {'a': 1});
        expect(identical(s0.applying(const {}), s0), isTrue);
      });

      test('결과도 불변', () {
        final s0 = ScopeSnapshot.fromSeed(const {'a': 1});
        final s1 = s0.applying({
          'a': JsonValue.normalize(<Object?>[1]),
        });
        expect(() => (s1.read('a') as List).add(2), throwsUnsupportedError);
      });
    });
  });
}
