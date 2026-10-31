import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/presence_config.dart';
import '../presence.dart';

enum _Phase { holding, showing, done }

/// Bridges a scope's loading state to its content with a skeleton placeholder.
///
/// The skeleton fills the slot from the first frame but is painted only after
/// [grace]. This prevents fast loads from flashing a placeholder while still
/// reserving space so slower sibling scopes cannot reflow shared layouts. When
/// the load finishes the slot swaps the skeleton for the content as a
/// presence swap ([presence]): the size goes from the skeleton's to the
/// content's while one crossfades into the other. A content already loaded at
/// mount shows at once.
class SkeletonScope extends StatefulWidget {
  const SkeletonScope({
    super.key,
    required this.loading,
    required this.skeleton,
    required this.child,
    this.grace = const Duration(milliseconds: 300),
    this.presence = const PresenceConfig(),
  });

  final ValueListenable<bool> loading;
  final Widget skeleton;
  final Widget child;

  /// The delay before an in-flight load reveals its skeleton.
  final Duration grace;

  /// How the skeleton swaps to the content.
  final PresenceConfig presence;

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

  /// The author's outline, wrapped in the automatic shimmer sweep. Authors draw
  /// only bones (`skeleton` widgets) and layout — the effect is applied here so
  /// no node wires its own animation.
  Widget get _shimmered => _Shimmer(child: widget.skeleton);

  // The content keeps one key from the swap on, so finishing the swap never
  // remounts it or re-fires its entrance motion / mount lifecycle.
  @override
  Widget build(BuildContext context) => PresenceGroup.single(
    config: widget.presence,
    childKey: _phase == _Phase.done ? 'content' : 'skeleton',
    child: switch (_phase) {
      _Phase.holding => Opacity(opacity: 0, child: _shimmered),
      _Phase.showing => _shimmered,
      _Phase.done => widget.child,
    },
  );
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
