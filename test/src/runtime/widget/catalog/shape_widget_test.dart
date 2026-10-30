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

bool _isSaveLayer(Symbol method, List<dynamic> args) => method == #saveLayer;

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

    testWidgets('subtract는 목록 순서대로 하드 difference Path로 칠한다 (셰이더 없음)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host({
          'shapes': [
            _bar,
            {
              'kind': 'circle',
              'op': 'subtract',
              'at': [0.5, 0.3],
              'radius': 20,
            },
          ],
        }),
      );
      expect(
        find.byKey(_key),
        paints..path(
          includes: const [Offset(20, 50), Offset(180, 50)],
          excludes: const [Offset(100, 40)],
        ),
      );
    });

    testWidgets('intersect는 겹치는 곳만 남긴다 (셰이더 없음)', (tester) async {
      await tester.pumpWidget(
        _host({
          'shapes': [
            _bar,
            {
              'kind': 'circle',
              'op': 'intersect',
              'at': [0.5, 0.3],
              'radius': 20,
            },
          ],
        }),
      );
      expect(
        find.byKey(_key),
        paints..path(
          includes: const [Offset(100, 40)],
          excludes: const [Offset(20, 50), Offset(100, 15)],
        ),
      );
    });

    testWidgets('at은 align보다 우선한다', (tester) async {
      await tester.pumpWidget(
        _host({
          'shapes': [
            {
              'kind': 'circle',
              'align': 'top_left',
              'at': [0.9, 0.5],
              'radius': 8,
            },
          ],
        }),
      );
      expect(
        find.byKey(_key),
        paints..path(
          includes: const [Offset(180, 50)],
          excludes: const [Offset(8, 8)],
        ),
      );
    });

    testWidgets('잘못된 op·at·smooth 동적 값은 그 도형만 직전 정상값을 유지하고 보고하지 않는다', (
      tester,
    ) async {
      final reported = <SduiError>[];
      EngineErrors.observer = _Capture(reported);
      Map<String, Object?> props(Object? op, Object? at, Object? smooth) => {
        'shapes': [
          _bar,
          {
            'kind': 'circle',
            'op': op,
            'at': at,
            'smooth': smooth,
            'radius': 20,
          },
        ],
      };
      await tester.pumpWidget(_host(props('subtract', [0.5, 0.3], 4)));
      expect(find.byKey(_key), paints..path(excludes: const [Offset(100, 40)]));
      for (final bad in <List<Object?>>[
        [
          'cut',
          [0.5, 0.3],
          4,
        ],
        [
          'subtract',
          [double.nan, 0],
          4,
        ],
        [
          'subtract',
          [0.5],
          4,
        ],
        [
          'subtract',
          [0.5, 0.3],
          'x',
        ],
        [
          3,
          [0.5, 0.3],
          4,
        ],
      ]) {
        await tester.pumpWidget(_host(props(bad[0], bad[1], bad[2])));
        expect(
          find.byKey(_key),
          paints..path(excludes: const [Offset(100, 40)]),
          reason: '$bad',
        );
      }
      expect(reported, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('gradient fill은 셰이더가 없으면 Path를 gradient로 칠한다', (tester) async {
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
          'fill': {
            'colors': ['#FFFF0000', '#FF0000FF'],
          },
        }),
      );
      expect(
        find.byKey(_key),
        paints..something(
          (method, args) =>
              method == #drawPath && (args[1] as Paint).shader != null,
        ),
      );
    });

    testWidgets('gradient fill은 셰이더 coverage 위에 srcIn으로 칠한다', (tester) async {
      await tester.runAsync(ShaderRegistry.warmUp);
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
          'fill': {
            'colors': ['#FFFF0000', '#FF0000FF'],
          },
        }),
      );
      expect(
        find.byKey(_key),
        paints
          ..something(_isSaveLayer)
          ..rect(rect: const Rect.fromLTWH(0, 0, 200, 100))
          ..something(
            (method, args) =>
                method == #drawRect &&
                (args[1] as Paint).blendMode == BlendMode.srcIn &&
                (args[1] as Paint).shader != null,
          )
          ..restore(),
      );
    });

    testWidgets('투명 fill + gradient rim: rim만 따로 coverage를 칠한다', (
      tester,
    ) async {
      await tester.runAsync(ShaderRegistry.warmUp);
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
          'fill': '#00000000',
          'rim': {
            'width': 2,
            'gradient': {
              'colors': ['#FFFFFFFF', '#FF00FF00'],
            },
          },
        }),
      );
      expect(
        find.byKey(_key),
        paints
          ..rect()
          ..something(_isSaveLayer)
          ..rect()
          ..something(
            (method, args) =>
                method == #drawRect &&
                (args[1] as Paint).blendMode == BlendMode.srcIn,
          )
          ..restore(),
      );
    });

    testWidgets('gradient fill + 불투명 rim: fill만 layer로 칠하고 rim은 바로 칠한다', (
      tester,
    ) async {
      await tester.runAsync(ShaderRegistry.warmUp);
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
          'fill': {
            'colors': ['#FFFF0000', '#FF0000FF'],
          },
          'rim': {'color': '#FFFFFFFF', 'width': 2},
        }),
      );
      expect(
        find.byKey(_key),
        paints
          ..something(_isSaveLayer)
          ..rect()
          ..rect()
          ..restore()
          ..rect(),
      );
    });

    testWidgets('rim gradient (셰이더 없음)은 stroke를 gradient로 긋는다', (tester) async {
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
          'rim': {
            'width': 3,
            'gradient': {
              'colors': ['#FFFFFFFF', '#FF00FF00'],
            },
          },
        }),
      );
      expect(
        find.byKey(_key),
        paints
          ..path(style: PaintingStyle.fill)
          ..something(
            (method, args) =>
                method == #drawPath &&
                (args[1] as Paint).style == PaintingStyle.stroke &&
                (args[1] as Paint).strokeWidth == 3 &&
                (args[1] as Paint).shader != null,
          ),
      );
    });

    testWidgets('shadow는 fill보다 먼저 blur layer에 그림자 색으로 칠한다 (셰이더)', (
      tester,
    ) async {
      await tester.runAsync(ShaderRegistry.warmUp);
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
          'shadow': {
            'color': '#80000000',
            'blur': 99,
            'offset': [0, 4],
          },
        }),
      );
      expect(
        find.byKey(_key),
        paints
          ..something(
            (method, args) =>
                method == #saveLayer && (args[1] as Paint).imageFilter != null,
          )
          ..rect()
          ..restore()
          ..rect(),
      );
    });

    testWidgets('shadow (셰이더 없음)은 옮긴 Path를 mask blur로 칠한다', (tester) async {
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
          'shadow': {
            'color': '#80000000',
            'blur': 6,
            'offset': [0, 40],
          },
        }),
      );
      expect(
        find.byKey(_key),
        paints
          ..something(
            (method, args) =>
                method == #drawPath &&
                (args[1] as Paint).maskFilter != null &&
                (args[1] as Paint).color.toARGB32() == 0x80000000,
          )
          ..path(color: const Color(0xFF000000)),
      );
    });

    testWidgets(
      'backdrop은 하드 Path clip 아래 BackdropFilterLayer를 둔다 (투명 fill도)',
      (tester) async {
        await tester.pumpWidget(
          _host({
            'shapes': [_bar],
            'fill': '#00000000',
            'backdrop': {'blur': 12},
          }),
        );
        final clips = tester.layers.whereType<ClipPathLayer>().toList();
        expect(clips, hasLength(1));
        expect(clips.single.clipPath!.contains(const Offset(100, 50)), isTrue);
        expect(clips.single.clipPath!.contains(const Offset(100, 10)), isFalse);
        final backdrops = tester.layers
            .whereType<BackdropFilterLayer>()
            .toList();
        expect(backdrops, hasLength(1));
        expect(backdrops.single.parent, same(clips.single));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('backdrop blur 0·잘못된 값이면 layer를 두지 않는다', (tester) async {
      for (final backdrop in <Object?>[
        {'blur': 0},
        {'blur': double.nan},
        {'blur': 'x'},
        'x',
        null,
      ]) {
        await tester.pumpWidget(
          _host({
            'shapes': [_bar],
            'backdrop': backdrop,
          }),
        );
        expect(
          tester.layers.whereType<BackdropFilterLayer>(),
          isEmpty,
          reason: '$backdrop',
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('shape는 RepaintBoundary 안에 있다', (tester) async {
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
        }),
      );
      expect(
        find.descendant(
          of: find.byKey(_key),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('단계별 격리: shadow가 던져도 fill·rim은 칠하고 단계마다 한 번만 보고한다', (
      tester,
    ) async {
      final reported = <SduiError>[];
      EngineErrors.observer = _Capture(reported);
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
          'shadow': {'color': '#80000000', 'blur': 4},
          'rim': {'color': '#FFFFFFFF', 'width': 2},
        }),
      );
      final box = _shapeBox(tester);
      final canvas = _StageCanvas(throwOn: {#shadow});
      box.paint(_FakeContext(canvas), Offset.zero);
      box.paint(_FakeContext(canvas), Offset.zero);
      expect(reported, hasLength(1));
      expect(canvas.fills, 2);
      expect(canvas.strokes, 2);
    });

    testWidgets('단계별 격리: fill이 던져도 rim은 칠한다', (tester) async {
      final reported = <SduiError>[];
      EngineErrors.observer = _Capture(reported);
      await tester.pumpWidget(
        _host({
          'shapes': [_bar],
          'rim': {'color': '#FFFFFFFF', 'width': 2},
        }),
      );
      final box = _shapeBox(tester);
      final canvas = _StageCanvas(throwOn: {#fill});
      box.paint(_FakeContext(canvas), Offset.zero);
      box.paint(_FakeContext(canvas), Offset.zero);
      expect(reported, hasLength(1));
      expect(canvas.strokes, 2);
    });

    testWidgets('새 속성의 잘못된 값은 조용히 기본값·꺼짐으로 간다', (tester) async {
      final reported = <SduiError>[];
      EngineErrors.observer = _Capture(reported);
      for (final props in <Map<String, Object?>>[
        {
          'fill': <String, Object?>{'colors': 1},
        },
        {
          'fill': <String, Object?>{
            'colors': <Object?>['#FFFFFFFF'],
          },
        },
        {
          'rim': <String, Object?>{'width': 2, 'gradient': 'x'},
        },
        {'shadow': 'x'},
        {
          'shadow': <String, Object?>{'blur': double.infinity},
        },
        {
          'shadow': <String, Object?>{'color': 'x'},
        },
        {
          'shadow': <String, Object?>{
            'offset': <Object?>[1],
          },
        },
        {
          'backdrop': <String, Object?>{'blur': -3},
        },
      ]) {
        await tester.pumpWidget(
          _host({
            'shapes': [_bar],
            ...props,
          }),
        );
        expect(find.byKey(_key), paints..path(), reason: '$props');
      }
      expect(reported, isEmpty);
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

/// Counts the Path fallback's stages and throws in the chosen ones: `#shadow`
/// (a mask-blurred path), `#fill` (a plain fill path), `#rim` (a stroke).
class _StageCanvas extends Fake implements Canvas {
  _StageCanvas({required this.throwOn});

  final Set<Symbol> throwOn;
  int fills = 0;
  int strokes = 0;

  @override
  void drawPath(Path path, Paint paint) {
    final stage = paint.maskFilter != null
        ? #shadow
        : paint.style == PaintingStyle.stroke
        ? #rim
        : #fill;
    if (throwOn.contains(stage)) throw StateError('$stage failure');
    if (stage == #fill) fills++;
    if (stage == #rim) strokes++;
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
