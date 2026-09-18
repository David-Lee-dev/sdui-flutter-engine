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

`_motion` accepts a non-empty name, a map with non-empty `type`, or a non-empty list of names/maps. Parameters are recursively expression-bindable. Composite user parameters are merged over every atom's preset defaults.

## Common scheduling parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `duration` | non-negative finite milliseconds | `300` (`shimmer`: `1200`) | One animation leg. |
| `curve` | name | `ease_out` (`shimmer`: `linear`) | `linear`, `ease`, `ease_in`, `ease_out`, `ease_in_out`, `fast_out_slow_in`, `bounce_out`, `elastic_out`, `decelerate`. Unknown names use the atom fallback. |
| `delay` | non-negative finite milliseconds | `0` | Initial delay. |
| `repeat` | bool | `false` (`shimmer`: `true`) | Repeats until disposal/change. |
| `reverse` | bool | `false` | Alternates direction when repeating. |
| `trigger` | any | `null` | Runtime restart identity. |

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

Unknown preset names fall through as atom names and must be registered in `MotionFactory` or resolution throws at runtime.

## Custom motion atoms

`Motion`, `MotionParams`, and `MotionPlan` are exported by `package:sdui_engine/sdui_engine.dart`. Implement the three-part atom contract:

- `type` is the non-empty template-facing name used by `_motion`.
- `plan(params)` returns the duration, curve, delay, repeat/reverse behavior, and optional restart trigger. `MotionPlan.from(params)` applies the standard scheduling parameters while allowing atom-specific defaults.
- `frame(context, t, child, params)` returns the child wrapped in the visual state for normalized, curve-adjusted progress `t` from 0 to 1. Read atom-specific values through `MotionParams` so malformed dynamic input falls back safely.

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
