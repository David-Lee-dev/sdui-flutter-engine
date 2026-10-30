# safe_area

Builds Flutter's [SafeArea], supplying an empty child when required. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `top` | `flag` | — | `true` | Yes | offset from the parent top edge. |
| `bottom` | `flag` | — | `true` | Yes | offset from the parent bottom edge. |
| `left` | `flag` | — | `true` | Yes | offset from the parent left edge. |
| `right` | `flag` | — | `true` | Yes | offset from the parent right edge. |
| `maintain_bottom_view_padding` | `flag` | — | `false` | Yes | preserves bottom view padding when the keyboard appears. |
| `minimum` | `edge` | — | `EdgeInsets.zero` | Yes | minimum safe-area inset on each edge. |
| `_child` | widget node | — | `null` | No | The single positional child; cannot be combined with `_children` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: safe_area
top: true
_child: { _type: text, value: hi }
```

```yaml
_type: safe_area
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
- Since 0.11.0 the SDK applies no safe area of its own (the `scaffold` body is not wrapped), so `safe_area` is how a template clears device intrusions the host app has left to it. Like Flutter's `SafeArea` it pads only the edges whose `MediaQuery` padding is still there: an edge the host, an outer `safe_area`, an `app_bar` or a bottom slot already consumed adds nothing.
- Use `safe_area` with `top: false` for fixed bottom content outside a scroll view, such as a CTA. Inside a vertical scroll view that reaches the screen bottom the bottom inset is already 0 (the scroll view adds it to its end spacing), so a `safe_area` there adds nothing. A `safe_area` around a whole scroll view keeps `bottom: true` by default and consumes the inset first, so the content stops above it again. See [Insets](../../concepts.md#insets).

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
