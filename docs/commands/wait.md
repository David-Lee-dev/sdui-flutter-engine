# `wait`

Suspends the current command until a delay ends or a condition becomes truthy.
Declare `_requires: [wait_v1]` on the template root; using `wait` without it
fails compilation.

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `duration` | number or numeric string, milliseconds | 0–1,000,000 | `0` | Yes | Delay, rounded to the nearest millisecond. |
| `until` | one `${…}` expression | template truthiness | none | Live expression | Re-evaluated when a referenced state key changes. |
| `timeout` | number or numeric string, milliseconds | 1–1,000,000 | required with `until` | Yes, once at start | Maximum time to wait for the condition. |

Use `duration` or `until` with `timeout`. Combining `duration` and `until`,
omitting `timeout` with `until`, or passing a non-expression `until` fails
validation. Parameter presence counts even when the value is null.

Invalid durations (negative, too large, non-finite, or non-numeric) become 0;
they emit one debug diagnostic and no error-observer report. An invalid timeout
becomes 0 and times out immediately if the condition is still false.

```yaml
_requires: [wait_v1]
_type: text
_scope:
  _state: { status: ready }
  _action:
    show_done:
      - { _type: set, status: done }
      - { _type: wait, duration: 1500 }
      - { _type: set, status: ready }
_on: { tap: show_done }
value: '${status}'
```

The condition is checked immediately and then on state changes, including
ancestor state and the action's `$event`/`$data` shadows. An evaluation exception
is reported and treated as false; the wait remains active until success,
timeout, or disposal. No frame polling occurs.

```yaml
_type: wait
until: '${progress >= 1}'
timeout: 5000
_then:
  _type: set
  status: complete
_error:
  WAIT_TIMEOUT:
    _type: set
    status: timed_out
```

On timeout, `DriverError('WAIT_TIMEOUT')` follows the existing action failure
flow: the matching `_error` branch (or `_` fallback) runs, otherwise the error
observer receives it. The wait's `_then` is skipped; later batches continue.
Put work that requires success in `_then`. See [action flows](../actions.md).

Success returns null as `$data`. Concurrent commands in the same batch run
normally, while the next batch waits for this command. Disposing the scope that
owns the action releases the timer and condition listener and completes the
wait immediately; subsequent batches, `_then`, and `_always` do not run.
Pushing another route over a still-mounted owner does not cancel its wait.

Engines before 0.26.0 reject the `wait_v1` feature and the `wait` command.
