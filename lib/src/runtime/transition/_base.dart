import 'package:flutter/widgets.dart';
import 'package:sdui_engine/src/ir/model/page_transition.dart';

/// A visual page transition driven by the route's primary and secondary animations.
abstract class PageTransitionEffect {
  const PageTransitionEffect();

  String get type;

  Duration get defaultDuration => const Duration(milliseconds: 300);

  Duration get defaultReverseDuration => defaultDuration;

  Duration duration(PageTransitionSpec spec) =>
      Duration(milliseconds: spec.durationMs ?? defaultDuration.inMilliseconds);

  Duration reverseDuration(PageTransitionSpec spec) => Duration(
    milliseconds:
        spec.reverseDurationMs ?? defaultReverseDuration.inMilliseconds,
  );

  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  );
}
