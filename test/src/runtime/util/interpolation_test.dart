import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/value_compiler.dart';
import 'package:sdui_engine/src/runtime/environment/map_environment.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/ir/compiled_value.dart';
import 'package:sdui_engine/src/runtime/interpreter/expression_evaluator.dart';

/// 템플릿 값을 컴파일한 뒤 [state]에 대고 평가한 결과.
Object? _eval(Object? template, [Map<String, Object?> state = const {}]) =>
    ExpressionEvaluator.resolveValue(
      ValueCompiler.value(template, 'test'),
      MapEnvironment(Map.of(state)),
    );

void main() {
  group(r'ValueCompiler ${…} 문법', () {
    group('통짜 표현식 (주변 텍스트 0 → 타입 보존)', () {
      test('바인딩', () => expect(_eval(r'${count}', {'count': 5}), 5));
      test('산술', () => expect(_eval(r'${count + 1}', {'count': 5}), 6));
      test(
        '불리언(predicate용)',
        () => expect(_eval(r'${show}', {'show': true}), true),
      );
      test('경로', () {
        expect(
          _eval(r'${user.name}', {
            'user': {'name': 'kim'},
          }),
          'kim',
        );
      });
      test('리스트', () {
        expect(
          _eval(r'${items}', {
            'items': [1, 2],
          }),
          [1, 2],
        );
      });
    });

    group('보간 (텍스트 섞임 → 항상 문자열)', () {
      test('중간 치환', () {
        expect(
          _eval(r'phase: ${phase} 입니다', {'phase': 'mounted'}),
          'phase: mounted 입니다',
        );
      });
      test('숫자도 문자열화', () => expect(_eval(r'n=${count}', {'count': 5}), 'n=5'));
      test('여러 조각', () {
        expect(_eval(r'${a}-${b}', {'a': 'x', 'b': 'y'}), 'x-y');
      });
      test('null은 빈 문자열', () => expect(_eval(r'[${missing}]'), '[]'));
      test(r'$$ 로 리터럴 ${…} 이스케이프', () => expect(_eval(r'$${x}'), r'${x}'));
    });

    group('리터럴', () {
      test(r'${} 없으면 리터럴', () => expect(_eval('phase: hi'), 'phase: hi'));
      test(r'$5.00 는 리터럴(크래시 아님)', () => expect(_eval(r'$5.00'), r'$5.00'));
      test(r'$user는 중괄호가 없으면 리터럴', () {
        expect(_eval(r'$user', {'user': 'kim'}), r'$user');
      });
      test(r'{_expr: "x"}는 리터럴 맵', () {
        expect(_eval({'_expr': 'x'}, {'x': 5}), {'_expr': 'x'});
      });
    });

    group('문자열 경계 (§0.5)', () {
      test('식 안 문자열의 unescaped } 는 보간 끝이 아니다', () {
        expect(_eval(r'${"a}b"}'), 'a}b');
      });
      test(r'식 안 문자열의 escape된 따옴표(\") 를 존중한다 — 뒤 } 를 보간 끝으로 오인 안 함', () {
        // 회귀 방어: escape 처리가 없으면 \" 가 문자열을 조기 종료해 뒤의 } 로 식이 잘려 마운트-치명.
        expect(_eval(r'${"a\"}b"}'), 'a"}b');
      });
    });

    group('오류', () {
      test(r'닫히지 않은 ${ 는 마운트-치명', () {
        expect(
          () => ValueCompiler.value(r'a ${b', 'p'),
          throwsA(isA<InvalidTemplateException>()),
        );
      });
      test(r'${$user}의 $ 바인딩 접두사는 마운트-치명', () {
        expect(
          () => ValueCompiler.value(r'${$user}', 'p'),
          throwsA(isA<InvalidTemplateException>()),
        );
      });
    });
  });

  group('roots (반응성)', () {
    test('보간의 조각 식 root가 모두 잡힌다', () {
      final compiled = ValueCompiler.map({'label': r'${a} ${b.c}'}, 'p');
      expect(CompiledValue.rootsOf(compiled), {'a', 'b'});
    });
  });
}
