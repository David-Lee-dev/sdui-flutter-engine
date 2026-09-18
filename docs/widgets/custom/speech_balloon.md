# speech_balloon

Paints a rounded balloon with an integrated bezier nip.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `text` | `String` | — | `''` | Yes | fallback content when no child is given. |
| `style` | `textStyle` | — | `TextStyle()` | Yes | fallback text styling. |
| `decoration` | `boxDecoration` | color, gradient, border, border_radius, container | `null` | Yes | box fill/border/radius (`color` \| `gradient`, `border`, `border_radius`), same schema as `container`. |
| `nip_height` | `size` | — | `10` | Yes | nip height. |
| `nip_width` | `size` | — | five times `nip_height` | Yes | nip width. |
| `nip_position` | `String` | — | `bottom` | Yes | `top` or `bottom`. |
| `width` | `size` | — | intrinsic | Yes | body width. |
| `height` | `size` | — | intrinsic | Yes | body height excluding the nip. |
| `padding` | `edge` | — | horizontal 10 and vertical 6 | Yes | content inset. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: speech_balloon
```

```yaml
_type: speech_balloon
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
