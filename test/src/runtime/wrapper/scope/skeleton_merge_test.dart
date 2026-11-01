import 'dart:async';
import 'dart:math' as math;
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
const _blue = Color(0xFF0000FF);

Widget _app(Map<String, Object?> template) => MaterialApp(
  home: Material(
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

/// A section scope that loads `ready` through the gate driver around
/// [children].
Map<String, Object?> _section(List<Map<String, Object?>> children) => {
  '_requires': const ['skeleton_v2', 'skeleton_merge_v1'],
  '_type': 'column',
  'cross_axis_alignment': 'start',
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
  },
  '_children': children,
};

/// A row of two text bones and a fixed 20x20 image under [skeleton].
Map<String, Object?> _row(Object? skeleton) => {
  '_type': 'row',
  'main_axis_size': 'min',
  'spacing': 8,
  '_skeleton': skeleton,
  '_children': const [
    {
      '_type': 'text',
      'value': r'ready ${ready}',
      'style': {'font_size': 28},
    },
    {
      '_type': 'text',
      'value': 'points',
      'style': {'font_size': 28},
    },
    {'_type': 'image', 'src': 'a.png', 'width': 20, 'height': 20},
  ],
};

final _slot = find.byType(SkeletonScope);

/// The skeleton mask, whose subtree paints every bone.
RenderObject _mask(WidgetTester tester) =>
    tester.renderObject(find.byType(ShaderMask));

/// The color painted at [local] inside the skeleton slot.
Future<Color> _pixel(WidgetTester tester, Offset local) async {
  final at = tester.getTopLeft(_slot) + local;
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

  /// Leaves while loading, so the content (and its image) never builds.
  Future<void> leave(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox());

  Future<void> openAndSettle(WidgetTester tester) async {
    for (final gate in gates) {
      if (!gate.isCompleted) gate.complete();
    }
    await tester.pumpAndSettle();
  }

  /// Pumps [template] past the grace, so the bones are painted.
  Future<void> showBones(
    WidgetTester tester,
    Map<String, Object?> template,
  ) async {
    await tester.pumpWidget(_app(template));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// The slot size of the derived (`true`) bones of [node] while loading.
  Future<Size> derivedSize(
    WidgetTester tester,
    Map<String, Object?> node,
  ) async {
    await showBones(tester, _section([node]));
    final size = tester.getSize(_slot);
    expect(
      _mask(tester),
      paints
        ..rrect()
        ..rrect()
        ..rrect(),
    );
    await leave(tester);
    return size;
  }

  testWidgets('merge paints one box the size of the derived bones', (
    tester,
  ) async {
    final derived = await derivedSize(tester, _row(true));
    // Taller than the 20 px image: the height comes from the text style.
    expect(derived.height, greaterThan(20));

    await showBones(tester, _section([_row('merge')]));
    expect(tester.getSize(_slot), derived);
    expect(_mask(tester), paintsExactlyCountTimes(#drawRRect, 1));
    expect(
      _mask(tester),
      paints..rrect(
        rrect: RRect.fromRectAndRadius(
          Offset.zero & derived,
          const Radius.circular(8),
        ),
      ),
    );
    await leave(tester);
  });

  testWidgets('a width override sets the box width, the height as derived', (
    tester,
  ) async {
    final derived = await derivedSize(tester, _row(true));

    await showBones(
      tester,
      _section([
        _row({'merge': true, 'width': 224}),
      ]),
    );
    expect(tester.getSize(_slot), Size(224, derived.height));
    expect(
      _mask(tester),
      paints..rrect(
        rrect: RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, 224, derived.height),
          const Radius.circular(8),
        ),
      ),
    );
    await leave(tester);
  });

  for (final (skeleton, label) in const [
    ({'merge': true, 'radius': 12}, 'radius 12'),
    ({'merge': true, 'shape': 'pill'}, 'pill'),
    ({'merge': true, 'shape': 'rect'}, 'rect'),
  ]) {
    testWidgets('$label rounds the box corners', (tester) async {
      await showBones(tester, _section([_row(skeleton)]));
      final size = tester.getSize(_slot);
      final radius = switch (label) {
        'radius 12' => 12.0,
        'pill' => size.height / 2,
        _ => 8.0,
      };
      expect(
        _mask(tester),
        paints..rrect(
          rrect: RRect.fromRectAndRadius(
            Offset.zero & size,
            Radius.circular(radius),
          ),
        ),
      );
      await leave(tester);
    });
  }

  testWidgets('a positioned child outside a stack does not enlarge the box', (
    tester,
  ) async {
    await showBones(
      tester,
      _section([
        {
          '_type': 'stack',
          'clip_behavior': 'none',
          '_skeleton': 'merge',
          '_children': [
            {'_type': 'container', 'width': 100, 'height': 40},
            {
              '_type': 'positioned',
              'top': -18,
              'left': 0,
              '_child': {'_type': 'text', 'value': r'balloon ${ready}'},
            },
          ],
        },
      ]),
    );
    expect(tester.getSize(_slot), const Size(100, 40));
    expect(_mask(tester), paintsExactlyCountTimes(#drawRRect, 1));
    expect(
      _mask(tester),
      paints..rrect(
        rrect: RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 100, 40),
          const Radius.circular(8),
        ),
      ),
    );
    await openAndSettle(tester);
  });

  group('skeleton style', () {
    void present(SkeletonStyle style) =>
        EnginePresentation.value = SduiPresentation(skeleton: style);

    testWidgets('tint paints the whole box, the gaps between bones too', (
      tester,
    ) async {
      present(const SkeletonStyle(base: SkeletonPaint.color(_red)));
      await showBones(tester, _section([_row('merge')]));
      final size = tester.getSize(_slot);
      // The image bone sits at the right end; the spacing gap before it
      // stays clear with derived bones but is painted by the merged box.
      final gap = Offset(size.width - 24, size.height / 2);
      expect(await _pixel(tester, gap), _near(_red));
      expect(
        await _pixel(tester, Offset(size.width / 2, size.height / 2)),
        _near(_red),
      );
      await leave(tester);
    });

    testWidgets('breathe animates the box', (tester) async {
      present(
        const SkeletonStyle(
          effect: SkeletonEffect.breathe,
          base: SkeletonPaint.color(_red),
          highlight: SkeletonPaint.color(_blue),
          duration: Duration(milliseconds: 1000),
        ),
      );
      await showBones(tester, _section([_row('merge')]));
      final size = tester.getSize(_slot);
      final gap = Offset(size.width - 24, size.height / 2);
      // The scope's shared phase runs from the mount: 0.3 after the grace.
      await tester.pump(const Duration(milliseconds: 200));
      expect(await _pixel(tester, gap), _near(_blue));
      await tester.pump(const Duration(milliseconds: 500));
      expect(await _pixel(tester, gap), _near(_red));
      await leave(tester);
    });
  });

  testWidgets('the box is inert: no hit test and no semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await showBones(tester, _section([_row('merge')]));
    final center = tester.getCenter(_slot);
    final hits = tester.hitTestOnBinding(center).path.map((e) => e.target);
    final mask = _mask(tester);
    bool below(Object target) {
      if (target is! RenderObject) return false;
      for (RenderObject? o = target; o != null; o = o.parent) {
        if (identical(o, mask)) return true;
      }
      return false;
    }

    expect(hits.where(below), isEmpty);
    expect(find.bySemanticsLabel(RegExp('points|ready')), findsNothing);
    await leave(tester);
    semantics.dispose();
  });

  testWidgets('the content replaces the box without a remount, the slot '
      'within the box and content heights', (tester) async {
    await showBones(
      tester,
      _section([
        {
          '_type': 'sizedbox',
          'width': 120,
          '_child': {
            '_type': 'column',
            'cross_axis_alignment': 'stretch',
            '_skeleton': 'merge',
            '_children': const [
              {
                '_type': 'text',
                'value': r'ready ${ready} and a long tail that wraps',
                'style': {'font_size': 20},
              },
            ],
          },
        },
      ]),
    );
    final box = tester.getSize(_slot).height;
    expect(_mask(tester), paintsExactlyCountTimes(#drawRRect, 1));
    expect(
      _mask(tester),
      paints..rrect(
        rrect: RRect.fromRectAndRadius(
          Offset.zero & tester.getSize(_slot),
          const Radius.circular(8),
        ),
      ),
    );

    for (final gate in gates) {
      gate.complete();
    }
    await tester.pump();
    await tester.pump();
    final content = find.textContaining('ready true');
    expect(content, findsOneWidget);
    final element = tester.element(content);

    final heights = <double>[];
    for (var i = 0; i < 90; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      heights.add(tester.getSize(_slot).height);
    }
    expect(find.byType(ShaderMask), findsNothing);
    expect(identical(tester.element(content), element), isTrue);
    final end = heights.last;
    expect(end, greaterThan(box));
    final limit = math.max(box, end);
    expect(
      heights.where((h) => h > limit + 0.01),
      isEmpty,
      reason: 'box $box, content $end, frames $heights',
    );
  });

  group('inside a derived _skeleton', () {
    final merged = find.byType(MergedBones);

    /// A text of [size] px that reads the section state.
    Map<String, Object?> text(String value, double size) => {
      '_type': 'text',
      'value': '$value \${ready}',
      'style': {'font_size': size},
    };

    /// A column with derived bones: a text above [node].
    Map<String, Object?> column(Map<String, Object?> node) => {
      '_type': 'column',
      'cross_axis_alignment': 'start',
      '_skeleton': true,
      '_children': [text('title', 20), node],
    };

    /// A row of two texts and a pill container under [skeleton].
    Map<String, Object?> row(Object? skeleton) => {
      '_type': 'row',
      'main_axis_size': 'min',
      'spacing': 8,
      '_skeleton': ?skeleton,
      '_children': [
        text('name', 28),
        text('live', 12),
        const {
          '_type': 'container',
          'width': 36,
          'height': 18,
          'decoration': {'color': '#FF00FF', 'border_radius': 9},
        },
      ],
    };

    /// The size of the descendant of type [widget] in the derived bones.
    Future<Size> derivedSize(
      WidgetTester tester,
      Map<String, Object?> node,
      Type widget,
    ) async {
      await showBones(tester, _section([column(node)]));
      final size = tester.getSize(
        find
            .descendant(
              of: find.byType(ShaderMask),
              matching: find.byType(widget),
            )
            .last,
      );
      await leave(tester);
      return size;
    }

    /// The rect of the merged box, local to the skeleton mask.
    Rect boxRect(WidgetTester tester) =>
        (tester.getTopLeft(merged) -
            tester.getTopLeft(find.byType(ShaderMask))) &
        tester.getSize(merged);

    testWidgets('a merged row is one box of the row size beside the bones', (
      tester,
    ) async {
      final derived = await derivedSize(tester, row(null), Row);

      await showBones(tester, _section([column(row('merge'))]));
      expect(merged, findsOneWidget);
      expect(tester.getSize(merged), derived);
      // The title bone and the merged box; the row's own bones are not.
      expect(_mask(tester), paintsExactlyCountTimes(#drawRRect, 2));
      expect(
        _mask(tester),
        paints
          ..rrect()
          ..rrect(
            rrect: RRect.fromRectAndRadius(
              boxRect(tester),
              const Radius.circular(8),
            ),
          ),
      );
      await leave(tester);
    });

    testWidgets('width and radius: the width set, the height derived', (
      tester,
    ) async {
      Map<String, Object?> timer(Object? skeleton) => {
        '_type': 'column',
        'cross_axis_alignment': 'start',
        '_skeleton': ?skeleton,
        '_children': [text('time', 28), text('left', 12)],
      };
      // Without a width the box is the derived column (as for the row).
      await showBones(
        tester,
        _section([
          column(timer({'merge': true, 'radius': 12})),
        ]),
      );
      final derived = tester.getSize(merged);
      // A 28 px text over a 12 px text.
      expect(derived.height, greaterThan(40));
      await leave(tester);

      await showBones(
        tester,
        _section([
          column(timer({'merge': true, 'width': 224, 'radius': 12})),
        ]),
      );
      expect(tester.getSize(merged), Size(224, derived.height));
      expect(
        _mask(tester),
        paints
          ..rrect()
          ..rrect(
            rrect: RRect.fromRectAndRadius(
              boxRect(tester),
              const Radius.circular(12),
            ),
          ),
      );
      await leave(tester);
    });

    testWidgets('a pill stack is the stack box, its overflowing balloon '
        'outside', (tester) async {
      await showBones(
        tester,
        _section([
          column(const {
            '_type': 'stack',
            'clip_behavior': 'none',
            '_skeleton': {'merge': true, 'shape': 'pill'},
            '_children': [
              {'_type': 'container', 'width': 100, 'height': 40},
              {
                '_type': 'positioned',
                'top': -18,
                'left': 0,
                '_child': {'_type': 'text', 'value': r'balloon ${ready}'},
              },
            ],
          }),
        ]),
      );
      expect(tester.getSize(merged), const Size(100, 40));
      expect(_mask(tester), paintsExactlyCountTimes(#drawRRect, 2));
      expect(
        _mask(tester),
        paints
          ..rrect()
          ..rrect(
            rrect: RRect.fromRectAndRadius(
              boxRect(tester),
              const Radius.circular(20),
            ),
          ),
      );
      await leave(tester);
    });

    testWidgets('the ancestor slot alone loads, tints the box and swaps once', (
      tester,
    ) async {
      EnginePresentation.value = const SduiPresentation(
        skeleton: SkeletonStyle(base: SkeletonPaint.color(_red)),
      );
      await showBones(tester, _section([column(row('merge'))]));
      expect(_slot, findsOneWidget);
      expect(gates, hasLength(1));
      final box = boxRect(tester);
      // The spacing gap after the name stays clear with derived bones but is
      // painted by the merged box.
      final at =
          tester.getTopLeft(merged) -
          tester.getTopLeft(_slot) +
          Offset(box.width - 40, box.height / 2);
      expect(await _pixel(tester, at), _near(_red));

      gates.single.complete();
      await tester.pump();
      await tester.pump();
      final content = find.textContaining('name true');
      expect(content, findsOneWidget);
      final element = tester.element(content);
      await tester.pumpAndSettle();
      expect(find.byType(ShaderMask), findsNothing);
      expect(merged, findsNothing);
      expect(identical(tester.element(content), element), isTrue);
      expect(gates, hasLength(1));
    });
  });
}
