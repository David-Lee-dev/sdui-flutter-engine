import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/widget/swipe/swipe_controller_scope.dart';
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

/// Fails its unmount, so Flutter abandons the rest of that frame's unmounts:
/// the subtrees it leaves behind stay deactivated, never disposed.
class _FailsUnmount extends StatefulWidget {
  const _FailsUnmount();

  @override
  State<_FailsUnmount> createState() => _FailsUnmountState();
}

class _FailsUnmountState extends State<_FailsUnmount> {
  @override
  void dispose() {
    super.dispose();
    throw StateError('unmount failed');
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

enum _Bones { node, legacy, loop }

const _bone = {'_type': 'skeleton', 'width': 80, 'height': 20};

/// The home banners in small: a section scope loads the items through the
/// gate and an autoplaying, looping swipe shows them behind [bones].
Widget _section(_Bones bones) {
  final swipe = {
    '_type': 'text',
    'value': r'${item}',
    '_loop': {
      '_in': r'${items}',
      '_as': 'item',
      '_index': 'i',
      '_key': r'${i}',
      '_wrap': {'_type': 'swipe', 'autoplay_interval': 500, 'loop': true},
    },
    if (bones == _Bones.loop)
      '_skeleton': {
        'count': 1,
        'tree': {
          '_type': 'expanded',
          '_child': {'_type': 'skeleton', 'radius': 16},
        },
      },
  };
  return NodeBuilder.build(
    TemplateCompiler.buildRoot(
      TemplateParser.buildUiTree({
        '_type': 'sizedbox',
        'width': 200,
        'height': 40,
        '_scope': {
          '_state': {'items': <Object?>[]},
          '_action': {
            'load': {
              '_type': 'gate',
              '_then': {
                '_type': 'set',
                'items': ['a', 'b', 'c'],
              },
            },
          },
          '_lifecycle': const [
            {'on': 'mount', 'action': 'load'},
          ],
          if (bones == _Bones.legacy) '_skeleton': _bone,
        },
        '_child': {
          '_type': 'row',
          if (bones == _Bones.node) '_skeleton': _bone,
          '_children': [
            {
              '_type': 'expanded',
              // Loop bones show only while the loop node is built.
              if (bones != _Bones.loop) '_if': r'${len(items) > 0}',
              '_child': {'_type': 'sizedbox', 'height': 40, '_child': swipe},
            },
          ],
        },
      }),
    ),
  );
}

Widget _app(Widget child) => MaterialApp(
  home: Align(alignment: Alignment.topLeft, child: child),
);

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

  /// Whether the bones are on stage and painted.
  bool bonesShown() =>
      find.byType(ShaderMask).evaluate().isNotEmpty &&
      find
          .byWidgetPredicate((w) => w is Opacity && w.opacity == 0)
          .evaluate()
          .isEmpty;

  for (final bones in _Bones.values) {
    for (final slow in [true, false]) {
      testWidgets('${bones.name} bones, ${slow ? 'slow' : 'fast'} load: the '
          'swipe autoplays after the swap and leaves no timer', (tester) async {
        await tester.pumpWidget(_app(_section(bones)));
        await tester.pump(Duration(milliseconds: slow ? 300 : 100));
        expect(bonesShown(), slow);

        openAll();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(ShaderMask), findsNothing);
        final swipe = tester.widget<SwipeControllerScope>(
          find.byType(SwipeControllerScope),
        );
        final index = swipe.controller.index;

        await tester.pump(const Duration(milliseconds: 500));
        expect(swipe.controller.index, (index + 1) % 3);
        expect(tester.takeException(), isNull);

        // A pending autoplay timer fails the test after this dispose.
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('a section stranded during the swap no longer autoplays', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(Column(children: [const _FailsUnmount(), _section(_Bones.node)])),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(bonesShown(), isTrue);
    openAll();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SkeletonScope), findsOneWidget); // mid-swap

    await tester.pumpWidget(_app(const SizedBox()));
    expect(tester.takeException(), isStateError);

    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('a route popped during the swap leaves no error or timer', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(navigatorKey: navigator, home: const SizedBox()),
    );
    unawaited(
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) =>
              Align(alignment: Alignment.topLeft, child: _section(_Bones.node)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(bonesShown(), isTrue);
    openAll();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    navigator.currentState!.pop();
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.byType(SwipeControllerScope), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
