import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'skeleton_shimmer.dart';

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
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SkeletonShimmer.period,
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
          SkeletonShimmer.gradient(_controller.value).createShader(bounds),
      child: child,
    ),
  );
}
