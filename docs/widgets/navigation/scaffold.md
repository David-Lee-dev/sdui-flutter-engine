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
| `inset_bottom` | `flag` | — | `false` | Yes | clears the bottom system inset around the body (the behavior before 0.8.0). |
| `cover_bottom_inset` | `flag` | — | `null` (Android only) | Yes | paints an opaque strip of the scaffold background over the bottom of the body, as tall as the system bottom inset, so scrolled content does not show behind the system bar. `true` forces it on every platform, `false` turns it off. |
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
- Since 0.8.0 the body clears the top, left and right insets but not the bottom: vertical scroll views draw under the home indicator and add the inset after their last item. Put a fixed bottom CTA in the `bottom_navigation_bar` slot (Flutter then removes the body's bottom padding, so the scroll adds nothing) or wrap it in `safe_area` with `top: false`. Do not wrap the whole body in a `safe_area` that keeps `bottom: true`; it consumes the inset before the scroll view sees it. `inset_bottom: true` restores the old behavior. See [Bottom inset](../../concepts.md#bottom-inset).
- Since 0.10.0, on Android the scaffold covers the system bottom inset with its background (`background_color`, else the theme's scaffold background): content scrolls under the system bar but is hidden there, and the scroll end still stops above it. The strip takes the real inset from the device view, not the `MediaQuery` padding, so a floating tab bar an app shell adds to the padding is not covered. It does not take taps. There is no strip with a `bottom_navigation_bar` slot (the slot lies over the inset), with `inset_bottom: true`, when something above the scaffold already consumed the bottom padding, or while the keyboard is up. Set `cover_bottom_inset: false` for a body that should show through the system bar (an edge-to-edge image), or `true` to cover the home indicator area on iOS too.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
