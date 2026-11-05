import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sdui_engine/src/contract/model_3d_source.dart';

import '../../../../log/engine_log.dart';
import '../../../../media/model_3d_source_registry.dart';
import '../../../../util/props_resolver.dart';
import '../../../contract/action_sink.dart';
import '../../primitive/image_widget.dart';
import 'model_3d_camera_rig.dart';
import 'model_3d_progress.dart';

/// `model_3d` — Renders a policy-backed 3D model driven by a state → clip table.
///
/// ```yaml
/// _type: model_3d
/// src: /assets/character.glb
/// poster: /assets/character.png
/// height: 200
/// state: '${mood}'
/// states:
///   idle: { clip: Idle, loop: true }
///   jump: { clip: Jump, next: idle }
/// ```
///
/// Props:
/// - `src` (`text`, default `null`) — model source path or URL.
/// - `poster` (`text`, default `null`) — image shown until the model is ready, and instead of it when no renderer is installed or loading fails.
/// - `fit` (`boxFit`, default `contain`) — poster fitting mode. Values: fill | contain | cover | fit_width | fit_height | none | scale_down.
/// - `width` (`size` (scaled by EngineMetrics), default `null`) — sets the box width.
/// - `height` (`size` (scaled by EngineMetrics), default `null`) — sets the box height.
/// - `aspect_ratio` (`number`, default `1`) — width-to-height ratio used unless both `width` and `height` are set.
/// - `state` (`text`, default `null`) — the state to enter; changing it plays that state's clip.
/// - `state_trigger` (`any`, default `null`) — re-enters `state` whenever this value changes, so the same state can replay (e.g. bind a tap counter).
/// - `states` (`map`, default `{}`) — state name → `{ clip, loop, next }`. `clip` names an animation in the model; `loop` (default `false`) repeats it; `next` is the state entered when a non-looping clip ends.
/// - `crossfade_duration` (`integer`, default `200`) — blend time between clips in milliseconds.
/// - `controls` (`map`, default `null`) — how gestures move the camera: `{ rotate, min_pitch, max_pitch, min_zoom, max_zoom, sensitivity, inertia, return_duration }`. `rotate` is none | horizontal | vertical | free (default free); `min_pitch`/`max_pitch` limit pitch in degrees (default -60/60); `min_zoom`/`max_zoom` limit pinch magnification (no pinch when both are absent, an absent one is 1); `sensitivity` multiplies half a degree per pixel (default 1); `inertia` keeps a fling turning (default true); `return_duration` eases back to `camera` over that many milliseconds after release (stays put when absent). Without it, gestures pass through to ancestors.
/// - `interactive` (`flag`, default `false`) — shorthand for `controls: { rotate: free }` when `controls` is absent.
/// - `camera` (`map`, default `{}`) — the resting camera `{ yaw, pitch, zoom, duration }`: degrees around (0 = front, positive toward the model's right), degrees above the horizon, magnification (1 frames the whole model); changes ease over `duration` milliseconds (default 300).
/// - `auto_rotate` (`number` or `flag`, default `0`) — degrees per second the camera orbits on its own (`true` is 30); pauses while the user drags.
/// - `progress` (`map`, default `null`) — holds one clip at a playhead the template sets: `{ clip, at, value, speed }`. `at` is milliseconds into the clip, `value` a 0–1 fraction (`at` wins); the playhead plays toward a changed target at `speed` (default 1, the clip's own pace; 0 jumps). The first target after a load shows at once.
/// - `on_progress_end` (`text`, default `null`) — action dispatched when the `progress` playhead arrives at the clip's end.
/// - `on_progress_arrive` (`text`, default `null`) — action dispatched, with `{clip, at}` (`at` in milliseconds), when the playhead settles at a target the template changed: after playing there, at once when it jumps or nothing can play. A target replaced mid-way does not arrive. Lets a template ignore taps until the motion lands.
/// - `on_state_end` (`text`, default `null`) — action dispatched, with `{state}`, when a state's non-looping clip ends.
/// - `on_ready` (`text`, default `null`) — action dispatched once the model is ready for the current `src`.
/// - `on_error` (`text`, default `null`) — action dispatched each time the model fails to load for the current `src`: the first load and every retry.
///
/// Child: none.
///
/// Rendering delegates to the app-installed model policy. Animation is
/// decoration: when no renderer is installed, loading fails, or a clip is
/// missing, a non-looping state ends immediately, so `on_state_end` and
/// `next` still run and template flows never wait on the renderer.
final class Model3dWidget {
  const Model3dWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
    ActionSink? dispatch,
  ) {
    final src = PropsResolver.text(props['src']);
    final poster = PropsResolver.text(props['poster']);
    if ((src == null || src.isEmpty) && (poster == null || poster.isEmpty)) {
      return const SizedBox.shrink();
    }
    final (camera, cameraDuration) = parseModel3dCamera(props['camera']);
    return _Model3dView(
      src: src == null || src.isEmpty ? null : src,
      poster: poster == null || poster.isEmpty ? null : poster,
      fit: PropsResolver.text(props['fit']) ?? 'contain',
      width: PropsResolver.size(context, props['width']),
      height: PropsResolver.size(context, props['height']),
      aspectRatio: PropsResolver.number(props['aspect_ratio']) ?? 1,
      state: PropsResolver.text(props['state']),
      stateTrigger: props['state_trigger'],
      states: _statesOf(props['states']),
      crossfade: Duration(
        milliseconds: PropsResolver.integer(props['crossfade_duration']) ?? 200,
      ),
      controls: Model3dControls.parse(
        props['controls'],
        interactive: PropsResolver.flag(props['interactive']) ?? false,
      ),
      camera: camera,
      cameraDuration: cameraDuration,
      autoRotate: parseAutoRotate(props['auto_rotate']),
      progress: Model3dProgress.parse(props['progress']),
      onProgressEnd: PropsResolver.text(props['on_progress_end']),
      onProgressArrive: PropsResolver.text(props['on_progress_arrive']),
      onStateEnd: PropsResolver.text(props['on_state_end']),
      onReady: PropsResolver.text(props['on_ready']),
      onError: PropsResolver.text(props['on_error']),
      dispatch: dispatch,
    );
  }

  static Map<String, _Model3dStateEntry> _statesOf(Object? raw) {
    if (raw is! Map) return const {};
    final states = <String, _Model3dStateEntry>{};
    for (final MapEntry(:key, :value) in raw.entries) {
      if (key is! String || value is! Map) continue;
      final clip = PropsResolver.text(value['clip']);
      if (clip == null || clip.isEmpty) {
        EngineLog.warn('model state "$key" has no clip', tag: 'model_3d');
        continue;
      }
      states[key] = _Model3dStateEntry(
        clip: clip,
        loop: PropsResolver.flag(value['loop']) ?? false,
        next: PropsResolver.text(value['next']),
      );
    }
    return states;
  }
}

