# `toast`

The `toast` command shows a host-provided transient message with a normalized presentation variant.

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `message` | string | — | `''` for non-string | Yes | Text passed to the host toast service. |
| `variant` | string | `info`, `success`, `warn`, `error` | `info` | Yes | Unknown values normalize to `info`. |

The command is a no-op when the host has no toast capability and returns null.

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

