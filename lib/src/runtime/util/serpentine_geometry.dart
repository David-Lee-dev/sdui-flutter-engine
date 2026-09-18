import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The stroke path enclosing a serpentine board's cells, with the arc length at
/// which each cell sits on that path.
final class SerpentineTrack {
  const SerpentineTrack({
    required this.path,
    required this.distances,
    required this.length,
  });

  final Path path;

  /// Arc length of each cell, in the order the path visits them (even rows left
  /// to right, odd rows right to left).
  final List<double> distances;

  /// Total arc length of [path].
  final double length;
}

/// Computes paths and arc-length positions for serpentine boards.
///
/// The track does **not** join cell centres. Every row's straight spans one
/// board-wide horizontal extent (`spanLeft`..`spanRight`), so the U-turns wrap
/// around the outside of the end cells and each row's line is wider than its
/// cells. A per-row extent would make the widest row stick out past the line and
/// would turn every row-to-row link into a diagonal, breaking the U-turn.
///
/// Cells are therefore points *near* the path rather than vertices *on* it, and
/// their distances come from projecting each cell onto its own row's primitives.
///
/// The path's two open ends are the exception to the shared extent: they are
/// not turns, so nothing needs them to line up with any other row. `headX` and
/// `tailX` pull the very first and very last vertex in to stop just past their
/// own row's outermost cell instead of dangling out to the shared span.
final class SerpentineGeometry {
  const SerpentineGeometry._();

  /// Builds the rounded-corner track enclosing the cells of [rows].
  ///
  /// [rows] holds each row's cell anchors in display order (left to right).
  /// [spanLeft] and [spanRight] are the shared horizontal extent of every row's
  /// straight, already including any overhang past the cells.
  ///
  /// [headX] and [tailX] override the x of the path's first and last vertex —
  /// the two ends that are not turns, so they need not sit at the shared extent.
  /// Leaving either null keeps that end at the shared extent, as before.
  ///
  /// A null [turnRadius] derives an exact semicircular U-turn from each measured
  /// row link. Explicit radii are reduced where neighbouring corners would
  /// overlap, symmetrically at both ends of a link.
  static SerpentineTrack track(
    List<List<Offset>> rows, {
    double spanLeft = 0,
    double spanRight = 0,
    double? turnRadius,
    double? headX,
    double? tailX,
  }) {
    final board = _board(rows, spanLeft, spanRight);
    final path = Path();
    if (board.vertices.isEmpty) {
      return SerpentineTrack(path: path, distances: const [], length: 0);
    }

    // 헤드/테일은 턴이 아니라 열린 끝점이므로, 다른 행과의 정렬을 신경 쓸
    // 필요 없이 이 두 정점만 자기 행 기준으로 안쪽으로 당긴다.
    if (headX != null) {
      board.vertices[0] = Offset(headX, board.vertices.first.dy);
    }
    if (tailX != null) {
      final lastIndex = board.vertices.length - 1;
      board.vertices[lastIndex] = Offset(tailX, board.vertices[lastIndex].dy);
    }

    path.moveTo(board.vertices.first.dx, board.vertices.first.dy);
    if (board.vertices.length == 1) {
      return SerpentineTrack(
        path: path,
        distances: List<double>.filled(board.cellCount, 0),
        length: 0,
      );
    }

    final built = _buildPath(path, board.vertices, board.links, turnRadius);
    return SerpentineTrack(
      path: path,
      distances: _cellDistances(board, built.primitives),
      length: built.length,
    );
  }

  /// Interpolates [distances] at a fractional [index], clamped to its ends.
  static double distanceAt(List<double> distances, num index) {
    if (distances.isEmpty) return 0;
    final clampedIndex = index.clamp(0, distances.length - 1).toDouble();
    final lowerIndex = clampedIndex.floor();
    final upperIndex = clampedIndex.ceil();
    if (lowerIndex == upperIndex) return distances[lowerIndex];
    final fraction = clampedIndex - lowerIndex;
    return distances[lowerIndex] +
        (distances[upperIndex] - distances[lowerIndex]) * fraction;
  }

