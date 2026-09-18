import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/scaffold_widget.dart';

void main() {
  group('ScaffoldWidget', () {
    testWidgets('drawer 슬롯과 resize·FAB 위치 prop을 전달한다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EngineMetrics(
            scale: 1,
            child: Builder(
              builder: (context) => ScaffoldWidget.build(
                context,
                const {
                  'resize_to_avoid_bottom_inset': false,
                  'floating_action_button_location': 'center_float',
                },
                const {
                  'drawer': Text('서랍'),
                  'floating_action_button': Text('FAB'),
                },
              ),
            ),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isNotNull);
      expect(scaffold.resizeToAvoidBottomInset, isFalse);
      expect(
        scaffold.floatingActionButtonLocation,
        FloatingActionButtonLocation.centerFloat,
      );
    });

    testWidgets('body 슬롯을 항상 SafeArea로 감싼다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EngineMetrics(
            scale: 1,
            child: Builder(
              builder: (context) => ScaffoldWidget.build(
                context,
                const {},
                const {'body': Text('본문')},
              ),
            ),
          ),
        ),
      );

      final safeArea = tester.widget<SafeArea>(
        find.ancestor(of: find.text('본문'), matching: find.byType(SafeArea)),
      );
      // Scaffold가 앱바/하단바 유무에 맞춰 body의 상·하 padding을 이미 제거하므로,
      // 모든 엣지를 켜도 이중 여백 없이 노출된 엣지만 실제로 인셋된다.
      expect(safeArea.top, isTrue);
      expect(safeArea.bottom, isTrue);
    });

    testWidgets('extend_body·extend_body_behind_app_bar면 해당 엣지 인셋을 끈다', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EngineMetrics(
            scale: 1,
            child: Builder(
              builder: (context) => ScaffoldWidget.build(
                context,
                const {'extend_body': true, 'extend_body_behind_app_bar': true},
                const {'body': Text('본문')},
              ),
            ),
          ),
        ),
      );

      final safeArea = tester.widget<SafeArea>(
        find.ancestor(of: find.text('본문'), matching: find.byType(SafeArea)),
      );
      // 템플릿이 명시적으로 그 엣지 뒤로 body를 확장하려는 것이므로 인셋을 끈다.
      expect(safeArea.top, isFalse);
      expect(safeArea.bottom, isFalse);
    });
  });
}
