import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';

void main() {
  group('MorphScope', () {
    testWidgets('from→to 값을 subtree에 발행하고 완료 뒤 목표값에 닿는다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EngineRunner(
              template: {
                '_type': 'text',
                '_morph': {
                  '_from': 0,
                  '_to': 100,
                  '_as': 'n',
                  '_duration': 100,
                  '_curve': 'linear',
                },
                'value': r'${int(n)}',
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 50));
      final midway = int.parse(tester.widget<Text>(find.byType(Text)).data!);
      expect(midway, inExclusiveRange(0, 100));
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('_curve가 없으면 easeOut을 쓴다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EngineRunner(
              template: {
                '_type': 'text',
                '_morph': {
                  '_from': 0,
                  '_to': 100,
                  '_as': 'n',
                  '_duration': 100,
                },
                'value': r'${int(n)}',
              },
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      final midway = int.parse(tester.widget<Text>(find.byType(Text)).data!);
      expect(midway, greaterThan(50));
      await tester.pumpAndSettle();
    });

    testWidgets('반응형 _to 변경 시 현재값에서 새 목표로 재전이한다', (tester) async {
      final score = ValueNotifier<int>(100);
      addTearDown(score.dispose);

      Widget tree() => MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: score,
            builder: (context, value, child) => EngineRunner(
              template: const {
                '_type': 'text',
                '_morph': {
                  '_from': 0,
                  '_to': r'${score}',
                  '_as': 'n',
                  '_duration': 100,
                  '_curve': 'linear',
                },
                'value': r'${int(n)}',
              },
              rootData: {'score': value},
            ),
          ),
        ),
      );

      await tester.pumpWidget(tree());
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);

      score.value = 200;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      final midway = int.parse(tester.widget<Text>(find.byType(Text)).data!);
      expect(midway, inExclusiveRange(100, 200));
      await tester.pumpAndSettle();
      expect(find.text('200'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
