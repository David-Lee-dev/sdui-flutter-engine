# shared_element

Wraps one box child in a Flutter Hero between matching tags, using snapshots or a continuous live video surface.

## Properties

| Name | Type | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- |
| `tag` | string | none | Yes | Non-empty identifier shared by source and destination. |
| `radius` | number | `0` | Yes | Non-negative real corner radius at rest, interpolated between endpoints during flight. |
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

Use the same evaluated tag at both endpoints in the same Navigator. The overlay crossfades source and destination snapshots using aspect-preserving `BoxFit.cover`, clipped by the interpolated radius; the live widget and GlobalKeys stay in their original tree. Push grows/moves to the destination rectangle; pop reverses the snapshot endpoints if the source slot still exists. A destination capture failure retains the source snapshot. Empty placeholders preserve both slot sizes without a second visible card.

Both endpoints must exist on the destination's first frame. Place the destination outside `_skeleton` and data-dependent subtrees that mount after navigation. Duplicate tags in one route fail closed for all participants and emit a debug warning; removing duplicates restores flights.

Modal surfaces and inactive tabs (`TickerMode: false`) are excluded. A zero-size, unpainted, or platform-view source cannot provide a snapshot, so navigation continues without a flight. Reduced motion disables flights when `respectReducedMotion` and `disableAnimations` are both true.

## Continuous video

A subtree containing exactly one leased `video` can hand off playback when both endpoints have the same tag and exactly the same `src`, in the same Navigator. The controller initializes once and keeps its position; each endpoint and the shuttle builds its own view from the same controller, with cover fit inside the animated rounded rectangle. Endpoint slots stay offstage during flight; view overlap during handoff is allowed to avoid an empty frame. Content other than matching video continues to use the snapshot crossfade.

Push transfers controls, playback callbacks/`on_end`, loop, volume and autoplay configuration to the destination; pop returns them to the source. Route and flight leases release on removal or gesture cancellation, and the last release disposes the controller exactly once. Different sources, duplicate tags and untagged videos use independent playback. Texture-backed `PlayerVideoController` is supported; custom platform views are unsupported for continuous handoff, skip the flight and may flicker when their view remounts.

Tab-shell branch-to-root navigation remains unverified; only the same Navigator is supported. See [video](video.md#continuous-video-across-navigation) for an example.

The wrapper clips its child with anti-aliasing when `radius` is greater than zero. Set each endpoint's actual radius independently (for example, a card at `16` and a square detail header at `0`); push interpolates `16 → 0`, and pop retraces `0 → 16`, including swipe and cancellation. Snapshots are captured before this clip so flight rounding is applied only once.

## Known limitation

If the destination route is removed by code (a `navigate go`, deep link or redirect) while an iOS edge-swipe is still being dragged, the in-flight transition is not resolved: the source element can stay hidden and a continuous-video flight keeps its controller lease until the screen is rebuilt. Completed and cancelled swipes, and Back, are unaffected. The regression tests for this case are skipped.

See [page transitions](../../transitions.md#shared-elements) for `_transition.content_timing` and destination-content reveal behavior.
