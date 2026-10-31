import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/skeleton_scope.dart';

/// Holds every run open until the test completes its gate.
class _GateDriver extends Driver {
  _GateDriver(this.gates);

  final List<Completer<void>> gates;

  @override
  String get type => 'gate';

  @override
  Future<Object?> run(DriverContext ctx) {
    final gate = Completer<void>();
    gates.add(gate);
    return gate.future.then((_) => null);
  }
}

Widget _app(Map<String, Object?> template) => Directionality(
  textDirection: TextDirection.ltr,
  child: Align(
    alignment: Alignment.topLeft,
    child: NodeBuilder.build(
      TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template)),
    ),
  ),
);

/// A section scope that loads `ready` through the gate driver.
Map<String, Object?> _section(
  Map<String, Object?> child, {
  Map<String, Object?>? skeleton,
  List<Map<String, Object?>> lifecycle = const [
    {'on': 'mount', 'action': 'load'},
  ],
}) => {
  ...child,
  '_scope': {
    '_state': {'ready': false},
    '_action': {
      'load': {
        '_type': 'gate',
        '_then': {'_type': 'set', 'ready': true},
      },
    },
    '_lifecycle': lifecycle,
    '_skeleton': ?skeleton,
  },
};

const _content = {'_type': 'text', 'value': r'ready ${ready}'};

