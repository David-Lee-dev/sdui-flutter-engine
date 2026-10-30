import 'package:flutter/widgets.dart';

/// Holds the edge events (`start_reached`, `end_reached`) of scroll views
/// while something laid out in them is not real content yet.
///
/// Holders (an automatic skeleton's stand-in rows) [hold] a scroll view while
/// they are mounted in it and [release] it when they leave; the
/// scroll-event wrapper around it holds its edges meanwhile.
abstract final class ScrollEdgeHold {
  /// How many holds are live across every scroll view, so scroll views skip
  /// the lookup while there are none. Process-wide; it returns to zero as
  /// holders release.
  static int _live = 0;

  static final _holds = Expando<int>('ScrollEdgeHold.holds');

  static final _onRelease = Expando<Set<VoidCallback>>(
    'ScrollEdgeHold.release',
  );

  static void hold(ScrollableState scrollable) {
    _live++;
    _holds[scrollable] = (_holds[scrollable] ?? 0) + 1;
  }

  /// Drops one hold on [scrollable]; after the frame in which its last hold
  /// goes, when the real content has been laid out, the [whenReleased]
  /// callbacks run once.
  static void release(ScrollableState scrollable) {
    _live--;
    final holds = _holds[scrollable] = _holds[scrollable]! - 1;
    final callbacks = _onRelease[scrollable];
    if (holds > 0 || callbacks == null) return;
    _onRelease[scrollable] = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final callback in callbacks) {
        callback();
      }
    });
  }

  /// The scroll view that sent [notification] when it is held, else `null`.
  static ScrollableState? heldBy(ScrollNotification notification) {
    if (_live == 0) return null;
    final scrollable = notification.context
        ?.findAncestorStateOfType<ScrollableState>();
    return scrollable != null && holds(scrollable) ? scrollable : null;
  }

  /// Whether anything holds [scrollable].
  static bool holds(ScrollableState scrollable) =>
      (_holds[scrollable] ?? 0) > 0;

  /// Calls [callback] once after the frame in which the last hold leaves
  /// [scrollable].
  static void whenReleased(ScrollableState scrollable, VoidCallback callback) =>
      (_onRelease[scrollable] ??= {}).add(callback);
}
