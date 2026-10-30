import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Primitive kinds a `shape` node can combine.
enum ShapeKind { circle, capsule, rrect }

/// How a primitive combines with everything listed before it.
///
/// [code] is the primitive's `uOp` value in `shaders/sdf_shapes.frag`.
enum ShapeOp {
  union(0),
  subtract(1),
  intersect(2);

  const ShapeOp(this.code);

  final int code;
}

/// One `shape` primitive as declared, in scaled logical units and independent
/// of the box it is painted into.
///
/// [inset] (horizontal, vertical) deflates the box and wins over [size];
/// a circle may give only [radius]. Without either the primitive fills the
/// box. [at] (fractions of the box) places the primitive's center and wins
/// over [alignment]; [inset] wins over both.
///
/// [op] combines the primitive with those listed before it (ignored on the
/// first) and [smooth] is its own blend width, `null` for the shape's
/// common one.
final class ShapePrimitive {
  const ShapePrimitive({
    required this.kind,
    required this.alignment,
    this.offset = Offset.zero,
    this.inset,
    this.size,
    this.radius,
    this.at,
    this.op = ShapeOp.union,
    this.smooth,
  });

  final ShapeKind kind;
  final Alignment alignment;
  final Offset offset;
  final Size? inset;
  final Size? size;
  final double? radius;
  final Offset? at;
  final ShapeOp op;
  final double? smooth;

  @override
  bool operator ==(Object other) =>
      other is ShapePrimitive &&
      other.kind == kind &&
      other.alignment == alignment &&
      other.offset == offset &&
      other.inset == inset &&
      other.size == size &&
      other.radius == radius &&
      other.at == at &&
      other.op == op &&
      other.smooth == smooth;

  @override
  int get hashCode =>
      Object.hash(kind, alignment, offset, inset, size, radius, at, op, smooth);
}

/// A primitive resolved into box-local coordinates: a rounded box around
/// [center] with half extents [half] and corner [radius], combined by [op]
/// with blend width [smooth] (`null` for the shape's common one).
final class ShapeBox {
  const ShapeBox({
    required this.center,
    required this.half,
    required this.radius,
    this.op = ShapeOp.union,
    this.smooth,
  });

  final Offset center;
  final Size half;
  final double radius;
  final ShapeOp op;
  final double? smooth;

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
      other.radius == radius &&
      other.op == op &&
      other.smooth == smooth;

  @override
  int get hashCode => Object.hash(center, half, radius, op, smooth);
}

/// Geometry of the `shape` widget: placement, signed distances, and the hard
/// outline fallback.
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
      if (primitive.at case final at?) {
        final extent = size ?? box;
        frame = Rect.fromCenter(
          center: Offset(at.dx * box.width, at.dy * box.height),
          width: extent.width,
          height: extent.height,
        );
      } else {
        frame = size == null
            ? Offset.zero & box
            : primitive.alignment.inscribe(size, Offset.zero & box);
      }
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
      op: primitive.op,
      smooth: primitive.smooth,
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

  /// Polynomial smooth maximum, `-smoothMin(-a, -b, k)`.
  static double smoothMax(double a, double b, double k) =>
      -smoothMin(-a, -b, k);

  /// Signed distance of [shapes] folded left in list order at [p]; infinity
  /// when [shapes] is empty.
  ///
  /// Each later shape joins by its op — union `smoothMin(d, b)`, subtract
  /// `smoothMax(d, -b)`, intersect `smoothMax(d, b)` — with its own smooth,
  /// or [k] when it has none. The first shape's op is ignored.
  static double combineDistance(Offset p, List<ShapeBox> shapes, double k) {
    if (shapes.isEmpty) return double.infinity;
    var d = roundBoxDistance(p, shapes.first);
    for (final shape in shapes.skip(1)) {
      final b = roundBoxDistance(p, shape);
      final blend = shape.smooth ?? k;
      d = switch (shape.op) {
        ShapeOp.union => smoothMin(d, b, blend),
        ShapeOp.subtract => smoothMax(d, -b, blend),
        ShapeOp.intersect => smoothMax(d, b, blend),
      };
    }
    return d;
  }

  /// The hard outline of [shapes], combined in list order by each op (smooth
  /// ignored); `null` when a path operation fails.
  static Path? hardPath(List<ShapeBox> shapes) {
    Path? outline;
    for (final shape in shapes) {
      final path = Path()
        ..addRRect(
          RRect.fromRectAndRadius(shape.rect, Radius.circular(shape.radius)),
        );
      if (outline == null) {
        outline = path;
        continue;
      }
      final operation = switch (shape.op) {
        ShapeOp.union => PathOperation.union,
        ShapeOp.subtract => PathOperation.difference,
        ShapeOp.intersect => PathOperation.intersect,
      };
      try {
        outline = Path.combine(operation, outline, path);
      } catch (_) {
        return null;
      }
    }
    return outline ?? Path();
  }
}
