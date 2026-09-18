/// Server-driven UI for Flutter: JSON templates -> live, reactive widget tree.
///
/// Quick start:
/// ```dart
/// Sdui.initialize(screenLoader: MyScreenLoader(), apiClient: MyApiClient());
/// runApp(MaterialApp.router(routerConfig: Sdui.router()));
/// ```
/// Every seam has a working default and accepts a replacement — see [Sdui].
///
/// This barrel is the package's entire public API; implementation lives under
/// `src/` and is not part of the contract (importing `src/` paths is
/// unsupported). Test-only hooks are in `package:sdui_engine/testing.dart`.
/// Explicit `show` lists keep the surface from growing by accident.
library;

// ── Dependencies: the app implements and injects ALL of these ──────────────
export 'src/dependency/api_client.dart' show ApiClient, ApiResult;
export 'src/shell/sdui_service.dart'
    show CommandDismissed, CommandFailure, CommandInvocation, ExternalCommand;
export 'src/dependency/image_source.dart'
    show
        ImageRequest,
        ImageResult,
        ImageSource,
        NoImage,
        PendingImage,
        ReadyImage;
export 'src/dependency/app_storage.dart' show AppStorage;
export 'src/dependency/screen_loader.dart' show LoadedScreen, ScreenLoader;
export 'src/contract/external_command.dart'
    show CommandDismissed, CommandFailure, CommandInvocation, ExternalCommand;
export 'src/shell/sdui_service.dart' show SduiService;
export 'src/dependency/secure_storage.dart' show SecureStorage;
export 'src/dependency/telemetry_sink.dart'
    show TelemetryEvent, TelemetryReservation, TelemetrySink;
export 'src/dependency/video_source.dart' show VideoRequest, VideoSource;

// ── Swappable default implementations ───────────────────────────────────────
export 'src/runtime/media/asset_image_source.dart' show AssetImageSource;
export 'src/runtime/media/asset_video_source.dart' show AssetVideoSource;
export 'src/impl/noop_telemetry_sink.dart' show NoopTelemetrySink;

// ── Extension points: services (commands) and custom widgets ────────────────
export 'src/ir/model/layout_protocol.dart' show LayoutProtocol;
export 'src/runtime/widget/contract/action_sink.dart'
    show ActionInvocation, ActionNode, ActionSink;
export 'src/runtime/widget/contract/child_builder.dart' show ChildBuilder;
export 'src/runtime/widget/contract/spec.dart'
    show
        ActionBuild,
        ActionSpec,
        BoundBuild,
        BoundSpec,
        BuilderBuild,
        BuilderSpec,
        EagerBuild,
        EagerSpec,
        SlotBuild,
        SlotSpec,
        WidgetSpec;

// ── Low-level engine API (skip the facade for full control) ─────────────────
export 'src/engine.dart' show Engine;
export 'src/engine_runner.dart' show EngineRunner;
export 'src/runtime/engine_host.dart'
    show EngineHost, NavigateHandle, ToastHandle;
export 'src/runtime/log/engine_log.dart' show LogLevel;
// Loading polish reusable by app ImageSource implementations.
export 'src/runtime/media/loading_image.dart'
    show fadeInImageFrame, loadingImageTransition, shimmerPlaceholder;

// ── Batteries-included app shell ────────────────────────────────────────────
export 'src/shell/screen_page.dart'
    show SduiErrorBuilder, SduiLoadingBuilder, SduiScreenPage;
export 'src/shell/sdui.dart' show Sdui;
