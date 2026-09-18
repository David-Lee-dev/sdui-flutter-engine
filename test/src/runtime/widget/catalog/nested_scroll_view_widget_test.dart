import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/nested_scroll_view_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: EngineMetrics(
        scale: 1.0,
        child: Builder(
          builder: (context) =>
              NestedScrollViewWidget.build(context, props, children),
        ),
      ),
    ),
  ),
);

void main() {
  group('NestedScrollViewWidget', () {
    group('build', () {
      testWidgets('마지막 자식은 body로, 앞 자식들은 헤더 슬리버로 간다', (tester) async {
        await _pump(
          tester,
          const {},
          children: [
            const SliverToBoxAdapter(child: Text('헤더')),
            const SliverPersistentHeader(
              pinned: true,
              delegate: _FixedDelegate(),
            ),
            const Text('본문'), // 마지막 = body(box)
          ],
        );
        expect(find.byType(NestedScrollView), findsOneWidget);
        expect(find.text('헤더'), findsOneWidget);
        expect(find.text('본문'), findsOneWidget);
      });

      testWidgets('자식이 body 하나뿐이면 헤더는 비고 그게 body', (tester) async {
        await _pump(tester, const {}, children: [const Text('본문만')]);
        expect(find.byType(NestedScrollView), findsOneWidget);
        expect(find.text('본문만'), findsOneWidget);
      });

      testWidgets('floatHeaderSlivers를 전달한다', (tester) async {
        await _pump(
          tester,
          const {'float_header_slivers': true},
          children: [const Text('본문')],
        );
        expect(
          tester
              .widget<NestedScrollView>(find.byType(NestedScrollView))
              .floatHeaderSlivers,
          isTrue,
        );
      });
    });
  });
}

/// 테스트용 고정 높이 헤더 델리게이트.
class _FixedDelegate extends SliverPersistentHeaderDelegate {
  const _FixedDelegate();

  @override
  double get minExtent => 40;

  @override
  double get maxExtent => 40;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      const SizedBox.expand(child: Text('탭바'));

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
