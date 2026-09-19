import 'package:flutter/widgets.dart';

import 'telemetry.dart';

/// Observes one surface visit: dwell time, scroll depth, and the closing
/// `screen_leave` (TELEMETRY.md §3 item 6, §7).
///
/// Extracted from the mount so measuring a visit and mounting a template are
/// separate jobs: `EngineRunner` composes this around the mounted tree when
/// the mount has a surface identity, and the widget is a transparent no-op
/// when [screenId]/[screenViewId] are null (modal bodies without identity,
/// bare test mounts).
///
/// It also publishes the identity via [TelemetryScope], so every descendant
/// action/command event attributes to this visit.
final class VisitObserver extends StatefulWidget {
  const VisitObserver({
    super.key,
    required this.screenId,
    required this.screenViewId,
    this.surfaceType,
    this.modalId,
    this.resolveExitReason,
    required this.child,
  });

  final String? screenId;

  /// The current visit's identifier, fresh per activation. A change means a
  /// new visit for a kept-alive mount — counters restart from zero.
  final String? screenViewId;

  /// `'modal'` for modal bodies; absent for plain screens.
  final String? surfaceType;

  final String? modalId;

  /// The owner's attribution for why the visit ended (`ScreenPage` from the
  /// navigation flow, the modal frame from how it closed). `null` result
  /// means "cannot tell" and no `exit_reason` is emitted — a wrong one
  /// silently corrupts drop-off analysis.
  final String? Function()? resolveExitReason;

  final Widget child;

  @override
  State<VisitObserver> createState() => _VisitObserverState();
}

