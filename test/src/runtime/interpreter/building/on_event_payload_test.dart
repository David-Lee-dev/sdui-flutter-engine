import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

/// A loop whose items each report their own value to an action declared above
/// them — the shape a tappable day strip or category chip row needs.
const _template = {
  '_type': 'column',
  '_scope': {
    '_state': {
      'picked': 0,
      'items': [
        {'day': 7},
        {'day': 8},
      ],
    },
    '_action': {
      'pick': {'_type': 'set', 'picked': r'${event}'},
    },
  },
  '_children': [
    {
      '_type': 'container',
      '_loop': {
        '_in': r'${items}',
        '_as': 'item',
        '_key': r'${item.day}',
        '_wrap': {'_type': 'row'},
      },
      '_on': {
        'tap': {'do': 'pick', 'event': r'${item.day}'},
      },
      '_child': {'_type': 'text', 'value': r'${item.day}'},
    },
    {'_type': 'text', 'value': r'picked=${picked}'},
  ],
};

void main() {
  testWidgets('_on 이 아이템 값을 조상 액션에 넘긴다', (tester) async {
    WidgetFactory.ensureRegistered();
    DriverRegistry.ensureRegistered();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: EngineMetrics(
          scale: 1.0,
          child: Center(
            child: SizedBox(
              width: 300,
              height: 200,
              child: NodeBuilder.build(
                TemplateCompiler.buildDirectiveTree(
                  TemplateParser.buildUiTree(_template),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('picked=0'), findsOneWidget);

    await tester.tap(find.text('8'));
    await tester.pump();

    expect(find.text('picked=8'), findsOneWidget);
  });
}
