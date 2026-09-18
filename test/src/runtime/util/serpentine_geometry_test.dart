import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/serpentine_geometry.dart';

void main() {
  const epsilon = 1e-3;

  group('SerpentineGeometry', () {
    group('track', () {
      test('every row spans the same extent, wider than the widest row', () {
        final board = _Boards.alternating(rowCount: 4);
        final track = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
        );
        final bounds = track.path.getBounds();

        // The bug this replaced: the line stopped at the end cells' centres, so
        // the 3-cell rows hung outside it.
        expect(bounds.left, lessThan(board.cellLeft));
        expect(bounds.right, greaterThan(board.cellRight));
      });

      test('a short row shows more line rather than turning early', () {
        final board = _Boards.alternating(rowCount: 4);
        final track = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
        );
        final bounds = track.path.getBounds();

        // Turning at each row's own cells would tilt every link into a diagonal;
        // a shared extent keeps the U-turn vertical whatever the row holds.
        expect(bounds.left, closeTo(board.spanLeft, epsilon));
        expect(bounds.right, closeTo(board.spanRight, epsilon));
      });

      test('uses auto radii to form exact semicircular turns', () {
        final board = _Boards.uniform(rowCount: 3, rowGap: 10);
        final track = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
        );
        const radius = 10 / 2;
        final straight = board.spanRight - board.spanLeft;
        // Each turn is two right-angle corners whose trims (r·tan45 = r) eat the
        // whole vertical link plus r from each adjoining straight, leaving the
        // pair as one semicircle of arc length π·r.
        final expected =
            straight * 3 - 2 * (2 * radius) + 2 * (math.pi * radius);

        expect(track.length, closeTo(expected, epsilon));
      });

      test('matches the length reported by Path metrics', () {
        final board = _Boards.uniform(rowCount: 4, rowGap: 12);
        final track = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
        );

        _isContinuous(track, epsilon: epsilon);
      });

      test('stays accurate at the board scale used by the widget', () {
        final board = _Boards.alternating(rowCount: 11);
        final track = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
        );
        final metric = track.path.computeMetrics().single;

        // Skia flattens arcs against an absolute deviation budget, so the
        // relative error is small at board scale even though it grows on tiny
        // boards.
        expect(metric.length, closeTo(track.length, track.length * 0.002));
      });

      test('an explicit radius smaller than the link rounds the corners', () {
        final board = _Boards.uniform(rowCount: 2, rowGap: 40);
        final rounded = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
          turnRadius: 5,
        );
        final semicircle = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
        );

        // A tight radius leaves a straight run between the two quarter turns,
        // which is longer than the semicircle it replaces.
        expect(rounded.length, greaterThan(semicircle.length));
      });

      test('a zero radius degenerates into sharp corners', () {
        final board = _Boards.uniform(rowCount: 2, rowGap: 40);
        final track = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
          turnRadius: 0,
        );
        final straight = board.spanRight - board.spanLeft;

        expect(track.length, closeTo(straight * 2 + 40, epsilon));
      });

      test('drops empty rows without letting two rows run the same way', () {
        final board = _Boards.uniform(rowCount: 3, rowGap: 10);
        final withGap = [board.rows[0], const <Offset>[], board.rows[1]];
        final track = SerpentineGeometry.track(
          withGap,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
        );

        // Two kept rows, so exactly one U-turn — not a full-width diagonal.
        _isContinuous(track, epsilon: epsilon);
        expect(track.distances.length, board.rows[0].length * 2);
      });

      test('an empty board yields an empty track', () {
        final track = SerpentineGeometry.track(const []);

        expect(track.length, 0);
        expect(track.distances, isEmpty);
      });

      test('headX/tailX pull only the first and last vertex inward', () {
        final board = _Boards.alternating(rowCount: 4);
        final untrimmed = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
        );
        // Both ends land on the spanLeft side here: row 0 always starts there,
        // and with an even row count (4) the last row is odd-indexed (right to
        // left), so it also ends there.
        const headX = 20.0;
        const tailX = 40.0;
        final trimmed = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
          headX: headX,
          tailX: tailX,
        );
        final bounds = trimmed.path.getBounds();

        // The path's own first/last points sit exactly at headX/tailX.
        final metric = trimmed.path.computeMetrics().single;
        expect(
          metric.getTangentForOffset(0)!.position.dx,
          closeTo(headX, epsilon),
        );
        expect(
          metric.getTangentForOffset(metric.length)!.position.dx,
          closeTo(tailX, epsilon),
        );
        // The interior turns are untouched, so the path still bulges out to the
        // shared span in the middle.
        expect(bounds.left, closeTo(board.spanLeft, epsilon));
        expect(bounds.right, closeTo(board.spanRight, epsilon));
        // Shortening the two open ends can only shorten the track.
        expect(trimmed.length, lessThan(untrimmed.length));
      });

      test('omitting headX/tailX leaves the track exactly as before', () {
        final board = _Boards.alternating(rowCount: 4);
        final withoutEnds = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
        );
        final withNullEnds = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
          headX: null,
          tailX: null,
        );

        expect(withNullEnds.length, withoutEnds.length);
      });
    });

    group('distances', () {
      test('are non-decreasing in path order', () {
        final board = _Boards.alternating(rowCount: 11);
        final track = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
        );

        for (var i = 1; i < track.distances.length; i += 1) {
          expect(
            track.distances[i],
            greaterThanOrEqualTo(track.distances[i - 1]),
            reason: 'cell $i went backwards',
          );
        }
        expect(track.distances.last, lessThanOrEqualTo(track.length));
      });

      test('place end cells on the U-turn, strictly between neighbours', () {
        // Real proportions: gap 110 makes the auto radius 55, larger than half a
        // cell (42), so both end cells sit on the arc rather than the straight.
        final board = _Boards.alternating(rowCount: 4);
        final track = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
        );

        // Cells 0..2 are row 0 left→right; cell 2 is the end cell on the turn.
        expect(track.distances[1], greaterThan(track.distances[0]));
        expect(track.distances[2], greaterThan(track.distances[1]));
        expect(track.distances[3], greaterThan(track.distances[2]));
      });

      test('follow the path order, so odd rows read right to left', () {
        final board = _Boards.uniform(rowCount: 2, rowGap: 20);
        final track = SerpentineGeometry.track(
          board.rows,
          spanLeft: board.spanLeft,
          spanRight: board.spanRight,
        );
        final perRow = board.rows.first.length;

        // Row 1's first distance belongs to its rightmost cell, so the cell the
        // path reaches first is the one furthest right on screen.
        final firstOfRow1 = track.distances[perRow];
        final lastOfRow1 = track.distances[perRow * 2 - 1];
        expect(firstOfRow1, lessThan(lastOfRow1));
      });
    });

    group('distanceAt', () {
      test('interpolates fractionally and clamps at both ends', () {
        const distances = [0.0, 10.0, 30.0];

        expect(SerpentineGeometry.distanceAt(distances, 1), 10);
        expect(SerpentineGeometry.distanceAt(distances, 1.5), 20);
        expect(SerpentineGeometry.distanceAt(distances, -3), 0);
        expect(SerpentineGeometry.distanceAt(distances, 99), 30);
        expect(SerpentineGeometry.distanceAt(const [], 0.5), 0);
      });
    });
  });
}

