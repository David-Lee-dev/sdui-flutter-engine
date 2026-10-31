# skeleton

One loading-placeholder bone (a rounded box) for a `_skeleton` outline.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `of` | `text` | text | `null` | Yes | `text` draws the bone of a text: as tall as a text with the same `style` and `max_lines` (same text scale), one bar per line, the last of several lines at 60 % width. Since 0.17.0. |
| `width` | `size` | — | `null` | Yes | bone width; null lets the parent size it (e.g. inside `expanded`). Ignored for `circle` (diameter = `height`). A text bone without it fills the parent, or takes 80 when unbounded. |
| `height` | `size` | — | `16` | Yes | bone height (and circle diameter). Ignored for a text bone. |
| `radius` | `size` | — | `8` | Yes | corner radius for the `rect` shape. |
| `shape` | `text` | rect, circle, pill | `rect` | Yes | `rect` \| `circle` \| `pill`. |
| `style` | `textStyle` | — | `null` | Yes | the text style a text bone stands for. |
| `max_lines` | `integer` | — | `1` | Yes | the lines a text bone stands for. |
| `color` | `color` | — | base grey | Yes | fill; irrelevant under the shimmer mask, kept for standalone/degraded use. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: skeleton
width: 120
height: 16
shape: pill
```

```yaml
_type: skeleton
of: text
style: { font_size: 28 }
max_lines: 2
```

```yaml
_type: skeleton
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
