# Actions and command flows

`_scope._action` maps names to driver commands or ordered lists of sequential/concurrent command batches.

## Shape

```yaml
_scope:
  _state: { saving: false }
  _action:
    save:
      - _type: set
        saving: true
      - - _type: net
          op: save_profile
        - _type: sys_haptic
          variant: selection
      - _type: set
        saving: false
```

A map is one command. A top-level list is a sequence of batches. Each list item that is a map is a one-command batch; a nested list is a concurrent batch executed with `Future.wait`. Each batch completes before the next begins. There is **no `_steps` key** in the implemented grammar.

Every command needs a non-empty `_type`. Bare keys are recursively resolved driver parameters. The built-ins are linked from the [index](README.md#built-in-commands); unknown driver types fail validation.

## Metadata

| Key | Type | Default | Behavior |
| --- | --- | --- | --- |
| `_when` | one `${…}` string | none | Falsy skips the command and all handlers. Evaluation errors are reported and skip it. |
| `_background` | bool | `false` | Fire-and-forget; not awaited, failures have no handlers. `_then`, `_error`, `_dismiss`, and `_always` are forbidden. |
| `_then` | flow | none | Runs after success with result exposed as `$data`. |
| `_error` | map `{code: flow}` | none | Exact `DriverError.code` wins; `_` is the default branch. Exposes `$error`. |
| `_dismiss` | flow | none | Runs for reserved dismissal code `DISMISSED`; dismissal is otherwise a no-op. |
| `_always` | flow | none | Runs after success, failure, dismissal, or handled boundary failure, unless the owner is disposed. It receives no new shadow. |
| `_dedupe` | bool | `true` | Action-level option accepted only on the single-command map form; suppresses another invocation of the same action while its foreground flow is running. |

Handlers use the same flow grammar recursively. Handler failures are reported and isolated. Background work does not extend a dedupe window.

## Shadow environments

An interaction or widget-dispatched payload is exposed as `$event` throughout the action. `_then` adds `$data`; `_error` adds `$error = {code, message, data}` for `DriverError`, or `{code: null, message}` for unexpected errors. These names are read-only. A null event does not add an event frame.

```yaml
_type: net
op: load_user
params: { id: '${event.id}' }
_then:
  _type: set
  user: '${data}'
_error:
  NOT_FOUND:
    _type: toast
    message: 'Missing: ${error.message}'
  _:
    _type: toast
    message: Request failed
_always:
  _type: set
  loading: false
```

## Error codes

The request fields in these examples (`op`, `params`, `path`, ...) are application vocabulary — the starter kit's `RestNetworkClient` reads `method`/`path`/`params`/`body` — not engine-defined command fields. See [`net`](commands/net.md) for the boundary between engine and application vocabulary.

`DriverError(code, message?, data?)` represents expected failures. `DISMISSED` routes only to `_dismiss`. `BOUNDARY_HANDLED` means an application boundary already handled the failure: `_then` and `_error` are skipped and the error is not reported, but `_always` still runs. Built-in modal errors include `MODAL_NOT_FOUND` and `NO_OVERLAY`; `NetworkResult.errorCode` values pass through unchanged. Unhandled expected or unexpected failures are reported by the action host.

## Command telemetry

`CommandObserver` records engine-known structure only: `type`, `origin`, optional `branch_origin`, `invocation_id`, and a sorted `param_keys` list. Parameter values are never included, and there are no special `query_id` or network-variable fields; richer request telemetry belongs in the application `NetworkClient`.

Whether a command gets a *reserved, latency-measured* span is declared, not type-checked: `Driver.measured` (the engine's `net` command is `true`) or, for app commands, `ExternalCommand.measured` opt-in. A measured command reserves the event before it runs and completes it with `outcome`, `duration_ms`, and optional `error_code` once it settles. An unmeasured command records only on failure — no duration, no success record — so a `command` event in a sink is never proof a command ran unless it was measured.

See [interaction](interaction.md), [lifecycle](lifecycle.md), and [external commands](commands/external.md).
