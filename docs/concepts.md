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

`LanguageCatalog` is an immutable snapshot of the accepted widget schemas, command types, motion atoms/presets, and expression function names. `Compile.build(template, keys, catalog: ...)` validates against the supplied snapshot. `BuiltinLanguage` declares the entire built-in language — every widget schema, command type, motion name, and expression function name — compile-side, with no Flutter or runtime dependency; `LanguageCatalog.builtin()` is that declaration alone, usable by a build-time or server-side compiler with no device or registry involved. `Engine.initialize` registers the built-ins and application extensions, freezes the registries, and assembles the boot snapshot exposed as `Engine.catalog`; `EngineRunner` passes that catalog to every compile.

With the boot catalog, unknown widget or command types, unknown `_motion` names, unknown function calls in those validated expression positions, unknown reserved keys, undeclared binding roots, incompatible child forms, and protocol mismatches all fail before mounting. Motion failures contain `unknown motion`; function failures contain `unknown function`.

A bare `EngineRunner` mount before initialization no longer degrades validation: it falls back to `Engine.snapshotCatalog()`, a live enumeration of the compile-side widget/command registries plus every registered motion and function name — the built-ins from `BuiltinLanguage` (registries are pre-seeded from it) union any directly-registered customs. Unknown widget, command, motion, and function names all still fail at compile time in this configuration; only the frozen boot catalog itself (and the `net` command's `NetworkClient`) is missing.

## Initialization and logging

`Sdui.initialize` installs application extensions before freezing the process-wide catalogs. The low-level `Engine.initialize` accepts the same catalog extensions, with `externalCommands` in place of the facade's `services`:

| Parameter | Purpose |
| --- | --- |
| `services` / `externalCommands` | Register app-owned command types. |
| `widgets` | Register app-owned widget specifications by template `_type`. |
| `motions` | Register [`Motion`](motion.md#custom-motion-atoms) implementations by their `type`. |
| `functions` | Register [expression functions](expressions.md#application-functions) by call name. |
| `presentation` | Install an app-owned `SduiPresentation` — [tap feedback](interaction.md#tap-feedback), [`modal`](commands/modal.md) chrome, typography, scaling, and error/loading surfaces (see below). |
| `errorObserver` (optional) | Install an `SduiErrorObserver`; defaults to `FlutterErrorObserver`, preserving the classic `FlutterError.reportError` behavior. See [errors](errors.md#sduierrorobserver). |
| `telemetry` (optional) | Install a `TelemetrySink`; defaults to a no-op sink, so not observing is a valid choice. |
| `toastPresenter` (`Sdui.initialize` only) | Replace the facade's default `SnackBar` presentation for [`toast`](commands/toast.md). |
| `debugLogLevel` | Set the minimum engine diagnostic level (default `info`; pass `LogLevel.debug` for action, state and widget detail). Per-frame `scroll` actions and interval ticks never log. |
| `logOutput` | Receive each formatted engine log line in an app-owned sink. |

Initialization is process-wide and single-shot. A second call to either `Sdui.initialize` or `Engine.initialize` throws `StateError` before changing services, loaders, presentation, logging, or any registry.

Engine diagnostics remain debug-only. Their default output is Flutter's `debugPrint`; pass `logOutput: (line) => appLogger.debug(line)` to either initializer to redirect them. Internally this is the same output hook exposed by `EngineLog.configure(output: ...)`; changing the destination does not enable logs in release mode.

A `EngineRunner` mounted without either initializer (a bare test mount) still compiles and still fully validates, against a live registry snapshot instead of the frozen boot catalog — only no `NetworkClient` is configured for the `net` command. The engine warns once per process (`EngineLog.warn`) when this happens — intended only for tests, since in an app it signals a boot-order bug.

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
- `loadErrorBuilder` — global fallback for a retryable screen *load* failure (the app's `ScreenLoader` threw); a page-local `errorBuilder` still wins.
- `nodeErrorBuilder` — global replacement for the degraded-node surface (`SduiErrorScope.nodeBuild` isolation); `null` keeps the classic policy of a compact debug-only tag / empty release box.
- `loadingBuilder` — global default for the facade's loading surface; a page-local `loadingBuilder` still wins.

The full error-surface map — which builder wins, what gets reported to `SduiErrorObserver`, and how domain failures (`_error[code]`) stay separate from engine errors — is in [errors.md](errors.md).

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

## Insets

Since 0.11.0 the SDK applies no safe-area policy of its own. The host app owns it: which edges are cleared (status bar, notch, home indicator, Android system bar), and how that differs per platform. It decides by wrapping the engine in its own `SafeArea` (or `Scaffold`) and by the `MediaQuery` padding it passes down. A template adds more only by wrapping its content in [`safe_area`](widgets/layout/safe_area.md).

| Where | Behavior |
| --- | --- |
| [`scaffold`](widgets/navigation/scaffold.md) body | Passed to Flutter's `Scaffold` as is; no `SafeArea`, no Android bottom strip. Without an `app_bar` the body starts at the very top, under the status bar, and keeps the whole `MediaQuery` padding for its content. With an `app_bar` the bar's own frame (status-bar inset plus `app_bar_height`) keeps the body below it, as before. `extend_body` and `extend_body_behind_app_bar` keep their Flutter meaning. `inset_bottom` and `cover_bottom_inset` are no-ops. |
| [`safe_area`](widgets/layout/safe_area.md) | Flutter `SafeArea`: pads only the edges whose `MediaQuery` padding is still there. An edge the host (or an outer `safe_area`, app bar or bottom slot) already consumed adds nothing. |
| Vertical [`single_child_scroll_view`](widgets/scrolling/single_child_scroll_view.md), [`list_view`](widgets/scrolling/list_view.md), [`grid_view`](widgets/scrolling/grid_view.md), [`custom_scroll_view`](widgets/scrolling/custom_scroll_view.md) | Add the `MediaQuery` bottom padding the host passes in after their content, on top of the template `padding` (a `custom_scroll_view` ends with a sliver of that height), and hand their content a bottom padding of 0, so an inner `safe_area` or nested scroll view does not add it again. By default only when the view's bottom edge reaches the bottom inset of the screen; a view that ends higher (above a fixed CTA or bottom bar, inside a centered dialog) adds nothing. `inset_end: true` always adds it, `inset_end: false` never does. The host decides the value: a host that consumed the bottom inset passes 0, and nothing is added. They do not add the top padding. |
| Horizontal scroll views, `page_view`, `tab_bar_view` | Unchanged. A vertical scroll view inside each page applies the rule. |
| Keyboard | Flutter reports a bottom padding of 0 while the keyboard is up, so the end spacing shrinks to the template `padding`; `resize_to_avoid_bottom_inset` works as before. |

The scroll views decide from their laid-out position, ignoring paint-only transforms such as page transitions, and re-check whenever they are laid out or painted. A view in a bottom sheet anchored to the screen bottom reaches it; a view in a centered dialog does not. The first frame assumes the view reaches the bottom. When the measurement disagrees (a scroll above a CTA, or a bottom bar appears later), the next frame changes only the end spacing and the content's bottom padding. Content at the scroll start does not move, except in a `reverse` view, whose start is the bottom edge and shifts by the inset once.

A screen without an `app_bar` whose host leaves the top inset to it wraps its content (or its top part) in a `safe_area` with `bottom: false`. Fixed bottom content, such as a CTA, belongs in the scaffold `bottom_navigation_bar` slot: Flutter then removes the body's bottom padding, so the scroll view adds nothing. Outside that slot, wrap it in a `safe_area` with `top: false`. A `safe_area` with `bottom: true` around a whole scroll view consumes the inset before the scroll view sees it, and the content stops above the inset again. An app shell that draws a floating tab bar should add the bar height to the `MediaQuery` bottom padding rather than shrinking the layout; the scroll views then end above the bar.

Lists and grids built by `_loop._wrap` (`list`, `grid`, `reorderable`, `dismissible`) do not apply these rules. Without `padding` they keep Flutter's own handling, which also adds the bottom padding; with `padding` they add nothing.

## Alignment values

Every `alignment`-typed property (for example `align.alignment`, `stack.alignment`, gradient `begin`/`end`/`center`, motion anchors) accepts one of the nine names `top_left`, `top_center`, `top_right`, `center_left`, `center`, `center_right`, `bottom_left`, `bottom_center`, `bottom_right`, or, since 0.7.0, a list `[x, y]` of two finite numbers in Flutter's `Alignment` coordinates (`[-1, -1]` is top left, `[0, 0]` the center, `[1, 1]` bottom right). Each axis is clamped to −4…4. Anything else falls back to the property's default.

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

A template root may also declare `_requires`, a list of engine features the template needs: `spring_v1` (`_morph._spring`), `shape_v1` (the `shape` widget), `math_v1` (`sin`, `cos`, `pow`, `remap`) and `align_xy_v1` (`[x, y]` alignments). Since 0.9.0 also: `spring_v2` (`_morph._velocity`), `curve_v2` (bezier lists, Material 3 and spring curve names), `motion_repeat_v1` (`repeat: <count>`, `repeat_delay`), `press_v1` (`_on.tap.pressed_as`), `transform_offset_v1` (`offset` in `transform`), `math_v2` (`smoothstep`, `sign`), `parent_data_motion_v1` (`_motion`/`_on` on `positioned`, `positioned_fill`, `expanded`, `flexible`, `spacer`), `shape_v2` (`shape` `op`, per-item `smooth`, `at`, gradient `fill`/`rim`, `shadow`, `backdrop`), `semantics_v1` (the `semantics` widget) and `layout_builder_v1` (the `layout_builder` widget). Since 0.13.0 also: `motion_start_v1` (`_motion` `start: 'mount'`). An unknown feature name fails compilation, and engines older than 0.7.0 reject `_requires` itself as an unknown reserved key, so the template fails to mount instead of rendering partially. `_requires` is accepted only at the root.

Inside `_scope`, the allowed keys are `_state`, `_action`, `_lifecycle`, and `_skeleton`. Inside a command, the metadata keys are `_type`, `_then`, `_error`, `_dismiss`, `_always`, `_background`, `_when`, plus action-level `_dedupe` on the single-command form. Other underscore-prefixed names are rejected; widget/driver properties must not begin with `_`.

See [control flow](control-flow.md), [loops](loops.md), [state](state.md), [actions](actions.md), and [widgets](widgets/README.md).
