# swipe_indicator

A page indicator that follows its `swipe_layout`'s [SwipeController].

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `controller` | `text` | — | `null` | Yes | optional `swipe_layout` id; omit it to use the nearest layout. |
| `dot_width` | `size` (scaled by EngineMetrics) | — | `8.0` | Yes | width of each indicator dot. |
| `dot_height` | `size` (scaled by EngineMetrics) | — | `8.0` | Yes | height of each indicator dot. |
| `spacing` | `size` (scaled by EngineMetrics) | — | `8.0` | Yes | gap between adjacent children or indicator dots. |
| `radius` | `size` (scaled by EngineMetrics) | — | `8.0` | Yes | corner radius of indicator dots. |
| `color` | `color` | — | `#66FFFFFF` | Yes | color or tint. |
| `active_color` | `color` | — | `#FFFFFFFF` | Yes | color used for the selected or active state. |
| `effect` | `text` | worm, expand, scale, jump, slide, scrolling, swap, color | `worm` | Yes | transition style of the active dot. Values: worm \| expand \| scale \| jump \| slide \| scrolling \| swap \| color. |
| `expansion_factor` | `number` | — | `3` | Yes | width multiplier for the active expanding dot. |
| `scale` | `number` | — | `1.6` | Yes | size multiplier for the active scale-effect dot. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: swipe_indicator
controller: example
```

```yaml
_type: swipe_indicator
_scope:
  _action:
    announce:
      _type: toast
      message: Activated
_on:
  tap:
    do: announce
    ripple: false
```

## Pitfalls & related

- Use only the documented positional child form; `_slots` are rejected for this specification kind.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
