# transition_source

Marks the exact region that grows into a destination page using `container_transform`.

## Properties

| Name | Type | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- |
| `radius` | number | `0` | Yes | Finite non-negative corner radius; clips the box at rest and interpolates to zero during the transform. |
| `_child` | box widget | empty | No | The single box captured on pointer-down. |

```yaml
_type: transition_source
radius: 16
_child:
  _type: container
  width: 160
  height: 100
  _child: { _type: text, value: "${title}" }
```

Declare `_transition: { type: container_transform }` on the destination screen. Keep card text and controls that should not grow outside this wrapper. Existing tap/navigation actions work unchanged: this widget observes pointer-down without competing for gestures.

The engine captures this box's pixels, global rectangle and radius. The next engine preload push consumes the capture once, within one second and in the same Navigator. A newer pointer-down replaces it. Empty, unpainted, platform-view, stale or unmounted sources fall back to a page fade. Without this wrapper, `container_transform` also fades.

The source box keeps its layout and live child mounted while its painting is hidden during the transition. Painting is restored after push, Back, swipe cancellation/completion, and route removal, including removal during a swipe. Pop re-reads a still-mounted source rectangle; otherwise it returns to the stored rectangle using the captured pixels.

Nested `shared_element` tags are excluded from individual Hero flights while this container route exists: their pixels grow with the container snapshot, preventing two simultaneous animations. Nested video uses that snapshot rather than continuous Hero handoff. Shared elements outside this wrapper remain independent.

See [page transitions](../../transitions.md#source-wrapper-and-tap-origins) for effect parameters, tap origins, fallbacks and reduced motion.
