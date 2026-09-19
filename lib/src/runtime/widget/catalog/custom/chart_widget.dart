import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `chart` — A data-driven line, area, or bar chart.
///
/// Takes the same row list the rest of a template iterates and reads two keys
/// off each row: one for the value, one for the axis label. That keeps the
/// server payload a plain list — no chart-specific shape — so the same rows can
/// feed a chart here and a table elsewhere.
///
/// ```yaml
/// _type: chart
/// type: area
/// data: '${chart_days}'
/// value_key: amount
/// label_key: day
/// height: 140
/// line_color: { .token: color.primary }
/// selected_label: '${selected_day}'
/// ```
///
/// Props:
/// - `data` (`list`, default `[]`) — rows to plot; non-map entries are skipped.
/// - `type` (`text`, default `area`) — `area` | `line` | `bar`.
/// - `value_key` (`text`, default `value`) — row key holding the y value.
/// - `label_key` (`text`, default `label`) — row key holding the x label.
/// - `height` (`size` (scaled by EngineMetrics), default `140`) — chart height.
/// - `line_color` (`color`, default theme accent) — line/bar colour.
/// - `fill_color` (`color`, default `line_color`) — area gradient top colour.
/// - `curved` (`flag`, default `true`) — smooths the line (`area`/`line` only).
/// - `bar_width` (`number`, default `2.5`) — line thickness, or bar width in `bar`.
/// - `show_dots` (`flag`, default `false`) — draws a dot on every point.
/// - `selected_label` (any, default `null`) — highlights the row whose label
///   equals this, with a filled dot and a vertical rule.
/// - `show_x_labels` (`flag`, default `true`) — draws the bottom axis labels.
/// - `x_label_interval` (`number`, default auto) — label every Nth row.
/// - `x_label_style` (`textStyle`, default 10pt muted) — bottom axis label style.
/// - `show_y_grid` (`flag`, default `true`) — draws horizontal grid lines.
/// - `grid_color` (`color`, default 10% white) — grid line colour.
/// - `min_y` / `max_y` (`number`, default auto) — y bounds; auto pads the top 15%.
///
/// Child: none.
final class ChartWidget {
  const ChartWidget._();

  static const Color _accent = Color(0xFFEBFE5C);
  static const Color _muted = Color(0xFF838383);
  static const Color _grid = Color(0x1AFFFFFF);

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final rows = _rows(props['data']);
    final valueKey = PropsResolver.text(props['value_key']) ?? 'value';
    final labelKey = PropsResolver.text(props['label_key']) ?? 'label';
    final height = PropsResolver.size(context, props['height']) ?? 140;
    final line = PropsResolver.color(props['line_color']) ?? _accent;
    final fill = PropsResolver.color(props['fill_color']) ?? line;
    final type = PropsResolver.text(props['type']) ?? 'area';

    final values = <double>[
      for (final row in rows) PropsResolver.number(row[valueKey]) ?? 0,
    ];
    final labels = <Object?>[for (final row in rows) row[labelKey]];

    // An all-zero series would collapse to a flat line on the baseline with no
    // grid to read it against, so the axis keeps a minimum span.
    final peak = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    final maxY =
        PropsResolver.number(props['max_y']) ?? (peak <= 0 ? 1.0 : peak * 1.15);
    final minY = PropsResolver.number(props['min_y']) ?? 0;

    final selectedIndex = _selectedIndex(labels, props['selected_label']);