  /// Turns rows of cell anchors into the two span vertices per row.
  ///
  /// Empty rows are dropped and direction alternates over the **kept** rows, so
  /// a dropped row cannot leave two consecutive rows running the same way (which
  /// would replace a U-turn with a full-width diagonal).
  static _Board _board(
    List<List<Offset>> rows,
    double spanLeft,
    double spanRight,
  ) {
    final vertices = <Offset>[];
    final cellsInPathOrder = <List<Offset>>[];
    var cellCount = 0;
    for (final row in rows) {
      if (row.isEmpty) continue;
      final goingRight = cellsInPathOrder.length.isEven;
      final y = row.first.dy;
      vertices
        ..add(Offset(goingRight ? spanLeft : spanRight, y))
        ..add(Offset(goingRight ? spanRight : spanLeft, y));
      cellsInPathOrder.add(goingRight ? row : row.reversed.toList());
      cellCount += row.length;
    }
    return _Board(
      vertices: vertices,
      cells: cellsInPathOrder,
      cellCount: cellCount,
      // Vertex pair (2j, 2j+1) is row j's straight; (2j+1, 2j+2) is the link.
      links: [
        for (var row = 1; row < cellsInPathOrder.length; row += 1)
          _Link(from: row * 2 - 1, to: row * 2),
      ],
    );
  }

  /// Emits the rounded polyline through [vertices], recording each primitive so
  /// cells can later be projected onto the piece of path they sit on.
  static _BuiltPath _buildPath(
    Path path,
    List<Offset> vertices,
    List<_Link> links,
    double? turnRadius,
  ) {
    final corners = _cornerGeometry(vertices, links, turnRadius: turnRadius);
    final primitives = <_Primitive?>[];
    var length = 0.0;
    var pathPosition = vertices.first;

    void emitLine(Offset end) {
      final distance = (end - pathPosition).distance;
      primitives.add(
        _LinePrimitive(
          start: length,
          end: length + distance,
          a: pathPosition,
          b: end,
        ),
      );
      length += distance;
      path.lineTo(end.dx, end.dy);
      pathPosition = end;
    }

    for (var index = 1; index < vertices.length - 1; index += 1) {
      final vertex = vertices[index];
      final incomingDelta = vertex - vertices[index - 1];
      final outgoingDelta = vertices[index + 1] - vertex;
      final incomingLength = incomingDelta.distance;
      final outgoingLength = outgoingDelta.distance;
      final corner = corners[index];

      if (corner.radius == 0 || incomingLength == 0 || outgoingLength == 0) {
        emitLine(vertex);
        // A degenerate corner consumes no arc, but the slot must still exist so
        // primitive indices keep matching vertex indices.
        primitives.add(null);
        continue;
      }

      final incoming = incomingDelta / incomingLength;
      final outgoing = outgoingDelta / outgoingLength;
      final arcStart = vertex - incoming * corner.trim;
      final arcEnd = vertex + outgoing * corner.trim;
      emitLine(arcStart);

      final clockwise =
          incoming.dx * outgoing.dy - incoming.dy * outgoing.dx > 0;
      final arc = _ArcPrimitive.between(
        start: length,
        from: arcStart,
        to: arcEnd,
        radius: corner.radius,
        theta: corner.theta,
        incoming: incoming,
        clockwise: clockwise,
      );
      primitives.add(arc);
      length = arc.end;
      path.arcToPoint(
        arcEnd,
        radius: Radius.circular(corner.radius),
        clockwise: clockwise,
      );
      pathPosition = arcEnd;
    }

    emitLine(vertices.last);
    return _BuiltPath(length: length, primitives: primitives);
  }

  /// Projects every cell onto its own row's primitives, in path order.
  ///
  /// The search is restricted to the row's straight and the two arcs adjoining
  /// it: with rows close together, an unrestricted search could snap a cell onto
  /// a neighbouring row and break monotonicity.
  ///
  /// A cell landing on an arc rather than the straight is the normal case, not
  /// an edge case — on the real board the row gap (~110) makes the auto turn
  /// radius (~55) larger than half a cell (~42), so both end cells sit on the
  /// U-turn.
  static List<double> _cellDistances(
    _Board board,
    List<_Primitive?> primitives,
  ) {
    final distances = <double>[];
    for (var row = 0; row < board.cells.length; row += 1) {
      // Primitives interleave line/arc/line/arc…, so line i spans vertices
      // (i, i+1) and arc i sits on vertex i.
      final candidates = <_Primitive>[
        for (final index in [row * 4 - 1, row * 4, row * 4 + 1])
          if (index >= 0 &&
              index < primitives.length &&
              primitives[index] != null)
            primitives[index]!,
      ];
      for (final cell in board.cells[row]) {
        distances.add(_project(cell, candidates));
      }
    }
    return distances;
  }

