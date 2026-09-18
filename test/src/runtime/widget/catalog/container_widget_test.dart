import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/adaptive_radius.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/container_widget.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
  double scale = 1.0,
  Widget Function(Widget child)? wrap,
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: scale,
      child: Builder(
        builder: (context) {
          final child = ContainerWidget.build(context, props, children);
          return wrap == null ? child : wrap(child);
        },
      ),
    ),
  ),
);

void main() {
  group('ContainerWidget', () {
    group('build', () {
      testWidgets('width·height·padding·margin이 scale된다', (tester) async {
        await _pump(tester, const {
          'width': 100,
          'height': 200,
          'padding': 8,
          'margin': 4,
        }, scale: 0.5);
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxWidth, 50);
        expect(container.constraints?.maxHeight, 100);
        expect(container.padding, const EdgeInsets.all(4));
        expect(container.margin, const EdgeInsets.all(2));
      });

      testWidgets('decoration이 없으면 color를 그대로 쓴다', (tester) async {
        await _pump(tester, const {'color': '#ff0000'});
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.color, const Color(0xffff0000));
      });

      testWidgets('decoration이 있으면 color는 null(Flutter 동시 지정 assert 회피)', (
        tester,
      ) async {
        await _pump(tester, const {
          'color': '#ff0000',
          'decoration': {'color': '#00ff00'},
        });
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.color, isNull);
        expect(
          (container.decoration as BoxDecoration?)?.color,
          const Color(0xff00ff00),
        );
      });

      testWidgets('decoration border_radius auto는 실제 렌더 크기를 사용한다', (
        tester,
      ) async {
        await _pump(tester, const {
          'width': 100,
          'height': 100,
          'padding': 8,
          'decoration': {'border_radius': 'auto', 'color': '#00ff00'},
        }, wrap: (child) => Center(child: child));
        await tester.pump();

        final container = tester.widget<Container>(find.byType(Container));
        final measuredSize = tester.getSize(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(
          decoration.borderRadius,
          BorderRadius.circular(AdaptiveRadius.compute(measuredSize)),
        );
        expect(decoration.color, const Color(0xff00ff00));
        expect(container.padding, const EdgeInsets.all(8));
      });

      testWidgets(
        'auto-radius에서도 radius 무관 prop을 build 중 동기적으로 읽는다 (audit 순서 회귀)',
        (tester) async {
          late BuildContext ctx;
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: EngineMetrics(
                scale: 1.0,
                child: Builder(
                  builder: (c) {
                    ctx = c;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          );

          final props = _RecordingMap({
            'padding': 8,
            'width': 100,
            'margin': 4,
            'decoration': {'border_radius': 'auto', 'color': '#00ff00'},
          });

          // Build but do NOT mount the returned widget — so the
          // AdaptiveRadiusBox builder never runs. The audit runs at exactly
          // this point in node_builder.
          ContainerWidget.build(ctx, props, const []);

          expect(
            props.reads,
            containsAll(<String>['padding', 'width', 'margin']),
            reason:
                'auto-radius must not defer radius-independent prop reads '
                'past the audit',
          );
        },
      );

      testWidgets('자식은 첫 번째만', (tester) async {
        await _pump(
          tester,
          const {},
          children: [const Text('a'), const Text('b')],
        );
        final container = tester.widget<Container>(find.byType(Container));
        expect((container.child as Text).data, 'a');
      });

      testWidgets('clipBehavior 기본은 Clip.none', (tester) async {
        await _pump(tester, const {});
        expect(
          tester.widget<Container>(find.byType(Container)).clipBehavior,
          Clip.none,
        );
      });

      testWidgets('foregroundDecoration·transform·transformAlignment를 전달한다', (
        tester,
      ) async {
        await _pump(tester, const {
          'foreground_decoration': {'color': '#80000000'},
          'transform': {
            'scale': [-1, 1],
          },
          'transform_alignment': 'center_right',
        });
        final container = tester.widget<Container>(find.byType(Container));
        expect(
          (container.foregroundDecoration as BoxDecoration).color,
          const Color(0x80000000),
        );
        expect(container.transform?.entry(0, 0), -1);
        expect(container.transform?.entry(1, 1), 1);
        expect(container.transformAlignment, Alignment.centerRight);
      });
    });
  });
}

/// Records which keys are read, to assert synchronous prop consumption.
class _RecordingMap extends MapView<String, Object?> {
  _RecordingMap(super.map);

  final Set<String> reads = {};

  @override
  Object? operator [](Object? key) {
    if (key is String) reads.add(key);
    return super[key];
  }
}
