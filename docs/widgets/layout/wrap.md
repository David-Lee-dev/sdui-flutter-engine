# wrap

Builds Flutter's [Wrap] from the node's children. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `direction` | `axis` | horizontal, vertical | `horizontal` | Yes | selects the layout or dismissal axis. Values: horizontal \| vertical. |
| `alignment` | `wrapAlignment` | start, end, center, space_between, space_around, space_evenly | `start` | Yes | positions the child or children within the available space. Values: start \| end \| center \| space_between \| space_around \| space_evenly. |
| `run_alignment` | `wrapAlignment` | start, end, center, space_between, space_around, space_evenly | `start` | Yes | distributes wrap runs along the cross axis. Values: start \| end \| center \| space_between \| space_around \| space_evenly. |
| `cross_axis_alignment` | `wrapCrossAlignment` | start, end, center | `start` | Yes | positions children across the layout cross axis. Values: start \| end \| center. |
| `spacing` | `size` (scaled by EngineMetrics) | — | `0.0` | Yes | gap between adjacent children or indicator dots. |
| `run_spacing` | `size` (scaled by EngineMetrics) | — | `0.0` | Yes | gap between adjacent wrap runs. |
| `text_direction` | `textDirection` | ltr, rtl | `null` | Yes | resolves start/end ordering and alignment. Values: ltr \| rtl. |
| `vertical_direction` | `verticalDirection` | up, down | `down` | Yes | orders vertical layout from top-down or bottom-up. Values: up \| down. |
| `clip_behavior` | `clip` | none, hard_edge, anti_alias, anti_alias_with_save_layer | `none` | Yes | edge clipping behavior. Values: none \| hard_edge \| anti_alias \| anti_alias_with_save_layer. |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. The name `wrap` is also a recognized `_loop._wrap` strategy. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: wrap
direction: horizontal
_children:
  - { _type: text, value: a }
  - { _type: text, value: b }
```

```yaml
_type: wrap
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
