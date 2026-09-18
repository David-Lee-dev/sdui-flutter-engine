import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../contract/action_sink.dart';
import '../../../util/props_resolver.dart';

/// `spin_grid` — Lays out children in a grid and cycles one highlighted cell.
///
/// The cycle owns its highlight state so the same child template can also be
/// reused by boards that do not spin.
///
/// ```yaml
/// _type: spin_grid
/// winner_index: 4
/// trigger: draw-17
/// duration: 3300
/// steps: 30
/// on_finish: reveal_prize
/// _children:
///   - { _type: text, value: Prize }
/// ```
///
/// Props:
/// - `winner_index` (`integer`, required) — child on which the cycle settles;
///   invalid indices leave the grid at rest.
/// - `trigger` (`any`, default `null`) — changing this value starts a new cycle.
/// - `duration` (`integer`, default `3300`) — total cycle length in milliseconds.
/// - `steps` (`integer`, default `30`) — number of highlight hops.
/// - `dim_opacity` (`number`, default `0.5`) — opacity of unlit children.
/// - `cross_axis_count` (`integer`, default `3`) — number of grid columns.
/// - `main_axis_spacing` (`size`, default `8`) — scaled vertical grid gap.
/// - `cross_axis_spacing` (`size`, default `8`) — scaled horizontal grid gap.
/// - `child_aspect_ratio` (`number`, default `0.7`) — grid cell width-to-height ratio.
/// - `on_finish` (`text`, default `null`) — action dispatched once after settling.
///
/// Child: `_children`.
final class SpinGridWidget {
  const SpinGridWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
    ActionSink? dispatch,
  ) {
    final duration = PropsResolver.integer(props['duration']) ?? 3300;
    final steps = PropsResolver.integer(props['steps']) ?? 30;
    final crossAxisCount =
        PropsResolver.integer(props['cross_axis_count']) ?? 3;
    final childAspectRatio =
        PropsResolver.number(props['child_aspect_ratio']) ?? 0.7;

    return _SpinGrid(
      winnerIndex: PropsResolver.integer(props['winner_index']),
      trigger: props['trigger'],
      duration: Duration(milliseconds: math.max(1, duration)),
      steps: math.max(1, steps),
      dimOpacity: PropsResolver.ratio01(props['dim_opacity']) ?? 0.5,
      crossAxisCount: math.max(1, crossAxisCount),
      mainAxisSpacing:
          PropsResolver.size(context, props['main_axis_spacing']) ?? 8,
      crossAxisSpacing:
          PropsResolver.size(context, props['cross_axis_spacing']) ?? 8,
      childAspectRatio: childAspectRatio > 0 && childAspectRatio.isFinite
          ? childAspectRatio
          : 0.7,
      onFinish: PropsResolver.text(props['on_finish']),
      dispatch: dispatch,
      children: children,
    );
  }
}

class _SpinGrid extends StatefulWidget {
  const _SpinGrid({
    required this.winnerIndex,
    required this.trigger,
    required this.duration,
    required this.steps,
    required this.dimOpacity,
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.childAspectRatio,
    required this.onFinish,
    required this.dispatch,
    required this.children,
  });

  final int? winnerIndex;
  final Object? trigger;
  final Duration duration;
  final int steps;
  final double dimOpacity;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final String? onFinish;
  final ActionSink? dispatch;
  final List<Widget> children;

  @override
  State<_SpinGrid> createState() => _SpinGridState();
}

class _SpinGridState extends State<_SpinGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int? _cycleWinner;
  int? _highlightedIndex;
  bool _didFinish = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..addListener(_updateHighlight)
      ..addStatusListener(_handleStatus);
    // Null is the no-event default; an initial non-null trigger represents a
    // draw that arrived before this widget was first mounted.
    if (widget.trigger != null) _startCycle();
  }

  @override
  void didUpdateWidget(_SpinGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.trigger != oldWidget.trigger) _startCycle();
  }

  bool get _hasValidWinner {
    final winner = widget.winnerIndex;
    return winner != null &&
        winner >= 0 &&
        winner < widget.children.length &&
        widget.children.isNotEmpty;
  }

  void _startCycle() {
    _didFinish = false;
    if (!_hasValidWinner) {
      _controller.stop();
      setState(() {
        _cycleWinner = null;
        _highlightedIndex = null;
      });
      return;
    }

    _cycleWinner = widget.winnerIndex;
    _highlightedIndex = _indexForHop(0);
    _controller.forward(from: 0);
  }

  void _updateHighlight() {
    final winner = _cycleWinner;
    if (winner == null || !mounted) return;

    // Mapping elapsed time through ease-out advances many steps early and only
    // a few near the end, reproducing the slot-machine slowdown without timers.
    final progress = Curves.easeOut.transform(_controller.value);
    final hop = math.min((progress * widget.steps).floor(), widget.steps - 1);
    final nextIndex = _indexForHop(hop);
    if (nextIndex == _highlightedIndex) return;
    setState(() => _highlightedIndex = nextIndex);
  }

  int _indexForHop(int hop) {
    final winner = _cycleWinner!;
    final offsetFromWinner = widget.steps - 1 - hop;
    return (winner - offsetFromWinner) % widget.children.length;
  }

  void _handleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _didFinish) return;
    _didFinish = true;
    setState(() => _highlightedIndex = _cycleWinner);
    final action = widget.onFinish;
    if (action != null) widget.dispatch?.handle(action);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlighted = _highlightedIndex;
    return GridView.count(
      crossAxisCount: widget.crossAxisCount,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
      childAspectRatio: widget.childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var index = 0; index < widget.children.length; index += 1)
          Opacity(
            opacity: highlighted == null || highlighted == index
                ? 1
                : widget.dimOpacity,
            child: widget.children[index],
          ),
      ],
    );
  }
}