/// Cross-checks the analytic length against Skia's flattened measurement.
void _isContinuous(SerpentineTrack track, {required double epsilon}) {
  final metrics = track.path.computeMetrics().toList();

  expect(metrics, hasLength(1), reason: 'the track must be one contour');
  expect(
    metrics.single.length,
    closeTo(track.length, track.length * 0.02 + epsilon),
  );
}

/// A laid-out board: cell anchors plus the span the widget would derive.
final class _Board {
  const _Board({
    required this.rows,
    required this.cellLeft,
    required this.cellRight,
    required this.overhang,
  });

  final List<List<Offset>> rows;

  /// Left edge of the widest row's leftmost cell.
  final double cellLeft;

  /// Right edge of the widest row's rightmost cell.
  final double cellRight;

  final double overhang;

  double get spanLeft => cellLeft - overhang;
  double get spanRight => cellRight + overhang;
}

final class _Boards {
  const _Boards._();

  /// Rows of equal cell counts, evenly spaced.
  static _Board uniform({required int rowCount, required double rowGap}) {
    const cell = 20.0;
    const count = 3;
    return _Board(
      rows: [
        for (var row = 0; row < rowCount; row += 1)
          [
            for (var col = 0; col < count; col += 1)
              Offset(cell / 2 + col * cell * 2, row * rowGap),
          ],
      ],
      cellLeft: 0,
      cellRight: cell / 2 + (count - 1) * cell * 2 + cell / 2,
      overhang: 6,
    );
  }

  /// The real attendance shape: 3/2 rows of 84px cells on a 110px row pitch.
  static _Board alternating({required int rowCount}) {
    const cell = 84.0;
    const gap = 22.0;
    const pitch = 110.0;
    const wide = 3 * cell + 2 * gap;
    const left = 0.0;
    return _Board(
      rows: [
        for (var row = 0; row < rowCount; row += 1)
          _row(
            count: row.isEven ? 3 : 2,
            y: row * pitch,
            cell: cell,
            gap: gap,
            wide: wide,
          ),
      ],
      cellLeft: left,
      cellRight: wide,
      overhang: 6,
    );
  }

  /// Cells centred inside the widest row's extent, like `mainAxisAlignment.center`.
  static List<Offset> _row({
    required int count,
    required double y,
    required double cell,
    required double gap,
    required double wide,
  }) {
    final width = count * cell + (count - 1) * gap;
    final start = (wide - width) / 2;
    return [
      for (var col = 0; col < count; col += 1)
        Offset(start + cell / 2 + col * (cell + gap), y),
    ];
  }
}
