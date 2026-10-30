# shape

Paints circles, capsules and rounded rects folded together by smooth union, subtract and intersect. Since 0.7.0; `op`, per-item `smooth`, `at`, gradients, `shadow` and `backdrop` since 0.9.0 (`_requires: [shape_v2]`).

`shape` is decorative: it takes no children, ignores hit testing (taps reach whatever is under it) and adds no semantics. It fills its parent's constraints, so place it in a bounded parent such as `positioned_fill` or a sized `sizedbox`. An unbounded axis is sized `0` and logged once.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `shapes` | `List` of maps | 1–8 primitives (below) | empty | Yes | Primitives in box-local coordinates, folded left in list order. Items past the eighth are ignored and logged once. |
| `smooth` | `number` | 0–64 (clamped), scaled | `0` | Yes | Common blend width in logical pixels; `0` is a hard combination. |
| `fill` | `color` or gradient map | — | `#FF000000` | Yes | Fill color, or a `linear`/`radial`/`sweep` gradient map as in `container` `gradient` (`colors`, `stops`, `begin`/`end`, `center`, `radius`, …), spanning the shape's box. |
| `rim` | `Map` | `color` (`color`, default transparent) or `gradient` (gradient map), `width` (`size`, 0–16 clamped) | none | Yes | A stroke centred on the edge. `gradient` wins over `color`. |
| `shadow` | `Map` | `color` (`color`, default `#40000000`), `blur` (sigma, 0–40 clamped, default `0`), `offset` (`[x, y]`, scaled, default `[0, 0]`) | none | Yes | A blurred copy of the fill area under the shape. |
| `backdrop` | `Map` | `blur` (sigma, 0–40 clamped) | none | Yes | Blurs what is behind the shape's hard outline (frosted glass). |

Each `shapes` item:

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `circle` \| `capsule` \| `rrect` | required | Primitive kind. |
| `op` | `union` \| `subtract` \| `intersect` | `union` | How the item joins everything listed before it. Ignored on the first item. Since 0.9.0. |
| `smooth` | `number`, 0–64 clamped, scaled | the shape's `smooth` | This item's own blend width. Since 0.9.0. |
| `at` | `[fx, fy]` | none | Places the item's center at `fx` × width, `fy` × height of the box (`[0.5, 0]` is the top-center point). Wins over `align`. Since 0.9.0. |
| `align` | `alignment` (name or `[x, y]`) | `center` | Where a sized primitive sits in the box. |
| `offset` | `[x, y]`, scaled | `[0, 0]` | Shift after `at` or `align`. |
| `inset` | `[h, v]`, scaled | none | Deflates the box by `h` left/right and `v` top/bottom; wins over `width`/`height`, `at` and `align`. |
| `width` / `height` | `size` | none | Primitive size. A circle needs one of them (the shorter side is the diameter); `capsule` and `rrect` need both or neither. |
| `radius` | `size` | none | A circle's radius when no size is given; an `rrect`'s corner radius (clamped to half the shorter side). A capsule's radius is always half its shorter side. |

A primitive with no `inset` and no size fills the box (centered on `at` when given). Coordinates and extents are clamped to ±16384.

The fold is `d = item₁`, then for each later item `union` → `smoothMin(d, item)`, `subtract` → `smoothMax(d, −item)`, `intersect` → `smoothMax(d, item)`, each with that item's blend width. So `[bar, {circle, op: subtract}]` cuts the circle out of the bar, and a later `union` adds back on top of the result.

## Invalid values

- A literal unknown `op` value, or an unknown key in a literal `shapes` item, `shadow` or `backdrop` map, fails compilation as a typo.
- A bound value that is invalid at runtime (an unknown `kind` or `op`, a non-finite or negative size, a malformed `at` or list) keeps the last valid form of that item; an item that has never been valid is left out until it is. Nothing is reported.
- An invalid `fill` or `fill` gradient paints black, an invalid `rim.gradient` falls back to `rim.color`, and an invalid `shadow` or `backdrop` value turns that stage off. Nothing is reported.

