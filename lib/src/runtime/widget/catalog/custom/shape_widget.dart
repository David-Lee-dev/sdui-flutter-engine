import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../../../compile/schema/builtin_language.dart';
import '../../../engine_errors.dart';
import '../../../log/engine_log.dart';
import '../../../media/shader_registry.dart';
import '../../../util/props_resolver.dart';
import '../../../util/shape_geometry.dart';

/// `shape` — Paints circles, capsules and rounded rects folded together by
/// smooth union, subtract and intersect.
///
/// Decorative only: no children, no hit testing, no semantics. The shape
/// fills its parent's constraints; an unbounded axis collapses to `0`.
///
/// Props:
/// - `shapes` (`List`, 1–8 items, default empty) — primitives, each a map:
///   `kind` (`circle` | `capsule` | `rrect`), `op` (`union` | `subtract` |
///   `intersect`, default `union`; ignored on the first item), `smooth`
///   (`number`, scaled, clamped 0–64, default the shape's `smooth`), `at`
///   (`[fx, fy]` fractions of the box placing the center; wins over
///   `align`), `align` (`alignment`, default `center`), `offset` (`[x, y]`,
///   scaled, default `[0, 0]`), `inset` (`[h, v]`, scaled; wins over size,
///   `at` and `align`) or `width`/`height` (`size`), and `radius` (`size`; a
///   circle's radius, an rrect's corner). Items fold left in list order.
///   Items past the eighth are ignored. An item with an invalid value keeps
///   its last valid form, or is left out until it has one.
/// - `smooth` (`number`, scaled, clamped 0–64, default `0`) — common blend
///   width; `0` is a hard combination.
/// - `fill` (`color` or gradient map, default black) — fill.
/// - `rim` (`Map`, default none) — edge stroke: `color` (`color`, default
///   transparent) or `gradient` (gradient map), and `width` (`size`, clamped
///   0–16, default `0`).
/// - `shadow` (`Map`, default none) — `color` (`color`, default
///   `#40000000`), `blur` (sigma, clamped 0–40, default `0`), `offset`
///   (`[x, y]`, scaled, default `[0, 0]`).
/// - `backdrop` (`Map`, default none) — `blur` (sigma, clamped 0–40) blurs
///   what is behind the hard outline.
///
/// Paints shadow, backdrop, fill, then rim. Each stage is isolated: an
/// invalid value turns only that stage off, and a paint failure is reported
/// once and turns only that stage off.
///
/// The smooth combination needs the engine shader, which `Sdui.initialize`
/// starts loading; until it is loaded, or where it cannot load, the shape
/// paints the hard outline of the same primitives.
///
/// SDUI type: `shape`.
final class ShapeWidget {
  const ShapeWidget._();

  /// Most primitives one `shape` combines; the shader has one slot per item.
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
    shadow: props['shadow'],
    backdrop: props['backdrop'],
  );
}

/// A resolved `shadow`: [blur] is a sigma, [offset] is scaled.
typedef _ShapeShadow = ({Color color, double blur, Offset offset});

class _Shape extends StatefulWidget {
  const _Shape({
    required this.shapes,
    required this.smooth,
    required this.fill,
    required this.rim,
    required this.shadow,
    required this.backdrop,
  });

