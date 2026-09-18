import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/environment/map_environment.dart';
import 'package:sdui_engine/src/runtime/interpreter/expression_evaluator.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import 'package:sdui_engine/src/runtime/util/function_registry.dart';

Object? eval(String src, [Map<String, Object?> vars = const {}]) =>
    ExpressionEvaluator.evaluate(Expression.compile(src), MapEnvironment(vars));

bool truthy(String src, [Map<String, Object?> vars = const {}]) =>
    ExpressionEvaluator.evaluateTruthy(
      Expression.compile(src),
      MapEnvironment(vars),
    );

void main() {
  group('Expression', () {
    group('깊이 제한 (B-1.2)', () {
      test('과도하게 깊은 괄호 중첩은 FormatException (StackOverflow 방지)', () {
        final deep = '${'(' * 300}1${')' * 300}';
        expect(() => Expression.compile(deep), throwsFormatException);
      });

      test('과도하게 깊은 단항 연쇄도 FormatException', () {
        expect(
          () => Expression.compile('not ' * 300 + 'true'),
          throwsFormatException,
        );
      });
    });

    group('리터럴·바인딩', () {
      test('숫자·문자열·bool·null', () {
        expect(eval('1'), 1);
        expect(eval('1.5'), 1.5);
        expect(eval("'hi'"), 'hi');
        expect(eval('true'), true);
        expect(eval('null'), isNull);
      });

      test('바인딩 root·프로퍼티·인덱스', () {
        final vars = {
          'user': {'name': 'Kim'},
          'items': ['a', 'b'],
          'i': 1,
        };
        expect(eval(r'user.name', vars), 'Kim');
        expect(eval(r'items[0]', vars), 'a');
        expect(eval(r'items[i]', vars), 'b');
      });

      test('결측 root·프로퍼티는 null(관대)', () {
        expect(eval(r'nope'), isNull);
        expect(eval(r'user.age', {'user': <String, Object?>{}}), isNull);
      });
    });

    group('산술', () {
      test('사칙·나머지, 나눗셈은 실수', () {
        expect(eval('2 + 3 * 4'), 14); // 우선순위
        expect(eval('(2 + 3) * 4'), 20);
        expect(eval('10 / 4'), 2.5);
        expect(eval('7 % 3'), 1);
      });

      test('%는 파이썬 floor-mod — 결과 부호가 제수를 따른다 (M5)', () {
        // Dart %(항상 비음수)가 아니라 파이썬 시맨틱: 서버 작성자가 파이썬으로 검증한
        // 식이 기기에서 같은 값을 내야 한다.
        expect(eval('5 % -3'), -1);
        expect(eval('-5 % 3'), 1);
        expect(eval('-5 % -3'), -2);
        expect(eval('6 % -3'), 0);
        expect(eval('5.5 % -2'), -0.5);
        expect(eval('-5 + 2'), -3);
      });

      test('문자열 연결은 +', () {
        expect(eval("'a' + 'b'"), 'ab');
      });
    });

    group('== 컬렉션 구조 동등 (B-1.3)', () {
      test('구조가 같은 맵·리스트는 == 참 (별 인스턴스여도)', () {
        final vars = {
          'a': {
            'x': 1,
            'y': [2, 3],
          },
          'b': {
            'x': 1,
            'y': [2, 3],
          },
          'l1': [1, 2],
          'l2': [1, 2],
        };
        expect(truthy(r'a == b', vars), isTrue);
        expect(truthy(r'l1 == l2', vars), isTrue);
        expect(truthy(r'a != b', vars), isFalse);
      });

      test('구조가 다르면 == 거짓', () {
        final vars = {
          'a': {'x': 1},
          'b': {'x': 2},
          'l1': [1, 2],
          'l2': [1, 2, 3],
        };
        expect(truthy(r'a == b', vars), isFalse);
        expect(truthy(r'l1 == l2', vars), isFalse);
      });
    });

    group('비교', () {
      test('숫자·문자열 순서, ==는 강제변환 없음', () {
        expect(truthy('1 < 2'), isTrue);
        expect(truthy("'a' < 'b'"), isTrue);
        expect(truthy('1 == 1.0'), isTrue);
        expect(truthy("1 == '1'"), isFalse);
      });

      test('파이썬 chaining a < b < c', () {
        expect(truthy(r'0 <= x', {'x': 5}), isTrue);
        expect(truthy(r'0 <= x < 10', {'x': 5}), isTrue);
        expect(truthy(r'0 <= x < 10', {'x': 20}), isFalse);
        expect(truthy('1 < 3 < 2'), isFalse);
      });
    });

    group('논리·truthiness', () {
      test('and/or 단락 평가·피연산자 반환', () {
        expect(eval('1 and 2'), 2);
        expect(eval('0 or 5'), 5);
        expect(eval("null or 'x'"), 'x');
      });

      test('not은 비교보다 느슨(파이썬)', () {
        expect(truthy('not 1 == 2'), isTrue); // not (1 == 2)
        expect(truthy('not 0'), isTrue);
      });

      test('and로 null 가드', () {
        // age가 null이면 단락 → null(거짓), 순서 비교에 안 닿아 안전.
        expect(truthy(r'age and age > 18', {'age': null}), isFalse);
        expect(truthy(r'age and age > 18', {'age': 20}), isTrue);
      });

      test('파이썬 truthiness — 0·빈문자·빈컬렉션·null 거짓', () {
        expect(truthy('0'), isFalse);
        expect(truthy("''"), isFalse);
        expect(truthy('null'), isFalse);
        expect(truthy(r'not e', {'e': <Object?>[]}), isTrue);
        expect(truthy(r'not m', {'m': <String, Object?>{}}), isTrue);
      });
    });

    group('문자열 escape', () {
      test('escape·양쪽 따옴표', () {
        expect(eval(r"'a\nb'"), 'a\nb');
        expect(eval(r'"say \"hi\""'), 'say "hi"');
        expect(eval(r"'A'"), 'A');
        expect(eval(r"'it\'s'"), "it's");
      });
    });

    group('에러는 던진다', () {
      test('타입 오류·0 나눗셈', () {
        expect(() => eval(r'x + 1', {'x': null}), throwsFormatException);
        expect(() => eval("1 < 'a'"), throwsFormatException);
        expect(() => eval('1 / 0'), throwsFormatException);
        expect(() => eval('1 % 0'), throwsFormatException);
      });

      test('문법 오류', () {
        expect(() => eval(r'$'), throwsFormatException);
        expect(
          () => eval('_foo'),
          throwsFormatException,
        ); // 바인딩 root는 `_` 금지(맨몸도)
        expect(() => eval("'abc"), throwsFormatException); // 미종료
        expect(() => eval(r"'\q'"), throwsFormatException); // 알 수 없는 escape
        expect(() => eval('1 +'), throwsFormatException);
      });
    });

    group('참조 root(AST)', () {
      test('경로·인덱스의 root, 문자열 리터럴 안 \$는 제외', () {
        expect(Expression.compile(r'a + b.c').roots, {'a', 'b'});
        expect(Expression.compile(r'items[i]').roots, {'items', 'i'});
        expect(Expression.compile(r"'$x' == 'y'").roots, isEmpty);
      });
    });

    group('bareBindingKey — write-back 대상 판정', () {
      test('맨몸 바인딩(경로·연산 없음)은 그 root', () {
        expect(Expression.compile(r'items').bareBindingKey, 'items');
      });

      test('프로퍼티·인덱스·연산·컴프리헨션은 null (단일 쓰기 대상 없음)', () {
        // `$feed.items`는 root가 하나(`feed`)여도 맨몸이 아니다 — 여기에 되쓰면 feed를 뭉갠다.
        expect(Expression.compile(r'feed.items').bareBindingKey, isNull);
        expect(Expression.compile(r'items[0]').bareBindingKey, isNull);
        expect(Expression.compile(r'a + b').bareBindingKey, isNull);
        expect(
          Expression.compile(r'[x for x in items if x.visible]').bareBindingKey,
          isNull,
        );
      });
    });

    group('리터럴 확장', () {
      test('16진수', () {
        expect(eval('0xFF'), 255);
        expect(eval('0x1_0'), 16); // 구분자 섞여도 무시하고 파싱
      });

      test('천단위 구분자', () {
        expect(eval('1_000'), 1000);
        expect(eval('1_000.5'), 1000.5);
      });

      test('리스트 리터럴 — 원소는 표현식, 후행 콤마 허용', () {
        expect(eval('[1, 2, 3]'), [1, 2, 3]);
        expect(eval('[]'), isEmpty);
        expect(eval(r'[1, x, 2 + 1,]', {'x': 9}), [1, 9, 3]);
      });

      test('맵 리터럴 — 키·값 모두 표현식', () {
        expect(eval("{'a': 1, 'b': 2}"), {'a': 1, 'b': 2});
        expect(eval('{}'), isEmpty);
        expect(eval(r"{'a': x + 1}", {'x': 1}), {'a': 2});
      });
    });

    group('삼항 (단락)', () {
      test('참/거짓 가지', () {
        expect(eval('true ? 1 : 2'), 1);
        expect(eval('false ? 1 : 2'), 2);
        expect(eval('0 ? 1 : 2'), 2); // 파이썬 truthiness
      });

      test('미평가 가지는 평가되지 않는다 — 0으로 나눠도 안 던진다', () {
        expect(eval('true ? 1 : 1 / 0'), 1);
        expect(eval('false ? 1 / 0 : 2'), 2);
      });

      test('우결합 — a ? b : c ? d : e', () {
        expect(eval('false ? 1 : true ? 2 : 3'), 2);
        expect(eval('false ? 1 : false ? 2 : 3'), 3);
      });
    });

    group('null-coalesce ??', () {
      test('왼쪽이 null일 때만 오른쪽 — or와 다르게 0은 왼쪽을 그대로 낸다', () {
        expect(eval('null ?? 9'), 9);
        expect(eval('0 ?? 9'), 0);
        expect(eval('0 or 9'), 9); // 대비용
      });

      test('우결합', () {
        expect(eval('null ?? null ?? 3'), 3);
      });

      test('결측 바인딩과 조합', () {
        expect(eval(r'missing ?? 7'), 7);
      });
    });

    group('in / not in', () {
      test('리스트 — 구조동등 포함', () {
        expect(truthy('2 in [1, 2, 3]'), isTrue);
        expect(truthy('9 in [1, 2, 3]'), isFalse);
        expect(truthy("[1, 2] in [[1, 2], [3, 4]]"), isTrue); // 구조 동등
      });

      test('맵 — 키 존재', () {
        expect(truthy("'a' in {'a': 1}"), isTrue);
        expect(truthy("'b' in {'a': 1}"), isFalse);
      });

      test('문자열 — 부분문자열(우변도 문자열일 때만)', () {
        expect(truthy("'ell' in 'hello'"), isTrue);
        expect(truthy("'zz' in 'hello'"), isFalse);
        expect(truthy('1 in 12'), isFalse); // 우변이 문자열 아니면 false
      });

      test('not in — 부정, 비체이닝', () {
        expect(truthy('9 not in [1, 2, 3]'), isTrue);
        expect(truthy('2 not in [1, 2, 3]'), isFalse);
      });

      test('접두 not과 구분 — not a in b == not (a in b)', () {
        expect(truthy('not 2 in [1, 2, 3]'), isFalse);
        expect(truthy('not 9 in [1, 2, 3]'), isTrue);
      });
    });

    group('산술 확장', () {
      test('// 는 파이썬 floor-div', () {
        expect(eval('7 // 2'), 3);
        expect(eval('-7 // 2'), -4);
      });

      test('** 는 우결합 거듭제곱', () {
        expect(eval('2 ** 3'), 8);
        expect(eval('2 ** 3 ** 2'), 512); // 2 ** (3 ** 2)
      });

      test('str * int / int * str — 문자열 반복', () {
        expect(eval("'-' * 3"), '---');
        expect(eval("3 * '-'"), '---');
        expect(eval("'-' * 0"), ''); // 관대
        expect(eval("'-' * -1"), ''); // 관대
      });

      test('list * int — 리스트 반복', () {
        expect(eval('[0] * 3'), [0, 0, 0]);
      });

      test('반복 캡 초과는 FormatException', () {
        expect(() => eval("'x' * 200000"), throwsFormatException);
      });
    });

    group('접근 확장', () {
      test('음수 인덱스', () {
        final vars = {
          'items': [1, 2, 3],
        };
        expect(eval(r'items[-1]', vars), 3);
        expect(eval(r'items[-3]', vars), 1);
        expect(eval(r'items[-9]', vars), isNull); // 범위 밖은 관대
      });

      test('슬라이스 — 리스트, 생략·음수·step', () {
        final vars = {
          'items': [0, 1, 2, 3, 4],
        };
        expect(eval(r'items[1:3]', vars), [1, 2]);
        expect(eval(r'items[:2]', vars), [0, 1]);
        expect(eval(r'items[2:]', vars), [2, 3, 4]);
        expect(eval(r'items[:]', vars), [0, 1, 2, 3, 4]);
        expect(eval(r'items[::2]', vars), [0, 2, 4]);
        expect(eval(r'items[::-1]', vars), [4, 3, 2, 1, 0]);
        expect(eval(r'items[-2:]', vars), [3, 4]);
      });

      test('슬라이스 — 문자열 (유니코드 스칼라, 서로게이트 안 깨짐 §0.6)', () {
        expect(eval(r"'hello'[1:3]"), 'el');
        expect(eval(r"'hello'[::-1]"), 'olleh');
        // 이모지(서로게이트 쌍)를 코드유닛으로 자르면 반쪽이 된다 — 스칼라(rune) 단위로 자른다.
        expect(eval(r's[:1]', {'s': '😀David'}), '😀');
        expect(eval(r's[1:]', {'s': '😀David'}), 'David');
        expect(eval(r's[-1:]', {'s': 'a😀'}), '😀');
      });

      test('slice step 0은 관대하게 빈 결과', () {
        expect(
          eval(r'items[::0]', {
            'items': [1, 2, 3],
          }),
          isEmpty,
        );
      });
    });

    group('함수 호출', () {
      tearDown(FunctionRegistry.reset);

      test('등록된 함수를 호출한다', () {
        FunctionRegistry.register('double', (a) => (a[0]! as num) * 2);
        expect(eval('double(21)'), 42);
      });

      test('인자 여러 개', () {
        FunctionRegistry.register(
          'add',
          (a) => (a[0]! as num) + (a[1]! as num),
        );
        expect(eval('add(1, 2)'), 3);
      });

      test('미등록 함수는 FormatException', () {
        expect(() => eval('nope(1)'), throwsFormatException);
      });

      test('호출 뒤 postfix 체이닝 — f(x)[0]', () {
        FunctionRegistry.register('list123', (a) => [1, 2, 3]);
        expect(eval('list123()[0]'), 1);
      });

      test('인자는 표현식(바인딩·산술 포함)', () {
        FunctionRegistry.register('id', (a) => a[0]);
        expect(eval(r'id(x + 1)', {'x': 4}), 5);
      });
    });

    group('빌트인 arity — 초과 인자는 null (§0.7)', () {
      test('고정 arity 초과는 null (전엔 초과 인자 무시하고 그럴듯한 오답)', () {
        expect(eval('str(1, 2)'), isNull); // 전: "1"
        expect(eval("upper('a', 'b')"), isNull);
        expect(eval('round(1.239, 2, 9)'), isNull); // round는 최대 2
      });

      test('정상 arity는 그대로', () {
        expect(eval('str(1)'), '1');
        expect(eval('round(1.239, 2)'), 1.24);
        expect(eval("substring('hello', 1)"), 'ello'); // 선택 인자 생략 OK
      });

      test('가변 인자(min·max·sum)는 상한 없음', () {
        expect(eval('min(3, 1, 2)'), 1);
        expect(eval('max(3, 1, 2)'), 3);
        expect(eval('sum(1, 2, 3, 4)'), 10);
      });
    });

    group('불변 업데이트 (§5 — merge·updateAt·setPath)', () {
      test('merge — 얕은 병합, changes 우선', () {
        expect(
          eval(r'merge(a, b)', {
            'a': {'x': 1, 'y': 2},
            'b': {'y': 9, 'z': 3},
          }),
          {'x': 1, 'y': 9, 'z': 3},
        );
        expect(eval('merge(1, 2)'), isNull); // 맵 아니면 null
      });

      test('updateAt — i번째만 새 리스트로 (음수·범위밖 관대, 원본 불변)', () {
        final vars = {
          'items': [10, 20, 30],
        };
        expect(eval(r'update_at(items, 1, 99)', vars), [10, 99, 30]);
        expect(eval(r'update_at(items, -1, 99)', vars), [10, 20, 99]);
        expect(eval(r'update_at(items, 9, 1)', vars), [10, 20, 30]); // 범위 밖
        expect(vars['items'], [10, 20, 30]); // 원본 안 바뀜
      });

      test('setPath — 중첩 필드만 바꾼 새 구조 (형제·원본 보존)', () {
        final feed = {
          'title': 'F',
          'items': [
            {'id': 'a', 'claimed': false},
            {'id': 'b', 'claimed': false},
          ],
        };
        expect(
          eval(r"set_path(feed, ['items', 0, 'claimed'], true)", {
            'feed': feed,
          }),
          {
            'title': 'F',
            'items': [
              {'id': 'a', 'claimed': true},
              {'id': 'b', 'claimed': false},
            ],
          },
        );
        expect((feed['items'] as List)[0], {
          'id': 'a',
          'claimed': false,
        }); // 원본 불변
      });

      test('setPath — 빈 경로는 원본', () {
        expect(eval(r'set_path(x, [], 9)', {'x': 5}), 5);
      });
    });

    group('컴프리헨션', () {
      test('기본', () {
        expect(
          eval(r'[x * 2 for x in items]', {
            'items': [1, 2, 3],
          }),
          [2, 4, 6],
        );
      });

      test('if 필터', () {
        expect(
          eval(r'[x for x in items if x > 1]', {
            'items': [1, 2, 3],
          }),
          [2, 3],
        );
      });

      test('ITER가 List가 아니면 빈 리스트(관대)', () {
        expect(eval(r'[x for x in items]', {'items': null}), isEmpty);
      });

      test('VAR은 컴프리헨션 로컬 — 바깥 env를 가리지 않는다', () {
        expect(
          eval(r'[x for x in items] and x', {
            'items': [1],
            'x': 'outer',
          }),
          'outer',
        );
      });

      test('크기 캡 초과는 FormatException', () {
        expect(
          () => eval(r'[x for x in range(200000)]'),
          throwsFormatException,
        );
      });
    });

    group('컴프리헨션 roots', () {
      test('ITER root + (EXPR·COND root - VAR)', () {
        final roots = Expression.compile(
          r'[x + offset for x in items if x > min]',
        ).roots;
        expect(roots, {'items', 'offset', 'min'});
      });
    });

    group('우선순위 대표 조합 (§8)', () {
      test('a ? b : c ?? d', () {
        expect(eval('null ? 1 : null ?? 3'), 3);
      });

      test('not a in b', () {
        expect(truthy('not 2 in [1, 2, 3]'), isFalse);
      });

      test('-2 ** 2 == -4', () {
        expect(truthy('-2 ** 2 == -4'), isTrue);
      });

      test('1 + 2 * 3', () {
        expect(eval('1 + 2 * 3'), 7);
      });
    });
  });
}
