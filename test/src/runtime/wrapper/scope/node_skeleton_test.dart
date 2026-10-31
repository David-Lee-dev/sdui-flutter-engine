import 'dart:async';

import 'package:flutter/widgets.dart';
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

    testWidgets('a load inside the grace shows the content at once', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_section(column([boned(_content)]))));
      await tester.pump(const Duration(milliseconds: 100));

      await openAndSettle(tester);
      expect(find.text('ready true'), findsOneWidget);
      expect(find.byType(ShaderMask), findsNothing);
      expect(find.byType(FadeTransition), findsNothing);
    });

    testWidgets('a legacy _scope._skeleton load inside the grace shows the '
        'content at once', (tester) async {
      await tester.pumpWidget(_app(_section(_content, skeleton: bone)));
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
  });
}
