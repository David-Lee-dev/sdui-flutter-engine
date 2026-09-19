# Error handling

The engine separates two kinds of failure. A **domain failure** — a driver
rejecting a request, an external command throwing on purpose — is expected
template behavior and routes to the template's own `_error[code]` flow (see
[actions](actions.md#error-codes)). An **engine error** — a compile failure,
a node that threw while building, a screen that failed to load, an
unexpected exception in an action command, a scope rejecting a reseed — is
not something a template branch can be written for, and converges on a
single seam instead: [`SduiErrorObserver`](#sduierrorobserver).

The two never cross. A `DriverError`/`CommandFailure` is never reported to
the observer, and an unexpected exception is never routed to `_error[code]`.

## Surfaces

Each surface below has a builder an app can replace, in the same
global-then-local precedence: a value on `SduiPresentation` is the app-wide
default, and a mount-local builder parameter always wins over it.

| Surface | Trigger | Global builder (`SduiPresentation`) | Local override | Package default |
| --- | --- | --- | --- | --- |
| Load failure | The app's `ScreenLoader` threw. Retryable — this is an operational condition (network down, server error), not an engine defect. | `loadErrorBuilder` | Page-local `errorBuilder` | — |
| Compile failure | `TemplateParser`/`TemplateCompiler`/`TemplateValidator` rejected the template. | `screenErrorBuilder` | `EngineRunner.errorBuilder` / `SduiScreenPage.errorBuilder` | Neutral English text ("This screen could not be loaded."). |
| Degraded node | A single node's build threw and was isolated in place (see [Node isolation](#node-isolation)). | `nodeErrorBuilder` | — | Compact diagnostic tag in debug builds, empty layout (`SizedBox.shrink()`) in release. |
| Modal body | A `modal` command's body template failed. | Same as compile failure — modals compile through the same pipeline. | — | — |

`SduiPresentation` and its builder fields are documented in
[concepts.md](concepts.md#contracts-presentation-and-package-defaults).

## Node isolation

`NodeGuard` wraps every node's build. Only `FormatException` and
`StateError` are caught — the two exception types the engine itself raises
for malformed runtime state (bad expression evaluation, invalid binding
reads). Any other exception is an engine defect and is left to propagate
loudly rather than silently degrading a widget.

A caught failure is reported to the observer as `SduiErrorScope.nodeBuild`
with the failing node's template path (`nodePath`), then replaced in place:
`nodeErrorBuilder` if the app installed one, otherwise the package default
(a tagged red box in debug, nothing in release).

## `SduiErrorObserver`

`SduiErrorObserver` is the single seam every unexpected engine error passes
through, structured as an `SduiError`:

```dart
abstract class SduiErrorObserver {
  void onError(SduiError error);
}

final class SduiError {
  final SduiErrorScope scope;
  final Object error;
  final StackTrace? stack;
  final String? screenId;   // known for screenLoad and templateCompile
  final String? nodePath;   // known for nodeBuild
}
```

`SduiErrorScope` has five values:

| Scope | Raised when |
| --- | --- |
| `screenLoad` | The app's `ScreenLoader` threw while loading a screen. |
| `templateCompile` | Parse/compile/validate failed for a screen template. |
| `nodeBuild` | A single node's build failed and was isolated (see above). |
| `action` | An action command threw an unexpected error — not a `DriverError`/`CommandFailure`, which routes to `_error[code]` instead. |
| `scopeReseed` | A scope rejected a reseed whose keyset changed (schema drift). |

Install a custom observer via `Sdui.initialize(errorObserver: ...)` or
`Engine.initialize(errorObserver: ...)`. `onError` runs on the raising
site's stack and must not throw — an observer exception is swallowed by the
engine (`EngineErrors.report`) so a broken observer can never take the
render or action path down with it. Observation cannot alter control flow:
it happens after the engine has already decided how to degrade or continue.

Before the observer runs, the engine always emits its own debug-only log
line (via `EngineLog`, tagged by scope). Redirecting that log
(`logOutput` on either initializer) and installing an observer are
independent — the log always fires, the observer is what apps use to route
errors into their own crash reporting.

### Package default: `FlutterErrorObserver`

Installing nothing keeps the classic behavior: `FlutterErrorObserver`
forwards every scope except `screenLoad` to
`FlutterError.reportError(FlutterErrorDetails(..., library: 'engine'))`,
with a scope-specific `context` description. `screenLoad` is excluded from
the default because it is an operational condition, not a framework
error — an app that installs a custom observer sees it too, since a custom
observer receives every scope with no such exclusion.

## Where this shows up elsewhere

- [Actions](actions.md#error-codes) — the `_error[code]` domain-failure
  flow, and where unexpected action-command errors get reported
  (`SduiErrorScope.action`).
- [External commands](commands/external.md) — `CommandFailure`/
  `CommandDismissed` for expected failures; any other exception thrown by an
  external command is unexpected and reported the same way.
- [Concepts](concepts.md#initialization-and-logging) — the `errorObserver`
  initialization parameter and diagnostic logging.
