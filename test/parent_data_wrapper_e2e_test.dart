import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/wrapper/interaction.dart';
import 'package:sdui_engine/src/runtime/wrapper/motion.dart';

import 'support/engine_harness.dart';

/// `_motion` / `_on` on nodes whose widget is a ParentDataWidget (0.9.0): the
/// wrappers go inside the parent-data widget, around its child.
Map<String, Object?> _counter(Map<String, Object?> container) => {
  '_type': 'column',
  '_scope': {
    '_state': {'n': 0},
    '_action': {
      'inc': {'_type': 'set', 'n': r'${n + 1}'},
    },
  },
  '_children': [container],
};

Map<String, Object?> _node(
  String type, [
  Map<String, Object?> extra = const {},
]) => {
  '_type': type,
  ...extra,
  '_motion': 'fade_in',
  '_on': {'tap': 'inc'},
  '_child': {'_type': 'text', 'value': r'n=${n}'},
};

Map<String, Object?> _inStack(Map<String, Object?> node) => {
  '_type': 'sizedbox',
  'width': 200,
  'height': 200,
  '_child': {
    '_type': 'stack',
    '_children': [node],
  },
};

Map<String, Object?> _inRow(Map<String, Object?> node) => {
  '_type': 'sizedbox',
  'width': 300,
  'height': 50,
  '_child': {
    '_type': 'row',
    '_children': [
      node,
      {'_type': 'sizedbox', 'width': 100},
    ],
  },
};

/// The nearest [type] above the node's motion layer: the node's own widget.
Finder _nodeOf(Type type) => find
    .ancestor(of: find.byType(MotionWrapper), matching: find.byType(type))
    .first;

Finder _wrapperBelow(Type parentData, Type wrapper) =>
    find.descendant(of: _nodeOf(parentData), matching: find.byType(wrapper));

Future<void> _expectTapCounts(WidgetTester tester) async {
  expect(find.text('n=0'), findsOneWidget);
  await tester.tap(find.text('n=0'));
  await tester.pump();
  expect(find.text('n=1'), findsOneWidget);
}

void main() {
  testWidgets('특성화: 일반 노드는 key > interaction > motion > 위젯 순서 그대로', (
    tester,
  ) async {
    await pumpEngineTemplate(
      tester,
      _counter({
        '_type': 'padding',
        '_key': 'k',
        'padding': 4,
        '_motion': 'fade_in',
        '_on': {'tap': 'inc'},
        '_child': {'_type': 'text', 'value': r'n=${n}'},
      }),
    );
    await tester.pumpAndSettle();
    final keyed = find.byKey(const ValueKey('k'));
    final interaction = find.descendant(
      of: keyed,
      matching: find.byType(InteractionWrapper),
    );
    expect(interaction, findsOneWidget);
    final motion = find.descendant(
      of: interaction,
      matching: find.byType(MotionWrapper),
    );
    expect(motion, findsOneWidget);
    expect(
      find.descendant(of: motion, matching: find.byType(Padding)),
      findsWidgets,
    );
    await _expectTapCounts(tester);
  });

  testWidgets('positioned: 모션·탭이 동작하고 위치를 지킨다', (tester) async {
    await pumpEngineTemplate(
      tester,
      _counter(_inStack(_node('positioned', {'left': 10, 'top': 20}))),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(_wrapperBelow(Positioned, MotionWrapper), findsOneWidget);
    expect(_wrapperBelow(Positioned, InteractionWrapper), findsOneWidget);
    final positioned = tester.widget<Positioned>(_nodeOf(Positioned));
    final stack = tester.getTopLeft(_nodeOf(Stack));
    final text = tester.getTopLeft(find.text('n=0'));
    expect(text - stack, Offset(positioned.left!, positioned.top!));
    await _expectTapCounts(tester);
  });

  testWidgets('positioned_fill: 모션·탭이 동작하고 채운다', (tester) async {
    await pumpEngineTemplate(
      tester,
      _counter(_inStack(_node('positioned_fill'))),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(_wrapperBelow(Positioned, MotionWrapper), findsOneWidget);
    expect(
      tester.getSize(find.byType(InteractionWrapper)),
      tester.getSize(_nodeOf(Stack)),
    );
    await _expectTapCounts(tester);
  });

  testWidgets('expanded: 모션·탭이 동작하고 flex를 지킨다', (tester) async {
    await pumpEngineTemplate(
      tester,
      _counter(_inRow(_node('expanded', {'flex': 2}))),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(_wrapperBelow(Expanded, MotionWrapper), findsOneWidget);
    expect(tester.widget<Expanded>(_nodeOf(Expanded)).flex, 2);
    expect(
      tester.getSize(find.byType(InteractionWrapper)).width,
      tester.getSize(_nodeOf(Row)).width - 100,
    );
    await _expectTapCounts(tester);
  });

  testWidgets('flexible: 모션·탭이 동작하고 flex·fit을 지킨다', (tester) async {
    await pumpEngineTemplate(
      tester,
      _counter(_inRow(_node('flexible', {'flex': 3, 'fit': 'tight'}))),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(_wrapperBelow(Flexible, MotionWrapper), findsOneWidget);
    final flexible = tester.widget<Flexible>(_nodeOf(Flexible));
    expect([flexible.flex, flexible.fit], [3, FlexFit.tight]);
    await _expectTapCounts(tester);
  });

  testWidgets('spacer의 모션도 flex 공간을 지킨다', (tester) async {
    await pumpEngineTemplate(
      tester,
      _inRow({'_type': 'spacer', 'flex': 1, '_motion': 'fade_in'}),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(_wrapperBelow(Expanded, MotionWrapper), findsOneWidget);
    expect(
      tester.getSize(_wrapperBelow(Expanded, MotionWrapper)).width,
      tester.getSize(_nodeOf(Row)).width - 100,
    );
  });

  testWidgets('반복 모션만 있는 expanded도 parent data를 지킨다', (tester) async {
    await pumpEngineTemplate(
      tester,
      _inRow({
        '_type': 'expanded',
        '_motion': 'pulse',
        '_child': {'_type': 'text', 'value': 'x'},
      }),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    expect(_wrapperBelow(Expanded, MotionWrapper), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
