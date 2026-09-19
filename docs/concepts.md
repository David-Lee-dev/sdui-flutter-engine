# Core concepts

An SDUI template is a YAML/JSON widget tree that is parsed, compiled to typed directives, validated against frozen catalogs, and interpreted reactively.

## Node anatomy

Every node is a map with a string `_type`:

```yaml
_type: container
padding: 16
_key: profile-card
_motion: fade_in
_child:
  _type: text
  value: '${user.name}'
```

Bare keys are widget properties. Structural and compiler keys start with `_`. `_child`, `_children`, and `_slots` are mutually exclusive child forms; `_key`, when present, must be a string. A tree may be at most 256 nested nodes deep.

Widget property values, command parameters, `_motion` parameters, `_on.*.event`, and loop-wrapper parameters are recursively compiled for [expressions](expressions.md). Structural shapes are not interpolated.

## Compile pipeline

1. **Parse** — `TemplateParser` requires `_type`, parses child forms, splits bare props from reserved keys, and attaches diagnostic paths.
2. **Compile** — `TemplateCompiler` turns values into literals/expressions and wraps plain widgets with morph, scope, condition, and loop directives. Wrapper order from inner to outer is morph → scope → condition → loop.
3. **Validate** — `TemplateValidator` checks the compiled tree against a `LanguageCatalog`: widget and command registration, motion names, function calls in widget properties and command parameters/guards, binding roots, action references, child shapes, writable bindings, loop wrappers, and box/sliver protocols, including inactive branches.
4. **Interpret** — observers evaluate against the current environment, subscribe only to referenced roots, and rebuild the affected directive.

`LanguageCatalog` is an immutable snapshot of the accepted widget schemas, command types, motion atoms/presets, and expression function names. `Compile.build(template, keys, catalog: ...)` validates against the supplied snapshot. `Engine.initialize` registers the built-ins and application extensions, freezes the registries, and assembles the boot snapshot exposed as `Engine.catalog`; `EngineRunner` passes that catalog to every compile.

With the boot catalog, unknown widget or command types, unknown `_motion` names, unknown function calls in those validated expression positions, unknown reserved keys, undeclared binding roots, incompatible child forms, and protocol mismatches all fail before mounting. Motion failures contain `unknown motion`; function failures contain `unknown function`.

`Compile.build` without a catalog, including a bare `EngineRunner` mount before initialization, falls back to a snapshot of the compile-side widget and command registries. That fallback cannot enumerate runtime-owned motions or functions, so only those two name checks are skipped; runtime resolution can still reject an unknown name if execution reaches it.

## Initialization and logging

`Sdui.initialize` installs application extensions before freezing the process-wide catalogs. The low-level `Engine.initialize` accepts the same catalog extensions, with `externalCommands` in place of the facade's `services`:

