import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../util/props_resolver.dart';
import '../../../util/serpentine_geometry.dart';
import 'serpentine_row_widget.dart';

/// `serpentine` — Measures rows, draws their serpentine track, then paints cells.
///
/// Props:
/// - `spacing` (`size`, scaled, default `0`) — gap between rows.
/// - `turn_radius` (`size` or `String` `auto`, scaled, default `auto`) — U-turn
///   radius; `auto` derives it from measured row links.
/// - `anchor` (`alignment`, default `center`) — point inside each cell through
///   which the track passes.
/// - `overhang` (`size`, scaled, default = the track's stroke width) — how far
///   the track extends past the widest row's cell edges, so the U-turns wrap
///   around the outside of the end cells instead of stopping at their centres.
/// - `track` (`Map`, default empty) — base track style: `color` (`color`,
///   default black), `gradient` (`gradient`, default `null`, wins over color),
///   and `width` (`size`, scaled, default `2`).
/// - `progress` (`Map`, default `null`) — completed-track style: `index`
///   (`number`, fractional, default `null`), `color` (`color`, default base
///   color), and `gradient` (`gradient`, default `null`, wins over color).
///
/// Children: one `serpentine_row` per board row.
///
/// SDUI type: `serpentine`.
final class SerpentineWidget {
  const SerpentineWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final track = props['track'];
    final trackMap = track is Map ? track : const <Object?, Object?>{};
    final progress = props['progress'];
    final progressMap = progress is Map ? progress : const <Object?, Object?>{};
    final trackGradient = PropsResolver.gradient(trackMap['gradient']);
    final trackColor =
        PropsResolver.color(trackMap['color']) ?? const Color(0xFF000000);
    final progressGradient = PropsResolver.gradient(progressMap['gradient']);
    final progressColor =
        PropsResolver.color(progressMap['color']) ?? trackColor;
    final rawRadius = props['turn_radius'];

    return SerpentineRenderObjectWidget(
      spacing: PropsResolver.size(context, props['spacing']) ?? 0,
      turnRadius: PropsResolver.isAutoRadius(rawRadius) || rawRadius == null
          ? null
          : PropsResolver.size(context, rawRadius),
      anchor: PropsResolver.alignment(props['anchor']) ?? Alignment.center,
      overhang: PropsResolver.size(context, props['overhang']),
      trackColor: trackColor,
      trackGradient: trackGradient,
      trackWidth: PropsResolver.size(context, trackMap['width']) ?? 2,
      progressIndex: PropsResolver.number(progressMap['index']),
      progressColor: progressColor,
      progressGradient: progressGradient,
      children: children,
    );
  }
}

/// Hosts the render object that owns serpentine row layout and track painting.
final class SerpentineRenderObjectWidget extends MultiChildRenderObjectWidget {
  const SerpentineRenderObjectWidget({
    super.key,
    required this.spacing,
    required this.turnRadius,
    required this.anchor,
    required this.overhang,
    required this.trackColor,
    required this.trackGradient,
    required this.trackWidth,
    required this.progressIndex,
    required this.progressColor,
    required this.progressGradient,
    required super.children,
  });

  final double spacing;
  final double? turnRadius;
  final Alignment anchor;
  final double? overhang;
  final Color trackColor;
  final Gradient? trackGradient;
  final double trackWidth;
  final double? progressIndex;
  final Color progressColor;
  final Gradient? progressGradient;

