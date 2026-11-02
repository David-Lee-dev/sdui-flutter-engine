# model

Renders a policy-backed 3D model driven by a state → clip table.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `src` | `text` | — | `null` | Yes | model source path or URL. |
| `poster` | `text` | — | `null` | Yes | image shown until the model is ready, and instead of it when no renderer is installed or loading fails. Resolved through the installed `ImageSource`. |
| `fit` | `boxFit` | fill, contain, cover, fit_width, fit_height, none, scale_down | `contain` | Yes | poster fitting mode. |
| `width` | `size` (scaled by EngineMetrics) | — | `null` | Yes | sets the box width. |
| `height` | `size` (scaled by EngineMetrics) | — | `null` | Yes | sets the box height. |
| `aspect_ratio` | `number` | — | `1` | Yes | width-to-height ratio used unless both `width` and `height` are set. |
| `state` | `text` | — | `null` | Yes | the state to enter; changing it plays that state's clip. |
| `state_key` | any | — | `null` | Yes | re-enters `state` whenever this value changes, so the same state can replay (e.g. bind a tap counter). |
| `states` | map | — | `{}` | Yes | state name → `{ clip, loop, next }`. `clip` names an animation in the model; `loop` (default `false`) repeats it; `next` is the state entered when a non-looping clip ends. |
| `crossfade_ms` | `integer` | — | `200` | Yes | blend time between clips in milliseconds. The first clip after a load starts without a blend. |
| `controls` | map | — | `null` | Yes | how gestures move the camera; see [Camera and gestures](#camera-and-gestures). Without it, gestures pass through to ancestors. |
| `interactive` | `flag` | — | `false` | Yes | shorthand for `controls: { rotate: free }` when `controls` is absent. |
| `camera` | map | — | `{}` | Yes | the resting camera `{ yaw, pitch, zoom, duration_ms }`; see [Camera and gestures](#camera-and-gestures). |
| `auto_rotate` | `number` or `flag` | — | `0` | Yes | degrees per second the camera orbits on its own; `true` is 30. Pauses while the user drags. |
| `progress` | map | — | `null` | Yes | holds one clip at a playhead the template sets: `{ clip, at, value, speed }`; see [Progress](#progress). |
| `on_progress_end` | `text` | — | `null` | Yes | action dispatched when the `progress` playhead arrives at the clip's end. The event payload is `{ clip }`. |
| `on_state_end` | map | — | `{}` | Yes | state name → action dispatched when that state's non-looping clip ends. The event payload is `{ state }`. |
| `on_ready` | `text` | — | `null` | Yes | action dispatched once the model is ready for the current `src`. |
| `on_error` | `text` | — | `null` | Yes | action dispatched once if the model fails to load for the current `src`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol and takes no children. See [Concepts](../../concepts.md#box-and-sliver-protocols).

## Rendering contract

The engine ships no renderer. The app installs one through `Sdui.initialize(modelSource: ...)` — a webview `<model-viewer>`, Filament, SceneKit, or anything that implements `ModelSource`:

- `ModelSource.controllerFor(ModelRequest(src))` returns an unloaded `SduiModelController`.
- The widget calls `initialize()`, reads `clips`, and drives `play(clip, loop:, crossfade:)`.
- The widget calls `setCamera(ModelCamera(yaw, pitch, zoom))` right after creation and on every frame the camera moves.
- For `progress`, the widget reads `clipDuration(clip)` once the model is ready and calls `setPose(clip, time)` on every frame the playhead moves. The renderer stops its own playback of that clip and holds the pose. The renderer's view never receives pointers; the engine handles gestures, so every renderer moves the same way for the same template.
- A non-looping clip holds its last frame and advances `ModelPlayback.completions`; the engine detects a clip end by that counter.
- `ModelSource.warmUp()` runs once in the background after boot, so a renderer can do its expensive first-time setup (such as creating a webview) before the first `model` mounts.

Without an installed source, `model` renders `poster` only. A `src` change disposes and replaces the controller; `state`, `camera`, `controls` and `auto_rotate` changes reuse it.

## Camera and gestures

The camera orbits the model's centre. The engine computes it each frame from the resting `camera`, accumulated `auto_rotate`, and the user's gesture offset, and hands it to the renderer.

`camera`:

| Key | Default | Meaning |
| --- | --- | --- |
| `yaw` | `0` | degrees around the vertical axis; 0 faces the model's front, positive moves the camera toward the model's right. |
| `pitch` | `0` | degrees above the horizon; positive looks down on the model. |
| `zoom` | `1` | magnification; 1 frames the whole model, 2 is twice as close. |
| `duration_ms` | `300` | how long a change to `camera` takes to ease in. |

Bind `camera` to state to turn the model from an action, e.g. `camera: { yaw: '${facing}' }` with a `set` that changes `facing`.

`controls`:

| Key | Default | Meaning |
| --- | --- | --- |
| `rotate` | `free` | `none`, `horizontal`, `vertical` or `free`: which drag axes turn the camera. |
| `pitch` | `[-60, 60]` | pitch limits in degrees for vertical dragging. |
| `zoom` | none | `[min, max]` pinch magnification; without it pinch is off. |
| `sensitivity` | `1` | multiplies the base rate of half a degree per logical pixel. |
| `inertia` | `true` | a fling keeps the camera turning and slowing down. |
| `return_ms` | none | after release, ease back to `camera` over this many milliseconds; without it the camera stays where it was left. |

Gestures go through Flutter's gesture arena. `rotate: horizontal` claims only horizontal drags, so an enclosing scroll view still scrolls vertically over the model. `free`, `vertical` and any `zoom` claim drags in their directions over the model, so use them where the model is not inside a scroll view in that direction. Taps are never claimed, so `_on: tap` on the model or an ancestor still fires.

## Progress

`progress` turns one long clip into steps the template controls, e.g. a lever that moves a stage per tap. The engine owns the playhead: it shows the clip at the target time and, when the target changes, plays toward it at the clip's own pace and stops there.

| Key | Default | Meaning |
| --- | --- | --- |
| `clip` | — | the animation to hold; required. |
| `at` | — | target in seconds into the clip. Wins over `value`. |
| `value` | `0` | target as a fraction of the clip, 0 to 1. |
| `speed` | `1` | clip seconds played per second toward a new target, in either direction; `0` jumps. |

- The first target after a load shows at once, without playing: a model that mounts with `taps: 3` from the server appears at stage 3.
- A target that moves on while the playhead is still on its way (fast taps) is followed without a jump; a target behind the playhead plays backward.
- Targets are clamped to the clip. `on_progress_end` dispatches when the playhead arrives at the clip's end by moving there — not when a model loads already at its end.
- Drive the progress clip from `progress` only. `states` may play other clips at the same time when they animate other parts of the model.

## Animation never blocks a flow

Animation is decoration. When no renderer is installed, the model fails to load, or the model lacks a state's clip, a non-looping state ends at once: `on_state_end` dispatches and `next` is followed exactly as if the clip had played. While the model is still loading, a state waits and plays once it is ready.

The same holds for `progress`: without the clip, a `value` that changes to 1 or more dispatches `on_progress_end` at once. An `at` target cannot be judged without the clip's length, so it never ends there; prefer `value` when a flow waits on the end. A target that reaches the end while the model is loading dispatches once the clip attaches there.

## Examples

A character that idles, jumps on tap, and returns to idle:

```yaml
_type: model
src: /assets/character.glb
poster: /assets/character.png
height: 200
state: '${mood}'
state_key: '${taps}'
states:
  idle: { clip: Idle, loop: true }
  jump: { clip: Jump, next: idle }
on_state_end:
  jump: landed
_scope:
  _state:
    mood: idle
    taps: 0
  _action:
    hop:
      _type: set
      mood: jump
      taps: '${taps + 1}'
    landed:
      _type: set
      mood: idle
_on:
  tap: { do: hop, ripple: false }
```

`state_key: '${taps}'` lets every tap replay `jump`, even while `mood` already is `jump`.

A model in a scrolling feed that turns sideways, springs back, and spins slowly:

```yaml
_type: model
src: /assets/egg.glb
height: 200
camera: { pitch: 15 }
controls: { rotate: horizontal, return_ms: 400 }
auto_rotate: 20
```

A dispenser whose lever moves one stage per tap, through stops placed at the animation's beats:

```yaml
_type: model
src: /assets/dispenser.glb
height: 200
progress:
  clip: Sequence
  at: '${[0, 1.1, 2.25, 3.6, 3.8, 6.2][min(taps, 5)]}'
on_progress_end: reward
_scope:
  _state:
    taps: 0
  _action:
    tap_lever:
      _type: set
      taps: '${taps + 1}'
_on:
  tap: { do: tap_lever, ripple: false }
```

## Pitfalls & related

- Keep one or two models per screen: renderer views are heavy, and webview-backed renderers cost memory per instance.
- Inside a vertical scroll view, use `controls: { rotate: horizontal }` so vertical drags keep scrolling.
- Keep `poster` the same framing as the model's first frame so the swap from poster to model is not noticeable.
- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- See [Media](../../media.md) for the image and video policies, and return to the [widget catalog](../README.md).
