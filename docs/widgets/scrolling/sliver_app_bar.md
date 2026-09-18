# sliver_app_bar

Assigns named engine slots to a Flutter [SliverAppBar]. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `floating` | `flag` | — | `false` | Yes | reveals the header as soon as scrolling reverses. |
| `pinned` | `flag` | — | `false` | Yes | keeps the header visible at its minimum extent. |
| `snap` | `flag` | — | `false` | Yes | snaps a floating app bar fully open or closed. |
| `expanded_height` | `size` (scaled by EngineMetrics) | — | `null` | Yes | height of the app bar when fully expanded. |
| `elevation` | `size` (scaled by EngineMetrics) | — | `null` | Yes | shadow depth beneath the app bar. |
| `background_color` | `color` | — | `null` | Yes | paints the widget background. |
| `foreground_color` | `color` | — | `null` | Yes | sets the default color for app-bar content. |
| `center_title` | `flag` | — | `null` | Yes | centers the title across the full bar width. |
| `automatically_imply_leading` | `flag` | — | `false` | Yes | inserts a route-aware leading widget when none is supplied. |
| `bottom_height` | `size` (scaled by EngineMetrics) | — | `48.0` | Yes | preferred height assigned to the bottom slot. |
| `_slots` | map of widget nodes | actions, bottom, flexible_space, leading, title | `{}` | No | Named children consumed by this slot widget; positional children are rejected. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **sliver** layout protocol. It accepts named slots (`_slots: { actions, bottom, flexible_space, leading, title }`); each slot must produce a box child. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: custom_scroll_view
_children:
  - _type: sliver_app_bar
    floating: true
    _slots: { actions: { _type: text, value: actions }, bottom: { _type: text, value: bottom }, flexible_space: { _type: text, value: flexible_space }, leading: { _type: text, value: leading }, title: { _type: text, value: title } }
```

```yaml
_type: custom_scroll_view
_children:
  - _type: sliver_app_bar
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
- A sliver cannot be mounted at the engine root or under a box parent; place it in `custom_scroll_view` or another sliver parent.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
