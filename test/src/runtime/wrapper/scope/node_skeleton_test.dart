import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
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
}
