import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';

/// anchor(위젯) ↔ scroll(드라이버) end-to-end — **마운트-스코프 레지스트리 배선** 검증.
///
/// 위젯(`anchor`)은 build 때 context로 [EngineRunner]가 내린 레지스트리에 등록하고, 드라이버(`scroll`,
/// pre-seed builtin·주입 없음)는 `DriverContext.registries`로 그 **같은** 레지스트리를 받아 조작한다.
/// 배선(EngineRunner→EngineRegistryScope→ScopeState→ActionHost→DriverContext→scroll)이 한 군데라도
/// 끊기면 `ctx.registries`가 null이라 스크롤이 무동작해 이 테스트가 실패한다.
void main() {
  testWidgets('탭→scroll 액션이 마운트 레지스트리의 anchor로 실제 스크롤한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EngineRunner(
            template: {
              '_type': 'column',
              '_scope': {
                '_action': {
                  'go_bottom': {
                    '_type': 'scroll',
                    'anchor': 'bottom',
                    'duration': 0,
                  },
                },
              },
              '_children': [
                {
                  '_type': 'container',
                  'height': 40,
                  '_on': {'tap': 'go_bottom'},
                  '_child': {'_type': 'text', 'value': 'go'},
                },
                {
                  '_type': 'expanded',
                  '_child': {
                    '_type': 'single_child_scroll_view',
                    '_child': {
                      '_type': 'column',
                      '_children': [
                        {'_type': 'sizedbox', 'height': 2000},
                        {
                          '_type': 'anchor',
                          'id': 'bottom',
                          '_child': {'_type': 'text', 'value': '타깃'},
                        },
                      ],
                    },
                  },
                },
              ],
            },
          ),
        ),
      ),
    );

    // 처음엔 '타깃'이 뷰포트 한참 아래(2000px 밑).
    final before = tester.getTopLeft(find.text('타깃')).dy;

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    // scroll 드라이버가 마운트 레지스트리에서 anchor를 찾아 ensureVisible → 타깃이 위로 올라온다.
    final after = tester.getTopLeft(find.text('타깃')).dy;
    expect(after, lessThan(before));
  });
}
