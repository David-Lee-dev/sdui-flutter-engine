# auto_scroll

A seamless, infinitely repeating scrolling marquee.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `scroll_direction` | `axis` | horizontal, vertical | `vertical` | Yes | axis along which content scrolls. Values: horizontal \| vertical. |
| `height` | `size` | — | `null` | Yes | optional viewport height. |
| `width` | `size` | — | `null` | Yes | optional viewport width. |
| `speed` | `number` | — | `40` | Yes | forward scroll speed in logical pixels per second. |
| `spacing` | `size` | — | `0` | Yes | gap after each repeated item. |
| `reverse` | `flag` | — | `false` | Yes | reverses the scroll direction. |
| `pause_on_interaction` | `flag` | — | `false` | Yes | pauses while a pointer is held down. |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. The name `auto_scroll` is also a recognized `_loop._wrap` strategy. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: auto_scroll
scroll_direction: horizontal
speed: 40
spacing: 12
_children:
  - { _type: text, value: a }
  - { _type: text, value: b }
```

```yaml
_type: auto_scroll
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
