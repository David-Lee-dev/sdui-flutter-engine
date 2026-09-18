# `app_storage`

The `app_storage` command reads/writes application storage and supplies calendar-day throttling primitives.

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `method` | string | `get`, `set`, `stamp`, `due` | `set` | Yes | Storage operation. |
| `key` | string | non-empty | required | Yes | Store key. |
| `value` | any | — | `null` | Yes | Value written by `set`; returned as `$data`. |
| `days` | non-negative integer | — | `1` | Yes | Calendar days required by `due`. |

`get` returns the stored value. `set` writes and returns `value`. `stamp` stores and returns current epoch milliseconds. `due` compares local calendar dates, returning true for missing/non-integer stamps, future stamps, or when at least `days` dates have elapsed. It is calendar-based, not elapsed-24-hour based.

```yaml
_type: app_storage
method: due
key: promo_last_shown
days: 7
_then:
  _type: modal
  _when: '${data}'
  modal: weekly_promo
```

```yaml
_type: app_storage
method: stamp
key: promo_last_shown
```

