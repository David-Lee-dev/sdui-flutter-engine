/// Server-driven UI for Flutter: JSON templates -> live, reactive widget tree.
///
/// Quick start:
/// ```dart
/// Sdui.initialize(screenLoader: MyScreenLoader(), networkClient: MyNetworkClient());
/// runApp(MaterialApp.router(routerConfig: Sdui.router()));
/// ```
/// The app implements and injects every required contract seam; optional
/// seams (telemetry, tap feedback) carry package defaults — see [Sdui].
///
/// This barrel is the package's entire public API; implementation lives under
/// `src/` and is not part of the contract (importing `src/` paths is
/// unsupported). Test-only hooks are in `package:sdui_engine/testing.dart`.
/// Explicit `show` lists keep the surface from growing by accident.
library;

// ── Contracts: required seams the app implements and injects ────────────────
export 'src/contract/network_client.dart'
    show NetworkClient, NetworkRequest, NetworkResult;
export 'src/contract/image_source.dart'
    show
        ImageRequest,
        ImageResult,
        ImageSource,
        NoImage,
        PendingImage,
        ReadyImage;
export 'src/contract/app_storage.dart' show AppStorage;
export 'src/contract/screen_loader.dart' show LoadedScreen, ScreenLoader;
export 'src/contract/external_command.dart'
    show CommandDismissed, CommandFailure, CommandInvocation, ExternalCommand;
export 'src/shell/sdui_service.dart' show SduiService;
export 'src/contract/secure_storage.dart' show SecureStorage;
export 'src/contract/telemetry_sink.dart'
    show TelemetryEvent, TelemetryReservation, TelemetrySink;
export 'src/contract/video_source.dart' show VideoRequest, VideoSource;

// ── Optional-seam contracts and their package defaults ──────────────────────
export 'src/runtime/media/asset_image_source.dart' show AssetImageSource;
export 'src/runtime/media/asset_video_source.dart' show AssetVideoSource;
export 'src/impl/noop_telemetry_sink.dart' show NoopTelemetrySink;

// ── Extension points: services (commands), custom widgets, motions, functions
export 'src/runtime/motion/_base.dart' show Motion, MotionParams, MotionPlan;
export 'src/contract/tap_feedback.dart' show TapFeedback;
export 'src/impl/ink_tap_feedback.dart' show InkTapFeedback;
export 'src/presentation/modal_style.dart' show ModalStyle;
export 'src/presentation/presentation.dart'
    show SduiPresentation, SduiScreenErrorBuilder, SduiToastPresenter;
export 'src/presentation/scaling.dart' show SduiScaling;
export 'src/presentation/typography.dart' show SduiTypography;
export 'src/compile/schema/language_catalog.dart' show LanguageCatalog;
export 'src/compile/schema/widget_schema.dart' show WidgetSchema, WidgetKind;
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
export 'src/runtime/telemetry/screen_visit.dart' show ScreenVisit;
export 'src/runtime/media/loading_image.dart'
    show fadeInImageFrame, loadingImageTransition, shimmerPlaceholder;

// ── Batteries-included app shell ────────────────────────────────────────────
export 'src/shell/screen_page.dart'
    show SduiErrorBuilder, SduiLoadingBuilder, SduiScreenPage;
export 'src/shell/sdui.dart' show Sdui;
