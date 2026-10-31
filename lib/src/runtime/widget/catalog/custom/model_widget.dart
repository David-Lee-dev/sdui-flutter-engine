import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sdui_engine/src/contract/model_source.dart';

import '../../../log/engine_log.dart';
import '../../../media/model_source_registry.dart';
import '../../../util/props_resolver.dart';
import '../../contract/action_sink.dart';
import '../primitive/image_widget.dart';
import 'model_camera_rig.dart';

/// `model` — Renders a policy-backed 3D model driven by a state → clip table.
///
/// ```yaml
/// _type: model
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
/// - `state_key` (`any`, default `null`) — re-enters `state` whenever this value changes, so the same state can replay (e.g. bind a tap counter).
/// - `states` (`map`, default `{}`) — state name → `{ clip, loop, next }`. `clip` names an animation in the model; `loop` (default `false`) repeats it; `next` is the state entered when a non-looping clip ends.
/// - `crossfade_ms` (`integer`, default `200`) — blend time between clips in milliseconds.
/// - `controls` (`map`, default `null`) — how gestures move the camera: `{ rotate, pitch, zoom, sensitivity, inertia, return_ms }`. `rotate` is none | horizontal | vertical | free (default free); `pitch` is `[min, max]` degrees (default `[-60, 60]`); `zoom` is `[min, max]` pinch magnification (no pinch when absent); `sensitivity` multiplies half a degree per pixel (default 1); `inertia` keeps a fling turning (default true); `return_ms` eases back to `camera` after release (stays put when absent). Without it, gestures pass through to ancestors.
/// - `interactive` (`flag`, default `false`) — shorthand for `controls: { rotate: free }` when `controls` is absent.
/// - `camera` (`map`, default `{}`) — the resting camera `{ yaw, pitch, zoom, duration_ms }`: degrees around (0 = front, positive toward the model's right), degrees above the horizon, magnification (1 frames the whole model); changes ease over `duration_ms` (default 300).
/// - `auto_rotate` (`number` or `flag`, default `0`) — degrees per second the camera orbits on its own (`true` is 30); pauses while the user drags.
/// - `on_state_end` (`map`, default `{}`) — state name → action dispatched when that state's non-looping clip ends.
/// - `on_ready` (`text`, default `null`) — action dispatched once the model is ready for the current `src`.
/// - `on_error` (`text`, default `null`) — action dispatched once if the model fails to load for the current `src`.
///
/// Child: none.
///
/// Rendering delegates to the app-installed model policy. Animation is
/// decoration: when no renderer is installed, loading fails, or a clip is
/// missing, a non-looping state ends immediately, so `on_state_end` and
/// `next` still run and template flows never wait on the renderer.
final class ModelWidget {
  const ModelWidget._();

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
    final (camera, cameraDuration) = parseModelCamera(props['camera']);
    return _ModelView(
      src: src == null || src.isEmpty ? null : src,
      poster: poster == null || poster.isEmpty ? null : poster,
      fit: PropsResolver.text(props['fit']) ?? 'contain',
      width: PropsResolver.size(context, props['width']),
      height: PropsResolver.size(context, props['height']),
      aspectRatio: PropsResolver.number(props['aspect_ratio']) ?? 1,
      state: PropsResolver.text(props['state']),
      stateKey: props['state_key'],
      states: _statesOf(props['states']),
      crossfade: Duration(
        milliseconds: PropsResolver.integer(props['crossfade_ms']) ?? 200,
      ),
      controls: ModelControls.parse(
        props['controls'],
        interactive: PropsResolver.flag(props['interactive']) ?? false,
      ),
      camera: camera,
      cameraDuration: cameraDuration,
      autoRotate: parseAutoRotate(props['auto_rotate']),
      onStateEnd: _actionsOf(props['on_state_end']),
      onReady: PropsResolver.text(props['on_ready']),
      onError: PropsResolver.text(props['on_error']),
      dispatch: dispatch,
    );
  }

  static Map<String, _ModelStateEntry> _statesOf(Object? raw) {
    if (raw is! Map) return const {};
    final states = <String, _ModelStateEntry>{};
    for (final MapEntry(:key, :value) in raw.entries) {
      if (key is! String || value is! Map) continue;
      final clip = PropsResolver.text(value['clip']);
      if (clip == null || clip.isEmpty) {
        EngineLog.warn('model state "$key" has no clip', tag: 'model');
        continue;
      }
      states[key] = _ModelStateEntry(
        clip: clip,
        loop: PropsResolver.flag(value['loop']) ?? false,
        next: PropsResolver.text(value['next']),
      );
    }
    return states;
  }

  static Map<String, String> _actionsOf(Object? raw) {
    if (raw is! Map) return const {};
    return {
      for (final MapEntry(:key, :value) in raw.entries)
        if (key is String && value is String) key: value,
    };
  }
}

