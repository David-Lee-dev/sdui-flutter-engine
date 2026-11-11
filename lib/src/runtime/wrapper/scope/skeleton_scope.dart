import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/presence_config.dart';
import 'package:sdui_engine/src/ir/model/skeleton_style_override.dart';
import 'package:sdui_engine/src/presentation/skeleton_style.dart';
import '../../engine_presentation.dart';
import '../../log/engine_log.dart';
import '../../util/props_resolver.dart';
import '../presence.dart';

enum _Phase { holding, showing, done }

/// Bridges a scope's loading state to its content with a skeleton placeholder.
///
/// The skeleton fills the slot from the first frame but is painted only after
/// [grace]. This prevents fast loads from flashing a placeholder while still
/// reserving space so slower sibling scopes cannot reflow shared layouts. When
/// the load finishes the slot swaps the skeleton for the content at once by
/// default. With an enabled [presence] the swap animates instead: the size
/// goes from the skeleton's to the content's while one crossfades into the
/// other, and a load inside the grace swaps the same way from the
/// never-painted skeleton, so the content fades in. A content already loaded
/// at mount shows at once.
class SkeletonScope extends StatefulWidget {
  const SkeletonScope({
    super.key,
    required this.loading,
    required this.skeleton,
    required this.child,
    this.grace = const Duration(milliseconds: 300),
    this.presence = const PresenceConfig(),
    this.shimmer,
  });

  final ValueListenable<bool> loading;
  final Widget skeleton;
  final Widget child;

  /// The delay before an in-flight load reveals its skeleton.
  final Duration grace;

  /// How the skeleton swaps to the content.
  final PresenceConfig presence;

  /// The phase shared by the skeletons of one [LoadingScope]; the skeleton
  /// runs its own when `null` or when its style's period differs.
  final AnimationController? shimmer;

  @override
  State<SkeletonScope> createState() => _SkeletonScopeState();
}

class _SkeletonScopeState extends State<SkeletonScope> {
  late _Phase _phase;
  Timer? _graceTimer;

  @override
  void initState() {
    super.initState();
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

  @override
  void didUpdateWidget(SkeletonScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading == oldWidget.loading) return;
    oldWidget.loading.removeListener(_handleLoading);
    widget.loading.addListener(_handleLoading);
    _handleLoading();
  }

  void _handleLoading() {
    if (widget.loading.value || _phase == _Phase.done) return;
    _graceTimer?.cancel();
    setState(() => _phase = _Phase.done);
  }

  @override
  void dispose() {
    _graceTimer?.cancel();
    widget.loading.removeListener(_handleLoading);
    super.dispose();
  }

  /// The author's outline, painted by the skeleton style in effect. Authors
  /// draw only bones (`skeleton` widgets) and layout — the effect is applied
  /// here so no node wires its own animation. Bones are inert in every phase:
  /// they take no pointer or focus and say nothing to screen readers.
  Widget get _bones => IgnorePointer(
    child: ExcludeSemantics(
      child: ExcludeFocus(
        child: _SkeletonMask(phase: widget.shimmer, child: widget.skeleton),
      ),
    ),
  );

  // The content keeps one key from the swap on, so finishing the swap never
  // remounts it or re-fires its entrance motion / mount lifecycle.
  @override
  Widget build(BuildContext context) => PresenceGroup.single(
    config: widget.presence,
    childKey: _phase == _Phase.done ? 'content' : 'skeleton',
    child: switch (_phase) {
      _Phase.holding => Opacity(opacity: 0, child: _bones),
      _Phase.showing => _bones,
      _Phase.done => widget.child,
    },
  );
}

/// Applies a scope's `_skeleton_style` over the skeleton style around it,
/// key by key, for the skeletons and scopes below.
class SkeletonStyleScope extends StatelessWidget {
  const SkeletonStyleScope({
    super.key,
    required this.style,
    required this.child,
  });

  /// The keys this scope sets.
  final SkeletonStyleOverride style;
  final Widget child;

  /// The skeleton style in effect at [context]: the nearest scope's, or the
  /// app's.
  static SkeletonStyle of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_StyleLayer>()?.style ??
      EnginePresentation.value.skeleton;

  @override
  Widget build(BuildContext context) {
    final effect = style.effect;
    final ms = style.durationMs;
    return _StyleLayer(
      style: of(context).merge(
        effect: effect == null ? null : SkeletonEffect.values.byName(effect),
        base: _paint(style.base),
        highlight: _paint(style.highlight),
        duration: ms == null ? null : Duration(milliseconds: ms),
      ),
      child: child,
    );
  }

  /// Decodes a compiled color literal or gradient map.
  static SkeletonPaint? _paint(Object? raw) {
    if (raw is Map) {
      final gradient = PropsResolver.gradient(raw);
      return gradient == null ? null : SkeletonPaint.gradient(gradient);
    }
    final color = PropsResolver.color(raw);
    return color == null ? null : SkeletonPaint.color(color);
  }
}