  final Object? shapes;
  final Object? smooth;
  final Object? fill;
  final Object? rim;
  final Object? shadow;
  final Object? backdrop;

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
    final scale = PropsResolver.scaleOf(context);
    final backdrop = widget.backdrop is Map ? widget.backdrop! as Map : null;
    // The shape repaints every frame while a bound value animates; the
    // boundary keeps that repaint off its siblings.
    return RepaintBoundary(
      child: _ShapeRender(
        primitives: _primitives(context),
        smooth: (_clamped(widget.smooth, 'smooth') ?? 0) * scale,
        fill: PropsResolver.color(widget.fill) ?? const Color(0xFF000000),
        fillGradient: PropsResolver.gradient(widget.fill),
        rimColor: PropsResolver.color(rim['color']) ?? const Color(0x00000000),
        rimGradient: PropsResolver.gradient(rim['gradient']),
        rimWidth: (_clamped(rim['width'], 'rim.width') ?? 0) * scale,
        shadow: _shadow(context, widget.shadow),
        backdropBlur: _clamped(backdrop?['blur'], 'backdrop.blur') ?? 0,
        program: ShaderRegistry.sdfShapes.value,
      ),
    );
  }

  /// [raw] as a number clamped to the `shape` range [key], or `null`.
  static double? _clamped(Object? raw, String key) {
    final range = BuiltinLanguage.shapeRanges[key]!;
    return PropsResolver.number(raw)?.clamp(range.min, range.max).toDouble();
  }

  /// Decodes `shadow`, or returns `null` when it is absent or any present
  /// value is invalid.
  static _ShapeShadow? _shadow(BuildContext context, Object? raw) {
    if (raw is! Map) return null;
    final color = raw['color'] == null
        ? const Color(0x40000000)
        : PropsResolver.color(raw['color']);
    final blur = raw['blur'] == null
        ? 0.0
        : _clamped(raw['blur'], 'shadow.blur');
    final offset = raw['offset'] == null
        ? Offset.zero
        : _pair(raw['offset'], (v) => PropsResolver.offset(context, v));
    if (color == null || blur == null || offset == null) return null;
    return (color: color, blur: blur, offset: offset);
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
    final op = switch (raw['op']) {
      null || 'union' => ShapeOp.union,
      'subtract' => ShapeOp.subtract,
      'intersect' => ShapeOp.intersect,
      _ => null,
    };
    if (op == null) return null;

    final alignment = raw['align'] == null
        ? Alignment.center
        : PropsResolver.alignment(raw['align']);
    final offset = raw['offset'] == null
        ? Offset.zero
        : _pair(raw['offset'], (v) => PropsResolver.offset(context, v));
    final at = raw['at'] == null
        ? null
        : _pair(raw['at'], PropsResolver.number);
    final smooth = _clamped(raw['smooth'], 'smooth');
    final inset = raw['inset'] == null
        ? null
        : _pair(raw['inset'], (v) => PropsResolver.size(context, v));
    final width = PropsResolver.size(context, raw['width']);
    final height = PropsResolver.size(context, raw['height']);
    final radius = PropsResolver.size(context, raw['radius']);
    final invalid =
        alignment == null ||
        offset == null ||
        (raw['at'] != null && at == null) ||
        (raw['smooth'] != null && smooth == null) ||
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
      at: at,
      op: op,
      smooth: smooth == null ? null : smooth * PropsResolver.scaleOf(context),
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
    required this.fillGradient,
    required this.rimColor,
    required this.rimGradient,
    required this.rimWidth,
    required this.shadow,
    required this.backdropBlur,
    required this.program,
  });

  final List<ShapePrimitive> primitives;
  final double smooth;
  final Color fill;
  final Gradient? fillGradient;
  final Color rimColor;
  final Gradient? rimGradient;
  final double rimWidth;
  final _ShapeShadow? shadow;
  final double backdropBlur;
  final ui.FragmentProgram? program;

  @override
  _RenderShape createRenderObject(BuildContext context) =>
      _RenderShape().._assign(this);

  @override
  void updateRenderObject(BuildContext context, _RenderShape renderObject) =>
      renderObject._assign(this);
}

/// Fills the incoming constraints and paints each stage inside its own
/// guard.
class _RenderShape extends RenderBox {
  void _assign(_ShapeRender widget) {
    primitives = widget.primitives;
    smooth = widget.smooth;
    fill = widget.fill;
    fillGradient = widget.fillGradient;
    rimColor = widget.rimColor;
    rimGradient = widget.rimGradient;
    rimWidth = widget.rimWidth;
    shadow = widget.shadow;
    backdropBlur = widget.backdropBlur;
    program = widget.program;
  }

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

  Gradient? _fillGradient;
  set fillGradient(Gradient? value) =>
      _setPaint(_fillGradient, value, (v) => _fillGradient = v);

  Color _rimColor = const Color(0x00000000);
  set rimColor(Color value) =>
      _setPaint(_rimColor, value, (v) => _rimColor = v);

  Gradient? _rimGradient;
  set rimGradient(Gradient? value) =>
      _setPaint(_rimGradient, value, (v) => _rimGradient = v);

  double _rimWidth = 0;
  set rimWidth(double value) =>
      _setPaint(_rimWidth, value, (v) => _rimWidth = v);

  _ShapeShadow? _shadow;
  set shadow(_ShapeShadow? value) =>
      _setPaint(_shadow, value, (v) => _shadow = v);