final class _Model3dStateEntry {
  const _Model3dStateEntry({
    required this.clip,
    required this.loop,
    required this.next,
  });

  final String clip;
  final bool loop;
  final String? next;
}

enum _Phase { loading, ready, unavailable }

class _Model3dView extends StatefulWidget {
  const _Model3dView({
    required this.src,
    required this.poster,
    required this.fit,
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.state,
    required this.stateTrigger,
    required this.states,
    required this.crossfade,
    required this.controls,
    required this.camera,
    required this.cameraDuration,
    required this.autoRotate,
    required this.progress,
    required this.onProgressEnd,
    required this.onProgressArrive,
    required this.onStateEnd,
    required this.onReady,
    required this.onError,
    required this.dispatch,
  });

  final String? src;
  final String? poster;
  final String fit;
  final double? width;
  final double? height;
  final double aspectRatio;
  final String? state;
  final Object? stateTrigger;
  final Map<String, _Model3dStateEntry> states;
  final Duration crossfade;
  final Model3dControls controls;
  final Model3dCamera camera;
  final Duration cameraDuration;
  final double autoRotate;
  final Model3dProgress? progress;
  final String? onProgressEnd;
  final String? onProgressArrive;
  final String? onStateEnd;
  final String? onReady;
  final String? onError;
  final ActionSink? dispatch;

