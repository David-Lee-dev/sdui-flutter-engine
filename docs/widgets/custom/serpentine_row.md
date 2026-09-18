# serpentine_row

Lays out one measured row of serpentine board cells.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `spacing` | `size`, scaled | — | `0` | Yes | gap between adjacent cells. |
| `alignment` | `main_axis_alignment` | start, end, center, space_between, space_around, space_evenly | `center` | Yes | horizontal cell distribution. |
| `cross_alignment` | `cross_axis_alignment` | start, end, center, stretch, baseline | `center` | Yes | vertical cell alignment. |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. The name `serpentine_row` is also a recognized `_loop._wrap` strategy. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: serpentine_row
_children:
  - _type: text
    value: First
```

```yaml
_type: serpentine_row
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
