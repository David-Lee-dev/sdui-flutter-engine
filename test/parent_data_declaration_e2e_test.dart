import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

import 'support/engine_harness.dart';

/// Every built-in parent-data declaration mounts: a parent that declares
/// `childParentData` lays out the kind it declares, and a pass-through
/// built-in hands its child's parent data to its parent.
const _text = {'_type': 'text', 'value': 'x'};

const _childOf = {
  ParentDataKind.flex: {'_type': 'expanded', '_child': _text},
  ParentDataKind.stack: {
    '_type': 'positioned',
    'left': 0,
    'top': 0,
    '_child': _text,
  },
};

const _widgetOf = {
  ParentDataKind.flex: Expanded,
  ParentDataKind.stack: Positioned,
};

/// The `_requires` feature a parent type needs to compile.
const _requires = {'anchored_overlay': 'anchored_overlay_v1'};

Map<String, Object?> _boxed(Map<String, Object?> parent) => {
  if (_requires[parent['_type']] case final feature?) '_requires': [feature],
  '_type': 'sizedbox',
  'width': 300,
  'height': 300,
  '_child': parent,
};

Future<void> _expectMounts(
  WidgetTester tester,
  Map<String, Object?> template,
  ParentDataKind kind,
) async {
  await pumpEngineTemplate(tester, _boxed(template));
  expect(tester.takeException(), isNull);
  expect(find.byType(_widgetOf[kind]!), findsOneWidget);
  expect(find.text('x'), findsOneWidget);
}

void main() {
  setUp(WidgetFactory.ensureRegistered);
  tearDown(WidgetFactory.reset);

  group('childParentData 를 선언한 내장 부모는 그 자식을 놓는다', () {
    WidgetFactory.ensureRegistered();
    final declared = {
      for (final type in WidgetFactory.types())
        if (WidgetFactory.schemaOf(type)!.childParentData case final kind
            when kind != ParentDataKind.none)
          type: kind,
    };
    WidgetFactory.reset();

    test('선언 목록', () {
      expect(declared, {
        'column': ParentDataKind.flex,
        'row': ParentDataKind.flex,
        'flex': ParentDataKind.flex,
        'serpentine_row': ParentDataKind.flex,
        'stack': ParentDataKind.stack,
        'anchored_overlay': ParentDataKind.stack,
      });
    });

    for (final MapEntry(key: type, value: kind) in declared.entries) {
      testWidgets('$type > ${_childOf[kind]!['_type']}', (tester) async {
        await _expectMounts(tester, {
          '_type': type,
          '_children': [_childOf[kind]!],
        }, kind);
      });
    }
  });

  group('자식을 넘기는 내장 위젯은 자식의 parent data 를 부모에게 준다', () {
    final passing = <String, Map<String, Object?>>{
      'container': {'_type': 'container'},
      'container(clip_behavior: none)': {
        '_type': 'container',
        'clip_behavior': 'none',
        'transform_alignment': 'center',
      },
      'visibility': {'_type': 'visibility'},
      'visibility(maintain_*: false)': {
        '_type': 'visibility',
        'maintain_state': false,
        'maintain_size': false,
      },
    };
    const parents = {
      ParentDataKind.flex: 'column',
      ParentDataKind.stack: 'stack',
    };
    for (final MapEntry(key: name, value: node) in passing.entries) {
      for (final MapEntry(key: kind, value: parent) in parents.entries) {
        testWidgets('$parent > $name > ${_childOf[kind]!['_type']}', (
          tester,
        ) async {
          await _expectMounts(tester, {
            '_type': parent,
            '_children': [
              {...node, '_child': _childOf[kind]!},
            ],
          }, kind);
        });
      }
    }
  });

  testWidgets('Flutter 의 IndexedStack 은 자식과의 사이에 위젯을 넣어 Positioned 를 못 놓는다', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: IndexedStack(
          children: [Positioned(left: 0, top: 0, child: SizedBox())],
        ),
      ),
    );
    expect(
      tester.takeException().toString(),
      contains('Incorrect use of ParentDataWidget'),
    );
  });
}
