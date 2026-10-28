# `sys_haptic`

The `sys_haptic` command plays custom taps, custom continuous haptics, named presets, semantic rhythms, or a platform impulse. For concepts and device behavior, see the [haptic guide](../haptic.md); for preset names and details, see the [preset catalog](../haptic-presets.md).

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `continuous` | map | curves and taps (below) | none | Yes | Custom continuous vibration with taps on top. Played before `pattern` and `variant` when supported. Since 0.6.0. |
| `pattern` | list of maps | pulses (below) | none | Yes | Native taps. Played before `variant` when supported. |
| `variant` | string | Preset key or `success`, `warning`, `error`, `light`, `medium`, `heavy`, `strong`, `selection`, `vibrate` | none | Yes | Preset, rhythm, or impulse vocabulary. Unknown values play nothing. |
| `intensity` | string | `light`, `medium`, `strong`, `heavy` | rhythm base | Yes | Overrides the strength of `success` / `warning` / `error` rhythms; `heavy` aliases `strong`. |

## `pattern` items

Each item is one short transient tap (never a continuous buzz):

| Key | Type | Range | Default | Description |
| --- | --- | --- | --- | --- |
| `intensity` | number | 0–1 | `1.0` | Tap strength. `0` (including negatives clamped to 0) skips the tap but keeps its `delay`. |
| `sharpness` | number | 0–1 | `0.5` | Tap crispness. iOS only; ignored on Android. |
| `delay` | number (ms) | ≥ 0 | `0` | Wait after the previous tap; on the first tap, the wait before it. |

Out-of-range values are clamped; a missing or non-numeric key takes its default. A `pattern` that is not a non-empty list of maps is treated as absent.

## `continuous`

A `continuous` map describes one continuous vibration whose intensity and sharpness follow curves, with optional taps on top:

| Key | Type | Required | Description |
| --- | --- | --- | --- |
| `intensity` | list of `[ms, value]` | Yes | Intensity curve. Non-empty. |
| `sharpness` | list of `[ms, value]` | No | Sharpness curve. When absent, a flat 0.5 from 0 to the last `intensity` time. |
| `taps` | list of maps | No | Taps on top, in the same item format as `pattern`; each `delay` is after the previous tap. |

Each curve point is a list of exactly two numbers: milliseconds from the start (rounded, ≥ 0, never smaller than the previous point's) and a value clamped to 0–1. Other keys are ignored. A `continuous` that is not a map, lacks a valid `intensity`, or has an invalid `sharpness` or `taps` (when present; `taps` must be a non-empty list of maps) is treated as absent. Playback checks cancellation at least every 50 ms and stops the vibration when cancelled.

```yaml
_type: sys_haptic
continuous:
  intensity: [[0, 0], [5, 1], [150, 0.3], [500, 0]]
  sharpness: [[0, 0.5], [500, 0.2]]
  taps:
    - { intensity: 1.0, sharpness: 0.2 }
pattern:
  - { intensity: 1.0 }
  - { intensity: 0.4, delay: 150 }
variant: error
```
