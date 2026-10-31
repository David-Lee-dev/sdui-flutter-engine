import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/contract/error_observer.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
import 'package:sdui_engine/src/ir/model/scope_config.dart';
import 'package:sdui_engine/src/runtime/engine_errors.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';

Directive _compile(Map<String, Object?> template) =>
    TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template));

Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: MediaQuery(
    data: const MediaQueryData(),
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 300, height: 400, child: child),
    ),
  ),
);

/// The zero-extent sliver an empty branch leaves; a viewport reports it as
/// offstage.
final _emptySliver = find.byWidgetPredicate(
  (widget) => widget is SliverToBoxAdapter && widget.child == null,
  skipOffstage: false,
);

class _Errors implements SduiErrorObserver {
  final errors = <SduiError>[];

  @override
  void onError(SduiError error) => errors.add(error);
}

void main() {
  late _Errors errors;
  setUp(() => EngineErrors.observer = errors = _Errors());
  tearDown(EngineErrors.reset);
  tearDown(WidgetFactory.reset);

  group('빈 · 실패 출력은 대체하는 자리의 레이아웃 프로토콜을 따른다', () {
    for (final presence in [true, false]) {
      testWidgets('sliver `_if` 가 거짓이 되면 빈 sliver (presence=$presence)', (
        tester,
      ) async {
        final key = GlobalKey<ScopeState>();
        await tester.pumpWidget(
          _host(
            Scope(
              key: key,
              config: const ScopeConfig(state: {'show': true}),
              child: NodeBuilder.build(
                _compile({
                  '_type': 'custom_scroll_view',
                  '_children': [
                    {
                      '_type': 'sliver_to_box_adapter',
                      '_if': r'${show}',
                      '_presence': presence,
                      '_child': {'_type': 'text', 'value': 'content'},
                    },
                  ],
                }),
              ),
            ),
          ),
        );
        expect(find.text('content'), findsOneWidget);

        key.currentState!.set('show', false);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('content'), findsNothing);
        expect(_emptySliver, findsOneWidget);
      });
    }

    testWidgets('sliver `switch` 가 맞는 case 없이 비면 빈 sliver', (tester) async {
      await tester.pumpWidget(
        _host(
          Scope.ofState(
            const {'tab': 'none'},
            child: NodeBuilder.build(
              _compile({
                '_type': 'custom_scroll_view',
                '_children': [
                  {
                    '_type': 'switch',
                    '_value': r'${tab}',
                    '_children': [
                      {
                        '_type': 'sliver_to_box_adapter',
                        '_case': 'a',
                        '_child': {'_type': 'text', 'value': 'a'},
                      },
                    ],
                  },
                ],
              }),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_emptySliver, findsOneWidget);
    });

    testWidgets('_else 만 있는 sliver cond 는 fallback 본문을 그린다', (tester) async {
      await tester.pumpWidget(
        _host(
          NodeBuilder.build(
            _compile({
              '_type': 'custom_scroll_view',
              '_children': [
                {
                  '_type': 'cond',
                  '_children': [
                    {
                      '_type': 'sliver_to_box_adapter',
                      '_else': true,
                      '_child': {'_type': 'text', 'value': 'fallback'},
                    },
                  ],
                },
              ],
            }),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('fallback'), findsOneWidget);
    });

    testWidgets('prop 이 FormatException 을 던진 sliver 노드는 sliver 진단을 남긴다', (
      tester,
    ) async {
      WidgetFactory.register(
        'bad_sliver',
        EagerSpec(
          (context, props, children) => throw const FormatException('bad'),
          produces: LayoutProtocol.sliver,
        ),
      );
      await tester.pumpWidget(
        _host(
          NodeBuilder.build(
            _compile({
              '_type': 'custom_scroll_view',
              '_children': [
                {'_type': 'bad_sliver'},
                {
                  '_type': 'sliver_to_box_adapter',
                  '_child': {'_type': 'text', 'value': 'after'},
                },
              ],
            }),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(errors.errors, hasLength(1));
      expect(find.text('after'), findsOneWidget);
      expect(find.byType(SliverToBoxAdapter), findsNWidgets(2));
    });

    testWidgets('앱이 sliver_list 를 box 위젯으로 등록해도 loop 의 빈 출력은 sliver', (
      tester,
    ) async {
      WidgetFactory.register(
        'sliver_list',
        EagerSpec((context, props, children) => const SizedBox()),
      );
      final key = GlobalKey<ScopeState>();
      await tester.pumpWidget(
        _host(
          Scope(
            key: key,
            config: const ScopeConfig(state: {'show': true}),
            child: NodeBuilder.build(
              _compile({
                '_type': 'custom_scroll_view',
                '_children': [
                  {
                    '_type': 'cond',
                    '_children': [
                      {
                        '_type': 'text',
                        'value': r'item ${item}',
                        '_if': r'${show}',
                        '_loop': {
                          '_in': [1],
                          '_wrap': 'sliver_list',
                          '_key': r'${item}',
                        },
                      },
                    ],
                  },
                ],
              }),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('item 1'), findsOneWidget);

      key.currentState!.set('show', false);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('item 1'), findsNothing);
      expect(_emptySliver, findsOneWidget);
    });
  });

  group('엔진이 볼 수 없는 parent data 에는 래퍼를 씌우지 않는다', () {
    testWidgets('lifecycle scope 의 bare container > expanded', (tester) async {
      await tester.pumpWidget(
        _host(
          NodeBuilder.build(
            _compile({
              '_type': 'column',
              '_children': [
                {
                  '_type': 'container',
                  '_scope': {
                    '_state': {'x': 0},
                    '_action': {
                      'load': {'_type': 'set', 'x': 1},
                    },
                    '_lifecycle': [
                      {'on': 'mount', 'action': 'load'},
                    ],
                  },
                  '_child': {
                    '_type': 'expanded',
                    '_child': {'_type': 'text', 'value': 'content'},
                  },
                },
              ],
            }),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Expanded)).height, 400);
    });

    testWidgets('repeat `_morph` 의 bare container > expanded', (tester) async {
      await tester.pumpWidget(
        _host(
          NodeBuilder.build(
            _compile({
              '_type': 'column',
              '_children': [
                {
                  '_type': 'container',
                  '_morph': {
                    '_from': 0,
                    '_to': 1,
                    '_duration': 1000,
                    '_repeat': true,
                    '_as': 'v',
                  },
                  '_child': {
                    '_type': 'expanded',
                    '_child': {'_type': 'text', 'value': 'content'},
                  },
                },
              ],
            }),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Expanded)).height, 400);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('lifecycle scope 의 concrete expanded 는 안쪽 경계를 유지한다', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          NodeBuilder.build(
            _compile({
              '_type': 'column',
              '_children': [
                {
                  '_type': 'expanded',
                  '_scope': {
                    '_state': {'x': 0},
                    '_action': {
                      'load': {'_type': 'set', 'x': 1},
                    },
                    '_lifecycle': [
                      {'on': 'mount', 'action': 'load'},
                    ],
                  },
                  '_child': {'_type': 'text', 'value': 'content'},
                },
              ],
            }),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        find.descendant(
          of: find.byType(Expanded),
          matching: find.byType(RepaintBoundary),
        ),
        findsWidgets,
      );
    });

    testWidgets(
      'bare container > expanded 의 `_scope._skeleton` 은 건너뛰고 내용을 그린다',
      (tester) async {
        await tester.pumpWidget(
          _host(
            NodeBuilder.build(
              _compile({
                '_type': 'column',
                '_children': [
                  {
                    '_type': 'container',
                    '_scope': {
                      '_state': {'x': 0},
                      '_action': {
                        'load': {'_type': 'set', 'x': 1},
                      },
                      '_lifecycle': [
                        {'on': 'mount', 'action': 'load'},
                      ],
                      '_skeleton': {'_type': 'sizedbox', 'height': 20},
                    },
                    '_child': {
                      '_type': 'expanded',
                      '_child': {'_type': 'text', 'value': 'content'},
                    },
                  },
                ],
              }),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('content'), findsOneWidget);
      },
    );
  });
}
