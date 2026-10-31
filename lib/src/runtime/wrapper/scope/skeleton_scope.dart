import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/presence_config.dart';
import '../../log/engine_log.dart';
import '../presence.dart';

enum _Phase { holding, showing, done }

/// Bridges a scope's loading state to its content with a skeleton placeholder.
///
/// The skeleton fills the slot from the first frame but is painted only after
/// [grace]. This prevents fast loads from flashing a placeholder while still
/// reserving space so slower sibling scopes cannot reflow shared layouts. When
/// the load finishes the slot swaps the skeleton for the content as a
/// presence swap ([presence]): the size goes from the skeleton's to the
/// content's while one crossfades into the other. A load inside the grace
/// swaps the same way from the never-painted skeleton, so the content fades
/// in. A content already loaded at mount shows at once.
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

  /// The shimmer phase shared by the skeletons of one [LoadingScope]; the
  /// skeleton runs its own when `null`.
  final Animation<double>? shimmer;

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
  /// no node wires its own animation. Bones are inert in every phase: they
  /// take no pointer or focus and say nothing to screen readers.
  Widget get _shimmered => IgnorePointer(
    child: ExcludeSemantics(
      child: ExcludeFocus(
        child: _Shimmer(animation: widget.shimmer, child: widget.skeleton),
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
/// continuous band while transparent layout gaps stay clear. A shared
/// [animation] or else one controller per skeleton drives it; individual bones
/// carry no animation.
class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child, this.animation});

  final Widget child;
  final Animation<double>? animation;

  // Standard shimmer cadence (the `shimmer` package's default period).
  static const period = Duration(milliseconds: 1500);

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  static const Color _base = Color(0xFF2C2C2C); // surface30
  static const Color _highlight = Color(0xFF4B4B4B); // surface50

  AnimationController? _own;

  Animation<double> get _animation =>
      widget.animation ??
      (_own ??= AnimationController(vsync: this, duration: _Shimmer.period)
        ..repeat());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = _animation;
    return AnimatedBuilder(
      animation: animation,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) =>
            _gradient(animation.value).createShader(bounds),
        child: child,
      ),
    );
  }

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

/// Gives the node skeletons below a scope its loading state and one shimmer
/// phase, which runs only while the scope loads and some slot holds bones.
class LoadingScope extends StatefulWidget {
  const LoadingScope({super.key, required this.loading, required this.child});

  final ValueListenable<bool> loading;
  final Widget child;

  @override
  State<LoadingScope> createState() => _LoadingScopeState();
}

class _LoadingScopeState extends State<LoadingScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: _Shimmer.period,
  );

  @override
  void initState() {
    super.initState();
    widget.loading.addListener(_sync);
    _sync();
  }

  @override
  void didUpdateWidget(LoadingScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading == oldWidget.loading) return;
    oldWidget.loading.removeListener(_sync);
    widget.loading.addListener(_sync);
    _sync();
  }

  /// The slots below that hold bones.
  int _slots = 0;

  void _retain() {
    _slots++;
    _sync();
  }

  void _release() {
    _slots--;
    _sync();
  }

  void _sync() {
    if (!widget.loading.value || _slots == 0) {
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
    owner: this,
    child: widget.child,
  );
}

class _LoadingLayer extends InheritedWidget {
  const _LoadingLayer({
    required this.loading,
    required this.shimmer,
    required this.owner,
    required super.child,
  });

  final ValueListenable<bool> loading;
  final Animation<double> shimmer;

  /// Counts the slots holding bones, which run the [shimmer].
  final _LoadingScopeState owner;

  @override
  bool updateShouldNotify(_LoadingLayer oldWidget) =>
      loading != oldWidget.loading || shimmer != oldWidget.shimmer;
}

/// A node `_skeleton`: shows [bones] in place of [child] while the nearest
/// [LoadingScope] loads.
///
/// The slot decides at its first build. Without a loading scope, or after
/// the load, it shows [child] for good. A [child] that is not a box (a
/// parent-data, sliver or app-registered widget) cannot sit in the slot, so
/// it is shown directly with a warning.
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
  late final _LoadingLayer? _layer = _loadingLayer();

  /// The loading scope whose shimmer this slot's bones keep running.
  _LoadingScopeState? _retained;

  _LoadingLayer? _loadingLayer() {
    final layer = context.getInheritedWidgetOfExactType<_LoadingLayer>();
    if (layer == null || !layer.loading.value) return null;
    if (widget.boxed) {
      _retained = layer.owner.._retain();
      return layer;
    }
    EngineLog.warn(
      '"_skeleton" at ${widget.path} is skipped: the node is not a box '
      '(parent data, sliver or an app widget); showing the content',
      tag: 'scope',
    );
    return null;
  }

  @override
  void dispose() {
    if (_retained?.mounted ?? false) _retained!._release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layer = _layer;
    if (layer == null) return widget.child;
    return SkeletonScope(
      loading: layer.loading,
      skeleton: widget.bones,
      presence: widget.presence,
      shimmer: layer.shimmer,
      child: widget.child,
    );
  }
}
