import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/event_timing.dart';
import 'package:sdui_engine/src/ir/model/interaction_events.dart';
import 'event_timing_controller.dart';
import '../telemetry/telemetry.dart';
import '../widget/contract/action_sink.dart';
import 'scope/scope.dart';
import '../engine_presentation.dart';

/// Dispatches discrete gestures, adding press feedback and button semantics to taps.
///
/// Each gesture's action dispatch runs through the per-event [timing]
/// (throttle / debounce), so e.g. a `tap` can drop rapid double-fires.
class InteractionWrapper extends StatefulWidget {
  const InteractionWrapper({
    super.key,
    required this.on,
    required this.node,
    this.timing = const {},
    this.payloads = const {},
    this.feedback = true,
    required this.child,
  });

  static const Set<String> events = InteractionEvents.gesture;

  final Map<String, String> on;

  /// The compiled identity of the node owning these gestures.
  final ActionNode node;

  final Map<String, EventTiming> timing;

  /// Per-event values handed to the action as `${event}`, already resolved in
  /// this node's frame.
  final Map<String, Object?> payloads;

  /// Whether a tap plays the press feedback. When false, taps still fire, silently.
  final bool feedback;

  final Widget child;

  @override
  State<InteractionWrapper> createState() => _InteractionWrapperState();
}

class _InteractionWrapperState extends State<InteractionWrapper> {
  final EventTimingController _timing = EventTimingController();
  final Map<String, _AttemptWindow> _attempts = {};

  @override
  void dispose() {
    for (final window in _attempts.values) {
      window.timer.cancel();
      _recordRejected(window);
    }
    _attempts.clear();
    _timing.dispose();
    super.dispose();
  }

  VoidCallback? _handler(String event) {
    final action = widget.on[event];
    if (action == null) return null;
    return () {
      final scope = TelemetryScope.maybeOf(context);
      final key = '${scope?.screenViewId}|${widget.node.path}|$event';
      final window = _attempts.putIfAbsent(
        key,
        () => _AttemptWindow(
          gesture: event,
          action: action,
          screenId: scope?.screenId,
          screenViewId: scope?.screenViewId,
          timer: Timer(const Duration(seconds: 3), () => _flush(key)),
        ),
      );
      window.attempts++;
      _timing.run(event, widget.timing[event], () {
        if (!mounted) return;
        window.accepted++;
        final invocation = ActionInvocation(
          invocationId: Telemetry.newId(),
          origin: ActionOrigin.tap,
          node: widget.node,
        );
        Telemetry.record(
          'action_intent',
          screenId: scope?.screenId,
          screenViewId: scope?.screenViewId,
          correlationId: invocation.invocationId,
          properties: _properties(
            gesture: event,
            action: action,
            accepted: true,
            invocationId: invocation.invocationId,
          ),
        );
        Scope.actionHost(context)?.handle(
          action,
          event: widget.payloads[event],
          invocation: invocation,
        );
      });
    };
  }

  void _flush(String key) {
    final window = _attempts.remove(key);
    if (window != null) _recordRejected(window);
  }

  void _recordRejected(_AttemptWindow window) {
    final rejected = window.attempts - window.accepted;
    if (rejected <= 0) return;
    Telemetry.record(
      'action_intent',
      screenId: window.screenId,
      screenViewId: window.screenViewId,
      properties: {
        ..._properties(
          gesture: window.gesture,
          action: window.action,
          accepted: false,
        ),
        'count': rejected,
      },
    );
  }

  Map<String, Object?> _properties({
    required String gesture,
    required String action,
    required bool accepted,
    String? invocationId,
  }) => {
    'gesture': gesture,
    'action_id': action,
    'accepted': accepted,
    if (invocationId != null) 'invocation_id': invocationId,
    'node_type': widget.node.type,
    'node_path': widget.node.path,
    if (widget.node.entity != null) 'entity': widget.node.entity,
    if (widget.node.position.isNotEmpty) 'position': widget.node.position,
  };

  @override
  Widget build(BuildContext context) {
    final onTap = _handler('tap');
    final onDoubleTap = _handler('double_tap');
    final onLongPress = _handler('long_press');

    if (onTap != null && widget.feedback) {
      return Semantics(
        button: true,
        // Look is implementation-owned (contract/tap_feedback.dart): the
        // package default is the stock ink ripple; apps inject their own via
        // SduiPresentation(tapFeedback: ...).
        child: EnginePresentation.tapFeedback.wrap(
          context,
          widget.child,
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
        ),
      );
    }

    // No tap, or feedback suppressed: a plain detector still fires every gesture.
    final detector = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: widget.child,
    );
    return onTap == null ? detector : Semantics(button: true, child: detector);
  }
}

final class _AttemptWindow {
  _AttemptWindow({
    required this.gesture,
    required this.action,
    required this.screenId,
    required this.screenViewId,
    required this.timer,
  });

  final String gesture;
  final String action;
  final String? screenId;
  final String? screenViewId;
  final Timer timer;
  int attempts = 0;
  int accepted = 0;
}
