import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/contract/image_source.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_environment.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/observer/plain_observer.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';

/// A state change reassembles only the nodes that read it: observers reuse
/// their children's configurations between their own notifications.

Directive _compile(Map<String, Object?> template) =>
    TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template));

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;

Widget _app(Widget tree, ScopeEnvironment env) => MaterialApp(
  home: Scaffold(
    body: Scope.provideEnv(env: env, child: tree),
  ),
);

/// Counts plain-node assemblies by `path:type`: a static observer rebuilt by
/// its parent, or the listenable builder of a bound one.
Map<String, int> _observe() {
  final counts = <String, int>{};
  final previous = debugOnRebuildDirtyWidget;
  debugOnRebuildDirtyWidget = (element, builtOnce) {
    previous?.call(element, builtOnce);
    PlainObserver? observer;
    if (element.widget case PlainObserver w when w.directive.roots.isEmpty) {
      observer = w;
    } else if (element.widget is ListenableBuilder) {
      element.visitAncestorElements((parent) {
        if (parent.widget case PlainObserver w) observer = w;
        return false;
      });
    }
    final d = observer?.directive;
    if (d == null) return;
    counts.update('${d.path}:${d.type}', (n) => n + 1, ifAbsent: () => 1);
  };
  addTearDown(() => debugOnRebuildDirtyWidget = previous);
  return counts;
}

int _total(Map<String, int> counts) => counts.values.fold(0, (a, b) => a + b);

/// Hosts [tree] under [env] at a fixed size, for presence runs.
Widget _host(ScopeEnvironment env, Widget tree) => Directionality(
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
          child: Scope.provideEnv(env: env, child: tree),
        ),
      ),
    ),
  ),
);

