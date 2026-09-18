import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/refresh_indicator_widget.dart';

void main() {
  group('RefreshIndicatorWidget', () {
    testWidgets('backgroundColor를 전달한다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EngineMetrics(
            scale: 1,
            child: Builder(
              builder: (context) => RefreshIndicatorWidget.build(
                context,
                const {'background_color': '#FF123456'},
                const [SingleChildScrollView(child: SizedBox(height: 1000))],
                null,
              ),
            ),
          ),
        ),
      );

      expect(
        tester
            .widget<RefreshIndicator>(find.byType(RefreshIndicator))
            .backgroundColor,
        const Color(0xFF123456),
      );
    });
  });
}