  double _backdropBlur = 0;
  set backdropBlur(double value) {
    if (value == _backdropBlur) return;
    final composited = (value > 0) != (_backdropBlur > 0);
    _backdropBlur = value;
    if (composited) markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  ui.FragmentProgram? _program;
  set program(ui.FragmentProgram? value) {
    if (identical(value, _program)) return;
    _program = value;
    _disposeShaders();
    markNeedsPaint();
  }

  // One shader per stage, so one stage's uniforms never leak into another
  // stage's draw.
  ui.FragmentShader? _shadowShader;
  ui.FragmentShader? _fillShader;
  ui.FragmentShader? _rimShader;

  final _clipLayer = LayerHandle<ClipPathLayer>();
  final _backdropLayer = LayerHandle<BackdropFilterLayer>();

  // Each stage breaks on its own; EngineErrors.isolate is sticky per owner.
  final _shadowStage = Object();
  final _backdropStage = Object();
  final _fillStage = Object();
  final _rimStage = Object();

  bool _warnedUnbounded = false;

  void _setPaint<T>(T current, T next, void Function(T) assign) {
    if (current == next) return;
    assign(next);
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  bool get alwaysNeedsCompositing => _backdropBlur > 0;

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
    if (_primitives.isEmpty || size.isEmpty) {
      _dropBackdrop();
      return;
    }
    final boxes = [
      for (final primitive in _primitives)
        ShapeGeometry.resolve(primitive, size),
    ];
    // The hard outline serves the Path fallback and the backdrop clip.
    Path? outline;
    var outlined = false;
    Path? hard() {
      if (!outlined) {
        outlined = true;
        outline = ShapeGeometry.hardPath(boxes);
      }
      return outline;
    }

    if (_shadow case final shadow?) {
      _stage(
        _shadowStage,
        () => _paintShadow(context, offset, shadow, boxes, hard),
      );
    }
    if (_backdropBlur > 0) {
      _stage(_backdropStage, () => _pushBackdrop(context, offset, hard()));
    } else {
      _dropBackdrop();
    }
    _stage(_fillStage, () => _paintFill(context, offset, boxes, hard));
    if (_rimWidth > 0) {
      _stage(_rimStage, () => _paintRim(context, offset, boxes, hard));
    }
  }

  static void _stage(Object owner, void Function() paint) =>
      EngineErrors.isolate(owner, null, paint, fallback: null);

  void _paintShadow(
    PaintingContext context,
    Offset offset,
    _ShapeShadow shadow,
    List<ShapeBox> boxes,
    Path? Function() hard,
  ) {
    _translated(context.canvas, offset + shadow.offset, (canvas) {
      final program = _program;
      if (program == null) {
        final path = hard();
        if (path == null) return;
        canvas.drawPath(
          path,
          Paint()
            ..color = shadow.color
            ..maskFilter = shadow.blur > 0
                ? MaskFilter.blur(BlurStyle.normal, shadow.blur)
                : null,
        );
        return;
      }
      final shader = _shadowShader ??= program.fragmentShader();
      void draw() => _drawCoverage(canvas, shader, boxes, shadow.color);
      if (shadow.blur <= 0) return draw();
      canvas.saveLayer(
        (Offset.zero & size).inflate(shadow.blur * 3),
        Paint()
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: shadow.blur,
            sigmaY: shadow.blur,
          ),
      );
      try {
        draw();
      } finally {
        canvas.restore();
      }
    });
  }

  /// Blurs what is behind the hard outline: a clip layer around a
  /// [BackdropFilterLayer], so the blur shows whatever the fill is.
  void _pushBackdrop(PaintingContext context, Offset offset, Path? outline) {
    if (outline == null) return _dropBackdrop();
    final backdrop = _backdropLayer.layer ??= BackdropFilterLayer();
    backdrop.filter = ui.ImageFilter.blur(
      sigmaX: _backdropBlur,
      sigmaY: _backdropBlur,
    );
    _clipLayer.layer = context.pushClipPath(
      needsCompositing,
      offset,
      Offset.zero & size,
      outline,
      (context, offset) =>
          context.pushLayer(backdrop, (context, offset) {}, offset),
      oldLayer: _clipLayer.layer,
    );
  }

  void _dropBackdrop() {
    _clipLayer.layer = null;
    _backdropLayer.layer = null;
  }

