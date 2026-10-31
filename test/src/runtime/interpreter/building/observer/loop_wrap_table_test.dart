import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/observer/loop_observer.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';

/// The wrap params a strategy needs to build at all.
const _params = <String, Map<String, Object?>>{
  'spin_grid': {'winner_index': 0},
  'grid': {'cross_axis_count': 2},
  'sliver_grid': {'cross_axis_count': 2},
};

/// A loop of two texts with [wrap], placed where its declared protocol fits.
Widget _loop(String wrap, LayoutProtocol produces) {
  final loop = NodeBuilder.build(
    TemplateCompiler.buildDirectiveTree(
      TemplateParser.buildUiTree({
        '_type': 'text',
        'value': r'${it}',
        '_loop': {
          '_in': r'${items}',
          '_as': 'it',
          '_key': r'${it}',
          '_wrap': {'_type': wrap, ...?_params[wrap]},
        },
      }),
    ),
  );
  // Material localizations and an overlay for `reorderable`'s
  // ReorderableListView.
  return Localizations(
    locale: const Locale('en'),
    delegates: const [
      DefaultMaterialLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
    ],
    child: MediaQuery(
      data: const MediaQueryData(),
      child: EngineMetrics(
        scale: 1.0,
        child: Scope.ofState(
          const {
            'items': ['a', 'b'],
          },
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (_) => Center(
                  child: SizedBox(
                    width: 400,
                    height: 200,
                    child: produces == LayoutProtocol.sliver
                        ? CustomScrollView(slivers: [loop])
                        : loop,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// The widget types between the item `a` and its loop.
List<Type> _itemAncestors(WidgetTester tester) {
  final types = <Type>[];
  tester.element(find.byKey(const ValueKey('a')).first).visitAncestorElements((
    element,
  ) {
    if (element.widget is LoopObserver) return false;
    types.add(element.widget.runtimeType);
    return true;
  });
  return types;
}

void main() {
  setUp(() {
    WidgetFactory.ensureRegistered();
    DriverRegistry.ensureRegistered();
  });

  test('the runtime dispatch handles exactly the table strategies', () {
    expect(LoopObserver.handledWraps, loopWraps.keys.toSet());
  });

  testWidgets(
    'every strategy builds the protocol and host the table declares',
    (tester) async {
      // The widget each declared host builds, read from the factory itself.
      late final Map<String, Type> hosts;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            hosts = {
              for (final widget
                  in loopWraps.values.map((w) => w.widget).nonNulls)
                widget: WidgetFactory.build(
                  context,
                  widget,
                  const {},
                  const [],
                ).runtimeType,
            };
            return const SizedBox();
          },
        ),
      );

      for (final MapEntry(key: name, value: wrap) in loopWraps.entries) {
        await tester.pumpWidget(_loop(name, wrap.produces));

        expect(tester.takeException(), isNull, reason: name);
        expect(
          tester.renderObject(find.byType(LoopObserver)),
          wrap.produces == LayoutProtocol.sliver
              ? isA<RenderSliver>()
              : isA<RenderBox>(),
          reason: '"$name" builds ${wrap.produces.name}',
        );
        final ancestors = _itemAncestors(tester);
        if (wrap.widget case final widget?) {
          expect(
            ancestors,
            contains(hosts[widget]),
            reason: '"$name" lays its items in "$widget"',
          );
        } else {
          expect(
            ancestors.toSet().intersection(hosts.values.toSet()),
            isEmpty,
            reason: '"$name" lays its items in a widget of its own',
          );
        }

        await tester.pumpWidget(const SizedBox());
      }
    },
  );
}
