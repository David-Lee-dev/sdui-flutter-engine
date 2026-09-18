# shader_mask

Paints a gradient over its child, tinting the child's painted pixels with it (`blend_mode: src_in`) — the way to render gradient text or icons. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `gradient` | `gradient` | — | — | Yes | the shader painted over the child; when null the child is returned unchanged. `type`: linear \| radial \| sweep (+ colors/stops/…). |
| `blend_mode` | `blendMode` | src_over, src_atop, src_in, dst_in, modulate, multiply, screen, overlay, darken, lighten, color, hue, saturation, luminosity, difference, exclusion, plus, clear | `src_in` | Yes | how the gradient composites onto the child; `src_in` fills the child's opaque pixels. Values: src_over \| src_atop \| src_in \| dst_in \| modulate \| multiply \| screen \| overlay \| darken \| lighten \| color \| hue \| saturation \| luminosity \| difference \| exclusion \| plus \| clear. |
| `_child` | widget node | — | `null` | No | The single positional child; cannot be combined with `_children` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: shader_mask
gradient: { type: linear, colors: [ { .token: color.primary }, { .token: color.blue } ] }
_child: { _type: text, value: "7%", style: { font_size: 20, font_weight: w700 } }
```

```yaml
_type: shader_mask
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