void main() {
  late List<Completer<void>> gates;

  setUp(() {
    gates = [];
    DriverRegistry.register(_GateDriver(gates));
  });

  tearDown(DriverRegistry.reset);

  void openAll() {
    for (final gate in gates) {
      if (!gate.isCompleted) gate.complete();
    }
  }

  group('characterization (0.16.1)', () {
    testWidgets('a scope without any skeleton dispatches mount through the '
        'deduped path and shows content at once', (tester) async {
      await tester.pumpWidget(
        _app(
          _section(
            _content,
            lifecycle: const [
              {'on': 'mount', 'action': 'load'},
              {'on': 'render', 'action': 'load'},
            ],
          ),
        ),
      );
      await tester.pump();

      // render fires while mount is in flight: deduped.
      expect(gates, hasLength(1));
      expect(find.text('ready false'), findsOneWidget);
      expect(find.byType(SkeletonScope), findsNothing);

      openAll();
      await tester.pump();
      await tester.pump();
      expect(find.text('ready true'), findsOneWidget);
    });

    testWidgets('a legacy _scope._skeleton awaits mount outside dedupe', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _section(
            _content,
            skeleton: const {'_type': 'text', 'value': 'bones'},
            lifecycle: const [
              {'on': 'mount', 'action': 'load'},
              {'on': 'render', 'action': 'load'},
            ],
          ),
        ),
      );
      await tester.pump();

      expect(gates, hasLength(2));
      openAll();
      await tester.pump();
    });

    testWidgets('a legacy skeleton shows after the grace and swaps to the '
        'content with an animation after a slow load', (tester) async {
      await tester.pumpWidget(
        _app(
          _section(
            _content,
            skeleton: const {'_type': 'skeleton', 'width': 80, 'height': 40},
          ),
        ),
      );
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(find.text('ready false'), findsNothing);

      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0),
        findsNothing,
      );

      openAll();
      await tester.pump();
      await tester.pump();
      // Both are on stage while the swap plays.
      expect(find.text('ready true'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ShaderMask), findsNothing);
      expect(find.text('ready true'), findsOneWidget);
    });
  });

  group('node _skeleton', () {
    const bone = {'_type': 'skeleton', 'width': 80, 'height': 20};

    Map<String, Object?> column(List<Map<String, Object?>> children) => {
      '_type': 'column',
      '_children': children,
    };

    Map<String, Object?> boned(Map<String, Object?> node) => {
      ...node,
      '_skeleton': bone,
    };

    /// Whether the bones are on stage and painted.
    bool bonesShown() =>
        find.byType(ShaderMask).evaluate().isNotEmpty &&
        find
            .byWidgetPredicate((w) => w is Opacity && w.opacity == 0)
            .evaluate()
            .isEmpty;

    Future<void> openAndSettle(WidgetTester tester) async {
      openAll();
      await tester.pump();
      await tester.pump();
    }

    testWidgets('a slow load holds the bones invisible, shows them after the '
        'grace and swaps to the content', (tester) async {
      await tester.pumpWidget(_app(_section(column([boned(_content)]))));

      expect(find.byType(SkeletonScope), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(bonesShown(), isFalse);
      expect(find.text('ready false'), findsNothing);

      await tester.pump(const Duration(milliseconds: 300));
      expect(bonesShown(), isTrue);

      await openAndSettle(tester);
      expect(find.text('ready true'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ShaderMask), findsNothing);
      expect(find.text('ready true'), findsOneWidget);
      expect(gates, hasLength(1));
    });

    testWidgets('a scope tracking node bones awaits mount outside dedupe', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _section(
            column([boned(_content)]),
            lifecycle: const [
              {'on': 'mount', 'action': 'load'},
              {'on': 'render', 'action': 'load'},
            ],
          ),
        ),
      );
      await tester.pump();
      expect(gates, hasLength(2));
      await openAndSettle(tester);
    });

    /// The layers painting at a partial opacity, as a crossfade does.
    List<OpacityLayer> partialOpacityLayers(WidgetTester tester) => [
      for (final layer in tester.layers)
        if (layer is OpacityLayer && layer.alpha! > 0 && layer.alpha! < 255)
          layer,
    ];

    /// Checks a swap from never-painted bones: the content fades in while
    /// the bones stay unpainted and the slot grows from the bone size to
    /// the content's.
    Future<void> expectFadeIn(WidgetTester tester) async {
      final slot = find.byType(SkeletonScope);
      await openAndSettle(tester);
      expect(find.text('ready true'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(bonesShown(), isFalse);
      await tester.pump(const Duration(milliseconds: 150));
      expect(partialOpacityLayers(tester), isNotEmpty);
      final mid = tester.getSize(slot);
      expect(mid.width, greaterThan(80));

      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ShaderMask), findsNothing);
      expect(partialOpacityLayers(tester), isEmpty);
      final end = tester.getSize(slot);
      expect(end, tester.getSize(find.text('ready true')));
      expect(mid.width, lessThan(end.width));
    }

    testWidgets('a load inside the grace fades the content in from the '
        'unpainted bones', (tester) async {
      await tester.pumpWidget(_app(_section(column([boned(_content)]))));
      await tester.pump(const Duration(milliseconds: 100));

      await expectFadeIn(tester);
    });

    testWidgets('a legacy _scope._skeleton load inside the grace fades the '
        'content in from the unpainted bones', (tester) async {
      await tester.pumpWidget(_app(_section(_content, skeleton: bone)));
      await tester.pump(const Duration(milliseconds: 100));

      await expectFadeIn(tester);
    });

    testWidgets('_presence: false shows a load inside the grace at once', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _section(
            column([
              {..._content, '_skeleton': bone, '_presence': false},
            ]),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await openAndSettle(tester);
      expect(find.text('ready true'), findsOneWidget);
      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('two mount hooks keep the bones until both settle', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _section(
            column([boned(_content)]),
            lifecycle: const [
              {'on': 'mount', 'action': 'load'},
              {'on': 'mount', 'action': 'load', 'delay': 500},
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await openAndSettle(tester);
      expect(bonesShown(), isTrue);

      await tester.pump(const Duration(milliseconds: 300));
      expect(gates, hasLength(2));
      expect(bonesShown(), isTrue);
      await openAndSettle(tester);
      expect(find.text('ready true'), findsOneWidget);
    });

    testWidgets('a failing mount action clears the bones', (tester) async {
      await tester.pumpWidget(
        _app({
          '_type': 'column',
          '_scope': {
            '_state': {'ready': false},
            '_action': {
              'load': {
                '_type': 'gate',
                '_error': {
                  '_': {'_type': 'set', 'ready': 'failed'},
                },
              },
            },
            '_lifecycle': const [
              {'on': 'mount', 'action': 'load'},
            ],
          },
          '_children': [boned(_content)],
        }),
      );
      await tester.pump(const Duration(milliseconds: 300));
      gates.single.completeError(StateError('offline'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('ready failed'), findsOneWidget);
      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('a hung load clears after 8 s with a warning, node and '
        'legacy alike', (tester) async {
      final lines = <String>[];
      EngineLog.configure(output: lines.add);
      addTearDown(() => EngineLog.configure(output: debugPrint));

      await tester.pumpWidget(
        _app(
          column([
            _section(column([boned(_content)])),
            _section(_content, skeleton: bone),
          ]),
        ),
      );
      await tester.pump(const Duration(milliseconds: 7900));
      expect(find.byType(ShaderMask), findsNWidgets(2));
      expect(find.text('ready false'), findsNothing);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ShaderMask), findsNothing);
      expect(find.text('ready false'), findsNWidgets(2));
      expect(lines.where((line) => line.contains('8 s')), hasLength(2));

      // A late response still lands in place.
      await openAndSettle(tester);
      expect(find.text('ready true'), findsNWidgets(2));
    });

    testWidgets('a remount after the load shows no bones', (tester) async {
      await tester.pumpWidget(
        _app(
          _section(
            column([boned(_content)]),
            lifecycle: const [
              {'on': 'mount', 'action': 'load'},
              {'on': 'remount', 'action': 'load'},
            ],
          ),
        ),
      );
      await openAndSettle(tester);
      await tester.pump(const Duration(seconds: 1));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(milliseconds: 400));
      expect(gates, hasLength(2));
      expect(find.byType(ShaderMask), findsNothing);
      expect(find.text('ready true'), findsOneWidget);
      await openAndSettle(tester);
    });

    testWidgets('a node first built after the load shows its content', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _section(
            column([
              {
                '_type': 'column',
                '_if': r'${ready}',
                '_children': [boned(_content)],
              },
            ]),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await openAndSettle(tester);

      expect(find.text('ready true'), findsOneWidget);
      expect(find.byType(SkeletonScope), findsNothing);
    });

    testWidgets('a nested scope with mount hooks gates its own bones', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _section(
            column([
              _section(column([boned(_content)])),
            ]),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(gates, hasLength(2));

      gates.first.complete();
      await tester.pump();
      await tester.pump();
      expect(bonesShown(), isTrue);

      await openAndSettle(tester);
      expect(find.text('ready true'), findsOneWidget);
    });

    testWidgets('a scope without mount hooks passes the loading through', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _section(
            column([
              {
                '_type': 'column',
                '_scope': {
                  '_state': {'local': 1},
                },
                '_children': [boned(_content)],
              },
            ]),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(bonesShown(), isTrue);
      await openAndSettle(tester);
      expect(find.text('ready true'), findsOneWidget);
    });

    testWidgets('a node without a loading scope shows its content', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(boned(const {'_type': 'text', 'value': 'static'})),
      );
      expect(find.text('static'), findsOneWidget);
      expect(find.byType(SkeletonScope), findsNothing);
    });

    testWidgets('bones of an _if node collapse when it is false after the '
        'load', (tester) async {
      await tester.pumpWidget(
        _app(
          _section(
            column([
              {..._content, '_if': r'${ready == "never"}', '_skeleton': bone},
            ]),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getSize(find.byType(SkeletonScope)).height, 20);

      await openAndSettle(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ShaderMask), findsNothing);
      expect(tester.getSize(find.byType(SkeletonScope)).height, 0);
    });

    testWidgets('_presence: false swaps the bones at once', (tester) async {
      await tester.pumpWidget(
        _app(
          _section(
            column([
              {..._content, '_skeleton': bone, '_presence': false},
            ]),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(bonesShown(), isTrue);

      await openAndSettle(tester);
      expect(find.text('ready true'), findsOneWidget);
      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('a loop shows its bone rows in its wrap until the load', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app({
          '_type': 'column',
          '_scope': {
            '_state': {'items': <Object?>[]},
            '_action': {
              'load': {
                '_type': 'gate',
                '_then': {
                  '_type': 'set',
                  'items': [
                    {'id': 1, 'name': 'one'},
                    {'id': 2, 'name': 'two'},
                  ],
                },
              },
            },
            '_lifecycle': const [
              {'on': 'mount', 'action': 'load'},
            ],
          },
          '_children': [
            {
              '_type': 'text',
              'value': r'${item.name}',
              '_loop': {
                '_in': r'${items}',
                '_as': 'item',
                '_key': r'${item.id}',
                '_wrap': {'_type': 'column', 'spacing': 4},
              },
              '_skeleton': {
                'count': 3,
                'tree': {'_type': 'text', 'value': 'bone'},
              },
            },
          ],
        }),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('bone'), findsNWidgets(3));

      await openAndSettle(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('bone'), findsNothing);
      expect(find.text('one'), findsOneWidget);
      expect(find.text('two'), findsOneWidget);
    });

    testWidgets('bones in one scope share one shimmer animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(_section(column([boned(_content), boned(_content)]))),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final animations = {
        for (final element in find.byType(ShaderMask).evaluate())
          (element.findAncestorWidgetOfExactType<AnimatedBuilder>()!.listenable)
              .hashCode,
      };
      expect(find.byType(ShaderMask), findsNWidgets(2));
      expect(animations, hasLength(1));
      await openAndSettle(tester);
    });

    testWidgets('an app-registered node shows its content with a warning', (
      tester,
    ) async {
      final lines = <String>[];
      EngineLog.configure(output: lines.add);
      addTearDown(() => EngineLog.configure(output: debugPrint));
      WidgetFactory.register(
        'app_probe',
        EagerSpec((context, props, children) => const Text('app')),
      );
      addTearDown(WidgetFactory.reset);

      await tester.pumpWidget(
        _app(
          _section(
            column([
              boned(const {'_type': 'app_probe'}),
            ]),
          ),
        ),
      );
      expect(find.text('app'), findsOneWidget);
      expect(find.byType(SkeletonScope), findsNothing);
      expect(lines.where((line) => line.contains('_skeleton')), isNotEmpty);
      await openAndSettle(tester);
    });

    testWidgets('nothing ticks after the load settles', (tester) async {
      await tester.pumpWidget(_app(_section(column([boned(_content)]))));
      await tester.pump(const Duration(milliseconds: 300));
      await openAndSettle(tester);
      await tester.pump(const Duration(seconds: 1));

      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('the shimmer does not run while no bones are on stage', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _section(
            column([
              const {'_type': 'text', 'value': 'static'},
              {
                '_type': 'column',
                '_if': r'${ready == "never"}',
                '_children': [boned(_content)],
              },
            ]),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SkeletonScope), findsNothing);
      expect(tester.binding.transientCallbackCount, 0);
      await openAndSettle(tester);
    });
  });

  group('parent-data outputs of presence slots', () {
    const leaf = {'_type': 'skeleton', 'width': 40, 'height': 20};
    const items = [
      {'index': 0},
      {'index': 1},
      {'index': 2},
    ];

    /// A [type] parent-data node around [child], shown when [when] holds.
    Map<String, Object?> slot(
      String type,
      Map<String, Object?> child, {
      String? when,
    }) => {
      '_type': type,
      if (type == 'positioned') ...{'left': 0, 'top': 0},
      '_if': ?when,
      '_child': child,
    };

    /// The flex or stack that gives [type] its parent data.
    Map<String, Object?> host(String type, List<Map<String, Object?>> kids) =>
        type == 'positioned'
        ? {
            '_type': 'sizedbox',
            'width': 200,
            'height': 40,
            '_child': {'_type': 'stack', '_children': kids},
          }
        : {'_type': 'row', '_children': kids};

    /// A section loading `ready` and `items` through the gate driver.
    Map<String, Object?> section(
      Map<String, Object?> child, {
      Map<String, Object?>? skeleton,
    }) => {
      '_type': 'column',
      '_scope': {
        '_state': {'ready': false, 'items': <Object?>[]},
        '_action': {
          'load': {
            '_type': 'gate',
            '_then': {'_type': 'set', 'ready': true, 'items': items},
          },
        },
        '_lifecycle': const [
          {'on': 'mount', 'action': 'load'},
        ],
        '_skeleton': ?skeleton,
      },
      '_children': [child],
    };

    /// Loads after the grace ([slow]) or inside it and plays the swap out.
    Future<void> load(
      WidgetTester tester,
      Map<String, Object?> template, {
      required bool slow,
    }) async {
      await tester.pumpWidget(_app(template));
      await tester.pump(Duration(milliseconds: slow ? 300 : 100));
      openAll();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(find.byType(ShaderMask), findsNothing);
      expect(tester.binding.transientCallbackCount, 0);
    }

    String speed(bool slow) => slow ? 'slow' : 'fast';

    for (final type in const ['expanded', 'flexible', 'positioned']) {
      for (final bones in const ['node', 'legacy']) {
        for (final slow in const [true, false]) {
          testWidgets('an _if $type under $bones bones swaps in after a '
              '${speed(slow)} load', (tester) async {
            final content = host(type, [
              leaf,
              slot(type, _content, when: r'${ready}'),
            ]);
            final tree = host(type, [leaf, slot(type, leaf)]);
            await load(
              tester,
              bones == 'node'
                  ? section({...content, '_skeleton': tree})
                  : section(content, skeleton: tree),
              slow: slow,
            );
            expect(find.text('ready true'), findsOneWidget);
          });

          testWidgets('a bare container with _if around a $type under '
              '$bones bones swaps in after a ${speed(slow)} load', (
            tester,
          ) async {
            final content = host(type, [
              leaf,
              {
                '_type': 'container',
                '_if': r'${ready}',
                '_child': slot(type, _content),
              },
            ]);
            final tree = host(type, [leaf, slot(type, leaf)]);
            await load(
              tester,
              bones == 'node'
                  ? section({...content, '_skeleton': tree})
                  : section(content, skeleton: tree),
              slow: slow,
            );
            expect(find.text('ready true'), findsOneWidget);
          });
        }
      }
    }

    for (final type in const ['expanded', 'flexible']) {
      for (final bones in const ['loop', 'legacy', 'no']) {
        for (final slow in const [true, false]) {
          testWidgets('loop items of a bare container around an _if $type '
              'under $bones bones enter after a ${speed(slow)} load', (
            tester,
          ) async {
            final row = {
              '_type': 'container',
              if (bones == 'loop')
                '_skeleton': {'count': 1, 'tree': slot(type, leaf)},
              '_loop': {
                '_in': r'${items}',
                '_as': 'item',
                '_key': r'${item.index}',
                '_wrap': {'_type': 'row', 'main_axis_size': 'max'},
              },
              '_child': slot(type, const {
                '_type': 'text',
                'value': r'item ${item.index}',
              }, when: r'${item.index > 0}'),
            };
            await load(
              tester,
              section(row, skeleton: bones == 'legacy' ? leaf : null),
              slow: slow,
            );
            expect(find.text('item 0'), findsNothing);
            expect(find.text('item 1'), findsOneWidget);
            expect(find.text('item 2'), findsOneWidget);
          });
        }
      }
    }
  });

  group('inert bones', () {
    Widget materialApp(Map<String, Object?> template) =>
        MaterialApp(home: Material(child: _app(template)));

    /// A scope whose bones hold a live toggle bound to `flag` and a label.
    Map<String, Object?> flagSection({required bool legacy}) {
      const tree = {
        '_type': 'column',
        '_children': [
          {'_type': 'toggle', 'bind': 'flag'},
          {'_type': 'text', 'value': 'bone label'},
        ],
      };
      return {
        '_type': 'column',
        '_scope': {
          '_state': {'ready': false, 'flag': false},
          '_action': {
            'load': {
              '_type': 'gate',
              '_then': {'_type': 'set', 'ready': true},
            },
          },
          '_lifecycle': const [
            {'on': 'mount', 'action': 'load'},
          ],
          if (legacy) '_skeleton': tree,
        },
        '_children': [
          {
            '_type': 'text',
            'value': r'flag ${flag}',
            if (!legacy) '_skeleton': tree,
          },
        ],
      };
    }

    for (final legacy in [false, true]) {
      final kind = legacy ? 'legacy' : 'node';

      for (final (phase, wait) in const [
        ('holding', Duration.zero),
        ('showing', Duration(milliseconds: 300)),
      ]) {
        testWidgets('a tap on $kind bones while $phase changes nothing', (
          tester,
        ) async {
          await tester.pumpWidget(materialApp(flagSection(legacy: legacy)));
          await tester.pump(wait);
          await tester.tap(find.byType(Switch), warnIfMissed: false);
          await tester.pump();

          openAll();
          await tester.pump();
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
          expect(find.text('flag false'), findsOneWidget);
        });
      }

      testWidgets('$kind bones add no semantics', (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(materialApp(flagSection(legacy: legacy)));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.bySemanticsLabel('bone label'), findsNothing);
        openAll();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        semantics.dispose();
      });
    }

    testWidgets('dismissing a bone row of a dismissible loop changes nothing', (
      tester,
    ) async {
      await tester.pumpWidget(
        materialApp({
          '_type': 'column',
          '_scope': {
            '_state': {
              'ready': false,
              'items': ['a', 'b'],
            },
            '_action': {
              'load': {
                '_type': 'gate',
                '_then': {'_type': 'set', 'ready': true},
              },
            },
            '_lifecycle': const [
              {'on': 'mount', 'action': 'load'},
            ],
          },
          '_children': [
            {
              '_type': 'text',
              'value': r'${item}',
              '_loop': {
                '_in': r'${items}',
                '_as': 'item',
                '_key': r'${item}',
                '_wrap': {
                  '_type': 'dismissible',
                  'bind': 'items',
                  'shrink_wrap': true,
                },
              },
              '_skeleton': true,
            },
          ],
        }),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Dismissible), findsNothing);
      await tester.fling(
        find.byType(SkeletonScope),
        const Offset(500, 0),
        1000,
        warnIfMissed: false,
      );
      await tester.pump(const Duration(seconds: 1));

      openAll();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
    });

    testWidgets('a legacy skeleton shows the content when its mount hook is '
        'replaced by a table without one', (tester) async {
      Map<String, Object?> section(List<Map<String, Object?>> lifecycle) =>
          _section(
            _content,
            skeleton: const {'_type': 'skeleton', 'width': 80, 'height': 40},
            lifecycle: lifecycle,
          );

      await tester.pumpWidget(
        _app(
          section(const [
            {'on': 'mount', 'action': 'load', 'delay': 200},
          ]),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(
        _app(
          section(const [
            {'on': 'render', 'action': 'load'},
          ]),
        ),
      );
      await tester.pump(const Duration(seconds: 9));
      expect(find.text('ready false'), findsOneWidget);
      expect(find.byType(ShaderMask), findsNothing);
      openAll();
      await tester.pump();
    });
  });
}
