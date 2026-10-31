# Control flow and morphing

Conditions and switches select directive branches, while `_morph` exposes an animated value to one child subtree.

## Node `_if`

Any ordinary widget node may carry `_if: '${predicate}'`. It must be one whole non-empty expression; the widget renders only when truthy. `_if` can combine with `_scope` and `_loop` according to the wrapper order described in [Concepts](concepts.md#compile-pipeline).

## `cond`

`cond` is a control node: it takes `_children` and no widget props. Each child has exactly one `_if` expression or `_else: true`; only one fallback is allowed.

```yaml
_type: cond
_children:
  - _type: text
    _if: '${score >= 90}'
    value: Excellent
  - _type: text
    _if: '${score >= 60}'
    value: Passing
  - _type: text
    _else: true
    value: Try again
```

The first truthy branch wins. A condition may contain only `_if`, `_loop`, `_scope`, and `_presence` as control-node markers; branch marker keys are stripped before the child is compiled. Every branch is validated even when inactive and must satisfy the parent's layout protocol.

## `switch`

`switch` requires a whole-expression `_value` and at least one `_case`. Case values are literal strings, numbers, or booleans; expressions and duplicates are rejected. One `_default: true` is optional.

```yaml
_type: switch
_value: '${status}'
_children:
  - { _type: text, _case: ready, value: Ready }
  - { _type: text, _case: 404, value: Missing }
  - { _type: text, _default: true, value: Unknown }
```

Matching uses the evaluator's structural equality. A switch control node allows `_value`, `_if`, `_loop`, `_scope`, and `_presence` only; like `cond`, it takes no widget props.

## Presence transitions

Since 0.16.0 a structural change is a transition owned by the directive that made it, on by default. When `_if`, `cond`, or `switch` inserts content, its slot grows from nothing to the content's size; when it removes content, the content plays its exit motions (`_motion` entries with `on: exit` or `on: both`, see [Motion](motion.md#exit-motions)) and the slot collapses, then the content leaves. A branch change (if↔else, case A→B) shows both while the size goes from A's to B's; an output without phase motions of its own crossfades. Eager loops (`column`, `row`, `wrap`) do the same per item (see [Loops](loops.md#presence)), and a `_scope` `_skeleton` swaps to its content the same way.

| Phase | Default | Curve |
| --- | --- | --- |
| enter | 300 ms | `emphasized_decelerate` |
| exit | 250 ms | `emphasized_accelerate` |
| swap | 300 ms | `emphasized` |

The app sets these once with `SduiPresentation(presence: PresenceStyle(...))`. A node tunes or turns them off with `_presence`, which applies to every structural directive of that node (`_if`, `_loop`, `_scope` skeleton, `cond`, `switch`):

```yaml
- _type: cond
  _presence: false                 # instant, as before 0.16
- _type: container
  _if: '${banner != null}'
  _presence: { order: sequential, duration: 200 }
  _motion: [pop_in, { type: fade, on: exit }]
```

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `space` | bool | `true` | Animate the slot size. `false` keeps the exit motions but the size changes at once. |
| `order` | `parallel` or `sequential` | `parallel` | `sequential`: exit motions finish before the slot collapses, and the slot expands before entrance motions start. |
| `duration` | milliseconds | style | Length of every phase. |
| `curve` | curve name or `[x1, y1, x2, y2]` | style | Curve of every phase. |

An unknown `_presence` key fails to compile; a malformed value takes its default. Declare `_requires: [presence_v1]` for `_presence` and `on:`.

Rules:

- The first build, reduced motion (`MediaQuery.disableAnimations`) and a page whose tickers are muted (another route on top, an inactive tab) never animate: content appears and leaves at once.
- Exits run only at the directive that removed the content. Popping or pushing a route, removing an ancestor, reseeding a template or hot reload remove content without exits.
- Content that comes back while it exits reverses in place, on the same element and state.
- Leaving content keeps the values it showed last (bindings do not update), takes no taps, gives up keyboard focus, is left out of semantics, sees no action host (its widgets cannot dispatch), and its `_scope` lifecycle hooks pause; they resume, without `remount`, if it comes back. `dispose` hooks still fire when it is removed.
- A `reveal_*` motion in the content owns the space in its phase, so the slot does not also animate the size.
- Sliver bodies, `dismissible` bodies and lazy loops stay instant. A parent-data body (`expanded`, `flexible`, `positioned`, `positioned_fill`, `spacer`) keeps its parent data: it plays its exit motions in place without a size animation, still receives taps while it exits but they dispatch nothing (it sees no action host), gives up keyboard focus when its exit starts, and a new branch replaces it at once. Widgets the app registers (`Engine.initialize(widgets:)`) are placed in place the same way, with no space animation, since they may return parent data.

## `_morph`

`_morph` animates from a scalar/numeric source to `_to` and exposes the current interpolated value under `_as`:

| Key | Type | Default |
| --- | --- | --- |
| `_to` | whole expression or scalar number/bool | required |
| `_from` | whole expression or scalar | previous/current target behavior when omitted |
| `_as` | bindable identifier | required |
| `_duration` | non-negative integer ms | `400` |
| `_curve` | string | `ease_out` |
| `_delay` | non-negative integer ms | `0` |
| `_trigger` | expression or scalar | none |
| `_repeat` | bool | `false` |
| `_reverse` | bool | `false` |
| `_spring` | preset name or literal `{stiffness, damping_ratio, mass}` | none (tween) |

```yaml
_type: opacity
_morph:
  _from: 0
  _to: '${visible ? 1 : 0}'
  _as: alpha
  _duration: 250
opacity: '${alpha}'
_child: { _type: text, value: Ready }
```

The morph variable is readable only by its child and is not writable state. `_curve` uses the same resolver as `_motion` (names, Material 3 easings, `[x1, y1, x2, y2]` beziers and spring curves; see [Motion](motion.md#curves)). A spring curve name without `_duration` runs for the spring's settle time instead of 400 ms. When the platform asks to reduce motion (`MediaQuery.disableAnimations`) the variable jumps to every target, including with `_repeat` (since 0.9.0).

### `_velocity`

`_velocity: <name>` adds a second variable holding the value's current rate of change, in `_to` units per second (since 0.9.0, `_requires: [spring_v2]`). Like `_as` it is readable only by the child.

```yaml
_type: transform
_morph:
  _to: '${offset}'
  _as: x
  _velocity: vx
  _spring: spatial_default
rotate: '${clamp(vx / 4000, -0.2, 0.2)}'
_child: { _type: text, value: Drag }
```

- With `_spring` it is the simulation's velocity; for a tween, the curve's slope times `(_to - _from)` over the duration, negative on a reversing `_repeat` leg.
- It is `0` when the value is at rest, before the first run, under reduced motion and in a morph without animation. Non-finite results read as `0`; the magnitude is clamped to 10,000.
- An unbindable name (`'v-x'`) is a compile error like `_as`; a non-string or empty value drops only this variable (a child that reads it then fails as an undeclared binding).

### When a morph is misused or fails

A morph never fails the template or stops the app, in debug and release alike (since 0.7.0). Only typos are compile errors:

- **Compile error (typo):** an unknown `_morph` key, an `_as` name that cannot be referenced as a binding (e.g. `line-item`), an unknown `_spring` preset name or `_spring` map key, and expression syntax errors.
- **No morph:** a `_morph` value that is not a map, or a missing, empty or non-string `_as`. The child renders without the morph (a child that still reads the name then fails as any undeclared binding does).
- **Morph without animation:** any other malformed value — a missing `_to`, a `_to`/`_from`/`_trigger` that is neither an expression nor a scalar, `_duration`/`_delay` that are not non-negative integers, a `_curve` that is neither a string nor a list, non-bool `_repeat`/`_reverse`, `_repeat` with `_duration: 0`, and every `_spring` misuse listed [below](#_spring). The `_as` variable is still provided and equals the evaluated `_to` immediately, following every `_to` change at once. An unknown curve *name* or a malformed bezier list still falls back to `ease_out`.
- **Runtime:** when evaluating `_to`, `_from` or `_trigger` throws or yields something that is not a finite number, the variable keeps its last good value; before any good value it uses a valid `_from`, and otherwise it is `null`.

None of this reaches `SduiErrorObserver` or `NodeGuard`; a debug build logs one `animation off (...)` line per node and reason. See [Error handling](errors.md#motion-and-morph-never-fail).

### `_spring`

`_spring` replaces the duration/curve tween with a spring simulation. A target change starts a new simulation from the current value and, except for `effect_default`, the current velocity, so a retarget mid-flight continues smoothly. Since 0.7.0.

```yaml
_type: align
_morph:
  _to: '${tab}'
  _as: lens
  _spring: spatial_default
alignment: '${[remap(lens, 0, 3, -0.9, 0.9), 0]}'
_child: { _type: sizedbox, width: 72, height: 52 }
```

| Preset | Stiffness | Damping ratio | Velocity on retarget |
| --- | --- | --- | --- |
| `spatial_fast` | 1400 | 0.8 | kept |
| `spatial_default` | 700 | 0.75 | kept |
| `spatial_slow` | 300 | 0.85 | kept |
| `effect_default` | 800 | 1.0 | reset to 0 |

A literal map gives `stiffness` (1–5000, required), `damping_ratio` (0.2–2, required) and `mass` (0.1–10, default 1). Mass is 1 in every preset.

- An unknown preset name or an unknown map key is a typo and fails compilation with the node path.
- Any other misuse gives a morph without animation instead of a compile error: an expression (`'${preset}'`), a value that is neither a name nor a map (`5`, `true`, `null`), a missing, non-numeric, non-finite or out-of-range parameter, or combining `_spring` with `_duration`, `_curve`, `_repeat` or `_reverse`.
- `_from`, `_delay` and `_trigger` work as for the tween; a trigger restarts from `_from` at rest.
- A target equal to the current target is ignored. A target that is not a finite number, or whose expression fails to evaluate, keeps the previous target; with no good target yet the value is a valid `_from`, else `null`.
- A simulation that has not settled after 5 seconds snaps to its target. When the platform asks to reduce motion (`MediaQuery.disableAnimations`), the value jumps to the target; turning it on mid-flight or during `_delay` stops there at velocity `0`, and turning it off again does not replay (since 0.10.1).
- The morph's direct widget (a plain node) is drawn in its own `RepaintBoundary`, inside a parent-data widget such as `expanded`; so is the direct widget of a tween with `_repeat`. One-shot tweens add nothing (since 0.9.0). A sliver node (`sliver_to_box_adapter`, `sliver_list`, ...) gets no boundary, since a sliver must stay the direct child of its viewport (since 0.10.1).

Older engines reject `_spring` as an unknown morph key; declare `_requires: [spring_v1]` at the template root (see [Concepts](concepts.md#reserved-keys)).

