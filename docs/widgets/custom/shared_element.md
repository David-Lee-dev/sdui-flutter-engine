# shared_element

Wraps one box child in a Flutter Hero that flies a snapshot between matching tags.

## Properties

| Name | Type | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- |
| `tag` | string | none | Yes | Non-empty identifier shared by source and destination. |
| `radius` | number | `0` | Yes | Non-negative corner radius, interpolated during flight. |
| `_child` | box widget | empty | No | Any single box child, including images, text, composed widgets and video. |

```yaml
_type: shared_element
tag: "card-${id}"
radius: 16
_child:
  _type: container
  width: 120
  height: 80
  _child: { _type: text, value: "${title}" }
```

Use the same evaluated tag at both endpoints in the same Navigator. The overlay paints source pixels using `RawImage`; the live widget and GlobalKeys stay in their original tree. Push grows/moves to the destination rectangle; pop flies back if the source slot still exists.

Both endpoints must exist on the destination's first frame. Place the destination outside `_skeleton` and data-dependent subtrees that mount after navigation. Duplicate tags in one route fail closed for all participants and emit a debug warning; removing duplicates restores flights.

Modal surfaces and inactive tabs (`TickerMode: false`) are excluded. A zero-size, unpainted, or platform-view source cannot provide a snapshot, so navigation continues without a flight. Reduced motion disables flights when `respectReducedMotion` and `disableAnimations` are both true.

Video is a snapshot during flight and initializes at the destination as usual. Video-controller handoff is not part of v1. Tab-shell branch-to-root navigation is unverified; v1 supports the same Navigator only.

See [page transitions](../../transitions.md#shared-elements) for `_transition.content_timing` and destination-content reveal behavior. `radius` affects the flight; use a `clip_rrect` child when rounded endpoint rendering is also desired.