  @override
  RenderSerpentine createRenderObject(BuildContext context) {
    return RenderSerpentine(
      spacing: spacing,
      turnRadius: turnRadius,
      anchor: anchor,
      overhang: overhang,
      trackColor: trackColor,
      trackGradient: trackGradient,
      trackWidth: trackWidth,
      progressIndex: progressIndex,
      progressColor: progressColor,
      progressGradient: progressGradient,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSerpentine renderObject) {
    renderObject
      ..spacing = spacing
      ..turnRadius = turnRadius
      ..anchor = anchor
      ..overhang = overhang
      ..trackColor = trackColor
      ..trackGradient = trackGradient
      ..trackWidth = trackWidth
      ..progressIndex = progressIndex
      ..progressColor = progressColor
      ..progressGradient = progressGradient;
  }
}

/// Measures board rows and paints a path through their cell anchors.
class RenderSerpentine extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        > {
  RenderSerpentine({
    required double spacing,
    required double? turnRadius,
    required Alignment anchor,
    required double? overhang,
    required Color trackColor,
    required Gradient? trackGradient,
    required double trackWidth,
    required double? progressIndex,
    required Color progressColor,
    required Gradient? progressGradient,
  }) : _spacing = spacing,
       _turnRadius = turnRadius,
       _anchor = anchor,
       _overhang = overhang,
       _trackColor = trackColor,
       _trackGradient = trackGradient,
       _trackWidth = trackWidth,
       _progressIndex = progressIndex,
       _progressColor = progressColor,
       _progressGradient = progressGradient;

  double _spacing;
  double? _turnRadius;
  Alignment _anchor;
  double? _overhang;
  Color _trackColor;
  Gradient? _trackGradient;
  double _trackWidth;
  double? _progressIndex;
  Color _progressColor;
  Gradient? _progressGradient;
  SerpentineTrack _track = SerpentineGeometry.track(const []);
  List<List<Offset>> _cellPoints = const [];
  List<Offset> _rowOffsets = const [];
  bool _didWarnAboutNonRowChild = false;

  double get spacing => _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  double? get turnRadius => _turnRadius;
  set turnRadius(double? value) {
    if (_turnRadius == value) return;
    _turnRadius = value;
    markNeedsLayout();
  }

  Alignment get anchor => _anchor;
  set anchor(Alignment value) {
    if (_anchor == value) return;
    _anchor = value;
    markNeedsLayout();
  }

  /// Falls back to the stroke width: an overhang of zero would put the turn
  /// exactly on the cell edge, and one stroke width clears it.
  double get _resolvedOverhang => _overhang ?? _trackWidth;

  double? get overhang => _overhang;
  set overhang(double? value) {
    if (_overhang == value) return;
    _overhang = value;
    markNeedsLayout();
  }

  Color get trackColor => _trackColor;
  set trackColor(Color value) {
    if (_trackColor == value) return;
    _trackColor = value;
    markNeedsPaint();
  }

  Gradient? get trackGradient => _trackGradient;
  set trackGradient(Gradient? value) {
    if (_trackGradient == value) return;
    _trackGradient = value;
    markNeedsPaint();
  }

  double get trackWidth => _trackWidth;
  set trackWidth(double value) {
    if (_trackWidth == value) return;
    _trackWidth = value;
    markNeedsLayout();
  }

  double? get progressIndex => _progressIndex;
  set progressIndex(double? value) {
    if (_progressIndex == value) return;
    _progressIndex = value;
    markNeedsPaint();
  }

  Color get progressColor => _progressColor;
  set progressColor(Color value) {
    if (_progressColor == value) return;
    _progressColor = value;
    markNeedsPaint();
  }

  Gradient? get progressGradient => _progressGradient;
  set progressGradient(Gradient? value) {
    if (_progressGradient == value) return;
    _progressGradient = value;
    markNeedsPaint();
  }

  /// The geometry produced by the latest layout.
  @visibleForTesting
  SerpentineTrack get track => _track;

  /// The measured cell anchors produced by the latest layout.
  @visibleForTesting
  List<List<Offset>> get cellPoints => _cellPoints;

  /// The board-space offset of each row produced by the latest layout.
  @visibleForTesting
  List<Offset> get rowOffsets => _rowOffsets;

