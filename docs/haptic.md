# Haptics

A haptic is tactile feedback. In this engine, a **tap** is a short transient pulse; a **continuous** haptic follows intensity and sharpness curves over time and can include taps. `sys_haptic` exposes `continuous`, `pattern`, `variant`, and `intensity`; see the [command reference](commands/sys-haptic.md) for exact fields, validation, and value tables, and the [preset catalog](haptic-presets.md) for every named preset.

## Playback order

The driver checks inputs in this order:

1. A valid `continuous` value plays if continuous haptics are supported. If it is invalid or unsupported, processing falls through.
2. A valid `pattern` plays if native taps are supported. If invalid or unsupported, processing falls through.
3. `variant` is resolved in this order:
   1. A basic preset plays its taps when taps are supported; otherwise it is silent. It does not fall through.
   2. A continuous preset plays when continuous haptics are supported; otherwise it is silent. Its taps never play alone.
   3. A legacy tap preset (`light`, `success`, `warning`, `error`) plays its tap form when taps are supported.
   4. Legacy semantic rhythms (`success`, `warning`, `error`) or impulses (`light`, `medium`, `heavy`/`strong`, `selection`, `vibrate`) use platform feedback where applicable.
4. Missing, unknown, or unsupported names are silent.

When `continuous` is unsupported, the driver continues to `pattern`, then `variant`; a valid but unsupported custom value does not silence later fallbacks. Before engine 0.6.0, unknown `continuous` parameters are ignored, so older engines continue to `pattern` and then `variant`. Always provide a `variant` fallback for custom haptics.

## Device capabilities

| Platform | Taps | Continuous |
| --- | --- | --- |
| iOS | Core Haptics transient events | Core Haptics continuous event with intensity and sharpness curves |
| Android | API 30+ and vibrator supports `PRIMITIVE_CLICK` | API 36+ and vibrator supports envelope effects |
| No plugin / web / desktop / unsupported hardware | Silent for native taps | Silent |

Android never falls back to waveform, amplitude, or one-shot vibration. A device without the relevant capability stays silent for that custom pattern or preset. On a Samsung Galaxy Z Flip6 (SM-F741N) running Android 16, taps work but `dumpsys` reports `mMaxEnvelopeEffectSize = 0`; continuous haptics are therefore silent on that device and likely unavailable on most current Android devices.

### Android tap intensity tiers

Since 0.14.0, a tap's `intensity` picks which Android primitive plays, approximating iOS's soft-to-strong range instead of always scaling `PRIMITIVE_CLICK` (which still feels weak even at 1.0).

The tiers are derived from the AOSP haptics HAL targets ([Implement constants and primitives](https://source.android.com/docs/core/interaction/haptics/haptics-constants-primitives)), not fitted to one device: `PRIMITIVE_TICK` targets a 1 G peak (half a CLICK), `PRIMITIVE_CLICK` a 2 G peak, and `EFFECT_HEAVY_CLICK` is heavier than CLICK ([UX design](https://source.android.com/docs/core/interaction/haptics/haptics-ux-design), no published number). Vendors tune their actuators to these targets. `intensity` maps linearly to a target peak, `target G = intensity × 2 / 0.75`, so a full CLICK is reached at `0.75`; each primitive's scale is the target divided by its own peak (assuming scale is linear in amplitude). The result is one straight line from 0 to 2 G with no jump between tiers. `PRIMITIVE_THUD` is not used: it targets only 0.25 G over 300 ms, a low knock rather than a strong tap.

| `intensity` | Target peak | Plays | Scale |
| --- | --- | --- | --- |
| `<= 0` | — | nothing | — |
| `0 – 0.375` (exclusive) | 0 – 1 G | `PRIMITIVE_TICK` | `target / 1 G` |
| `0.375 – 0.75` (exclusive) | 1 – 2 G | `PRIMITIVE_CLICK` | `target / 2 G` (0.5 – 1.0) |
| `>= 0.75` | > 2 G | the predefined `EFFECT_HEAVY_CLICK` | not scalable |

Sharpness has no Android counterpart for taps and stays ignored, as before. Per-device fallbacks (capability queried once and cached): a device without `PRIMITIVE_TICK` plays `PRIMITIVE_CLICK` at the same target (`target / 2 G`) instead; a device without the predefined `EFFECT_HEAVY_CLICK` plays `PRIMITIVE_CLICK` at full scale instead. A device without `PRIMITIVE_CLICK` itself stays silent for every tap, exactly as before.

## Authoring guidance

Android's custom haptic effects guidance recommends gaps of at least 50 ms for separate taps to be perceived clearly and intensity steps at least 1.4× apart. Presets that differ only in sharpness feel identical on Android because the tap primitive path scales intensity and does not vary sharpness. Taps with intensity 0 are skipped but retain their delay. These limits make `variant` fallbacks especially useful when authoring custom patterns.

## Custom tap pattern

Each item in `pattern` is a transient tap. `delay` is measured after the previous tap; the first delay is before the first tap.

```yaml
_type: sys_haptic
pattern:
  - { intensity: 0.35 }
  - { intensity: 0.85, delay: 80 }
variant: success
```

## Custom continuous haptic

`continuous` supplies an intensity curve, optional sharpness curve, and optional taps layered over the curve. A supported device plays it as one continuous effect. Older engines ignore this parameter, and unsupported devices fall through to `pattern` and then `variant`.

```yaml
_type: sys_haptic
continuous:
  intensity: [[0, 0], [30, 0.8], [180, 0.35], [400, 0]]
  sharpness: [[0, 0.3], [400, 0.7]]
  taps:
    - { intensity: 1, sharpness: 0.8, delay: 120 }
variant: light
```