  void _paintFill(
    PaintingContext context,
    Offset offset,
    List<ShapeBox> boxes,
    Path? Function() hard,
  ) {
    _translated(context.canvas, offset, (canvas) {
      final gradient = _fillGradient;
      final program = _program;
      if (program == null) {
        final path = hard();
        if (path == null) return;
        canvas.drawPath(path, _paintOf(_fill, gradient));
        return;
      }
      final shader = _fillShader ??= program.fragmentShader();
      if (gradient == null) return _drawCoverage(canvas, shader, boxes, _fill);
      _tinted(canvas, gradient, () {
        _drawCoverage(canvas, shader, boxes, const Color(0xFFFFFFFF));
      });
    });
  }

  void _paintRim(
    PaintingContext context,
    Offset offset,
    List<ShapeBox> boxes,
    Path? Function() hard,
  ) {
    _translated(context.canvas, offset, (canvas) {
      final gradient = _rimGradient;
      final program = _program;
      if (program == null) {
        final path = hard();
        if (path == null) return;
        canvas.drawPath(
          path,
          _paintOf(_rimColor, gradient)
            ..style = PaintingStyle.stroke
            ..strokeWidth = _rimWidth,
        );
        return;
      }
      final shader = _rimShader ??= program.fragmentShader();
      if (gradient == null) {
        return _drawCoverage(canvas, shader, boxes, _rimColor, rim: true);
      }
      _tinted(canvas, gradient, () {
        _drawCoverage(
          canvas,
          shader,
          boxes,
          const Color(0xFFFFFFFF),
          rim: true,
        );
      });
    });
  }

  Paint _paintOf(Color color, Gradient? gradient) => gradient == null
      ? (Paint()..color = color)
      : (Paint()..shader = gradient.createShader(Offset.zero & size));

  /// Paints [coverage] in a layer, then [gradient] over it with
  /// [BlendMode.srcIn], so the gradient shows exactly where it covers.
  void _tinted(Canvas canvas, Gradient gradient, void Function() coverage) {
    final bounds = Offset.zero & size;
    canvas.saveLayer(bounds, Paint());
    try {
      coverage();
      canvas.drawRect(
        bounds,
        Paint()
          ..shader = gradient.createShader(bounds)
          ..blendMode = BlendMode.srcIn,
      );
    } finally {
      canvas.restore();
    }
  }

  static void _translated(
    Canvas canvas,
    Offset offset,
    void Function(Canvas canvas) paint,
  ) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    try {
      paint(canvas);
    } finally {
      canvas.restore();
    }
  }

  /// Draws the box with [shader] painting the fill coverage, or the rim
  /// coverage when [rim], tinted by [color].
  void _drawCoverage(
    Canvas canvas,
    ui.FragmentShader shader,
    List<ShapeBox> boxes,
    Color color, {
    bool rim = false,
  }) {
    var i = 0;
    void put(double v) => shader.setFloat(i++, v);
    void rgba(Color c) {
      put(c.r);
      put(c.g);
      put(c.b);
      put(c.a);
    }

    const none = Color(0x00000000);
    ShapeBox? slot(int index) => index < boxes.length ? boxes[index] : null;

    put(boxes.length.toDouble());
    put(0);
    put(_rimWidth);
    put(rim ? 1 : 0);
    rgba(rim ? none : color);
    rgba(rim ? color : none);
    for (var s = 0; s < ShapeWidget.maxShapes; s++) {
      final box = slot(s);
      put(box?.center.dx ?? 0);
      put(box?.center.dy ?? 0);
      put(box?.half.width ?? 0);
      put(box?.half.height ?? 0);
    }
    for (var s = 0; s < ShapeWidget.maxShapes; s++) {
      put(slot(s)?.radius ?? 0);
    }
    for (var s = 0; s < ShapeWidget.maxShapes; s++) {
      put((slot(s)?.op.code ?? 0).toDouble());
    }
    for (var s = 0; s < ShapeWidget.maxShapes; s++) {
      final box = slot(s);
      put(box == null ? 0 : box.smooth ?? _smooth);
    }
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  void _disposeShaders() {
    _shadowShader?.dispose();
    _fillShader?.dispose();
    _rimShader?.dispose();
    _shadowShader = null;
    _fillShader = null;
    _rimShader = null;
  }

  @override
  void dispose() {
    _disposeShaders();
    _dropBackdrop();
    super.dispose();
  }
}