  /// The completed fraction of the analytic track, when progress is usable.
  @visibleForTesting
  double? get progressRatio {
    final index = _progressIndex;
    if (index == null || index < 0 || _track.length <= 0) return null;
    return SerpentineGeometry.distanceAt(_track.distances, index) /
        _track.length;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SerpentineParentData) {
      child.parentData = _SerpentineParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => _widestIntrinsicRow(height);

  @override
  double computeMaxIntrinsicWidth(double height) => _widestIntrinsicRow(height);

  double _widestIntrinsicRow(double height) {
    var width = 0.0;
    for (
      RenderBox? child = firstChild;
      child != null;
      child = childAfter(child)
    ) {
      width = math.max(width, child.getMaxIntrinsicWidth(height));
    }
    return width + _trackMargin * 2;
  }

  /// Horizontal room the track needs outside the cells, per side.
  ///
  /// The span reaches `overhang` past the cell edges and the stroke straddles
  /// it, so reserving exactly this much guarantees the track fits — no bounds
  /// probe and no second layout pass.
  double get _trackMargin =>
      _trackWidth <= 0 ? 0 : _resolvedOverhang + _trackWidth / 2;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final boardWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth(_widestIntrinsicRow(double.infinity));
    final rowConstraints = BoxConstraints.tightFor(
      width: math.max(0, boardWidth - _trackMargin * 2),
    );
    var height = 0.0;
    for (
      RenderBox? child = firstChild;
      child != null;
      child = childAfter(child)
    ) {
      height += child.getDryLayout(rowConstraints).height;
      if (childAfter(child) != null) height += _spacing;
    }

    return constraints.constrain(Size(boardWidth, height));
  }

  @override
  void performLayout() {
    final boardWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth(_widestIntrinsicRow(double.infinity));
    final result = _layoutRows(boardWidth, _trackMargin);

    _track = result.track;
    _cellPoints = result.cellPoints;
    _rowOffsets = result.rowOffsets;
    size = constraints.constrain(Size(boardWidth, result.height));
  }

  _LayoutResult _layoutRows(double boardWidth, double reservation) {
    final contentWidth = math.max(0.0, boardWidth - reservation * 2);
    final rowConstraints = BoxConstraints.tightFor(width: contentWidth);
    final points = <List<Offset>>[];
    final offsets = <Offset>[];
    final cellRects = <Rect>[];
    // 공유 span과 별개로 head/tail을 계산하려면 행별 rect도 필요하다. 빈 행은
    // 건너뛴다 — _board가 빈 행을 드롭하고 유지된 행들만 기준으로 좌우를
    // 번갈아 매기므로, 여기서도 같은 기준(kept index)이어야 tail이 엉뚱한
    // 쪽으로 붙지 않는다.
    final rowRects = <List<Rect>>[];
    var y = 0.0;
    for (
      RenderBox? child = firstChild;
      child != null;
      child = childAfter(child)
    ) {
      child.layout(rowConstraints, parentUsesSize: true);
      final offset = Offset(reservation, y);
      (child.parentData! as ContainerBoxParentData<RenderBox>).offset = offset;
      offsets.add(offset);

      List<Rect> rects;
      if (child is RenderSerpentineRow) {
        rects = [for (final rect in child.cellRects) rect.shift(offset)];
        points.add([for (final rect in rects) _anchor.withinRect(rect)]);
      } else {
        assert(
          _debugWarnAboutNonRowChild(child),
          'serpentine direct-child constraint requires RenderSerpentineRow.',
        );
        final rect = offset & child.size;
        rects = [rect];
        points.add([_anchor.withinRect(rect)]);
      }
      cellRects.addAll(rects);
      if (rects.isNotEmpty) rowRects.add(rects);
      y += child.size.height;
      if (childAfter(child) != null) y += _spacing;
    }
    final span = _span(cellRects, _resolvedOverhang);
    final ends = _ends(rowRects, _resolvedOverhang);
    return _LayoutResult(
      height: y,
      cellPoints: points,
      rowOffsets: offsets,
      track: SerpentineGeometry.track(
        points,
        spanLeft: span.$1,
        spanRight: span.$2,
        turnRadius: _turnRadius,
        headX: ends.$1,
        tailX: ends.$2,
      ),
    );
  }

