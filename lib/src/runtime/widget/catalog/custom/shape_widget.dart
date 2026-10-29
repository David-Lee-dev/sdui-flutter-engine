import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../engine_errors.dart';
import '../../../log/engine_log.dart';
import '../../../media/shader_registry.dart';
import '../../../util/props_resolver.dart';
import '../../../util/shape_geometry.dart';

/// `shape` — Paints a smooth union of circles, capsules and rounded rects.
///
/// Decorative only: no children, no hit testing, no semantics. The shape
/// fills its parent's constraints; an unbounded axis collapses to `0`.
///
/// Props:
/// - `shapes` (`List`, 1–8 items, default empty) — primitives, each a map:
///   `kind` (`circle` | `capsule` | `rrect`), `align` (`alignment`, default
///   `center`), `offset` (`[x, y]`, scaled, default `[0, 0]`), `inset`
///   (`[h, v]`, scaled; wins over size) or `width`/`height` (`size`), and
///   `radius` (`size`; a circle's radius, an rrect's corner). Items past the
///   eighth are ignored. An item with an invalid value keeps its last valid
///   form, or is left out until it has one.
/// - `smooth` (`number`, scaled, clamped 0–64, default `0`) — blend width of
///   the union; `0` is a hard union.
/// - `fill` (`color`, default black) — fill color.
/// - `rim` (`Map`, default none) — edge stroke: `color` (`color`, default
///   transparent) and `width` (`size`, clamped 0–16, default `0`).
///
/// The smooth union needs the engine shader, which `Sdui.initialize` starts
/// loading; until it is loaded, or where it cannot load, the shape paints the
/// hard union of the same primitives.
///
/// SDUI type: `shape`.
final class ShapeWidget {
  const ShapeWidget._();

  /// Most primitives one `shape` unions; the shader has one slot per item.
  static const maxShapes = 8;

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) => _Shape(
    shapes: props['shapes'],
    smooth: props['smooth'],
    fill: props['fill'],
    rim: props['rim'],
  );
}

class _Shape extends StatefulWidget {
  const _Shape({
    required this.shapes,
    required this.smooth,
    required this.fill,
    required this.rim,
  });

  final Object? shapes;
  final Object? smooth;
  final Object? fill;
  final Object? rim;

  @override
  State<_Shape> createState() => _ShapeState();
}

class _ShapeState extends State<_Shape> {
  /// The last valid form of each primitive slot.
  final _lastGood = List<ShapePrimitive?>.filled(ShapeWidget.maxShapes, null);
  bool _warnedExtra = false;

  @override
  void initState() {
    super.initState();
    ShaderRegistry.sdfShapes.addListener(_onProgram);
  }

  void _onProgram() => setState(() {});

  @override
  void dispose() {
    ShaderRegistry.sdfShapes.removeListener(_onProgram);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rim = widget.rim is Map ? widget.rim! as Map : const {};
    final rimWidth = PropsResolver.number(rim['width'])?.clamp(0, 16) ?? 0;
    final smooth = PropsResolver.number(widget.smooth)?.clamp(0, 64) ?? 0;
    final scale = PropsResolver.scaleOf(context);
    return _ShapeRender(
      primitives: _primitives(context),
      smooth: smooth * scale,
      fill: PropsResolver.color(widget.fill) ?? const Color(0xFF000000),
      rimColor: PropsResolver.color(rim['color']) ?? const Color(0x00000000),
      rimWidth: rimWidth * scale,
      program: ShaderRegistry.sdfShapes.value,
    );
  }

  List<ShapePrimitive> _primitives(BuildContext context) {
    final raw = widget.shapes;
    if (raw is! List) return const [];
    if (raw.length > ShapeWidget.maxShapes && !_warnedExtra) {
      _warnedExtra = true;
      EngineLog.warn(
        'shape: ${raw.length} shapes given; only the first '
        '${ShapeWidget.maxShapes} are painted.',
        tag: 'widget',
      );
    }
    final primitives = <ShapePrimitive>[];
    for (var i = 0; i < raw.length && i < ShapeWidget.maxShapes; i++) {
      final parsed = _parse(context, raw[i]);
      if (parsed != null) _lastGood[i] = parsed;
      final primitive = parsed ?? _lastGood[i];
      if (primitive != null) primitives.add(primitive);
    }
    return primitives;
  }

  /// Decodes one primitive map, or returns `null` when any present value is
  /// invalid.
  static ShapePrimitive? _parse(BuildContext context, Object? raw) {
    if (raw is! Map) return null;
    final kind = switch (raw['kind']) {
      'circle' => ShapeKind.circle,
      'capsule' => ShapeKind.capsule,
      'rrect' => ShapeKind.rrect,
      _ => null,
    };
    if (kind == null) return null;

    final alignment = raw['align'] == null
        ? Alignment.center
        : PropsResolver.alignment(raw['align']);
    final offset = raw['offset'] == null
        ? Offset.zero
        : _pair(raw['offset'], (v) => PropsResolver.offset(context, v));
    final inset = raw['inset'] == null
        ? null
        : _pair(raw['inset'], (v) => PropsResolver.size(context, v));
    final width = PropsResolver.size(context, raw['width']);
    final height = PropsResolver.size(context, raw['height']);
    final radius = PropsResolver.size(context, raw['radius']);
    final invalid =
        alignment == null ||
        offset == null ||
        (raw['inset'] != null && inset == null) ||
        (raw['width'] != null && width == null) ||
        (raw['height'] != null && height == null) ||
        (raw['radius'] != null && radius == null);
    if (invalid) return null;

    // A circle needs one side; the other primitives need both or neither.
    final Size? size;
    if (width == null && height == null) {
      size = null;
    } else if (kind == ShapeKind.circle) {
      size = Size(width ?? height!, height ?? width!);
    } else if (width == null || height == null) {
      return null;
    } else {
      size = Size(width, height);
    }
    return ShapePrimitive(
      kind: kind,
      alignment: alignment,
      offset: offset,
      inset: inset == null ? null : Size(inset.dx, inset.dy),
      size: size,
      radius: radius,
    );
  }

