# model_3d

Renders a policy-backed 3D model driven by a state → clip table.

Camera easing, auto-rotation, inertia, return and progress motion follow the
installed source's `frameRate`, without requesting Flutter frames. The default
`Model3dSource.frameRate` is null (display-rate vsync); Filament defaults to
60 fps. Speeds and durations stay time-based. `TickerMode` pauses hidden
views and they resume from the paused value; pointer drags still update the
camera directly.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `src` | `text` | — | `null` | Yes | model source path or URL. |
| `outfit` | map | — | `{}` | Yes | named parts, recolouring and socket props; see [Outfit](#outfit). |
| `scene` | list | — | `[]` | Yes | extra models in the same view; see [Scene](#scene). |
| `poster` | `text` | — | `null` | Yes | image shown until the model is ready, and instead of it when no renderer is installed or loading fails. Resolved through the installed `ImageSource`. |
| `fit` | `boxFit` | fill, contain, cover, fit_width, fit_height, none, scale_down | `contain` | Yes | poster fitting mode. |
| `width` | `size` (scaled by EngineMetrics) | — | `null` | Yes | sets the box width. |
| `height` | `size` (scaled by EngineMetrics) | — | `null` | Yes | sets the box height. |
| `aspect_ratio` | `number` | — | `1` | Yes | width-to-height ratio used unless both `width` and `height` are set. |
| `state` | `text` | — | `null` | Yes | the state to enter; changing it plays that state's clip. |
| `state_trigger` | any | — | `null` | Yes | re-enters `state` whenever this value changes, so the same state can replay (e.g. bind a tap counter). |
| `states` | map | — | `{}` | Yes | state name → `{ clip, loop, next }`. `clip` names an animation in the model; `loop` (default `false`) repeats it; `next` is the state entered when a non-looping clip ends. |
| `crossfade_duration` | `integer` | — | `200` | Yes | blend time between clips in milliseconds. The first clip after a load starts without a blend. |
| `controls` | map | — | `null` | Yes | how gestures move the camera; see [Camera and gestures](#camera-and-gestures). Without it, gestures pass through to ancestors. |
| `interactive` | `flag` | — | `false` | Yes | shorthand for `controls: { rotate: free }` when `controls` is absent. |
| `camera` | map | — | `{}` | Yes | the resting camera `{ yaw, pitch, zoom, target, duration }`; see [Camera and gestures](#camera-and-gestures). |
| `lighting` | map | — | `{}` | Yes | Environment multiplier and rotation, optional directional light; see [Lighting and shadows](#lighting-and-shadows). |
| `shadow` | text or map | none, contact, cast, `{ type, opacity }` | `none` | Yes | Ground contact ellipse; cast also enables model self-shadowing with a key light. Opacity defaults to 0.5. |
| `on_tap_model` | text | action name | `null` | Yes | Dispatches `{node, material}` for a model hit; empty space does nothing. |
| `quality` | text | low, medium, high | `medium` | Yes | Renderer quality preset; see below. |
| `exposure` | number | finite stops | `0` | Yes | Overall brightness, in stops. |
| `auto_rotate` | `number` or `flag` | — | `0` | Yes | degrees per second the camera orbits on its own; `true` is 30. Pauses while the user drags. |
| `progress` | map | — | `null` | Yes | holds one clip at a playhead the template sets: `{ clip, at, value, speed }`; see [Progress](#progress). |
| `on_progress_end` | `text` | — | `null` | Yes | action dispatched when the `progress` playhead arrives at the clip's end. The event payload is `{ clip }`. |
| `on_progress_arrive` | `text` | — | `null` | Yes | action dispatched when the `progress` playhead settles at a target the template changed. The event payload is `{ clip, at }` (`at` in milliseconds); see [Progress](#progress). |
| `on_state_end` | `text` | — | `null` | Yes | action dispatched when a state's non-looping clip ends. The event payload is `{ state }`; branch on it with `_when: '${event.state == "jump"}'`. |
| `on_ready` | `text` | — | `null` | Yes | action dispatched once the model is ready for the current `src`. |
| `on_error` | `text` | — | `null` | Yes | action dispatched each time the model fails to load for the current `src`: the first load and every retry. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

A character that idles, jumps on tap, and returns to idle:

```yaml
_type: model_3d
src: /assets/character.glb
poster: /assets/character.png
height: 200
state: '${mood}'
state_trigger: '${taps}'
states:
  idle: { clip: Idle, loop: true }
  jump: { clip: Jump, next: idle }
on_state_end: landed
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

`state_trigger: '${taps}'` lets every tap replay `jump`, even while `mood` already is `jump`.

A model in a scrolling feed that turns sideways, springs back, and spins slowly:

```yaml
_type: model_3d
src: /assets/egg.glb
height: 200
camera: { pitch: 15 }
controls: { rotate: horizontal, return_duration: 400 }
auto_rotate: 20
```

A dispenser whose lever moves one stage per tap, through stops placed at the animation's beats. Every tap buzzes, but a tap only advances once the previous stage has landed:

```yaml
_type: model_3d
src: /assets/dispenser.glb
height: 200
progress:
  clip: Sequence
  at: '${[0, 1100, 2250, 3600, 3800, 6200][min(taps, 5)]}'
on_progress_end: reward
on_progress_arrive: landed
_scope:
  _state:
    taps: 0
    moving: false
  _action:
    tap_lever:
      - { _type: sys_haptic, variant: chip, _background: true }
      - _type: set
        _when: '${not moving}'
        taps: '${taps + 1}'
        moving: true
    landed:
      _type: set
      moving: false
_on:
  tap: { do: tap_lever, ripple: false }
```

## Camera and gestures

The camera orbits the primary model's extent centre, or its `target` when set. Its angles are in degrees, unlike the radians of 2D `transform` and motion `rotate`, since 3D cameras are conventionally set in degrees. The engine computes it each frame from the resting `camera`, accumulated `auto_rotate`, and the user's gesture offset, and hands it to the renderer.

`camera`:

| Key | Default | Meaning |
| --- | --- | --- |
| `yaw` | `0` | degrees around the vertical axis; 0 faces the model's front, positive moves the camera toward the model's right. |
| `pitch` | `0` | degrees above the horizon; positive looks down on the model. |
| `zoom` | `1` | magnification; 1 frames the whole model, 2 is twice as close. |
| `target` | extent centre | finite `[x, y, z]` in primary glTF units, or primary node name. A missing node falls back to the extent centre; animated nodes are resolved as they move. Changes ease with yaw/pitch/zoom. |
| `duration` | `300` | how long a change to `camera` takes to ease in, in milliseconds. |

Bind `camera` to state to turn the model from an action, e.g. `camera: { yaw: '${facing}' }` with a `set` that changes `facing`.

`controls`:

| Key | Default | Meaning |
| --- | --- | --- |
| `rotate` | `free` | `none`, `horizontal`, `vertical` or `free`: which drag axes turn the camera. |
| `min_pitch` | `-60` | lowest pitch in degrees for vertical dragging. |
| `max_pitch` | `60` | highest pitch in degrees for vertical dragging. |
| `min_zoom` | none | smallest pinch magnification. |
| `max_zoom` | none | largest pinch magnification. Pinch is off unless `min_zoom` or `max_zoom` is set; the one left out is `1`. |
| `pan` | `false` | two-finger drag moves the model with the fingers in the view plane; can run together with pinch. No pan inertia. |
| `max_pan` | `0.5` | maximum accumulated pan vector length relative to the primary framed size (world-extent diagonal); drag deltas divide by the viewport's shorter side. |
| `sensitivity` | `1` | multiplies the base rate of half a degree per logical pixel. |
| `inertia` | `true` | a fling keeps the camera turning and slowing down. |
| `return_duration` | none | after release, ease back to `camera` over this many milliseconds; without it the camera and pan stay where they were left. Pan returns to zero. |

Gestures go through Flutter's gesture arena. `rotate: horizontal` claims only horizontal drags, so an enclosing scroll view still scrolls vertically over the model. `free`, `vertical` and pinch zoom claim drags in their directions over the model, so use them where the model is not inside a scroll view in that direction. Taps are never claimed, so `_on: tap` on the model or an ancestor still fires.

## Progress

`progress` turns one long clip into steps the template controls, e.g. a lever that moves a stage per tap. The engine owns the playhead: it shows the clip at the target time and, when the target changes, plays toward it at the clip's own pace and stops there.

| Key | Default | Meaning |
| --- | --- | --- |
| `clip` | — | the animation to hold; required. |
| `at` | — | target in milliseconds into the clip. Wins over `value`. |
| `value` | `0` | target as a fraction of the clip, 0 to 1. |
| `speed` | `1` | playback rate toward a new target, in either direction: `1` is the clip's own pace, `2` twice as fast; `0` jumps. |

- The first target after a load shows at once, without playing: a model that mounts with `taps: 3` from the server appears at stage 3.
- A target that moves on while the playhead is still on its way (fast taps) is followed without a jump; a target behind the playhead plays backward.
- Targets are clamped to the clip. `on_progress_end` dispatches when the playhead arrives at the clip's end by moving there — not when a model loads already at its end.
- `on_progress_arrive` dispatches once the playhead settles at a target the template changed: after playing there, or at once when it jumps (`speed: 0`, a new `clip`), already holds the target, or has no clip to play (`at` is then `null`). A target replaced mid-way does not arrive; only the last one does. The first target after a load does not dispatch, but a target changed while loading does once the clip attaches. At the clip's end it follows `on_progress_end`.
- To ignore taps while the motion plays, gate the step on a state the arrival clears (see the dispenser in [Examples](#examples)). The gate lives in the template, so it can instead queue taps, or give ignored taps their own haptic.
- Drive the progress clip from `progress` only. `states` may play other clips at the same time when they animate other parts of the model.

## Loading, failure and visibility

The app installs the renderer (see [Media](../../media.md#3d-models)). Without one, `model_3d` renders `poster` only. `poster` shows until the model is ready and fades out above it. A `src` change replaces the model; `state`, `camera`, `controls` and `auto_rotate` changes keep it.

A failed load keeps `poster` and is tried again when the view shows again or the app returns to the foreground — a weak network may have dropped the download. Each retry dispatches `on_error` if it fails, or `on_ready` and plays `state` from the start once it loads.

Animation is decoration. When no renderer is installed, the model fails to load, the model lacks a state's clip, or the clip fails to play, a non-looping state ends at once: `on_state_end` dispatches and `next` is followed exactly as if the clip had played. A chain of such states stops where its `next` comes back to one it already ended, so a cycle with nothing to play never spins. While the model is still loading, a state waits and plays once it is ready.

The same holds for `progress`: without the clip, a `value` that changes to 1 or more dispatches `on_progress_end` at once. An `at` target cannot be judged without the clip's length, so it never ends there; prefer `value` when a flow waits on the end. A target that reaches the end while the model is loading dispatches once the clip attaches there. `on_progress_arrive` likewise dispatches at once on every target change when the clip cannot play, so a template gated on it never stalls.

While an inactive tab or a covering route hides the view, a looping state's clip stops and plays again once the view shows, so a hidden loop does not keep the renderer drawing. Camera motion, `progress` and `auto_rotate` pause and go on from where they stopped, without catching up the hidden time; a non-looping clip plays to its end and its state ends as usual.

## Pitfalls & related

- Use only the documented positional child form; `_slots` are rejected for this specification kind.
- Set `poster`: without it the box stays empty while the model loads and after a failed load. Keep it the same framing as the model's first frame so the swap is not noticeable.
- Keep one or two models per screen: renderer views are heavy.
- Inside a vertical scroll view, use `controls: { rotate: horizontal }` so vertical drags keep scrolling.
- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- See [Media](../../media.md#3d-models) for the renderer contract, and return to the [widget catalog](../README.md).

## Lighting and shadows

All four look props update at runtime without loading the model again or flashing
its poster. Invalid fields fall back individually to their defaults. Declare
`_requires: [model_3d_look_v1]` at the root to reject engines that do not know this
feature; the declaration is optional (older engines ignore these props).

```yaml
_type: model_3d
src: /assets/character.glb
lighting:
  environment: 0.7
  environment_rotation: 30
  light: { yaw: 45, pitch: 45, intensity: 1, color: '#FFFFFF' }
shadow: { type: cast, opacity: 0.5 }
quality: high
exposure: 0.5
```

`lighting.environment` is a non-negative multiplier of the source's IBL intensity
(default 1); `environment_rotation` turns it around the vertical axis in degrees
(default 0). `light` defaults to absent; `false` removes it. Its default yaw and
pitch are 45°, intensity is 1 (non-negative) and color is white. Angles use the
camera frame: the light comes from that direction (yaw 0 = front, positive toward
+X, positive pitch above the horizon). Filament maps intensity 1 to 100,000 lux
and converts the supplied sRGB color to linear RGB.

`contact` draws a soft dark ground ellipse under the normalized model, visible
on a transparent background. `cast` adds model cast/receive self-shadowing when
a light exists and keeps the ellipse; without a light it behaves as contact.
The contact opacity accepts 0–1 (default 0.5). There is no opaque floor.

Filament presets: low = FXAA, low render quality, AO off; medium = FXAA, medium
render quality, AO off; high = MSAA + FXAA, high render quality, AO on and PCSS
soft cast shadows. Thermion exposes MSAA as a boolean; the effective sample count
is backend dependent and has not been measured for this change. No new color
grading is attached at exposure 0, preserving the default picture.


## Scene

`scene` adds independently loaded GLBs beside the primary `src` model. Each list
index is a slot: retaining its `src` preserves its native asset while transforms,
clip and spin update; a changed `src` replaces only that slot. Duplicate sources
are independent instances sharing cached bytes. A failed extra is logged and
skipped. `on_ready` and poster readiness depend only on the primary model.

```yaml
_type: model_3d
src: /assets/character.glb
state: walk
states:
  walk: { clip: Walk, loop: true }
scene:
  - src: /assets/planet.glb
    position: [0, -1, 0]
    rotation: { yaw: 0, pitch: 0, roll: 0 }
    scale: 1
    spin: { axis: x, speed: 12 }
camera: { target: Head, zoom: 2, duration: 500 }
controls: { rotate: free, pan: true, max_pan: 0.5, return_duration: 400 }
```

Position defaults to `[0,0,0]`, rotation to zero degrees and scale to `1`.
All placements use primary glTF world units (metres for assets exported that
way), retaining authored transforms. The placement matrix is
`translation × yaw(Y) × pitch(X) × roll(Z) × uniform scale × spin`: spin rotates
about the extra's own origin on its local `x`, `y` or `z` axis, at signed degrees
per second. Optional `clip` names a looping animation in that extra.
Malformed entries, empty sources, invalid/non-finite vectors or spin values,
and non-positive scales are dropped.

The camera frames only the primary's bounding sphere (half its world-extent
diagonal); extras do not expand it. Lighting and cast/receive settings apply to
all models. Hidden views retain assets and spin phase, stop extra loops and
release their rendering hold; showing the view resumes without hidden-time spin.
Pan offsets both eye and focus opposite the drag so the model follows the fingers:
positive contract pan x moves the model right and positive y moves it down in the
camera plane. It does not change the framed distance.

`model_3d_scene_v1` is declare-only: root `_requires: [model_3d_scene_v1]` can
reject engines without this support; older engines otherwise ignore these props.


## Outfit

`outfit` dresses the primary character without reloading it or interrupting clips:

```yaml
outfit:
  show: [shirt_blue]
  hide: [shirt_red, body_torso]
  colors: { cloth_blue: '#4477FF' }
  attach: { Head: /assets/hat.glb, Hand: null }
  transition: pop
  transition_duration: 300
```

`show` and `hide` name GLB nodes (including their renderable descendants). A name
in both lists is shown. The nearest explicitly named ancestor or the node itself
controls visibility: hiding a child overrides showing its group, and showing a
child overrides hiding its group. Unmentioned nodes keep their authored visibility;
removing an override restores it. `colors` maps material names to base colour
factors; every primitive using that material changes, multiplying its texture.
Template colours are sRGB and are converted to linear factors before application.
Removing a colour restores its authored factor. Unknown names are logged and
ignored. Invalid map/list entries are dropped.

`attach` maps a primary node name to a separate GLB source loaded through the
same model cache. Any named node works; `socket_*` is the authoring convention.
Null or removal detaches and destroys the prop; a different source replaces it.
The viewer owns all prop resources.

The first outfit cuts immediately. Later changed parts enter/leave with `pop`
(default: scale with overshoot), `drop` (fall with bounce, shrink on exit),
`dissolve` (fade BLEND materials, otherwise pop), or `cut` (immediate).
Rigid parts use the scale/fall motion. Skinned parts use a brief emissive flash
on the changed part and a subtle whole-character pop (1 → 1.04 → 1) for `pop`,
`drop`, and opaque/masked `dissolve`; BLEND `dissolve` still fades. Skin joints
keep playing, and authored emissive values are restored after the flash.
`transition_duration` is milliseconds (default 300; zero cuts). Recolouring
cross-fades over the same duration. Unchanged parts keep their materials and local
transforms. A new request
settles the previous target before applying its own changes. Render frames stay
active until transitions finish.

Asset authoring contract: fixed bone names; one node per clothing variant;
`socket_*` empty nodes parented to bones; separate materials for recolourable
parts; body split into segments clothing can hide; rigid props authored with
their origin at the socket. Skinned clothing lives inside the character GLB;
separate props are rigid. Use glTF `alphaMode: BLEND` for dissolve.

`model_3d_outfit_v1` is declare-only: `_requires: [model_3d_outfit_v1]` rejects
older engines, which otherwise ignore `outfit`.

## Expressions and motion

Since 0.29.0; declare-only feature `model_3d_motion_v1`.

```yaml
_type: model_3d
src: /assets/character.glb
morphs: { smile: 0.7 }
morph_duration: 150
blink: { target: blink, every: 4000, duration: 150 }
look_at: { bone: head, target: camera, weight: 1, max_yaw: 60, max_pitch: 30, duration: 150 }
layer: { clip: Wave, loop: false, weight: 1 }
crossfade_duration: 200
on_layer_end: waved
```

`morphs` maps target names to finite weights in 0–1. Invalid weights are dropped;
unknown names are ignored. Changed weights ease from their current values over
`morph_duration` milliseconds (default 150); removing a name eases it to zero.
`blink: true` uses target `blink`, interval 4000ms with ±30% jitter and a 150ms
close/open pulse. The map form overrides those defaults. Disabled or hidden
views stop scheduling blink work; an idle blink does not hold renderer frames.

`look_at` adds a local rotation on top of the animated pose of `bone` (default
`head`); an absent bone disables it. `target` is `camera`, `pointer`, or a finite
`[x,y,z]` point in primary model units. Pointer tracking works independently of
camera controls: a touch moves the target over the view; release eases its weight
back to rest. `weight` is 0–1 (default 1), `max_yaw`/`max_pitch` are degree limits
(default 60/30; the yaw limit is capped at 170 so a target behind the model never
flips sides), and `duration` is the response time in ms (default 150). The head
turns at most 180° per second and, while the target is behind the model, keeps
facing the side it last saw it on.

`layer` plays a second named clip while the base state/progress clip continues.
Its authored channels override base channels; `loop` defaults false and `weight`
to 1. Changes/clear use `crossfade_duration` (default 200ms) as entrance/exit
weight envelopes. `on_layer_end` receives `{clip}` once per non-looping layer.
All props update without reloading the primary model. Hidden views pause motion.

Asset contract: name each mesh's morph targets consistently; several meshes may
share a target name. Name the head bone explicitly or use `head`. Author layer
clips with only the bones/channels they need (e.g. an arm wave); a full-body layer
overrides full-body base motion.

Filament limitations: while look-at or a layer is enabled, the renderer evaluates
base time → layer time → manual morphs → look-at → bone matrices in its frame
hook. Base clip changes cut in this mode. Layer weights/envelopes interpolate the
local node TRS produced by successive clip evaluations; this is not Thermion's
native clip crossfade or general weighted blending of animated morph channels.
Outside this mode, a playing clip can overwrite a manual weight it also animates;
use morph targets independent of that clip or enable renderer-driven posing.

## Model taps

```yaml
_type: model_3d
_requires: [model_3d_tap_v1]
src: /assets/character.glb
on_tap_model: part_selected
```

A hit carries the authored node name and a unique material name, each nullable.
Unnamed nodes stay null; when a renderable has different or unnamed materials,
`material` is null. Picks finish after roughly two or three renderer frames and
return no hit after 150 milliseconds without a result or after disposal. Drags,
multiple pointers, cancelled gestures and long presses do not trigger model taps.
The raw pointer listener does not compete with ancestor tap recognizers. Without
`on_tap_model`, no picking is requested and ancestor taps still work. Existing
camera gesture controls still apply.

The feature identifier is declare-only. Hosts implement the optional exported
`Model3dTapController` with `Future<Model3dHit?> hitTest(Offset localPosition)`.
The engine's internal dispatch returns null without that capability, preserving
existing `implements SduiModel3dController` hosts. Picking addresses the primary
model, including skinned and morphed meshes, using entity ids without requesting
accessible geometry buffers.
