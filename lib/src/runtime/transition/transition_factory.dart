import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'transition_origin.dart';
import 'package:sdui_engine/src/ir/model/page_transition.dart';

import '_base.dart';

/// Owns the process-wide mapping from transition names to implementations.
final class PageTransitionFactory {
  const PageTransitionFactory._();

  static const Map<String, PageTransitionEffect> _builtins = {
    'platform': _PlatformPageTransition(),
    'none': _NonePageTransition(),
    'fade': _FadePageTransition(),
    'slide_up': _SlideUpPageTransition(),
    'zoom': _ZoomPageTransition(),
    'fade_through': _FadeThroughPageTransition(),
    'shared_axis': _SharedAxisPageTransition(),
    'container_transform': _ContainerTransformPageTransition(),
    'card_stack': _CardStackPageTransition(),
    'tap_zoom': _TapZoomPageTransition(),
  };

  static final Map<String, PageTransitionEffect> _transitions = {..._builtins};
  static bool _frozen = false;

  static void freeze() => _frozen = true;

  static void register(PageTransitionEffect transition) {
    if (_frozen) {
      throw StateError(
        'PageTransitionFactory is frozen — register before freeze().',
      );
    }
    _transitions[transition.type] = transition;
  }

  static void registerAll(Iterable<PageTransitionEffect> transitions) {
    for (final transition in transitions) {
      register(transition);
    }
  }

  static void reset() {
    _frozen = false;
    _transitions
      ..clear()
      ..addAll(_builtins);
  }

  static Set<String> types() => Set.unmodifiable(_transitions.keys);

  static PageTransitionEffect resolve(String type) {
    final transition = _transitions[type];
    if (transition == null) {
      throw StateError('Unknown page transition type: "$type".');
    }
    return transition;
  }
}

final class _PlatformPageTransition extends PageTransitionEffect {
  const _PlatformPageTransition();

  @override
  String get type => 'platform';

  @override
  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  ) => child;
}

final class _NonePageTransition extends PageTransitionEffect {
  const _NonePageTransition();

  @override
  String get type => 'none';

  @override
  Duration get defaultDuration => Duration.zero;

  @override
  Duration get defaultReverseDuration => Duration.zero;

  @override
  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  ) => child;
}

final class _FadePageTransition extends PageTransitionEffect {
  const _FadePageTransition();

  @override
  String get type => 'fade';

  @override
  Duration get defaultDuration => const Duration(milliseconds: 200);

  @override
  Duration get defaultReverseDuration => const Duration(milliseconds: 150);

  @override
  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  ) => FadeTransition(opacity: animation, child: child);
}

final class _SlideUpPageTransition extends PageTransitionEffect {
  const _SlideUpPageTransition();

  @override
  String get type => 'slide_up';

  @override
  Duration get defaultDuration => const Duration(milliseconds: 250);

  @override
  Duration get defaultReverseDuration => const Duration(milliseconds: 200);

  @override
  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  ) {
    final begin = (spec.params['distance'] as num?)?.toDouble() ?? 0.08;
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, begin),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

final class _ZoomPageTransition extends PageTransitionEffect {
  const _ZoomPageTransition();

  @override
  String get type => 'zoom';

  @override
  Duration get defaultDuration => const Duration(milliseconds: 250);

  @override
  Duration get defaultReverseDuration => const Duration(milliseconds: 200);

  @override
  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  ) {
    final begin = (spec.params['begin_scale'] as num?)?.toDouble() ?? 0.94;
    return ScaleTransition(
      scale: Tween<double>(begin: begin, end: 1).animate(animation),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

final class _FadeThroughPageTransition extends PageTransitionEffect {
  const _FadeThroughPageTransition();

  @override
  String get type => 'fade_through';

  @override
  Duration get defaultDuration => const Duration(milliseconds: 300);

  @override
  Duration get defaultReverseDuration => const Duration(milliseconds: 250);

  @override
  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  ) {
    final threshold = (spec.params['threshold'] as num?)?.toDouble() ?? 0.35;
    final incoming = animation.drive(CurveTween(curve: Interval(threshold, 1)));
    return FadeTransition(
      opacity: incoming,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1).animate(incoming),
        child: child,
      ),
    );
  }

  @override
  Widget buildOutgoing(
    BuildContext context,
    Animation<double> animation,
    Widget child,
    PageTransitionSpec spec,
  ) {
    final threshold = (spec.params['threshold'] as num?)?.toDouble() ?? 0.35;
    return FadeTransition(
      opacity: animation
          .drive(CurveTween(curve: Interval(0, threshold)))
          .drive(Tween<double>(begin: 1, end: 0)),
      child: child,
    );
  }
}

final class _SharedAxisPageTransition extends PageTransitionEffect {
  const _SharedAxisPageTransition();

  @override
  String get type => 'shared_axis';

  @override
  Duration get defaultDuration => const Duration(milliseconds: 300);

  @override
  Duration get defaultReverseDuration => const Duration(milliseconds: 250);

