import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/ir/model/presence_config.dart';
import 'package:sdui_engine/src/ir/model/scope_config.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/wrapper/presence.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/skeleton_scope.dart';

const _timing = PresenceConfig(
  enabled: true,
  durationMs: 1000,
  curve: 'linear',
);
const _child = SizedBox(width: 120, height: 80);

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    );

Widget _single(bool show) => PresenceGroup.single(
  childKey: show ? 'a' : null,
  config: _timing,
  child: show ? _child : null,
);

RenderBox _slot(WidgetTester tester) => tester.allRenderObjects
    .whereType<RenderBox>()
    .firstWhere((r) => r.runtimeType.toString() == '_RenderPresence');

Future<void> _half(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('compiled balance card keeps width and clips only vertically', (
    tester,
  ) async {
    final template = {
      '_type': 'column',
      '_children': [
        {
          '_type': 'container',
          '_if': r'${show}',
          '_presence': {'duration': 1000, 'curve': 'linear'},
          'height': 80,
          '_child': {
            '_type': 'row',
            '_children': [
              for (final color in ['#ff0000', '#0000ff'])
                {
                  '_type': 'expanded',
                  '_child': {'_type': 'container', 'color': color},
                },
            ],
          },
        },
        {'_type': 'sizedbox', 'height': 20},
      ],
    };
    final child = NodeBuilder.build(
      TemplateCompiler.buildDirectiveTree(TemplateParser.buildUiTree(template)),
    );
    await tester.pumpWidget(
      _host(
        EngineMetrics(
          scale: 1,
          child: RepaintBoundary(
            key: const ValueKey('capture'),
            child: SizedBox(
              width: 300,
              child: Scope(
                config: const ScopeConfig(state: {'show': true}),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
    final slot = _slot(tester);
    expect(slot.size, const Size(300, 80));
    final state = tester.state<ScopeState>(find.byType(Scope).first);
    state.set('show', false);
    await tester.pump();
    await _half(tester);
    expect(slot.size, const Size(300, 40));
    expect(slot.localToGlobal(Offset.zero).dx, 0);
    final expanded = tester.renderObject<RenderBox>(find.byType(Expanded).last);
    expect(expanded.size.width, 150);
    expect(expanded.localToGlobal(Offset.zero).dx + expanded.size.width, 300);
    // A full-width vertical clip cannot truncate the right half of the card.
    expect(slot.paintBounds.right, 300);
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('capture')),
      );
      final image = await boundary.toImage();
      final data = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      final pixel = (10 * image.width + 275) * 4;
      expect(data.getUint8(pixel + 2), 255); // Blue right-hand expanded child.
      expect(data.getUint8(pixel + 3), 255); // Fully painted, not clipped away.
      image.dispose();
    });
    state.set('show', true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(slot.size.width, 300);
    await tester.pumpAndSettle();
  });

  testWidgets('horizontal viewport intrinsic sizes match layout', (
    tester,
  ) async {
    Widget scene(bool show) => _host(
      SizedBox(
        width: 300,
        height: 80,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _single(show),
        ),
      ),
    );
    await tester.pumpWidget(scene(true));
    await tester.pumpWidget(scene(false));
    await _half(tester);
    final slot = _slot(tester);
    expect(slot.getMaxIntrinsicWidth(80), 60);
    expect(slot.getMaxIntrinsicHeight(120), 80);
    expect(
      slot.getDryLayout(const BoxConstraints(maxHeight: 80)),
      const Size(60, 80),
    );
    await tester.pumpAndSettle();
  });

  final parents = <String, (Widget Function(Widget), Axis)>{
    'column': (
      (w) => Column(mainAxisSize: MainAxisSize.min, children: [w]),
      Axis.vertical,
    ),
    'row': (
      (w) => Row(mainAxisSize: MainAxisSize.min, children: [w]),
      Axis.horizontal,
    ),
    'nested padding in row': (
      (w) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Center(child: w),
          ),
        ],
      ),
      Axis.horizontal,
    ),
    'horizontal wrap': ((w) => Wrap(children: [w]), Axis.horizontal),
    'vertical wrap': (
      (w) => Wrap(direction: Axis.vertical, children: [w]),
      Axis.vertical,
    ),
    'horizontal list body': (
      (w) => UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        child: SizedBox(
          height: 80,
          child: ListBody(mainAxis: Axis.horizontal, children: [w]),
        ),
      ),
      Axis.horizontal,
    ),
    'stack blocks outer row axis': (
      (w) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(children: [w]),
        ],
      ),
      Axis.vertical,
    ),
    'stack fallback': ((w) => Stack(children: [w]), Axis.vertical),
    'standalone align fallback': (
      (w) => Align(
        alignment: Alignment.topLeft,
        widthFactor: 1,
        heightFactor: 1,
        child: w,
      ),
      Axis.vertical,
    ),
    'horizontal list view': (
      (w) => SizedBox(
        width: 300,
        height: 80,
        child: ListView(scrollDirection: Axis.horizontal, children: [w]),
      ),
      Axis.horizontal,
    ),
    'horizontal single scroll': (
      (w) => SizedBox(
        width: 300,
        height: 80,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: w,
        ),
      ),
      Axis.horizontal,
    ),
    'horizontal sliver adapter': (
      (w) => SizedBox(
        width: 300,
        height: 80,
        child: CustomScrollView(
          scrollDirection: Axis.horizontal,
          slivers: [SliverToBoxAdapter(child: w)],
        ),
      ),
      Axis.horizontal,
    ),
  };
  for (final entry in parents.entries) {
    for (final direction in TextDirection.values) {
      testWidgets('${entry.key} $direction uses only its space axis', (
        tester,
      ) async {
        final (parent, axis) = entry.value;
        Widget scene(bool show) =>
            _host(parent(_single(show)), direction: direction);
        await tester.pumpWidget(scene(true));
        await tester.pumpWidget(scene(false));
        await _half(tester);
        expect(
          _slot(tester).size,
          axis == Axis.vertical ? const Size(120, 40) : const Size(60, 80),
        );
        await tester.pumpAndSettle();
      });
    }
  }

  for (final axis in Axis.values) {
    testWidgets('tight $axis grid keeps the allocated cell', (tester) async {
      Widget scene(bool show) => _host(
        SizedBox(
          width: 240,
          height: 160,
          child: GridView.count(
            scrollDirection: axis,
            crossAxisCount: 2,
            children: [_single(show)],
          ),
        ),
      );
      await tester.pumpWidget(scene(true));
      final before = _slot(tester).size;
      await tester.pumpWidget(scene(false));
      await _half(tester);
      expect(_slot(tester).size, before);
      await tester.pumpAndSettle();
    });

    testWidgets('explicit $axis loop axis unchanged', (tester) async {
      Widget scene(bool show) => _host(
        PresenceGroup.list(
          items: show ? [('a', _child)] : [],
          axis: axis,
          config: _timing,
          builder: (children) => Flex(
            direction: axis,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      );
      await tester.pumpWidget(scene(true));
      await tester.pumpWidget(scene(false));
      await _half(tester);
      expect(
        _slot(tester).size,
        axis == Axis.vertical ? const Size(120, 40) : const Size(60, 80),
      );
      await tester.pumpAndSettle();
    });
    testWidgets('skeleton swap in $axis retains natural size interpolation', (
      tester,
    ) async {
      final loading = ValueNotifier(true);
      await tester.pumpWidget(
        _host(
          Flex(
            direction: axis,
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonScope(
                loading: loading,
                presence: _timing,
                grace: Duration.zero,
                skeleton: const SizedBox(width: 120, height: 80),
                child: const SizedBox(width: 60, height: 40),
              ),
            ],
          ),
        ),
      );
      loading.value = false;
      await tester.pump();
      await _half(tester);
      expect(_slot(tester).size, const Size(90, 60));
      await tester.pumpAndSettle();
      expect(_slot(tester).size, const Size(60, 40));
      await tester.pumpWidget(const SizedBox());
      loading.dispose();
    });
    testWidgets('intrinsic and dry layout agree in $axis', (tester) async {
      Widget scene(bool show) => _host(
        Flex(
          direction: axis,
          mainAxisSize: MainAxisSize.min,
          children: [_single(show)],
        ),
      );
      await tester.pumpWidget(scene(true));
      await tester.pumpWidget(scene(false));
      await _half(tester);
      final slot = _slot(tester);
      final expected = axis == Axis.vertical
          ? const Size(120, 40)
          : const Size(60, 80);
      expect(slot.getDryLayout(const BoxConstraints()), expected);
      expect(slot.getMaxIntrinsicWidth(80), expected.width);
      expect(slot.getMinIntrinsicWidth(80), expected.width);
      expect(slot.getMaxIntrinsicHeight(120), expected.height);
      expect(slot.getMinIntrinsicHeight(120), expected.height);
      await tester.pumpAndSettle();
    });
  }

  testWidgets('nested presence in a row folds horizontally', (tester) async {
    Widget scene(bool show) => _host(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PresenceGroup.single(
            childKey: 'outer',
            config: _timing,
            child: _single(show),
          ),
        ],
      ),
    );
    await tester.pumpWidget(scene(true));
    await tester.pumpWidget(scene(false));
    await _half(tester);
    final slots = tester.allRenderObjects
        .whereType<RenderBox>()
        .where((r) => r.runtimeType.toString() == '_RenderPresence')
        .toSet()
        .toList();
    expect(slots, hasLength(2));
    expect(slots.last.size, const Size(60, 80));
    expect(slots.first.size, const Size(60, 80));
    await tester.pumpAndSettle();
  });

  const sizes = {
    'a': SizedBox(width: 200, height: 80),
    'b': SizedBox(width: 120, height: 40),
    'c': SizedBox(width: 160, height: 40),
  };
  Widget column(String? key) => _host(
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PresenceGroup.single(childKey: key, config: _timing, child: sizes[key]),
      ],
    ),
  );

  testWidgets(
    'a fold interrupting a swap keeps the swap sizing until settled',
    (tester) async {
      await tester.pumpWidget(column('a'));
      await tester.pumpWidget(column('b'));
      await tester.pump(const Duration(milliseconds: 250));
      final slot = _slot(tester);
      // a at 0.75 and b at 0.25 of their natural size in both axes.
      expect(slot.size, const Size(180, 70));

      await tester.pumpWidget(column(null));
      expect(slot.size, const Size(180, 70));

      await tester.pump(const Duration(milliseconds: 100));
      // a at 0.65; b folds from 0.25 over 250 ms, now 0.15.
      expect(slot.size.width, moreOrLessEquals(200 * 0.65 + 120 * 0.15));
      expect(slot.size.height, moreOrLessEquals(80 * 0.65 + 40 * 0.15));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('a swap interrupting a fold keeps the flow axis until settled', (
    tester,
  ) async {
    await tester.pumpWidget(column('a'));
    await tester.pumpWidget(column(null));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpWidget(column('b'));
    await tester.pump(const Duration(milliseconds: 250));
    final slot = _slot(tester);
    // a folds to 0.5 and b enters to 0.25 along the column; the width stays
    // the widest child's.
    expect(slot.size, const Size(200, 80 * 0.5 + 40 * 0.25));

    await tester.pumpWidget(column('c'));
    expect(slot.size, const Size(200, 80 * 0.5 + 40 * 0.25));

    await tester.pump(const Duration(milliseconds: 100));
    // a at 0.4; b leaves from 0.25 over 250 ms, now 0.15; c enters, 0.1.
    expect(slot.size.width, 200);
    expect(slot.size.height, moreOrLessEquals(80 * 0.4 + 40 * 0.15 + 40 * 0.1));
    await tester.pumpAndSettle();
  });

  // Unbounded on both axes, so the flex hands its child the same constraints
  // in either direction.
  testWidgets('a flex direction flip moves the fold to the new axis', (
    tester,
  ) async {
    Widget scene(Axis direction, bool show) => _host(
      UnconstrainedBox(
        child: Flex(
          direction: direction,
          mainAxisSize: MainAxisSize.min,
          children: [_single(show)],
        ),
      ),
    );
    await tester.pumpWidget(scene(Axis.vertical, true));
    await tester.pumpWidget(scene(Axis.vertical, false));
    await tester.pump(const Duration(milliseconds: 250));
    final slot = _slot(tester);
    expect(slot.size, const Size(120, 60));

    await tester.pumpWidget(scene(Axis.horizontal, false));
    expect(slot.size, const Size(90, 80));
    expect(slot.getMaxIntrinsicWidth(80), 90);
    expect(slot.getMaxIntrinsicHeight(120), 80);
    await tester.pump(const Duration(milliseconds: 250));
    expect(slot.size, const Size(60, 80));
    await tester.pumpAndSettle();
  });

  // The same slot widget keeps its render object untouched by the flip, so
  // only the intrinsic query decides the size IntrinsicHeight imposes.
  testWidgets('a flex flip refreshes the axis of intrinsic sizes', (
    tester,
  ) async {
    final hidden = _single(false);
    Widget scene(Axis direction, Widget slot) => _host(
      UnconstrainedBox(
        child: Flex(
          direction: direction,
          mainAxisSize: MainAxisSize.min,
          children: [IntrinsicHeight(child: slot)],
        ),
      ),
    );
    await tester.pumpWidget(scene(Axis.vertical, _single(true)));
    await tester.pumpWidget(scene(Axis.vertical, hidden));
    await tester.pump(const Duration(milliseconds: 250));
    final slot = _slot(tester);
    expect(slot.size, const Size(120, 60));

    await tester.pumpWidget(scene(Axis.horizontal, hidden));
    expect(slot.size, const Size(90, 80));
    await tester.pumpAndSettle();
  });

  testWidgets('a slot moved from a column to a row folds horizontally', (
    tester,
  ) async {
    final key = GlobalKey();
    Widget scene(bool row, bool show) {
      final slot = PresenceGroup.single(
        key: key,
        childKey: show ? 'a' : null,
        config: _timing,
        child: show ? _child : null,
      );
      return _host(
        UnconstrainedBox(
          child: row
              ? Row(mainAxisSize: MainAxisSize.min, children: [slot])
              : Column(mainAxisSize: MainAxisSize.min, children: [slot]),
        ),
      );
    }

    await tester.pumpWidget(scene(false, true));
    await tester.pumpWidget(scene(false, false));
    await tester.pump(const Duration(milliseconds: 250));
    final slot = _slot(tester);
    expect(slot.size, const Size(120, 60));

    await tester.pumpWidget(scene(true, false));
    expect(_slot(tester), same(slot));
    expect(slot.size, const Size(90, 80));
    await tester.pump(const Duration(milliseconds: 250));
    expect(slot.size, const Size(60, 80));
    await tester.pumpAndSettle();
  });

  testWidgets('layout builder in a row folds horizontally', (tester) async {
    Widget scene(bool show) => _host(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [LayoutBuilder(builder: (_, _) => _single(show))],
      ),
    );
    await tester.pumpWidget(scene(true));
    await tester.pumpWidget(scene(false));
    await _half(tester);
    expect(_slot(tester).size, const Size(60, 80));
    await tester.pumpAndSettle();
  });
}