  static double _project(Offset point, List<_Primitive> candidates) {
    var best = 0.0;
    var bestDistance = double.infinity;
    for (final primitive in candidates) {
      final hit = primitive.project(point);
      if (hit.squaredDistance < bestDistance) {
        bestDistance = hit.squaredDistance;
        best = hit.arcLength;
      }
    }
    return best;
  }

  static List<_CornerGeometry> _cornerGeometry(
    List<Offset> points,
    List<_Link> links, {
    required double? turnRadius,
  }) {
    final demands = List<double>.filled(points.length, double.infinity);
    for (final link in links) {
      final linkLength = (points[link.to] - points[link.from]).distance;
      final desiredRadius = math.max(0.0, turnRadius ?? linkLength / 2);
      demands[link.from] = math.min(demands[link.from], desiredRadius);
      demands[link.to] = math.min(demands[link.to], desiredRadius);
    }

    final thetas = List<double>.filled(points.length, 0);
    final tangentHalfAngles = List<double>.filled(points.length, 0);
    final trims = List<double>.filled(points.length, 0);
    for (var index = 1; index < points.length - 1; index += 1) {
      final incomingDelta = points[index] - points[index - 1];
      final outgoingDelta = points[index + 1] - points[index];
      final incomingLength = incomingDelta.distance;
      final outgoingLength = outgoingDelta.distance;
      if (incomingLength == 0 || outgoingLength == 0) continue;

      final incoming = incomingDelta / incomingLength;
      final outgoing = outgoingDelta / outgoingLength;
      final dot = (incoming.dx * outgoing.dx + incoming.dy * outgoing.dy).clamp(
        -1.0,
        1.0,
      );
      final theta = math.acos(dot);
      thetas[index] = theta;
      if (theta == 0 || theta == math.pi) continue;

      final tangentHalfAngle = math.tan(theta / 2);
      final desiredRadius = demands[index].isFinite ? demands[index] : 0.0;
      final desiredTrim = desiredRadius * tangentHalfAngle;
      if (!tangentHalfAngle.isFinite ||
          tangentHalfAngle <= 0 ||
          !desiredTrim.isFinite ||
          desiredTrim <= 0) {
        continue;
      }

      tangentHalfAngles[index] = tangentHalfAngle;
      trims[index] = math.min(
        desiredTrim,
        math.min(incomingLength, outgoingLength),
      );
    }

    // Neighbouring corners must not eat more of a segment than it has. Clamping
    // happens in trim space, not radius space: at an obtuse turn the trim
    // (r·tan(θ/2)) exceeds the radius, so clamping the radius would let the arc
    // overrun its segment and make the arc-length bookkeeping run backwards.
    for (var index = 0; index < trims.length - 1; index += 1) {
      final sum = trims[index] + trims[index + 1];
      final segmentLength = (points[index + 1] - points[index]).distance;
      if (sum <= segmentLength || sum == 0) continue;
      final scale = segmentLength / sum;
      trims[index] *= scale;
      trims[index + 1] *= scale;
    }

    // Both ends of a link share the tighter radius, so a short row cannot make
    // one half of a U-turn wider than the other.
    for (final link in links) {
      final fromTangent = tangentHalfAngles[link.from];
      final toTangent = tangentHalfAngles[link.to];
      if (fromTangent == 0 || toTangent == 0) continue;
      final radius = math.min(
        trims[link.from] / fromTangent,
        trims[link.to] / toTangent,
      );
      trims[link.from] = radius * fromTangent;
      trims[link.to] = radius * toTangent;
    }

    return List<_CornerGeometry>.generate(points.length, (index) {
      final tangentHalfAngle = tangentHalfAngles[index];
      final trim = trims[index];
      final radius = tangentHalfAngle == 0 ? 0.0 : trim / tangentHalfAngle;
      if (!radius.isFinite || radius <= 0 || !trim.isFinite) {
        return _CornerGeometry(theta: thetas[index], trim: 0, radius: 0);
      }
      return _CornerGeometry(theta: thetas[index], trim: trim, radius: radius);
    });
  }
}

