# serpentine

Measures rows, draws their serpentine track, then paints cells.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `spacing` | `size`, scaled | — | `0` | Yes | gap between rows. |
| `turn_radius` | `size` or `String` `auto`, scaled | — | `auto` | Yes | U-turn radius; `auto` derives it from measured row links. |
| `anchor` | `alignment` | top_left, top_center, top_right, center_left, center, center_right, bottom_left, bottom_center, bottom_right | `center` | Yes | point inside each cell through which the track passes. |
| `overhang` | `size`, scaled | — | = the track's stroke width | Yes | how far the track extends past the widest row's cell edges, so the U-turns wrap around the outside of the end cells instead of stopping at their centres. |
| `track` | `Map` | — | empty | Yes | base track style: `color` (`color`, default black), `gradient` (`gradient`, default `null`, wins over color), and `width` (`size`, scaled, default `2`). |
| `progress` | `Map` | — | `null` | Yes | completed-track style: `index` (`number`, fractional, default `null`), `color` (`color`, default base color), and `gradient` (`gradient`, default `null`, wins over color). |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. The name `serpentine` is also a recognized `_loop._wrap` strategy. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: serpentine
_children:
  - _type: text
    value: First
```

```yaml
_type: serpentine
_scope:
  _action:
    announce:
      _type: toast
      message: Activated
_on:
  tap:
    do: announce
    ripple: false
_children:
  - _type: text
    value: Tap target
```

## Pitfalls & related

- Use only the documented positional child form; `_slots` are rejected for this specification kind.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
