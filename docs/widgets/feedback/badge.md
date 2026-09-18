# badge

Places a label or dot badge over a child widget. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `label` | `text` | — | `null` | Yes | label text; null creates a dot badge. |
| `background_color` | `color` | — | `null` | Yes | badge fill color. |
| `text_color` | `color` | — | `null` | Yes | label text color. |
| `alignment` | `alignmentDirectional` | top_start, top_center, top_end, center_start, center, center_end, bottom_start, bottom_center, bottom_end | `null` | Yes | badge alignment. |
| `is_label_visible` | `flag` | — | `true` | Yes | whether the badge is visible. |
| `_child` | widget node | — | `null` | No | The single positional child; cannot be combined with `_children` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: badge
label: '3'
background_color: '#cc0000'
text_color: '#ffffff'
alignment: top_end
_child: { _type: icon, name: notifications }
```

```yaml
_type: badge
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
