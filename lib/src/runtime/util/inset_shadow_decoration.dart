import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/painting.dart';

/// A [BoxDecoration] that also paints CSS-like inset shadows.
///
/// Produced by `PropsResolver.boxDecoration` when a `box_shadow` entry has
/// `inset: true`; [boxShadow] keeps only the outer entries. Paint order is
/// outer shadows, then the color or gradient, then [insetShadows] (in list
/// order, clipped to the box shape), then the border; the child paints above
/// the decoration as usual.
///
/// Each inset shadow paints the area between the shape and a hole: the shape
/// moved by the shadow `offset` and shrunk by `spreadRadius` (its radii shrink
/// with it), blurred by `blurRadius`. `blurStyle` is ignored for inset entries.
///
/// [copyWith], [scale] and [lerpFrom]/[lerpTo] are inherited, so they return a
/// plain [BoxDecoration] without the inset shadows; the engine does not call
/// them. Consumers that only read the fields (for example `speech_balloon`)
/// do not paint inset shadows.
final class InsetShadowDecoration extends BoxDecoration {
  const InsetShadowDecoration({
    super.color,
    super.image,
    super.border,
    super.borderRadius,
    super.boxShadow,
    super.gradient,
    super.backgroundBlendMode,
    super.shape,
    required this.insetShadows,
  });

  final List<BoxShadow> insetShadows;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _InsetShadowPainter(this, onChanged);

  @override
  bool operator ==(Object other) =>
      other is InsetShadowDecoration &&
      super == other &&
      listEquals(other.insetShadows, insetShadows);

  @override
  int get hashCode => Object.hash(super.hashCode, Object.hashAll(insetShadows));
}

final class _InsetShadowPainter extends BoxPainter {
  _InsetShadowPainter(this._decoration, super.onChanged)
    : _base = BoxDecoration(
        color: _decoration.color,
        image: _decoration.image,
        borderRadius: _decoration.borderRadius,
        boxShadow: _decoration.boxShadow,
        gradient: _decoration.gradient,
        backgroundBlendMode: _decoration.backgroundBlendMode,
        shape: _decoration.shape,
      ).createBoxPainter(onChanged);

  final InsetShadowDecoration _decoration;

  /// Paints everything but the border and the inset shadows.
  final BoxPainter _base;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;
    final rect = offset & size;
    final direction = configuration.textDirection;

    _base.paint(canvas, offset, configuration);

    final shape = _decoration.shape;
    final radius = _decoration.borderRadius?.resolve(direction);
    canvas
      ..save()
      ..clipPath(_shapePath(rect, shape, radius));
    for (final shadow in _decoration.insetShadows) {
      final hole = rect.shift(shadow.offset).deflate(shadow.spreadRadius);
      final path = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(rect.inflate(shadow.blurRadius * 2 + shadow.offset.distance))
        ..addPath(
          _holePath(hole, shape, radius, shadow.spreadRadius),
          Offset.zero,
        );
      final paint = Paint()..color = shadow.color;
      if (shadow.blurSigma > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma);
      }
      canvas.drawPath(path, paint);
    }
    canvas.restore();

    _decoration.border?.paint(
      canvas,
      rect,
      shape: shape,
      borderRadius: radius,
      textDirection: direction,
    );
  }

  static Path _shapePath(Rect rect, BoxShape shape, BorderRadius? radius) =>
      switch (shape) {
        BoxShape.circle => Path()..addOval(_circle(rect)),
        BoxShape.rectangle when radius != null =>
          Path()..addRRect(radius.toRRect(rect)),
        BoxShape.rectangle => Path()..addRect(rect),
      };

  /// The shape shrunk by [spread], with radii shrunk to match (never below 0).
  static Path _holePath(
    Rect hole,
    BoxShape shape,
    BorderRadius? radius,
    double spread,
  ) {
    if (hole.isEmpty) return Path();
    if (shape == BoxShape.circle) return Path()..addOval(_circle(hole));
    if (radius == null) return Path()..addRect(hole);
    Radius shrink(Radius r) => Radius.elliptical(
      (r.x - spread).clamp(0.0, double.infinity),
      (r.y - spread).clamp(0.0, double.infinity),
    );
    return Path()..addRRect(
      RRect.fromRectAndCorners(
        hole,
        topLeft: shrink(radius.topLeft),
        topRight: shrink(radius.topRight),
        bottomLeft: shrink(radius.bottomLeft),
        bottomRight: shrink(radius.bottomRight),
      ),
    );
  }

  /// The circle BoxDecoration paints for [rect]: centered, shortest side.
  static Rect _circle(Rect rect) =>
      Rect.fromCircle(center: rect.center, radius: rect.shortestSide / 2);

  @override
  void dispose() {
    _base.dispose();
    super.dispose();
  }
}
