import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/environment/map_environment.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import 'package:sdui_engine/src/runtime/interpreter/binding/loop_resolver.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';

/// _loop directive를 손으로 짓는 헬퍼(컴파일러를 안 거치고 LoopResolver만 테스트).
LoopDirective loopOver(Object? source, {String key = r'it.id'}) =>
    LoopDirective(
      source: source is String ? Expression.compile(source) : source,
      as: 'it',
      index: 'index',
      keyExpression: Expression.compile(key),
      child: const PlainDirective(
        type: 'text',
        props: {},
        children: [],
        roots: <String>{},
      ),
      path: 'test',
    );

void main() {
  group('LoopResolver', () {
    group('resolve', () {
      test('소스 리스트를 항목별 프레임·키로 펼친다', () {
        final items = LoopResolver.resolve(
          loopOver(r'items'),
          const MapEnvironment({
            'items': [
              {'id': 'a'},
              {'id': 'b'},
            ],
          }),
        );

        expect(items.map((i) => i.key), ['a', 'b']);
        expect(items[0].frame['index'], 0);
        expect(items[1].frame['it'], {'id': 'b'});
      });

      test('소스가 리스트가 아니면 빈 목록', () {
        expect(
          LoopResolver.resolve(loopOver(r'nope'), const MapEnvironment({})),
          isEmpty,
        );
      });

      test('컴파일된 literal list의 중첩 바인딩을 바깥 환경에서 푼다', () {
        final items = LoopResolver.resolve(
          loopOver([
            {
              'id': Expression.compile(r'outer'),
              'value': Expression.compile(r'outer'),
            },
            {'id': 'fixed', 'value': 2},
          ]),
          const MapEnvironment({'outer': 'bound'}),
        );

        expect(items.map((item) => item.key), ['bound', 'fixed']);
        expect(items.first.frame['it'], {'id': 'bound', 'value': 'bound'});
      });

      test('키가 null로 풀리면 FormatException', () {
        expect(
          () => LoopResolver.resolve(
            loopOver(r'items', key: r'it.missing'),
            const MapEnvironment({
              'items': [
                {'id': 'a'},
              ],
            }),
          ),
          throwsFormatException,
        );
      });

      test('숫자 id는 문자열 키로 정규화한다', () {
        final items = LoopResolver.resolve(
          loopOver(r'items'),
          const MapEnvironment({
            'items': [
              {'id': 1},
              {'id': 2},
            ],
          }),
        );

        expect(items.map((i) => i.key), ['1', '2']);
      });

      test('중복 키면 FormatException', () {
        expect(
          () => LoopResolver.resolve(
            loopOver(r'items'),
            const MapEnvironment({
              'items': [
                {'id': 'a'},
                {'id': 'a'},
              ],
            }),
          ),
          throwsFormatException,
        );
      });

      test('키가 map이면 FormatException', () {
        expect(
          () => LoopResolver.resolve(
            loopOver(r'items', key: r'it'),
            const MapEnvironment({
              'items': [
                {'id': 'a'},
              ],
            }),
          ),
          throwsFormatException,
        );
      });

      test('키가 list면 FormatException', () {
        expect(
          () => LoopResolver.resolve(
            loopOver(r'items'),
            const MapEnvironment({
              'items': [
                {
                  'id': [1, 2],
                },
              ],
            }),
          ),
          throwsFormatException,
        );
      });

      test('키가 NaN이면 FormatException', () {
        expect(
          () => LoopResolver.resolve(
            loopOver(r'items'),
            const MapEnvironment({
              'items': [
                {'id': double.nan},
              ],
            }),
          ),
          throwsFormatException,
        );
      });

      test('산술 키도 Expression으로 해석한다 (F6 — 옛 BindingTarget은 못 풀던 것)', () {
        final items = LoopResolver.resolve(
          loopOver(r'items', key: r'it.a + it.b'),
          const MapEnvironment({
            'items': [
              {'a': 1, 'b': 2},
              {'a': 2, 'b': 2},
            ],
          }),
        );

        expect(items.map((i) => i.key), ['3', '4']); // 1+2, 2+2
      });

      test('인덱스·프레임 밖 상태를 섞은 소스·키도 Expression으로 (F6)', () {
        final items = LoopResolver.resolve(
          loopOver(r'data.rows', key: r'it.id'),
          const MapEnvironment({
            'data': {
              'rows': [
                {'id': 'x'},
                {'id': 'y'},
              ],
            },
          }),
        );

        expect(items.map((i) => i.key), ['x', 'y']);
      });
    });
  });
}
