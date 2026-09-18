import 'package:flutter/material.dart';

/// Stroke pattern for [StyledBoxBorder].
enum BorderLineStyle { solid, dashed, dotted }

/// A [BoxBorder] that strokes with a solid [color] or a [gradient], optionally as a
/// dashed or dotted line.
///
/// Produced by `PropsResolver.border` for the styled-border schema
/// (`{ width, color | gradient, style, dash, gap }`) whenever a plain solid color
/// border is not enough. The decoration's `border_radius` reaches [paint] as
/// `borderRadius`, so rounded dashed/gradient borders work. `dotted` renders as
/// round-capped dots; per-side styling is not supported (uniform only).
final class StyledBoxBorder extends BoxBorder {
  const StyledBoxBorder({
    required this.width,
    required this.color,
    required this.gradient,
    required this.style,
    required this.dash,
    required this.gap,
  });

  final double width;
  final Color? color;
  final Gradient? gradient;
  final BorderLineStyle style;
  final double dash;
  final double gap;

  BorderSide get _side =>
      BorderSide(color: color ?? const Color(0xFF000000), width: width);

  @override
  BorderSide get top => _side;

  @override
  BorderSide get bottom => _side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  ShapeBorder scale(double t) => StyledBoxBorder(
    width: width * t,
    color: color,
    gradient: gradient,
    style: style,
    dash: dash * t,
    gap: gap * t,
  );

  @override
  BoxBorder? add(ShapeBorder other, {bool reversed = false}) => null;

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) => null;

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) => null;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect.deflate(width));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    if (width <= 0) return;
    final strokeRect = rect.deflate(width / 2);
    final path = Path();
    if (shape == BoxShape.circle) {
      path.addOval(strokeRect);
    } else if (borderRadius != null) {
      path.addRRect(borderRadius.toRRect(strokeRect));
    } else {
      path.addRect(strokeRect);
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final shaderGradient = gradient;
    if (shaderGradient != null) {
      paint.shader = shaderGradient.createShader(rect);
    } else {
      paint.color = color ?? const Color(0xFF000000);
    }
    if (style == BorderLineStyle.solid) {
      canvas.drawPath(path, paint);
      return;
    }
    final dotted = style == BorderLineStyle.dotted;
    paint.strokeCap = dotted ? StrokeCap.round : StrokeCap.butt;
    canvas.drawPath(_dashPath(path, dotted ? width * 0.1 : dash, gap), paint);
  }
}

Path _dashPath(Path source, double on, double off) {
  final result = Path();
  if (on <= 0 || off < 0) return result;
  for (final metric in source.computeMetrics()) {
    var start = 0.0;
    while (start < metric.length) {
      final end = (start + on).clamp(0.0, metric.length);
      result.addPath(metric.extractPath(start, end), Offset.zero);
      start = end + off;
    }
  }
  return result;
}
