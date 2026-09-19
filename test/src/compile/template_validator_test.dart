import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/compile/schema/language_catalog.dart';
import 'package:sdui_engine/src/compile/schema/command_schema.dart';
import 'package:sdui_engine/src/compile/schema/widget_schema.dart';
import 'package:sdui_engine/src/compile/schema/widget_schema_registry.dart';
import 'package:sdui_engine/src/compile/template_validator.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

final throwsInvalidTemplate = throwsA(isA<InvalidTemplateException>());

/// 바인딩·액션 검사에 쓰는 placeholder driver — validator가 이제 커맨드 type 존재도 확인하므로(⑥)
/// 테스트가 쓰는 임의 driver type을 등록해 둔다(no-op).
class _Dummy extends Driver {
  const _Dummy(this.type);
  @override
  final String type;
  @override
  Future<Object?> run(DriverContext ctx) async => null;
}

/// 템플릿을 파싱·컴파일한 뒤 [declared] 선언 아래서 검사한다.
void validate(
  Map<String, Object?> template,
  Set<String> declared, {
  LanguageCatalog? catalog,
}) {
  final node = TemplateParser.buildUiTree(template);
  final directive = TemplateCompiler.buildDirectiveTree(node);
  TemplateValidator.validate(directive, declared, catalog: catalog);
}

/// 레지스트리 스냅샷에 모션·함수 열거를 더한 풀 카탈로그.
LanguageCatalog fullCatalog({
  Set<String> motions = const {'fade'},
  Set<String> functions = const {'upper'},
}) => LanguageCatalog(
  widgets: WidgetSchemaRegistry.all(),
  commands: CommandSchemaRegistry.all(),
  motions: motions,
  functions: functions,
);