class _StyleLayer extends InheritedWidget {
  const _StyleLayer({required this.style, required super.child});

  final SkeletonStyle style;

  @override
  bool updateShouldNotify(_StyleLayer oldWidget) => style != oldWidget.style;
}

/// Paints the whole subtree with the skeleton style in effect.
///
/// A `srcATop` [ShaderMask] repaints every opaque pixel of the skeleton
/// outline while transparent layout gaps stay clear, so all bones share one
/// paint. [SkeletonEffect.tint] paints the base and never ticks; breathe and
/// shimmer animate over the style's period, on the shared [phase] when its
/// period matches or else on one controller of their own. Reduced motion
/// paints the base. Individual bones carry no animation.
class _SkeletonMask extends StatefulWidget {
  const _SkeletonMask({required this.child, this.phase});

  final Widget child;
  final AnimationController? phase;

  @override
  State<_SkeletonMask> createState() => _SkeletonMaskState();
}

class _SkeletonMaskState extends State<_SkeletonMask>
    with SingleTickerProviderStateMixin {
  AnimationController? _own;

  /// The phase to animate on: the shared one at [period], else this mask's.
  Animation<double> _phaseAt(Duration period) {
    final shared = widget.phase;
    if (shared != null && shared.duration == period) {
      _own?.stop();
      return shared;
    }
    final own = _own ??= AnimationController(vsync: this, duration: period);
    if (own.duration != period || !own.isAnimating) {
      own
        ..duration = period
        ..repeat();
    }
    return own;
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = SkeletonStyleScope.of(context);
    final still =
        style.effect == SkeletonEffect.tint ||
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    if (still) {
      _own?.stop();
      return _mask(widget.child, () => style.base.asGradient);
    }
    final phase = _phaseAt(style.duration);
    return AnimatedBuilder(
      animation: phase,
      child: widget.child,
      builder: (context, child) => _mask(
        child!,
        () => style.effect == SkeletonEffect.breathe
            ? _breath(style, phase.value)
            : _band(style, phase.value),
      ),
    );
  }

  static Widget _mask(Widget child, Gradient Function() gradient) => ShaderMask(
    blendMode: BlendMode.srcATop,
    shaderCallback: (bounds) => gradient().createShader(bounds),
    child: child,
  );

  /// Base eased to highlight and back as [t] goes 0→1.
  static Gradient _breath(SkeletonStyle style, double t) => Gradient.lerp(
    style.base.asGradient,
    style.highlight.asGradient,
    Curves.easeInOut.transform(t < 0.5 ? 2 * t : 2 - 2 * t),
  )!;

  /// The standard shimmer gradient: a highlight band padded by base on both
  /// ends (so a base gap follows each pass), swept left→right as [t] goes
  /// 0→1. Clamp tiling keeps everything base once the band slides off.
  /// With one color each it matches the widely used `shimmer` package's
  /// stops and direction. A gradient paint contributes its colors along the
  /// sweep: the base's first and last pad the band, and the highlight's
  /// spread evenly across it.
  static LinearGradient _band(SkeletonStyle style, double t) {
    final base = style.base.colors;
    final highlight = style.highlight.colors;
    final n = highlight.length;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.centerRight,
      colors: [base.first, base.first, ...highlight, base.last, base.last],
      stops: [
        0.0,
        0.35,
        for (var i = 1; i <= n; i++) 0.35 + 0.3 * i / (n + 1),
        0.65,
        1.0,
      ],
      transform: _SlideTransform(2 * t - 1),
    );
  }
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

/// Gives the node skeletons below a scope its loading state and one shared
/// animation phase at the style's period, which runs only while the scope
/// loads and some bones animate on it (a still tint never does).
class LoadingScope extends StatefulWidget {
  const LoadingScope({super.key, required this.loading, required this.child});

  final ValueListenable<bool> loading;
  final Widget child;

  @override
  State<LoadingScope> createState() => _LoadingScopeState();
}

class _LoadingScopeState extends State<LoadingScope>
    with SingleTickerProviderStateMixin {
  late final _shimmer = _SharedShimmer(vsync: this, onPainters: _sync);

  @override
  void initState() {
    super.initState();
    widget.loading.addListener(_sync);
    _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final period = SkeletonStyleScope.of(context).duration;
    if (_shimmer.duration == period) return;
    _shimmer.duration = period;
    if (_shimmer.isAnimating) _shimmer.repeat();
  }

  @override
  void didUpdateWidget(LoadingScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading == oldWidget.loading) return;
    oldWidget.loading.removeListener(_sync);
    widget.loading.addListener(_sync);
    _sync();
  }

  void _sync() {
    if (!mounted) return;
    if (!widget.loading.value || _shimmer.painters == 0) {
      _shimmer.stop();
    } else if (!_shimmer.isAnimating) {
      _shimmer.repeat();
    }
  }

  @override
  void dispose() {
    widget.loading.removeListener(_sync);
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _LoadingLayer(
    loading: widget.loading,
    shimmer: _shimmer,
    child: widget.child,
  );
}

