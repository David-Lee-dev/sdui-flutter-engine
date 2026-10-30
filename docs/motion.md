# Motion

`_motion` wraps a widget with one or more registered motion atoms, either named directly or expanded from a composite preset.

## Declaration

```yaml
_type: text
value: Saved
_motion: fade_slide_up
```

```yaml
_type: icon
name: refresh
_motion:
  - { type: rotate, begin: 0, end: 6.2832, duration: 900, curve: linear, repeat: true }
  - { type: tint, begin: '#66FFFFFF', end: '#00FFFFFF', blend: src_atop }
```

`_motion` accepts a non-empty name, a map with non-empty `type`, or a list of names/maps. Parameters are recursively expression-bindable. Composite user parameters are merged over every atom's preset defaults.

## Failure never stops the template

A motion only ever decorates its widget, so since 0.7.0 nothing about it can fail the template or the app — in debug and release alike. The one exception is a typo:

- **Compile error (typo):** a motion or preset name that is not registered (`unknown motion`), and expression syntax errors in parameters.
- **Layer dropped at compile time:** a `_motion` value that is not a name, map or list (e.g. `5`, `null`), a list entry that is neither, an empty name, or a map with a missing, empty or non-string `type`. Only that entry is dropped; the other layers stay. An empty list means no layers. Unknown parameter keys are ignored, as before.
- **Layer turned off at runtime:** if evaluating a layer's parameters throws, or the atom's `plan()` or `frame()` throws (built-in or app-registered), or a repeating plan has no duration, that layer is off for the rest of the node's life. The widget is drawn at rest as if the layer were absent; the other layers keep running.
- **Out-of-range values:** numbers, offsets and durations beyond ±1,000,000 (ms for durations) fall back to the atom default, like any other malformed value.

