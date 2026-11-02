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
| `interactive` | `flag` | — | `false` | Yes | lets the view handle camera gestures (orbit, zoom); when false, gestures pass through to ancestors. |
| `auto_rotate` | `flag` | — | `false` | Yes | slowly orbits the camera. |
| `on_state_end` | map | — | `{}` | Yes | state name → action dispatched when that state's non-looping clip ends. The event payload is `{ state }`. |
| `on_ready` | `text` | — | `null` | Yes | action dispatched once the model is ready for the current `src`. |
| `on_error` | `text` | — | `null` | Yes | action dispatched once if the model fails to load for the current `src`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol and takes no children. See [Concepts](../../concepts.md#box-and-sliver-protocols).

## Rendering contract

The engine ships no renderer. The app installs one through `Sdui.initialize(modelSource: ...)` — a webview `<model-viewer>`, Filament, SceneKit, or anything that implements `ModelSource`:

- `ModelSource.controllerFor(ModelRequest(src, interactive, autoRotate))` returns an unloaded `SduiModelController`.
- The widget calls `initialize()`, reads `clips`, and drives `play(clip, loop:, crossfade:)`.
- A non-looping clip holds its last frame and advances `ModelPlayback.completions`; the engine detects a clip end by that counter.
- `ModelSource.warmUp()` runs once in the background after boot, so a renderer can do its expensive first-time setup (such as creating a webview) before the first `model` mounts.

Without an installed source, `model` renders `poster` only. A `src` or `interactive`/`auto_rotate` change disposes and replaces the controller; a `state` change reuses it.

## Animation never blocks a flow

Animation is decoration. When no renderer is installed, the model fails to load, or the model lacks a state's clip, a non-looping state ends at once: `on_state_end` dispatches and `next` is followed exactly as if the clip had played. While the model is still loading, a state waits and plays once it is ready.

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

## Pitfalls & related

- Keep one or two models per screen: renderer views are heavy, and webview-backed renderers cost memory per instance.
- With `interactive: true` the view consumes drags, so it fights a parent scroll view; keep it false inside scrollables.
- Keep `poster` the same framing as the model's first frame so the swap from poster to model is not noticeable.
- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- See [Media](../../media.md) for the image and video policies, and return to the [widget catalog](../README.md).
