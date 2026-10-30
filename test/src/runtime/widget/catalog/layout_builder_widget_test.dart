import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/layout_builder_widget.dart';

import '../../../../support/engine_harness.dart';

/// Records the vars each child build received.
final class _Probe {
  final calls = <Map<String, Object?>>[];

  Widget? build(int index, {Map<String, Object?> vars = const {}}) {
    calls.add(vars);
    return const SizedBox(width: 10, height: 10);
  }
}

Widget _host(
  _Probe probe, {
  double scale = 1.0,
  required Widget Function(Widget) wrap,
}) => Directionality(
  textDirection: TextDirection.ltr,
  child: EngineMetrics(
    scale: scale,
    child: Align(
      alignment: Alignment.topLeft,
      child: wrap(
        Builder(
          builder: (context) =>
              LayoutBuilderWidget.build(context, const {}, 1, probe.build),
        ),
      ),
    ),
  ),
);

void main() {
  group('LayoutBuilderWidget', () {
    for (final scale in [1.0, 1.2]) {
      testWidgets('max_width·max_height는 템플릿 단위(px / scale $scale)다', (
        tester,
      ) async {
        final probe = _Probe();
        await tester.pumpWidget(
          _host(
            probe,
            scale: scale,
            wrap: (child) => SizedBox(width: 240, height: 120, child: child),
          ),
        );
        expect(probe.calls.last['max_width'], closeTo(240 / scale, 1e-9));
        expect(probe.calls.last['max_height'], closeTo(120 / scale, 1e-9));
      });
    }

    testWidgets('무한 축은 null을 준다', (tester) async {
      final probe = _Probe();
      await tester.pumpWidget(
        _host(
          probe,
          wrap: (child) => SizedBox(
            height: 50,
            child: Row(
              children: [
                UnconstrainedBox(child: SizedBox(height: 50, child: child)),
              ],
            ),
          ),
        ),
      );
      expect(probe.calls.last['max_width'], isNull);
      expect(probe.calls.last['max_height'], closeTo(50, 1e-9));
      expect(tester.takeException(), isNull);
    });

    testWidgets('제약이 바뀌면 새 값으로 다시 빌드한다', (tester) async {
      final probe = _Probe();
      Widget sized(double w) => _host(
        probe,
        wrap: (child) => SizedBox(width: w, height: 10, child: child),
      );
      await tester.pumpWidget(sized(100));
      await tester.pumpWidget(sized(180));
      expect(probe.calls.last['max_width'], closeTo(180, 1e-9));
    });

    testWidgets('앱 쪽 IntrinsicHeight 안에서도 예외 없이 크기 0으로 답한다', (tester) async {
      final probe = _Probe();
      await tester.pumpWidget(
        _host(
          probe,
          wrap: (child) =>
              SizedBox(width: 200, child: IntrinsicHeight(child: child)),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(probe.calls.last['max_width'], closeTo(200, 1e-9));
    });

    testWidgets('엔진 템플릿에서 자식이 max_width를 바인딩한다', (tester) async {
      await pumpEngineTemplate(tester, {
        '_type': 'sizedbox',
        'width': 300,
        'height': 50,
        '_child': {
          '_type': 'layout_builder',
          '_provides': ['max_width', 'max_height'],
          '_child': {
            '_type': 'text',
            'value': r'${max_width > 100 ? "wide" : "narrow"}',
          },
        },
      });
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('wide'), findsOneWidget);
    });
  });
}