Nothing in these cases reaches `SduiErrorObserver` or `NodeGuard`; a debug build logs one `animation off (...)` line per node and reason under the `widget` tag. See [Error handling](errors.md#motion-and-morph-never-fail).

## Common scheduling parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `duration` | milliseconds, 0–1,000,000 | `300` (`shimmer`: `1200`); a spring curve's settle time | One animation leg. |
| `curve` | name or `[x1, y1, x2, y2]` | `ease_out` (`shimmer`: `linear`) | See [Curves](#curves). Unknown names and malformed lists use the atom fallback. |
| `delay` | milliseconds, 0–1,000,000 | `0` | Initial delay, measured from when the start gate opens (see below). |
| `repeat` | `true` or a leg count 1–1000 | `false` (`shimmer`: `true`) | `true` repeats until disposal/change; a count runs that many legs and stops at the end of the last one. Since 0.9.0 for counts. |
| `repeat_delay` | milliseconds, 0–1,000,000 | `0` | Pause between two repeated legs, holding the end of the leg just run. Since 0.9.0. |
| `reverse` | bool | `false` | Alternates direction when repeating. |
| `trigger` | any | `null` | Runtime restart identity; also restarts a leg count. |
| `start` | `'visible'` or `'mount'` | `'visible'` | Inside an ancestor `Scrollable`, `'mount'` skips the start gate below and starts (counting `delay`) as soon as the layer mounts. Since 0.13.0. |

A `repeat` value that is neither a bool nor a whole number in 1–1000 (`0`, `2.5`, `1001`, `'x'`) falls back to the atom default, and an invalid `repeat_delay` to `0`. With `reverse`, odd legs run backwards, so `repeat: 2, reverse: true` goes there and back and stops at the start. A counted or pausing repeat detects each leg's end on the frame after it is due, so the next leg may start up to one frame late. Declare `_requires: [motion_repeat_v1]` for counts and `repeat_delay`. A `start` value other than `'mount'` (an unknown string, or any non-string) falls back to `'visible'`. Declare `_requires: [motion_start_v1]` for `start: 'mount'`.

### Curves

`curve` (and `_morph._curve`) accepts, since 0.9.0 (`_requires: [curve_v2]`):

- The names `linear`, `ease`, `ease_in`, `ease_out`, `ease_in_out`, `fast_out_slow_in`, `bounce_out`, `elastic_out`, `decelerate`.
- Material 3 easings: `emphasized`, `emphasized_decelerate` (0.05, 0.7, 0.1, 1), `emphasized_accelerate` (0.3, 0, 0.8, 0.15), `standard` (0.2, 0, 0, 1), `standard_decelerate` (0, 0, 0, 1), `standard_accelerate` (0.3, 0, 1, 1).
- A cubic bezier `[x1, y1, x2, y2]` of four finite numbers. `x1`/`x2` are clamped to 0–1; a `y` beyond ±10, a non-number or a wrong length uses the fallback.
- Spring curves `spatial_fast`, `spatial_default`, `spatial_slow`, `effect_default`: the matching [`_spring` preset](control-flow.md#_spring) run from 0 to 1 at rest, stretched so its settle time maps to the end. Without an explicit `duration` the motion runs for that settle time; with one, the spring is squeezed into it. It overshoots like the spring does.

### Reduced motion

When the platform asks to reduce motion (`MediaQuery.disableAnimations`), every `_motion` layer draws its end state at once (t = 1) and runs nothing: delays, repeats and `shimmer` stop there, and a `trigger` change keeps the end state. A one-shot layer whose `reverse` flips shows the start state instead. Turning reduced motion on mid-run jumps to the end. Since 0.9.0.

### Repaint isolation

A repeating layer wraps its child in a `RepaintBoundary`, so the animation repaints only the moving subtree. The decision is made when the layer mounts. A one-shot layer adds nothing to the tree. Since 0.9.0. A layer on a sliver node gets no boundary (since 0.10.1).

### Parent-data widgets

`_motion` and `_on` work on `positioned`, `positioned_fill`, `expanded`, `flexible` and `spacer` since 0.9.0: their layers go around the node's child, inside the parent-data widget, so the parent still sees it directly. Older engines fail with "Incorrect use of ParentDataWidget"; declare `_requires: [parent_data_motion_v1]`.

`_motion` atoms are time-based tweens. For a value that follows changing state with spring physics (velocity carried across retargets), use `_morph` with `_spring`; see [Control flow](control-flow.md#_spring).

## Start gate inside a scrollable

Without an ancestor `Scrollable`, a motion starts as soon as it mounts, exactly as its
scheduling parameters describe.

With one or more ancestor `Scrollable`s (a `ListView`/`PageView` page, a `swipe_pane` page
including one only mirrored by another pane's drag via `jumpTo`, etc.), the motion instead
waits for a start gate: it begins (and starts counting `delay`) the first time its render box
is visible in every ancestor scrollable's viewport *and* every ancestor scroll position has
stopped moving. This keeps an off-screen or mid-drag `delay`/`duration` from elapsing before the
user can see the motion. Once the gate has opened and the motion has started, scrolling it off
screen and back never restarts it. A `trigger` change still restarts the motion immediately,
bypassing the gate, exactly as before. `repeat: true` motions wait on the same gate before their
first run.

Visibility is judged from the slot the motion occupies. When a motion's first frame collapses its
own box (a `reveal_*` starting at width or height 0), the slot keeps the motion's position and
takes the size of the first sized box beneath it. Known limits of that fallback: a collapsed
reveal aligned to the right or bottom edge of its parent can stay waiting when that edge sits
exactly at the viewport edge, and a collapsed multi-child layout is sized by its first child only.
Prefer left/top alignment for reveals inside scrollables.

`start: 'mount'` skips this gate entirely: the motion starts (and starts counting `delay`) as
soon as its layer mounts, whether or not it is on-screen and whether or not an ancestor is still
scrolling. A gated motion with a `delay` can look laggy — its content only appears well after the
user scrolls it into view — so `start: 'mount'` is for templates that want the motion running
before the user gets there; with it, an off-screen motion may finish before the user ever scrolls
to it. `trigger` restarts and reduced motion are unaffected either way.

## Atoms

| Atom | Specific parameters | Effect |
| --- | --- | --- |
| `fade` | `begin` number `0`, `end` number `1` | Opacity interpolation clamped to 0–1. |
| `move` | `begin` `[x,y]` `[0,0]`, `end` `[x,y]` `[0,0]` | Logical-pixel translation. |
| `scale` | `begin` number `1`, `end` number `1` | Uniform scale. |
| `rotate` | `begin` radians `0`, `end` `0`, `axis` `x|y|z` default `z`, `align` nine-direction default `center` | 2D Z rotation or perspective X/Y rotation; any non-`z`/`x` axis selects Y. |
| `blur` | `begin` sigma `8`, `end` `0` | Image-filter blur; sigma below .01 returns the child unchanged. |
| `tint` | `begin` color `#66000000`, `end` `#00000000`, `blend` | Color overlay; blend is `src_atop`, `modulate`, `overlay`, `color`, or `screen`; unknown defaults to `src_atop`. |
| `reveal` | `direction` | Clip/align reveal: `up` (default), `down`, `left`, `right`. |
| `saturate` | `begin` `0`, `end` `1` | Saturation matrix clamped to 0–2. |
| `shimmer` | `base` `#00FFFFFF`, `highlight` `#8CFFFFFF` | Repeating left-to-right `srcATop` highlight shader. |

## Composite presets

| Preset | Expansion |
| --- | --- |
| `fade_in` | `fade` |
| `reveal_up`, `reveal_down`, `reveal_left`, `reveal_right` | The matching `reveal(direction: up/down/left/right)` atom. |
| `blur_in` | `blur(begin: 8, end: 0)` |
| `color_in` | `saturate(begin: 0, end: 1)` |
| `slide_up` / `slide_down` | `move([0,24]→[0,0])` / `move([0,-24]→[0,0])` |
| `slide_left` / `slide_right` | `move([24,0]→[0,0])` / `move([-24,0]→[0,0])` |
| `drop` | `fade` + `move([0,-40]→[0,0], bounce_out, 500ms)` |
| `raise` | `fade` + `move([0,40]→[0,0], ease_out, 400ms)` |
| `zoom_in` | `scale(.8→1)` |
| `rotate_in` | `rotate(-.3→0)` |
| `flip_in` | `rotate(axis:y, 1.5708→0)` |
| `pop_in` | `scale(0→1, elastic_out, 600ms)` |
| `fade_slide_up`, `fade_slide_down`, `fade_slide_left`, `fade_slide_right` | `fade` plus the corresponding slide atom above. |
| `fade_scale` | `fade` + `scale(.92→1)` |
| `flip_fade_in` | `fade` + `rotate(axis:y, 1.2→0)` |
| `pulse` | `scale(1→1.06, ease_in_out, repeat, reverse, 700ms)` |
| `float` | `move([0,0]→[0,-8], ease_in_out, repeat, reverse, 1400ms)` |
| `bounce` | `move([0,0]→[0,-14], ease_out, repeat, reverse, 500ms)` |
| `blink` | `fade(.3→1, repeat, reverse, 700ms)` |
| `shake` | `move([-4,0]→[4,0], repeat, reverse, 70ms)` |
| `wobble` | `rotate(-.06→.06, repeat, reverse, 120ms)` |
| `swing` | `rotate(-.12→.12, ease_in_out, repeat, reverse, 700ms)` |
| `spin` | `rotate(0→6.2832, linear, repeat, 1200ms)` |
| `tada` | `scale(1→1.1, ease_in_out, repeat, reverse, 400ms)` + `rotate(-.05→.05, repeat, reverse, 200ms)` |

When the app boots through `Sdui.initialize` or `Engine.initialize`, the boot catalog includes every registered atom and composite preset. `EngineRunner` validates `_motion` against that snapshot, so an unknown name is a compile-fatal `unknown motion` validator error before mounting. A bare mount without initialization falls back to `Engine.snapshotCatalog()`, a live enumeration of every registered motion name, so this check still applies — an unknown `_motion` fails the same way. A server-side or build-time compiler using `LanguageCatalog.builtin()` gets the built-in atom and preset names declared in `BuiltinLanguage`, with no runtime involved at all.

## Custom motion atoms

`Motion`, `MotionParams`, and `MotionPlan` are exported by `package:sdui_engine/sdui_engine.dart`. Implement the three-part atom contract:

- `type` is the non-empty template-facing name used by `_motion`.
- `plan(params)` returns the duration, curve, delay, repeat/reverse behavior, and optional restart trigger. `MotionPlan.from(params)` applies the standard scheduling parameters while allowing atom-specific defaults.
- `frame(context, t, child, params)` returns the child wrapped in the visual state for normalized, curve-adjusted progress `t` from 0 to 1. Read atom-specific values through `MotionParams` so malformed dynamic input falls back safely.

A throw from `plan()` or `frame()` turns that layer off for the node's lifetime instead of failing the node (see [above](#failure-never-stops-the-template)), so a bug in an app atom shows up as a missing animation plus one debug log line, not as an error report.

```dart
import 'package:flutter/widgets.dart';
import 'package:sdui_engine/sdui_engine.dart';

final class LiftMotion extends Motion {
  const LiftMotion();

  @override
  String get type => 'app_lift';

  @override
  MotionPlan plan(MotionParams params) => MotionPlan.from(
    params,
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOut,
  );

  @override
  Widget frame(
    BuildContext context,
    double t,
    Widget child,
    MotionParams params,
  ) {
    final distance = params.number('distance', 16).toDouble();
    return Transform.translate(
      offset: Offset(0, distance * (1 - t)),
      child: child,
    );
  }
}
```

Register atoms during initialization, before the catalog freezes:

```dart
Sdui.initialize(
  // Required dependencies omitted.
  motions: const [LiftMotion()],
);
```

The atom is then available by name or map declaration:

```yaml
_motion: { type: app_lift, distance: 24, duration: 320 }
```
