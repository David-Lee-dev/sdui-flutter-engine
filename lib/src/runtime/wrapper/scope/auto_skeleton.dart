import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../scroll_edge_hold.dart';
import 'skeleton_shimmer.dart';

/// Paces every bone of one automatic skeleton (`_skeleton: auto`).
///
/// Bones stay unpainted for [grace] from the scope's mount, so data that
/// arrives quickly never flashes a placeholder. Afterwards all bones share
/// one shimmer phase, swept across this widget's box so separate nodes read
/// as one band. The shimmer runs only while some bone is visible.
///
/// Once [loading] (the scope's mount hooks) has gone from true to false, the
/// clock is [SkeletonClockState.finished]: its content has been revealed and
/// never turns back into bones, whatever a later scope starts awaiting.
class SkeletonClock extends StatefulWidget {
  const SkeletonClock({
    super.key,
    required this.loading,
    required this.child,
    this.grace = const Duration(milliseconds: 300),
  });

  final ValueListenable<bool> loading;

  final Widget child;

  /// The delay from mount before pending nodes paint their bones.
  final Duration grace;

  static SkeletonClockState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ClockScope>()?.clock;

  /// The nearest scroll view above [context] when it lies inside the same
  /// automatic skeleton as [context], else `null`. Stand-in rows fill and
  /// hold only such a scroll view, never one outside their skeleton.
  static ScrollableState? scrollableWithin(BuildContext context) {
    final scrollable = context.findAncestorStateOfType<ScrollableState>();
    final clock = context.findAncestorStateOfType<SkeletonClockState>();
    if (scrollable == null || clock == null) return null;
    final enclosing = scrollable.context
        .findAncestorStateOfType<SkeletonClockState>();
    return identical(enclosing, clock) ? scrollable : null;
  }

  @override
  State<SkeletonClock> createState() => SkeletonClockState();
}

