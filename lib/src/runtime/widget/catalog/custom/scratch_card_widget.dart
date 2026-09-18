import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';
import '../../contract/action_sink.dart';

/// `scratch_card` — Reveals its first child as the user rubs the second away.
///
/// The two children are stacked: `_children[0]` is what lies underneath and
/// `_children[1]` is the covering that gets scratched off. The covering stays a
/// live widget subtree — it is clipped, not rasterized — so it can animate while
/// being erased.
///
/// Progress is measured on a coarse grid rather than by true erased area: a cell
/// counts as cleared once a brush stroke covers its centre. That keeps the value
/// monotonic and cheap, which is what a "78% 완료" readout needs.
///
/// ```yaml
/// _type: scratch_card
/// threshold: 80
/// on_changed: sync_percent
/// on_threshold: claim
/// _children:
///   - { _type: text, value: 3등 }
///   - { _type: container, decoration: { color: '#CBCBCB' } }
/// ```
///
/// Props:
/// - `reset_token` (any, default `null`) — changing it wipes the scratched area
///   and re-arms `on_threshold`, for reusing one card across rounds.
/// - `brush_size` (`size`, scaled, default `40`) — diameter erased around the touch point.
/// - `threshold` (`integer`, default `80`) — percent cleared that fires `on_threshold`.
/// - `haptic` (`flag`, default `false`) — light tick every 10% of progress.
/// - `on_changed` (`text`, default `null`) — action dispatched with the integer percent, once per whole percent.
/// - `on_threshold` (`text`, default `null`) — action dispatched once, when `threshold` is first reached.
///
/// Children: exactly two — revealed content, then the covering.
///
/// SDUI type: `scratch_card`.
final class ScratchCardWidget {
  const ScratchCardWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
    ActionSink? dispatch,
  ) {
    return _ScratchCard(
      resetToken: props['reset_token'],
      brushSize: PropsResolver.size(context, props['brush_size']) ?? 40,
      threshold: (PropsResolver.integer(props['threshold']) ?? 80).clamp(
        1,
        100,
      ),
      haptic: PropsResolver.flag(props['haptic']) ?? false,
      onChanged: PropsResolver.text(props['on_changed']),
      onThreshold: PropsResolver.text(props['on_threshold']),
      dispatch: dispatch,
      revealed: children.isEmpty ? const SizedBox.shrink() : children.first,
      covering: children.length > 1 ? children[1] : const SizedBox.shrink(),
    );
  }
}

/// Grid resolution used to estimate progress. 40×20 cells is fine enough that a
/// single brush pass registers, coarse enough to stay a rounding-error cost.
const _gridColumns = 40;
const _gridRows = 20;
const _cellCount = _gridColumns * _gridRows;

class _ScratchCard extends StatefulWidget {
  const _ScratchCard({
    required this.resetToken,
    required this.brushSize,
    required this.threshold,
    required this.haptic,
    required this.onChanged,
    required this.onThreshold,
    required this.dispatch,
    required this.revealed,
    required this.covering,
  });

  final Object? resetToken;
  final double brushSize;
  final int threshold;
  final bool haptic;
  final String? onChanged;
  final String? onThreshold;
  final ActionSink? dispatch;
  final Widget revealed;
  final Widget covering;

  @override
  State<_ScratchCard> createState() => _ScratchCardState();
}

class _ScratchCardState extends State<_ScratchCard> {
  /// Union of every brush stamp so far, in local coordinates.
  Path _erased = Path();

  /// Cleared grid cells, indexed `row * _gridColumns + column`.
  final _cleared = <int>{};

  Size _size = Size.zero;
  Offset? _lastStamp;
  int _percent = 0;
  int _hapticStep = 0;
  bool _thresholdFired = false;

  @override
  void didUpdateWidget(_ScratchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetToken != widget.resetToken) {
      setState(() {
        _erased = Path();
        _cleared.clear();
        _lastStamp = null;
        _percent = 0;
        _hapticStep = 0;
        _thresholdFired = false;
      });
    }
  }

  /// Stamps closer together than a third of the brush add nothing but path
  /// nodes — every rebuild pays for them, so drop them at the source.
  double get _minStep => widget.brushSize / 3;

  void _stamp(Offset point) {
    final last = _lastStamp;
    if (last != null && (point - last).distance < _minStep) return;
    _lastStamp = point;

    final radius = widget.brushSize / 2;
    _erased = Path.combine(
      PathOperation.union,
      _erased,
      Path()..addOval(Rect.fromCircle(center: point, radius: radius)),
    );
    _markCells(point, radius);

    final next = (_cleared.length * 100 / _cellCount).floor().clamp(0, 100);
    setState(() {});
    if (next != _percent) {
      _percent = next;
      _report(next);
    }
  }

  /// Marks every grid cell whose centre the brush covers.
  void _markCells(Offset point, double radius) {
    if (_size.isEmpty) return;
    final cellWidth = _size.width / _gridColumns;
    final cellHeight = _size.height / _gridRows;
    final firstColumn = ((point.dx - radius) / cellWidth).floor();
    final lastColumn = ((point.dx + radius) / cellWidth).ceil();
    final firstRow = ((point.dy - radius) / cellHeight).floor();
    final lastRow = ((point.dy + radius) / cellHeight).ceil();

    for (var row = firstRow; row <= lastRow; row++) {
      if (row < 0 || row >= _gridRows) continue;
      for (var column = firstColumn; column <= lastColumn; column++) {
        if (column < 0 || column >= _gridColumns) continue;
        final centre = Offset(
          (column + 0.5) * cellWidth,
          (row + 0.5) * cellHeight,
        );
        if ((centre - point).distance <= radius) {
          _cleared.add(row * _gridColumns + column);
        }
      }
    }
  }

  void _report(int percent) {
    final onChanged = widget.onChanged;
    if (onChanged != null) widget.dispatch?.handle(onChanged, event: percent);

    if (widget.haptic && percent ~/ 10 > _hapticStep) {
      _hapticStep = percent ~/ 10;
      HapticFeedback.selectionClick();
    }

    if (!_thresholdFired && percent >= widget.threshold) {
      _thresholdFired = true;
      final onThreshold = widget.onThreshold;
      if (onThreshold != null) widget.dispatch?.handle(onThreshold);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (details) => _stamp(details.localPosition),
          onPanUpdate: (details) => _stamp(details.localPosition),
          onPanEnd: (_) => _lastStamp = null,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              widget.revealed,
              ClipPath(
                clipper: _CoveringClipper(_erased),
                child: widget.covering,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Clips the covering to everything the brush has *not* touched.
class _CoveringClipper extends CustomClipper<Path> {
  const _CoveringClipper(this.erased);

  final Path erased;

  @override
  Path getClip(Size size) => Path.combine(
    PathOperation.difference,
    Path()..addRect(Offset.zero & size),
    erased,
  );

  @override
  bool shouldReclip(_CoveringClipper oldClipper) => oldClipper.erased != erased;
}
