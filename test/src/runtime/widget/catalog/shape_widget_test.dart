import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/error_observer.dart';
import 'package:sdui_engine/src/runtime/engine_errors.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';
import 'package:sdui_engine/src/runtime/media/shader_registry.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/shape_widget.dart';

const _key = ValueKey('shape');

Widget _host(Map<String, Object?> props, {Widget Function(Widget)? wrap}) {
  final shape = Builder(
    builder: (context) => ShapeWidget.build(context, props, const []),
  );
  return Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: 1.0,
      child: Align(
        alignment: Alignment.topLeft,
        child: wrap != null
            ? wrap(shape)
            : SizedBox(key: _key, width: 200, height: 100, child: shape),
      ),
    ),
  );
}

/// A 200×100 bar (capsule, y 30–70) with a circle (r 20) centred at (100, 20).
const _bar = {
  'kind': 'capsule',
  'inset': [0, 30],
};
const _ball = {
  'kind': 'circle',
  'align': [0, -1],
  'offset': [0, 0],
  'radius': 20,
};

RenderBox _shapeBox(WidgetTester tester) => tester.renderObject<RenderBox>(
  find.descendant(
    of: find.byKey(_key),
    matching: find.byWidgetPredicate((w) => w is LeafRenderObjectWidget),
  ),
);