## Rendering

The shape paints in four stages, in this order: `shadow`, `backdrop`, `fill`, `rim`. Each stage is isolated: if one fails while painting it is reported once through the error observer (`nodeBuild`) and only that stage stops painting; the others go on.

The smooth combination is drawn by the engine's fragment shader (`shaders/sdf_shapes.frag`), which `Sdui.initialize` loads in the background. Fill and rim coverage are painted separately, so a transparent fill with an opaque rim (or the reverse) works, and each takes its own gradient. Until the shader is loaded, or where it cannot load, `shape` paints the hard outline of the same primitives (`Path` union, difference and intersect in list order, no `smooth` blend): a smooth `subtract` then has sharp shoulders.

The shader paints only inside the shape's own box; keep primitives (and a dip's shoulder) inside it, or give the shape a larger box and position the primitives with `inset` or `at`.

`backdrop` clips the blur with the **hard** outline, because a blur layer can only be clipped by a path. Where a large `smooth` rounds a `subtract`, the blur therefore shows a little outside the painted edge. Measured on a 360×64 capsule with a radius-34 dip: about **8 px** at `smooth: 24` and about **20 px** at `smooth: 64` (`shape_geometry_test.dart`). With a faint glass fill this is hard to see; prefer a small `smooth` on a dip under a backdrop.

The shape sits in its own `RepaintBoundary`, so a shape that repaints every frame (a bound value animating) does not repaint its siblings. Each `backdrop` is a full-screen blur pass on the GPU; use one or two per screen.

## Protocol

This widget produces the **box** layout protocol and takes no children. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

A bar with a circle that merges into it and lifts to float 12px above it:

```yaml
_type: stack
_morph:
  _to: '${lifted ? 1 : 0}'
  _as: lift
  _spring: spatial_default
_children:
  - _type: positioned_fill
    _child:
      _type: shape
      shapes:
        - { kind: capsule, align: bottom_center, width: 360, height: 64 }
        - kind: circle
          align: [0, -1]
          radius: 28
          offset: '${[0, lerp(28, -12, lift)]}'
      smooth: '${lerp(20, 0, lift)}'
      fill: '#E61C1C1E'
      rim: { color: '#33FFFFFF', width: 1 }
```

A frosted glass bar whose top edge dips under the active tab of five, following a spring:

```yaml
_type: stack
_morph: { _to: '${tab}', _as: pos, _velocity: vel, _spring: spatial_default }
_children:
  - _type: positioned_fill
    _child:
      _type: shape
      shapes:
        - { kind: capsule, align: bottom_center, width: 360, height: 72 }
        - kind: circle
          op: subtract
          at: '${[(pos + 0.5) / 5, 0.32]}'
          radius: '${30 + clamp(abs(vel) * 2, 0, 8)}'
          smooth: 12
      fill: { colors: ['#2EFFFFFF', '#14FFFFFF'], begin: top_center, end: bottom_center }
      rim: { color: '#40FFFFFF', width: 1 }
      shadow: { color: '#33000000', blur: 12, offset: [0, 4] }
      backdrop: { blur: 16 }
```

## Pitfalls & related

- Declare `_requires: [shape_v1]` (and `shape_v2` for `op`, item `smooth`, `at`, gradients, `shadow`, `backdrop`; plus `spring_v1`, `spring_v2`, `math_v1`, `align_xy_v1` for the examples above) at the template root so older engines reject the template with a clear reason.
- `shadow.blur` and `backdrop.blur` are Gaussian sigmas like `backdrop_filter` `blur`, not `box_shadow` `blur_radius`, and are not scaled.
- Interaction maps belong on a sibling or parent node; `shape` itself is not hit-testable.
- Return to the [widget catalog](../README.md).
