import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/presentation/presentation.dart';
import 'package:sdui_engine/src/presentation/skeleton_style.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/engine_presentation.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/skeleton_scope.dart';

/// Holds every run open until the test completes its gate.
class _GateDriver extends Driver {
  _GateDriver(this.gates);

  final List<Completer<void>> gates;

  @override
  String get type => 'gate';

  @override
  Future<Object?> run(DriverContext ctx) {
    final gate = Completer<void>();
    gates.add(gate);
    return gate.future.then((_) => null);
  }
}

const _canvas = ValueKey('canvas');

const _red = Color(0xFFFF0000);
const _green = Color(0xFF00FF00);
const _blue = Color(0xFF0000FF);
const _white = Color(0xFFFFFFFF);
const _defaultBase = Color(0xFF2C2C2C);
const _defaultHighlight = Color(0xFF4B4B4B);

const _bone = {'_type': 'skeleton', 'width': 200, 'height': 40, 'radius': 0};

Widget _app(Map<String, Object?> template, {bool reduceMotion = false}) =>
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: _canvas,
          child: Align(
            alignment: Alignment.topLeft,
            child: NodeBuilder.build(
              TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template)),
            ),
          ),
        ),
      ),
    );

/// A scope that loads through the gate driver and shows [skeleton] or the
/// node `_skeleton`s below meanwhile.
Map<String, Object?> _section({
  Map<String, Object?>? style,
  Map<String, Object?>? skeleton = _bone,
  List<Map<String, Object?>> children = const [
    {'_type': 'text', 'value': 'content'},
  ],
}) => {
  '_type': 'column',
  '_scope': {
    '_state': {'ready': false},
    '_action': {
      'load': {
        '_type': 'gate',
        '_then': {'_type': 'set', 'ready': true},
      },
    },
    '_lifecycle': const [
      {'on': 'mount', 'action': 'load'},
    ],
    '_skeleton': ?skeleton,
    '_skeleton_style': ?style,
  },
  '_children': children,
};

Map<String, Object?> _root(Map<String, Object?> node) => {
  ...node,
  '_requires': const ['skeleton_v2', 'skeleton_style_v1'],
};

/// A text whose node `_skeleton` is one [_bone].
const _bonedText = {'_type': 'text', 'value': 'boned', '_skeleton': _bone};

void _present(SkeletonStyle style) =>
    EnginePresentation.value = SduiPresentation(skeleton: style);

/// The color painted at [local] inside the [index]th skeleton slot.
Future<Color> _pixel(WidgetTester tester, Offset local, {int index = 0}) async {
  final at = tester.getTopLeft(find.byType(SkeletonScope).at(index)) + local;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_canvas),
  );
  final (bytes, width) = (await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final width = image.width;
    image.dispose();
    return (data!, width);
  }))!;
  final i = (at.dy.floor() * width + at.dx.floor()) * 4;
  return Color.fromARGB(
    bytes.getUint8(i + 3),
    bytes.getUint8(i),
    bytes.getUint8(i + 1),
    bytes.getUint8(i + 2),
  );
}

Matcher _near(Color expected, {int tolerance = 8}) => predicate<Color>((c) {
  int channel(double v) => (v * 255).round();
  return (channel(c.r) - channel(expected.r)).abs() <= tolerance &&
      (channel(c.g) - channel(expected.g)).abs() <= tolerance &&
      (channel(c.b) - channel(expected.b)).abs() <= tolerance;
}, 'within $tolerance of $expected');

bool _ticking(WidgetTester tester) => tester.binding.transientCallbackCount > 0;

/// The band peak of the default sweep at phase 0.5 sits here in a 200x40
/// slot: the midpoint of the topLeft → centerRight axis.
const _peak = Offset(100, 10);

