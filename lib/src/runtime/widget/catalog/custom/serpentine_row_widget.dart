import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `serpentine_row` — Lays out one measured row of serpentine board cells.
///
/// Props:
/// - `spacing` (`size`, scaled, default `0`) — gap between adjacent cells.
/// - `alignment` (`main_axis_alignment`, default `center`) — horizontal cell
///   distribution.
/// - `cross_alignment` (`cross_axis_alignment`, default `center`) — vertical
///   cell alignment.
///
/// Children: the cells, positionally.
///
/// SDUI type: `serpentine_row`.
final class SerpentineRowWidget {
  const SerpentineRowWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return SerpentineRowRenderObjectWidget(
      spacing: PropsResolver.size(context, props['spacing']) ?? 0,
      alignment:
          PropsResolver.mainAxisAlignment(props['alignment']) ??
          MainAxisAlignment.center,
      crossAlignment:
          PropsResolver.crossAxisAlignment(props['cross_alignment']) ??
          CrossAxisAlignment.center,
      textDirection: Directionality.maybeOf(context),
      children: children,
    );
  }
}

/// Hosts the horizontal flex render object used by a `serpentine_row` node.
final class SerpentineRowRenderObjectWidget
    extends MultiChildRenderObjectWidget {
  const SerpentineRowRenderObjectWidget({
    super.key,
    required this.spacing,
    required this.alignment,
    required this.crossAlignment,
    required this.textDirection,
    required super.children,
  });

  final double spacing;
  final MainAxisAlignment alignment;
  final CrossAxisAlignment crossAlignment;
  final TextDirection? textDirection;

  @override
  RenderSerpentineRow createRenderObject(BuildContext context) {
    return RenderSerpentineRow(
      spacing: spacing,
      mainAxisAlignment: alignment,
      crossAxisAlignment: crossAlignment,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSerpentineRow renderObject,
  ) {
    renderObject
      ..spacing = spacing
      ..mainAxisAlignment = alignment
      ..crossAxisAlignment = crossAlignment
      ..textDirection = textDirection;
  }
}

/// A horizontal flex that exposes its laid-out direct child rectangles.
class RenderSerpentineRow extends RenderFlex {
  RenderSerpentineRow({
    required super.spacing,
    required super.mainAxisAlignment,
    required super.crossAxisAlignment,
    required super.textDirection,
  }) : super(direction: Axis.horizontal, mainAxisSize: MainAxisSize.max);

  List<Rect> _cellRects = const [];

  /// The laid-out rect of each cell, in this row's own coordinate space.
  List<Rect> get cellRects => _cellRects;

  @override
  void performLayout() {
    super.performLayout();
    // Cache while RenderFlex owns child-size access; the board is the row's
    // parent, not the cells' parent, so it cannot read those sizes directly.
    _cellRects = [
      for (
        RenderBox? child = firstChild;
        child != null;
        child = childAfter(child)
      )
        (child.parentData! as FlexParentData).offset & child.size,
    ];
  }
}