final class _ModelStateEntry {
  const _ModelStateEntry({
    required this.clip,
    required this.loop,
    required this.next,
  });

  final String clip;
  final bool loop;
  final String? next;
}

enum _Phase { loading, ready, unavailable }

class _ModelView extends StatefulWidget {
  const _ModelView({
    required this.src,
    required this.poster,
    required this.fit,
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.state,
    required this.stateKey,
    required this.states,
    required this.crossfade,
    required this.controls,
    required this.camera,
    required this.cameraDuration,
    required this.autoRotate,
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
  final Object? stateKey;
  final Map<String, _ModelStateEntry> states;
  final Duration crossfade;
  final ModelControls controls;
  final ModelCamera camera;
  final Duration cameraDuration;
  final double autoRotate;
  final Map<String, String> onStateEnd;
  final String? onReady;
  final String? onError;
  final ActionSink? dispatch;

  @override
  State<_ModelView> createState() => _ModelViewState();
}

class _ModelViewState extends State<_ModelView>
    with SingleTickerProviderStateMixin {
  SduiModelController? _controller;
  late final ModelCameraRig _rig;
  _Phase _phase = _Phase.loading;
  int _generation = 0;

  /// The state the view is in — set by the template or advanced by `next`.
  String? _active;

  /// [ModelPlayback.completions] when the active clip started.
  int _baseline = 0;

  /// The first clip after a load starts without a crossfade.
  bool _played = false;

  @override
  void initState() {
    super.initState();
    _rig = ModelCameraRig(
      vsync: this,
      rest: widget.camera,
      controls: widget.controls,
      autoRotate: widget.autoRotate,
      onChanged: (camera) => _controller?.setCamera(camera),
    );
    _load();
  }

  void _load() {
    _disposeController();
    final generation = ++_generation;
    _phase = _Phase.loading;
    _active = widget.state;
    _played = false;
    final source = ModelSourceRegistry.current;
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

  Future<void> _create(ModelSource source, String src, int generation) async {
    try {
      final controller = await source.controllerFor(ModelRequest(src: src));
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
      _dispatch(widget.onReady);
    } catch (error) {
      if (!_isCurrent(generation)) return;
      EngineLog.warn('model "$src" failed to load: $error', tag: 'model');
      _disposeController();
      setState(() => _phase = _Phase.unavailable);
      _dispatch(widget.onError);
    }
    _enter(_active);
  }

  /// Enters [state]: plays its clip when the model is ready, waits while it
  /// loads, and otherwise ends a non-looping state at once.
  void _enter(String? state) {
    _active = state;
    if (state == null) return;
    final entry = widget.states[state];
    if (entry == null) {
      EngineLog.warn('model has no state "$state"', tag: 'model');
      return;
    }
    if (_phase == _Phase.loading) return;
    final controller = _controller;
    if (_phase == _Phase.ready && controller != null) {
      if (controller.clips.contains(entry.clip)) {
        _baseline = controller.playback.completions;
        final crossfade = _played ? widget.crossfade : Duration.zero;
        _played = true;
        unawaited(
          controller.play(entry.clip, loop: entry.loop, crossfade: crossfade),
        );
        return;
      }
      EngineLog.warn(
        'model has no clip "${entry.clip}" for state "$state"',
        tag: 'model',
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
    scheduleMicrotask(() {
      if (!_isCurrent(generation) || _active != state) return;
      _dispatch(widget.onStateEnd[state], event: {'state': state});
      if (_active != state) return;
      final next = widget.states[state]?.next;
      if (next != null) _enter(next);
    });
  }

  void _dispatch(String? action, {Object? event}) {
    if (action != null) widget.dispatch?.handle(action, event: event);
  }

  @override
  void didUpdateWidget(_ModelView oldWidget) {
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
    // A template that follows `next` (e.g. resets `mood` to idle in
    // on_state_end) catches up to a state already entered; only `state_key`
    // forces a replay.
    if (oldWidget.stateKey != widget.stateKey ||
        (oldWidget.state != widget.state && widget.state != _active)) {
      _enter(widget.state);
    }
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
    _disposeController();
    _rig.dispose();
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
    final content = ModelGestureLayer(
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
