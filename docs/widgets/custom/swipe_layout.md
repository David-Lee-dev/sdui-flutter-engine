# swipe_layout

Owns the [SwipeController] shared by a swipe layout's panes and indicators.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `id` | `text` | — | `null` | Yes | identifier used to register or connect the widget. |
| `length` | `integer` | — | `1` | Yes | number of pages or tabs managed by the controller. |
| `index` | `integer` | — | `null` | Yes | externally controlled current page index. |
| `initial_index` | `integer` | — | `0` | Yes | page or tab selected initially. |
| `on_changed` | `text` | — | `null` | Yes | action dispatched after the value settles. |
| `loop` | `flag` | — | `true` | Yes | true wraps past the last page back to the first. |
| `autoplay_interval` | `duration` | — | `null` | Yes | time between automatic page advances; null disables autoplay. |
| `autoplay_resume_delay` | `duration` | — | `4 seconds` | Yes | delay before autoplay resumes after interaction. |
| `_child` | widget node | — | `null` | No | The single positional child; cannot be combined with `_children` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: swipe_layout
id: example
_child: { _type: text, value: hi }
```

```yaml
_type: swipe_layout
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

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
