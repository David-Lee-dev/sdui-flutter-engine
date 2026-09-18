# overflow_bar

Builds Flutter's [OverflowBar] from the node's children. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `spacing` | `size` (scaled by EngineMetrics) | — | `0.0` | Yes | gap between adjacent children or indicator dots. |
| `overflow_spacing` | `size` (scaled by EngineMetrics) | — | `0.0` | Yes | gap between children after the bar overflows. |
| `alignment` | `mainAxisAlignment` | start, end, center, space_between, space_around, space_evenly | `null` | Yes | positions the child or children within the available space. Values: start \| end \| center \| space_between \| space_around \| space_evenly. |
| `overflow_alignment` | `overflowBarAlignment` | start, center, end | `start` | Yes | aligns children across the overflow column. Values: start \| center \| end. |
| `overflow_direction` | `verticalDirection` | up, down | `down` | Yes | direction in which overflow rows are stacked. Values: up \| down. |
| `text_direction` | `textDirection` | ltr, rtl | `null` | Yes | resolves start/end ordering and alignment. Values: ltr \| rtl. |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: overflow_bar
spacing: 1
_children:
  - { _type: text, value: a }
  - { _type: text, value: b }
```

```yaml
_type: overflow_bar
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