| Parameter | Purpose |
| --- | --- |
| `services` / `externalCommands` | Register app-owned command types. |
| `widgets` | Register app-owned widget specifications by template `_type`. |
| `motions` | Register [`Motion`](motion.md#custom-motion-atoms) implementations by their `type`. |
| `functions` | Register [expression functions](expressions.md#application-functions) by call name. |
| `presentation` | Install an app-owned `SduiPresentation` — [tap feedback](interaction.md#tap-feedback), [`modal`](commands/modal.md) chrome, typography, scaling, and error/loading surfaces (see below). |
| `telemetry` (optional) | Install a `TelemetrySink`; defaults to a no-op sink, so not observing is a valid choice. |
| `toastPresenter` (`Sdui.initialize` only) | Replace the facade's default `SnackBar` presentation for [`toast`](commands/toast.md). |
| `debugLogLevel` | Set the minimum engine diagnostic level. |
| `logOutput` | Receive each formatted engine log line in an app-owned sink. |

Initialization is process-wide and single-shot. A second call to either `Sdui.initialize` or `Engine.initialize` throws `StateError` before changing services, loaders, presentation, logging, or any registry.

Engine diagnostics remain debug-only. Their default output is Flutter's `debugPrint`; pass `logOutput: (line) => appLogger.debug(line)` to either initializer to redirect them. Internally this is the same output hook exposed by `EngineLog.configure(output: ...)`; changing the destination does not enable logs in release mode.

A `EngineRunner` mounted without either initializer (a bare test mount) still compiles, against a registry snapshot instead of the frozen boot catalog: motion and function name validation is skipped, and no `NetworkClient` is configured for the `net` command. The engine warns once per process (`EngineLog.warn`) when this happens — intended only for tests, since in an app it signals a boot-order bug.

**Drivers are sealed.** They are the engine's internal execution tools for built-in commands (`net`, `modal`, `navigate`, `set`, storage, haptics, …) and move with the engine; apps cannot register or replace one. Needing a new driver means proposing a new engine capability for every consumer of this package (a contribution), not an app-side extension. App-specific capability ships as `services`/`externalCommands` instead — each `ExternalCommand.type` becomes a template-callable `{ _type: ... }` and the engine routes to it knowing nothing else. See [external commands](commands/external.md).

## Contracts, presentation, and package defaults

Source under `lib/src` splits app-facing configuration into three roles, distinguished by what each one is allowed to contain:

| Layer | Contains | Contains no policy decisions | Examples |
| --- | --- | --- | --- |
| `contract/` | Shapes — abstract seams and their carrier/signal types. | Required | `ScreenLoader`, `NetworkClient`, `ImageSource`, `VideoSource`, `AppStorage`, `SecureStorage` (required at `Sdui.initialize`); `TelemetrySink`, `TapFeedback` (optional, package defaults exist); `ExternalCommand` (the shared protocol app services implement). |
| `impl/` | Decisions — the package's own implementation of an optional contract. | No — this is where the decision lives | `NoopTelemetrySink`, `InkTapFeedback`. |
| `presentation/` | Values — static configuration with no behavior of its own. | Yes | `SduiPresentation`, `ModalStyle`, `SduiTypography`, `SduiScaling`. |

A contract never bundles a policy call; whether a seam is *required* is expressed by `Sdui.initialize`'s/`Engine.initialize`'s signature (a plain required parameter), not by which folder it lives in. `presentation/` values only carry configuration — anything that makes a decision (like which press effect to draw) is a `contract/` interface, with the app's chosen implementation held as a value inside `SduiPresentation`.

`SduiPresentation` (in `presentation/`) carries:

- `tapFeedback` — a `TapFeedback` implementation; `null` uses the package default (`InkTapFeedback`, [see interaction](interaction.md#tap-feedback)).
- `modal` — `ModalStyle`, the [`modal`](commands/modal.md) command's chrome.
- `typography` — `SduiTypography(fontFamily, baseStyle)`, merged *under* every template `style` (template fields win field by field; see `PropsResolver.textStyle`).
- `scaling` — `SduiScaling(baseWidth: 390, minScale: 0.82, maxScale: 1.0)`, the width band `EngineMetrics.scaleForWidth` scales template dimensions against.
- `screenErrorBuilder` — global fallback for a mount-level compile failure; a mount-local `EngineRunner.errorBuilder`/`SduiScreenPage.errorBuilder` still wins. The package default renders neutral English text ("This screen could not be loaded.").
- `loadingBuilder` — global default for the facade's loading surface; a page-local `loadingBuilder` still wins.

## Telemetry

`Sdui.initialize`/`Engine.initialize` install the app's `TelemetrySink` (or the no-op default) once at boot; `Sdui.telemetryEnabled` toggles delivery at runtime without re-initializing. `ScreenVisit.begin(screenId)` (exported from `sdui_engine`) issues a fresh `screen_view_id`, records `screen_view`, and returns the id an `EngineRunner`/`ScreenPage`-like mount threads through for dwell/scroll telemetry and the matching `screen_leave`. `SduiScreenPage` calls it internally; an app that mounts `EngineRunner` directly (skipping the facade) owns calling it itself:

```dart
final visit = ScreenVisit.begin('home');
EngineRunner(screenId: 'home', screenViewId: visit.id, ...);
```

Command-level telemetry is covered in [actions](actions.md#command-telemetry) and [external commands](commands/external.md#telemetry).

## Structural contracts

The runtime has five widget specification kinds:

| Kind | Child form | Runtime behavior |
| --- | --- | --- |
| eager | `_child` or `_children` | Receives an already-built positional list. |
| slot | `_slots` | Receives named children; positional children are rejected. |
| builder | positional child | Requests scoped children lazily. |
| bound | none | Receives live state value and change/submit callbacks. |
| action | `_child` or `_children` | Receives positional children and an action dispatcher. |

The parser rejects mixing `_slots` with positional children and mixing `_child` with `_children`. Validation additionally rejects slots on non-slot specifications, positional children on slot specifications, and any children on bound inputs.

## Box and sliver protocols

Every widget declares the render protocol it produces and the protocol its children require. Most produce and consume boxes. Sliver producers are valid only under sliver parents such as [`custom_scroll_view`](widgets/scrolling/custom_scroll_view.md); [`sliver_to_box_adapter`](widgets/scrolling/sliver_to_box_adapter.md) adapts a box into a sliver. A bare sliver at the engine root is invalid.

`nested_scroll_view` deliberately accepts mixed child roles. Loop wrappers `sliver_list` and `sliver_grid` produce slivers; all other loop wrappers produce boxes. Repeated items themselves must produce boxes.

## Reserved keys

The parser always consumes `_type`, `_child`, `_children`, `_slots`, and `_key`. The compiler recognizes these additional widget-node markers:

| Key | Purpose |
| --- | --- |
| `_if` | Conditional node or `cond` branch predicate. |
| `_else` | Literal-`true` fallback marker on a `cond` child only. |
| `_value` | Whole-expression selector on `switch`. |
| `_case` | Literal string/number/bool case label on a `switch` child. |
| `_default` | Literal-`true` switch fallback marker. |
| `_loop` | Repetition and wrapper configuration. |
| `_morph` | Animated numeric/scalar environment value. |
| `_scope` | State, actions, lifecycle, and skeleton boundary. |
| `_on` | Interaction event map. |
| `_motion` | Motion atom/preset or list. |
| `_provides` | Builder-provided readable variable names. |

Inside `_scope`, the allowed keys are `_state`, `_action`, `_lifecycle`, and `_skeleton`. Inside a command, the metadata keys are `_type`, `_then`, `_error`, `_dismiss`, `_always`, `_background`, `_when`, plus action-level `_dedupe` on the single-command form. Other underscore-prefixed names are rejected; widget/driver properties must not begin with `_`.

See [control flow](control-flow.md), [loops](loops.md), [state](state.md), [actions](actions.md), and [widgets](widgets/README.md).