  static Offset? _pair(Object? raw, double? Function(Object?) decode) {
    if (raw is! List || raw.length != 2) return null;
    final x = decode(raw[0]);
    final y = decode(raw[1]);
    return x == null || y == null ? null : Offset(x, y);
  }
}

class _ShapeRender extends LeafRenderObjectWidget {
  const _ShapeRender({
    required this.primitives,
    required this.smooth,
    required this.fill,
    required this.rimColor,
    required this.rimWidth,
    required this.program,
  });

  final List<ShapePrimitive> primitives;
  final double smooth;
  final Color fill;
  final Color rimColor;
  final double rimWidth;
  final ui.FragmentProgram? program;

  @override
  _RenderShape createRenderObject(BuildContext context) => _RenderShape()
    ..primitives = primitives
    ..smooth = smooth
    ..fill = fill
    ..rimColor = rimColor
    ..rimWidth = rimWidth
    ..program = program;

  @override
  void updateRenderObject(BuildContext context, _RenderShape renderObject) {
    renderObject
      ..primitives = primitives
      ..smooth = smooth
      ..fill = fill
      ..rimColor = rimColor
      ..rimWidth = rimWidth
      ..program = program;
  }
}

/// Fills the incoming constraints and paints the union inside the guard.
class _RenderShape extends RenderBox {
  List<ShapePrimitive> _primitives = const [];
  set primitives(List<ShapePrimitive> value) {
    if (listEquals(value, _primitives)) return;
    _primitives = value;
    markNeedsPaint();
  }

  double _smooth = 0;
  set smooth(double value) => _setPaint(_smooth, value, (v) => _smooth = v);

  Color _fill = const Color(0xFF000000);
  set fill(Color value) => _setPaint(_fill, value, (v) => _fill = v);

  Color _rimColor = const Color(0x00000000);
  set rimColor(Color value) =>
      _setPaint(_rimColor, value, (v) => _rimColor = v);

  double _rimWidth = 0;
  set rimWidth(double value) =>
      _setPaint(_rimWidth, value, (v) => _rimWidth = v);

  ui.FragmentProgram? _program;
  set program(ui.FragmentProgram? value) {
    if (identical(value, _program)) return;
    _program = value;
    _shader?.dispose();
    _shader = null;
    markNeedsPaint();
  }

  ui.FragmentShader? _shader;
  bool _warnedUnbounded = false;

  void _setPaint<T>(T current, T next, void Function(T) assign) {
    if (current == next) return;
    assign(next);
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => Size(
    constraints.hasBoundedWidth ? constraints.maxWidth : 0,
    constraints.hasBoundedHeight ? constraints.maxHeight : 0,
  );

  @override
  void performResize() {
    size = computeDryLayout(constraints);
    if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
      if (!_warnedUnbounded) {
        _warnedUnbounded = true;
        EngineLog.warn(
          'shape: placed on an unbounded axis; that axis is sized 0. '
          'Give the shape a bounded parent (sizedbox, positioned_fill).',
          tag: 'widget',
        );
      }
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => 0;
  @override
  double computeMaxIntrinsicWidth(double height) => 0;
  @override
  double computeMinIntrinsicHeight(double width) => 0;
  @override
  double computeMaxIntrinsicHeight(double width) => 0;

  @override
  bool hitTestSelf(Offset position) => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_primitives.isEmpty || size.isEmpty) return;
    EngineErrors.isolate(this, null, () {
      final boxes = [
        for (final primitive in _primitives)
          ShapeGeometry.resolve(primitive, size),
      ];
      final canvas = context.canvas;
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      try {
        final program = _program;
        if (program != null) {
          _paintShader(canvas, program, boxes);
        } else {
          _paintPath(canvas, boxes);
        }
      } finally {
        canvas.restore();
      }
    }, fallback: null);
  }

  void _paintShader(
    Canvas canvas,
    ui.FragmentProgram program,
    List<ShapeBox> boxes,
  ) {
    final shader = _shader ??= program.fragmentShader();
    var i = 0;
    void put(double v) => shader.setFloat(i++, v);
    void color(Color c) {
      put(c.r);
      put(c.g);
      put(c.b);
      put(c.a);
    }

    put(boxes.length.toDouble());
    put(_smooth);
    put(_rimWidth);
    put(0);
    color(_fill);
    color(_rimColor);
    for (var slot = 0; slot < ShapeWidget.maxShapes; slot++) {
      final box = slot < boxes.length ? boxes[slot] : null;
      put(box?.center.dx ?? 0);
      put(box?.center.dy ?? 0);
      put(box?.half.width ?? 0);
      put(box?.half.height ?? 0);
    }
    for (var slot = 0; slot < ShapeWidget.maxShapes; slot++) {
      put(slot < boxes.length ? boxes[slot].radius : 0);
    }
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  void _paintPath(Canvas canvas, List<ShapeBox> boxes) {
    final path = ShapeGeometry.unionPath(boxes);
    canvas.drawPath(path, Paint()..color = _fill);
    if (_rimWidth > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _rimWidth
          ..color = _rimColor,
      );
    }
  }

  @override
  void dispose() {
    _shader?.dispose();
    _shader = null;
    super.dispose();
  }
}
