import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';

/// 리스트 제스처 위젯 end-to-end — refreshIndicator·dismissible·reorderable이 실제 제스처로
/// 상태를 변형하는지 검증한다(완전 동작의 증명). 셋 다 `$event` payload 없이 동작한다:
/// refresh=완료-대기 액션, dismissible/reorderable=loop source 직접 변형(bind key에 write-back).
Future<void> _pump(WidgetTester tester, Map<String, Object?> template) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: EngineRunner(template: template)),
      ),
    );

void main() {
  group('list gestures (end-to-end)', () {
    testWidgets(
      'standalone dismissible — 스와이프가 onDismissed 액션을 발화 (ActionSpec 경로)',
      (tester) async {
        // loop 밖 단독 dismissible — `NodeBuilder.assemble`의 ActionSpec 분기 + Scope.actionHost 주입을
        // 탄다(loop 경로는 LoopObserver가 자체 Dismissible를 빌드해 이 경로를 우회한다). dismiss 뒤엔
        // `_if`로 트리에서 빼야 Flutter "dismissed widget still in tree" assertion을 피한다.
        await _pump(tester, const {
          '_type': 'column',
          '_scope': {
            '_state': {'gone': false},
            '_action': {
              'remove': {'_type': 'set', 'gone': true},
            },
          },
          '_children': [
            {'_type': 'text', 'value': r'gone=${gone}'},
            {
              '_type': 'dismissible',
              '_if': r'${gone == false}',
              'key': 'card1',
              'on_dismissed': 'remove',
              '_child': {'_type': 'text', 'value': 'swipe me'},
            },
          ],
        });

        expect(find.text('gone=false'), findsOneWidget);
        expect(find.text('swipe me'), findsOneWidget);

        await tester.drag(find.text('swipe me'), const Offset(500, 0));
        await tester.pumpAndSettle();

        expect(find.text('gone=true'), findsOneWidget);
        expect(find.text('swipe me'), findsNothing); // 액션이 상태를 바꿔 _if가 제거
      },
    );

    testWidgets('refreshIndicator — 당기면 액션이 발화되고 완료를 기다린다', (tester) async {
      await _pump(tester, const {
        '_type': 'column',
        '_scope': {
          '_state': {'count': 0},
          '_action': {
            'reload': {'_type': 'set', 'count': r'${count + 1}'},
          },
        },
        '_children': [
          {'_type': 'text', 'value': r'count=${count}'},
          {
            '_type': 'expanded',
            '_child': {
              '_type': 'refresh_indicator',
              'on_refresh': 'reload',
              '_child': {
                '_type': 'list_view',
                '_children': [
                  {'_type': 'container', 'height': 800},
                ],
              },
            },
          },
        ],
      });

      expect(find.text('count=0'), findsOneWidget);

      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(find.text('count=1'), findsOneWidget); // 당김 → reload 발화
    });

    testWidgets('dismissible — 스와이프하면 항목이 source에서 제거된다', (tester) async {
      await _pump(tester, const {
        '_type': 'column',
        '_scope': {
          '_state': {
            'items': [
              {'id': 'a', 'label': 'A'},
              {'id': 'b', 'label': 'B'},
              {'id': 'c', 'label': 'C'},
            ],
          },
        },
        '_children': [
          {
            '_type': 'expanded',
            '_child': {
              '_type': 'container',
              'height': 60,
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it.id}',
                '_wrap': {'_type': 'dismissible', 'bind': 'items'},
              },
              '_child': {'_type': 'text', 'value': r'${it.label}'},
            },
          },
        ],
      });

      expect(find.text('B'), findsOneWidget);

      await tester.drag(find.text('B'), const Offset(600, 0));
      await tester.pumpAndSettle();

      expect(find.text('B'), findsNothing); // 제거됨
      expect(find.text('A'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets(r'dismissible — bind 없이 맨몸 소스($items)면 그 root로 추론해 제거한다', (
      tester,
    ) async {
      // write-back 대상 추론(_sourceKey→Expression.bareBindingKey): 소스가 맨몸 `$items`면 명시 bind
      // 없이도 items에 되쓴다. `$feed.items` 같은 프로퍼티 소스라면 대상이 null이라 무동작(상태 뭉갬
      // 방지) — 그 판정은 expression_test bareBindingKey가 단위로 지킨다.
      await _pump(tester, const {
        '_type': 'column',
        '_scope': {
          '_state': {
            'items': [
              {'id': 'a', 'label': 'A'},
              {'id': 'b', 'label': 'B'},
            ],
          },
        },
        '_children': [
          {
            '_type': 'expanded',
            '_child': {
              '_type': 'container',
              'height': 60,
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it.id}',
                '_wrap': {'_type': 'dismissible'}, // bind 없음 → 맨몸 소스로 추론
              },
              '_child': {'_type': 'text', 'value': r'${it.label}'},
            },
          },
        ],
      });

      expect(find.text('A'), findsOneWidget);

      await tester.drag(find.text('A'), const Offset(600, 0));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsNothing); // 추론된 items에 write-back → 제거 유지
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('reorderable — 드래그하면 source 순서가 바뀐다', (tester) async {
      await _pump(tester, const {
        '_type': 'column',
        '_scope': {
          '_state': {
            'items': [
              {'id': 'a', 'label': 'A'},
              {'id': 'b', 'label': 'B'},
              {'id': 'c', 'label': 'C'},
            ],
          },
        },
        '_children': [
          {'_type': 'text', 'value': r'first=${items[0].id}'},
          {
            '_type': 'expanded',
            '_child': {
              '_type': 'container',
              'height': 80,
              '_loop': {
                '_in': r'${items}',
                '_as': 'it',
                '_key': r'${it.id}',
                '_wrap': {'_type': 'reorderable', 'bind': 'items'},
              },
              '_child': {'_type': 'text', 'value': r'${it.label}'},
            },
          },
        ],
      });

      expect(find.text('first=a'), findsOneWidget);

      // A를 아래로 리오더 — 하나의 연속 제스처로: 길게 눌러(드래그 시작) → 이동 → 놓음.
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('A')),
      );
      await tester.pump(const Duration(milliseconds: 600)); // long-press 지연
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 120));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('first=a'), findsNothing); // 첫 항목이 더는 a가 아님
    });

    testWidgets(
      r'reorderable — 중첩 소스($feed.items)는 write-back 거부로 feed를 뭉개지 않는다 (§0.2 회귀)',
      (tester) async {
        // 옛 로직(roots.length==1)은 `$feed.items`의 root가 하나(feed)라 reorder 결과를 state 키
        // 'feed'에 써넣어, 맵 {title,items}를 리스트로 덮어 title·중첩을 소멸시켰다. bareBindingKey는
        // 맨몸이 아니면 null → write-back 무동작 → feed 보존. (fix 없으면 title이 사라져 RED.)
        await _pump(tester, const {
          '_type': 'column',
          '_scope': {
            '_state': {
              'feed': {
                'title': 'MyFeed',
                'items': [
                  {'id': 'a', 'label': 'A'},
                  {'id': 'b', 'label': 'B'},
                  {'id': 'c', 'label': 'C'},
                ],
              },
            },
          },
          '_children': [
            {'_type': 'text', 'value': r'title=${feed.title}'},
            {
              '_type': 'expanded',
              '_child': {
                '_type': 'container',
                'height': 80,
                '_loop': {
                  '_in': r'${feed.items}',
                  '_as': 'it',
                  '_key': r'${it.id}',
                  '_wrap': {'_type': 'reorderable'}, // bind 없음 + 중첩 소스
                },
                '_child': {'_type': 'text', 'value': r'${it.label}'},
              },
            },
          ],
        });

        expect(find.text('title=MyFeed'), findsOneWidget);

        final gesture = await tester.startGesture(
          tester.getCenter(find.text('A')),
        );
        await tester.pump(const Duration(milliseconds: 600));
        await gesture.moveBy(const Offset(0, 40));
        await tester.pump();
        await gesture.moveBy(const Offset(0, 120));
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        expect(find.text('title=MyFeed'), findsOneWidget); // feed가 리스트로 안 뭉개짐
        expect(find.text('A'), findsOneWidget); // items도 살아 있음
      },
    );
  });
}
