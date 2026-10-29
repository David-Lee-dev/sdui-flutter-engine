import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Primitive kinds a `shape` node can union.
enum ShapeKind { circle, capsule, rrect }

/// One `shape` primitive as declared, in scaled logical units and independent
/// of the box it is painted into.
///
/// [inset] (horizontal, vertical) deflates the box and wins over [size];
/// a circle may give only [radius]. Without either the primitive fills the
/// box.
final class ShapePrimitive {
  const ShapePrimitive({
    required this.kind,
    required this.alignment,
    this.offset = Offset.zero,
    this.inset,
    this.size,
    this.radius,
  });

  final ShapeKind kind;
  final Alignment alignment;
  final Offset offset;
  final Size? inset;
  final Size? size;
  final double? radius;

  @override
  bool operator ==(Object other) =>
      other is ShapePrimitive &&
      other.kind == kind &&
      other.alignment == alignment &&
      other.offset == offset &&
      other.inset == inset &&
      other.size == size &&
      other.radius == radius;

  @override
  int get hashCode => Object.hash(kind, alignment, offset, inset, size, radius);
}

/// A primitive resolved into box-local coordinates: a rounded box around
/// [center] with half extents [half] and corner [radius].
final class ShapeBox {
  const ShapeBox({
    required this.center,
    required this.half,
    required this.radius,
  });

  final Offset center;
  final Size half;
  final double radius;

  Rect get rect => Rect.fromCenter(
    center: center,
    width: half.width * 2,
    height: half.height * 2,
  );

  @override
  bool operator ==(Object other) =>
      other is ShapeBox &&
      other.center == center &&
      other.half == half &&
      other.radius == radius;

  @override
  int get hashCode => Object.hash(center, half, radius);
}

/// Geometry of the `shape` widget: placement, signed distances, and the hard
/// union fallback.
///
/// The distance functions use the same formulas and constants as
/// `shaders/sdf_shapes.frag`, so the Dart side describes exactly what the
/// shader paints.
final class ShapeGeometry {
  const ShapeGeometry._();

  /// Largest absolute box-local coordinate or extent a primitive may have.
  static const maxCoordinate = 16384.0;

  /// Places [primitive] inside a box of [box] size.
  ///
  /// Extents never go negative, and every coordinate is clamped to
  /// ±[maxCoordinate].
  static ShapeBox resolve(ShapePrimitive primitive, Size box) {
    final Rect frame;
    if (primitive.inset case final inset?) {
      frame = Rect.fromLTWH(
        inset.width,
        inset.height,
        math.max(0, box.width - inset.width * 2),
        math.max(0, box.height - inset.height * 2),
      );
    } else {
      final r = primitive.radius;
      final size =
          primitive.size ??
          (primitive.kind == ShapeKind.circle && r != null
              ? Size(r * 2, r * 2)
              : null);
      frame = size == null
          ? Offset.zero & box
          : primitive.alignment.inscribe(size, Offset.zero & box);
    }
    final rect = frame.shift(primitive.offset);
    final short = math.min(rect.width, rect.height);
    final (half, radius) = switch (primitive.kind) {
      ShapeKind.circle => (Size(short / 2, short / 2), short / 2),
      ShapeKind.capsule => (rect.size / 2, short / 2),
      ShapeKind.rrect => (
        rect.size / 2,
        (primitive.radius ?? 0).clamp(0, short / 2).toDouble(),
      ),
    };
    return ShapeBox(
      center: Offset(_coordinate(rect.center.dx), _coordinate(rect.center.dy)),
      half: Size(_extent(half.width), _extent(half.height)),
      radius: _extent(radius),
    );
  }

  static double _coordinate(double v) =>
      v.clamp(-maxCoordinate, maxCoordinate).toDouble();

  static double _extent(double v) => v.clamp(0, maxCoordinate).toDouble();

  /// Signed distance from [p] to [shape]: negative inside, zero on the edge.
  static double roundBoxDistance(Offset p, ShapeBox shape) {
    final r = shape.radius;
    final qx = (p.dx - shape.center.dx).abs() - shape.half.width + r;
    final qy = (p.dy - shape.center.dy).abs() - shape.half.height + r;
    final outside = math.sqrt(
      math.pow(math.max(qx, 0), 2) + math.pow(math.max(qy, 0), 2),
    );
    return outside + math.min(math.max(qx, qy), 0) - r;
  }

  /// Polynomial smooth minimum; [k] is the blend width, `0` is a hard min.
  static double smoothMin(double a, double b, double k) {
    if (k <= 0) return math.min(a, b);
    final h = math.max(k - (a - b).abs(), 0) / k;
    return math.min(a, b) - h * h * k * 0.25;
  }

  /// Smooth union of [shapes] at [p]; infinity when [shapes] is empty.
  static double unionDistance(Offset p, List<ShapeBox> shapes, double k) {
    if (shapes.isEmpty) return double.infinity;
    var d = roundBoxDistance(p, shapes.first);
    for (final shape in shapes.skip(1)) {
      d = smoothMin(d, roundBoxDistance(p, shape), k);
    }
    return d;
  }

  /// The hard union outline of [shapes].
  static Path unionPath(List<ShapeBox> shapes) {
    Path? union;
    for (final shape in shapes) {
      final path = Path()
        ..addRRect(
          RRect.fromRectAndRadius(shape.rect, Radius.circular(shape.radius)),
        );
      union = union == null
          ? path
          : Path.combine(PathOperation.union, union, path);
    }
    return union ?? Path();
  }
}
