# sdui_engine

Server-driven UI for Flutter: JSON templates (compiled from YAML on the
server) become a live, reactive widget tree — bindings, actions, drivers,
modals, motion — without app releases.

## Quick start

```dart
import 'package:sdui_engine/sdui_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Sdui.initialize(
    screenLoader: MyScreenLoader(),   // required — where templates come from
    apiClient: MyApiClient(),         // required — the data plane
  );
  runApp(MaterialApp.router(routerConfig: Sdui.router()));
}
```

The rule is uniform: **the app implements and injects every dependency** —
loader, api client, media sources, storage. The package ships no default
implementations (telemetry alone falls back to a no-op sink). The starter kit
carries reference implementations for all of them under `lib/app/impl`.
Every screen is served at `/screens/:id` and query parameters land in each
screen's root state.

## Override any seam

The seams follow one rule: **`contract/` constrains, `defaults/` does the
bare minimum.** A contract is an abstract class defining exactly what an
injected implementation must provide — and nothing about *how* (transport,
caching, storage are the implementor's freedom). Anything that would need a
server URL baked in has NO default — it is required; the rest defaults.

| Parameter | Contract | Default |
|---|---|---|
| `screenLoader` | `ScreenLoader` | **required** — where templates come from is the app's server contract |
| `apiClient` | `ApiClient` | **required** — installed as the `api` command |
| `keyValueStore` / `secureStore` | storage contracts | in-memory |
| `imageSource` / `videoSource` | media contracts | bundled assets (`AssetImageSource` / `AssetVideoSource`); network sources are app implementations (the loading polish — `fadeInImageFrame`, `shimmerPlaceholder`, `loadingImageTransition` — is exported for reuse) |
| `telemetry` | `TelemetrySink` | `NoopTelemetrySink` — observes nothing; runtime toggle via `Sdui.telemetryEnabled` |
| `services` | `SduiService` | none — the ONLY extension channel: a service bundles the `ExternalCommand`s of one integration (ads SDK, support chat, clipboard, ...) with an `onRegister` setup hook. Drivers cannot be injected — every driver (`set`, `api`, `navigate`, `toast`, `modal`, `scroll`, `sys_haptic`, ...) is engine-owned and locked; `api` routes to the injected `ApiClient` |
| `widgets` | `WidgetSpec` | app-owned widget types |

`Sdui.router(routes: [...], loadingBuilder: ..., errorBuilder: ...)` composes
app-owned routes (tab shells, pre-warmed screens, custom transitions) in front
of the generic screen route and swaps the loading/error surfaces.

Runtime toggles: `Sdui.telemetryEnabled = false` stops telemetry delivery
without rewiring the sink (privacy opt-out); set it back to resume.

Full control: skip the facade — call `Engine.initialize` and mount
`EngineRunner`/`SduiScreenPage` yourself. The public API is exactly the
`sdui_engine.dart` barrel (plus `testing.dart` for test hooks); `src/` paths
are implementation and unsupported.

## Layering

```
sdui_engine.dart / testing.dart      public barrels (the entire API surface)
src/shell/       Sdui facade, SduiService, SduiScreenPage, router (go_router)
src/dependency/  seams the app must implement and inject
src/contract/    cross-cutting protocols (ExternalCommand)
src/impl/        package implementations (NoopTelemetrySink only)
src/ir + compile + runtime           the engine: compile -> validate -> interpret
```

The engine core owns no transport and no platform services; everything
platform-shaped enters through `Sdui.initialize`.

## Template language

See the starter kit's `docs/TEMPLATE-GUIDE.md` and the compiler spec
(`../spec/SPEC.md`) for the authoring format.
