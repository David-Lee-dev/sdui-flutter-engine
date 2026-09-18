# scaffold

Assigns named engine slots to the corresponding [Scaffold] regions. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `background_color` | `color` | — | `null` | Yes | paints the widget background. |
| `floating_action_button_location` | `fabLocation` | start_float, center_float, end_float, start_top, center_top, end_top, start_docked, center_docked, end_docked, mini_start_float, mini_center_float, mini_end_float | `null` | Yes | positions the floating action button in the scaffold. Values: start_float \| center_float \| end_float \| start_top \| center_top \| end_top \| start_docked \| center_docked \| end_docked \| mini_start_float \| mini_center_float \| mini_end_float. |
| `resize_to_avoid_bottom_inset` | `flag` | — | `null` | Yes | resizes the body around the keyboard and other bottom insets. |
| `extend_body` | `flag` | — | `false` | Yes | lets the body extend behind the bottom navigation bar. |
| `extend_body_behind_app_bar` | `flag` | — | `false` | Yes | lets the body extend behind the app bar. |
| `app_bar_height` | `size` (scaled by EngineMetrics) | — | `kToolbarHeight` | Yes | height reserved for the fixed app bar. |
| `_slots` | map of widget nodes | app_bar, body, bottom_navigation_bar, bottom_sheet, drawer, end_drawer, floating_action_button | `{}` | No | Named children consumed by this slot widget; positional children are rejected. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. It accepts named slots (`_slots: { app_bar, body, bottom_navigation_bar, bottom_sheet, drawer, end_drawer, floating_action_button }`); each slot must produce a box child. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: scaffold
background_color: example
_slots: { app_bar: { _type: text, value: app_bar }, body: { _type: text, value: body }, bottom_navigation_bar: { _type: text, value: bottom_navigation_bar }, bottom_sheet: { _type: text, value: bottom_sheet }, drawer: { _type: text, value: drawer }, end_drawer: { _type: text, value: end_drawer }, floating_action_button: { _type: text, value: floating_action_button } }
```

```yaml
_type: scaffold
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
  app_bar:
    _type: text
    value: Tap target
```

## Pitfalls & related

- Use `_slots` only; the validator rejects `_child` and `_children`.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
