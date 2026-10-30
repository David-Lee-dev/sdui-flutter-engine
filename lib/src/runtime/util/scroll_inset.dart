import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Lets a vertical scroll view draw under the bottom system inset (home
/// indicator, system bar, a floating tab bar the shell adds to the padding)
/// while its last item still stops above it.
///
/// The scroll view adds the bottom [MediaQueryData.padding] to its end spacing
/// and hands its content a padding without that bottom, so an inner
/// `safe_area` or nested scroll view does not add the same inset again. The
/// inset stays on the physical bottom edge, also for a `reverse` scroll view,
/// whose first item rests there. When the keyboard is up Flutter reports a
/// bottom padding of 0, so the end spacing shrinks to the template padding.
///
/// By default (`inset_end` absent) the inset applies only while the view's
/// bottom edge reaches into the bottom inset of the screen: a full-height
/// scroll or one in a bottom sheet gets it, a scroll above a fixed CTA or in a
/// centered dialog does not. `inset_end: true` always applies it and
/// `inset_end: false` never does. Horizontal scroll views are left untouched.
final class ScrollInset {
  const ScrollInset._();

  /// Builds a scroll view of [axis] through [builder], which receives the
  /// bottom inset to add after the content (0 when it does not apply).
  ///
  /// [insetEnd] is the `inset_end` prop: `null` decides from the view's laid
  /// out position (see [ScrollInset]). The first frame assumes the view
  /// reaches the bottom; when the measurement disagrees the next frame only
  /// changes the end spacing and the content's bottom padding.
  static Widget build(
    BuildContext context, {
    required Axis axis,
    required bool? insetEnd,
    required Widget Function(BuildContext context, double extent) builder,
  }) {
    if (axis != Axis.vertical) return builder(context, 0);
    return _ScrollInsetScope(insetEnd: insetEnd, builder: builder);
  }

  /// [base] with [extent] added to the bottom; a horizontal view keeps [base].
  ///
  /// A vertical view never gets `null`: a list or grid without padding would
  /// otherwise take the top and bottom padding from [MediaQuery] by itself,
  /// adding the inset again or ignoring `inset_end: false`. The scaffold body
  /// already clears the top, left and right edges.
  static EdgeInsets? endPadding(EdgeInsets? base, Axis axis, double extent) {
    if (axis != Axis.vertical) return base;
    return (base ?? EdgeInsets.zero) + EdgeInsets.only(bottom: extent);
  }
}

/// Holds the "reaches the bottom inset" decision of one vertical scroll view.
class _ScrollInsetScope extends StatefulWidget {
  const _ScrollInsetScope({required this.insetEnd, required this.builder});

  final bool? insetEnd;
  final Widget Function(BuildContext context, double extent) builder;

  @override
  State<_ScrollInsetScope> createState() => _ScrollInsetScopeState();
}

class _ScrollInsetScopeState extends State<_ScrollInsetScope> {
  /// Laying out under the inset is the common case (a full-height scroll), so
  /// the first frame assumes it.
  bool _reaches = true;

  void _onMeasured(bool reaches) {
    if (reaches != _reaches) setState(() => _reaches = reaches);
  }

  /// The tree keeps the same shape whatever the decision or the inset value,
  /// so the content keeps its state when either changes.
  @override
  Widget build(BuildContext context) {
    final applies = widget.insetEnd ?? _reaches;
    final inset = MediaQuery.maybePaddingOf(context)?.bottom ?? 0;
    final screenHeight = MediaQuery.maybeSizeOf(context)?.height ?? 0;

    final view = _BottomProbe(
      threshold: screenHeight - inset - _BottomProbe.tolerance,
      onMeasured: widget.insetEnd == null ? _onMeasured : null,
      child: widget.builder(context, applies ? inset : 0),
    );
    if (MediaQuery.maybeOf(context) == null) return view;
    return MediaQuery.removePadding(
      context: context,
      removeBottom: applies,
      child: view,
    );
  }
}

/// Reports after each frame that laid it out or painted it whether its bottom
/// edge reaches [threshold] on the screen.
class _BottomProbe extends SingleChildRenderObjectWidget {
  const _BottomProbe({
    required this.threshold,
    required this.onMeasured,
    required super.child,
  });

  /// Rounding slack for a view whose bottom sits exactly on the inset edge.
  static const tolerance = 1.0;

  final double threshold;
  final ValueChanged<bool>? onMeasured;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderBottomProbe(threshold: threshold, onMeasured: onMeasured);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderBottomProbe renderObject,
  ) {
    renderObject
      ..threshold = threshold
      ..onMeasured = onMeasured;
  }
}

class _RenderBottomProbe extends RenderProxyBox {
  _RenderBottomProbe({required double threshold, this.onMeasured})
    : _threshold = threshold;

  ValueChanged<bool>? onMeasured;
  bool _scheduled = false;

  double get threshold => _threshold;
  double _threshold;
  set threshold(double value) {
    if (value == _threshold) return;
    _threshold = value;
    _schedule();
  }

  @override
  void performLayout() {
    super.performLayout();
    _schedule();
  }

  /// Painting also catches moves without a relayout (an animated sheet).
  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    _schedule();
  }

  /// Measures once after the current frame, when every ancestor has placed
  /// its children.
  void _schedule() {
    if (_scheduled || onMeasured == null) return;
    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      final report = onMeasured;
      if (report == null || !attached || !hasSize) return;
      report(_layoutBottom() >= _threshold);
    });
  }

  /// The bottom edge in screen coordinates from layout positions alone.
  ///
  /// Proxy boxes are skipped, so paint-only transforms (a page transition
  /// scaling or sliding the route, a fading dialog) do not flip the decision
  /// mid-animation. Scroll offsets and shifted boxes still count.
  double _layoutBottom() {
    final chain = <RenderObject>[this];
    var node = parent;
    while (node != null && node.parent != null) {
      chain.add(node);
      node = node.parent;
    }

    final transform = Matrix4.identity();
    for (var i = chain.length - 1; i > 0; i--) {
      final ancestor = chain[i];
      if (ancestor is RenderProxyBoxMixin) continue;
      ancestor.applyPaintTransform(chain[i - 1], transform);
    }
    return MatrixUtils.transformPoint(transform, Offset(0, size.height)).dy;
  }
}
