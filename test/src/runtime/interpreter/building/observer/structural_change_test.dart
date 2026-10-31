import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/ir/model/scope_config.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';

/// Structural changes that stay as they are when presence transitions exist:
/// paths presence does not cover, first builds, reorders, reseeds, reloads
/// and route teardown.

Widget _content(Map<String, Object?> template) => NodeBuilder.build(
  TemplateCompiler.buildDirectiveTree(TemplateParser.buildUiTree(template)),
);

Widget _host(Map<String, Object?> state, Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: MediaQuery(
    data: const MediaQueryData(),
    child: EngineMetrics(
      scale: 1.0,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 300,
          height: 400,
          child: Scope(
            config: ScopeConfig(state: state),
            child: child,
          ),
        ),
      ),
    ),
  ),
);

ScopeState _scope(WidgetTester tester) =>
    tester.state<ScopeState>(find.byType(Scope).first);

Map<String, Object?> _box(String label, {double height = 20}) => {
  '_type': 'sizedbox',
  'width': 100,
  'height': height,
  '_child': {'_type': 'text', 'value': label},
};

List<Map<String, Object?>> _items(List<String> ids) => [
  for (final id in ids) {'id': id},
];

void main() {
  group('structural changes outside presence', () {
    testWidgets('a lazy list loop drops a removed item in the same frame', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          {
            'items': _items(['a', 'b', 'c']),
          },
          _content({
            ..._box(r'${it.id}'),
            '_loop': {
              '_in': r'${items}',
              '_as': 'it',
              '_key': r'${it.id}',
              '_wrap': 'list',
            },
          }),
        ),
      );
      expect(find.text('b'), findsOneWidget);

      _scope(tester).set('items', _items(['a', 'c']));
      await tester.pump();

      expect(find.text('b'), findsNothing);
      expect(tester.getTopLeft(find.text('c')).dy, 20);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets(
      'a sliver loop and a sliver cond body toggle in the same frame',
      (tester) async {
        await tester.pumpWidget(
          _host(
            {
              'show': true,
              'items': _items(['a', 'b']),
            },
            _content({
              '_type': 'custom_scroll_view',
              '_children': [
                {
                  '_type': 'cond',
                  '_children': [
                    {
                      '_type': 'sliver_to_box_adapter',
                      '_if': r'${show}',
                      '_child': _box('header'),
                    },
                    {
                      '_type': 'sliver_to_box_adapter',
                      '_else': true,
                      '_child': _box('footer'),
                    },
                  ],
                },
                {
                  ..._box(r'${it.id}'),
                  '_loop': {
                    '_in': r'${items}',
                    '_as': 'it',
                    '_key': r'${it.id}',
                    '_wrap': 'sliver_list',
                  },
                },
              ],
            }),
          ),
        );
        expect(find.text('header'), findsOneWidget);

        _scope(tester)
          ..set('show', false)
          ..set('items', _items(['b']));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('header'), findsNothing);
        expect(find.text('footer'), findsOneWidget);
        expect(find.text('a'), findsNothing);
        expect(tester.getTopLeft(find.text('b')).dy, 20);
      },
    );

    testWidgets('the first build lays out cond bodies and loop items in full', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          {
            'show': true,
            'items': _items(['a', 'b', 'c']),
          },
          _content({
            '_type': 'column',
            '_children': [
              {..._box('top', height: 50), '_if': r'${show}'},
              {
                ..._box(r'${it.id}'),
                '_loop': {'_in': r'${items}', '_as': 'it', '_key': r'${it.id}'},
              },
            ],
          }),
        ),
      );

      expect(tester.getTopLeft(find.text('a')).dy, 50);
      expect(tester.getTopLeft(find.text('c')).dy, 90);
    });

    testWidgets('an eager loop reorder moves kept items in the same frame', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          {
            'items': _items(['a', 'b', 'c']),
          },
          _content({
            ..._box(r'${it.id}'),
            '_loop': {'_in': r'${items}', '_as': 'it', '_key': r'${it.id}'},
          }),
        ),
      );
      final a = tester.element(find.text('a'));

      _scope(tester).set('items', _items(['c', 'b', 'a']));
      await tester.pump();

      expect(tester.element(find.text('a')), same(a));
      expect(tester.getTopLeft(find.text('a')).dy, 40);
      expect(tester.getTopLeft(find.text('c')).dy, 0);
    });

    testWidgets('an expanded cond body keeps its flex parent data', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          {'show': true},
          _content({
            '_type': 'row',
            '_children': [
              {'_type': 'sizedbox', 'width': 100, 'height': 20},
              {
                '_type': 'expanded',
                '_if': r'${show}',
                '_child': {
                  '_type': 'sizedbox',
                  'height': 20,
                  '_child': {'_type': 'text', 'value': 'fill'},
                },
              },
            ],
          }),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(Expanded), findsOneWidget);
      expect(tester.getTopLeft(find.text('fill')).dx, 100);
    });

    testWidgets('reseeding an equal template keeps the selected branch', (
      tester,
    ) async {
      const template = {
        '_type': 'cond',
        '_children': [
          {'_type': 'text', 'value': 'yes', '_if': r'${show}'},
          {'_type': 'text', 'value': 'no', '_else': true},
        ],
      };
      await tester.pumpWidget(_host({'show': true}, _content(template)));
      final yes = tester.element(find.text('yes'));

      await tester.pumpWidget(_host({'show': true}, _content(template)));

      expect(tester.element(find.text('yes')), same(yes));
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('a hot reload keeps the selected branch without a frame', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          {
            'show': true,
            'items': _items(['a']),
          },
          _content({
            '_type': 'column',
            '_children': [
              {'_type': 'text', 'value': 'yes', '_if': r'${show}'},
              {
                ..._box(r'${it.id}'),
                '_loop': {'_in': r'${items}', '_as': 'it', '_key': r'${it.id}'},
              },
            ],
          }),
        ),
      );
      final yes = tester.element(find.text('yes'));

      final reload = tester.binding.reassembleApplication();
      await tester.pump();
      await reload;

      expect(tester.element(find.text('yes')), same(yes));
      expect(find.text('a'), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('popping a route disposes its conds and loops cleanly', (
      tester,
    ) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigator, home: const SizedBox()),
      );
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => _host(
            {
              'show': true,
              'items': _items(['a', 'b']),
            },
            _content({
              '_type': 'column',
              '_children': [
                {'_type': 'text', 'value': 'yes', '_if': r'${show}'},
                {
                  ..._box(r'${it.id}'),
                  '_loop': {
                    '_in': r'${items}',
                    '_as': 'it',
                    '_key': r'${it.id}',
                  },
                },
              ],
            }),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('yes'), findsOneWidget);

      navigator.currentState!.pop();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('yes'), findsNothing);
      expect(find.text('a'), findsNothing);
    });
  });
}
