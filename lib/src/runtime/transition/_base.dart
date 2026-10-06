import 'package:flutter/widgets.dart';
import 'package:sdui_engine/src/ir/model/page_transition.dart';

/// A visual page transition driven by the route's primary and secondary animations.
abstract class PageTransitionEffect {
  const PageTransitionEffect();

  String get type;

  Duration get defaultDuration => const Duration(milliseconds: 250);

  Duration get defaultReverseDuration => defaultDuration;

  Duration duration(PageTransitionSpec spec) =>
      Duration(milliseconds: spec.durationMs ?? defaultDuration.inMilliseconds);

  Duration reverseDuration(PageTransitionSpec spec) => Duration(
    milliseconds:
        spec.reverseDurationMs ?? defaultReverseDuration.inMilliseconds,
  );

  /// Optionally animates the page below this route. The animation includes
  /// this route's curve and retraces the same values on pop and swipe.
  /// Returning null preserves the previous effect's secondary transition.
  Widget? buildOutgoing(
    BuildContext context,
    Animation<double> animation,
    Widget child,
    PageTransitionSpec spec,
  ) => null;

  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  );
}
