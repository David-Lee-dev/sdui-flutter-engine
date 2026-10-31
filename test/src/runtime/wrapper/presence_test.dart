import 'package:flutter/material.dart' hide Action;
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/ir/model/action/command.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/scope_config.dart';
import 'package:sdui_engine/src/presentation/presence_style.dart';
import 'package:sdui_engine/src/presentation/presentation.dart';
import 'package:sdui_engine/src/runtime/engine_presentation.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/skeleton_scope.dart';

/// Presence transitions of structural directives: the space axis (a slot
/// grows into and collapses out of its place) and the visual axis (`_motion`
/// entries with `on: exit|both` played backwards while content leaves).

Widget _content(Map<String, Object?> template) => NodeBuilder.build(
  TemplateCompiler.buildDirectiveTree(TemplateParser.buildUiTree(template)),
);

Widget _host(
  Map<String, Object?> state,
  Widget child, {
  bool reduceMotion = false,
  Map<String, Object?> actions = const {},
}) => Directionality(
  textDirection: TextDirection.ltr,
  child: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: EngineMetrics(
      scale: 1.0,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 300,
          height: 400,
          child: Scope(
            config: ScopeConfig(state: state),
            actions: actions.isEmpty ? const {} : _actions(actions),
            child: child,
          ),
        ),
      ),
    ),
  ),
);

/// Compiles [raw] `_action` entries through the template compiler.
Map<String, Action> _actions(Map<String, Object?> raw) {
  final scope = TemplateCompiler.buildDirectiveTree(
    TemplateParser.buildUiTree({
      '_type': 'sizedbox',
      '_scope': {'_action': raw},
    }),
  );
  return (scope as ScopeDirective).actions;
}

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

double _top(WidgetTester tester, String text) =>
    tester.getTopLeft(find.text(text)).dy;

double _opacityAbove(WidgetTester tester, String text) => tester
    .widget<Opacity>(
      find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first,
    )
    .opacity;

/// A column with an `_if` box of height 50 labelled `top` over a box
/// labelled `below`, so `below`'s offset is the slot's height.
Map<String, Object?> _toggled({
  Object? motion,
  Object? presence,
  String label = 'top',
}) => {
  '_type': 'column',
  '_children': [
    {
      ..._box(label, height: 50),
      '_if': r'${show}',
      '_motion': ?motion,
      '_presence': ?presence,
    },
    _box('below'),
  ],
};

/// No ticker is running (a running controller registers a transient
/// frame callback).
/// Every label in the current semantics tree.
List<String> _labels(WidgetTester tester) {
  final labels = <String>[];
  bool visit(SemanticsNode node) {
    labels.add(node.label);
    node.visitChildren(visit);
    return true;
  }

  final owner = tester.binding.renderViews.first.owner!;
  final root = owner.semanticsOwner!.rootSemanticsNode;
  if (root != null) visit(root);
  return labels;
}

bool _idle(WidgetTester tester) => tester.binding.transientCallbackCount == 0;

