# spin_grid

Lays out children in a grid and cycles one highlighted cell.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `winner_index` | `integer` | — | required | Yes | child on which the cycle settles; invalid indices leave the grid at rest. |
| `trigger` | `any` | — | `null` | Yes | changing this value starts a new cycle. |
| `duration` | `integer` | — | `3300` | Yes | total cycle length in milliseconds. |
| `steps` | `integer` | — | `30` | Yes | number of highlight hops. |
| `dim_opacity` | `number` | — | `0.5` | Yes | opacity of unlit children. |
| `cross_axis_count` | `integer` | — | `3` | Yes | number of grid columns. |
| `main_axis_spacing` | `size` | — | `8` | Yes | scaled vertical grid gap. |
| `cross_axis_spacing` | `size` | — | `8` | Yes | scaled horizontal grid gap. |
| `child_aspect_ratio` | `number` | — | `0.7` | Yes | grid cell width-to-height ratio. |
| `on_finish` | `text` | — | `null` | Yes | action dispatched once after settling. |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. The name `spin_grid` is also a recognized `_loop._wrap` strategy. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: spin_grid
winner_index: 4
trigger: draw-17
duration: 3300
steps: 30
on_finish: reveal_prize
_children:
  - { _type: text, value: Prize }
```

```yaml
_type: spin_grid
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
