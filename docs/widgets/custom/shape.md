# shape

Paints a smooth union of circles, capsules and rounded rects. Since 0.7.0.

`shape` is decorative: it takes no children, ignores hit testing (taps reach whatever is under it) and adds no semantics. It fills its parent's constraints, so place it in a bounded parent such as `positioned_fill` or a sized `sizedbox`. An unbounded axis is sized `0` and logged once.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `shapes` | `List` of maps | 1–8 primitives (below) | empty | Yes | Primitives to union, in box-local coordinates. Items past the eighth are ignored and logged once. |
| `smooth` | `number` | 0–64 (clamped), scaled | `0` | Yes | Blend width of the union in logical pixels; `0` is a hard union. |
| `fill` | `color` | — | `#FF000000` | Yes | Fill color. |
| `rim` | `Map` | `color` (`color`, default transparent), `width` (`size`, 0–16 clamped) | none | Yes | A stroke centred on the union's edge. |

Each `shapes` item:

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `circle` \| `capsule` \| `rrect` | required | Primitive kind. |
| `align` | `alignment` (name or `[x, y]`) | `center` | Where a sized primitive sits in the box. |
| `offset` | `[x, y]`, scaled | `[0, 0]` | Shift after alignment. |
| `inset` | `[h, v]`, scaled | none | Deflates the box by `h` left/right and `v` top/bottom; wins over `width`/`height` and `align`. |
| `width` / `height` | `size` | none | Primitive size. A circle needs one of them (the shorter side is the diameter); `capsule` and `rrect` need both or neither. |
| `radius` | `size` | none | A circle's radius when no size is given; an `rrect`'s corner radius (clamped to half the shorter side). A capsule's radius is always half its shorter side. |

A primitive with no `inset` and no size fills the box. Coordinates and extents are clamped to ±16384.

An item whose value is invalid at runtime (an unknown `kind`, a non-finite or negative size, a malformed list) keeps the last valid form of that item; an item that has never been valid is left out until it is.

## Rendering

The smooth union is drawn by the engine's fragment shader (`shaders/sdf_shapes.frag`), which `Sdui.initialize` loads in the background. Until it is loaded, or where it cannot load, `shape` paints the hard union of the same primitives with `fill` and `rim` (no `smooth` blend). A paint failure is reported once through the error observer (`nodeBuild`) and the shape then paints nothing.

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

## Pitfalls & related

- Declare `_requires: [shape_v1]` (plus `spring_v1`, `math_v1`, `align_xy_v1` for the example above) at the template root so engines older than 0.7.0 reject the template with a clear reason.
- Interaction maps belong on a sibling or parent node; `shape` itself is not hit-testable.
- Return to the [widget catalog](../README.md).
