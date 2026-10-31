import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `skeleton` — One loading-placeholder bone (a rounded box) for a `_skeleton`
/// outline.
///
/// A bone declares only its *shape*; the shimmer sweep is applied automatically
/// by the enclosing `SkeletonScope`, so authors never wire an animation per node.
/// The fill is opaque on purpose — the ancestor shimmer paints over it with a
/// `srcATOP` mask, recoloring every bone in unison while transparent gaps (the
/// surrounding layout) stay clear. That yields the modern "bones on background"
/// look from a plain outline.
///
/// ```yaml
/// _type: skeleton
/// width: 120
/// height: 16
/// shape: pill
/// ```
///
/// Props:
/// - `of` (`text`, default `null`) — `text` draws the bone of a text: as tall
///   as a text with the same `style` and `max_lines`, one bar per line, the
///   last of several lines at 60 % width.
/// - `width` (`size`, default `null`) — bone width; null lets the parent size it
///   (e.g. inside `expanded`). Ignored for `circle` (diameter = `height`). A
///   text bone without it fills the parent, or takes 80 when unbounded.
/// - `height` (`size`, default `16`) — bone height (and circle diameter).
///   Ignored for a text bone.
/// - `radius` (`size`, default `8`) — corner radius for the `rect` shape.
/// - `shape` (`text`, default `rect`) — `rect` | `circle` | `pill`.
/// - `style` (`textStyle`, default `null`) — the text style a text bone stands
///   for.
/// - `max_lines` (`integer`, default `1`) — the lines a text bone stands for.
/// - `color` (`color`, default base grey) — fill; irrelevant under the shimmer
///   mask, kept for standalone/degraded use.
///
/// Child: none.
final class SkeletonWidget {
  const SkeletonWidget._();

  /// Opaque base so the ancestor shimmer's `srcATOP` mask has pixels to recolor.
  static const Color _base = Color(0xFF2C2C2C); // surface30

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    if (PropsResolver.text(props['of']) == 'text') {
      return _textBone(context, props);
    }
    final height = PropsResolver.size(context, props['height']) ?? 16;
    final shape = PropsResolver.text(props['shape']) ?? 'rect';
    final color = PropsResolver.color(props['color']) ?? _base;
    final width = PropsResolver.size(context, props['width']);

    final (double? boxWidth, BorderRadius radius) = switch (shape) {
      'circle' => (height, BorderRadius.circular(height / 2)),
      'pill' => (width, BorderRadius.circular(height / 2)),
      _ => (
        width,
        BorderRadius.circular(
          PropsResolver.size(context, props['radius']) ?? 8,
        ),
      ),
    };

    return Container(
      width: boxWidth,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: radius),
    );
  }

  /// Lays out `max_lines` lines in the text's own resolved style and text
  /// scale, so the bone box is exactly as tall as the text, then draws one
  /// bar of about the glyph height per line.
  static Widget _textBone(BuildContext context, Map<String, Object?> props) {
    final defaults = DefaultTextStyle.of(context);
    final style = defaults.style.merge(
      PropsResolver.textStyle(context, props['style']),
    );
    final scaler = MediaQuery.textScalerOf(context);
    final lines = math.max(1, PropsResolver.integer(props['max_lines']) ?? 1);
    final painter = TextPainter(
      text: TextSpan(text: List.filled(lines, '가').join('\n'), style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      textHeightBehavior: defaults.textHeightBehavior,
      maxLines: lines,
    )..layout();
    final line = painter.height / lines;
    painter.dispose();
    final bar = math.min(line, scaler.scale(style.fontSize ?? 14) * 0.75);
    final color = PropsResolver.color(props['color']) ?? _base;

    final bars = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < lines; i++)
          SizedBox(
            height: line,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: lines > 1 && i == lines - 1 ? 0.6 : 1,
                child: Container(
                  height: bar,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(bar / 4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    final width = PropsResolver.size(context, props['width']);
    if (width != null) return SizedBox(width: width, child: bars);
    return LimitedBox(
      maxWidth: 80,
      child: SizedBox(width: double.infinity, child: bars),
    );
  }
}
