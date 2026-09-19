import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/template_validator.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/observer/loop_observer.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';

Widget _content(Map<String, Object?> template) => NodeBuilder.build(
  TemplateCompiler.buildDirectiveTree(TemplateParser.buildUiTree(template)),
);

Future<void> _pump(WidgetTester tester, Widget widget) => tester.pumpWidget(
  Directionality(textDirection: TextDirection.ltr, child: widget),
);

/// Mounts [widget] under a fixed viewport so PageView-backed wraps (swipe) have
/// bounded constraints and a MediaQuery ancestor.
Future<void> _pumpBounded(WidgetTester tester, Widget widget) =>
    tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(),
          child: EngineMetrics(
            scale: 1.0,
            child: Center(
              child: SizedBox(width: 400, height: 40, child: widget),
            ),
          ),
        ),
      ),
    );

/// A taller bounded viewport for cases that stack a pager and a readout.
Future<void> _pumpTall(WidgetTester tester, Widget widget) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: EngineMetrics(
        scale: 1.0,
        child: Center(child: SizedBox(width: 400, height: 200, child: widget)),
      ),
    ),
  ),
);

const _template = {
  '_type': 'column',
  '_children': [
    {
      '_type': 'text',
      'value': r'${it.name}',
      '_loop': {'_in': r'${items}', '_as': 'it', '_key': r'${it.id}'},
    },
  ],
};

