import 'dart:async';
import 'dart:io' show ProcessInfo;
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// The load timeline of one model view, in milliseconds since its controller
/// was created.
final class ModelLoadStats extends ChangeNotifier {
  ModelLoadStats({required this.src, required this.mount, this.warmUpMs});

  final String src;

  /// 1 for the first model view of the source since launch, then 2, 3, ...
  final int mount;

  /// How long [WebModelSource.warmUp] took, or null when it had not finished
  /// as this view was created.
  final int? warmUpMs;

  final _clock = Stopwatch()..start();
  final List<({String label, int ms})> marks = [];

  /// How the model bytes reached the page, e.g. `7.6MB cache 3ms`.
  String? model;
  String? error;

  void mark(String label) {
    marks.add((label: label, ms: _clock.elapsedMilliseconds));
    notifyListeners();
  }

  /// Records the model bytes served to the page; [cached] when they were
  /// already in (or on their way into) the byte cache.
  void served({required int bytes, required bool cached, required int ms}) {
    model =
        '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB '
        '${cached ? 'cache' : 'net'} ${ms}ms';
    mark('model');
  }

  void fail(String reason) {
    error = reason;
    mark('error');
  }

  int get elapsedMs => _clock.elapsedMilliseconds;

  bool get isReady => marks.any((m) => m.label == 'ready');

  String get warmUp =>
      warmUpMs == null ? 'warm-up pending' : 'warm-up ${warmUpMs}ms';

  /// One line for logs: `#1 warm-up 812ms a.glb: webview 15ms, ... (7.6MB ...)`.
  String summary() => [
    '#$mount $warmUp $src:',
    marks.map((m) => '${m.label} ${m.ms}ms').join(', '),
    if (model != null) '($model)',
    if (error != null) 'error: $error',
  ].join(' ');
}

/// Frame build/raster times counted against one refresh interval.
final class FrameStats {
  FrameStats({this.budgetMs = 1000 / 60});

  double budgetMs;
  int frames = 0;
  int janky = 0;
  double worstMs = 0;

  void add(Iterable<FrameTiming> timings) {
    for (final timing in timings) {
      addMs(
        math.max(
              timing.buildDuration.inMicroseconds,
              timing.rasterDuration.inMicroseconds,
            ) /
            1000,
      );
    }
  }

  @visibleForTesting
  void addMs(double ms) {
    frames++;
    if (ms > budgetMs) janky++;
    worstMs = math.max(worstMs, ms);
  }

  void reset() {
    frames = 0;
    janky = 0;
    worstMs = 0;
  }

  @override
  String toString() {
    final share = frames == 0 ? 0 : janky * 100 ~/ frames;
    return 'frames $frames, >${budgetMs.toStringAsFixed(1)}ms $janky ($share%), '
        'worst ${worstMs.toStringAsFixed(1)}ms';
  }
}

/// Paints [stats], app memory and frame times over a model view.
///
/// Memory is this app process's RSS: the webview's own content process is
/// not included, so measure the total with Instruments (iOS) or
/// `adb shell dumpsys meminfo` (Android). Frame times are Flutter's, counted
/// from the model's ready mark; the webview's own frame rate is not.
final class ModelDebugOverlay extends StatefulWidget {
  const ModelDebugOverlay({
    super.key,
    required this.stats,
    required this.child,
  });

  final ModelLoadStats stats;
  final Widget child;

  @override
  State<ModelDebugOverlay> createState() => _ModelDebugOverlayState();
}

final class _ModelDebugOverlayState extends State<ModelDebugOverlay> {
  final _frames = FrameStats();
  late final int? _rssAtMount = _rss();
  int? _rssNow;
  Timer? _tick;

  static int? _rss() {
    try {
      return ProcessInfo.currentRss;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _rssNow = _rssAtMount;
    widget.stats.addListener(_onStats);
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _rssNow = _rss());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final hz = View.maybeOf(context)?.display.refreshRate ?? 60;
    _frames.budgetMs = 1000 / (hz > 0 ? hz : 60);
  }

  void _onStats() {
    // Steady-state frames only: the load itself is in the marks.
    if (widget.stats.marks.lastOrNull?.label == 'ready') _frames.reset();
    if (mounted) setState(() {});
  }

  void _onTimings(List<FrameTiming> timings) {
    if (widget.stats.isReady) _frames.add(timings);
  }

  @override
  void dispose() {
    _tick?.cancel();
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    widget.stats.removeListener(_onStats);
    super.dispose();
  }

  String _mb(int bytes) => '${bytes ~/ (1024 * 1024)}MB';

  @override
  Widget build(BuildContext context) {
    final stats = widget.stats;
    final rss = _rssNow;
    final base = _rssAtMount;
    final lines = [
      '#${stats.mount} ${stats.warmUp} ${stats.src.split('/').last}',
      stats.marks.map((m) => '${m.label} ${m.ms}').join(' · '),
      if (stats.model != null) 'model ${stats.model}',
      if (stats.error != null) 'error ${stats.error}',
      if (rss != null && base != null)
        'app RSS ${_mb(rss)} (${rss >= base ? '+' : '-'}${_mb((rss - base).abs())}) '
            'excl. webview process',
      if (stats.isReady)
        'since ready: $_frames'
      else
        'loading ${stats.elapsedMs}ms',
    ];
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          left: 4,
          top: 4,
          right: 4,
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.topLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xB3000000),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    lines.join('\n'),
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 9,
                      height: 1.3,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
