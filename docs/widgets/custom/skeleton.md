# skeleton

One loading-placeholder bone (a rounded box) for a `_skeleton` outline.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `width` | `size` | — | `null` | Yes | bone width; null lets the parent size it (e.g. inside `expanded`). Ignored for `circle` (diameter = `height`). |
| `height` | `size` | — | `16` | Yes | bone height (and circle diameter). |
| `radius` | `size` | — | `8` | Yes | corner radius for the `rect` shape. |
| `shape` | `text` | rect, circle, pill | `rect` | Yes | `rect` \| `circle` \| `pill`. |
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