  /// The horizontal extent every row's straight shares, in board space.
  ///
  /// Board-level, not per-row, on purpose: rows hold different cell counts, so a
  /// per-row extent would leave the widest row hanging outside its own line and
  /// would tilt every row-to-row link into a diagonal instead of a U-turn.
  static (double, double) _span(List<Rect> cellRects, double overhang) {
    if (cellRects.isEmpty) return (0, 0);
    var left = double.infinity;
    var right = -double.infinity;
    for (final rect in cellRects) {
      left = math.min(left, rect.left);
      right = math.max(right, rect.right);
    }
    return (left - overhang, right + overhang);
  }

  /// Where the path's head and tail stop, unlike every other row's straight.
  ///
  /// The head/tail are not turns, so a full-width run past them is just
  /// dangling line — worst on a short final row, where it hangs far past the
  /// last cell. Each end instead clears only its own row's outermost cell by
  /// [overhang], the same clearance the shared span already uses sideways.
  ///
  /// [rows] holds only kept (non-empty) rows, in display order, matching
  /// `SerpentineGeometry`'s own row-dropping so a dropped row cannot flip which
  /// side the tail lands on.
  static (double?, double?) _ends(List<List<Rect>> rows, double overhang) {
    if (rows.isEmpty) return (null, null);

    // Row 0 in path order always runs left to right, so its first cell is its
    // leftmost.
    var headLeft = double.infinity;
    for (final rect in rows.first) {
      headLeft = math.min(headLeft, rect.left);
    }

    final tailIndex = rows.length - 1;
    final tailRow = rows[tailIndex];
    if (tailIndex.isEven) {
      var tailRight = -double.infinity;
      for (final rect in tailRow) {
        tailRight = math.max(tailRight, rect.right);
      }
      return (headLeft - overhang, tailRight + overhang);
    }
    var tailLeft = double.infinity;
    for (final rect in tailRow) {
      tailLeft = math.min(tailLeft, rect.left);
    }
    return (headLeft - overhang, tailLeft - overhang);
  }

  bool _debugWarnAboutNonRowChild(RenderBox child) {
    if (!_didWarnAboutNonRowChild) {
      _didWarnAboutNonRowChild = true;
      debugPrint(
        'serpentine direct-child constraint: expected RenderSerpentineRow, '
        'got ${child.runtimeType}; treating it as a single-cell row. Put motion '
        'wrappers on cells instead of rows.',
      );
    }
    return true;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _paintTrack(context.canvas, offset);
    defaultPaint(context, offset);
  }

  void _paintTrack(Canvas canvas, Offset offset) {
    if (_trackWidth <= 0 || _track.length <= 0) return;
    final metrics = _track.path.computeMetrics().iterator;
    if (!metrics.moveNext()) return;
    final metric = metrics.current;
    final bounds = _track.path.getBounds().shift(offset);
    final basePaint = _strokePaint(
      bounds: bounds,
      color: _trackColor,
      gradient: _trackGradient,
    );
    canvas.drawPath(_track.path.shift(offset), basePaint);

    final ratio = progressRatio;
    if (ratio == null) return;
    // Skia's flattened metric is slightly shorter than the analytic geometry;
    // applying the analytic ratio to it cancels that systematic measurement bias.
    final completed = metric
        .extractPath(0, metric.length * ratio)
        .shift(offset);
    final progressPaint = _strokePaint(
      bounds: bounds,
      color: _progressColor,
      gradient: _progressGradient,
    );
    canvas.drawPath(completed, progressPaint);
  }

  Paint _strokePaint({
    required Rect bounds,
    required Color color,
    required Gradient? gradient,
  }) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _trackWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color
      // Both stretches use the full-track bounds so a gradient remains continuous.
      ..shader = gradient?.createShader(bounds);
  }
}

final class _SerpentineParentData extends ContainerBoxParentData<RenderBox> {}

final class _LayoutResult {
  const _LayoutResult({
    required this.height,
    required this.cellPoints,
    required this.rowOffsets,
    required this.track,
  });

  final double height;
  final List<List<Offset>> cellPoints;
  final List<Offset> rowOffsets;
  final SerpentineTrack track;
}
