# row

Builds Flutter's [Row] for a `row` node. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `main_axis_alignment` | `mainAxisAlignment` | start, end, center, space_between, space_around, space_evenly | `start` | Yes | distributes children along the layout main axis. Values: start \| end \| center \| space_between \| space_around \| space_evenly. |
| `cross_axis_alignment` | `crossAxisAlignment` | start, end, center, stretch, baseline | `center` | Yes | positions children across the layout cross axis. Values: start \| end \| center \| stretch \| baseline. |
| `main_axis_size` | `mainAxisSize` | min, max | `max` | Yes | min hugs children, max fills the main axis. Values: min \| max. |
| `vertical_direction` | `verticalDirection` | up, down | `down` | Yes | orders vertical layout from top-down or bottom-up. Values: up \| down. |
| `text_direction` | `textDirection` | ltr, rtl | `null` | Yes | resolves start/end ordering and alignment. Values: ltr \| rtl. |
| `text_baseline` | `textBaseline` | alphabetic, ideographic | `null` | Yes | baseline used when aligning flex children. Values: alphabetic \| ideographic. |
| `spacing` | `size` (scaled by EngineMetrics) | — | `0.0` | Yes | gap between adjacent children or indicator dots. |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. The name `row` is also a recognized `_loop._wrap` strategy. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: row
main_axis_alignment: start
_children:
  - { _type: text, value: a }
  - { _type: text, value: b }
```

```yaml
_type: row
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
