# `sys_haptic`

The `sys_haptic` command plays a pattern of native taps, a semantic multi-pulse rhythm, or a single platform haptic.

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `pattern` | list of maps | pulses (below) | none | Yes | Native taps. Played instead of `variant` when the device supports native taps. |
| `variant` | string | `success`, `warning`, `error`, `light`, `medium`, `heavy`, `strong`, `selection`, `vibrate` | none | Yes | Rhythm or impulse vocabulary. A missing or unknown value plays nothing. |
| `intensity` | string | `light`, `medium`, `strong`, `heavy` | rhythm base | Yes | Overrides the strength of `success` / `warning` / `error`; `heavy` aliases strong. |

Each `pattern` item is one short transient tap (never a continuous buzz):

| Key | Type | Range | Default | Description |
| --- | --- | --- | --- | --- |
| `intensity` | number | 0–1 | `1.0` | Tap strength. `0` (including negatives clamped to 0) skips the tap but keeps its `delay` — Android would otherwise play its weakest click. |
| `sharpness` | number | 0–1 | `0.5` | Tap crispness. iOS only; ignored on Android. |
| `delay` | number (ms) | ≥ 0 | `0` | Wait after the previous tap; on the first tap, the wait before it. |

Out-of-range values are clamped; a missing or non-numeric key takes its default. A `pattern` that is not a non-empty list of maps is treated as absent.

## Which haptic plays

1. `pattern` is present and valid and the device supports native taps → the taps play; `variant` is ignored.
2. Otherwise `variant` names a rhythm or impulse → it plays as before 0.4.0.
3. Otherwise nothing plays.

Give a `variant` beside a `pattern` when devices without native taps should still feel something.

`success` is two pulses 70 ms apart (light then medium by default); `warning` is two medium pulses 130 ms apart; `error` is three strong pulses 130 ms apart. `light`, `medium`, `heavy`/`strong`, `selection` and `vibrate` are single impulses. Strong uses vibrate on Android and heavy impact elsewhere. Cancellation is checked before each pulse and after each delay.

## Native tap support

| Platform | Supported when | Tap |
| --- | --- | --- |
| iOS | `CHHapticEngine.capabilitiesForHardware().supportsHaptics` | Core Haptics transient event with intensity and sharpness |
| Android | API 30+, the device has a vibrator and supports the `PRIMITIVE_CLICK` composition primitive | click primitive scaled by intensity |
| Web, desktop, tests | never | — |

The engine asks once per process. There is no fallback to waveform or one-shot vibration: an unsupported device uses `variant`.

The engine is a Flutter plugin since 0.4.0 (it declares `android.permission.VIBRATE`), so apps must be rebuilt, not hot-restarted, after upgrading.

## Behavior change in 0.4.0

A missing or unknown `variant` used to play a light impact; it now plays nothing. Write `variant: light` for a light impact.

```yaml
_type: sys_haptic
variant: success
pattern:
  - { intensity: 0.4 }
  - { intensity: 0.9, sharpness: 0.7, delay: 90 }
  - { intensity: 0.4, delay: 90 }
```

```yaml
_type: sys_haptic
variant: warning
intensity: strong
```
