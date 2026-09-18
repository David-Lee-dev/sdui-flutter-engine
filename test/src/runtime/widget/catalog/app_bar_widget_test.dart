import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/app_bar_widget.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props,
  Map<String, Widget> slots,
) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          height: 56,
          child: Builder(
            builder: (context) => AppBarWidget.build(context, props, slots),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  group('AppBarWidget', () {
    group('build', () {
      testWidgets('center_title=false면 title이 Expanded로 좌측을 채운다', (
        tester,
      ) async {
        await _pump(tester, const {}, const {
          'leading': Icon(Icons.arrow_back),
          'title': Text('제목'),
          'actions': Icon(Icons.search),
        });
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.text('제목'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
        expect(find.byType(Expanded), findsOneWidget);
      });

      testWidgets('title이 없어도 actions는 오른쪽으로 밀린다(Expanded 유지)', (tester) async {
        await _pump(tester, const {}, const {'actions': Icon(Icons.settings)});
        // 가운데 Expanded가 남은 폭을 먹어 actions를 오른쪽 끝으로 민다.
        expect(find.byType(Expanded), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
      });

      testWidgets('center_title=true면 title을 Stack으로 절대 중앙에 둔다', (
        tester,
      ) async {
        await _pump(
          tester,
          const {'center_title': true},
          const {
            'leading': Icon(Icons.arrow_back),
            'title': Text('제목'),
            'actions': Icon(Icons.search),
          },
        );
        expect(find.byType(Stack), findsWidgets);
        expect(
          find.ancestor(of: find.text('제목'), matching: find.byType(Stack)),
          findsWidgets,
        );
      });
    });
  });

  group('scaffold app_bar 슬롯', () {
    testWidgets('상태바 인셋 + 중앙 title + 넓은 actions를 device 폭에서 overflow 없이 렌더', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(top: 47);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: EngineRunner(
            template: {
              '_type': 'scaffold',
              '_slots': {
                'app_bar': {
                  '_type': 'app_bar',
                  'center_title': true,
                  '_slots': {
                    'leading': {'_type': 'icon', 'name': 'arrow_back'},
                    'title': {'_type': 'text', 'value': '개요'},
                    'actions': {
                      '_type': 'row',
                      'main_axis_size': 'min',
                      '_children': [
                        {'_type': 'icon', 'name': 'search'},
                        {'_type': 'sizedbox', 'width': 16},
                        {'_type': 'icon', 'name': 'settings'},
                      ],
                    },
                  },
                },
                // 본문은 슬라이버가 아닌 자유 위젯.
                'body': {'_type': 'text', 'value': '본문'},
              },
            },
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('개요'), findsOneWidget);
      expect(find.text('본문'), findsOneWidget);
    });
  });
}
