import 'package:flutter/widgets.dart';
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
  Duration get defaultDuration => const Duration(milliseconds: 280);

  @override
  Duration get defaultReverseDuration => const Duration(milliseconds: 220);

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
  Duration get defaultDuration => const Duration(milliseconds: 280);

  @override
  Duration get defaultReverseDuration => const Duration(milliseconds: 220);

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
