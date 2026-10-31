import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/skeleton_widget.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/text_widget.dart';

Future<void> _pump(WidgetTester tester, Map<String, Object?> props) =>
    tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: EngineMetrics(
          scale: 1.0,
          child: Center(
            child: Builder(
              builder: (context) =>
                  SkeletonWidget.build(context, props, const []),
            ),
          ),
        ),
      ),
    );

Container _box(WidgetTester tester) =>
    tester.widget<Container>(find.byType(Container));

void main() {
  group('SkeletonWidget', () {
    group('build', () {
      testWidgets('rect — sizes the bone and rounds by radius', (tester) async {
        await _pump(tester, const {'width': 120, 'height': 16, 'radius': 6});
        final box = tester.getSize(find.byType(Container));
        expect(box, const Size(120, 16));
        final decoration = _box(tester).decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(6));
        // opaque fill so the ancestor shimmer's srcATOP mask has pixels.
        expect((decoration.color)!.a, 1.0);
      });

      testWidgets('circle — diameter is height, width ignored', (tester) async {
        await _pump(tester, const {
          'width': 200,
          'height': 40,
          'shape': 'circle',
        });
        expect(tester.getSize(find.byType(Container)), const Size(40, 40));
        final decoration = _box(tester).decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(20));
      });

      testWidgets('pill — fully rounded ends at any width', (tester) async {
        await _pump(tester, const {'width': 80, 'height': 24, 'shape': 'pill'});
        final decoration = _box(tester).decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(12));
      });
    });

    group('of: text', () {
      const textKey = ValueKey('text');
      const boneKey = ValueKey('bone');

      /// A real text and its bone with the same props, under text scale 1.3.
      Future<void> pumpPair(
        WidgetTester tester,
        Map<String, Object?> props, {
        String value = 'Hello',
        bool unbounded = false,
      }) {
        Widget pair(BuildContext context) {
          final children = [
            KeyedSubtree(
              key: textKey,
              child: TextWidget.build(context, {
                ...props,
                'value': value,
              }, const []),
            ),
            KeyedSubtree(
              key: boneKey,
              child: SkeletonWidget.build(context, {
                ...props,
                'of': 'text',
              }, const []),
            ),
          ];
          return unbounded
              ? Row(children: children)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                );
        }

        return tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: EngineMetrics(
                scale: 1.0,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(width: 200, child: Builder(builder: pair)),
                ),
              ),
            ),
          ),
        );
      }

      testWidgets('is as tall as the text it stands for', (tester) async {
        for (final size in const [12, 16, 28]) {
          for (final height in const [null, 1.4]) {
            final style = {'font_size': size, 'height': ?height};
            await pumpPair(tester, {'style': style});
            expect(
              tester.getSize(find.byKey(boneKey)).height,
              moreOrLessEquals(
                tester.getSize(find.byKey(textKey)).height,
                epsilon: 0.5,
              ),
              reason: 'font_size $size, height $height',
            );
          }
        }
      });

      testWidgets('draws one bar per line, the last at 60 % width', (
        tester,
      ) async {
        await pumpPair(tester, const {
          'style': {'font_size': 16},
          'max_lines': 2,
        }, value: 'Hello\nWorld');

        expect(
          tester.getSize(find.byKey(boneKey)).height,
          moreOrLessEquals(
            tester.getSize(find.byKey(textKey)).height,
            epsilon: 0.5,
          ),
        );
        final bars = find.descendant(
          of: find.byKey(boneKey),
          matching: find.byType(DecoratedBox),
        );
        expect(bars, findsNWidgets(2));
        expect(tester.getSize(bars.first).width, 200);
        expect(tester.getSize(bars.last).width, 120);
      });

      testWidgets('takes its width or 80 px in an unbounded row', (
        tester,
      ) async {
        await pumpPair(tester, const {'width': 50});
        expect(tester.getSize(find.byKey(boneKey)).width, 50);

        await pumpPair(tester, const {}, unbounded: true);
        expect(tester.getSize(find.byKey(boneKey)).width, 80);
      });
    });
  });
}
