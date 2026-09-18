import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/environment/map_environment.dart';
import 'package:sdui_engine/src/runtime/interpreter/expression_evaluator.dart';
import 'package:sdui_engine/src/ir/compiled_value.dart';
import 'package:sdui_engine/src/ir/expression.dart';

void main() {
  group('CompiledValue', () {
    group('resolve_map', () {
      test('Expression은 평가하고 리터럴은 그대로, 중첩은 재귀한다', () {
        final env = const MapEnvironment({'count': 4, 'name': 'kim'});
        final resolved = ExpressionEvaluator.resolveMap({
          'a': Expression.compile(r'count + 1'),
          'b': 'literal',
          'c': {'inner': Expression.compile(r'name')},
          'd': [Expression.compile(r'count'), 7],
        }, env);

        expect(resolved, {
          'a': 5,
          'b': 'literal',
          'c': {'inner': 'kim'},
          'd': [4, 7],
        });
      });

      test('바인딩은 env 체인을 타고 가까운 층이 이긴다(렉시컬 섀도잉)', () {
        final outer = const MapEnvironment({'x': 'outer', 'y': 'only-outer'});
        final inner = MapEnvironment({'x': 'inner'}, parent: outer);
        final resolved = ExpressionEvaluator.resolveMap({
          'x': Expression.compile(r'x'),
          'y': Expression.compile(r'y'),
        }, inner);

        expect(resolved, {'x': 'inner', 'y': 'only-outer'});
      });
    });

    group('roots_of', () {
      test('트리 전체의 Expression root를 모은다(중첩 포함, 리터럴 제외)', () {
        final roots = CompiledValue.rootsOf({
          'a': Expression.compile(r'count + step'),
          'b': 'literal',
          'c': {'inner': Expression.compile(r'name')},
          'd': [Expression.compile(r'items[i]')],
        });

        expect(roots, {'count', 'step', 'name', 'items', 'i'});
      });

      test('Expression이 없으면 빈 집합', () {
        expect(
          CompiledValue.rootsOf({
            'a': 1,
            'b': ['x'],
          }),
          isEmpty,
        );
      });
    });
  });
}
