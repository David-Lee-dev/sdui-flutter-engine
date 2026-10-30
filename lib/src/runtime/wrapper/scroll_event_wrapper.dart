import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/event_timing.dart';
import 'package:sdui_engine/src/ir/model/interaction_events.dart';
import 'event_timing_controller.dart';
import 'scope/scope.dart';
import 'scope/skeleton_scope.dart';

/// Dispatches scrolling and threshold-entry events from the nearest descendant scrollable.
///
/// `scroll` fires once per scroll frame; the per-event [timing] (throttle /
/// debounce) rate-limits it — e.g. `{ do: on_scroll, throttle: 16 }` caps updates
/// per window, `{ do: on_settle, debounce: 150 }` fires only the final offset.
/// `start_reached` / `end_reached` are edge-gated (once per zone entry).
/// While the scrollable lays out automatic-skeleton stand-in rows
/// ([SkeletonRow]) the edge events are held; one whose zone is still occupied
/// when the rows leave fires then.
class ScrollEventWrapper extends StatefulWidget {
  const ScrollEventWrapper({
    super.key,
    required this.on,
    this.timing = const {},
    double? endThreshold,
    double? startThreshold,
    this.held = false,
    required this.child,
  }) : endThreshold = endThreshold ?? _defaultThreshold,
       startThreshold = startThreshold ?? _defaultThreshold;

  static const Set<String> events = InteractionEvents.scroll;

  static const double _defaultThreshold = 300.0;

  final Map<String, String> on;

  final Map<String, EventTiming> timing;

  final double endThreshold;

  final double startThreshold;

  /// Whether the node waits on an automatic skeleton: nothing fires, and an
  /// edge entered meanwhile fires on the first notification after it.
  final bool held;

  final Widget child;

  @override
  State<ScrollEventWrapper> createState() => _ScrollEventWrapperState();
}

class _ScrollEventWrapperState extends State<ScrollEventWrapper> {
  bool _inEndZone = false;
  bool _inStartZone = false;

  /// Whether an edge zone was entered and its event has not fired yet.
  bool _endOwed = false;
  bool _startOwed = false;

  /// The scroll view whose stand-in rows hold the edge events.
  ScrollableState? _heldBy;

  final EventTimingController _timing = EventTimingController();

  @override
  void dispose() {
    _timing.dispose();
    super.dispose();
  }

  Map<String, Object?> _metrics(ScrollMetrics metrics) => {
    'offset': metrics.pixels,
    'extent_after': metrics.extentAfter,
    'extent_before': metrics.extentBefore,
    'max_extent': metrics.maxScrollExtent,
    'progress': metrics.maxScrollExtent > 0
        ? (metrics.pixels / metrics.maxScrollExtent).clamp(0.0, 1.0)
        : 0.0,
  };

  void _emit(String event, String action, Map<String, Object?> payload) {
    _timing.run(event, widget.timing[event], () {
      if (!mounted) return;
      Scope.actionHost(context)?.handle(action, event: payload);
    });
  }

  /// Tracks the edge zones of [metrics] and fires the edge events owed: an
  /// edge is owed on entering its zone and fires once while not [holding],
  /// so an entry made while held fires on release if still in the zone.
  void _edges(ScrollMetrics metrics, {required bool holding}) {
    final nearEnd = metrics.extentAfter <= widget.endThreshold;
    if (nearEnd && !_inEndZone) _endOwed = true;
    if (!nearEnd) _endOwed = false;
    _inEndZone = nearEnd;
    final endAction = widget.on['end_reached'];
    if (_endOwed && !holding) {
      _endOwed = false;
      if (endAction != null) _emit('end_reached', endAction, _metrics(metrics));
    }

    final nearStart = metrics.extentBefore <= widget.startThreshold;
    if (nearStart && !_inStartZone) _startOwed = true;
    if (!nearStart) _startOwed = false;
    _inStartZone = nearStart;
    final startAction = widget.on['start_reached'];
    if (_startOwed && !holding) {
      _startOwed = false;
      if (startAction != null) {
        _emit('start_reached', startAction, _metrics(metrics));
      }
    }
  }

  /// Fires the edge events owed once the stand-in rows have left [_heldBy],
  /// against its settled position.
  void _released() {
    final scrollable = _heldBy;
    _heldBy = null;
    if (!mounted || scrollable == null || !scrollable.mounted) return;
    final position = scrollable.position;
    if (!position.hasContentDimensions || !position.hasPixels) return;
    _edges(position, holding: SkeletonRow.holds(scrollable) || widget.held);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth != 0) return false;
        final metrics = notification.metrics;
        final scrollAction = widget.on['scroll'];
        if (notification is ScrollUpdateNotification &&
            scrollAction != null &&
            !widget.held) {
          _emit('scroll', scrollAction, _metrics(metrics));
        }

        final heldBy = SkeletonRow.heldBy(notification);
        if (heldBy != null) {
          _heldBy = heldBy;
          SkeletonRow.whenReleased(heldBy, _released);
        }
        _edges(metrics, holding: heldBy != null || widget.held);
        return false;
      },
      child: widget.child,
    );
  }
}
