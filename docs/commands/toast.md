# `toast`

The `toast` command shows a host-provided transient message with a normalized presentation variant.

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `message` | string | — | `''` for non-string | Yes | Text passed to the host toast service. |
| `variant` | string | `info`, `success`, `warn`, `error` | `info` | Yes | Unknown values normalize to `info`. |

`Sdui.initialize` accepts an app-owned `SduiToastPresenter`. It replaces the facade's default `SnackBar` and receives the build context, normalized message, and normalized variant (`info`, `success`, `warn`, or `error`):

```dart
Sdui.initialize(
  // Required dependencies omitted.
  toastPresenter: (context, message, variant) {
    AppToast.show(context, message: message, variant: variant ?? 'info');
  },
);
```

Without `toastPresenter`, the `Sdui` facade shows its existing `SnackBar`; that fallback displays the message and does not style by variant. A bare engine host with no toast capability treats the command as a no-op. The command always returns null.

```yaml
_type: toast
message: 'Saved ${profile.name}'
variant: success
```

```yaml
_type: toast
message: Check your connection
variant: warn
```
