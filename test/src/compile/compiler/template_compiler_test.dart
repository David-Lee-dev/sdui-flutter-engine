import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/event_timing.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import 'package:sdui_engine/src/ir/compiled_value.dart';
import 'package:sdui_engine/src/ir/model/ui_node.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';

final throwsInvalidTemplate = throwsA(isA<InvalidTemplateException>());

/// 테스트용 노드 빌더 — 파서와 똑같이 flat attr map을 sigil로 갈라 [UiNode]를 만든다.
/// 맨몸 키 → `props`, `_` 접두 키 → `reserved`. 실제 파서 경로와 같은 분리를 태워, 컴파일러
/// 테스트가 프로덕션과 동일한 UiNode 형태를 받게 한다.
UiNode uiNode({
  required String type,
  Map<String, Object?> attrs = const {},
  List<UiNode> children = const [],
  String? key,
}) {
  final props = <String, Object?>{};
  final reserved = <String, Object?>{};
  attrs.forEach((k, v) => (k.startsWith('_') ? reserved : props)[k] = v);
  return UiNode(
    type: type,
    props: props,
    reserved: reserved,
    children: children,
    key: key,
  );
}

void main() {
  group('TemplateCompiler', () {
    group('build_directive_tree', () {
      test('plain 노드 → 그 노드를 실은 PlainDirective', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(type: 'text'),
        );

        expect(directive, isA<PlainDirective>());
        expect((directive as PlainDirective).type, 'text');
        expect(directive.children, isEmpty);
      });

      test('자식을 재귀 해석해 children directive로 담는다', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'column',
            children: [
              uiNode(type: 'text'),
              uiNode(type: 'box', attrs: {'_if': r'${show}'}),
            ],
          ),
        );

        final node = directive as PlainDirective;
        expect(node.children, hasLength(2));
        expect(node.children[0], isA<PlainDirective>());
        expect(node.children[1], isA<ConditionDirective>()); // _if가 자식을 감쌈
      });

      test('_if 노드 → 가지 하나짜리 ConditionDirective; 몸통에 _if 안 샘(contextual)', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(type: 'text', attrs: {'_if': r'${show}', 'value': 'hi'}),
        );

        expect(directive, isA<ConditionDirective>());
        final cond = directive as ConditionDirective;
        expect(cond.branches, hasLength(1));
        expect(cond.branches.single.predicate.source, r'show');
        final body = cond.branches.single.body as PlainDirective;
        expect(body.props.containsKey('_if'), isFalse); // 마커 소비됨
        expect(body.props['value'], 'hi'); // 일반 prop은 남음
        expect(cond.fallback, isNull);
      });

      test('_if 맨몸 식별자는 InvalidTemplateException (마운트-치명)', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(type: 'text', attrs: {'_if': 'show'}),
          ),
          throwsInvalidTemplate,
        );
      });

      test('_scope 노드 → PlainDirective를 감싼 ScopeDirective, config 원본 보존', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text',
            attrs: {
              '_scope': {
                '_state': {'count': 0},
              },
            },
          ),
        );

        expect(directive, isA<ScopeDirective>());
        final scope = directive as ScopeDirective;
        expect(scope.config.state, {'count': 0});
        expect(scope.child, isA<PlainDirective>());
      });

      test('_scope skeleton subtree compiles into its own directive tree', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text',
            attrs: {
              '_scope': {
                '_skeleton': {
                  '_type': 'column',
                  '_children': [
                    {'_type': 'box'},
                  ],
                },
              },
            },
          ),
        );

        final skeleton = (directive as ScopeDirective).skeleton;
        expect(skeleton, isA<PlainDirective>());
        expect((skeleton as PlainDirective).type, 'column');
        expect(skeleton.children.single, isA<PlainDirective>());
        expect(skeleton.path, '/_skeleton');
      });

      test('_morph 노드 → 필드가 컴파일된 MorphDirective', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text',
            attrs: {
              '_morph': {
                '_from': 0,
                '_to': r'${score}',
                '_as': 'n',
                '_duration': 800,
                '_curve': 'linear',
                '_delay': 20,
                '_trigger': r'${epoch}',
                '_repeat': true,
                '_reverse': true,
              },
            },
          ),
        );

        final morph = directive as MorphDirective;
        expect(morph.from!.source, '0');
        expect(morph.to.roots, {'score'});
        expect(morph.as, 'n');
        expect(morph.durationMs, 800);
        expect(morph.curve, 'linear');
        expect(morph.delayMs, 20);
        expect(morph.trigger!.roots, {'epoch'});
        expect(morph.repeat, isTrue);
        expect(morph.reverse, isTrue);
        expect(morph.child, isA<PlainDirective>());
      });

      test('_morph는 scope 안쪽에서 node를 직접 감싼다', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text',
            attrs: {
              '_scope': {
                '_state': {'score': 10},
              },
              '_morph': {'_to': r'${score}', '_as': 'n'},
            },
          ),
        );

        final scope = directive as ScopeDirective;
        expect(scope.child, isA<MorphDirective>());
        expect((scope.child as MorphDirective).child, isA<PlainDirective>());
      });

      test('_morph 필수 _to/_as 누락과 미지 키는 InvalidTemplateException', () {
        for (final morph in [
          {'_as': 'n'},
          {'_to': 1},
          {'_to': 1, '_as': 'n', '_unknown': true},
        ]) {
          expect(
            () => TemplateCompiler.buildDirectiveTree(
              uiNode(type: 'text', attrs: {'_morph': morph}),
            ),
            throwsInvalidTemplate,
          );
        }
      });

      test('_morph는 cond/switch control 노드에서 거부된다', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'cond',
              attrs: {
                '_morph': {'_to': 1, '_as': 'n'},
              },
            ),
          ),
          throwsInvalidTemplate,
        );
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'switch',
              attrs: {
                '_value': r'${kind}',
                '_morph': {'_to': 1, '_as': 'n'},
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('마커 순서: _loop → _if → _scope → node', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text',
            attrs: {
              '_scope': {'_state': <String, Object?>{}},
              '_if': r'${show}',
              '_loop': {'_in': r'${items}', '_key': r'${it.id}'},
            },
          ),
        );

        expect(directive, isA<LoopDirective>());
        final loop = directive as LoopDirective;
        expect(loop.child, isA<ConditionDirective>());
        final condBody =
            (loop.child as ConditionDirective).branches.single.body;
        expect(condBody, isA<ScopeDirective>());
        expect((condBody as ScopeDirective).child, isA<PlainDirective>());
      });

      test('_loop 노드 → PlainDirective를 감싼 LoopDirective, 바인딩 파싱', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text',
            attrs: {
              '_loop': {'_in': r'${items}', '_as': 'it', '_key': r'${it.id}'},
            },
          ),
        );

        expect(directive, isA<LoopDirective>());
        final loop = directive as LoopDirective;
        expect(loop.source, isA<Expression>());
        if (loop.source case final Expression source) {
          expect(source.source, r'items');
        }
        expect(loop.as, 'it');
        expect(loop.index, 'index'); // 기본값
        expect(loop.keyExpression.source, r'it.id');
        expect(loop.child, isA<PlainDirective>());
        expect(loop.wrap, 'column'); // 기본값
      });

      test('_loop._in literal list를 props와 같은 방식으로 컴파일한다', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text',
            attrs: {
              '_loop': {
                '_in': [
                  {'v': 1, 'outer': r'${outer}'},
                  {'v': 2},
                ],
                '_key': r'${item.v}',
              },
              'value': r'${item.v}',
            },
          ),
        );

        expect(directive, isA<LoopDirective>());
        final loop = directive as LoopDirective;
        expect(loop.source, isA<List<Object?>>());
        expect(CompiledValue.rootsOf({'source': loop.source}), {'outer'});
      });

      test('_loop._wrap을 읽는다(허용 값)', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text',
            attrs: {
              '_loop': {
                '_in': r'${items}',
                '_key': r'${it.id}',
                '_wrap': 'list',
              },
            },
          ),
        );
        expect((directive as LoopDirective).wrap, 'list');
      });

      test('_loop._wrap 이름 유효성은 컴파일러가 아니라 validator가 본다 (미지 값도 컴파일 통과)', () {
        // 컴파일러는 wrap 이름 유효성을 모른다 — 구조만 파싱하고 이름 그대로 통과시킨다(미지 위젯·
        // driver type과 같은 취급). 미지 `_wrap`("carousel")을 마운트-치명으로 잡는 건 TemplateValidator가
        // 등록된 wrap 셋에 대조해서 한다(template_validator_test 참조).
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text',
            attrs: {
              '_loop': {
                '_in': r'${items}',
                '_key': r'${it.id}',
                '_wrap': 'carousel',
              },
            },
          ),
        );
        expect((directive as LoopDirective).wrap, 'carousel');
      });

      test('_loop에 key가 없으면 InvalidTemplateException (필수)', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'text',
              attrs: {
                '_loop': {'_in': r'${items}'},
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('_loop + _if → Loop가 If를 감싸고 If가 Node를 감싼다(순서)', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text',
            attrs: {
              '_loop': {'_in': r'${items}', '_key': r'${it.id}'},
              '_if': r'${it.active}',
            },
          ),
        );

        expect(directive, isA<LoopDirective>());
        final inner = (directive as LoopDirective).child;
        expect(inner, isA<ConditionDirective>());
        expect(
          (inner as ConditionDirective).branches.single.body,
          isA<PlainDirective>(),
        );
      });

      test('_loop가 map이 아니면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(type: 'text', attrs: {'_loop': 'nope'}),
          ),
          throwsInvalidTemplate,
        );
      });

      test('_if가 문자열이 아니면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(type: 'text', attrs: {'_if': 42}),
          ),
          throwsInvalidTemplate,
        );
      });

      test('switch 노드 → SwitchDirective, case 라벨·default 짝짓기', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'switch',
            attrs: {'_value': r'${status}'},
            children: [
              uiNode(type: 'text', attrs: {'_case': 'loading'}),
              uiNode(type: 'text', attrs: {'_case': 'error'}),
              uiNode(type: 'text', attrs: {'_default': true}),
            ],
          ),
        );

        expect(directive, isA<SwitchDirective>());
        final sw = directive as SwitchDirective;
        expect(sw.selector.source, r'status');
        expect(sw.cases.map((c) => c.value), ['loading', 'error']);
        expect(sw.cases[0].branch, isA<PlainDirective>());
        expect(sw.fallback, isA<PlainDirective>());
      });

      test('switch가 default 없이도 만들어진다(빈 fallback)', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'switch',
            attrs: {'_value': r'${status}'},
            children: [
              uiNode(type: 'text', attrs: {'_case': 'a'}),
            ],
          ),
        );

        expect((directive as SwitchDirective).fallback, isNull);
      });

      test('switch 라벨은 num·bool도 되고 _default는 위치 무관', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'switch',
            attrs: {'_value': r'${n}'},
            children: [
              uiNode(type: 'text', attrs: {'_default': true}), // 먼저 와도 됨
              uiNode(type: 'text', attrs: {'_case': 1}),
              uiNode(type: 'box', attrs: {'_case': true}),
            ],
          ),
        );

        final sw = directive as SwitchDirective;
        expect(sw.cases.map((c) => c.value), [1, true]);
        expect(sw.fallback, isA<PlainDirective>()); // 위치와 무관하게 fallback
      });

      test('switch 셀렉터는 Expression — 인덱스식도 root를 정확히 모은다 (F6)', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'switch',
            attrs: {'_value': r'${items[i]}'},
            children: [
              uiNode(type: 'text', attrs: {'_case': 'a'}),
            ],
          ),
        );

        final sw = directive as SwitchDirective;
        expect(sw.selector.source, r'items[i]');
        expect(sw.roots, {'items', 'i'}); // 구독=해석 같은 문법
      });

      test('switch on이 문법 오류면 컴파일에서 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'switch',
              attrs: {'_value': r'${items[}'}, // 깨진 식
              children: [
                uiNode(type: 'text', attrs: {'_case': 'a'}),
              ],
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('switch 자식이 _case와 _if를 함께 가지면 case 몸통이 If로 감싸진다', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'switch',
            attrs: {'_value': r'${s}'},
            children: [
              uiNode(type: 'text', attrs: {'_case': 'a', '_if': r'${g}'}),
            ],
          ),
        );

        final sw = directive as SwitchDirective;
        expect(
          sw.cases.single.branch,
          isA<ConditionDirective>(),
        ); // _if가 case 몸통 감쌈
      });

      test('switch에 on 셀렉터가 없으면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'switch',
              children: [
                uiNode(type: 'text', attrs: {'_case': 'a'}),
              ],
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('switch case 라벨이 중복이면 InvalidTemplateException (1과 1.0 포함)', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'switch',
              attrs: {'_value': r'${status}'},
              children: [
                uiNode(type: 'text', attrs: {'_case': 1}),
                uiNode(type: 'box', attrs: {'_case': 1.0}),
              ],
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('switch _case가 바인딩이면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'switch',
              attrs: {'_value': r'${status}'},
              children: [
                uiNode(type: 'text', attrs: {'_case': r'${x}'}),
              ],
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('switch _case가 스칼라가 아니면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'switch',
              attrs: {'_value': r'${status}'},
              children: [
                uiNode(type: 'text', attrs: {'_case': <String, Object?>{}}),
              ],
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('switch에 _default가 둘이면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'switch',
              attrs: {'_value': r'${status}'},
              children: [
                uiNode(type: 'text', attrs: {'_default': true}),
                uiNode(type: 'box', attrs: {'_default': true}),
              ],
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('switch 자식에 _case도 _default도 없으면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'switch',
              attrs: {'_value': r'${status}'},
              children: [uiNode(type: 'text')],
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('switch에 _case가 하나도 없으면(default만) InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'switch',
              attrs: {'_value': r'${status}'},
              children: [
                uiNode(type: 'text', attrs: {'_default': true}),
              ],
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('switch가 _if로 감싸지면 ConditionDirective(child: SwitchDirective)', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'switch',
            attrs: {'_value': r'${status}', '_if': r'${show}'},
            children: [
              uiNode(type: 'text', attrs: {'_case': 'a'}),
            ],
          ),
        );

        expect(directive, isA<ConditionDirective>());
        expect(
          (directive as ConditionDirective).branches.single.body,
          isA<SwitchDirective>(),
        );
      });

      test('cond 노드 → ConditionDirective, 가지·fallback 순서 보존', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'cond',
            children: [
              uiNode(type: 'text', attrs: {'_if': r'${a}', 'value': 'A'}),
              uiNode(type: 'text', attrs: {'_if': r'${b}'}), // 예전 _elif → _if
              uiNode(type: 'box', attrs: {'_else': true, 'value': 'C'}),
            ],
          ),
        );

        expect(directive, isA<ConditionDirective>());
        final cond = directive as ConditionDirective;
        expect(cond.branches.map((b) => b.predicate.source), [r'a', r'b']);
        expect(cond.branches[0].body, isA<PlainDirective>());
        expect(cond.fallback, isA<PlainDirective>());
        // contextual 소비: 가지·fallback 몸통에 마커가 안 샌다
        final body0 = cond.branches[0].body as PlainDirective;
        expect(body0.props.containsKey('_if'), isFalse);
        expect(body0.props['value'], 'A');
        final fb = cond.fallback as PlainDirective;
        expect(fb.props.containsKey('_else'), isFalse);
        expect(fb.props['value'], 'C');
      });

      test('cond가 _else 없이도 만들어진다(빈 fallback)', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'cond',
            children: [
              uiNode(type: 'text', attrs: {'_if': r'${a}'}),
            ],
          ),
        );

        expect((directive as ConditionDirective).fallback, isNull);
      });

      test('cond는 위치 무관 — _else가 먼저 와도 되고 항상 마지막 평가', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'cond',
            children: [
              uiNode(type: 'box', attrs: {'_else': true}), // 먼저 와도 됨
              uiNode(type: 'text', attrs: {'_if': r'${a}'}),
            ],
          ),
        );

        final cond = directive as ConditionDirective;
        expect(cond.branches.map((b) => b.predicate.source), [r'a']);
        expect(cond.fallback, isA<PlainDirective>());
      });

      test('cond는 _if 반복 가능 — 배열 순서가 우선순위', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'cond',
            children: [
              uiNode(type: 'text', attrs: {'_if': r'${a}'}),
              uiNode(type: 'text', attrs: {'_if': r'${b}'}),
            ],
          ),
        );

        expect(
          (directive as ConditionDirective).branches.map(
            (b) => b.predicate.source,
          ),
          [r'a', r'b'],
        );
      });

      test('cond 자식이 _if·_else 둘 다면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'cond',
              children: [
                uiNode(type: 'text', attrs: {'_if': r'${a}', '_else': true}),
              ],
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('cond 자식에 마커가 없으면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'cond',
              children: [uiNode(type: 'text')],
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('cond의 _else가 true가 아니면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'cond',
              children: [
                uiNode(type: 'box', attrs: {'_else': false}),
              ],
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('cond에 _else가 둘이면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'cond',
              children: [
                uiNode(type: 'text', attrs: {'_if': r'${a}'}),
                uiNode(type: 'box', attrs: {'_else': true}),
                uiNode(type: 'text', attrs: {'_else': true}),
              ],
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('cond가 _else만 있어도 fallback으로 만들어진다', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'cond',
            children: [
              uiNode(type: 'box', attrs: {'_else': true, 'value': 'fallback'}),
            ],
          ),
        );

        final cond = directive as ConditionDirective;
        expect(cond.branches, isEmpty);
        expect(cond.fallback, isA<PlainDirective>());
        expect((cond.fallback! as PlainDirective).props['value'], 'fallback');
      });

      test('cond에 자식이 없으면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(uiNode(type: 'cond')),
          throwsInvalidTemplate,
        );
      });
    });

    group('예약어 _ 규칙', () {
      test('미지의 _ 키(오타난 마커)는 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(type: 'text', attrs: {'_els': r'${x}'}),
          ),
          throwsInvalidTemplate,
        );
      });

      test('맨몸 이름은 위젯 prop으로 자유롭다 (on 등 예전 예약어)', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(type: 'box', attrs: {'on': 'x', 'value': 1}),
        );
        final node = directive as PlainDirective;
        expect(node.props['on'], 'x'); // _on만 엔진; 맨몸 on은 자유
        expect(node.props['value'], 1);
      });

      test('상태 이름이 _로 시작하면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'text',
              attrs: {
                '_scope': {
                  '_state': {'_foo': 1},
                },
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('loop 프레임 변수 이름이 _로 시작하면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'text',
              attrs: {
                '_loop': {'_in': r'${items}', '_as': '_it', '_key': r'${x.id}'},
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('바인딩 root가 _로 시작하면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(type: 'text', attrs: {'_if': r'${_secret}'}),
          ),
          throwsInvalidTemplate,
        );
      });
    });

    group('_on 인터랙션', () {
      test('_on을 PlainDirective.on으로 뽑고 위젯 props엔 안 샌다', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'box',
            attrs: {
              '_on': {'tap': 'increment'},
              'value': 1,
            },
          ),
        );

        final node = directive as PlainDirective;
        expect(node.on, {'tap': 'increment'});
        expect(node.props.containsKey('_on'), isFalse); // 위젯엔 안 샘
        expect(node.props['value'], 1);
      });

      test('_on 없으면 on은 빈 맵', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(type: 'box'),
        );
        expect((directive as PlainDirective).on, isEmpty);
      });

      test('입력 change/submit 이벤트를 PlainDirective.on으로 뽑는다', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text_field',
            attrs: {
              '_on': {'change': 'on_type', 'submit': 'save'},
            },
          ),
        );

        expect((directive as PlainDirective).on, {
          'change': 'on_type',
          'submit': 'save',
        });
      });

      test('스크롤 endReached/startReached/scroll 이벤트를 뽑는다', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'list',
            attrs: {
              '_on': {
                'end_reached': 'more',
                'start_reached': 'first',
                'scroll': 'track',
              },
            },
          ),
        );

        expect((directive as PlainDirective).on, {
          'end_reached': 'more',
          'start_reached': 'first',
          'scroll': 'track',
        });
      });

      test('미지의 이벤트는 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'box',
              attrs: {
                '_on': {'typo': 'x'},
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('_on이 맵이 아니면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(type: 'box', attrs: {'_on': 'increment'}),
          ),
          throwsInvalidTemplate,
        );
      });

      test('액션 이름이 빈 문자열이면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'box',
              attrs: {
                '_on': {'tap': ''},
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });
    });

    group('_motion', () {
      test('단일 _motion을 1-원소 motions로 뽑고 props엔 안 샌다', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'box',
            attrs: {
              '_motion': {'type': 'pulse', 'duration': 500},
              'value': 1,
            },
          ),
        );

        final node = directive as PlainDirective;
        expect(node.motions, hasLength(1));
        expect(node.motions.single.type, 'pulse');
        expect(node.motions.single.params, {'duration': 500});
        expect(node.props.containsKey('_motion'), isFalse);
        expect(node.props['value'], 1);
      });

      test('리스트 _motion은 순서대로 여러 스택으로 뽑는다 (2안)', () {
        final directive =
            TemplateCompiler.buildDirectiveTree(
                  uiNode(
                    type: 'box',
                    attrs: {
                      '_motion': [
                        {'type': 'fade'},
                        {'type': 'float', 'amplitude': 6},
                      ],
                    },
                  ),
                )
                as PlainDirective;

        expect(directive.motions.map((m) => m.type), ['fade', 'float']);
        expect(directive.motions[1].params, {'amplitude': 6});
      });

      test('빈 _motion 리스트는 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(type: 'box', attrs: {'_motion': <Object?>[]}),
          ),
          throwsInvalidTemplate,
        );
      });

      test('리스트 원소가 맵도 문자열도 아니면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'box',
              attrs: {
                '_motion': [1],
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('맨몸 문자열 _motion은 인자 없는 1-원소 motions로', () {
        final directive =
            TemplateCompiler.buildDirectiveTree(
                  uiNode(type: 'box', attrs: {'_motion': 'float'}),
                )
                as PlainDirective;

        expect(directive.motions, hasLength(1));
        expect(directive.motions.single.type, 'float');
        expect(directive.motions.single.params, isEmpty);
      });

      test('빈 문자열 _motion은 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(type: 'box', attrs: {'_motion': ''}),
          ),
          throwsInvalidTemplate,
        );
      });

      test('리스트 원소로 문자열·맵을 섞어 쓸 수 있다', () {
        final directive =
            TemplateCompiler.buildDirectiveTree(
                  uiNode(
                    type: 'box',
                    attrs: {
                      '_motion': [
                        'fade_in',
                        {'type': 'float', 'duration': 500},
                      ],
                    },
                  ),
                )
                as PlainDirective;

        expect(directive.motions.map((m) => m.type), ['fade_in', 'float']);
        expect(directive.motions[0].params, isEmpty);
        expect(directive.motions[1].params, {'duration': 500});
      });

      test('리스트 원소의 빈 문자열은 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'box',
              attrs: {
                '_motion': [''],
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('_motion 없으면 motions는 빈 리스트', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(type: 'box'),
        );
        expect((directive as PlainDirective).motions, isEmpty);
      });

      test('_motion.type이 없거나 비면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'box',
              attrs: {
                '_motion': {'duration': 500},
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('roots가 props 바인딩과 _motion 인자 바인딩을 합친다', () {
        // H1: 마커로 걷어낸 _motion 인자의 바인딩도 반응·검증 root에 들어와야 한다.
        final directive =
            TemplateCompiler.buildDirectiveTree(
                  uiNode(
                    type: 'box',
                    attrs: {
                      'value': r'${label}',
                      '_motion': {'type': 'pulse', 'speed': r'${speed}'},
                    },
                  ),
                )
                as PlainDirective;
        expect(directive.roots, {'label', 'speed'});
      });

      test('roots가 리스트 _motion의 모든 원소 인자를 합친다', () {
        final directive =
            TemplateCompiler.buildDirectiveTree(
                  uiNode(
                    type: 'box',
                    attrs: {
                      '_motion': [
                        {'type': 'fade', 'delay': r'${d}'},
                        {'type': 'float', 'amplitude': r'${amp}'},
                      ],
                    },
                  ),
                )
                as PlainDirective;
        expect(directive.roots, {'d', 'amp'});
      });
    });

    // _action 컴파일 상세는 action_compiler_test가 커버. 여기선 _wrapScope가 ActionCompiler에
    // 위임해 ScopeDirective.actions를 Action으로 채우는 배선만 확인한다.
    group('_scope 스키마 검증 (B-1.1)', () {
      test('비-맵 _state는 조용히 {}가 아니라 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'text',
              attrs: {
                '_scope': {'_state': 'wrong'},
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('미지의 _scope 키(오타)는 InvalidTemplateException', () {
        // `_stat` 오타 → 예전엔 _state 부재로 조용히 빈 상태가 됐다.
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'text',
              attrs: {
                '_scope': {
                  '_stat': {'count': 0},
                },
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('명시적 _action: null은 부재가 아니라 꼴 오류', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'text',
              attrs: {
                '_scope': {
                  '_state': {'count': 0},
                  '_action': null,
                },
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('a non-map _skeleton is an InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'text',
              attrs: {
                '_scope': {'_skeleton': 'wrong'},
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('_state·_action 정상 조합은 통과', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text',
            attrs: {
              '_scope': {
                '_state': {'count': 0},
                '_action': {
                  'inc': {'_type': 'set', 'count': r'${count + 1}'},
                },
              },
            },
          ),
        );
        expect(directive, isA<ScopeDirective>());
      });
    });

    group('_action 배선', () {
      test('_action을 Action으로 컴파일해 ScopeDirective.actions에 담는다', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text',
            attrs: {
              '_scope': {
                '_state': {'count': 0},
                '_action': {
                  'increment': {'_type': 'set', 'count': r'${count + 1}'},
                },
              },
            },
          ),
        );

        final scope = directive as ScopeDirective;
        expect(scope.actions.keys, contains('increment'));
        final action = scope.actions['increment']!;
        expect(action.steps.single.single.type, 'set');
      });

      test('_state만 있으면 actions는 비어 있다', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'text',
            attrs: {
              '_scope': {
                '_state': {'count': 0},
              },
            },
          ),
        );
        expect((directive as ScopeDirective).actions, isEmpty);
      });

      test('액션 식 문법 오류는 InvalidTemplateException (마운트-치명)', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'text',
              attrs: {
                '_scope': {
                  '_state': {'count': 0},
                  '_action': {
                    'inc': {'_type': 'set', 'count': r'${count +}'}, // 깨진 식
                  },
                },
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('액션 이름이 _로 시작하면 InvalidTemplateException', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'text',
              attrs: {
                '_scope': {
                  '_state': {'count': 0},
                  '_action': {
                    '_hidden': {'_type': 'set', 'count': r'${count}'},
                  },
                },
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });
    });

    // props의 $-문자열은 액션 인자와 같은 규칙으로 앞단 컴파일된다 — 방언 하나(Expression).
    group('props 컴파일', () {
      test(r'$-문자열 prop은 Expression으로 컴파일된다 (산술·인덱싱 포함)', () {
        final directive =
            TemplateCompiler.buildDirectiveTree(
                  uiNode(
                    type: 'text',
                    attrs: {
                      'value': r'${count + 1}',
                      'first': r'${items[0]}',
                      'plain': 'literal',
                    },
                  ),
                )
                as PlainDirective;

        expect(directive.props['value'], isA<Expression>());
        expect(directive.props['first'], isA<Expression>());
        expect(directive.props['plain'], 'literal');
        expect(directive.roots, {'count', 'items'});
      });

      test(r'중첩 맵·리스트 안의 $-문자열도 컴파일된다', () {
        final directive =
            TemplateCompiler.buildDirectiveTree(
                  uiNode(
                    type: 'box',
                    attrs: {
                      'style': {'size': r'${size}'},
                      'tags': [r'${tag}', 'fixed'],
                    },
                  ),
                )
                as PlainDirective;

        final style = directive.props['style'] as Map<String, Object?>;
        final tags = directive.props['tags'] as List<Object?>;
        expect(style['size'], isA<Expression>());
        expect(tags[0], isA<Expression>());
        expect(tags[1], 'fixed');
        expect(directive.roots, {'size', 'tag'});
      });

      test(r'${…}로 $-접두 없는 식을 명시한다 (액션 인자와 동일 규칙)', () {
        final directive =
            TemplateCompiler.buildDirectiveTree(
                  uiNode(type: 'text', attrs: {'value': r'${not on}'}),
                )
                as PlainDirective;

        expect(directive.props['value'], isA<Expression>());
        expect(directive.roots, {'on'});
      });

      test('prop 식 문법 오류는 InvalidTemplateException (마운트-치명, 렌더까지 안 감)', () {
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(type: 'text', attrs: {'value': r'${count +}'}),
          ),
          throwsInvalidTemplate,
        );
      });

      test('loop 별칭이 소스 root와 겹쳐도 소스 의존은 남는다 (L1)', () {
        // roots에서 프레임 변수를 통째로 빼면 `_as`가 소스 root와 같을 때 진짜 바깥
        // 의존까지 지워져 검증·반응이 둘 다 무력화된다 — 프레임 변수는 키 식에서만 뺀다.
        final directive =
            TemplateCompiler.buildDirectiveTree(
                  uiNode(
                    type: 'text',
                    attrs: {
                      '_loop': {
                        '_in': r'${items}',
                        '_as': 'items',
                        '_key': r'${index}',
                      },
                    },
                  ),
                )
                as LoopDirective;
        expect(directive.roots, {'items'});
      });

      test('null 마커는 부재가 아니라 꼴 오류다 (L3)', () {
        for (final marker in ['_if', '_loop', '_scope', '_on', '_motion']) {
          expect(
            () => TemplateCompiler.buildDirectiveTree(
              uiNode(type: 'text', attrs: {marker: null}),
            ),
            throwsInvalidTemplate,
            reason: '$marker: null이 조용히 무시되면 안 된다',
          );
        }
      });

      test('cond/switch 밖의 가지 마커는 오타로 본다 (L4)', () {
        for (final entry in {
          '_else': true,
          '_case': 'x',
          '_default': true,
        }.entries) {
          expect(
            () => TemplateCompiler.buildDirectiveTree(
              uiNode(type: 'text', attrs: {entry.key: entry.value}),
            ),
            throwsInvalidTemplate,
            reason: '${entry.key}가 control 노드 밖에서 조용히 소거되면 안 된다',
          );
        }
      });

      test('control 노드의 잔여 키는 거부한다 (L5)', () {
        // switch의 _value 오타 — 조용히 무시되면 셀렉터 없는 switch가 된다.
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'switch',
              attrs: {'_value': r'${s}', '_vale': r'${other}'},
              children: [
                uiNode(type: 'text', attrs: {'_case': 'a'}),
              ],
            ),
          ),
          throwsInvalidTemplate,
        );
        // control 노드엔 _on/_motion 배선이 없다 — 조용히 소실 대신 거부.
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'cond',
              attrs: {
                '_on': {'tap': 'go'},
              },
              children: [
                uiNode(type: 'text', attrs: {'_if': r'${a}'}),
              ],
            ),
          ),
          throwsInvalidTemplate,
        );
        // control 노드는 위젯이 아니라 맨몸 prop도 죽은 데이터다.
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'switch',
              attrs: {'_value': r'${s}', 'color': 'red'},
              children: [
                uiNode(type: 'text', attrs: {'_case': 'a'}),
              ],
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test('control 노드도 wrapper 마커(_if 등)는 그대로 쓴다 (L5 양성)', () {
        final directive = TemplateCompiler.buildDirectiveTree(
          uiNode(
            type: 'switch',
            attrs: {'_value': r'${s}', '_if': r'${show}'},
            children: [
              uiNode(type: 'text', attrs: {'_case': 'a'}),
            ],
          ),
        );
        // _if가 switch를 감싼다.
        expect(directive, isA<ConditionDirective>());
        expect(
          (directive as ConditionDirective).branches.single.body,
          isA<SwitchDirective>(),
        );
      });

      test('바인딩으로 참조 불가능한 이름은 선언 불가 (L6)', () {
        // $user-id는 뺄셈으로 렉싱된다 — 선언만 되고 참조가 안 되는 이름은 오타다.
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'text',
              attrs: {
                '_scope': {
                  '_state': {'user-id': 1},
                },
              },
            ),
          ),
          throwsInvalidTemplate,
        );
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'text',
              attrs: {
                '_loop': {
                  '_in': r'${items}',
                  '_as': 'line-item',
                  '_key': r'${index}',
                },
              },
            ),
          ),
          throwsInvalidTemplate,
        );
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'text',
              attrs: {
                '_scope': {
                  '_state': {'': 1},
                },
              },
            ),
          ),
          throwsInvalidTemplate,
        );
        // 숫자 시작도 식별자가 아니다.
        expect(
          () => TemplateCompiler.buildDirectiveTree(
            uiNode(
              type: 'text',
              attrs: {
                '_loop': {
                  '_in': r'${items}',
                  '_index': '2nd',
                  '_key': r'${index}',
                },
              },
            ),
          ),
          throwsInvalidTemplate,
        );
      });

      test(r'_motion 인자의 $-문자열도 Expression으로 컴파일된다', () {
        final directive =
            TemplateCompiler.buildDirectiveTree(
                  uiNode(
                    type: 'box',
                    attrs: {
                      '_motion': {'type': 'pulse', 'speed': r'${speed * 2}'},
                    },
                  ),
                )
                as PlainDirective;

        expect(directive.motions.single.params['speed'], isA<Expression>());
        expect(directive.roots, {'speed'});
      });
    });

    group('_on 타이밍(throttle/debounce)', () {
      PlainDirective compileOn(Map<String, Object?> on) =>
          TemplateCompiler.buildDirectiveTree(
                uiNode(type: 'box', attrs: {'_on': on}),
              )
              as PlainDirective;

      test('문자열 값은 action만 담고 timing은 비어 있다', () {
        final directive = compileOn({'tap': 'submit'});
        expect(directive.on, {'tap': 'submit'});
        expect(directive.timing, isEmpty);
      });

      test('객체 값 throttle → on + leading timing', () {
        final directive = compileOn({
          'tap': {'do': 'submit', 'throttle': 100},
        });
        expect(directive.on, {'tap': 'submit'});
        expect(directive.timing['tap']!.mode, EventTimingMode.throttle);
        expect(
          directive.timing['tap']!.duration,
          const Duration(milliseconds: 100),
        );
      });

      test('객체 값 debounce → trailing timing', () {
        final directive = compileOn({
          'scroll': {'do': 'settle', 'debounce': 300},
        });
        expect(directive.on, {'scroll': 'settle'});
        expect(directive.timing['scroll']!.mode, EventTimingMode.debounce);
        expect(
          directive.timing['scroll']!.duration,
          const Duration(milliseconds: 300),
        );
      });

      test('throttle과 debounce 동시 지정은 거부', () {
        expect(
          () => compileOn({
            'tap': {'do': 'x', 'throttle': 1, 'debounce': 1},
          }),
          throwsInvalidTemplate,
        );
      });

      test('알 수 없는 옵션 키는 거부', () {
        expect(
          () => compileOn({
            'tap': {'do': 'x', 'delay': 1},
          }),
          throwsInvalidTemplate,
        );
      });

      test('do 누락은 거부', () {
        expect(
          () => compileOn({
            'tap': {'throttle': 100},
          }),
          throwsInvalidTemplate,
        );
      });

      test('0 이하 ms는 거부', () {
        expect(
          () => compileOn({
            'tap': {'do': 'x', 'throttle': 0},
          }),
          throwsInvalidTemplate,
        );
      });
    });
  });
}
