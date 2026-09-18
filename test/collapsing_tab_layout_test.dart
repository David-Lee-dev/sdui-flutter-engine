import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';

/// collapsing 탭 레이아웃 end-to-end — 접히는 헤더 + pinned 탭 헤더 + 탭별 독립 스크롤.
///
/// `defaultTabController > nestedScrollView > [sliverToBoxAdapter(헤더),
/// sliverPersistentHeader(pinned, tabBar), nestedBody(tabBarView[listView…])]` 조합을 실제
/// 엔진 파이프라인(parse→compile→interpret)으로 마운트해, 마커 검출·슬리버 배선·탭 컨트롤러
/// 공유가 실제로 이어지는지 확인한다(위젯 단위테스트만으론 이 배선이 끊겨도 통과할 수 있다).
Map<String, Object?> _listView(String label) => {
  '_type': 'list_view',
  '_children': [
    for (var i = 1; i <= 3; i++)
      {
        '_type': 'container',
        'height': 80,
        'padding': 12,
        '_child': {'_type': 'text', 'value': '$label 항목 $i'},
      },
  ],
};

final Map<String, Object?> _template = {
  '_type': 'default_tab_controller',
  'length': 2,
  '_child': {
    '_type': 'nested_scroll_view',
    '_children': [
      // ① 접히는 헤더 — 스크롤하면 위로 사라진다.
      {
        '_type': 'sliver_to_box_adapter',
        '_child': {
          '_type': 'container',
          'height': 120,
          'color': '#EEEEEE',
          '_child': {'_type': 'text', 'value': '프로필 헤더'},
        },
      },
      // ② pinned 탭 헤더 — 상단에 고정.
      {
        '_type': 'sliver_persistent_header',
        'pinned': true,
        'height': 48,
        '_child': {
          '_type': 'tab_bar',
          '_children': [
            {'_type': 'tab', 'text': '피드'},
            {'_type': 'tab', 'text': '정보'},
          ],
        },
      },
      // ③ body — 마지막 자식(위치 규약). 탭별 독립 스크롤(각 listView가 primary라 collapse 구동).
      {
        '_type': 'tab_bar_view',
        '_children': [_listView('피드'), _listView('정보')],
      },
    ],
  },
};

void main() {
  group('collapsing tab layout (end-to-end)', () {
    testWidgets('헤더·pinned 탭바·선택 탭 body가 한 파이프라인으로 렌더된다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EngineRunner(template: _template)),
        ),
      );

      // 배선 확인: NestedScrollView가 서고, 헤더 슬리버와 탭 헤더, 첫 탭 body가 보인다.
      expect(find.byType(NestedScrollView), findsOneWidget);
      expect(find.text('프로필 헤더'), findsOneWidget);
      expect(find.text('피드'), findsOneWidget); // 탭 라벨
      expect(find.text('정보'), findsOneWidget); // 탭 라벨
      expect(find.text('피드 항목 1'), findsOneWidget); // 선택된 탭(0) body
    });

    testWidgets('탭을 누르면 다른 탭 body로 전환된다(컨트롤러 공유)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EngineRunner(template: _template)),
        ),
      );

      await tester.tap(find.text('정보'));
      await tester.pumpAndSettle();

      expect(find.text('정보 항목 1'), findsOneWidget);
    });
  });
}
