# `sys_haptic`

The `sys_haptic` command plays a single platform haptic or a semantic multi-pulse pattern.

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `variant` | string | `success`, `warning`, `error`, `light`, `medium`, `heavy`, `strong`, `selection`, `vibrate` | light impact | Yes | Pattern or impulse vocabulary. Unknown/null values also play light impact. |
| `intensity` | string | `light`, `medium`, `strong`, `heavy` | pattern base | Yes | Overrides semantic pattern strength; `heavy` aliases strong. |

`success` is two pulses 70 ms apart (light then medium by default); `warning` is two medium pulses 130 ms apart; `error` is three strong pulses 130 ms apart. Strong uses vibrate on Android and heavy impact elsewhere. Cancellation is checked before and between pulses.

```yaml
_type: sys_haptic
variant: success
```

```yaml
_type: sys_haptic
variant: warning
intensity: strong
```