    return SizedBox(
      height: height,
      child: type == 'bar'
          ? BarChart(
              _barData(
                context,
                props,
                values,
                labels,
                line,
                minY,
                maxY,
                selectedIndex,
              ),
            )
          : LineChart(
              _lineData(
                context,
                props,
                values,
                labels,
                line,
                fill,
                minY,
                maxY,
                selectedIndex,
                type == 'area',
              ),
            ),
    );
  }

  /// Keeps only map rows — a malformed entry drops out instead of throwing.
  static List<Map<String, Object?>> _rows(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map)
          item.map((key, value) => MapEntry(key.toString(), value)),
    ];
  }

  /// Index of the row whose label matches [selected], compared as text so an
  /// int label and a string binding still line up.
  static int? _selectedIndex(List<Object?> labels, Object? selected) {
    if (selected == null) return null;
    final needle = selected.toString();
    for (var i = 0; i < labels.length; i++) {
      if (labels[i]?.toString() == needle) return i;
    }
    return null;
  }

  static LineChartData _lineData(
    BuildContext context,
    Map<String, Object?> props,
    List<double> values,
    List<Object?> labels,
    Color line,
    Color fill,
    double minY,
    double maxY,
    int? selectedIndex,
    bool area,
  ) {
    final curved = PropsResolver.flag(props['curved']) ?? true;
    final barWidth = PropsResolver.number(props['bar_width']) ?? 2.5;
    final showDots = PropsResolver.flag(props['show_dots']) ?? false;

    final spots = <FlSpot>[
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    return LineChartData(
      minY: minY,
      maxY: maxY,
      minX: 0,
      maxX: (values.length - 1).clamp(0, double.infinity).toDouble(),
      clipData: const FlClipData.all(),
      gridData: _grid_(context, props, minY, maxY),
      borderData: FlBorderData(show: false),
      titlesData: _titles(context, props, labels),
      lineTouchData: const LineTouchData(enabled: false),
      // A vertical rule under the selected point, so the picker's choice is
      // legible without a tooltip.
      extraLinesData: selectedIndex == null
          ? const ExtraLinesData()
          : ExtraLinesData(
              verticalLines: [
                VerticalLine(
                  x: selectedIndex.toDouble(),
                  color: line.withValues(alpha: 0.35),
                  strokeWidth: 1,
                  dashArray: const [3, 3],
                ),
              ],
            ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: curved,
          // Without this a curved series can dip below zero between two low
          // points, drawing the area under the baseline.
          preventCurveOverShooting: true,
          color: line,
          barWidth: barWidth,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: showDots || selectedIndex != null,
            checkToShowDot: (spot, _) =>
                showDots || spot.x.toInt() == selectedIndex,
            getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
              radius: spot.x.toInt() == selectedIndex ? 4 : 2.5,
              color: line,
              strokeWidth: 0,
            ),
          ),
          belowBarData: BarAreaData(
            show: area,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                fill.withValues(alpha: 0.35),
                fill.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static BarChartData _barData(
    BuildContext context,
    Map<String, Object?> props,
    List<double> values,
    List<Object?> labels,
    Color line,
    double minY,
    double maxY,
    int? selectedIndex,
  ) {
    final barWidth = PropsResolver.number(props['bar_width']) ?? 6;
    return BarChartData(
      minY: minY,
      maxY: maxY,
      gridData: _grid_(context, props, minY, maxY),
      borderData: FlBorderData(show: false),
      titlesData: _titles(context, props, labels),
      barTouchData: const BarTouchData(enabled: false),
      barGroups: [
        for (var i = 0; i < values.length; i++)
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                width: barWidth,
                // The unselected bars dim so the picked day reads first.
                color: selectedIndex == null || i == selectedIndex
                    ? line
                    : line.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(barWidth / 2),
              ),
            ],
          ),
      ],
    );
  }

  static FlGridData _grid_(
    BuildContext context,
    Map<String, Object?> props,
    double minY,
    double maxY,
  ) {
    final show = PropsResolver.flag(props['show_y_grid']) ?? true;
    final color = PropsResolver.color(props['grid_color']) ?? _grid;
    final span = maxY - minY;
    return FlGridData(
      show: show,
      drawVerticalLine: false,
      // Four bands regardless of magnitude — a fixed step would vanish on a
      // large series and crowd a small one.
      horizontalInterval: span <= 0 ? 1 : span / 4,
      getDrawingHorizontalLine: (_) => FlLine(color: color, strokeWidth: 1),
    );
  }

  static FlTitlesData _titles(
    BuildContext context,
    Map<String, Object?> props,
    List<Object?> labels,
  ) {
    final show = PropsResolver.flag(props['show_x_labels']) ?? true;
    final style =
        PropsResolver.textStyle(context, props['x_label_style']) ??
        const TextStyle(fontSize: 10, color: _muted);
    // Auto keeps roughly ten labels, so a 31-day month does not smear.
    final interval =
        PropsResolver.number(props['x_label_interval']) ??
        (labels.length <= 10 ? 1 : (labels.length / 10).ceilToDouble());

    return FlTitlesData(
      show: show,
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: show,
          reservedSize: 20,
          interval: interval,
          getTitlesWidget: (value, meta) {
            final index = value.round();
            if (index < 0 || index >= labels.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${labels[index] ?? ''}', style: style),
            );
          },
        ),
      ),
    );
  }
}
