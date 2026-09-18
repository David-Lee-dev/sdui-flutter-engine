import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/action_compiler.dart';
import 'package:sdui_engine/src/ir/model/action/command.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';

final throwsInvalidTemplate = throwsA(isA<InvalidTemplateException>());

Action compile(Object? def) => ActionCompiler.compile(def, 'root');

void main() {
  group('ActionCompiler', () {
    group('구조', () {
      test('단일 커맨드(_type)는 배치 하나짜리 steps', () {
        final action = compile({'_type': 'set', 'loading': true});

        expect(action.steps, hasLength(1)); // 배치 1
        expect(action.steps.single, hasLength(1)); // 커맨드 1
        final cmd = action.steps.single.single;
        expect(cmd.type, 'set');
        expect(cmd.params, {'loading': true});
      });

      test('list 값은 flow — 바깥=순차 배치·안=병렬(중첩 list)', () {
        final action = compile([
          [
            {'_type': 'set', 'a': 1},
            {'_type': 'set', 'b': 2},
          ], // 배치1: 병렬 2 (중첩 list = 동시)
          {'_type': 'log'}, // 배치2: 단일(맵 → 한 배치)
        ]);

        expect(action.steps, hasLength(2));
        expect(action.steps[0], hasLength(2)); // 병렬 2
        expect(action.steps[0].map((c) => c.type), ['set', 'set']);
        expect(action.steps[1], hasLength(1));
        expect(action.steps[1].single.type, 'log');
      });

      test('_type 없는 커맨드 맵은 InvalidTemplateException', () {
        expect(() => compile({'loading': true}), throwsInvalidTemplate);
      });

      test('_type이 빈 문자열/비문자열이면 InvalidTemplateException', () {
        expect(() => compile({'_type': ''}), throwsInvalidTemplate);
        expect(() => compile({'_type': 3}), throwsInvalidTemplate);
      });
    });

    group('params 컴파일', () {
      test(r'$로 시작하는 값은 Expression (바인딩·산술 모두)', () {
        final cmd = compile({
          '_type': 'set',
          'user': r'${user}',
          'next': r'${count + 1}',
        }).steps.single.single;

        expect(cmd.params['user'], isA<Expression>());
        expect((cmd.params['user'] as Expression).source, r'user');
        expect(cmd.params['next'], isA<Expression>());
        expect((cmd.params['next'] as Expression).source, r'count + 1');
      });

      test('리터럴은 그대로 (문자열·불리언·숫자)', () {
        final cmd = compile({
          '_type': 'toast',
          'message': '품절',
          'flag': false,
          'n': 8,
        }).steps.single.single;

        expect(cmd.params, {'message': '품절', 'flag': false, 'n': 8});
      });

      test(r'${…}는 $로 시작하지 않는 식도 Expression으로', () {
        final cmd = compile({
          '_type': 'set',
          'ok': r'${not busy}',
        }).steps.single.single;

        expect(cmd.params['ok'], isA<Expression>());
        expect((cmd.params['ok'] as Expression).source, r'not busy');
      });

      test('중첩 Map/List 안의 바인딩도 재귀 컴파일', () {
        final cmd = compile({
          '_type': 'net',
          'args': {'id': r'${user_id}', 'fixed': 1},
        }).steps.single.single;

        final args = cmd.params['args'] as Map<String, Object?>;
        expect(args['id'], isA<Expression>());
        expect(args['fixed'], 1);
      });

      test('식 문법 오류는 InvalidTemplateException (마운트-치명)', () {
        expect(
          () => compile({'_type': 'set', 'x': r'${a +}'}), // 깨진 식
          throwsInvalidTemplate,
        );
      });
    });

    group('핸들러', () {
      test('_then·_error·_always를 Flow로 담고 params엔 안 샌다', () {
        final cmd = compile({
          '_type': 'net',
          'query_id': 'claim',
          '_then': {'_type': 'set', 'done': true},
          '_error': {
            'RW0001': {'_type': 'toast', 'message': '품절'},
            '_': {'_type': 'set', 'done': false},
          },
          '_always': {'_type': 'log'},
        }).steps.single.single;

        expect(cmd.params, {'query_id': 'claim'}); // 핸들러 안 샘
        expect(cmd.then!.single.single.type, 'set');
        expect(cmd.onError!.keys, containsAll(['RW0001', '_']));
        expect(cmd.onError!['RW0001']!.single.single.type, 'toast');
        expect(cmd.always!.single.single.type, 'log');
      });

      test('_error가 맵이 아니면 InvalidTemplateException', () {
        expect(
          () => compile({'_type': 'net', '_error': 'nope'}),
          throwsInvalidTemplate,
        );
      });
    });

    group('_dedupe', () {
      test('_dedupe를 파싱하고 params엔 안 샌다', () {
        final action = compile({'_dedupe': false, '_type': 'set', 'x': 1});
        expect(action.dedupe, false);
        expect(action.steps.single.single.params, {'x': 1}); // _dedupe 안 샘
      });

      test('_dedupe 없으면 기본값 true', () {
        expect(compile({'_type': 'set', 'x': 1}).dedupe, true);
      });

      test('_dedupe가 불리언이 아니면 InvalidTemplateException', () {
        expect(
          () => compile({'_dedupe': 1, '_type': 'set'}),
          throwsInvalidTemplate,
        );
      });
    });

    // 미지의 `_`-키는 데이터가 아니라 오타난 엔진 키다 — 조용히 무시(_dedup)되거나
    // driver 인자로 둔갑(_backgound)하면 안 된다 (L7).
    group('예약키 엄격성', () {
      test('커맨드의 미지 _키는 InvalidTemplateException (_dedup 오타)', () {
        // `_dedupe`(액션 레벨)와 달리 `_dedup`은 커맨드에 남아 미지 _키로 거부된다.
        expect(
          () => compile({'_type': 'log', '_dedup': false}),
          throwsInvalidTemplate,
        );
      });

      test('커맨드 레벨의 미지 _키는 InvalidTemplateException (_backgound 오타)', () {
        expect(
          () => compile({'_type': 'sys_haptic', '_backgound': true}),
          throwsInvalidTemplate,
        );
      });

      test('flow 안 커맨드의 _dedupe는 커맨드 키가 아니다 (액션 레벨 전용)', () {
        expect(
          () => compile([
            {'_type': 'set', '_dedupe': false, 'x': 1},
          ]),
          throwsInvalidTemplate,
        );
      });

      test('background 커맨드의 핸들러는 컴파일 거부 — 런타임이 안 도는 가지 (M1)', () {
        for (final handler in ['_then', '_error', '_always']) {
          expect(
            () => compile({
              '_type': 'sys_haptic',
              '_background': true,
              handler: {'_type': 'log'},
            }),
            throwsInvalidTemplate,
            reason: 'background는 핸들러가 절대 안 돈다 — $handler는 도달 불가',
          );
        }
      });

      test('액션 컴파일 에러 path에 액션 이름·배치/커맨드 인덱스가 실린다 (M6)', () {
        // 여러 액션·배치 속 어느 커맨드가 문제인지 path만으로 찾아지게.
        try {
          ActionCompiler.compile([
            [
              {'_type': 'set', 'a': 1},
              {'_type': 'set', 'b': r'${broken +}'}, // 배치0, 커맨드1의 깨진 식
            ],
          ], 'root/_action/inc');
          fail('should throw');
        } on InvalidTemplateException catch (e) {
          expect(e.path, contains('root/_action/inc'));
          expect(e.path, contains('[0][1]'));
        }
      });

      test('_error의 code 키(_ 기본 가지 포함)는 값 공간이라 자유 (양성)', () {
        expect(
          () => compile({
            '_type': 'net',
            '_error': {
              '_': {'_type': 'log'},
            },
          }),
          returnsNormally,
        );
      });
    });

    group('_background', () {
      test('_background를 커맨드에 담고 params엔 안 샌다', () {
        final cmd = compile({
          '_type': 'sys_haptic',
          '_background': true,
          'style': 'light',
        }).steps.single.single;
        expect(cmd.background, true);
        expect(cmd.params, {'style': 'light'});
      });

      test('_background 없으면 기본값 false', () {
        expect(
          compile({'_type': 'set', 'x': 1}).steps.single.single.background,
          false,
        );
      });

      test('_background가 불리언이 아니면 InvalidTemplateException', () {
        expect(
          () => compile({'_type': 'sys_haptic', '_background': 1}),
          throwsInvalidTemplate,
        );
      });
    });

    group('_when', () {
      test(
        '_when expression compiles onto command and does not leak into params',
        () {
          final cmd = compile({
            '_type': 'set',
            '_when': r'${x > 0}',
            'value': 1,
          }).steps.single.single;

          expect(cmd.when, isNotNull);
          expect(cmd.when!.source, 'x > 0');
          expect(cmd.params, {'value': 1});
        },
      );

      test('command without _when has a null guard', () {
        final cmd = compile({'_type': 'set', 'value': 1}).steps.single.single;

        expect(cmd.when, isNull);
      });

      test('_when rejects interpolated text and non-expression strings', () {
        expect(
          () => compile({'_type': 'set', '_when': r'prefix ${x}'}),
          throwsInvalidTemplate,
        );
        expect(
          () => compile({'_type': 'set', '_when': 'x > 0'}),
          throwsInvalidTemplate,
        );
        expect(
          () => compile({'_type': 'set', '_when': true}),
          throwsInvalidTemplate,
        );
      });
    });
  });
}
