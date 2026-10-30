import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/semantics_widget.dart';

const _key = ValueKey('host');

Widget _host(Map<String, Object?> props, {bool child = true}) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(
    child: SizedBox(
      key: _key,
      width: 100,
      height: 40,
      child: Builder(
        builder: (context) => SemanticsWidget.build(context, props, [
          if (child) const Text('Inner'),
        ]),
      ),
    ),
  ),
);

void main() {
  group('SemanticsWidget', () {
    testWidgets('label·button·selected를 자식에 붙인다', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host({'label': 'Home', 'button': true, 'selected': true}),
      );
      expect(
        tester.getSemantics(find.byType(Semantics).first),
        matchesSemantics(
          label: 'Home\nInner',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('hidden이면 자식까지 의미 트리에서 뺀다', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host({'label': 'Home', 'hidden': true}));
      expect(find.bySemanticsLabel(RegExp('Home|Inner')), findsNothing);
      expect(find.text('Inner'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('selected false는 선택 상태를 가진 채 선택되지 않음이다', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host({'label': 'Home', 'selected': false}));
      expect(
        tester.getSemantics(find.byType(Semantics).first),
        matchesSemantics(
          label: 'Home\nInner',
          hasSelectedState: true,
          isSelected: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('잘못된 값은 기본값(없음·false)으로 간다', (tester) async {
      final handle = tester.ensureSemantics();
      for (final props in <Map<String, Object?>>[
        {'label': 3, 'button': 'yes', 'selected': 1, 'hidden': 'x'},
        {'label': null, 'button': null},
        <String, Object?>{},
      ]) {
        await tester.pumpWidget(_host(props));
        expect(tester.takeException(), isNull, reason: '$props');
        expect(
          find.bySemanticsLabel('Inner'),
          findsOneWidget,
          reason: '$props',
        );
        final node = tester.getSemantics(find.text('Inner'));
        expect(node.flagsCollection.isButton, isFalse);
        expect(node.flagsCollection.isSelected, isNot(true));
      }
      handle.dispose();
    });

    testWidgets('자식이 없어도 예외 없이 label만 낸다', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host({'label': 'Alone'}, child: false));
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Alone'), findsOneWidget);
      handle.dispose();
    });
  });
}
