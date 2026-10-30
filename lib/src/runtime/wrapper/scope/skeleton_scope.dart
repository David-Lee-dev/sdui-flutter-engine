import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

enum _Phase { holding, showing, revealing, done }

/// Bridges a scope's loading state to its content with a skeleton placeholder.
///
/// The skeleton fills the slot from the first frame but is painted only after
/// [grace]. This prevents fast loads from flashing a placeholder while still
/// reserving space so slower sibling scopes cannot reflow shared layouts. A
/// load that finishes during the grace shows content immediately with no fade;
/// one that finishes afterward fades the visible skeleton out over [fade].
class SkeletonScope extends StatefulWidget {
  const SkeletonScope({
    super.key,
    required this.loading,
    required this.skeleton,
    required this.child,
    this.grace = const Duration(milliseconds: 300),
    this.fade = const Duration(milliseconds: 250),
  });

  final ValueListenable<bool> loading;
  final Widget skeleton;
  final Widget child;

  /// The delay before an in-flight load reveals its skeleton.
  final Duration grace;

  /// The skeleton fade-out duration when revealing content.
  final Duration fade;

  @override
  State<SkeletonScope> createState() => _SkeletonScopeState();
}

class _SkeletonScopeState extends State<SkeletonScope>
    with SingleTickerProviderStateMixin {
  late _Phase _phase;
  late final AnimationController _fadeController;
  late final Animation<double> _opacity;
  Timer? _graceTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: widget.fade)
      ..addStatusListener(_handleFadeStatus);
    _opacity = Tween<double>(begin: 1, end: 0).animate(_fadeController);
    widget.loading.addListener(_handleLoading);
    _phase = widget.loading.value ? _Phase.holding : _Phase.done;
    if (_phase == _Phase.holding) {
      _graceTimer = Timer(widget.grace, () {
        if (!mounted || _phase != _Phase.holding || !widget.loading.value) {
          return;
        }
        setState(() => _phase = _Phase.showing);
      });
    }
  }

  void _handleLoading() {
    if (widget.loading.value) return;
    switch (_phase) {
      case _Phase.holding:
        _graceTimer?.cancel();
        setState(() => _phase = _Phase.done);
      case _Phase.showing:
        setState(() => _phase = _Phase.revealing);
        _fadeController.forward(from: 0);
      case _Phase.revealing || _Phase.done:
        return;
    }
  }

  void _handleFadeStatus(AnimationStatus status) {
    if (!mounted || status != AnimationStatus.completed) return;
    setState(() => _phase = _Phase.done);
  }

  @override
  void dispose() {
    _graceTimer?.cancel();
    widget.loading.removeListener(_handleLoading);
    _fadeController.dispose();
    super.dispose();
  }

  /// The author's outline, wrapped in the automatic shimmer sweep. Authors draw
  /// only bones (`skeleton` widgets) and layout — the effect is applied here so
  /// no node wires its own animation.
  Widget get _shimmered => _Shimmer(child: widget.skeleton);

  @override
  Widget build(BuildContext context) => switch (_phase) {
    _Phase.holding => Opacity(opacity: 0, child: _shimmered),
    _Phase.showing => _shimmered,
    // `revealing` and `done` share one tree shape so the child stays at the same
    // position (Stack index 0) across the transition. Returning a bare child on
    // `done` would re-parent it out of the Stack, remounting the subtree and
    // re-firing its entrance motion / mount lifecycle a second time.
    _Phase.revealing || _Phase.done => Stack(
      children: [
        widget.child,
        if (_phase == _Phase.revealing)
          FadeTransition(
            opacity: _opacity,
            child: IgnorePointer(child: _shimmered),
          ),
      ],
    ),
  };
}

/// Sweeps an animated shimmer band across its whole subtree.
///
/// A `srcATop` [ShaderMask] repaints every opaque pixel of the skeleton outline
/// with a moving `base → highlight → base` gradient, so all bones shimmer in one
/// continuous band while transparent layout gaps stay clear. One controller per
/// skeleton drives it; individual bones carry no animation.
class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  static const Color _base = Color(0xFF2C2C2C); // surface30
  static const Color _highlight = Color(0xFF4B4B4B); // surface50

  // Standard shimmer cadence (the `shimmer` package's default period).
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) => ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) =>
          _gradient(_controller.value).createShader(bounds),
      child: child,
    ),
  );

  /// The standard shimmer gradient: a highlight band padded by base on both ends
  /// (so a base gap follows each pass), swept left→right as [t] goes 0→1. Clamp
  /// tiling keeps everything base once the band slides off. Matches the widely
  /// used `shimmer` package's default colors/stops/direction.
  static LinearGradient _gradient(double t) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.centerRight,
    colors: const [_base, _base, _highlight, _base, _base],
    stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
    transform: _SlideTransform(2 * t - 1),
  );
}

/// Translates a gradient horizontally by [percent] of the bounds' width, moving
/// the highlight band across (and past) the subtree each cycle.
class _SlideTransform extends GradientTransform {
  const _SlideTransform(this.percent);

  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * percent, 0, 0);
}

/// Paces every bone of one automatic skeleton (`_skeleton: auto`).
///
/// Bones stay unpainted for [grace] from the scope's mount, so data that
/// arrives quickly never flashes a placeholder. Afterwards all bones share
/// one shimmer phase, swept across this widget's box so separate nodes read
/// as one band. The shimmer runs only while some bone is visible.
class SkeletonClock extends StatefulWidget {
  const SkeletonClock({
    super.key,
    required this.child,
    this.grace = const Duration(milliseconds: 300),
  });

  final Widget child;

  /// The delay from mount before pending nodes paint their bones.
  final Duration grace;

  static SkeletonClockState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ClockScope>()?.clock;

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

  @override
  void initState() {
    super.initState();
    shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _graceTimer = Timer(widget.grace, () => graced.value = true);
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
/// row is mounted in a scroll view, that scroll view's scroll events are held
/// (see [holdsScroll]), so paging never runs over placeholders.
class SkeletonRow extends StatefulWidget {
  const SkeletonRow({super.key, required this.child});

  final Widget child;

  /// How many stand-in rows are mounted, so scroll views skip the lookup
  /// while there are none.
  static int _live = 0;

  static final _rows = Expando<int>('SkeletonRow.rows');

  /// Whether stand-in rows are mounted in the scroll view that sent
  /// [notification].
  static bool holdsScroll(ScrollNotification notification) {
    if (_live == 0) return false;
    final scrollable = notification.context
        ?.findAncestorStateOfType<ScrollableState>();
    return scrollable != null && (_rows[scrollable] ?? 0) > 0;
  }

  @override
  State<SkeletonRow> createState() => _SkeletonRowState();
}

class _SkeletonRowState extends State<SkeletonRow> {
  ScrollableState? _scrollable;

  @override
  void initState() {
    super.initState();
    SkeletonRow._live++;
    final scrollable = _scrollable = context
        .findAncestorStateOfType<ScrollableState>();
    if (scrollable != null) {
      SkeletonRow._rows[scrollable] = (SkeletonRow._rows[scrollable] ?? 0) + 1;
    }
  }

  @override
  void dispose() {
    SkeletonRow._live--;
    final scrollable = _scrollable;
    if (scrollable != null) {
      SkeletonRow._rows[scrollable] = SkeletonRow._rows[scrollable]! - 1;
    }
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

  static const Color _base = _ShimmerState._base;

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
    final paint = Paint()..color = _base;
    final shimmer = _shimmer;
    if (shimmer != null) {
      paint.shader = _ShimmerState._gradient(
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
