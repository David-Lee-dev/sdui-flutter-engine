import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/sliver_persistent_header_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
  double scale = 1.0,
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: scale,
      child: CustomScrollView(
        slivers: [
          Builder(
            builder: (context) =>
                SliverPersistentHeaderWidget.build(context, props, children),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  group('SliverPersistentHeaderWidget', () {
    group('build', () {
      testWidgets('pinned와 고정 높이(height→min=max)를 반영(height scale)', (
        tester,
      ) async {
        await _pump(
          tester,
          const {'pinned': true, 'height': 80},
          children: [const Text('헤더')],
          scale: 0.5,
        );
        final header = tester.widget<SliverPersistentHeader>(
          find.byType(SliverPersistentHeader),
        );
        expect(header.pinned, isTrue);
        expect(header.delegate.minExtent, 40);
        expect(header.delegate.maxExtent, 40);
        expect(find.text('헤더'), findsOneWidget);
      });

      testWidgets('minExtent~maxExtent로 축소~확장 범위를 준다', (tester) async {
        await _pump(
          tester,
          const {'min_extent': 40, 'max_extent': 120},
          children: [const Text('헤더')],
        );
        final header = tester.widget<SliverPersistentHeader>(
          find.byType(SliverPersistentHeader),
        );
        expect(header.delegate.minExtent, 40);
        expect(header.delegate.maxExtent, 120);
      });
    });
  });
}