  @override
  State<_Model3dView> createState() => _Model3dViewState();
}

class _Model3dViewState extends State<_Model3dView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  SduiModel3dController? _controller;
  late final Model3dCameraRig _rig;
  late final Model3dPlayhead _playhead;

  /// Whether `progress` changed while the model was loading: a target that
  /// is the clip's end then still dispatches once the clip attaches there.
  bool _movedWhileLoading = false;
  _Phase _phase = _Phase.loading;
  int _generation = 0;

  /// The state the view is in — set by the template or advanced by `next`.
  String? _active;

  /// Counts state entries, so the end of one entry never ends a later entry
  /// of the same state.
  int _entered = 0;

  /// [Model3dPlayback.completions] when the active clip started.
  int _baseline = 0;

  /// The first clip after a load starts without a crossfade.
  bool _played = false;

  /// Off while an inactive tab or a covering route hides the view.
  ValueListenable<bool>? _shown;

  /// Whether the active looping clip is stopped until the view shows again:
  /// a hidden loop would keep the renderer drawing frames nobody sees.
  bool _held = false;

  /// Whether the last load failed. It is tried again when the view shows or
  /// the app resumes: a weak network may have dropped the download.
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _rig = Model3dCameraRig(
      vsync: this,
      rest: widget.camera,
      controls: widget.controls,
      autoRotate: widget.autoRotate,
      onChanged: (camera) => _controller?.setCamera(camera),
    );
    _playhead = Model3dPlayhead(
      vsync: this,
      onPose: (clip, time) => _controller?.setPose(clip, time),
      onEnd: _endProgressSoon,
      onArrive: _arriveSoon,
    );
    _load();
  }

  void _load() {
    _disposeController();
    final generation = ++_generation;
    _phase = _Phase.loading;
    _failed = false;
    _active = widget.state;
    _played = false;
    _playhead.detach();
    _movedWhileLoading = false;
    final source = Model3dSourceRegistry.current;
    final src = widget.src;
    if (source == null || src == null) {
      _phase = _Phase.unavailable;
      scheduleMicrotask(() {
        if (_isCurrent(generation)) _enter(_active);
      });
      return;
    }
    unawaited(_create(source, src, generation));
  }

  bool _isCurrent(int generation) => mounted && generation == _generation;

  Future<void> _create(Model3dSource source, String src, int generation) async {
    try {
      final controller = await source.controllerFor(Model3dRequest(src: src));
      if (!_isCurrent(generation)) {
        await controller.dispose();
        return;
      }
      controller.setCamera(_rig.camera);
      // Mount the view (under the poster) before initialize: a renderer that
      // loads inside its view, such as a webview, completes from there.
      setState(() => _controller = controller);
      controller.addListener(_onPlayback);
      await controller.initialize();
      if (!_isCurrent(generation)) return;
      setState(() => _phase = _Phase.ready);
      _attachProgress(widget.progress);
      _dispatch(widget.onReady);
    } catch (error) {
      if (!_isCurrent(generation)) return;
      EngineLog.warn('model "$src" failed to load: $error', tag: 'model_3d');
      _disposeController();
      setState(() {
        _phase = _Phase.unavailable;
        _failed = true;
      });
      _attachProgress(widget.progress);
      _dispatch(widget.onError);
    }
    _enter(_active);
  }

  /// Enters [state]: plays its clip when the model is ready, waits while it
  /// loads, and otherwise ends a non-looping state at once.
  void _enter(String? state) {
    _active = state;
    _held = false;
    final entered = ++_entered;
    if (state == null) return;
    final entry = widget.states[state];
    if (entry == null) {
      EngineLog.warn('model has no state "$state"', tag: 'model_3d');
      return;
    }
    if (_phase == _Phase.loading) return;
    final controller = _controller;
    if (_phase == _Phase.ready && controller != null) {
      if (controller.clips.contains(entry.clip)) {
        if (entry.loop && !_isShown) {
          _held = true;
          return;
        }
        _baseline = controller.playback.completions;
        final crossfade = _played ? widget.crossfade : Duration.zero;
        _played = true;
        final generation = _generation;
        unawaited(
          controller
              .play(entry.clip, loop: entry.loop, crossfade: crossfade)
              .then(
                (_) {},
                onError: (Object error) {
                  EngineLog.warn(
                    'model clip "${entry.clip}" failed to play: $error',
                    tag: 'model_3d',
                  );
                  // Flows never wait on the renderer.
                  if (!entry.loop &&
                      _isCurrent(generation) &&
                      _entered == entered) {
                    _finishSoon(state);
                  }
                },
              ),
        );
        return;
      }
      EngineLog.warn(
        'model has no clip "${entry.clip}" for state "$state"',
        tag: 'model_3d',
      );
    }
    if (!entry.loop) _finishSoon(state);
  }

  void _onPlayback() {
    final controller = _controller;
    final state = _active;
    if (_phase != _Phase.ready || controller == null || state == null) return;
    final entry = widget.states[state];
    if (entry == null || entry.loop) return;
    final completions = controller.playback.completions;
    if (completions <= _baseline) return;
    _baseline = completions;
    _finishSoon(state);
  }

  /// Ends [state] outside the current build or listener callback, since the
  /// dispatched action may write scope state.
  void _finishSoon(String state) {
    final generation = _generation;
    final entered = _entered;
    scheduleMicrotask(() {
      if (!_isCurrent(generation) || _entered != entered) return;
      _dispatch(widget.onStateEnd, event: {'state': state});
      if (_entered != entered) return;
      final next = widget.states[state]?.next;
      if (next != null) _enter(next);
    });
  }

  /// Shows [progress]'s target on the loaded clip. Without that clip the
  /// playhead stays detached and a `value` end dispatches at once, so flows
  /// never wait on the renderer. A target the template [changed] (or moved
  /// while loading) arrives at once, since it is shown without playing.
  void _attachProgress(Model3dProgress? progress, {bool changed = false}) {
    final moved = _movedWhileLoading;
    _movedWhileLoading = false;
    if (progress == null) {
      _playhead.detach();
      return;
    }
    final controller = _controller;
    final duration = controller != null && _phase == _Phase.ready
        ? controller.clipDuration(progress.clip)
        : null;
    if (duration == null && controller != null && _phase == _Phase.ready) {
      EngineLog.warn(
        'model has no clip "${progress.clip}" for progress',
        tag: 'model_3d',
      );
    }
    _playhead.attach(progress, duration, endIfThere: moved);
    if (duration == null && moved && progress.endsWithoutClip) {
      _endProgressSoon();
    }
    if (moved || changed) _arriveSoon();
  }

  void _updateProgress(Model3dProgress? old, Model3dProgress? progress) {
    if (progress == null) {
      _playhead.detach();
      return;
    }
    final reachesEnd =
        progress.endsWithoutClip && !(old?.endsWithoutClip ?? false);
    if (_phase == _Phase.loading) {
      if (old != progress) _movedWhileLoading = true;
      return;
    }
    if (old?.clip != progress.clip || !_playhead.attached) {
      if (old?.clip != progress.clip) {
        _attachProgress(progress, changed: true);
        return;
      }
      if (reachesEnd) _endProgressSoon();
      _arriveSoon();
      return;
    }
    _playhead.retarget(progress);
  }

  void _endProgressSoon() {
    final generation = _generation;
    final clip = widget.progress?.clip;
    if (clip == null) return;
    scheduleMicrotask(() {
      if (!_isCurrent(generation)) return;
      _dispatch(widget.onProgressEnd, event: {'clip': clip});
    });
  }

  /// Dispatches `on_progress_arrive` with where the playhead settled; with
  /// no clip attached, the target cannot be placed and `at` is null.
  void _arriveSoon() {
    final generation = _generation;
    final clip = widget.progress?.clip;
    if (clip == null || widget.onProgressArrive == null) return;
    final at = _playhead.attached ? _playhead.position : null;
    scheduleMicrotask(() {
      if (!_isCurrent(generation)) return;
      _dispatch(
        widget.onProgressArrive,
        event: {'clip': clip, 'at': at == null ? null : (at * 1000).round()},
      );
    });
  }

  void _dispatch(String? action, {Object? event}) {
    if (action != null) widget.dispatch?.handle(action, event: event);
  }

  @override
  void didUpdateWidget(_Model3dView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controls != widget.controls ||
        oldWidget.autoRotate != widget.autoRotate) {
      _rig.update(controls: widget.controls, autoRotate: widget.autoRotate);
    }
    if (oldWidget.camera != widget.camera) {
      _rig.setRest(widget.camera, widget.cameraDuration);
    }
    if (oldWidget.src != widget.src) {
      _load();
      return;
    }
    if (oldWidget.progress != widget.progress) {
      _updateProgress(oldWidget.progress, widget.progress);
    }
    // A template that follows `next` (e.g. resets `mood` to idle in
    // on_state_end) catches up to a state already entered; only `state_trigger`
    // forces a replay.
    if (oldWidget.stateTrigger != widget.stateTrigger ||
        (oldWidget.state != widget.state && widget.state != _active)) {
      _enter(widget.state);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shown = TickerMode.getNotifier(context);
    if (shown == _shown) return;
    _shown?.removeListener(_onShown);
    _shown = shown..addListener(_onShown);
    _onShown();
  }

  bool get _isShown => _shown?.value ?? true;

  /// Stops the active looping clip while the view is hidden and plays it
  /// again once it shows. Camera, progress and auto-rotation run on tickers,
  /// which [TickerMode] already stops; a non-looping clip ends by itself.
  void _onShown() {
    if (_isShown) {
      if (_failed) {
        _retry();
      } else if (_held) {
        _enter(_active);
      }
      return;
    }
    final controller = _controller;
    final state = _active;
    if (_held || _phase != _Phase.ready || controller == null) return;
    final entry = state == null ? null : widget.states[state];
    if (entry == null ||
        !entry.loop ||
        !controller.clips.contains(entry.clip)) {
      return;
    }
    _held = true;
    unawaited(
      controller.stop().then(
        (_) {},
        onError: (Object error) => EngineLog.warn(
          'model clip "${entry.clip}" failed to stop: $error',
          tag: 'model_3d',
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _retry();
  }

  /// Loads a failed model again while the view shows; a hidden view waits
  /// until [_onShown].
  void _retry() {
    if (!_failed || !_isShown) return;
    setState(_load);
  }

  void _disposeController() {
    _generation++;
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    controller.removeListener(_onPlayback);
    unawaited(controller.dispose());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shown?.removeListener(_onShown);
    _disposeController();
    _rig.dispose();
    _playhead.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final poster = widget.poster;
    final placeholder = poster == null
        ? const SizedBox.shrink()
        : SizedBox.expand(
            child: ImageWidget.build(context, {
              'src': poster,
              'fit': widget.fit,
            }, const {}),
          );
    final controller = _controller;
    final ready = _phase == _Phase.ready && controller != null;
    // The view stays mounted from controller creation on — swapping it in on
    // ready would recreate a platform view — and the poster fades out above.
    // It never takes pointers: gestures go to the rig, which moves the camera
    // the same way for every renderer.
    final view = Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null)
          KeyedSubtree(
            key: ObjectKey(controller),
            child: IgnorePointer(child: controller.buildView()),
          ),
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: ready ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: placeholder,
          ),
        ),
      ],
    );
    final content = Model3dGestureLayer(
      rig: _rig,
      controls: widget.controls,
      enabled: ready,
      child: view,
    );
    final width = widget.width;
    final height = widget.height;
    if (width != null && height != null) {
      return SizedBox(width: width, height: height, child: content);
    }
    return SizedBox(
      width: width,
      height: height,
      child: AspectRatio(aspectRatio: widget.aspectRatio, child: content),
    );
  }
}
