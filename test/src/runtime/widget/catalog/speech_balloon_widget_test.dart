import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/speech_balloon_widget.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: 1.0,
      child: Builder(
        builder: (context) =>
            SpeechBalloonWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('SpeechBalloonWidget', () {
    group('build', () {
      testWidgets('renders the provided child in a CustomPaint', (
        tester,
      ) async {
        await _pump(tester, const {}, children: [const Text('hi')]);

        expect(find.text('hi'), findsOneWidget);
        expect(find.byType(CustomPaint), findsOneWidget);
      });

      testWidgets('falls back to the text prop', (tester) async {
        await _pump(tester, const {'text': 'hello'});

        expect(find.text('hello'), findsOneWidget);
      });

      testWidgets('builds top and default bottom nip positions', (
        tester,
      ) async {
        await _pump(tester, const {'nip_position': 'top', 'text': 'top'});
        expect(tester.takeException(), isNull);

        await _pump(tester, const {'text': 'bottom'});
        expect(tester.takeException(), isNull);
      });

      testWidgets('builds a gradient fill and border', (tester) async {
        await _pump(tester, const {
          'text': 'styled',
          'decoration': {
            'gradient': {
              'colors': ['#FF0000', '#0000FF'],
            },
            'border': {'color': '#000000', 'width': 2},
            'border_radius': 12,
          },
        });

        expect(find.byType(CustomPaint), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
