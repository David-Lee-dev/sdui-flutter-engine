# `sys_haptic`

The `sys_haptic` command plays a pattern of native taps, a named preset (taps, or a continuous vibration with taps), a semantic multi-pulse rhythm, or a single platform haptic.

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
2. Otherwise `variant` names a [basic preset](#basic-presets-45-tap-only) → its taps play if the device supports native taps; otherwise nothing plays.
3. Otherwise `variant` names a [continuous preset](#continuous-presets-106) → it plays if the device supports [continuous haptics](#continuous-haptic-support); otherwise nothing plays — a continuous preset never plays only its taps.
4. Otherwise `variant` names a [legacy tap preset](#legacy-tap-presets) (`light`, `success`, `warning`, `error`) and the device supports native taps → its taps play.
5. Otherwise `variant` names a rhythm or impulse → it plays as before 0.4.0 (this is where devices without native taps play `light` / `success` / `warning` / `error`).
6. Otherwise nothing plays.

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

Since 0.5.0 `variant` also accepts the 151 presets of Software Mansion's [Pulsar](https://github.com/software-mansion/pulsar) (MIT, © 2025 Krzysztof Piaskowy), with names in snake_case. A preset name never falls back to a rhythm or impulse.

### Basic presets (45, tap-only)

Basic presets are taps only and play like a `pattern`: Android plays click primitives scaled by intensity, and sharpness is iOS only, so presets that differ only in sharpness feel the same on Android. A device without [native taps](#native-tap-support) plays nothing.

`afterglow`, `aftershock`, `barrage`, `bass_drop`, `bell_toll`, `bongo`, `boulder`, `breaking_wave`, `buildup`, `cadence`, `canter`, `cascade`, `castanets`, `cat_paw`, `chip`, `crescendo`, `fade_out`, `finger_drum`, `firecracker`, `gallop`, `gavel`, `herald`, `hoof_beat`, `ignition`, `jolt`, `murmur`, `patter`, `piston`, `plunk`, `rap`, `ratchet`, `rebound`, `rivet`, `stampede`, `stomp`, `stone_skip`, `syncopate`, `thump`, `thunder_roll`, `tick_tock`, `tidal_surge`, `tide_swell`, `tremor`, `war_drum`, `waterfall`

### Continuous presets (106)

Continuous presets are a continuous vibration whose intensity and sharpness follow curves, with taps on top. They play only on devices with [continuous haptics](#continuous-haptic-support) — iOS Core Haptics, or Android 16+ with envelope effects — and are silent otherwise, also on devices that support taps; the taps are never played alone.

Few Android devices report envelope effects yet: a Samsung Galaxy Z Flip6 (SM-F741N) on Android 16 reports none (`dumpsys vibrator_manager`: `mMaxEnvelopeEffectSize = 0`), so expect most Android devices to be silent for these presets.

`alarm`, `anvil`, `applause`, `ascent`, `balloon_pop`, `batter`, `blip`, `bloom`, `breath`, `burst`, `buzz`, `camera_shutter`, `charge`, `chime`, `chirp`, `clamor`, `clasp`, `cleave`, `coil`, `coin_drop`, `combination_lock`, `dewdrop`, `dirge`, `dissolve`, `dog_bark`, `drone`, `engine_rev`, `exhale`, `explosion`, `fanfare`, `feather`, `finale`, `fizz`, `flare`, `flick`, `flinch`, `flourish`, `flurry`, `flush`, `glitch`, `guitar_strum`, `hail`, `hammer`, `heartbeat`, `impact`, `keyboard_mechanical`, `keyboard_membrane`, `knell`, `knock`, `lament`, `latch`, `lighthouse`, `lilt`, `lock`, `lope`, `march`, `metronome`, `nudge`, `passing_car`, `peal`, `peck`, `pendulum`, `ping`, `pip`, `plink`, `plummet`, `poke`, `pound`, `power_down`, `propel`, `pulse`, `pummel`, `push`, `radar`, `rain`, `ramp`, `ripple`, `rustle`, `shockwave`, `snap`, `sonar`, `spark`, `spin`, `stagger`, `stamp`, `strike`, `summon`, `surge`, `sway`, `sweep`, `swell`, `throb`, `thud`, `thunder`, `trigger`, `triumph`, `trumpet`, `typewriter`, `unfurl`, `vortex`, `wane`, `wave`, `wisp`, `wobble`, `woodpecker`, `zipper`

A continuous preset is handed to the device as a whole; the command lasts as long as the preset, checks cancellation at least every 50 ms, and stops the vibration when cancelled.

```yaml
_type: sys_haptic
variant: crescendo
```

```yaml
_type: sys_haptic
variant: heartbeat
```

## Native tap support

| Platform | Supported when | Tap |
| --- | --- | --- |
| iOS | `CHHapticEngine.capabilitiesForHardware().supportsHaptics` | Core Haptics transient event with intensity and sharpness |
| Android | API 30+, the device has a vibrator and supports the `PRIMITIVE_CLICK` composition primitive | click primitive scaled by intensity |
| Web, desktop, tests | never | — |

The engine asks once per process. There is no fallback to waveform or one-shot vibration: an unsupported device uses `variant`.

## Continuous haptic support

| Platform | Supported when | Continuous preset |
| --- | --- | --- |
| iOS | `CHHapticEngine.capabilitiesForHardware().supportsHaptics` | one Core Haptics pattern: a continuous event shaped by intensity and sharpness control curves, plus a transient event per tap |
| Android | Android 16+ (API 36) and `Vibrator.areEnvelopeEffectsSupported()` | one `VibrationEffect.BasicEnvelopeBuilder` envelope; taps are merged into it as short peaks, as Pulsar does |
| Web, desktop, tests | never | — |

The engine asks once per process. Android never falls back to waveform, amplitude, one-shot or timing vibration for continuous presets: a device without envelope effects plays nothing for them.

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
