import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';
import '../../contract/action_sink.dart';
import '../../swipe/swipe_controller.dart';
import '../../swipe/swipe_controller_scope.dart';

/// `swipe_layout` — Owns the [SwipeController] shared by a swipe layout's panes and indicators.
///
/// This is a transparent provider: it wraps its single child subtree so panes
/// and indicators can be placed freely within it (e.g. `pane / indicator /
/// pane`). Scope is the source of truth for the settled index — bind it with
/// `index: ${state}` (reactive read) and `on_changed` (write-back on settle);
/// the controller handles the continuous mid-drag propagation underneath.
///
/// Optional autoplay advances the pages on a timer and pauses while the user is
/// dragging, resuming a configurable delay after the drag settles.
///
/// ```yaml
/// _type: swipe_layout
/// id: example
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `id` (`text`, default `null`) — identifier used to register or connect the widget.
/// - `length` (`integer`, default `1`) — number of pages or tabs managed by the controller.
/// - `index` (`integer`, default `null`) — externally controlled current page index.
/// - `initial_index` (`integer`, default `0`) — page or tab selected initially.
/// - `on_changed` (`text`, default `null`) — action dispatched after the value settles.
/// - `loop` (`flag`, default `true`) — true wraps past the last page back to the first.
/// - `autoplay_interval` (`duration`, default `null`) — time between automatic page advances; null disables autoplay.
/// - `autoplay_resume_delay` (`duration`, default `4 seconds`) — delay before autoplay resumes after interaction.
///
/// Child: `_child`.
final class SwipeLayoutWidget {
  const SwipeLayoutWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
    ActionSink? dispatch,
  ) {
    return _SwipeLayout(
      id: PropsResolver.text(props['id']),
      length: (PropsResolver.integer(props['length']) ?? 1).clamp(1, 1 << 30),
      boundIndex: PropsResolver.integer(props['index']),
      initialIndex: PropsResolver.integer(props['initial_index']) ?? 0,
      onChanged: PropsResolver.text(props['on_changed']),
      loop: PropsResolver.flag(props['loop']) ?? true,
      autoplayInterval: PropsResolver.duration(props['autoplay_interval']),
      resumeDelay:
          PropsResolver.duration(props['autoplay_resume_delay']) ??
          const Duration(seconds: 4),
      dispatch: dispatch,
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}

class _SwipeLayout extends StatefulWidget {
  const _SwipeLayout({
    required this.id,
    required this.length,
    required this.boundIndex,
    required this.initialIndex,
    required this.onChanged,
    required this.loop,
    required this.autoplayInterval,
    required this.resumeDelay,
    required this.dispatch,
    required this.child,
  });

  final String? id;
  final int length;
  final int? boundIndex;
  final int initialIndex;
  final String? onChanged;
  final bool loop;
  final Duration? autoplayInterval;
  final Duration resumeDelay;
  final ActionSink? dispatch;
  final Widget child;

  @override
  State<_SwipeLayout> createState() => _SwipeLayoutState();
}

class _SwipeLayoutState extends State<_SwipeLayout> {
  late final SwipeController _controller;
  Timer? _autoTimer;
  Timer? _resumeTimer;

  /// Guards the scope round-trip: the index last written back, so echoing a
  /// scope-driven change does not re-dispatch.
  int? _lastReported;

  @override
  void initState() {
    super.initState();
    _controller =
        SwipeController(
            length: widget.length,
            initialIndex: widget.boundIndex ?? widget.initialIndex,
            loop: widget.loop,
          )
          ..onSettled = _handleSettled
          ..onInteractionStart = _pauseAutoplay
          ..onInteractionEnd = _scheduleResume;
    _lastReported = _controller.index;
    _startAutoplay();
  }

  @override
  void didUpdateWidget(_SwipeLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.length != oldWidget.length) _controller.setLength(widget.length);
    // Scope drove the index: follow it (but not the value we just reported).
    final bound = widget.boundIndex;
    if (bound != null && bound != _controller.index && bound != _lastReported) {
      _lastReported = bound;
      _controller.goTo(bound);
    }
    if (widget.autoplayInterval != oldWidget.autoplayInterval ||
        widget.loop != oldWidget.loop) {
      _startAutoplay();
    }
  }

  void _handleSettled(int index) {
    if (index == _lastReported) return;
    _lastReported = index;
    final action = widget.onChanged;
    if (action != null) widget.dispatch?.handle(action, event: index);
  }

  int _nextIndex() {
    final next = _controller.index + 1;
    if (next < _controller.length) return next;
    return widget.loop ? 0 : _controller.index;
  }

  void _startAutoplay() {
    _autoTimer?.cancel();
    _resumeTimer?.cancel();
    final interval = widget.autoplayInterval;
    if (interval == null || interval <= Duration.zero) return;
    _autoTimer = Timer.periodic(interval, (_) {
      if (!_controller.isInteracting) _controller.goTo(_nextIndex());
    });
  }

  void _pauseAutoplay() {
    _autoTimer?.cancel();
    _autoTimer = null;
    _resumeTimer?.cancel();
    _resumeTimer = null;
  }

  void _scheduleResume() {
    if (widget.autoplayInterval == null) return;
    _resumeTimer?.cancel();
    _resumeTimer = Timer(widget.resumeDelay, _startAutoplay);
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _resumeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeControllerScope(
      id: widget.id,
      controller: _controller,
      child: widget.child,
    );
  }
}
