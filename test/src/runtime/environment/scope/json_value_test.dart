import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/environment/scope/json_value.dart';

void main() {
  group('JsonValue', () {
    group('is_scalar', () {
      test('null·bool·String·int·유한 double은 스칼라', () {
        expect(JsonValue.isScalar(null), isTrue);
        expect(JsonValue.isScalar(true), isTrue);
        expect(JsonValue.isScalar('hi'), isTrue);
        expect(JsonValue.isScalar(3), isTrue);
        expect(JsonValue.isScalar(1.5), isTrue);
      });

      test('비유한 double은 스칼라 아님', () {
        expect(JsonValue.isScalar(double.nan), isFalse);
        expect(JsonValue.isScalar(double.infinity), isFalse);
      });

      test('List·Map은 스칼라 아님', () {
        expect(JsonValue.isScalar(<Object?>[1]), isFalse);
        expect(JsonValue.isScalar(<String, Object?>{'a': 1}), isFalse);
      });
    });

    group('normalize', () {
      test('스칼라는 그대로 통과', () {
        expect(JsonValue.normalize(null), isNull);
        expect(JsonValue.normalize(true), true);
        expect(JsonValue.normalize('hi'), 'hi');
        expect(JsonValue.normalize(3), 3);
        expect(JsonValue.normalize(1.5), 1.5);
      });

      test('비유한 double은 ArgumentError', () {
        expect(() => JsonValue.normalize(double.nan), throwsArgumentError);
        expect(() => JsonValue.normalize(double.infinity), throwsArgumentError);
      });

      test('JSON 아닌 객체는 ArgumentError', () {
        expect(() => JsonValue.normalize(DateTime(2026)), throwsArgumentError);
        expect(() => JsonValue.normalize(Object()), throwsArgumentError);
      });

      test('비문자열 맵 키는 ArgumentError', () {
        expect(
          () => JsonValue.normalize(<Object?, Object?>{1: 'a'}),
          throwsArgumentError,
        );
      });

      test('정규화 후 원본을 바꿔도 결과에 안 샌다 (분리)', () {
        final original = <String, Object?>{
          'a': <Object?>[1, 2],
        };
        final normalized = JsonValue.normalize(original) as Map;
        (original['a'] as List).add(3);
        original['b'] = 'new';

        expect((normalized['a'] as List), [1, 2]);
        expect(normalized.containsKey('b'), isFalse);
      });

      test('반환된 맵은 변경 시 throw (깊은 불변)', () {
        final n = JsonValue.normalize(<String, Object?>{'a': 1}) as Map;
        expect(() => n['b'] = 2, throwsUnsupportedError);
      });

      test('반환된 중첩 리스트도 변경 시 throw', () {
        final n =
            JsonValue.normalize(<String, Object?>{
                  'a': <Object?>[1, 2],
                })
                as Map;
        expect(() => (n['a'] as List).add(3), throwsUnsupportedError);
      });

      test('깊은 중첩(map>list>map)도 재귀 정규화', () {
        final n =
            JsonValue.normalize(<String, Object?>{
                  'rows': <Object?>[
                    <String, Object?>{'v': 1},
                  ],
                })
                as Map;
        final row = (n['rows'] as List)[0] as Map;
        expect(row['v'], 1);
        expect(() => row['v'] = 9, throwsUnsupportedError);
      });
    });

    group('normalize_object', () {
      test('값마다 정규화하고 결과는 불변', () {
        final obj = JsonValue.normalizeObject(<String, Object?>{
          'n': 1,
          'list': <Object?>[1],
        });
        expect(obj['n'], 1);
        expect(() => obj['x'] = 1, throwsUnsupportedError);
        expect(() => (obj['list'] as List).add(2), throwsUnsupportedError);
      });
    });

    group('normalize — 순환 참조', () {
      test('자기 참조 맵·리스트는 ArgumentError (StackOverflow 금지, M3)', () {
        final cyclicMap = <String, Object?>{};
        cyclicMap['self'] = cyclicMap;
        expect(() => JsonValue.normalize(cyclicMap), throwsArgumentError);

        final cyclicList = <Object?>[];
        cyclicList.add(cyclicList);
        expect(() => JsonValue.normalize(cyclicList), throwsArgumentError);

        // 간접 순환(맵 → 리스트 → 맵)도 잡는다.
        final a = <String, Object?>{};
        final b = <Object?>[a];
        a['b'] = b;
        expect(() => JsonValue.normalize(a), throwsArgumentError);
      });

      test('순환 아닌 과도한 깊이도 ArgumentError (deep-but-acyclic, B-1.2)', () {
        Object? deep = 0;
        for (var i = 0; i < 300; i++) {
          deep = [deep];
        }
        expect(() => JsonValue.normalize(deep), throwsArgumentError);
      });

      test('순환 아닌 공유 참조(다이아몬드)는 정상 (M3 양성)', () {
        final shared = <Object?>[1, 2];
        final input = <String, Object?>{'x': shared, 'y': shared};
        final normalized = JsonValue.normalize(input) as Map;
        expect(normalized['x'], [1, 2]);
        expect(normalized['y'], [1, 2]);
      });
    });

    group('structurally_equal', () {
      test('같은 스칼라·같은 중첩 구조는 true', () {
        expect(JsonValue.structurallyEqual(1, 1), isTrue);
        expect(JsonValue.structurallyEqual('a', 'a'), isTrue);
        expect(
          JsonValue.structurallyEqual(
            <String, Object?>{
              'a': <Object?>[1, 2],
            },
            <String, Object?>{
              'a': <Object?>[1, 2],
            },
          ),
          isTrue,
        );
      });

      test('값이 다르면 false', () {
        expect(
          JsonValue.structurallyEqual(<Object?>[1, 2], <Object?>[1, 3]),
          isFalse,
        );
      });

      test('길이·키가 다르면 false', () {
        expect(
          JsonValue.structurallyEqual(<Object?>[1], <Object?>[1, 2]),
          isFalse,
        );
        expect(
          JsonValue.structurallyEqual(
            <String, Object?>{'a': 1},
            <String, Object?>{'a': 1, 'b': 2},
          ),
          isFalse,
        );
      });

      test('타입이 다르면(map vs list) false', () {
        expect(
          JsonValue.structurallyEqual(<Object?>[], <String, Object?>{}),
          isFalse,
        );
      });

      test('1 == 1.0은 수치 동등이라 true', () {
        expect(JsonValue.structurallyEqual(1, 1.0), isTrue);
      });
    });
  });
}
