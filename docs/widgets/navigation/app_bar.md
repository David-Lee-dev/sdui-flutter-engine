# app_bar

Arranges `leading` / `title` / `actions` for a fixed app bar's content. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `center_title` | `flag` | — | `false` | Yes | centers the title across the full bar width. |
| `horizontal_padding` | `size` (scaled by EngineMetrics) | — | `0.0` | Yes | insets app-bar content from both horizontal edges. |
| `background_color` | `color` | — | `null` | Yes | paints the widget background. |
| `_slots` | map of widget nodes | actions, leading, title | `{}` | No | Named children consumed by this slot widget; positional children are rejected. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. It accepts named slots (`_slots: { actions, leading, title }`); each slot must produce a box child. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: app_bar
center_title: true
_slots: { actions: { _type: text, value: actions }, leading: { _type: text, value: leading }, title: { _type: text, value: title } }
```

```yaml
_type: app_bar
_scope:
  _action:
    announce:
      _type: toast
      message: Activated
_on:
  tap:
    do: announce
    ripple: false
_slots:
  actions:
    _type: text
    value: Tap target
```

## Pitfalls & related

- Use `_slots` only; the validator rejects `_child` and `_children`.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