void main() {
  tearDown(EnginePresentation.reset);

  group('presence', () {
    testWidgets('the first build animates nothing and starts no ticker', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host({
          'show': true,
          'items': _items(['a', 'b']),
        }, _content(_toggled())),
      );

      expect(_top(tester, 'below'), 50);
      expect(_idle(tester), isTrue);
    });

    testWidgets('a settled slot schedules no frames', (tester) async {
      await tester.pumpWidget(
        _host({
          'show': true,
          'items': _items(['a', 'b']),
        }, _content(_toggled(motion: {'type': 'fade', 'on': 'exit'}))),
      );
      _scope(tester).set('show', false);
      await tester.pumpAndSettle();
      _scope(tester).set('show', true);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 1));
      expect(_idle(tester), isTrue);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('a cond that turns true grows its slot over 300 ms', (
      tester,
    ) async {
      await tester.pumpWidget(_host({'show': false}, _content(_toggled())));
      expect(_top(tester, 'below'), 0);

      _scope(tester).set('show', true);
      await tester.pump();
      expect(find.text('top'), findsOneWidget);
      expect(_top(tester, 'below'), 0);

      await tester.pump(const Duration(milliseconds: 150));
      // emphasized_decelerate is most of the way there half way through.
      expect(_top(tester, 'below'), inExclusiveRange(35, 50));

      await tester.pump(const Duration(milliseconds: 150));
      expect(_top(tester, 'below'), 50);
      await tester.pumpAndSettle();
      expect(_idle(tester), isTrue);
    });

    testWidgets(
      'a cond that turns false plays its exit motion backwards and collapses',
      (tester) async {
        await tester.pumpWidget(
          _host({
            'show': true,
          }, _content(_toggled(motion: {'type': 'fade', 'on': 'exit'}))),
        );
        expect(_opacityAbove(tester, 'top'), 1);

        _scope(tester).set('show', false);
        await tester.pump();
        expect(find.text('top'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 125));
        expect(_top(tester, 'below'), inExclusiveRange(0, 50));
        expect(_opacityAbove(tester, 'top'), inExclusiveRange(0, 1));

        await tester.pump(const Duration(milliseconds: 125));
        expect(_top(tester, 'below'), 0);
        // The fade (300 ms) outlasts the collapse (250 ms).
        expect(find.text('top'), findsOneWidget);

        await tester.pumpAndSettle();
        expect(find.text('top'), findsNothing);
        expect(_idle(tester), isTrue);
      },
    );

    testWidgets('leaving content keeps the values it showed last', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          {
            'banner': {'title': 'Hello'},
          },
          _content({
            '_type': 'column',
            '_children': [
              {
                '_type': 'text',
                'value': r'${banner.title}',
                '_if': r'${banner != null}',
              },
            ],
          }),
        ),
      );

      _scope(tester).set('banner', null);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Hello'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsNothing);
    });

    testWidgets('coming back while exiting reverses on the same element', (
      tester,
    ) async {
      await tester.pumpWidget(_host({'show': true}, _content(_toggled())));
      final top = tester.element(find.text('top'));

      _scope(tester).set('show', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final collapsed = _top(tester, 'below');
      expect(collapsed, inExclusiveRange(0, 50));

      _scope(tester).set('show', true);
      await tester.pump();
      expect(_top(tester, 'below'), closeTo(collapsed, 0.01));
      await tester.pump(const Duration(milliseconds: 50));
      expect(_top(tester, 'below'), greaterThan(collapsed));

      await tester.pumpAndSettle();
      expect(tester.element(find.text('top')), same(top));
      expect(_top(tester, 'below'), 50);
    });

    testWidgets('an if/else swap shows both while the size goes A to B', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          {'show': true},
          _content({
            '_type': 'column',
            '_children': [
              {
                '_type': 'cond',
                '_children': [
                  {..._box('A', height: 50), '_if': r'${show}'},
                  {..._box('B'), '_else': true},
                ],
              },
              _box('below'),
            ],
          }),
        ),
      );

      _scope(tester).set('show', false);
      await tester.pump();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 150));
      expect(_top(tester, 'below'), inExclusiveRange(20, 50));

      await tester.pumpAndSettle();
      expect(find.text('A'), findsNothing);
      expect(find.text('B'), findsOneWidget);
      expect(_top(tester, 'below'), 20);
    });

    testWidgets('a switch case change swaps the same way', (tester) async {
      await tester.pumpWidget(
        _host(
          {'tab': 'a'},
          _content({
            '_type': 'column',
            '_children': [
              {
                '_type': 'switch',
                '_value': r'${tab}',
                '_children': [
                  {..._box('A', height: 50), '_case': 'a'},
                  {..._box('B'), '_case': 'b'},
                ],
              },
              _box('below'),
            ],
          }),
        ),
      );

      _scope(tester).set('tab', 'b');
      await tester.pump();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 150));
      expect(_top(tester, 'below'), inExclusiveRange(20, 50));

      await tester.pumpAndSettle();
      expect(find.text('A'), findsNothing);
      expect(_top(tester, 'below'), 20);
    });

    testWidgets('an eager column loop collapses removed and grows new items', (
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

      _scope(tester).set('items', _items(['a', 'c']));
      await tester.pump();
      expect(find.text('b'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 125));
      expect(_top(tester, 'c'), inExclusiveRange(20, 40));
      await tester.pumpAndSettle();
      expect(find.text('b'), findsNothing);
      expect(_top(tester, 'c'), 20);

      _scope(tester).set('items', _items(['a', 'd', 'c']));
      await tester.pump();
      expect(_top(tester, 'd'), 20);
      expect(_top(tester, 'c'), 20);
      await tester.pump(const Duration(milliseconds: 150));
      expect(_top(tester, 'c'), inExclusiveRange(20, 40));
      await tester.pumpAndSettle();
      expect(_top(tester, 'c'), 40);
      expect(_idle(tester), isTrue);
    });

    testWidgets('an eager row loop collapses a removed item along its width', (
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
              '_wrap': 'row',
            },
          }),
        ),
      );

      _scope(tester).set('items', _items(['a', 'c']));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 125));
      expect(tester.getTopLeft(find.text('c')).dx, inExclusiveRange(100, 200));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('c')).dx, 100);
    });

    testWidgets('an expanded body keeps parent data and plays its exit', (
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
                '_motion': {'type': 'fade', 'on': 'exit'},
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

      _scope(tester).set('show', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
      expect(find.byType(Expanded), findsOneWidget);
      expect(tester.getTopLeft(find.text('fill')).dx, 100);
      expect(_opacityAbove(tester, 'fill'), inExclusiveRange(0, 1));

      await tester.pumpAndSettle();
      expect(find.text('fill'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('popping the route mid-exit disposes without errors', (
      tester,
    ) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigator, home: const SizedBox()),
      );
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => _host({
            'show': true,
          }, _content(_toggled(motion: {'type': 'fade', 'on': 'exit'}))),
        ),
      );
      await tester.pumpAndSettle();

      _scope(tester).set('show', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      navigator.currentState!.pop();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('top'), findsNothing);
    });

    testWidgets('removing the parent of an exiting cond disposes it at once', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          {'outer': true, 'inner': true},
          _content({
            '_type': 'column',
            '_if': r'${outer}',
            '_presence': false,
            '_children': [
              {
                ..._box('inner', height: 50),
                '_if': r'${inner}',
                '_motion': {'type': 'fade', 'on': 'exit'},
              },
            ],
          }),
        ),
      );

      _scope(tester).set('inner', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('inner'), findsOneWidget);

      _scope(tester).set('outer', false);
      await tester.pump();

      expect(find.text('inner'), findsNothing);
      expect(tester.takeException(), isNull);
      expect(_idle(tester), isTrue);
    });

    testWidgets('reduced motion enters and exits at once', (tester) async {
      await tester.pumpWidget(
        _host(
          {'show': true},
          _content(_toggled(motion: {'type': 'fade', 'on': 'exit'})),
          reduceMotion: true,
        ),
      );

      _scope(tester).set('show', false);
      await tester.pump();
      expect(find.text('top'), findsNothing);
      expect(_top(tester, 'below'), 0);

      _scope(tester).set('show', true);
      await tester.pump();
      expect(_top(tester, 'below'), 50);
      expect(_idle(tester), isTrue);
    });

    testWidgets('_presence: false keeps the change instant', (tester) async {
      await tester.pumpWidget(
        _host(
          {'show': true},
          _content(
            _toggled(motion: {'type': 'fade', 'on': 'exit'}, presence: false),
          ),
        ),
      );

      _scope(tester).set('show', false);
      await tester.pump();

      expect(find.text('top'), findsNothing);
      expect(_top(tester, 'below'), 0);
      expect(_idle(tester), isTrue);
    });

    testWidgets('space: false plays the exit without animating the size', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          {'show': true},
          _content(
            _toggled(
              motion: {'type': 'fade', 'on': 'exit'},
              presence: {'space': false},
            ),
          ),
        ),
      );

      _scope(tester).set('show', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(_top(tester, 'below'), 0);
      expect(find.text('top'), findsOneWidget);
      expect(_opacityAbove(tester, 'top'), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(find.text('top'), findsNothing);
    });

    testWidgets('sequential order fades out first, then collapses', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          {'show': true},
          _content(
            _toggled(
              motion: {'type': 'fade', 'on': 'both'},
              presence: {'order': 'sequential'},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      _scope(tester).set('show', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(_top(tester, 'below'), 50);
      expect(_opacityAbove(tester, 'top'), inExclusiveRange(0, 1));

      await tester.pump(const Duration(milliseconds: 275));
      expect(_top(tester, 'below'), inExclusiveRange(0, 50));
      await tester.pumpAndSettle();
      expect(find.text('top'), findsNothing);

      // Back in: the slot expands (300 ms), then the entrance fade starts.
      _scope(tester).set('show', true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(_top(tester, 'below'), inExclusiveRange(0, 50));
      expect(_opacityAbove(tester, 'top'), 0);
      await tester.pump(const Duration(milliseconds: 160));
      await tester.pump(const Duration(milliseconds: 140));
      expect(_top(tester, 'below'), 50);
      expect(_opacityAbove(tester, 'top'), greaterThan(0));
      await tester.pumpAndSettle();
    });

    testWidgets('a reveal entrance owns the space instead of the slot', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host({'show': false}, _content(_toggled(motion: 'reveal_down'))),
      );

      _scope(tester).set('show', true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final reveal = find
          .ancestor(
            of: find.text('top'),
            matching: find.byWidgetPredicate(
              (w) => w is Align && w.heightFactor != null,
            ),
          )
          .first;
      final revealed = tester.getSize(reveal).height;
      expect(revealed, inExclusiveRange(0, 50));
      expect(_top(tester, 'below'), closeTo(revealed, 0.01));
      await tester.pumpAndSettle();
      expect(_top(tester, 'below'), 50);
    });

    testWidgets(
      'leaving content takes no input, semantics or action host and pauses '
      'its lifecycle',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          _host(
            {'show': true, 'taps': 0},
            _content({
              '_type': 'column',
              '_children': [
                {
                  '_type': 'sizedbox',
                  'width': 100,
                  'height': 50,
                  '_if': r'${show}',
                  '_on': {'tap': 'bump'},
                  '_scope': {
                    '_state': {'ticks': 0},
                    '_action': {
                      'tick': {'_type': 'set', 'ticks': r'${ticks + 1}'},
                    },
                    '_lifecycle': [
                      {'on': 'interval', 'action': 'tick', 'every': 50},
                    ],
                  },
                  '_child': {'_type': 'text', 'value': r'ticks ${ticks}'},
                },
                {'_type': 'text', 'value': r'taps ${taps}'},
              ],
            }),
            actions: {
              'bump': {'_type': 'set', 'taps': r'${taps + 1}'},
            },
          ),
        );
        await tester.pump(const Duration(milliseconds: 120));
        final ticking = find.textContaining('ticks ');
        final before = tester.widget<Text>(ticking).data;
        expect(before, isNot('ticks 0'));
        expect(Scope.actionHost(tester.element(ticking)), isNotNull);

        _scope(tester).set('show', false);
        await tester.pump();
        expect(Scope.actionHost(tester.element(ticking)), isNull);
        expect(_labels(tester).where((l) => l.contains('ticks')), isEmpty);
        final frozen = tester.widget<Text>(ticking).data;

        await tester.tapAt(const Offset(50, 10));
        await tester.pump(const Duration(milliseconds: 120));
        expect(find.text('taps 0'), findsOneWidget);
        expect(tester.widget<Text>(ticking).data, frozen);

        _scope(tester).set('show', true);
        await tester.pumpAndSettle(const Duration(milliseconds: 10));
        await tester.pump(const Duration(milliseconds: 120));
        expect(Scope.actionHost(tester.element(ticking)), isNotNull);
        expect(tester.widget<Text>(ticking).data, isNot(frozen));
        semantics.dispose();
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('on: both runs the entrance and plays it backwards to exit', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host({
          'show': false,
        }, _content(_toggled(motion: {'type': 'fade', 'on': 'both'}))),
      );

      _scope(tester).set('show', true);
      await tester.pump();
      expect(_opacityAbove(tester, 'top'), 0);
      await tester.pump(const Duration(milliseconds: 150));
      expect(_opacityAbove(tester, 'top'), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(_opacityAbove(tester, 'top'), 1);

      _scope(tester).set('show', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(_opacityAbove(tester, 'top'), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(find.text('top'), findsNothing);
    });

    testWidgets('an exit plays only the removed slot, not nested slots', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          {'show': true, 'inner': true},
          _content({
            '_type': 'column',
            '_children': [
              {
                '_type': 'column',
                '_if': r'${show}',
                '_motion': {'type': 'fade', 'on': 'exit'},
                '_children': [
                  {
                    '_type': 'text',
                    'value': 'nested',
                    '_if': r'${inner}',
                    '_motion': {'type': 'scale', 'on': 'exit'},
                  },
                ],
              },
            ],
          }),
        ),
      );

      _scope(tester).set('show', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(_opacityAbove(tester, 'nested'), inExclusiveRange(0, 1));
      final scale = tester.widget<Transform>(
        find
            .ancestor(of: find.text('nested'), matching: find.byType(Transform))
            .first,
      );
      expect(scale.transform.getMaxScaleOnAxis(), 1);
      await tester.pumpAndSettle();
    });

    testWidgets('the presence style sets the app-wide timing', (tester) async {
      EnginePresentation.value = const SduiPresentation(
        presence: PresenceStyle(
          exit: Duration(milliseconds: 100),
          exitCurve: Curves.linear,
        ),
      );
      await tester.pumpWidget(_host({'show': true}, _content(_toggled())));

      _scope(tester).set('show', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(_top(tester, 'below'), closeTo(25, 0.5));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();
      expect(find.text('top'), findsNothing);
    });

    testWidgets('a template duration and curve override the style', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host({
          'show': true,
        }, _content(_toggled(presence: {'duration': 100, 'curve': 'linear'}))),
      );

      _scope(tester).set('show', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(_top(tester, 'below'), closeTo(25, 0.5));
    });

    testWidgets('muted tickers finish an exit at once', (tester) async {
      Widget page(bool enabled) => TickerMode(
        enabled: enabled,
        child: _host({
          'show': true,
        }, _content(_toggled(motion: {'type': 'fade', 'on': 'exit'}))),
      );
      await tester.pumpWidget(page(true));

      _scope(tester).set('show', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('top'), findsOneWidget);

      await tester.pumpWidget(page(false));
      await tester.pump();
      expect(find.text('top'), findsNothing);
      expect(_idle(tester), isTrue);
    });

    testWidgets('a reseed removes content at once, without an exit', (
      tester,
    ) async {
      final template = _toggled(motion: {'type': 'fade', 'on': 'exit'});
      await tester.pumpWidget(_host({'show': true}, _content(template)));
      expect(_top(tester, 'below'), 50);

      await tester.pumpWidget(_host({'show': false}, _content(template)));
      expect(find.text('top'), findsNothing);
      expect(_top(tester, 'below'), 0);
      expect(_idle(tester), isTrue);

      await tester.pumpWidget(_host({'show': true}, _content(template)));
      expect(_top(tester, 'below'), 50);
      expect(_idle(tester), isTrue);

      // A commit after the reseed frame animates again.
      _scope(tester).set('show', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('top'), findsOneWidget);
    });

    testWidgets('a reseed that brings content back mid-exit shows it at rest', (
      tester,
    ) async {
      final template = _toggled(motion: {'type': 'fade', 'on': 'exit'});
      await tester.pumpWidget(
        _host({'show': true, 'rev': 0}, _content(template)),
      );

      _scope(tester).set('show', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_opacityAbove(tester, 'top'), inExclusiveRange(0, 1));

      await tester.pumpWidget(
        _host({'show': true, 'rev': 1}, _content(template)),
      );
      expect(_top(tester, 'below'), 50);
      expect(_opacityAbove(tester, 'top'), 1);
      expect(_idle(tester), isTrue);
    });

    testWidgets('a leaving text field gives up focus and the keyboard', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: _host(
              {'show': true, 'q': ''},
              _content({
                '_type': 'column',
                '_children': [
                  {'_type': 'text', 'value': r'q=${q}'},
                  {'_type': 'text_field', 'bind': 'q', '_if': r'${show}'},
                ],
              }),
            ),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField));
      final field = tester.element(find.byType(EditableText));
      final focus = tester
          .widget<EditableText>(find.byType(EditableText))
          .focusNode;
      expect(tester.testTextInput.hasAnyClients, isTrue);

      _scope(tester).set('show', false);
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
      expect(focus.hasFocus, isFalse);
      expect(tester.testTextInput.hasAnyClients, isFalse);
      expect(find.text('q='), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      _scope(tester).set('show', true);
      await tester.pump();
      await tester.showKeyboard(find.byType(TextField));
      expect(tester.element(find.byType(EditableText)), same(field));
      expect(focus.hasFocus, isTrue);
      await tester.enterText(find.byType(TextField), 'hi');
      await tester.pump();
      expect(find.text('q=hi'), findsOneWidget);
    });

    group('skeleton swap', () {
      testWidgets('goes from the skeleton size to the content size', (
        tester,
      ) async {
        final loading = ValueNotifier(true);
        addTearDown(loading.dispose);
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SkeletonScope(
                loading: loading,
                skeleton: const SizedBox(width: 100, height: 120),
                child: const SizedBox(
                  width: 100,
                  height: 40,
                  child: Text('content'),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));

        loading.value = false;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('content'), findsOneWidget);
        expect(
          tester.getSize(find.byType(SkeletonScope)).height,
          inExclusiveRange(40, 120),
        );

        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(SkeletonScope)).height, 40);
        expect(find.byType(ShaderMask), findsNothing);
      });
    });
  });
}