class SkeletonClockState extends State<SkeletonClock>
    with SingleTickerProviderStateMixin {
  /// Whether [SkeletonClock.grace] has elapsed.
  final ValueNotifier<bool> graced = ValueNotifier(false);

  late final AnimationController shimmer;

  late final Timer _graceTimer;

  int _showing = 0;

  bool _finished = false;

  /// Whether the scope's mount hooks have settled after loading: nodes under
  /// this clock no longer show as pending.
  bool get finished => _finished;

  @override
  void initState() {
    super.initState();
    shimmer = AnimationController(
      vsync: this,
      duration: SkeletonShimmer.period,
    );
    _graceTimer = Timer(widget.grace, () => graced.value = true);
    if (widget.loading.value) widget.loading.addListener(_loadingChanged);
  }

  void _loadingChanged() {
    if (widget.loading.value) return;
    _finished = true;
    widget.loading.removeListener(_loadingChanged);
  }

  /// The box the shimmer sweep is aligned to.
  RenderBox? get box {
    final box = context.findRenderObject();
    return box is RenderBox && box.attached && box.hasSize ? box : null;
  }

  /// Keeps the shimmer running while a caller shows bones.
  void acquire() {
    if (_showing++ == 0) shimmer.repeat();
  }

  void release() {
    if (--_showing == 0) shimmer.stop();
  }

  @override
  void dispose() {
    widget.loading.removeListener(_loadingChanged);
    _graceTimer.cancel();
    graced.dispose();
    shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _ClockScope(clock: this, child: widget.child);
}

class _ClockScope extends InheritedWidget {
  const _ClockScope({required this.clock, required super.child});

  final SkeletonClockState clock;

  @override
  bool updateShouldNotify(_ClockScope oldWidget) => clock != oldWidget.clock;
}

/// One stand-in loop row of an automatic skeleton.
///
/// It ignores pointers and is hidden from accessibility. While any stand-in
/// row is mounted in a scroll view inside its own automatic skeleton, that
/// scroll view's edge events are held ([ScrollEdgeHold]), so paging never
/// runs over placeholders; a scroll view outside the skeleton is left alone.
class SkeletonRow extends StatefulWidget {
  const SkeletonRow({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonRow> createState() => _SkeletonRowState();
}

class _SkeletonRowState extends State<SkeletonRow> {
  ScrollableState? _scrollable;

  @override
  void initState() {
    super.initState();
    final scrollable = _scrollable = SkeletonClock.scrollableWithin(context);
    if (scrollable != null) ScrollEdgeHold.hold(scrollable);
  }

  @override
  void dispose() {
    final scrollable = _scrollable;
    if (scrollable != null) ScrollEdgeHold.release(scrollable);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      IgnorePointer(child: ExcludeSemantics(child: widget.child));
}

/// Shows one node of an automatic skeleton as bones while it is [pending].
///
/// The node lays out with its real geometry throughout; while pending only
/// bones are painted — one per text line, or the whole box (a circle when
/// [circle]) — and hit testing and semantics are off. Bones wait for the
/// clock's grace; revealing after it fades them out over [fade] above the
/// real content, on the same element tree. Under reduced motion bones are static and reveal
/// at once.
class SkeletonMask extends StatefulWidget {
  const SkeletonMask({
    super.key,
    required this.pending,
    required this.child,
    this.circle = false,
    this.fade = const Duration(milliseconds: 250),
  });

  final bool pending;
  final bool circle;
  final Duration fade;
  final Widget child;

  @override
  State<SkeletonMask> createState() => _SkeletonMaskState();
}

class _SkeletonMaskState extends State<SkeletonMask>
    with SingleTickerProviderStateMixin {
  /// The bones' opacity: 1 while shown, animating to 0 on reveal.
  late final AnimationController _bones = AnimationController(
    vsync: this,
    duration: widget.fade,
  );

  SkeletonClockState? _clock;
  bool _still = false;
  bool _shimmering = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final clock = SkeletonClock.maybeOf(context);
    if (!identical(clock, _clock)) {
      _setShimmering(false);
      _clock?.graced.removeListener(_sync);
      _clock = clock?..graced.addListener(_sync);
    }
    _still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _sync();
  }

  @override
  void didUpdateWidget(SkeletonMask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pending != oldWidget.pending) _sync();
  }

  bool get _graced => _clock?.graced.value ?? true;

  void _sync() {
    if (widget.pending) {
      _bones.value = _graced ? 1 : 0;
    } else if (_bones.value > 0 && !_still) {
      if (!_bones.isAnimating) _bones.reverse(from: _bones.value);
    } else {
      _bones.value = 0;
    }
    _setShimmering(widget.pending && _graced && !_still);
  }

  void _setShimmering(bool on) {
    if (on == _shimmering) return;
    _shimmering = on;
    on ? _clock?.acquire() : _clock?.release();
  }

  @override
  void dispose() {
    _setShimmering(false);
    _clock?.graced.removeListener(_sync);
    _bones.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    excluding: widget.pending,
    child: _Bones(
      pending: widget.pending,
      circle: widget.circle,
      opacity: _bones,
      shimmer: _still ? null : _clock?.shimmer,
      alignTo: _clock,
      child: widget.child,
    ),
  );
}

class _Bones extends SingleChildRenderObjectWidget {
  const _Bones({
    required this.pending,
    required this.circle,
    required this.opacity,
    required this.shimmer,
    required this.alignTo,
    required super.child,
  });

  final bool pending;
  final bool circle;
  final Animation<double> opacity;
  final Animation<double>? shimmer;
  final SkeletonClockState? alignTo;

  @override
  _RenderBones createRenderObject(BuildContext context) => _RenderBones(
    pending: pending,
    circle: circle,
    opacity: opacity,
    shimmer: shimmer,
    alignTo: alignTo,
  );

  @override
  void updateRenderObject(BuildContext context, _RenderBones renderObject) =>
      renderObject
        ..pending = pending
        ..circle = circle
        ..opacity = opacity
        ..shimmer = shimmer
        ..alignTo = alignTo;
}

/// Paints bones in place of (or, while revealing, above) its child.
class _RenderBones extends RenderProxyBox {
  _RenderBones({
    required bool pending,
    required this.circle,
    required Animation<double> opacity,
    required Animation<double>? shimmer,
    required this.alignTo,
  }) : _pending = pending,
       _opacity = opacity,
       _shimmer = shimmer;

  bool circle;
  SkeletonClockState? alignTo;

  /// The bones measured while pending, kept so the reveal fades the shapes
  /// the user saw rather than the real content's.
  List<RRect>? _measured;

  bool _pending;
  set pending(bool value) {
    if (value == _pending) return;
    _pending = value;
    markNeedsPaint();
  }

  Animation<double> _opacity;
  set opacity(Animation<double> value) {
    if (identical(value, _opacity)) return;
    if (attached) _opacity.removeListener(markNeedsPaint);
    _opacity = value;
    if (attached) _opacity.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  Animation<double>? _shimmer;
  set shimmer(Animation<double>? value) {
    if (identical(value, _shimmer)) return;
    if (attached) _shimmer?.removeListener(markNeedsPaint);
    _shimmer = value;
    if (attached) _shimmer?.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _opacity.addListener(markNeedsPaint);
    _shimmer?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _opacity.removeListener(markNeedsPaint);
    _shimmer?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) =>
      !_pending && super.hitTest(result, position: position);

  @override
  void performLayout() {
    super.performLayout();
    if (_pending) _measured = null;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_pending) super.paint(context, offset);
    final alpha = _opacity.value;
    if (alpha <= 0) return;
    final bones = _measured ??= _measure();
    final paint = Paint()..color = SkeletonShimmer.base;
    final shimmer = _shimmer;
    if (shimmer != null) {
      paint.shader = SkeletonShimmer.gradient(
        shimmer.value,
      ).createShader(_sweepRect().shift(offset));
    }
    void draw(PaintingContext context, Offset offset) {
      for (final bone in bones) {
        context.canvas.drawRRect(bone.shift(offset), paint);
      }
    }

    if (alpha >= 1) {
      draw(context, offset);
    } else {
      context.pushOpacity(offset, (alpha * 255).round(), (context, origin) {
        draw(context, origin);
      });
    }
  }

  /// The clock's box in local coordinates, so every bone samples one sweep.
  Rect _sweepRect() {
    final box = alignTo?.box;
    if (box == null || !attached) return Offset.zero & size;
    return MatrixUtils.transformRect(
      box.getTransformTo(this),
      Offset.zero & box.size,
    );
  }

  /// One rounded bone per laid-out text line, or the whole box.
  List<RRect> _measure() {
    final bones = <RRect>[];
    void visit(RenderObject node) {
      if (node is RenderParagraph) {
        final transform = node.getTransformTo(this);
        for (final line in _lines(node)) {
          final rect = MatrixUtils.transformRect(transform, line);
          bones.add(RRect.fromRectAndRadius(rect, _radius(rect)));
        }
        return;
      }
      node.visitChildren(visit);
    }

    final child = this.child;
    if (child != null) visit(child);
    if (bones.isNotEmpty) return bones;
    final rect = Offset.zero & size;
    return [
      RRect.fromRectAndRadius(
        rect,
        circle ? Radius.circular(rect.shortestSide / 2) : _radius(rect),
      ),
    ];
  }

  static Radius _radius(Rect rect) =>
      Radius.circular(rect.height < 8 ? rect.height / 2 : 4);

  /// Merges a paragraph's selection boxes into one rect per visual line.
  static List<Rect> _lines(RenderParagraph paragraph) {
    final length = paragraph.text.toPlainText().length;
    final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: length),
    );
    final lines = <Rect>[];
    for (final box in boxes) {
      final rect = box.toRect();
      if (rect.isEmpty) continue;
      final last = lines.isEmpty ? null : lines.last;
      if (last != null && rect.top < last.bottom && rect.bottom > last.top) {
        lines[lines.length - 1] = last.expandToInclude(rect);
      } else {
        lines.add(rect);
      }
    }
    return lines;
  }
}
