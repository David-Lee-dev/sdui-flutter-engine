# text

Builds Flutter's [Text], stringifying non-null dynamic values leniently. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `value` | `dynamic` | — | `null` | Yes | displayed text value. |
| `style` | `textStyle` | — | `null` | Yes | text style applied to the content. |
| `text_align` | `textAlign` | left, right, center, justify, start, end | `null` | Yes | horizontal alignment of text within each line. Values: left \| right \| center \| justify \| start \| end. |
| `max_lines` | `integer` | — | `null` | Yes | maximum number of displayed or editable lines. |
| `overflow` | `textOverflow` | clip, fade, ellipsis, visible | `null` | Yes | handling used when text exceeds its bounds. Values: clip \| fade \| ellipsis \| visible. |
| `soft_wrap` | `flag` | — | `null` | Yes | allows text to wrap at soft line breaks. |
| `text_direction` | `textDirection` | ltr, rtl | `null` | Yes | resolves start/end ordering and alignment. Values: ltr \| rtl. |
| `semantics_label` | `text` | — | `null` | Yes | accessibility label. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: text
value: example
```

```yaml
_type: text
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
