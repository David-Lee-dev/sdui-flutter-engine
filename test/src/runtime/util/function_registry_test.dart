import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:sdui_engine/src/runtime/util/function_registry.dart';

/// 등록된 함수를 이름으로 찾아 바로 호출한다(`_Builtins`는 파일 private라 `resolve`를 거친다).
Object? call(String name, [List<Object?> args = const []]) =>
    FunctionRegistry.resolve(name)!(args);

void main() {
  group('FunctionRegistry', () {
    tearDown(FunctionRegistry.reset);

    group('register/resolve', () {
      test('register한 함수를 이름으로 resolve한다', () {
        FunctionRegistry.register('double', (a) => (a[0]! as num) * 2);
        expect(FunctionRegistry.resolve('double')!([21]), 42);
      });

      test('registerAll로 여러 개를 한 번에 등록한다', () {
        FunctionRegistry.registerAll({'a': (args) => 1, 'b': (args) => 2});
        expect(FunctionRegistry.resolve('a')!(const []), 1);
        expect(FunctionRegistry.resolve('b')!(const []), 2);
      });

      test('미등록 이름은 null(호출처가 FormatException으로 바꾼다)', () {
        expect(FunctionRegistry.resolve('nope'), isNull);
      });

      test('reset은 빌트인만 남기고 되돌린다', () {
        FunctionRegistry.register('double', (a) => (a[0]! as num) * 2);
        FunctionRegistry.reset();
        expect(FunctionRegistry.resolve('double'), isNull);
        expect(FunctionRegistry.resolve('str'), isNotNull); // 빌트인은 남아있다
      });

      test('같은 이름 재등록은 덮어쓴다', () {
        FunctionRegistry.register('x', (a) => 1);
        FunctionRegistry.register('x', (a) => 2);
        expect(FunctionRegistry.resolve('x')!(const []), 2);
      });
    });

    group('빌트인 — 변환', () {
      test('str', () {
        expect(call('str', [5]), '5');
        expect(call('str', [null]), '');
        expect(call('str', [true]), 'true');
      });

      test('int', () {
        expect(call('int', [5.9]), 5);
        expect(call('int', ['42']), 42);
        expect(call('int', ['abc']), isNull); // 관대
        expect(call('int', [true]), isNull);
      });

      test('num', () {
        expect(call('num', [5]), 5);
        expect(call('num', ['3.5']), 3.5);
        expect(call('num', ['abc']), isNull);
      });

      test('bool', () {
        expect(call('bool', [1]), true);
        expect(call('bool', [0]), false);
        expect(call('bool', ['']), false);
        expect(call('bool', [null]), false);
      });
    });

    group('빌트인 — 일반', () {
      test('len', () {
        expect(call('len', ['hello']), 5);
        expect(
          call('len', [
            [1, 2, 3],
          ]),
          3,
        );
        expect(
          call('len', [
            {'a': 1},
          ]),
          1,
        );
        expect(call('len', [5]), isNull); // 관대
      });

      test('type', () {
        expect(call('type', [null]), 'null');
        expect(call('type', [true]), 'bool');
        expect(call('type', [5]), 'num');
        expect(call('type', ['x']), 'string');
        expect(
          call('type', [
            [1],
          ]),
          'list',
        );
        expect(call('type', [{}]), 'map');
      });

      test('default', () {
        expect(call('default', [null, 'fb']), 'fb');
        expect(call('default', [5, 'fb']), 5);
      });
    });

    group('빌트인 — 숫자', () {
      test('abs', () {
        expect(call('abs', [-5]), 5);
        expect(call('abs', ['x']), isNull);
      });

      test('round', () {
        expect(call('round', [1.5]), 2);
        expect(call('round', [1.234, 2]), 1.23);
      });

      test('floor/ceil', () {
        expect(call('floor', [1.9]), 1);
        expect(call('ceil', [1.1]), 2);
      });

      test('min/max — 가변 인자·리스트 둘 다', () {
        expect(call('min', [3, 1, 2]), 1);
        expect(call('max', [3, 1, 2]), 3);
        expect(
          call('min', [
            [3, 1, 2],
          ]),
          1,
        );
        expect(call('min', []), isNull); // 빈 인자는 관대
      });

      test('sum — 빈 인자는 0', () {
        expect(
          call('sum', [
            [1, 2, 3],
          ]),
          6,
        );
        expect(call('sum', []), 0);
      });

      test('clamp', () {
        expect(call('clamp', [5, 0, 10]), 5);
        expect(call('clamp', [-1, 0, 10]), 0);
        expect(call('clamp', [11, 0, 10]), 10);
        expect(call('clamp', ['x', 0, 10]), isNull);
      });

      test('lerp — 보간·외삽과 잘못된 인자 폴백', () {
        expect(call('lerp', [0, 10, 0.5]), 5);
        expect(call('lerp', [100, 300, 0]), 100);
        expect(call('lerp', [100, 300, 1]), 300);
        expect(call('lerp', ['x', double.infinity, null]), 0);
      });

      test('mix — 색 보간과 잘못된 색 폴백', () {
        final middle = Color(call('mix', ['#000000', '#ffffff', 0.5])! as int);
        expect(middle.r * 255, closeTo(128, 1));
        expect(middle.g * 255, closeTo(128, 1));
        expect(middle.b * 255, closeTo(128, 1));
        expect(call('mix', ['#123456', '#abcdef', 0]), 0xff123456);
        expect(call('mix', ['#123456', '#abcdef', 1]), 0xffabcdef);
        expect(call('mix', ['#123456', 'bad', 0.5]), 0xff123456);
        expect(call('mix', ['bad', '#abcdef', 0.5]), 0x00000000);
      });
    });

    group('빌트인 — 숫자 포맷', () {
      test('comma', () {
        expect(call('comma', [1234]), '1,234');
        expect(call('comma', [1234567]), '1,234,567');
        expect(call('comma', [1234.5]), '1,234.5');
        expect(call('comma', [-1234]), '-1,234');
        expect(call('comma', ['x']), isNull);
      });

      test('format', () {
        expect(call('format', [1.2, 2]), '1.20');
        expect(call('format', ['x', 2]), isNull);
      });

      test('percent', () {
        expect(call('percent', [0.5]), '50%');
        expect(call('percent', [0.5567, 1]), '55.7%');
      });

      test('currency', () {
        expect(call('currency', [1234]), '₩1,234');
        expect(call('currency', [1234, r'\$']), r'\$1,234');
      });
    });

    group('빌트인 — 문자열', () {
      test('upper/lower/trim/capitalize', () {
        expect(call('upper', ['ab']), 'AB');
        expect(call('lower', ['AB']), 'ab');
        expect(call('trim', [' ab ']), 'ab');
        expect(call('capitalize', ['abc']), 'Abc');
        expect(call('capitalize', ['']), '');
      });

      test('replace', () {
        expect(call('replace', ['aXbXc', 'X', '-']), 'a-b-c');
      });

      test('split', () {
        expect(call('split', ['a,b,c', ',']), ['a', 'b', 'c']);
      });

      test('substring', () {
        expect(call('substring', ['hello', 1]), 'ello');
        expect(call('substring', ['hello', 1, 3]), 'el');
      });

      test('startsWith/endsWith', () {
        expect(call('starts_with', ['hello', 'he']), true);
        expect(call('ends_with', ['hello', 'lo']), true);
      });

      test('contains — 문자열·리스트 겸용', () {
        expect(call('contains', ['hello', 'ell']), true);
        expect(
          call('contains', [
            [1, 2, 3],
            2,
          ]),
          true,
        );
        expect(
          call('contains', [
            [1, 2, 3],
            9,
          ]),
          false,
        );
      });

      test('padStart/padEnd', () {
        expect(call('pad_start', ['5', 3, '0']), '005');
        expect(call('pad_end', ['5', 3, '0']), '500');
        expect(call('pad_start', ['5', 3]), '  5');
      });

      test('repeat', () {
        expect(call('repeat', ['-', 3]), '---');
        expect(call('repeat', ['-', -1]), '');
      });

      test('repeat — 캡 초과는 FormatException', () {
        expect(() => call('repeat', ['x', 200000]), throwsFormatException);
      });
    });

    group('빌트인 — 리스트', () {
      test('join', () {
        expect(
          call('join', [
            [1, 2, 3],
            '-',
          ]),
          '1-2-3',
        );
      });

      test('first/last', () {
        expect(
          call('first', [
            [1, 2, 3],
          ]),
          1,
        );
        expect(
          call('last', [
            [1, 2, 3],
          ]),
          3,
        );
        expect(call('first', [[]]), isNull);
      });

      test('reversed', () {
        expect(
          call('reversed', [
            [1, 2, 3],
          ]),
          [3, 2, 1],
        );
      });

      test('sorted', () {
        expect(
          call('sorted', [
            [3, 1, 2],
          ]),
          [1, 2, 3],
        );
        expect(
          call('sorted', [
            ['b', 'a'],
          ]),
          ['a', 'b'],
        );
      });

      test('range(n)/range(a,b)/range(a,b,step)', () {
        expect(call('range', [3]), [0, 1, 2]);
        expect(call('range', [1, 4]), [1, 2, 3]);
        expect(call('range', [0, 10, 2]), [0, 2, 4, 6, 8]);
        expect(call('range', [5, 0, -1]), [5, 4, 3, 2, 1]);
      });

      test('range — 캡 초과는 FormatException', () {
        expect(() => call('range', [0, 200000]), throwsFormatException);
      });

      test('concat — 리스트를 가변 인자로 이어 붙인다', () {
        expect(
          call('concat', [
            [1, 2],
            [3, 4],
          ]),
          [1, 2, 3, 4],
        );
        expect(
          call('concat', [
            [1],
            [2],
            [3],
          ]),
          [1, 2, 3],
        );
      });

      test('concat — 리스트가 아닌 인자는 건너뛴다', () {
        expect(
          call('concat', [
            [1],
            null,
            [2],
          ]),
          [1, 2],
        );
        expect(
          call('concat', [
            [1],
            5,
            [2],
          ]),
          [1, 2],
        );
        expect(
          call('concat', [
            null,
            [1],
          ]),
          [1],
        );
        expect(call('concat'), <Object?>[]);
      });

      test('concat — 입력 리스트를 변경하지 않는다', () {
        final first = [1, 2];
        final second = [3, 4];

        expect(call('concat', [first, second]), [1, 2, 3, 4]);
        expect(first, [1, 2]);
        expect(second, [3, 4]);
      });

      test('concat — 캡 초과는 FormatException', () {
        final first = call('range', [100000]);
        final second = call('range', [100000]);

        expect(() => call('concat', [first, second]), throwsFormatException);
      });
    });

    group('빌트인 — 맵', () {
      test('keys/values', () {
        expect(
          call('keys', [
            {'a': 1, 'b': 2},
          ]),
          ['a', 'b'],
        );
        expect(
          call('values', [
            {'a': 1, 'b': 2},
          ]),
          [1, 2],
        );
      });

      test('get', () {
        expect(
          call('get', [
            {'a': 1},
            'a',
          ]),
          1,
        );
        expect(
          call('get', [
            {'a': 1},
            'b',
            'fb',
          ]),
          'fb',
        );
      });

      test('has', () {
        expect(
          call('has', [
            {'a': 1},
            'a',
          ]),
          true,
        );
        expect(
          call('has', [
            {'a': 1},
            'b',
          ]),
          false,
        );
      });
    });
  });
}