/// A point projected onto one path primitive.
typedef _Projection = ({double arcLength, double squaredDistance});

sealed class _Primitive {
  const _Primitive({required this.start, required this.end});

  /// Arc length at which this primitive begins.
  final double start;

  /// Arc length at which this primitive ends.
  final double end;

  _Projection project(Offset point);
}

final class _LinePrimitive extends _Primitive {
  const _LinePrimitive({
    required super.start,
    required super.end,
    required this.a,
    required this.b,
  });

  final Offset a;
  final Offset b;

  @override
  _Projection project(Offset point) {
    final delta = b - a;
    final lengthSquared = delta.distanceSquared;
    final t = lengthSquared == 0
        ? 0.0
        : (((point - a).dx * delta.dx + (point - a).dy * delta.dy) /
                  lengthSquared)
              .clamp(0.0, 1.0);
    final closest = a + delta * t;
    return (
      arcLength: start + (end - start) * t,
      squaredDistance: (point - closest).distanceSquared,
    );
  }
}

final class _ArcPrimitive extends _Primitive {
  const _ArcPrimitive({
    required super.start,
    required super.end,
    required this.center,
    required this.radius,
    required this.startAngle,
    required this.sweep,
  });

  /// Reconstructs the arc's centre from its endpoints and turn geometry.
  ///
  /// The centre lies on the normal of the incoming direction at [from]; the two
  /// candidate normals are tried and the one that is also [radius] away from
  /// [to] wins.
  factory _ArcPrimitive.between({
    required double start,
    required Offset from,
    required Offset to,
    required double radius,
    required double theta,
    required Offset incoming,
    required bool clockwise,
  }) {
    final normal = Offset(-incoming.dy, incoming.dx);
    final candidate = from + normal * radius;
    final other = from - normal * radius;
    final center =
        ((candidate - to).distance - radius).abs() <=
            ((other - to).distance - radius).abs()
        ? candidate
        : other;
    return _ArcPrimitive(
      start: start,
      end: start + radius * theta,
      center: center,
      radius: radius,
      startAngle: math.atan2(from.dy - center.dy, from.dx - center.dx),
      // Taken from the turn direction, not from the endpoint angles: a
      // semicircle's endpoints are π apart either way round, so the angle
      // difference alone cannot tell a clockwise U-turn from a counterclockwise
      // one — and the U-turn is this widget's main case.
      sweep: clockwise ? theta : -theta,
    );
  }

  final Offset center;
  final double radius;
  final double startAngle;
  final double sweep;

  @override
  _Projection project(Offset point) {
    final toPoint = point - center;
    if (toPoint.distanceSquared == 0) {
      return (arcLength: start, squaredDistance: radius * radius);
    }
    final angle = math.atan2(toPoint.dy, toPoint.dx);
    var delta = angle - startAngle;
    // Fold into (-π, π] first. A corner's sweep is never more than π, so a
    // straight clamp into the sweep's range then sends anything outside the arc
    // to whichever end is actually nearer.
    while (delta <= -math.pi) {
      delta += 2 * math.pi;
    }
    while (delta > math.pi) {
      delta -= 2 * math.pi;
    }
    delta = sweep >= 0 ? delta.clamp(0.0, sweep) : delta.clamp(sweep, 0.0);
    final closest =
        center +
        Offset(math.cos(startAngle + delta), math.sin(startAngle + delta)) *
            radius;
    return (
      arcLength: start + radius * delta.abs(),
      squaredDistance: (point - closest).distanceSquared,
    );
  }
}

final class _BuiltPath {
  const _BuiltPath({required this.length, required this.primitives});

  final double length;
  final List<_Primitive?> primitives;
}

final class _Board {
  const _Board({
    required this.vertices,
    required this.cells,
    required this.cellCount,
    required this.links,
  });

  /// Two span vertices per kept row, in path order.
  final List<Offset> vertices;

  /// Each kept row's cells, ordered the way the path visits them.
  final List<List<Offset>> cells;

  final int cellCount;

  /// The vertex pairs that join one row to the next.
  final List<_Link> links;
}

final class _Link {
  const _Link({required this.from, required this.to});

  final int from;
  final int to;
}

final class _CornerGeometry {
  const _CornerGeometry({
    required this.theta,
    required this.trim,
    required this.radius,
  });

  final double theta;
  final double trim;
  final double radius;
}