void main() {
  late List<Completer<void>> gates;

  setUp(() {
    gates = [];
    DriverRegistry.register(_GateDriver(gates));
  });

  tearDown(() {
    DriverRegistry.reset();
    EnginePresentation.reset();
  });

  Future<void> openAndSettle(WidgetTester tester) async {
    for (final gate in gates) {
      if (!gate.isCompleted) gate.complete();
    }
    await tester.pumpAndSettle();
  }

  group('effects', () {
    testWidgets('default: a static base tint with no ticker', (tester) async {
      await tester.pumpWidget(_app(_root(_section())));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 375));

      expect(find.byType(ShaderMask), findsOneWidget);
      expect(await _pixel(tester, _peak), _near(_defaultBase, tolerance: 1));
      expect(_ticking(tester), isFalse);
      await openAndSettle(tester);
    });

    testWidgets('default: node skeletons tint and the shared phase stays', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(_root(_section(skeleton: null, children: const [_bonedText]))),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 375));

      expect(find.byType(ShaderMask), findsOneWidget);
      expect(await _pixel(tester, _peak), _near(_defaultBase, tolerance: 1));
      expect(_ticking(tester), isFalse);
      await openAndSettle(tester);
    });

    testWidgets('breathe: the tint goes base → highlight → base', (
      tester,
    ) async {
      _present(
        const SkeletonStyle(
          effect: SkeletonEffect.breathe,
          base: SkeletonPaint.color(_red),
          highlight: SkeletonPaint.color(_blue),
          duration: Duration(milliseconds: 1000),
        ),
      );
      await tester.pumpWidget(_app(_root(_section())));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_ticking(tester), isTrue);
      expect(await _pixel(tester, _peak), _near(_red));

      await tester.pump(const Duration(milliseconds: 500));
      expect(await _pixel(tester, _peak), _near(_blue));
      await tester.pump(const Duration(milliseconds: 250));
      expect(await _pixel(tester, _peak), _near(Color.lerp(_red, _blue, 0.5)!));
      await tester.pump(const Duration(milliseconds: 250));
      expect(await _pixel(tester, _peak), _near(_red));
      await openAndSettle(tester);
    });

    testWidgets('shimmer: the band sweeps with the given colors and period', (
      tester,
    ) async {
      _present(
        const SkeletonStyle(
          effect: SkeletonEffect.shimmer,
          base: SkeletonPaint.color(_red),
          highlight: SkeletonPaint.color(_green),
          duration: Duration(milliseconds: 1000),
        ),
      );
      await tester.pumpWidget(_app(_root(_section())));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_ticking(tester), isTrue);
      expect(await _pixel(tester, _peak), _near(_red));

      await tester.pump(const Duration(milliseconds: 500));
      expect(await _pixel(tester, _peak), _near(_green));
      await tester.pump(const Duration(milliseconds: 500));
      expect(await _pixel(tester, _peak), _near(_red));
      await openAndSettle(tester);
    });

    testWidgets('shimmer with the default colors and period is the old sweep', (
      tester,
    ) async {
      _present(const SkeletonStyle(effect: SkeletonEffect.shimmer));
      await tester.pumpWidget(_app(_root(_section())));
      await tester.pump(const Duration(milliseconds: 300));

      // Phase 0.45: the axis point of the peak sits at 0.599, between the
      // highlight stop (0.5) and the base stop (0.65).
      await tester.pump(const Duration(milliseconds: 675));
      expect(
        await _pixel(tester, _peak),
        _near(
          Color.lerp(_defaultHighlight, _defaultBase, 0.099 / 0.15)!,
          tolerance: 2,
        ),
      );
      await tester.pump(const Duration(milliseconds: 75));
      expect(
        await _pixel(tester, _peak),
        _near(_defaultHighlight, tolerance: 2),
      );
      await tester.pump(const Duration(milliseconds: 750));
      expect(await _pixel(tester, _peak), _near(_defaultBase, tolerance: 2));
      await openAndSettle(tester);
    });

    testWidgets('gradient paints: tint paints the gradient, breathe lerps it', (
      tester,
    ) async {
      _present(
        const SkeletonStyle(
          base: SkeletonPaint.gradient(LinearGradient(colors: [_red, _blue])),
          highlight: SkeletonPaint.gradient(
            LinearGradient(colors: [_green, _white]),
          ),
          duration: Duration(milliseconds: 1000),
        ),
      );
      await tester.pumpWidget(
        _app(
          _root({
            '_type': 'column',
            '_children': [
              _section(),
              _section(style: const {'effect': 'breathe'}),
            ],
          }),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // The first scope tints with the base gradient, left to right.
      expect(await _pixel(tester, const Offset(1, 20)), _near(_red));
      expect(await _pixel(tester, const Offset(199, 20)), _near(_blue));

      // The second breathes from gradient to gradient.
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        await _pixel(tester, const Offset(1, 20), index: 1),
        _near(_green),
      );
      expect(
        await _pixel(tester, const Offset(199, 20), index: 1),
        _near(_white),
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(
        await _pixel(tester, const Offset(1, 20), index: 1),
        _near(Color.lerp(_red, _green, 0.5)!),
      );
      expect(
        await _pixel(tester, const Offset(199, 20), index: 1),
        _near(Color.lerp(_blue, _white, 0.5)!),
      );
      await openAndSettle(tester);
    });

    testWidgets('a template gradient literal paints the base', (tester) async {
      await tester.pumpWidget(
        _app(
          _root(
            _section(
              style: const {
                'base': {
                  'colors': ['#FF0000', '#0000FF'],
                },
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(await _pixel(tester, const Offset(1, 20)), _near(_red));
      expect(await _pixel(tester, const Offset(199, 20)), _near(_blue));
      await openAndSettle(tester);
    });
  });

  group('reduced motion', () {
    for (final effect in [SkeletonEffect.breathe, SkeletonEffect.shimmer]) {
      testWidgets('$effect paints the base without a ticker', (tester) async {
        _present(
          SkeletonStyle(
            effect: effect,
            base: const SkeletonPaint.color(_red),
            highlight: const SkeletonPaint.color(_green),
            duration: const Duration(milliseconds: 1000),
          ),
        );
        await tester.pumpWidget(_app(_root(_section()), reduceMotion: true));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 200));

        expect(await _pixel(tester, _peak), _near(_red));
        expect(_ticking(tester), isFalse);
        await openAndSettle(tester);
      });
    }
  });

  group('template override', () {
    testWidgets('an override of the effect alone keeps the app colors', (
      tester,
    ) async {
      _present(
        const SkeletonStyle(
          base: SkeletonPaint.color(_red),
          highlight: SkeletonPaint.color(_blue),
          duration: Duration(milliseconds: 1000),
        ),
      );
      await tester.pumpWidget(
        _app(_root(_section(style: const {'effect': 'breathe'}))),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 500));
      expect(await _pixel(tester, _peak), _near(_blue));
      await tester.pump(const Duration(milliseconds: 500));
      expect(await _pixel(tester, _peak), _near(_red));
      await openAndSettle(tester);
    });

    testWidgets('the nearest scope wins; siblings keep the app style', (
      tester,
    ) async {
      _present(const SkeletonStyle(base: SkeletonPaint.color(_red)));
      await tester.pumpWidget(
        _app(
          _root({
            '_type': 'column',
            '_children': [
              _section(
                style: const {'base': '#00FF00'},
                skeleton: null,
                children: [
                  _bonedText,
                  _section(style: const {'base': '#0000FF'}),
                ],
              ),
              _section(),
            ],
          }),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SkeletonScope), findsNWidgets(3));
      const inside = Offset(100, 20);
      expect(await _pixel(tester, inside), _near(_green));
      expect(await _pixel(tester, inside, index: 1), _near(_blue));
      expect(await _pixel(tester, inside, index: 2), _near(_red));
      await openAndSettle(tester);
    });

    testWidgets('both scope and node skeletons honor the style', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _root({
            '_type': 'column',
            '_children': [
              _section(style: const {'base': '#00FF00'}),
              _section(
                style: const {'base': '#0000FF'},
                skeleton: null,
                children: const [_bonedText],
              ),
            ],
          }),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      const inside = Offset(100, 20);
      expect(await _pixel(tester, inside), _near(_green));
      expect(await _pixel(tester, inside, index: 1), _near(_blue));
      await openAndSettle(tester);
    });
  });
}