final class _VisitObserverState extends State<VisitObserver>
    with WidgetsBindingObserver {
  bool get _observable =>
      widget.screenId != null && widget.screenViewId != null;

  /// Foreground time for the current visit. Runs only while this mount is
  /// both visible (not covered/offstage — see [_isVisible]) and the app
  /// itself is foregrounded; background time must not count as dwell.
  final Stopwatch _dwell = Stopwatch();

  /// This mount's own visibility — a kept-alive tab branch mounts one
  /// observer per tab, and each detects its own activation/deactivation.
  bool _visible = false;

  bool _appForeground = true;

  /// Whether this visit ever actually ran the dwell clock. Guards
  /// [_emitLeave] against firing for a visit that mounted already-offstage
  /// (a kept-alive tab prefetch) and never became visible.
  bool _trackedAnyForeground = false;

  bool _leaveEmittedForVisit = false;

  double _maxScrollPct = 0;
  bool _reachedEnd = false;
  int _scrollSessions = 0;

  /// Identifies the one vertical scrollable this visit's depth is measured
  /// against — see [_handleScrollNotification].
  BuildContext? _primaryScrollContext;

  @override
  void initState() {
    super.initState();
    if (_observable) WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_observable) return;
    final visible = _isVisible(context);
    final was = _visible;
    _visible = visible;
    _updateDwellRunning();
    if (was && !visible) {
      _emitLeave(
        exitReason:
            widget.resolveExitReason?.call() ?? _inferExitReason(context),
      );
    }
  }

  /// Mirrors `ScreenPage._isVisible`: a go_router `IndexedStack` tab branch
  /// wraps its inactive content in `Offstage` + `TickerMode(enabled: false)`,
  /// not Flutter's `Visibility`.
  bool _isVisible(BuildContext context) =>
      (ModalRoute.of(context)?.isCurrent ?? true) && TickerMode.of(context);

  /// The attribution this mount can make on its own, used only when
  /// [VisitObserver.resolveExitReason] had nothing to say.
  ///
  /// A covering route reads as `push` whether it is another screen or an
  /// app-owned page (the in-app webview): from here they are the same event —
  /// something was pushed over this screen.
  String? _inferExitReason(BuildContext context) {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return 'push';
    if (!TickerMode.of(context)) return 'tab';
    return null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_observable) return;
    final foreground = state == AppLifecycleState.resumed;
    if (foreground == _appForeground) return;
    _appForeground = foreground;
    _updateDwellRunning();
  }

  /// Starts or stops the dwell clock so it only ever accumulates time this
  /// mount was both visible and the app was foregrounded.
  void _updateDwellRunning() {
    final shouldRun = _visible && _appForeground;
    if (shouldRun == _dwell.isRunning) return;
    if (shouldRun) {
      _dwell.start();
      _trackedAnyForeground = true;
    } else {
      _dwell.stop();
    }
  }

  @override
  void didUpdateWidget(VisitObserver old) {
    super.didUpdateWidget(old);
    // A new screen_view_id means a new visit for an otherwise-kept-alive
    // mount (tab switched back to) — the old visit's leave was already
    // emitted by the visibility-loss path in [didChangeDependencies]; this
    // just resets the counters so the new visit starts from zero.
    if (widget.screenViewId != null &&
        widget.screenViewId != old.screenViewId) {
      _resetVisitMetrics();
      _updateDwellRunning();
    }
  }

  void _resetVisitMetrics() {
    _dwell
      ..stop()
      ..reset();
    _trackedAnyForeground = false;
    _leaveEmittedForVisit = false;
    _maxScrollPct = 0;
    _reachedEnd = false;
    _scrollSessions = 0;
    _primaryScrollContext = null;
  }

  /// Emits `screen_leave` for the current visit at most once. A visit that
  /// never ran the dwell clock (mounted already-offstage and never became
  /// visible) has nothing meaningful to report and is skipped.
  void _emitLeave({String? exitReason}) {
    if (_leaveEmittedForVisit || !_trackedAnyForeground) return;
    _leaveEmittedForVisit = true;
    if (_dwell.isRunning) _dwell.stop();
    Telemetry.record(
      'screen_leave',
      screenId: widget.screenId,
      screenViewId: widget.screenViewId,
      properties: {
        'foreground_ms': _dwell.elapsedMilliseconds,
        'max_depth': _depthBucket(_maxScrollPct),
        'reached_end': _reachedEnd,
        'scroll_sessions': _scrollSessions,
        if (exitReason != null) 'exit_reason': exitReason,
        if (widget.surfaceType != null) 'surface_type': widget.surfaceType,
        if (widget.modalId != null) 'modal_id': widget.modalId,
      },
    );
  }

  static int _depthBucket(double pct) {
    if (pct >= 100) return 100;
    if (pct >= 90) return 90;
    if (pct >= 75) return 75;
    if (pct >= 50) return 50;
    if (pct >= 25) return 25;
    return 0;
  }

  /// Tracks scroll depth for `screen_leave`'s `max_depth`/`reached_end`/
  /// `scroll_sessions` (TELEMETRY.md §3 "스크롤 깊이의 범위").
  ///
  /// A single listener at the mount root sees every descendant scrollable via
  /// bubbling, which is also the trap: sibling scrollables are all reported
  /// at `depth == 0`, and a horizontal carousel bubbles the same as the
  /// screen's real vertical list. Horizontal notifications are rejected
  /// outright, and the first vertical scrollable to report a scroll start
  /// becomes this visit's "primary" — every other vertical scrollable's
  /// notifications are ignored, so a carousel mixed in with the real list
  /// cannot inflate depth toward a false 100%.
  bool _handleScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return false;

    if (notification is ScrollStartNotification) {
      _primaryScrollContext ??= notification.context;
      if (notification.context != _primaryScrollContext) return false;
      _scrollSessions++;
    } else if (notification.context != _primaryScrollContext) {
      return false;
    }

    if (metrics.maxScrollExtent > 0) {
      final pct = (metrics.pixels / metrics.maxScrollExtent * 100).clamp(
        0.0,
        100.0,
      );
      if (pct > _maxScrollPct) _maxScrollPct = pct;
    }
    if (metrics.extentAfter <= 0.5) _reachedEnd = true;

    return false; // Observe only — let the notification keep bubbling.
  }

  @override
  void dispose() {
    if (_observable) {
      WidgetsBinding.instance.removeObserver(this);
      // A full unmount while still visible closes out the visit; one already
      // closed via visibility loss (tab switch) is a no-op via the guard.
      // The context cannot be consulted here, so the cause comes from the
      // owner — falling back to `background` only when the app itself was no
      // longer foregrounded, which is the one cause this mount can be sure of.
      if (_visible) {
        _emitLeave(
          exitReason:
              widget.resolveExitReason?.call() ??
              (_appForeground ? null : 'background'),
        );
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenId = widget.screenId;
    final screenViewId = widget.screenViewId;
    if (screenId == null || screenViewId == null) return widget.child;
    return TelemetryScope(
      screenId: screenId,
      screenViewId: screenViewId,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: widget.child,
      ),
    );
  }
}
