# anchored_overlay

Dims the app in the nearest Overlay and lays its children over the dim.

The node itself takes no space where it is written. While it is in the tree its layer sits in the nearest `Overlay` (the route's navigator), above everything that route shows: the app bar, and a shell bar drawn in a `Stack` beside the screen (the tab branch navigator's overlay, like modals). The layer is the dim, which takes every tap outside the children and blocks scrolling and input beneath, and then the children in order. The children are an ordinary template subtree: they read the screen's state and dispatch its actions. `anchored` children are placed at the measured rect of the `anchor` named by `anchor`.

Since 0.22.0. Declare `_requires: [anchored_overlay_v1]`; older engines reject the feature, so gate such templates by app version.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `anchor` | `text` | — | `null` | Yes | id of the `anchor` the `anchored` children are placed against. |
| `on_dismiss` | `text` | — | `null` | Yes | action dispatched by a tap on the dim or a system back. |
| `barrier_color` | `color` | — | `#8A000000` | Yes | color of the dim. |
| `barrier_duration` | `number` | milliseconds | `200` | Yes | how long the dim fades in and out. |
| `barrier_exit_delay` | `number` | milliseconds | `0` | Yes | how long the dim waits before it fades out; set it to follow the children's exit stagger. |
| `_children` | widget nodes | — | `[]` | No | The layer's content, painted over the dim in order. Takes `stack` parent data (`positioned`, `positioned_fill`). |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Opening and closing

Show the node with `_if` and turn presence on with `_presence: true`. A badge tap sets the flag; `on_dismiss` clears it. While the node leaves, the layer stays until every `on: exit` or `on: both` `_motion` inside it has finished, the dim's fade included, and the dim no longer dispatches `on_dismiss`. Without presence the layer goes at once and exit motions do not play.

Enter stagger: give each card a `_motion` with a growing `delay`. Exit stagger: give each card `on: both` and a growing `exit_delay` in the reverse order, and set `barrier_exit_delay` so the dim fades after the last card.

While open, a system back dispatches `on_dismiss` instead of popping the route. Without `on_dismiss` the dim only blocks input and back pops as usual.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`. See [Concepts](../../concepts.md#box-and-sliver-protocols).

## Examples

```yaml
_requires: [anchored_overlay_v1, presence_v1]
_type: column
_scope:
  _state: { open: false }
  _action:
    open: { _type: set, open: true }
    close: { _type: set, open: false }
_children:
  - _type: anchor
    id: badge
    _child:
      _type: container
      _on: { tap: open }
      _child: { _type: text, value: 고보상 }
  - _type: anchored_overlay
    _if: ${open}
    _presence: true
    anchor: badge
    on_dismiss: close
    barrier_exit_delay: 150
    _children:
      - _type: anchored
        placement: over
        _child: { _type: text, value: 고보상 }
      - _type: anchored
        placement: start
        gap: 8
        _child:
          _type: column
          _children:
            - _type: text
              value: 1,000P
              _motion: { type: fade_in, on: both, delay: 0, exit_delay: 50 }
            - _type: text
              value: 500P
              _motion: { type: fade_in, on: both, delay: 50, exit_delay: 0 }
```

## Pitfalls & related

- The layer belongs to the nearest `Overlay`. A route pushed on the root navigator above the tab navigator covers it.
- Put `_motion` on the content inside `anchored`, not on `anchored` itself: an `anchored` node fills the layer.
- `barrier_exit_delay` is not derived from the children; set it to match their exit stagger.
- See [`anchored`](anchored.md), [`anchor`](anchor.md), [Motion](../../motion.md#exit-motions) and [Control flow](../../control-flow.md#presence-transitions).
- Return to the [widget catalog](../README.md).
