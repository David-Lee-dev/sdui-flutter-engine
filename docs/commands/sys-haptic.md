# `sys_haptic`

The `sys_haptic` command plays a pattern of native taps, a named tap preset, a semantic multi-pulse rhythm, or a single platform haptic.

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `pattern` | list of maps | pulses (below) | none | Yes | Native taps. Played instead of `variant` when the device supports native taps. |
| `variant` | string | a [preset](#presets), or `success`, `warning`, `error`, `light`, `medium`, `heavy`, `strong`, `selection`, `vibrate` | none | Yes | Preset, rhythm or impulse vocabulary. A missing or unknown value plays nothing. |
| `intensity` | string | `light`, `medium`, `strong`, `heavy` | rhythm base | Yes | Overrides the strength of the `success` / `warning` / `error` rhythms (devices without native taps); `heavy` aliases strong. |

Each `pattern` item is one short transient tap (never a continuous buzz):

| Key | Type | Range | Default | Description |
| --- | --- | --- | --- | --- |
| `intensity` | number | 0–1 | `1.0` | Tap strength. `0` (including negatives clamped to 0) skips the tap but keeps its `delay` — Android would otherwise play its weakest click. |
| `sharpness` | number | 0–1 | `0.5` | Tap crispness. iOS only; ignored on Android. |
| `delay` | number (ms) | ≥ 0 | `0` | Wait after the previous tap; on the first tap, the wait before it. |

Out-of-range values are clamped; a missing or non-numeric key takes its default. A `pattern` that is not a non-empty list of maps is treated as absent.

## Which haptic plays

1. `pattern` is present and valid and the device supports native taps → the taps play; `variant` is ignored.
2. Otherwise `variant` names a [preset](#presets) → its taps play if the device supports native taps; otherwise nothing plays.
3. Otherwise `variant` names a [legacy tap preset](#legacy-tap-presets) (`light`, `success`, `warning`, `error`) and the device supports native taps → its taps play.
4. Otherwise `variant` names a rhythm or impulse → it plays as before 0.4.0 (this is where devices without native taps play `light` / `success` / `warning` / `error`).
5. Otherwise nothing plays.

Give a rhythm or impulse `variant` beside a `pattern` when devices without native taps should still feel something.

Without native taps, `success` is two pulses 70 ms apart (light then medium by default); `warning` is two medium pulses 130 ms apart; `error` is three strong pulses 130 ms apart. `light`, `medium`, `heavy`/`strong`, `selection` and `vibrate` are single impulses. Strong uses vibrate on Android and heavy impact elsewhere. `intensity` applies only to these platform impulses, not to taps. Cancellation is checked before each pulse and after each delay.

## Legacy tap presets

Since 0.5.0, on devices with native taps, four legacy names play taps instead of platform impulses (sharpness 0.5; strengths light 0.5 / medium 0.7 / strong 1.0, subject to tuning on devices):

| `variant` | Taps |
| --- | --- |
| `light` | 0.5 |
| `success` | 0.5, then 0.7 after 70 ms |
| `warning` | 0.7, then 0.7 after 130 ms |
| `error` | 1.0, then 1.0 after 130 ms, then 1.0 after 130 ms |

On Android this means `error` no longer uses vibrate on such devices. `medium`, `heavy`, `strong`, `selection` and `vibrate` keep their platform impulses everywhere, and devices without native taps are unchanged.

## Presets

Since 0.5.0 `variant` also accepts these 45 tap presets:

`afterglow`, `aftershock`, `barrage`, `bass_drop`, `bell_toll`, `bongo`, `boulder`, `breaking_wave`, `buildup`, `cadence`, `canter`, `cascade`, `castanets`, `cat_paw`, `chip`, `crescendo`, `fade_out`, `finger_drum`, `firecracker`, `gallop`, `gavel`, `herald`, `hoof_beat`, `ignition`, `jolt`, `murmur`, `patter`, `piston`, `plunk`, `rap`, `ratchet`, `rebound`, `rivet`, `stampede`, `stomp`, `stone_skip`, `syncopate`, `thump`, `thunder_roll`, `tick_tock`, `tidal_surge`, `tide_swell`, `tremor`, `war_drum`, `waterfall`

They are the tap-only (discrete-only) presets of Software Mansion's [Pulsar](https://github.com/software-mansion/pulsar) (MIT, © 2025 Krzysztof Piaskowy), with names in snake_case. Each plays like a `pattern`:

- Taps only, so Android plays click primitives scaled by intensity. Sharpness is iOS only, so presets that differ only in sharpness feel the same on Android.
- A device without native taps plays nothing for a preset name; there is no rhythm fallback.

```yaml
_type: sys_haptic
variant: crescendo
```

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