void main() {
  test(
    '_knownWraps 레지스트리 드리프트 가드: 컴파일 타임 검증과 런타임 dispatch가 같은 이름 집합을 다뤄야 한다',
    () {
      // 컴파일 타임 검증(TemplateValidator._knownWraps)과 런타임 dispatch
      // (LoopObserver._expand의 switch)는 서로 다른 파일의 별도 목록이다. 한쪽만
      // 갱신되면 이름은 컴파일을 통과하지만 런타임엔 조용히 column으로 폴백한다 —
      // spin_grid가 실제로 그렇게 깨졌었다(레이아웃 크래시로만 드러남). 이 테스트는
      // 그 드리프트를 정적으로 잡는다.
      final known = TemplateValidator.knownWraps;
      final handled = LoopObserver.handledWraps;

      // 'column'은 미등록 이름과 같은 fallback 분기이므로 정당하게 handled 밖이다.
      final missingCase = known.difference({'column'}).difference(handled);
      expect(
        missingCase,
        isEmpty,
        reason:
            '_knownWraps에는 있지만 LoopObserver._expand에 case가 없다: $missingCase '
            '(컴파일 검증은 통과하지만 런타임엔 조용히 column으로 폴백한다)',
      );

      // 반대 방향: switch가 다루는데 _knownWraps에 없는 이름은 컴파일 타임에 거짓
      // 에러(unknown loop layout)를 낸다.
      final unvalidated = handled.difference(known);
      expect(
        unvalidated,
        isEmpty,
        reason:
            'LoopObserver._expand가 다루지만 TemplateValidator._knownWraps에 없는 이름: '
            '$unvalidated',
      );
    },
  );

  group('LoopObserver', () {
    group('LoopTelemetryEntry', () {
      test(
        'uses only typed allowlist fields before falling back to unknown id',
        () {
          final typed = LoopTelemetryEntry.fromFrame(
            const {
              'item': {'productId': 'product-1', 'secret': 'nope'},
              'i': 2,
            },
            alias: 'item',
            indexName: 'i',
            key: 'key-1',
          );
          final unknown = LoopTelemetryEntry.fromFrame(
            const {
              'item': {'id': 7, 'name': 'private'},
              'i': 3,
            },
            alias: 'item',
            indexName: 'i',
            key: 'key-2',
          );

          expect(typed.entity, {'type': 'product', 'id': 'product-1'});
          expect(unknown.entity, {'type': 'unknown', 'id': '7'});
        },
      );

      test(
        'nested context keeps placement and chooses deepest typed entity',
        () {
          const scope = LoopTelemetryScope(
            entries: [
              LoopTelemetryEntry(
                index: 0,
                key: 'outer',
                entity: {'type': 'partner', 'id': 'partner-1'},
              ),
              LoopTelemetryEntry(
                index: 4,
                key: 'inner',
                entity: {'type': 'product', 'id': 'product-1'},
              ),
            ],
            child: SizedBox(),
          );

          final node = scope.node(type: 'text', path: r'$[0]');

          expect(node.entity, {'type': 'product', 'id': 'product-1'});
          expect(node.position, hasLength(2));
          expect(node.position.first['index'], 0);
          expect(node.position.last['index'], 4);
        },
      );
    });

    testWidgets('소스 리스트를 항목별로 펼치고 루프 변수를 푼다', (tester) async {
      await _pump(
        tester,
        Scope.ofState(const {
          'items': [
            {'id': 'a', 'name': 'Alice'},
            {'id': 'b', 'name': 'Bob'},
          ],
        }, child: _content(_template)),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('swipe wrap는 항목을 스와이프 페이지(PageView)로 펼친다', (tester) async {
      await _pumpBounded(
        tester,
        Scope.ofState(
          const {
            'items': [
              {'id': 'a', 'name': 'Alice'},
              {'id': 'b', 'name': 'Bob'},
            ],
          },
          child: _content(const {
            '_type': 'text',
            'value': r'${it.name}',
            '_loop': {
              '_in': r'${items}',
              '_as': 'it',
              '_key': r'${it.id}',
              '_wrap': {'_type': 'swipe'},
            },
          }),
        ),
      );
      await tester.pump();

      // The loop owns the page count: two items → a PageView showing the first.
      expect(find.byType(PageView), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('swipe wrap는 정착한 페이지를 on_changed 액션으로 되돌린다', (tester) async {
      // 루프가 만든 캐러셀에서 고른 페이지를 상위 상태로 돌려보낼 유일한 통로다.
      // 이게 없으면 데이터로 만든 스와이프 목록은 선택을 표현할 수 없다.
      WidgetFactory.ensureRegistered();
      DriverRegistry.ensureRegistered();

      await _pumpTall(
        tester,
        _content(const {
          '_type': 'column',
          '_scope': {
            '_state': {
              'picked': 0,
              'items': [
                {'id': 'a', 'name': 'Alice'},
                {'id': 'b', 'name': 'Bob'},
              ],
            },
            '_action': {
              'pick': {'_type': 'set', 'picked': r'${event}'},
            },
          },
          '_children': [
            {
              '_type': 'sizedbox',
              'height': 40,
              '_child': {
                '_type': 'text',
                'value': r'${it.name}',
                '_loop': {
                  '_in': r'${items}',
                  '_as': 'it',
                  '_key': r'${it.id}',
                  '_wrap': {
                    '_type': 'swipe',
                    'on_changed': 'pick',
                    'loop': false,
                  },
                },
              },
            },
            {'_type': 'text', 'value': r'picked=${picked}'},
          ],
        }),
      );
      await tester.pump();
      expect(find.text('picked=0'), findsOneWidget);

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('picked=1'), findsOneWidget);
    });

    testWidgets('swipe wrap는 scroll_direction을 pane에 전달한다 (세로)', (
      tester,
    ) async {
      await _pumpBounded(
        tester,
        Scope.ofState(
          const {
            'items': [
              {'id': 'a', 'name': 'Alice'},
              {'id': 'b', 'name': 'Bob'},
            ],
          },
          child: _content(const {
            '_type': 'text',
            'value': r'${it.name}',
            '_loop': {
              '_in': r'${items}',
              '_as': 'it',
              '_key': r'${it.id}',
              '_wrap': {'_type': 'swipe', 'scroll_direction': 'vertical'},
            },
          }),
        ),
      );
      await tester.pump();

      expect(
        tester.widget<PageView>(find.byType(PageView)).scrollDirection,
        Axis.vertical,
      );
    });

    testWidgets('literal list를 펼치고 각 항목과 바깥 바인딩을 푼다', (tester) async {
      await _pump(
        tester,
        Scope.ofState(
          const {'outer': 'outside'},
          child: _content(const {
            '_type': 'text',
            'value': r'${item.v}-${item.label}',
            '_loop': {
              '_in': [
                {'v': 1, 'label': r'${outer}'},
                {'v': 2, 'label': 'literal'},
              ],
              '_key': r'${item.v}',
            },
          }),
        ),
      );

      expect(find.text('1-outside'), findsOneWidget);
      expect(find.text('2-literal'), findsOneWidget);
    });

    testWidgets('소스가 바뀌면 재확장한다', (tester) async {
      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          const {
            'items': [
              {'id': 'a', 'name': 'Alice'},
            ],
          },
          key: key,
          child: _content(_template),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsNothing);

      key.currentState!.set('items', const [
        {'id': 'a', 'name': 'Alice'},
        {'id': 'b', 'name': 'Bob'},
      ]);
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('같은 key로 항목 내용이 바뀌면 새 값을 반영한다', (tester) async {
      // keyed reconciliation이 item Scope를 재사용하는 바로 그 경로 — H1.
      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          const {
            'items': [
              {'id': 'a', 'name': 'Alice'},
            ],
          },
          key: key,
          child: _content(_template),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);

      key.currentState!.set('items', const [
        {'id': 'a', 'name': 'Alicia'}, // 같은 id, 새 내용
      ]);
      await tester.pump();

      expect(find.text('Alicia'), findsOneWidget);
      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('앞에 항목이 추가돼 인덱스가 밀리면 기존 항목 인덱스도 갱신된다', (tester) async {
      const indexTemplate = {
        '_type': 'text',
        'value': r'${i}',
        '_loop': {
          '_in': r'${items}',
          '_as': 'it',
          '_index': 'i',
          '_key': r'${it.id}',
        },
      };
      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          const {
            'items': [
              {'id': 'a'},
            ],
          },
          key: key,
          child: _content(indexTemplate),
        ),
      );

      expect(find.text('0'), findsOneWidget); // a는 인덱스 0

      key.currentState!.set('items', const [
        {'id': 'x'}, // 앞에 추가 → a가 인덱스 1로 밀림
        {'id': 'a'},
      ]);
      await tester.pump();

      expect(find.text('0'), findsOneWidget); // x
      expect(find.text('1'), findsOneWidget); // 재사용된 a의 인덱스 갱신
    });

    group('_wrap 컨테이너 전략', () {
      Map<String, Object?> wrapTemplate(String? wrap) => {
        '_type': 'text',
        'value': r'${it}',
        '_loop': {
          '_in': r'${items}',
          '_as': 'it',
          '_key': r'${it}',
          '_wrap': ?wrap,
        },
      };

      Widget hosted(String? wrap) => Scope.ofState(const {
        'items': ['a', 'b'],
      }, child: _content(wrapTemplate(wrap)));

      testWidgets('기본(_wrap 없음)은 Column', (tester) async {
        await _pump(tester, hosted(null));
        expect(find.byType(Column), findsOneWidget);
        expect(find.text('a'), findsOneWidget);
        expect(find.text('b'), findsOneWidget);
      });

      testWidgets('row는 Row', (tester) async {
        await _pump(tester, hosted('row'));
        expect(find.byType(Row), findsOneWidget);
      });

      testWidgets('wrap은 Wrap', (tester) async {
        await _pump(tester, hosted('wrap'));
        expect(find.byType(Wrap), findsOneWidget);
      });

      testWidgets('auto_scroll은 항목을 가로 ListView로 펼친다', (tester) async {
        await _pump(
          tester,
          Scope.ofState(
            const {
              'items': ['a', 'b'],
            },
            child: _content(const {
              '_type': 'text',
              'value': r'${it}',
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it}',
                '_wrap': {
                  '_type': 'auto_scroll',
                  'scroll_direction': 'horizontal',
                },
              },
            }),
          ),
        );

        expect(
          tester.widget<ListView>(find.byType(ListView)).scrollDirection,
          Axis.horizontal,
        );
        expect(find.text('a'), findsWidgets);
        expect(find.text('b'), findsWidgets);
      });

      testWidgets('auto_scroll은 빈 소스에서 SizedBox.shrink를 렌더링한다', (tester) async {
        await _pump(
          tester,
          Scope.ofState(
            const {'items': <String>[]},
            child: _content(const {
              '_type': 'text',
              'value': r'${it}',
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it}',
                '_wrap': {
                  '_type': 'auto_scroll',
                  'scroll_direction': 'horizontal',
                },
              },
            }),
          ),
        );

        expect(find.byType(ListView), findsNothing);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox && widget.width == 0 && widget.height == 0,
          ),
          findsOneWidget,
        );
      });

      testWidgets('list는 스크롤 ListView', (tester) async {
        await _pump(tester, hosted('list'));
        expect(find.byType(ListView), findsOneWidget);
        expect(find.text('a'), findsOneWidget);
      });

      testWidgets('list는 lazy — 화면 밖 항목은 build하지 않는다', (tester) async {
        await _pump(
          tester,
          Scope.ofState(
            {
              'items': [for (var i = 0; i < 50; i++) 'Item $i'],
            },
            child: _content(const {
              '_type': 'container',
              'height': 100, // 항목당 100px → 화면(≈600px)엔 앞쪽 몇 개만
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it}',
                '_wrap': 'list',
              },
              '_child': {'_type': 'text', 'value': r'${it}'},
            }),
          ),
        );
        expect(find.text('Item 0'), findsOneWidget);
        expect(find.text('Item 49'), findsNothing); // 화면 밖 → 미build(lazy)
      });

      testWidgets('row _wrap 맵으로 spacing을 준다', (tester) async {
        await _pump(
          tester,
          Scope.ofState(
            const {
              'items': ['a', 'b'],
            },
            child: _content(const {
              '_type': 'text',
              'value': r'${it}',
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it}',
                '_wrap': {'_type': 'row', 'spacing': 8},
              },
            }),
          ),
        );
        expect(tester.widget<Row>(find.byType(Row)).spacing, 8);
      });

      testWidgets(r'_wrap 인자의 바인딩(${gap})이 풀리고 상태 변경에 반응한다', (tester) async {
        // 회귀 방어: wrap 인자도 위젯 prop과 같은 값 방언으로 컴파일돼야 한다. raw로 두면 `${gap}`이
        // PropsResolver에서 0으로 뭉개지고 gap 변경에도 반응하지 않는다(검토 §0.3).
        final key = GlobalKey<ScopeState>();
        await _pump(
          tester,
          Scope.ofState(
            const {
              'items': ['a', 'b'],
              'gap': 8,
            },
            key: key,
            child: _content(const {
              '_type': 'text',
              'value': r'${it}',
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it}',
                '_wrap': {'_type': 'row', 'spacing': r'${gap}'},
              },
            }),
          ),
        );

        expect(tester.widget<Row>(find.byType(Row)).spacing, 8); // 바인딩 해석됨

        key.currentState!.set('gap', 16);
        await tester.pump();

        expect(
          tester.widget<Row>(find.byType(Row)).spacing,
          16,
        ); // roots 구독 → 반응
      });

      testWidgets('list _wrap 맵으로 padding을 준다', (tester) async {
        await _pump(
          tester,
          Scope.ofState(
            const {
              'items': ['a', 'b'],
            },
            child: _content(const {
              '_type': 'text',
              'value': r'${it}',
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it}',
                '_wrap': {'_type': 'list', 'padding': 16},
              },
            }),
          ),
        );
        expect(
          tester.widget<ListView>(find.byType(ListView)).padding,
          const EdgeInsets.all(16),
        );
      });

      testWidgets('grid(맵 형태)는 crossAxisCount 격자 GridView', (tester) async {
        await _pump(
          tester,
          Scope.ofState(
            const {
              'items': ['a', 'b', 'c', 'd'],
            },
            child: _content(const {
              '_type': 'text',
              'value': r'${it}',
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it}',
                '_wrap': {'_type': 'grid', 'cross_axis_count': 2},
              },
            }),
          ),
        );
        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 2);
        expect(find.text('a'), findsOneWidget);
      });

      testWidgets('spin_grid은 항목을 GridView 하위 트리로 펼친다 (bare column으로 새지 않는다)', (
        tester,
      ) async {
        // 회귀 방어: spin_grid이 _knownWraps엔 있었지만 한때 _expand 스위치엔
        // case가 없어 default 분기(평범한 column)로 떨어졌던 결함의 재현.
        // draw_slot 셀은 expanded 자식 둘을 가진 column이라 무한 높이 column
        // 안에서 렌더 크래시로 이어졌다 — GridView가 실제로 마운트됐는지가 곧
        // 그 결함이 재발하지 않았다는 증거다.
        await _pump(
          tester,
          Scope.ofState(
            const {
              'items': ['a', 'b', 'c', 'd'],
            },
            child: _content(const {
              '_type': 'text',
              'value': r'${it}',
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it}',
                '_wrap': {'_type': 'spin_grid', 'winner_index': 0},
              },
            }),
          ),
        );

        expect(find.byType(GridView), findsOneWidget);
        for (final label in ['a', 'b', 'c', 'd']) {
          expect(
            find.descendant(
              of: find.byType(GridView),
              matching: find.text(label),
            ),
            findsOneWidget,
          );
        }
      });

      testWidgets('grid shrink_wrap는 컬럼 안에서 오버플로 없이 렌더한다', (tester) async {
        await _pump(
          tester,
          Scope.ofState(
            const {
              'items': ['a', 'b', 'c'],
            },
            child: Column(
              children: [
                _content(const {
                  '_type': 'text',
                  'value': r'${it}',
                  '_loop': {
                    '_in': r'${items}',
                    '_as': 'it',
                    '_key': r'${it}',
                    '_wrap': {
                      '_type': 'grid',
                      'cross_axis_count': 3,
                      'shrink_wrap': true,
                      'physics': 'never',
                    },
                  },
                }),
              ],
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(
          tester.widget<GridView>(find.byType(GridView)).shrinkWrap,
          isTrue,
        );
        expect(find.text('a'), findsOneWidget);
      });

      testWidgets(
        'grid crossAxisCount가 틀린 타입이면 기본값으로 폴백한다 (관대, TypeError 없음)',
        (tester) async {
          // 회귀 방어: grid 인자를 `as num?`로 직접 캐스트하면 `"three"` 같은 값이 렌더 중 TypeError를
          // 던져 NodeGuard를 우회한다. PropsResolver 관대 파싱으로 기본값 폴백해야 한다(검토 §0.4).
          await _pump(
            tester,
            Scope.ofState(
              const {
                'items': ['a', 'b'],
              },
              child: _content(const {
                '_type': 'text',
                'value': r'${it}',
                '_loop': {
                  '_in': r'${items}',
                  '_as': 'it',
                  '_key': r'${it}',
                  '_wrap': {'_type': 'grid', 'cross_axis_count': 'three'},
                },
              }),
            ),
          );
          final grid = tester.widget<GridView>(find.byType(GridView));
          final delegate =
              grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
          expect(delegate.crossAxisCount, 2); // 'three' → null → 기본값
          expect(tester.takeException(), isNull); // 캐스트 TypeError 안 남
        },
      );

      testWidgets('grid crossAxisCount 0은 1로 클램프해 마운트한다', (tester) async {
        await _pump(
          tester,
          Scope.ofState(
            const {
              'items': ['a', 'b'],
            },
            child: _content(const {
              '_type': 'text',
              'value': r'${it}',
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it}',
                '_wrap': {'_type': 'grid', 'cross_axis_count': 0},
              },
            }),
          ),
        );

        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, greaterThanOrEqualTo(1));
        expect(tester.takeException(), isNull);
      });

      testWidgets('sliverGrid는 CustomScrollView 안의 SliverGrid', (tester) async {
        await _pump(
          tester,
          Scope.ofState(
            const {
              'items': ['a', 'b'],
            },
            child: CustomScrollView(
              slivers: [
                _content(const {
                  '_type': 'text',
                  'value': r'${it}',
                  '_loop': {
                    '_in': r'${items}',
                    '_as': 'it',
                    '_key': r'${it}',
                    '_wrap': {'_type': 'sliver_grid', 'cross_axis_count': 2},
                  },
                }),
              ],
            ),
          ),
        );
        expect(find.byType(SliverGrid), findsOneWidget);
        expect(find.text('a'), findsOneWidget);
      });

      testWidgets('sliverList는 CustomScrollView 안의 SliverList', (tester) async {
        // sliver는 뷰포트 안에서만 성립 — Scope는 CustomScrollView 밖에 둬 sliver 슬롯을 안 막는다.
        await _pump(
          tester,
          Scope.ofState(
            const {
              'items': ['a', 'b'],
            },
            child: CustomScrollView(
              slivers: [_content(wrapTemplate('sliver_list'))],
            ),
          ),
        );
        expect(find.byType(SliverList), findsOneWidget);
        expect(find.text('a'), findsOneWidget);
      });
    });
  });
}
