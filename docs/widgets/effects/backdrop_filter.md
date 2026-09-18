# backdrop_filter

Blurs content painted behind its child. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `blur` | `number` | — | `0.0` | Yes | blur sigma used for both axes. |
| `sigma_x` | `number` | — | `blur` | Yes | horizontal blur sigma override. |
| `sigma_y` | `number` | — | `blur` | Yes | vertical blur sigma override. |
| `blend_mode` | `blendMode` | src_over, src_atop, src_in, dst_in, modulate, multiply, screen, overlay, darken, lighten, color, hue, saturation, luminosity, difference, exclusion, plus, clear | `src_over` | Yes | compositing mode. |
| `_child` | widget node | — | `null` | No | The single positional child; cannot be combined with `_children` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: backdrop_filter
blur: 8
sigma_x: 12
blend_mode: src_over
_child: { _type: text, value: Frosted }
```

```yaml
_type: backdrop_filter
_scope:
  _action:
    announce:
      _type: toast
      message: Activated
_on:
  tap:
    do: announce
    ripple: false
_child:
  _type: text
  value: Tap target
```

## Pitfalls & related

- Use only the documented positional child form; `_slots` are rejected for this specification kind.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
