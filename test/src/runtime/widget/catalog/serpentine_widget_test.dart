import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/compile/template_validator.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/util/serpentine_geometry.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/serpentine_row_widget.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/serpentine_widget.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';

Widget _row(
  BuildContext context,
  List<Size> sizes, {
  Map<String, Object?> props = const {},
}) => SerpentineRowWidget.build(context, props, [
  for (final size in sizes) SizedBox.fromSize(size: size),
]);

Future<RenderSerpentine> _pumpBoard(
  WidgetTester tester, {
  Map<String, Object?> props = const {},
  List<List<Size>> rows = const [],
  Map<String, Object?> rowProps = const {},
  List<Widget>? children,
  double width = 200,
  GlobalKey? paintKey,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: EngineMetrics(
        scale: 1,
        child: Center(
          child: RepaintBoundary(
            key: paintKey,
            child: SizedBox(
              width: width,
              child: Builder(
                builder: (context) => SerpentineWidget.build(
                  context,
                  props,
                  children ??
                      [
                        for (final row in rows)
                          _row(context, row, props: rowProps),
                      ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  return tester.renderObject<RenderSerpentine>(
    find.byType(SerpentineRenderObjectWidget),
  );
}

void main() {
  group('SerpentineWidget', () {
    testWidgets('forwards taps to cells in different rows', (tester) async {
      final firstKey = GlobalKey();
      final secondKey = GlobalKey();
      var firstTaps = 0;
      var secondTaps = 0;

      Widget tappableRow(
        BuildContext context,
        GlobalKey key,
        VoidCallback onTap,
      ) {
        return SerpentineRowWidget.build(context, const {}, [
          GestureDetector(
            key: key,
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: const SizedBox(width: 40, height: 30),
          ),
        ]);
      }

      final render = await _pumpBoard(
        tester,
        props: const {'spacing': 12},
        children: [
          Builder(
            builder: (context) =>
                tappableRow(context, firstKey, () => firstTaps++),
          ),
          Builder(
            builder: (context) =>
                tappableRow(context, secondKey, () => secondTaps++),
          ),
        ],
      );

      final hitTestResult = BoxHitTestResult();
      expect(
        render.hitTest(hitTestResult, position: render.cellPoints.first.single),
        isTrue,
      );

      await tester.tap(find.byKey(firstKey));
      await tester.pump();
      await tester.tap(find.byKey(secondKey));
      await tester.pump();

      expect(firstTaps, 1);
      expect(secondTaps, 1);
    });

    testWidgets('stacks rows with spacing and reports the stacked height', (
      tester,
    ) async {
      final render = await _pumpBoard(
        tester,
        props: const {'spacing': 7},
        rows: const [
          [Size(20, 10)],
          [Size(20, 20)],
          [Size(20, 15)],
        ],
      );

      expect(render.size, const Size(200, 59));
      expect(render.rowOffsets.map((offset) => offset.dy), [0, 17, 44]);
    });

    testWidgets('spans every row past the cells by the overhang', (
      tester,
    ) async {
      final render = await _pumpBoard(
        tester,
        props: const {'spacing': 10},
        rows: const [
          [Size(20, 20), Size(40, 20), Size(20, 20)],
          [Size(20, 20), Size(40, 20), Size(20, 20)],
        ],
      );
      const expectedPoints = <List<Offset>>[
        [Offset(70, 10), Offset(100, 10), Offset(130, 10)],
        [Offset(70, 40), Offset(100, 40), Offset(130, 40)],
      ];
      // Cells occupy 60..140; the default overhang is the 2px stroke width.
      final expected = SerpentineGeometry.track(
        expectedPoints,
        spanLeft: 58,
        spanRight: 142,
      );

      expect(render.cellPoints, expectedPoints);
      expect(render.track.length, closeTo(expected.length, 1e-6));
      expect(render.track.distances, expected.distances);
      final bounds = render.track.path.getBounds();
      expect(bounds.left, closeTo(58, 1e-6));
      expect(bounds.right, closeTo(142, 1e-6));
    });

    testWidgets(
      'a narrower final row stops its tail at its own cells, not the span',
      (tester) async {
        // Row 0 is the widest (3 cells, end-aligned); the last row is narrower
        // (2 cells, also end-aligned, so it shares row 0's right edge but not
        // its left). With the old shared-span tail, the last row's straight
        // would run all the way out to row 0's left edge instead of stopping
        // near its own.
        final withNarrowTail = await _pumpBoard(
          tester,
          props: const {'spacing': 10},
          rowProps: const {'alignment': 'end'},
          rows: const [
            [Size(20, 20), Size(20, 20), Size(20, 20)],
            [Size(20, 20), Size(20, 20)],
          ],
        );
        // Rebuilds the old, shared-span-at-both-ends track from the same cell
        // anchors, to compare against.
        final fullWidthTail = SerpentineGeometry.track(
          withNarrowTail.cellPoints,
          spanLeft: 135,
          spanRight: 199,
        );

        expect(withNarrowTail.track.length, lessThan(fullWidthTail.length));
        final distances = withNarrowTail.track.distances;
        for (var i = 1; i < distances.length; i += 1) {
          expect(
            distances[i],
            greaterThanOrEqualTo(distances[i - 1]),
            reason: 'cell $i went backwards',
          );
        }
      },
    );

    testWidgets('the tail lands on the correct side for the final row parity', (
      tester,
    ) async {
      // Two rows, both centred: the last (index 1, odd) runs right to left, so
      // its tail sits on the left of its own (narrower) cells, well inside the
      // shared spanLeft (68) row 0 alone would put it at.
      final oddTail = await _pumpBoard(
        tester,
        props: const {'spacing': 10},
        rows: const [
          [Size(20, 20), Size(20, 20), Size(20, 20)],
          [Size(20, 20)],
        ],
      );
      final oddMetric = oddTail.track.path.computeMetrics().single;
      final oddTailPoint = oddMetric
          .getTangentForOffset(oddMetric.length)!
          .position;

      expect(oddTailPoint.dx, closeTo(88, 1e-6));
      expect(oddTailPoint.dx, greaterThan(68));

      // Three rows, all centred: the last (index 2, even) runs left to right,
      // so its tail sits on the right of its own (narrower) cells, well inside
      // the shared spanRight (132) row 0 alone would put it at.
      final evenTail = await _pumpBoard(
        tester,
        props: const {'spacing': 10},
        rows: const [
          [Size(20, 20), Size(20, 20), Size(20, 20)],
          [Size(20, 20)],
          [Size(20, 20)],
        ],
      );
      final evenMetric = evenTail.track.path.computeMetrics().single;
      final evenTailPoint = evenMetric
          .getTangentForOffset(evenMetric.length)!
          .position;

      expect(evenTailPoint.dx, closeTo(112, 1e-6));
      expect(evenTailPoint.dx, lessThan(132));
    });

    testWidgets('uses the widest row intrinsic width when width is unbounded', (
      tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: EngineMetrics(
            scale: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (context) =>
                      SerpentineWidget.build(context, const {}, [
                        _row(context, const [Size(20, 10), Size(30, 10)]),
                      ]),
                ),
              ],
            ),
          ),
        ),
      );
      final render = tester.renderObject<RenderSerpentine>(
        find.byType(SerpentineRenderObjectWidget),
      );

      // 50 of row plus the track margin (2px overhang + half the 2px stroke)
      // on each side — the wrapping track is part of the board's natural width.
      expect(render.size, const Size(56, 10));
      expect(tester.takeException(), isNull);
    });

    testWidgets('dry layout matches actual size and supports IntrinsicHeight', (
      tester,
    ) async {
      final render = await _pumpBoard(
        tester,
        props: const {'spacing': 7},
        rows: const [
          [Size(20, 10)],
          [Size(30, 20)],
          [Size(40, 15)],
        ],
      );

      expect(
        render.getDryLayout(const BoxConstraints.tightFor(width: 200)),
        render.size,
      );
      expect(render.size, const Size(200, 59));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: EngineMetrics(
            scale: 1,
            child: Center(
              child: IntrinsicHeight(
                child: SizedBox(
                  width: 200,
                  child: Builder(
                    builder: (context) => SerpentineWidget.build(
                      context,
                      const {'spacing': 7},
                      [
                        _row(context, const [Size(20, 10)]),
                        _row(context, const [Size(30, 20)]),
                        _row(context, const [Size(40, 15)]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('reserves horizontal room for U-turn stroke bounds', (
      tester,
    ) async {
      final render = await _pumpBoard(
        tester,
        props: const {
          'spacing': 30,
          'anchor': 'center_right',
          'track': {'width': 8},
        },
        rowProps: const {'alignment': 'space_between'},
        rows: const [
          [Size(20, 20), Size(20, 20), Size(20, 20)],
          [Size(20, 20), Size(20, 20), Size(20, 20)],
        ],
        width: 120,
      );
      final bounds = render.track.path.getBounds().inflate(4);

      expect(render.rowOffsets.first.dx, greaterThan(0));
      expect(bounds.left, greaterThanOrEqualTo(-1e-3));
      expect(bounds.right, lessThanOrEqualTo(render.size.width + 1e-3));
    });

    testWidgets('anchor changes the point selected inside every cell', (
      tester,
    ) async {
      final centered = await _pumpBoard(
        tester,
        rows: const [
          [Size(20, 40), Size(20, 20)],
        ],
      );
      final centeredPoints = centered.cellPoints.single.toList();
      final topLeft = await _pumpBoard(
        tester,
        props: const {'anchor': 'top_left'},
        rows: const [
          [Size(20, 40), Size(20, 20)],
        ],
      );

      expect(topLeft.cellPoints.single.first.dy, 0);
      expect(
        topLeft.cellPoints.single.first.dy,
        lessThan(centeredPoints.first.dy),
      );
      expect(
        topLeft.cellPoints.single.first.dx,
        lessThan(centeredPoints.first.dx),
      );
    });

    testWidgets('treats non-row children as centred single-cell rows', (
      tester,
    ) async {
      final render = await _pumpBoard(
        tester,
        props: const {'spacing': 30},
        children: const [
          SizedBox(width: 40, height: 30),
          SizedBox(width: 60, height: 20),
        ],
      );

      expect(render.cellPoints, hasLength(2));
      expect(render.cellPoints.first.single, const Offset(100, 15));
      // The degraded row still produces a track that encloses it.
      final bounds = render.track.path.getBounds();
      expect(bounds.left, lessThan(3));
      expect(bounds.right, greaterThan(197));
      expect(tester.takeException(), isNull);
    });

    testWidgets('warns once per instance for non-row children', (tester) async {
      final messages = <String>[];
      final previousDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) messages.add(message);
      };
      try {
        final render = await _pumpBoard(
          tester,
          props: const {'spacing': 30},
          children: const [
            SizedBox(width: 40, height: 30),
            SizedBox(width: 60, height: 20),
          ],
        );
        render.markNeedsLayout();
        await tester.pump();

        expect(
          messages.where(
            (message) => message.startsWith(
              'serpentine direct-child constraint: expected',
            ),
          ),
          hasLength(1),
        );
      } finally {
        debugPrint = previousDebugPrint;
      }
    });

    testWidgets('empty boards paint nothing and do not throw', (tester) async {
      final paintKey = GlobalKey();
      final render = await _pumpBoard(tester, paintKey: paintKey);

      expect(render.track.length, 0);
      expect(tester.takeException(), isNull);
      expect(find.byKey(paintKey), isNot(paints..path()));
    });

    testWidgets('paints one stroked base path without progress', (
      tester,
    ) async {
      final paintKey = GlobalKey();
      await _pumpBoard(
        tester,
        paintKey: paintKey,
        props: const {
          'track': {'color': '#123456', 'width': 4},
        },
        rows: const [
          [Size(20, 20), Size(20, 20)],
        ],
      );

      expect(
        find.byKey(paintKey),
        paints..path(
          color: const Color(0xFF123456),
          strokeWidth: 4,
          style: PaintingStyle.stroke,
        ),
      );
    });

    testWidgets('paints progress as a second path in its own colour', (
      tester,
    ) async {
      final paintKey = GlobalKey();
      await _pumpBoard(
        tester,
        paintKey: paintKey,
        props: const {
          'track': {'color': '#123456', 'width': 4},
          'progress': {'index': 1.5, 'color': '#ABCDEF'},
        },
        rows: const [
          [Size(20, 20), Size(20, 20), Size(20, 20)],
        ],
      );

      expect(
        find.byKey(paintKey),
        paints
          ..path(color: const Color(0xFF123456))
          ..path(color: const Color(0xFFABCDEF)),
      );
    });

    testWidgets('fractional progress grows continuously with the index', (
      tester,
    ) async {
      final smaller = await _pumpBoard(
        tester,
        props: const {
          'progress': {'index': 0.5, 'color': '#FFFFFF'},
        },
        rows: const [
          [Size(20, 20), Size(20, 20), Size(20, 20)],
        ],
      );
      final smallerRatio = smaller.progressRatio;
      final larger = await _pumpBoard(
        tester,
        props: const {
          'progress': {'index': 1.5, 'color': '#FFFFFF'},
        },
        rows: const [
          [Size(20, 20), Size(20, 20), Size(20, 20)],
        ],
      );

      // One row of three 20px cells at 70..130 with a 2px overhang: the track
      // runs 68..132, so the cells sit at 12/32/52 along its 64px length.
      expect(smallerRatio, closeTo(22 / 64, 1e-6));
      expect(larger.progressRatio, closeTo(42 / 64, 1e-6));
      expect(larger.progressRatio!, greaterThan(smallerRatio!));
    });

    testWidgets('factory resolves both registered SDUI types', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: EngineMetrics(
            scale: 1,
            child: Builder(
              builder: (value) {
                context = value;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(
        WidgetFactory.build(context, 'serpentine', const {}, const []),
        isA<SerpentineRenderObjectWidget>(),
      );
      expect(
        WidgetFactory.build(context, 'serpentine_row', const {}, const []),
        isA<SerpentineRowRenderObjectWidget>(),
      );
    });

    testWidgets('a serpentine loop wrap validates and builds', (tester) async {
      const template = {
        '_type': 'serpentine_row',
        '_loop': {
          '_in': r'${rows}',
          '_as': 'row',
          '_key': r'${row.id}',
          '_wrap': 'serpentine',
        },
        '_children': [
          {'_type': 'sizedbox', 'width': 20, 'height': 20},
        ],
      };
      final node = TemplateParser.buildUiTree(template);
      final directive = TemplateCompiler.buildDirectiveTree(node);

      expect(
        () => TemplateValidator.validate(directive, const {'rows'}),
        returnsNormally,
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: EngineMetrics(
            scale: 1,
            child: Scope.ofState(
              const {
                'rows': [
                  {'id': 'a'},
                  {'id': 'b'},
                ],
              },
              child: SizedBox(width: 200, child: NodeBuilder.build(directive)),
            ),
          ),
        ),
      );

      expect(find.byType(SerpentineRenderObjectWidget), findsOneWidget);
      expect(find.byType(SerpentineRowRenderObjectWidget), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });
}
