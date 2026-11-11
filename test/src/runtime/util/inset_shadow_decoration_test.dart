import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/container_widget.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/decorated_box_widget.dart';

const _capture = Key('capture');

const _white = 0xffffff;
const _green = 0x00ff00;
const _red = 0xff0000;
const _blue = 0x0000ff;
const _black = 0x000000;

/// Paints [box] at (10, 10) on a white 120×60 canvas.
Future<void> _pump(WidgetTester tester, Widget Function(BuildContext) box) =>
    tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: EngineMetrics(
          scale: 1,
          child: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: _capture,
              child: Container(
                width: 120,
                height: 60,
                color: const Color(0xffffffff),
                padding: const EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                child: Builder(builder: box),
              ),
            ),
          ),
        ),
      ),
    );

Future<void> _pumpContainer(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
}) =>
    _pump(tester, (context) => ContainerWidget.build(context, props, children));

Future<int> _pixel(WidgetTester tester, int x, int y) async =>
    (await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(_capture),
      );
      final image = await boundary.toImage();
      final data = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      final i = (y * image.width + x) * 4;
      return data.getUint8(i) << 16 |
          data.getUint8(i + 1) << 8 |
          data.getUint8(i + 2);
    }))!;

Future<void> _expectPixel(WidgetTester tester, int x, int y, int rgb) async =>
    expect(
      (await _pixel(tester, x, y)).toRadixString(16).padLeft(6, '0'),
      rgb.toRadixString(16).padLeft(6, '0'),
      reason: 'pixel ($x, $y)',
    );

Map<String, Object?> _inset({
  List<num> offset = const [0, 0],
  num spread = 0,
}) => {
  'color': '#ff0000',
  'offset': offset,
  'spread_radius': spread,
  'inset': true,
};

void main() {
  group('box_shadow inset', () {
    testWidgets('offset 아래쪽이면 위쪽 안에 그림자가 생기고 밖에는 없다', (tester) async {
      await _pumpContainer(tester, {
        'width': 100,
        'height': 40,
        'decoration': {
          'color': '#00ff00',
          'box_shadow': _inset(offset: [0, 8]),
        },
      });
      await _expectPixel(tester, 60, 13, _red);
      await _expectPixel(tester, 60, 30, _green);
      await _expectPixel(tester, 60, 48, _green);
      await _expectPixel(tester, 60, 5, _white);
      await _expectPixel(tester, 60, 55, _white);
    });

    testWidgets('offset 위쪽이면 아래쪽 안에 그림자가 생긴다', (tester) async {
      await _pumpContainer(tester, {
        'width': 100,
        'height': 40,
        'decoration': {
          'color': '#00ff00',
          'box_shadow': _inset(offset: [0, -8]),
        },
      });
      await _expectPixel(tester, 60, 13, _green);
      await _expectPixel(tester, 60, 46, _red);
    });

    testWidgets('spread 는 안쪽으로 테두리처럼 두꺼워진다', (tester) async {
      await _pumpContainer(tester, {
        'width': 100,
        'height': 40,
        'decoration': {'color': '#00ff00', 'box_shadow': _inset(spread: 4)},
      });
      await _expectPixel(tester, 12, 30, _red);
      await _expectPixel(tester, 107, 30, _red);
      await _expectPixel(tester, 60, 12, _red);
      await _expectPixel(tester, 60, 47, _red);
      await _expectPixel(tester, 60, 30, _green);
    });

    testWidgets('border_radius 를 따라 안쪽에만 그린다', (tester) async {
      await _pumpContainer(tester, {
        'width': 100,
        'height': 40,
        'decoration': {
          'color': '#00ff00',
          'border_radius': 20,
          'box_shadow': _inset(spread: 6),
        },
      });
      // Inside the outer corner arc, outside the deflated (radius 14) hole.
      await _expectPixel(tester, 18, 18, _red);
      // Outside the rounded corner: not painted.
      await _expectPixel(tester, 11, 11, _white);
      await _expectPixel(tester, 60, 30, _green);
    });

    testWidgets('shape circle 을 따라 안쪽에만 그린다', (tester) async {
      await _pumpContainer(tester, {
        'width': 40,
        'height': 40,
        'decoration': {
          'color': '#00ff00',
          'shape': 'circle',
          'box_shadow': _inset(spread: 6),
        },
      });
      await _expectPixel(tester, 30, 13, _red);
      await _expectPixel(tester, 30, 30, _green);
      await _expectPixel(tester, 11, 11, _white);
    });

    testWidgets('자식은 inset 그림자 위에, border 는 그림자 위에 그린다', (tester) async {
      await _pumpContainer(
        tester,
        {
          'width': 100,
          'height': 40,
          'alignment': 'top_left',
          'decoration': {
            'color': '#00ff00',
            'border': {'width': 2, 'color': '#0000ff'},
            'box_shadow': _inset(spread: 8),
          },
        },
        children: const [
          SizedBox(
            width: 20,
            height: 20,
            child: ColoredBox(color: Color(0xff000000)),
          ),
        ],
      );
      await _expectPixel(tester, 15, 15, _black);
      await _expectPixel(tester, 60, 11, _blue);
      await _expectPixel(tester, 60, 15, _red);
      await _expectPixel(tester, 60, 30, _green);
    });

    testWidgets('바깥 그림자와 섞으면 바깥은 밖에, inset 은 안에 그린다', (tester) async {
      await _pumpContainer(tester, {
        'width': 100,
        'height': 40,
        'decoration': {
          'color': '#00ff00',
          'box_shadow': [
            {'color': '#0000ff', 'spread_radius': 4},
            _inset(spread: 4),
          ],
        },
      });
      await _expectPixel(tester, 60, 8, _blue);
      await _expectPixel(tester, 60, 12, _red);
      await _expectPixel(tester, 60, 30, _green);
    });

    testWidgets('inset 이 없으면 예전처럼 바깥 그림자만 그린다', (tester) async {
      await _pumpContainer(tester, {
        'width': 100,
        'height': 40,
        'decoration': {
          'color': '#00ff00',
          'box_shadow': {'color': '#0000ff', 'spread_radius': 4},
        },
      });
      await _expectPixel(tester, 60, 8, _blue);
      await _expectPixel(tester, 60, 12, _green);
    });

    testWidgets('decorated_box 도 inset 그림자를 그린다', (tester) async {
      await _pump(
        tester,
        (context) => DecoratedBoxWidget.build(
          context,
          {
            'decoration': {'color': '#00ff00', 'box_shadow': _inset(spread: 4)},
          },
          const [SizedBox(width: 100, height: 40)],
        ),
      );
      await _expectPixel(tester, 60, 12, _red);
      await _expectPixel(tester, 60, 30, _green);
    });
  });
}
