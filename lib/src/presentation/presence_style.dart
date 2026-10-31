import 'package:flutter/animation.dart';

/// App-owned defaults for presence transitions: how long, and on which
/// curve, structural content grows in, collapses out, or swaps one branch
/// for another. A template's `_presence` `duration`/`curve` still wins.
///
/// The defaults are the Material 3 motion tokens.
final class PresenceStyle {
  const PresenceStyle({
    this.enter = const Duration(milliseconds: 300),
    this.enterCurve = const Cubic(0.05, 0.7, 0.1, 1),
    this.exit = const Duration(milliseconds: 250),
    this.exitCurve = const Cubic(0.3, 0, 0.8, 0.15),
    this.swap = const Duration(milliseconds: 300),
    this.swapCurve = Curves.easeInOutCubicEmphasized,
  });

  /// Inserted content growing into its space (`emphasized_decelerate`).
  final Duration enter;
  final Curve enterCurve;

  /// Removed content collapsing out (`emphasized_accelerate`).
  final Duration exit;
  final Curve exitCurve;

  /// One branch replacing another in the same place (`emphasized`).
  final Duration swap;
  final Curve swapCurve;
}
