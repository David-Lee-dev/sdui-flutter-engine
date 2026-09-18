import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/event_timing.dart';
import 'package:sdui_engine/src/ir/model/interaction_events.dart';
import 'event_timing_controller.dart';
import 'scope/scope.dart';

/// Dispatches scrolling and threshold-entry events from the nearest descendant scrollable.
///
/// `scroll` fires once per scroll frame; the per-event [timing] (throttle /
/// debounce) rate-limits it — e.g. `{ do: on_scroll, throttle: 16 }` caps updates
/// per window, `{ do: on_settle, debounce: 150 }` fires only the final offset.
/// `start_reached` / `end_reached` are edge-gated (once per zone entry).
class ScrollEventWrapper extends StatefulWidget {
  const ScrollEventWrapper({
    super.key,
    required this.on,
    this.timing = const {},
    double? endThreshold,
    double? startThreshold,
    required this.child,
  }) : endThreshold = endThreshold ?? _defaultThreshold,
       startThreshold = startThreshold ?? _defaultThreshold;

  static const Set<String> events = InteractionEvents.scroll;

  static const double _defaultThreshold = 300.0;

  final Map<String, String> on;

  final Map<String, EventTiming> timing;

  final double endThreshold;

  final double startThreshold;

  final Widget child;

  @override
  State<ScrollEventWrapper> createState() => _ScrollEventWrapperState();
}

class _ScrollEventWrapperState extends State<ScrollEventWrapper> {
  bool _inEndZone = false;
  bool _inStartZone = false;

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

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth != 0) return false;
        final metrics = notification.metrics;
        final scrollAction = widget.on['scroll'];
        if (notification is ScrollUpdateNotification && scrollAction != null) {
          _emit('scroll', scrollAction, _metrics(metrics));
        }

        final nearEnd = metrics.extentAfter <= widget.endThreshold;
        final endAction = widget.on['end_reached'];
        if (nearEnd && !_inEndZone && endAction != null) {
          _emit('end_reached', endAction, _metrics(metrics));
        }
        _inEndZone = nearEnd;

        final nearStart = metrics.extentBefore <= widget.startThreshold;
        final startAction = widget.on['start_reached'];
        if (nearStart && !_inStartZone && startAction != null) {
          _emit('start_reached', startAction, _metrics(metrics));
        }
        _inStartZone = nearStart;
        return false;
      },
      child: widget.child,
    );
  }
}
