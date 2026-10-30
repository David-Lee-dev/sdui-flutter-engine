import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/media/shader_registry.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/util/shape_geometry.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/shape_widget.dart';

/// `shaders/sdf_shapes.frag`가 `ShapeGeometry.combineDistance`와 같은 식을
/// 쓰는지, 실제 셰이더 출력 픽셀을 Dart 거리값과 표본 지점에서 대조한다.
const _key = ValueKey('shape');
const _box = Size(120, 80);

Widget _host(Map<String, Object?> props) => Directionality(
  textDirection: TextDirection.ltr,
  child: EngineMetrics(
    scale: 1.0,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        key: _key,
        width: _box.width,
        height: _box.height,
        child: Builder(
          builder: (context) => ShapeWidget.build(context, props, const []),
        ),
      ),
    ),
  ),
);

/// Straight RGBA bytes of the shape's own repaint boundary.
Future<(ByteData, int)> _pixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.descendant(
      of: find.byKey(_key),
      matching: find.byType(RepaintBoundary),
    ),
  );
  final (data, width) = (await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final w = image.width;
    image.dispose();
    return (bytes!, w);
  }))!;
  return (data, width);
}

double _alpha(ByteData data, int width, int x, int y) =>
    data.getUint8((y * width + x) * 4 + 3) / 255;

void main() {
  setUp(ShaderRegistry.reset);
  tearDown(ShaderRegistry.reset);

  const bar = {
    'kind': 'capsule',
    'inset': [4, 24],
  };

  for (final op in ['union', 'subtract', 'intersect']) {
    for (final own in <double?>[null, 0, 16]) {
      testWidgets('op $op, 도형별 smooth $own (공통 8): 셰이더 = Dart', (tester) async {
        await tester.runAsync(ShaderRegistry.warmUp);
        expect(ShaderRegistry.available, isTrue);
        final circle = {
          'kind': 'circle',
          'op': op,
          'at': [0.5, 0.35],
          'radius': 22,
          'smooth': ?own,
        };
        await tester.pumpWidget(
          _host({
            'shapes': [bar, circle],
            'smooth': 8,
            'fill': '#FFFFFFFF',
          }),
        );
        final boxes = [
          ShapeGeometry.resolve(
            const ShapePrimitive(
              kind: ShapeKind.capsule,
              alignment: Alignment.center,
              inset: Size(4, 24),
            ),
            _box,
          ),
          ShapeGeometry.resolve(
            ShapePrimitive(
              kind: ShapeKind.circle,
              alignment: Alignment.center,
              at: const Offset(0.5, 0.35),
              radius: 22,
              op: ShapeOp.values.byName(op),
              smooth: own,
            ),
            _box,
          ),
        ];
        final (data, width) = await _pixels(tester);
        var compared = 0;
        var inside = 0;
        for (var y = 1; y < _box.height; y += 3) {
          for (var x = 1; x < _box.width; x += 3) {
            final d = ShapeGeometry.combineDistance(
              Offset(x + 0.5, y + 0.5),
              boxes,
              8,
            );
            final expected = (0.5 - d).clamp(0.0, 1.0);
            expect(
              _alpha(data, width, x, y),
              closeTo(expected, 0.06),
              reason: '($x, $y) d=$d',
            );
            compared++;
            if (expected == 1) inside++;
          }
        }
        expect(compared, greaterThan(900));
        expect(inside, greaterThan(0));
      });
    }
  }

  testWidgets('투명 fill + 불투명 rim: 안쪽은 비고 가장자리만 칠한다', (tester) async {
    await tester.runAsync(ShaderRegistry.warmUp);
    await tester.pumpWidget(
      _host({
        'shapes': [bar],
        'fill': '#00000000',
        'rim': {
          'width': 4,
          'gradient': {
            'colors': ['#FFFF0000', '#FFFF0000'],
          },
        },
      }),
    );
    final (data, width) = await _pixels(tester);
    expect(_alpha(data, width, 60, 40), 0); // 캡슐 한가운데
    expect(_alpha(data, width, 60, 24), greaterThan(0.9)); // 위 가장자리
    expect(data.getUint8((24 * width + 60) * 4), greaterThan(230)); // 빨강
  });

  testWidgets('gradient fill + 투명 rim: 안쪽만 칠하고 바깥 rim 자리는 빈다', (tester) async {
    await tester.runAsync(ShaderRegistry.warmUp);
    await tester.pumpWidget(
      _host({
        'shapes': [bar],
        'fill': {
          'colors': ['#FF00FF00', '#FF00FF00'],
        },
        'rim': {'color': '#00000000', 'width': 8},
      }),
    );
    final (data, width) = await _pixels(tester);
    expect(_alpha(data, width, 60, 40), greaterThan(0.99));
    expect(data.getUint8((40 * width + 60) * 4 + 1), greaterThan(250)); // 초록
    expect(_alpha(data, width, 60, 21), 0); // rim이 덮을 바깥 3px
  });
}
