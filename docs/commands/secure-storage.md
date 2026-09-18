# `secure_storage`

The `secure_storage` command reads, writes, or deletes a value through the configured secure store.

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `method` | string | `read`, `write`, `delete` | `read` | Yes | Secure-store operation. |
| `key` | string | non-empty | required | Yes | Secure key. |
| `value` | any | — | `null` | Yes | `write` stores `value.toString()` and returns the original value. |

`read` returns a nullable string; `delete` returns null. Writes/deletes check owner cancellation immediately before the irreversible store call.

```yaml
_type: secure_storage
method: write
key: access_token
value: '${data.token}'
```

```yaml
_type: secure_storage
method: delete
key: access_token
```

