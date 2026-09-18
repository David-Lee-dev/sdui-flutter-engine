# sliver_grid

Builds a non-lazy [SliverGrid] from the node's box children. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `cross_axis_count` | `integer` | — | `2` | Yes | number of tiles across the grid cross axis. |
| `main_axis_spacing` | `size` (scaled by EngineMetrics) | — | `0` | Yes | gap between grid tiles on the main axis. |
| `cross_axis_spacing` | `size` (scaled by EngineMetrics) | — | `0` | Yes | gap between grid tiles on the cross axis. |
| `child_aspect_ratio` | `number` | — | `1.0` | Yes | width-to-height ratio of each grid tile. |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **sliver** layout protocol. Its positional children must produce box. The name `sliver_grid` is also a recognized `_loop._wrap` strategy. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: custom_scroll_view
_children:
  - _type: sliver_grid
    cross_axis_count: 1
    _children:
      - { _type: text, value: a }
      - { _type: text, value: b }
```

```yaml
_type: custom_scroll_view
_children:
  - _type: sliver_grid
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
- A sliver cannot be mounted at the engine root or under a box parent; place it in `custom_scroll_view` or another sliver parent.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
