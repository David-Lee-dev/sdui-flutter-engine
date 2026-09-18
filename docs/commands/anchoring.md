# `anchoring`

The `anchoring` command animates copies of a registered `anchor_scope` item between two registered anchors.

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `method` | string | `move` | required | Yes | Only implemented operation. |
| `scope` | string | anchor-scope id | sole mounted scope | Yes | Resolves the named scope; when omitted, resolution succeeds only if exactly one scope is mounted. |
| `item` | string | item key in the scope's `items` map | required | Yes | Flyable template. |
| `from` / `to` | string | mounted anchor ids | required | Yes | Start and destination anchors. |
| `count` | integer | clamped 1–50 | `1` | Yes | Number of copies launched. |
| `stagger` | duration | — | `0` | Yes | Delay between launches. |
| `duration` | duration | — | `300ms` | Yes | Per-flight duration. |
| `curve` | curve name | motion curve registry names | `linear` | Yes | Flight curve; an unknown name also falls back to `linear`. |
| `to_align` | string | `top_left`, `top_center`, `top_right`, `center_left`, `center`, `center_right`, `bottom_left`, `bottom_center`, `bottom_right` | `center` | Yes | Landing point within destination rect. |

Coordinates are captured once for the launch. The command awaits the last launched copy, so `_then` runs after arrival. Missing scopes/items/anchors and malformed ids log and resolve normally; unknown methods throw `ArgumentError`.

```yaml
_type: anchoring
method: move
scope: rewards
item: coin
from: earned_coin
to: wallet
count: 5
stagger: 70
duration: 400
curve: ease_out
```
