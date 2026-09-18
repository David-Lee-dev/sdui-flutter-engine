# vertical_divider

Draws a vertical Material divider. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `width` | `size` | — | `null` | Yes | total horizontal extent. |
| `thickness` | `size` | — | `null` | Yes | painted line thickness. |
| `indent` | `size` | — | `null` | Yes | top inset. |
| `end_indent` | `size` | — | `null` | Yes | bottom inset. |
| `color` | `color` | — | `null` | Yes | line color. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: vertical_divider
width: 16
thickness: 2
indent: 8
end_indent: 8
color: '#cccccc'
```

```yaml
_type: vertical_divider
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
