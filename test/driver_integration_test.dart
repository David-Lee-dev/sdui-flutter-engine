import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/engine_host.dart';

import 'support/engine_harness.dart';

/// Phase 3 driver 통합 — `EngineRunner→ActionHost→driver` 전 배선을 실제 탭으로 건다.
///
/// 각 driver 단위 테스트는 `DriverContext`를 손으로 만들어 이 경로를 안 타므로, 마운트-스코프 채널
/// (전역 핸들·registries)이 실제 액션에서 driver까지 흘러가는지 못 잡는다. 여기서 그걸 계약으로 고정한다
/// (foreground 모달 회귀와 같은 종류의 통합 갭 방지).
void main() {
  group('driver 통합 (EngineRunner→ActionHost→driver)', () {
    testWidgets('navigate — 탭이 라우터 핸들을 route로 부른다', (tester) async {
      String? pushed;

      await pumpEngineTemplate(
        tester,
        const {
          '_type': 'container',
          '_scope': {
            '_action': {
              'go': {'_type': 'navigate', 'route': '/detail/42'},
            },
          },
          '_child': {
            '_type': 'text',
            '_on': {'tap': 'go'},
            'value': '열기',
          },
        },
        navigate: NavigateHandle(
          push: (location) async {
            pushed = location;
            return null;
          },
        ),
      );

      await tester.tap(find.text('열기'));
      await tester.pump();

      expect(pushed, '/detail/42');
    });

    testWidgets('toast — 탭이 토스트 핸들을 message/variant로 부른다', (tester) async {
      String? message;
      String? variant;

      await pumpEngineTemplate(
        tester,
        const {
          '_type': 'container',
          '_scope': {
            '_action': {
              'notify': {
                '_type': 'toast',
                'message': '완료',
                'variant': 'success',
              },
            },
          },
          '_child': {
            '_type': 'text',
            '_on': {'tap': 'notify'},
            'value': '알림',
          },
        },
        toast: ToastHandle((m, v) {
          message = m;
          variant = v;
        }),
      );

      await tester.tap(find.text('알림'));
      await tester.pump();

      expect(message, '완료');
      expect(variant, 'success');
    });

    testWidgets('scroll — 탭이 registries의 anchor로 스크롤한다 (마운트-스코프 채널 통합)', (
      tester,
    ) async {
      // registries 채널(EngineRunner→ScopeState→ActionHost→DriverContext)이 실제 액션에서 scroll
      // driver까지 흘러가는지 — modalTemplates와 같은 부류 채널이라 같은 종류의 lane 누락을 잡는다.
      await pumpEngineTemplate(tester, const {
        '_type': 'single_child_scroll_view',
        '_scope': {
          '_action': {
            'to_target': {'_type': 'scroll', 'anchor': 'target', 'duration': 0},
          },
        },
        '_child': {
          '_type': 'column',
          '_children': [
            {
              '_type': 'text',
              '_on': {'tap': 'to_target'},
              'value': '이동',
            },
            {'_type': 'sizedbox', 'height': 2000},
            {
              '_type': 'anchor',
              'id': 'target',
              '_child': {'_type': 'text', 'value': '도착'},
            },
          ],
        },
      });

      final position = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      expect(position.pixels, 0.0); // 처음엔 맨 위

      await tester.tap(find.text('이동'));
      await tester.pumpAndSettle();

      expect(position.pixels, greaterThan(0)); // 채널 왕복 → ensureVisible이 스크롤함
    });
  });
}
