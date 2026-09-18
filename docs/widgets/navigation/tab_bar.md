# tab_bar

Builds a [TabBar] that shares its nearest default tab controller. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `is_scrollable` | `flag` | — | `false` | Yes | lets tabs use intrinsic widths and scroll horizontally. |
| `indicator_color` | `color` | — | `null` | Yes | color of the selected-tab indicator. |
| `indicator_weight` | `size` (scaled by EngineMetrics) | — | `2.0` | Yes | thickness of the selected-tab indicator. |
| `indicator_size` | `tabBarIndicatorSize` | tab, label | `tab` | Yes | sizes the indicator to the tab or its label. Values: tab \| label. The engine pins `tab` because Material 3's primary TabBar default is the surprising label-width `label`. |
| `label_color` | `color` | — | `null` | Yes | color of selected tab labels. |
| `label_style` | `textStyle` | — | `null` | Yes | text style of selected tab labels. |
| `unselected_label_color` | `color` | — | `null` | Yes | color of unselected tab labels. |
| `unselected_label_style` | `textStyle` | — | `null` | Yes | text style of unselected tab labels. |
| `tab_alignment` | `tabAlignment` | start, start_offset, fill, center | `null` | Yes | positions tabs within the tab bar. Values: start \| start_offset \| fill \| center. |
| `divider_color` | `color` | — | `null` | Yes | color of the divider beneath the tab bar. |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: tab_bar
is_scrollable: true
_children:
  - { _type: text, value: a }
  - { _type: text, value: b }
```

```yaml
_type: tab_bar
_scope:
  _action:
    announce:
      _type: toast
      message: Activated
_on:
  tap:
    do: announce
    ripple: false
_children:
  - _type: text
    value: Tap target
```

## Pitfalls & related

- Use only the documented positional child form; `_slots` are rejected for this specification kind.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