void main() {
  late List<String> logs;

  setUp(() {
    ShaderRegistry.reset();
    logs = [];
    EngineLog.configure(output: logs.add);
  });
  tearDown(() {
    EngineLog.configure(output: debugPrint);
    EngineErrors.reset();
    ShaderRegistry.reset();
  });

  group('ShapeWidget', () {
    testWidgets('셰이더가 없으면 하드 Path 합집합을 fill로 칠한다', (tester) async {
      await tester.pumpWidget(
        _host({
          'shapes': [_bar, _ball],
          'fill': '#FF112233',
        }),
      );
      expect(
        find.byKey(_key),
        paints..path(
          color: const Color(0xFF112233),
          style: PaintingStyle.fill,
          includes: const [Offset(100, 50), Offset(100, 10), Offset(5, 50)],
          excludes: const [Offset(5, 5), Offset(195, 95)],
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('rim은 같은 경로를 rim 색·두께로 한 번 더 긋는다', (tester) async {
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
          'fill': '#FF000000',
          'rim': {'color': '#80FFFFFF', 'width': 2},
        }),
      );
      expect(
        find.byKey(_key),
        paints
          ..path(style: PaintingStyle.fill)
          ..path(
            style: PaintingStyle.stroke,
            strokeWidth: 2,
            color: const Color(0x80FFFFFF),
          ),
      );
    });

    testWidgets('rim 두께는 [0, 16]으로 자르고 0이면 긋지 않는다', (tester) async {
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
          'rim': {'color': '#FFFFFFFF', 'width': 99},
        }),
      );
      expect(
        find.byKey(_key),
        paints
          ..path(style: PaintingStyle.fill)
          ..path(style: PaintingStyle.stroke, strokeWidth: 16),
      );
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
          'rim': {'color': '#FFFFFFFF', 'width': 0},
        }),
      );
      expect(
        find.byKey(_key),
        isNot(paints..path(style: PaintingStyle.stroke)),
      );
    });

    testWidgets('셰이더가 있으면 상자를 셰이더로 한 번 칠하고 Path를 쓰지 않는다', (tester) async {
      await tester.runAsync(ShaderRegistry.warmUp);
      expect(ShaderRegistry.available, isTrue);
      await tester.pumpWidget(
        _host({
          'shapes': [_bar, _ball],
          'smooth': 24,
          'fill': '#FF112233',
          'rim': {'color': '#80FFFFFF', 'width': 1},
        }),
      );
      expect(
        find.byKey(_key),
        paints..rect(rect: const Rect.fromLTWH(0, 0, 200, 100)),
      );
      expect(find.byKey(_key), isNot(paints..path()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('마운트 뒤 셰이더가 준비되면 다시 칠해 셰이더로 넘어간다', (tester) async {
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
        }),
      );
      expect(find.byKey(_key), paints..path());
      await tester.runAsync(ShaderRegistry.warmUp);
      await tester.pump();
      expect(find.byKey(_key), paints..rect());
      expect(find.byKey(_key), isNot(paints..path()));
    });

    testWidgets('9개째부터는 무시하고 한 번만 알린다', (tester) async {
      final shapes = [
        for (var i = 0; i < 8; i++) _bar,
        {'kind': 'circle', 'align': 'top_left', 'radius': 5},
      ];
      await tester.pumpWidget(_host({'shapes': shapes}));
      expect(find.byKey(_key), paints..path(excludes: const [Offset(5, 5)]));
      await tester.pumpWidget(_host({'shapes': List.of(shapes)}));
      expect(
        logs.where((l) => l.contains('shape') && l.contains('8')),
        hasLength(1),
      );
    });

    testWidgets('잘못된 동적 값은 그 도형의 마지막 정상값을 유지한다', (tester) async {
      Map<String, Object?> props(Object? radius) => {
        'shapes': [
          {'kind': 'circle', 'align': 'center', 'radius': radius},
        ],
      };
      await tester.pumpWidget(_host(props(40)));
      expect(find.byKey(_key), paints..path(includes: const [Offset(100, 15)]));
      for (final bad in <Object?>[double.nan, -5, 'x', double.infinity]) {
        await tester.pumpWidget(_host(props(bad)));
        expect(
          find.byKey(_key),
          paints..path(includes: const [Offset(100, 15)]),
          reason: '$bad',
        );
      }
      await tester.pumpWidget(_host(props(10)));
      expect(find.byKey(_key), paints..path(excludes: const [Offset(100, 15)]));
    });

    testWidgets('정상값이 한 번도 없던 도형은 빠진다', (tester) async {
      await tester.pumpWidget(
        _host({
          'shapes': [
            {'kind': 'star', 'radius': 30},
            {
              'kind': 'rrect',
              'offset': [double.nan, 0],
            },
            'circle',
            _ball,
          ],
        }),
      );
      expect(
        find.byKey(_key),
        paints..path(
          includes: const [Offset(100, 20)],
          excludes: const [Offset(100, 60), Offset(10, 90)],
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('shapes가 없거나 비면 아무것도 칠하지 않는다', (tester) async {
      for (final shapes in <Object?>[null, <Object?>[], 'x', 3]) {
        await tester.pumpWidget(_host({'shapes': shapes}));
        expect(find.byKey(_key), isNot(paints..path()));
        expect(find.byKey(_key), isNot(paints..rect()));
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('무한 축은 크기 0으로 두고 한 번만 알린다', (tester) async {
      await tester.pumpWidget(
        _host(
          {
            'shapes': [_bar],
          },
          wrap: (shape) => SizedBox(
            key: _key,
            height: 100,
            child: Row(children: [shape]),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(_shapeBox(tester).size, const Size(0, 100));
      await tester.pump();
      expect(logs.where((l) => l.contains('unbounded')), hasLength(1));
    });

    testWidgets('intrinsic 측정 안에서도 예외가 없다', (tester) async {
      await tester.pumpWidget(
        _host(
          {
            'shapes': [_bar],
          },
          wrap: (shape) => SizedBox(
            key: _key,
            width: 200,
            child: IntrinsicHeight(child: shape),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('칠하다 던지면 아무것도 그리지 않고 한 번만 보고하며 계속 깨진다', (tester) async {
      final reported = <SduiError>[];
      EngineErrors.observer = _Capture(reported);
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
        }),
      );
      final box = _shapeBox(tester);
      final canvas = _ThrowingCanvas();
      final context = _FakeContext(canvas);
      box.paint(context, Offset.zero);
      expect(reported, hasLength(1));
      expect(reported.single.scope, SduiErrorScope.nodeBuild);
      box.paint(context, Offset.zero);
      expect(reported, hasLength(1));
      expect(canvas.calls, 1);
      // 깨진 노드는 이후 실제 프레임에서도 칠하지 않는다.
      box.markNeedsPaint();
      await tester.pump();
      expect(find.byKey(_key), isNot(paints..path()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('도형은 히트 테스트에 잡히지 않는다', (tester) async {
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
        }),
      );
      final result = BoxHitTestResult();
      expect(
        _shapeBox(tester).hitTest(result, position: const Offset(100, 50)),
        isFalse,
      );
    });
  });
}

final class _Capture extends SduiErrorObserver {
  _Capture(this.sink);

  final List<SduiError> sink;

  @override
  void onError(SduiError error) => sink.add(error);
}

class _ThrowingCanvas extends Fake implements Canvas {
  int calls = 0;

  @override
  void drawPath(Path path, Paint paint) {
    calls++;
    throw StateError('canvas failure');
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    calls++;
    throw StateError('canvas failure');
  }

  @override
  void save() {}

  @override
  void restore() {}

  @override
  void translate(double dx, double dy) {}
}

class _FakeContext extends Fake implements PaintingContext {
  _FakeContext(this.canvas);

  @override
  final Canvas canvas;
}
