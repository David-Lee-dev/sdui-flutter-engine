import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/chart_widget.dart';

Future<void> _pump(WidgetTester tester, Map<String, Object?> props) =>
    tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: EngineMetrics(
          scale: 1.0,
          child: Builder(
            builder: (context) => ChartWidget.build(context, props, const []),
          ),
        ),
      ),
    );

/// The three rows every case plots unless it needs something else.
const _rows = [
  {'day': 1, 'amount': 100},
  {'day': 2, 'amount': 300},
  {'day': 3, 'amount': 200},
];

LineChartData _lineData(WidgetTester tester) =>
    tester.widget<LineChart>(find.byType(LineChart)).data;

BarChartData _barData(WidgetTester tester) =>
    tester.widget<BarChart>(find.byType(BarChart)).data;

void main() {
  group('ChartWidget', () {
    group('build', () {
      testWidgets('기본값은 area — 채움 그라디언트가 켜진다', (tester) async {
        await _pump(tester, {
          'data': _rows,
          'value_key': 'amount',
          'label_key': 'day',
        });

        final bar = _lineData(tester).lineBarsData.single;
        expect(bar.belowBarData.show, isTrue);
        expect(bar.belowBarData.gradient, isNotNull);
      });

      testWidgets('line 타입은 면적을 채우지 않는다', (tester) async {
        await _pump(tester, {
          'data': _rows,
          'value_key': 'amount',
          'type': 'line',
        });

        expect(
          _lineData(tester).lineBarsData.single.belowBarData.show,
          isFalse,
        );
      });

      testWidgets('bar 타입은 행마다 막대 하나를 만든다', (tester) async {
        await _pump(tester, {
          'data': _rows,
          'value_key': 'amount',
          'type': 'bar',
        });

        expect(_barData(tester).barGroups, hasLength(3));
      });

      testWidgets('value_key로 y값을 읽는다', (tester) async {
        await _pump(tester, {'data': _rows, 'value_key': 'amount'});

        expect(_lineData(tester).lineBarsData.single.spots.map((s) => s.y), [
          100,
          300,
          200,
        ]);
      });

      testWidgets('맵이 아닌 행은 건너뛴다 — 한 줄 때문에 화면이 죽지 않는다', (tester) async {
        await _pump(tester, {
          'data': [
            {'day': 1, 'amount': 10},
            'garbage',
            {'day': 2, 'amount': 20},
          ],
          'value_key': 'amount',
        });

        expect(_lineData(tester).lineBarsData.single.spots, hasLength(2));
      });

      testWidgets('최고값 위로 여유를 둬 꼭짓점이 천장에 붙지 않는다', (tester) async {
        await _pump(tester, {'data': _rows, 'value_key': 'amount'});

        expect(_lineData(tester).maxY, closeTo(345, 0.001));
      });

      testWidgets('전부 0이어도 축이 무너지지 않는다', (tester) async {
        await _pump(tester, {
          'data': [
            {'day': 1, 'amount': 0},
            {'day': 2, 'amount': 0},
          ],
          'value_key': 'amount',
        });

        expect(_lineData(tester).maxY, greaterThan(0));
      });

      testWidgets('max_y를 주면 자동 계산을 덮는다', (tester) async {
        await _pump(tester, {
          'data': _rows,
          'value_key': 'amount',
          'max_y': 1000,
        });

        expect(_lineData(tester).maxY, 1000);
      });

      testWidgets('selected_label이 가리키는 지점에 수직선을 긋는다', (tester) async {
        await _pump(tester, {
          'data': _rows,
          'value_key': 'amount',
          'label_key': 'day',
          'selected_label': 2,
        });

        final lines = _lineData(tester).extraLinesData.verticalLines;
        expect(lines.single.x, 1);
      });

      testWidgets('라벨 타입이 달라도 문자열로 비교해 찾아낸다', (tester) async {
        await _pump(tester, {
          'data': _rows,
          'value_key': 'amount',
          'label_key': 'day',
          'selected_label': '3',
        });

        expect(_lineData(tester).extraLinesData.verticalLines.single.x, 2);
      });

      testWidgets('선택이 없으면 수직선도 없다', (tester) async {
        await _pump(tester, {'data': _rows, 'value_key': 'amount'});

        expect(_lineData(tester).extraLinesData.verticalLines, isEmpty);
      });

      testWidgets('행이 열 개를 넘으면 x라벨 간격을 벌린다', (tester) async {
        await _pump(tester, {
          'data': [
            for (var day = 1; day <= 31; day++) {'day': day, 'amount': day},
          ],
          'value_key': 'amount',
          'label_key': 'day',
        });

        expect(
          _lineData(tester).titlesData.bottomTitles.sideTitles.interval,
          4,
        );
      });

      testWidgets('데이터가 비어도 그린다', (tester) async {
        await _pump(tester, {'data': const []});

        expect(find.byType(LineChart), findsOneWidget);
      });
    });
  });
}
