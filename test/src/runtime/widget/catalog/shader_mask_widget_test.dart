import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/shader_mask_widget.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props,
  Widget child,
) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: 1.0,
      child: Builder(
        builder: (context) => ShaderMaskWidget.build(context, props, [child]),
      ),
    ),
  ),
);

void main() {
  group('ShaderMaskWidget', () {
    testWidgets('gradient wraps the child with srcIn by default', (
      tester,
    ) async {
      await _pump(tester, const {
        'gradient': {
          'colors': ['#f00', '#00f'],
        },
      }, const Text('child'));

      final mask = tester.widget<ShaderMask>(find.byType(ShaderMask));
      expect(mask.blendMode, BlendMode.srcIn);
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('blend_mode overrides the default', (tester) async {
      await _pump(tester, const {
        'gradient': {
          'colors': ['#f00', '#00f'],
        },
        'blend_mode': 'multiply',
      }, const Text('child'));

      expect(
        tester.widget<ShaderMask>(find.byType(ShaderMask)).blendMode,
        BlendMode.multiply,
      );
    });

    testWidgets('missing gradient passes the child through', (tester) async {
      await _pump(tester, const {}, const Text('child'));

      expect(find.byType(ShaderMask), findsNothing);
      expect(find.text('child'), findsOneWidget);
    });
  });
}