void main() {
  setUp(() => EngineLog.configure(minLevel: LogLevel.warn));

  testWidgets('home logo: 30 offset changes assemble the reader only', (
    tester,
  ) async {
    final env = ScopeEnvironment({'logo_offset': -70});
    addTearDown(env.dispose);
    final d = _compile({
      '_type': 'stack',
      '_children': [_fixture('t4_home_logo.json')],
    });
    final counts = _observe();
    await tester.pumpWidget(_app(NodeBuilder.build(d), env));
    counts.clear();

    for (var i = 0; i < 30; i++) {
      env.set('logo_offset', i);
      await tester.pump();
    }

    expect(_total(counts), 30, reason: '$counts');
    expect(counts.keys.single, endsWith(':positioned'));
    expect(find.text('은 무제한'), findsOneWidget);
  });

  testWidgets('home app bar: only the logo reader assembles', (tester) async {
    ImageSourceRegistry.install(_Images());
    addTearDown(ImageSourceRegistry.reset);
    final counts = _observe();
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(800, 600),
            disableAnimations: true,
          ),
          child: NodeBuilder.build(_compile(_fixture('t4_home_app_bar.json'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final root = tester.state<ScopeState>(find.byType(Scope).first);
    counts.clear();

    for (var i = 0; i < 30; i++) {
      root.set('logo_offset', i);
      await tester.pump();
    }

    expect(_total(counts), 30, reason: '$counts');
    expect(counts.keys.single, endsWith(':positioned'));
  });

  testWidgets('a bound child keeps its own subscription under a bound parent', (
    tester,
  ) async {
    final env = ScopeEnvironment({'width': 100, 'label': 'old'});
    addTearDown(env.dispose);
    final d = _compile({
      '_type': 'sizedbox',
      'width': r'${width}',
      '_child': {'_type': 'text', 'value': r'${label}'},
    });
    final counts = _observe();
    await tester.pumpWidget(_app(NodeBuilder.build(d), env));
    counts.clear();

    env.set('width', 150);
    await tester.pump();
    expect(counts.keys.single, endsWith(':sizedbox'));

    counts.clear();
    env.set('label', 'new');
    await tester.pump();
    expect(find.text('new'), findsOneWidget);
    expect(counts.keys.single, endsWith(':text'));
  });

  testWidgets('parent constraints reach the child through layout vars', (
    tester,
  ) async {
    final env = ScopeEnvironment({'width': 100});
    addTearDown(env.dispose);
    final d = _compile({
      '_type': 'sizedbox',
      'width': r'${width}',
      'height': 50,
      '_child': {
        '_type': 'layout_builder',
        '_provides': ['max_width', 'max_height'],
        '_child': {'_type': 'text', 'value': r'${max_width}'},
      },
    });
    await tester.pumpWidget(_app(NodeBuilder.build(d), env));
    expect(find.text('100.0'), findsOneWidget);

    env.set('width', 200);
    await tester.pump();
    await tester.pump();
    expect(find.text('200.0'), findsOneWidget);
  });

  testWidgets('a parent prop restyles a static child without reassembling it', (
    tester,
  ) async {
    WidgetFactory.register(
      't4_style',
      EagerSpec(
        (context, props, children) => DefaultTextStyle(
          style: TextStyle(fontSize: (props['size'] as num).toDouble()),
          child: children.single,
        ),
      ),
    );
    addTearDown(WidgetFactory.reset);
    final env = ScopeEnvironment({'size': 12});
    addTearDown(env.dispose);
    final d = _compile({
      '_type': 't4_style',
      'size': r'${size}',
      '_child': {'_type': 'text', 'value': 'inherited'},
    });
    final counts = _observe();
    await tester.pumpWidget(_app(NodeBuilder.build(d), env));
    double? fontSize() =>
        (tester
                    .widget<RichText>(
                      find.descendant(
                        of: find.text('inherited'),
                        matching: find.byType(RichText),
                      ),
                    )
                    .text
                as TextSpan)
            .style
            ?.fontSize;
    expect(fontSize(), 12);
    counts.clear();

    env.set('size', 24);
    await tester.pump();
    expect(fontSize(), 24);
    expect(counts.keys.single, endsWith(':t4_style'));
  });

  testWidgets(
    'a replaced outer environment reaches a nested scope under an owner',
    (tester) async {
      final old = ScopeEnvironment({'width': 100, 'label': 'old'});
      final next = ScopeEnvironment({'width': 100, 'label': 'new'});
      addTearDown(old.dispose);
      addTearDown(next.dispose);
      // The same owner widget under both environments: only its dependency
      // on the environment, not a new configuration, rebuilds it.
      final tree = NodeBuilder.build(
        _compile({
          '_type': 'sizedbox',
          'width': r'${width}',
          '_child': {
            '_type': 'text',
            'value': r'${label}',
            '_scope': {
              '_state': {'local': 0},
            },
          },
        }),
      );
      await tester.pumpWidget(_app(tree, old));
      old.set('width', 120);
      await tester.pump();
      expect(find.text('old'), findsOneWidget);

      await tester.pumpWidget(_app(tree, next));
      expect(find.text('new'), findsOneWidget);

      next.set('label', 'updated');
      await tester.pump();
      expect(find.text('updated'), findsOneWidget);
    },
  );

  for (final kind in ['cond', 'switch']) {
    testWidgets('$kind: an unchanged branch is not reassembled; a swap is', (
      tester,
    ) async {
      final env = ScopeEnvironment({'pick': 1});
      addTearDown(env.dispose);
      final template = kind == 'cond'
          ? <String, Object?>{
              '_type': 'cond',
              '_children': [
                {'_type': 'text', 'value': 'yes', '_if': r'${pick > 0}'},
                {'_type': 'text', 'value': 'no', '_else': true},
              ],
              '_presence': false,
            }
          : <String, Object?>{
              '_type': 'switch',
              '_value': r'${pick > 0}',
              '_children': [
                {'_case': true, '_type': 'text', 'value': 'yes'},
                {'_default': true, '_type': 'text', 'value': 'no'},
              ],
              '_presence': false,
            };
      final counts = _observe();
      await tester.pumpWidget(_app(NodeBuilder.build(_compile(template)), env));
      expect(find.text('yes'), findsOneWidget);
      counts.clear();

      env.set('pick', 2);
      await tester.pump();
      expect(counts, isEmpty);

      env.set('pick', 0);
      await tester.pump();
      expect(find.text('no'), findsOneWidget);
    });
  }

  testWidgets('loop items keep separate scopes and show reordered payloads', (
    tester,
  ) async {
    final env = ScopeEnvironment({
      'items': [
        {'id': 'a', 'label': 'A'},
        {'id': 'b', 'label': 'B'},
      ],
    });
    addTearDown(env.dispose);
    final d = _compile({
      '_type': 'text',
      'value': r'${item.label}-${index}',
      '_loop': {'_in': r'${items}', '_as': 'item', '_key': r'${item.id}'},
    });
    await tester.pumpWidget(_app(NodeBuilder.build(d), env));
    expect(find.text('A-0'), findsOneWidget);
    expect(find.text('B-1'), findsOneWidget);

    env.set('items', [
      {'id': 'b', 'label': 'BB'},
      {'id': 'a', 'label': 'AA'},
    ]);
    await tester.pump();
    await tester.pump();
    expect(find.text('BB-0'), findsOneWidget);
    expect(find.text('AA-1'), findsOneWidget);
  });

  testWidgets('recompile, reassemble and remount show current content', (
    tester,
  ) async {
    final env = ScopeEnvironment({'label': 'A'});
    addTearDown(env.dispose);
    final d = _compile({'_type': 'text', 'value': r'${label}'});
    await tester.pumpWidget(_app(NodeBuilder.build(d), env));
    final reload = tester.binding.reassembleApplication();
    await tester.pump();
    await reload;
    env.set('label', 'B');
    await tester.pump();
    expect(find.text('B'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app(NodeBuilder.build(d), env));
    env.set('label', 'C');
    await tester.pump();
    expect(find.text('C'), findsOneWidget);

    final next = _compile({'_type': 'text', 'value': r'new ${label}'});
    await tester.pumpWidget(_app(NodeBuilder.build(next), env));
    expect(find.text('new C'), findsOneWidget);
  });

  testWidgets('300 commits beside 100 static siblings assemble 300 nodes', (
    tester,
  ) async {
    final env = ScopeEnvironment({'pad': 0});
    addTearDown(env.dispose);
    final d = _compile({
      '_type': 'padding',
      'padding': r'${pad}',
      '_child': {
        '_type': 'column',
        'main_axis_size': 'min',
        '_children': [
          for (var i = 0; i < 100; i++)
            {
              '_type': 'sizedbox',
              'height': 1,
              '_child': {
                '_type': 'text',
                'value': '$i',
                'style': {'font_size': 1},
              },
            },
        ],
      },
    });
    final counts = _observe();
    await tester.pumpWidget(_app(NodeBuilder.build(d), env));
    counts.clear();

    for (var i = 0; i < 300; i++) {
      env.set('pad', (i + 1) % 2);
      await tester.pump();
    }

    expect(_total(counts), 300);
  });

  group('re-entry while exiting', () {
    testWidgets('a cond branch shows a value changed during its exit', (
      tester,
    ) async {
      final env = ScopeEnvironment({'show': true, 'label': 'A'});
      addTearDown(env.dispose);
      await tester.pumpWidget(
        _host(
          env,
          NodeBuilder.build(
            _compile({
              '_type': 'column',
              '_children': [
                {'_type': 'text', 'value': r'${label}', '_if': r'${show}'},
              ],
            }),
          ),
        ),
      );
      env.set('show', false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      env.set('label', 'B');
      await tester.pump();
      expect(find.text('A'), findsOneWidget);

      env.set('show', true);
      await tester.pump();
      expect(find.text('B'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('a loop item shows a value changed during its exit', (
      tester,
    ) async {
      final env = ScopeEnvironment({
        'items': [
          {'id': 'a'},
          {'id': 'b'},
        ],
        'label': 'A',
      });
      addTearDown(env.dispose);
      await tester.pumpWidget(
        _host(
          env,
          NodeBuilder.build(
            _compile({
              '_type': 'text',
              'value': r'${it.id}-${label}',
              '_loop': {'_in': r'${items}', '_as': 'it', '_key': r'${it.id}'},
            }),
          ),
        ),
      );
      env.set('items', [
        {'id': 'b'},
      ]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      env.set('label', 'B');
      await tester.pump();
      expect(find.text('a-A'), findsOneWidget);
      expect(find.text('b-B'), findsOneWidget);

      env.set('items', [
        {'id': 'a'},
        {'id': 'b'},
      ]);
      await tester.pump();
      expect(find.text('a-B'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('a-B'), findsOneWidget);
      expect(find.text('b-B'), findsOneWidget);
    });
  });
}

class _Images extends ImageSource {
  @override
  ImageResult resolve(ImageRequest request) => ReadyImage(
    SizedBox(width: request.width ?? 24, height: request.height ?? 24),
  );
}