  @override
  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  ) {
    final axis = spec.params['axis'] as String? ?? 'x';
    final faded = FadeTransition(opacity: animation, child: child);
    if (axis == 'z') {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1).animate(animation),
        child: faded,
      );
    }
    final distance = (spec.params['distance'] as num?)?.toDouble() ?? 30;
    final direction = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    return AnimatedBuilder(
      animation: animation,
      child: faded,
      builder: (_, child) => Transform.translate(
        offset: axis == 'y'
            ? Offset(0, distance * (1 - animation.value))
            : Offset(direction * distance * (1 - animation.value), 0),
        child: child,
      ),
    );
  }

  @override
  Widget buildOutgoing(
    BuildContext context,
    Animation<double> animation,
    Widget child,
    PageTransitionSpec spec,
  ) {
    final axis = spec.params['axis'] as String? ?? 'x';
    final faded = FadeTransition(
      opacity: animation.drive(Tween<double>(begin: 1, end: 0)),
      child: child,
    );
    if (axis == 'z') {
      return ScaleTransition(
        scale: Tween<double>(begin: 1, end: 1.1).animate(animation),
        child: faded,
      );
    }
    final distance = (spec.params['distance'] as num?)?.toDouble() ?? 30;
    final direction = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    return AnimatedBuilder(
      animation: animation,
      child: faded,
      builder: (_, child) => Transform.translate(
        offset: axis == 'y'
            ? Offset(0, -distance * animation.value)
            : Offset(-direction * distance * animation.value, 0),
        child: child,
      ),
    );
  }
}

final class _ContainerTransformPageTransition extends PageTransitionEffect {
  const _ContainerTransformPageTransition();
  @override
  String get type => 'container_transform';
  @override
  Duration get defaultDuration => const Duration(milliseconds: 300);
  @override
  Duration get defaultReverseDuration => const Duration(milliseconds: 250);

  @override
  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  ) {
    final source = TransitionOriginScope.of(context)?.source;
    if (source == null) return FadeTransition(opacity: animation, child: child);
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (_, child) {
            final box = context.findRenderObject();
            if (box is! RenderBox) return child!;
            final t = animation.value;
            final start = Rect.fromPoints(
              box.globalToLocal(source.rect.topLeft),
              box.globalToLocal(source.rect.bottomRight),
            );
            final rect = Rect.lerp(
              start,
              Offset.zero & constraints.biggest,
              t,
            )!;
            final radius = source.radius * (1 - t);
            final incoming = ((t - 0.35) / 0.65).clamp(0.0, 1.0);
            final snapshot = (1 - t / 0.35).clamp(0.0, 1.0);
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipPath(
                  clipper: _ContainerClip(rect, radius),
                  child: Opacity(opacity: incoming, child: child),
                ),
                Positioned.fromRect(
                  rect: rect,
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: Opacity(
                        opacity: snapshot,
                        child: RawImage(image: source.image, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget buildOutgoing(
    BuildContext context,
    Animation<double> animation,
    Widget child,
    PageTransitionSpec spec,
  ) {
    final scrim = (spec.params['scrim'] as num?)?.toDouble() ?? 0;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (_, child) => Stack(
        fit: StackFit.expand,
        children: [
          child!,
          IgnorePointer(
            child: ColoredBox(
              color: Color.fromRGBO(0, 0, 0, scrim * animation.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContainerClip extends CustomClipper<Path> {
  const _ContainerClip(this.rect, this.radius);
  final Rect rect;
  final double radius;
  @override
  Path getClip(Size size) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
  @override
  bool shouldReclip(_ContainerClip oldClipper) =>
      rect != oldClipper.rect || radius != oldClipper.radius;
}

final class _CardStackPageTransition extends PageTransitionEffect {
  const _CardStackPageTransition();
  @override
  String get type => 'card_stack';
  @override
  Duration get defaultDuration => const Duration(milliseconds: 350);
  @override
  Duration get defaultReverseDuration => const Duration(milliseconds: 300);

  @override
  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  ) => SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );

  @override
  Widget buildOutgoing(
    BuildContext context,
    Animation<double> animation,
    Widget child,
    PageTransitionSpec spec,
  ) {
    final scale = (spec.params['scale'] as num?)?.toDouble() ?? 0.94;
    final radius = (spec.params['radius'] as num?)?.toDouble() ?? 12;
    final dim = (spec.params['dim'] as num?)?.toDouble() ?? 0.2;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (_, child) => Transform.scale(
        scale: ui.lerpDouble(1, scale, animation.value),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius * animation.value),
          child: Stack(
            fit: StackFit.expand,
            children: [
              child!,
              IgnorePointer(
                child: ColoredBox(
                  color: Color.fromRGBO(0, 0, 0, dim * animation.value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _TapZoomPageTransition extends PageTransitionEffect {
  const _TapZoomPageTransition();
  @override
  String get type => 'tap_zoom';
  @override
  Duration get defaultDuration => const Duration(milliseconds: 300);
  @override
  Duration get defaultReverseDuration => const Duration(milliseconds: 250);

  @override
  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  ) {
    final point = TransitionOriginScope.of(context)?.point;
    final begin = (spec.params['begin_scale'] as num?)?.toDouble() ?? 0.1;
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (_, child) {
          final box = context.findRenderObject();
          final local = point != null && box is RenderBox
              ? box.globalToLocal(point)
              : null;
          final alignment = local == null || constraints.biggest.isEmpty
              ? Alignment.center
              : Alignment(
                  (2 * local.dx / constraints.maxWidth - 1).clamp(-1.0, 1.0),
                  (2 * local.dy / constraints.maxHeight - 1).clamp(-1.0, 1.0),
                );
          return Transform.scale(
            scale: ui.lerpDouble(begin, 1, animation.value),
            alignment: alignment,
            child: Opacity(opacity: animation.value, child: child),
          );
        },
      ),
    );
  }
}