void main() {
  group('TemplateValidator', () {
    // validator가 이제 위젯/driver type 존재도 검사(⑥) — 테스트가 placeholder로 쓰는 `box`(위젯)·
    // `fetch`/`api`/`analytics`(driver)를 등록해 바인딩 검사 로직만 격리한다.
    setUp(() {
      WidgetFactory.register(
        'box',
        EagerSpec((context, props, children) => const SizedBox()),
      );
      DriverRegistry.registerAll(const [
        _Dummy('fetch'),
        _Dummy('fetch_two'),
        _Dummy('analytics'),
      ]);
    });
    tearDown(() {
      WidgetFactory.reset();
      DriverRegistry.reset();
    });

    group('catalog 검증 (모션·함수 — 기기 아닌 컴파일에서 죽인다)', () {
      test('카탈로그가 모르는 _motion 이름은 컴파일에서 거부한다', () {
        expect(
          () => validate(
            {'_type': 'text', 'value': 'x', '_motion': 'sparkle_nope'},
            const {},
            catalog: fullCatalog(),
          ),
          throwsInvalidTemplate,
        );
        // 아는 이름은 통과.
        validate(
          {'_type': 'text', 'value': 'x', '_motion': 'fade'},
          const {},
          catalog: fullCatalog(),
        );
      });

      test('카탈로그가 모르는 함수 호출은 컴파일에서 거부한다', () {
        expect(
          () => validate(
            {'_type': 'text', 'value': r'${nope(name)}'},
            {'name'},
            catalog: fullCatalog(),
          ),
          throwsInvalidTemplate,
        );
        validate(
          {'_type': 'text', 'value': r'${upper(name)}'},
          {'name'},
          catalog: fullCatalog(),
        );
      });

      test('catalog 생략(레지스트리 스냅샷)도 빌트인 모션·함수는 검증한다', () {
        // 스냅샷 카탈로그가 BuiltinLanguage를 시드하므로 모르는 이름은 잡힌다.
        expect(
          () => validate(
            {'_type': 'text', 'value': 'x', '_motion': 'sparkle_nope'},
            const {},
          ),
          throwsInvalidTemplate,
        );
        // 빌트인은 통과.
        validate({'_type': 'text', 'value': 'x', '_motion': 'fade'}, const {});
      });

      test('모션·함수 집합이 null인 카탈로그는 그 검사를 건너뛴다 (명시적 opt-out)', () {
        validate(
          {'_type': 'text', 'value': r'${nope(name)}', '_motion': 'sparkle_nope'},
          {'name'},
          catalog: LanguageCatalog(
            widgets: WidgetSchemaRegistry.all(),
            commands: CommandSchemaRegistry.all(),
          ),
        );
      });
    });

    group('type 검증 (⑥)', () {
      test('미등록 위젯 type은 마운트-치명', () {
        expect(
          () => validate({'_type': 'nope_widget'}, const {}),
          throwsInvalidTemplate,
        );
      });
      test('미등록 driver type(커맨드)은 마운트-치명', () {
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_action': {
                'go': {'_type': 'nope_driver'},
              },
            },
            '_on': {'tap': 'go'},
          }, const {}),
          throwsInvalidTemplate,
        );
      });
      test('미등록 _loop._wrap 전략은 마운트-치명', () {
        // 컴파일러는 wrap 이름을 그대로 통과시킨다 — 여기서 등록된 wrap 셋에 대조.
        expect(
          () => validate(
            {
              '_type': 'box',
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it.id}',
                '_wrap': 'carousel',
              },
            },
            {'items'},
          ),
          throwsInvalidTemplate,
        );
      });
      test('등록된 _loop._wrap 전략은 통과', () {
        expect(
          () => validate(
            {
              '_type': 'box',
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it.id}',
                '_wrap': 'grid',
              },
            },
            {'items'},
          ),
          returnsNormally,
        );
      });
    });

    group('레이아웃 프로토콜 검증 (box/sliver 오배치 — 렌더 assertion을 마운트로)', () {
      test('sliver 위젯을 box 부모(column) 자식으로 두면 마운트-치명', () {
        // sliverList는 sliver를 생산하는데 column은 box 자식을 요구 → 렌더-타임 assertion을 마운트로.
        expect(
          () => validate({
            '_type': 'column',
            '_children': [
              {'_type': 'sliver_list', '_children': <Object?>[]},
            ],
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('box 위젯을 customScrollView 자식으로 두면 마운트-치명', () {
        // customScrollView는 sliver 자식을 요구하는데 text는 box를 생산.
        expect(
          () => validate({
            '_type': 'custom_scroll_view',
            '_children': [
              {'_type': 'text', 'value': 'x'},
            ],
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('bare sliver를 루트로 두면 마운트-치명 (뷰포트 밖)', () {
        // 루트는 box 부모(일반 위젯 트리)에 마운트되므로 sliver 생산은 크래시.
        expect(
          () => validate({'_type': 'sliver_to_box_adapter'}, const {}),
          throwsInvalidTemplate,
        );
      });

      test('_loop._wrap: sliverList를 box 부모 자식으로 두면 마운트-치명', () {
        // 컨테이너 전략이 sliver를 생산 → box 부모(column) 아래선 오배치.
        expect(
          () => validate(
            {
              '_type': 'column',
              '_children': [
                {
                  '_type': 'text',
                  'value': r'${it}',
                  '_loop': {
                    '_in': r'${items}',
                    '_as': 'it',
                    '_key': r'${it}',
                    '_wrap': 'sliver_list',
                  },
                },
              ],
            },
            {'items'},
          ),
          throwsInvalidTemplate,
        );
      });

      test('customScrollView + sliverToBoxAdapter(box 자식)는 통과', () {
        // sliverToBoxAdapter는 sliver 생산(customScrollView 요구 충족) + box 자식 요구(text 충족).
        expect(
          () => validate({
            '_type': 'custom_scroll_view',
            '_children': [
              {
                '_type': 'sliver_to_box_adapter',
                '_child': {'_type': 'text', 'value': 'x'},
              },
            ],
          }, const {}),
          returnsNormally,
        );
      });

      test('_if로 감싼 sliver는 customScrollView 안에서 통과 (프로토콜 투명)', () {
        // cond는 프로토콜에 투명 — customScrollView의 sliver 요구가 _if 가지의 sliverList까지 흐른다.
        expect(
          () => validate(
            {
              '_type': 'custom_scroll_view',
              '_children': [
                {
                  '_type': 'sliver_list',
                  '_if': r'${show}',
                  '_children': <Object?>[],
                },
              ],
            },
            {'show'},
          ),
          returnsNormally,
        );
      });

      test('_if로 감싼 box는 customScrollView 안에서 마운트-치명 (투명성이 새지 않음)', () {
        expect(
          () => validate(
            {
              '_type': 'custom_scroll_view',
              '_children': [
                {'_type': 'text', 'value': 'x', '_if': r'${show}'},
              ],
            },
            {'show'},
          ),
          throwsInvalidTemplate,
        );
      });

      test('nestedScrollView(혼합 자식)는 프로토콜 검증을 건너뛴다', () {
        // 헤더 sliver + box body가 위치로 섞여 단일 프로토콜로 못 적음 → childProtocol=null(스킵).
        expect(
          () => validate({
            '_type': 'nested_scroll_view',
            '_children': [
              {
                '_type': 'sliver_to_box_adapter',
                '_child': {'_type': 'text', 'value': 'h'},
              },
              {'_type': 'text', 'value': 'body'},
            ],
          }, const {}),
          returnsNormally,
        );
      });
    });

    group('자식 형태 검증 (W4 — kind 불일치 silent-drop 방지)', () {
      test('slot 위젯(scaffold)에 위치 자식을 주면 마운트-치명', () {
        expect(
          () => validate({
            '_type': 'scaffold',
            '_child': {'_type': 'text', 'value': 'x'},
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('slot 위젯에 _slots를 주면 통과', () {
        expect(
          () => validate({
            '_type': 'scaffold',
            '_slots': {
              'body': {'_type': 'text', 'value': 'hi'},
            },
          }, const {}),
          returnsNormally,
        );
      });

      test('slot 아닌 위젯(column)에 _slots를 주면 마운트-치명', () {
        expect(
          () => validate({
            '_type': 'column',
            '_slots': {
              'body': {'_type': 'text', 'value': 'x'},
            },
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('입력 위젯(checkbox)에 위치 자식을 주면 마운트-치명', () {
        expect(
          () => validate({
            '_type': 'checkbox',
            '_child': {'_type': 'text', 'value': 'x'},
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('eager 위젯(column)에 위치 자식은 통과', () {
        expect(
          () => validate({
            '_type': 'column',
            '_children': [
              {'_type': 'text', 'value': 'a'},
            ],
          }, const {}),
          returnsNormally,
        );
      });
    });

    group('bind 선언 검증 (stab#2 — 미선언 bind write 크래시 방지)', () {
      test('bind가 선언된 _scope._state 키면 통과', () {
        expect(
          () => validate({
            '_type': 'column',
            '_scope': {
              '_state': {'agree': false},
            },
            '_children': [
              {'_type': 'toggle', 'bind': 'agree'},
            ],
          }, const {}),
          returnsNormally,
        );
      });

      test('bind가 미선언(오타) 키면 마운트-치명', () {
        expect(
          () => validate({
            '_type': 'column',
            '_scope': {
              '_state': {'agree': false},
            },
            '_children': [
              {'_type': 'toggle', 'bind': 'agre'}, // 오타
            ],
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('bind가 rootData 키면 통과 (root scope가 writable)', () {
        expect(
          () => validate({'_type': 'checkbox', 'bind': 'ok'}, {'ok'}),
          returnsNormally,
        );
      });

      test('bind가 loop 프레임 변수(읽기 전용)면 마운트-치명', () {
        expect(
          () => validate({
            '_type': 'column',
            '_scope': {
              '_state': {'items': <Object?>[], 'chosen': false},
            },
            '_children': [
              {
                '_type': 'box',
                '_loop': {'_in': r'${items}', '_as': 'it', '_key': r'${it.id}'},
                '_child': {'_type': 'toggle', 'bind': 'it'}, // it=읽기 전용 프레임
              },
            ],
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('bind 없는 입력 위젯은 통과 (bind 선택)', () {
        expect(
          () => validate({'_type': 'checkbox'}, const {}),
          returnsNormally,
        );
      });
    });

    group('validate', () {
      test('rootData에 선언된 root는 통과', () {
        expect(
          () => validate({'_type': 'text', 'value': r'${title}'}, {'title'}),
          returnsNormally,
        );
      });

      test(r'미선언 root는 InvalidTemplateException ($isAdmn 오타)', () {
        expect(
          () =>
              validate({'_type': 'text', 'value': r'${isAdmn}'}, {'is_admin'}),
          throwsInvalidTemplate,
        );
      });

      test('_scope._state로 선언한 키를 자식에서 참조하면 통과', () {
        expect(
          () => validate({
            '_type': 'column',
            '_scope': {
              '_state': {'count': 0},
            },
            '_children': [
              {'_type': 'text', 'value': r'${count}'},
            ],
          }, const {}),
          returnsNormally,
        );
      });

      test('morph _as는 자식에서 읽기 전용 선언으로 보인다', () {
        expect(
          () => validate({
            '_type': 'text',
            '_morph': {'_from': 0, '_to': 100, '_as': 'n'},
            'value': r'${n}',
          }, const {}),
          returnsNormally,
        );
      });

      test('morph _to의 미선언 root는 마운트-치명', () {
        expect(
          () => validate({
            '_type': 'text',
            '_morph': {'_to': r'${missing}', '_as': 'n'},
            'value': r'${n}',
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('상위 scope에서 선언 안 된 root는 자식에서도 throw', () {
        expect(
          () => validate({
            '_type': 'column',
            '_scope': {
              '_state': {'count': 0},
            },
            '_children': [
              {'_type': 'text', 'value': r'${other}'}, // 미선언
            ],
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('loop 프레임 변수는 loop 안에서 선언된다', () {
        expect(
          () => validate(
            {
              '_type': 'box',
              '_loop': {'_in': r'${items}', '_as': 'it', '_key': r'${it.id}'},
              '_child': {'_type': 'text', 'value': r'${it.name}'},
            },
            {'items'},
          ),
          returnsNormally,
        );
      });

      test('프레임 변수를 loop 밖에서 참조하면 throw', () {
        expect(
          () => validate(
            {
              '_type': 'column',
              '_children': [
                {
                  '_type': 'box',
                  '_loop': {
                    '_in': r'${items}',
                    '_as': 'it',
                    '_key': r'${it.id}',
                  },
                  '_child': {'_type': 'text', 'value': r'${it.name}'},
                },
                {'_type': 'text', 'value': r'${it.name}'}, // loop 밖 — $it 미선언
              ],
            },
            {'items'},
          ),
          throwsInvalidTemplate,
        );
      });

      test('loop 소스 root가 미선언이면 throw', () {
        expect(
          () => validate({
            '_type': 'box',
            '_loop': {'_in': r'${items}', '_as': 'it', '_key': r'${it.id}'},
            '_child': {'_type': 'text', 'value': r'${it.name}'},
          }, const {}), // items 미선언
          throwsInvalidTemplate,
        );
      });

      test('안 뜨는 _if 가지의 미선언 root도 조기에 잡는다', () {
        expect(
          () => validate(
            {'_type': 'text', '_if': r'${isAdmn}', 'value': 'x'},
            {'is_admin'},
          ),
          throwsInvalidTemplate,
        );
      });

      test('switch 셀렉터 root도 검사한다', () {
        expect(
          () => validate({
            '_type': 'switch',
            '_value': r'${status}', // 미선언
            '_children': [
              {'_type': 'text', '_case': 'a', 'value': 'A'},
            ],
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('선언된 root의 값 공백(하위 경로)은 관대 — throw 안 함', () {
        // user는 선언, nickname 없음 → 런타임 null 관대. 키(root)만 강제.
        expect(
          () => validate(
            {'_type': 'text', 'value': r'${user.nickname}'},
            {'user'},
          ),
          returnsNormally,
        );
      });

      test('액션 인자 식이 미선언 root를 참조하면 throw', () {
        expect(
          () => validate({
            '_type': 'text',
            '_scope': {
              '_state': {'count': 0},
              '_action': {
                'inc': {
                  '_type': 'set',
                  'count': r'${missing + 1}',
                }, // missing 미선언
              },
            },
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('_on이 정의 안 된 액션을 참조하면 throw', () {
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_state': {'count': 0},
              '_action': {
                'inc': {'_type': 'set', 'count': r'${count + 1}'},
              },
            },
            '_child': {
              '_type': 'text',
              '_on': {'tap': 'nope'}, // 정의 없음
              'value': r'${count}',
            },
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      Map<String, Object?> eventTemplate(String type, String event) => {
        '_type': type,
        '_scope': {
          '_action': {
            'x': {'_type': 'analytics'},
          },
        },
        '_on': {event: 'x'},
      };

      test('입력 이벤트를 EagerSpec 위젯에 주면 마운트-치명', () {
        expect(
          () => validate(eventTemplate('text', 'change'), const {}),
          throwsInvalidTemplate,
        );
      });

      test('입력 이벤트를 BoundSpec 위젯에 주면 통과', () {
        expect(
          () => validate(eventTemplate('text_field', 'change'), const {}),
          returnsNormally,
        );
      });

      test('제스처 이벤트는 모든 위젯 종류에서 통과', () {
        expect(
          () => validate(eventTemplate('text', 'tap'), const {}),
          returnsNormally,
        );
      });

      test('스크롤 이벤트는 비스크롤 위젯에서도 통과', () {
        expect(
          () => validate(eventTemplate('text', 'end_reached'), const {}),
          returnsNormally,
        );
      });

      test('선언된 root·존재하는 액션 참조는 통과', () {
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_state': {'count': 0},
              '_action': {
                'increment': {'_type': 'set', 'count': r'${count + 1}'},
              },
            },
            '_child': {
              '_type': 'text',
              '_on': {'tap': 'increment'},
              'value': r'${count}',
            },
          }, const {}),
          returnsNormally,
        );
      });

      test(r'핸들러(_then) 안에선 $data가 선언된 root로 통한다', () {
        expect(
          () => validate({
            '_type': 'text',
            '_scope': {
              '_state': {'result': 0},
              '_action': {
                'load': {
                  '_type': 'net',
                  '_then': {'_type': 'set', 'result': r'${data}'},
                },
              },
            },
          }, const {}),
          returnsNormally,
        );
      });

      test('_motion 인자의 미선언 바인딩은 마운트-치명', () {
        // H1: props뿐 아니라 _motion 인자의 root도 선언 검사 대상.
        expect(
          () => validate({
            '_type': 'box',
            '_motion': {'type': 'pulse', 'speed': r'${undeclared}'},
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('_motion 인자 바인딩이 선언돼 있으면 통과', () {
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_state': {'speed': 1},
            },
            '_motion': {'type': 'pulse', 'speed': r'${speed}'},
          }, const {}),
          returnsNormally,
        );
      });
    });

    // set은 빌트인이고 쓰기 대상(인자의 맨몸 키)이 곧 그 scope의 상태 키다 — 컴파일 타임에
    // 전부 알 수 있으므로 read 검사와 대칭으로 write도 마운트에서 잡는다. 런타임 StateError
    // (탭할 때야 발견)로 미루지 않는다.
    group('set 쓰기 키 검사', () {
      test('자기 scope에 선언된 키에 쓰면 통과', () {
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_state': {'count': 0},
              '_action': {
                'inc': {'_type': 'set', 'count': r'${count + 1}'},
              },
            },
          }, const {}),
          returnsNormally,
        );
      });

      test('오타난 쓰기 키는 마운트-치명 (런타임 StateError로 안 미룸)', () {
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_state': {'count': 0},
              '_action': {
                'inc': {'_type': 'set', 'cont': 1}, // 오타
              },
            },
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('조상 scope의 키에 쓰려 하면 마운트-치명 (쓰기는 체인을 안 탄다)', () {
        // 읽기는 렉시컬 체인을 타지만 set은 액션을 정의한 scope의 store에만 쓴다.
        // 조상 키에 쓰려면 액션을 그 조상 scope에 정의한다.
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_state': {'outer': 0},
            },
            '_child': {
              '_type': 'box',
              '_scope': {
                '_state': {'inner': 0},
                '_action': {
                  'bad': {'_type': 'set', 'outer': 1}, // outer는 조상 소유
                },
              },
            },
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test(r'핸들러 안에서도 쓰기 키는 자기 scope 상태여야 한다 ($data는 읽기 전용 그림자)', () {
        // $data/$error는 핸들러 안에서 읽기로만 선언된다 — 쓰기 대상이 될 수 없다.
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_state': {'result': null},
              '_action': {
                'load': {
                  '_type': 'fetch',
                  '_then': {'_type': 'set', 'data': 1}, // 'data'는 상태 키가 아님
                },
              },
            },
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test(r'핸들러의 set이 $data를 읽어 자기 키에 쓰는 건 통과', () {
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_state': {'result': null},
              '_action': {
                'load': {
                  '_type': 'fetch',
                  '_then': {'_type': 'set', 'result': r'${data}'},
                },
              },
            },
          }, const {}),
          returnsNormally,
        );
      });

      test(r'핸들러 그림자는 런타임과 일치해야 — _always엔 $data가 없다 (L2)', () {
        // 런타임은 _then에 $data만, _error에 $error만 주고 _always엔 둘 다 안 준다.
        // validator가 셋 다 선언해 주면 마운트를 통과한 참조가 런타임에 null로 샌다.
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_state': {'result': null},
              '_action': {
                'load': {
                  '_type': 'fetch',
                  '_always': {'_type': 'set', 'result': r'${data}'},
                },
              },
            },
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test(r'_then에서 $error 참조는 마운트-치명 (L2)', () {
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_state': {'result': null},
              '_action': {
                'load': {
                  '_type': 'fetch',
                  '_then': {'_type': 'set', 'result': r'${error.message}'},
                },
              },
            },
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test(r'_error에서 $error 참조는 통과, $data는 마운트-치명 (L2)', () {
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_state': {'msg': null},
              '_action': {
                'load': {
                  '_type': 'fetch',
                  '_error': {
                    '_': {'_type': 'set', 'msg': r'${error.message}'},
                  },
                },
              },
            },
          }, const {}),
          returnsNormally,
        );
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_state': {'msg': null},
              '_action': {
                'load': {
                  '_type': 'fetch',
                  '_error': {
                    '_': {'_type': 'set', 'msg': r'${data}'},
                  },
                },
              },
            },
          }, const {}),
          throwsInvalidTemplate,
        );
      });

      test('set이 아닌 커맨드의 인자 키는 검사하지 않는다 (driver 인자는 opaque)', () {
        expect(
          () => validate({
            '_type': 'box',
            '_scope': {
              '_state': {'count': 0},
              '_action': {
                'log': {
                  '_type': 'analytics',
                  'event_name': 'tap',
                  'anything': 1,
                },
              },
            },
          }, const {}),
          returnsNormally,
        );
      });
    });
  });
}
