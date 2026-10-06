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