/// The animation phase a [LoadingScope] shares. Its listeners are the bones
/// animating on it, so [onPainters] learns when bones come on stage and when
/// the last ones leave, an exit included; a settled slot or a still tint
/// paints none.
class _SharedShimmer extends AnimationController {
  _SharedShimmer({required super.vsync, required this.onPainters});

  final VoidCallback onPainters;

  /// How many bone trees paint this phase now.
  int painters = 0;

  @override
  void didRegisterListener() {
    super.didRegisterListener();
    painters++;
    onPainters();
  }

  @override
  void didUnregisterListener() {
    super.didUnregisterListener();
    painters--;
    onPainters();
  }
}

class _LoadingLayer extends InheritedWidget {
  const _LoadingLayer({
    required this.loading,
    required this.shimmer,
    required super.child,
  });

  final ValueListenable<bool> loading;
  final AnimationController shimmer;

  @override
  bool updateShouldNotify(_LoadingLayer oldWidget) =>
      loading != oldWidget.loading || shimmer != oldWidget.shimmer;
}

/// A `_skeleton: merge`: lays [child] (the derived bones) out, under the
/// merge width when set, and paints one rounded box of its size instead of
/// it. The box is opaque like a bone, so the skeleton mask above recolors it
/// with the style in effect; children outside the box (a positioned child
/// that overflows) neither enlarge nor paint it.
class MergedBones extends StatelessWidget {
  const MergedBones({super.key, required this.merge, required this.child});

  final SkeletonMerge merge;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = PropsResolver.size(context, merge.width);
    return _MergedBox(
      radius: PropsResolver.size(context, merge.radius) ?? 0,
      child: width == null ? child : SizedBox(width: width, child: child),
    );
  }
}

class _MergedBox extends SingleChildRenderObjectWidget {
  const _MergedBox({required this.radius, super.child});

  final double radius;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMergedBox(radius);

  @override
  void updateRenderObject(BuildContext context, _RenderMergedBox renderObject) {
    renderObject.radius = radius;
  }
}

/// Sizes to its child but paints one rounded box in place of it.
class _RenderMergedBox extends RenderProxyBox {
  _RenderMergedBox(this._radius);

  /// Opaque, as a bone's base, so the skeleton mask has pixels to recolor.
  static const _base = Color(0xFF2C2C2C);

  double _radius;
  set radius(double value) {
    if (value == _radius) return;
    _radius = value;
    markNeedsPaint();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      false;

  @override
  void paint(PaintingContext context, Offset offset) {
    // A radius past half the short side (a pill's 999) rounds it fully.
    final radius = math.min(_radius, size.shortestSide / 2);
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(offset & size, Radius.circular(radius)),
      Paint()..color = _base,
    );
  }
}

/// A node `_skeleton`: shows [bones] in place of [child] while the nearest
/// [LoadingScope] loads.
///
/// The slot decides at its first build. Without a loading scope, or after
/// the load, it shows [child] for good. A [child] that is not a box (parent
/// data or a sliver) cannot sit in the slot, so it is shown directly with a
/// warning.
class SkeletonSlot extends StatefulWidget {
  const SkeletonSlot({
    super.key,
    required this.bones,
    required this.boxed,
    required this.path,
    required this.child,
    this.presence = const PresenceConfig(),
  });

  final Widget bones;

  /// Whether [child] builds a box that the slot can hold.
  final bool boxed;

  /// The node's tree path for diagnostics.
  final String path;

  final Widget child;

  /// How the [bones] swap to [child].
  final PresenceConfig presence;

  @override
  State<SkeletonSlot> createState() => _SkeletonSlotState();
}

class _SkeletonSlotState extends State<SkeletonSlot> {
  /// Whether the slot holds [SkeletonSlot.child] in a [SkeletonScope],
  /// decided at the first build and kept, so the child never remounts.
  bool? _wrapped;

  /// The loading layer the slot is under now; it changes when the layer
  /// replaces its load or the slot moves.
  _LoadingLayer? _layer;

  /// What a slot moved out of every loading scope follows: nothing loads.
  static final _loaded = ValueNotifier(false);

  bool _wraps(_LoadingLayer? layer) {
    if (layer == null || !layer.loading.value) return false;
    if (widget.boxed) return true;
    EngineLog.warn(
      '"_skeleton" at ${widget.path} is skipped: the node is not a box '
      '(parent data or sliver); showing the content',
      tag: 'scope',
    );
    return false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final layer = context.dependOnInheritedWidgetOfExactType<_LoadingLayer>();
    _wrapped ??= _wraps(layer);
    _layer = layer;
  }

  @override
  Widget build(BuildContext context) {
    if (!_wrapped!) return widget.child;
    final layer = _layer;
    return SkeletonScope(
      loading: layer?.loading ?? _loaded,
      skeleton: widget.bones,
      presence: widget.presence,
      shimmer: layer?.shimmer,
      child: widget.child,
    );
  }
}
