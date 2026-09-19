import 'package:flutter/foundation.dart' show ValueKey;
import 'package:go_router/go_router.dart';

import '../contract/network_client.dart';
import '../shell/sdui_service.dart';
import '../contract/image_source.dart';
import '../contract/app_storage.dart';
import '../contract/screen_loader.dart';
import '../contract/secure_storage.dart';
import '../contract/telemetry_sink.dart';
import '../contract/video_source.dart';
import '../runtime/motion/_base.dart';
import '../presentation/presentation.dart';
import 'screen_page.dart';
import '../impl/noop_telemetry_sink.dart';
import '../engine.dart';
import '../runtime/log/engine_log.dart';
import '../runtime/telemetry/telemetry.dart';
import '../runtime/widget/factory.dart';
import 'sdui_state.dart';

/// Batteries-included entry point for an SDUI app.
///
/// [initialize] requires an implementation for every dependency — the rule
/// is: the app implements and injects all of them; the package ships no
/// default implementations (the one exception is telemetry, which falls back
/// to a no-op sink so not observing is a valid choice). [router] returns a ready `GoRouter` serving every
/// screen at `/screens/:id`.
///
/// Apps that need full control can skip this facade and call
/// `Engine.initialize` + build their own router directly.
final class Sdui {
  const Sdui._();

  /// Whether telemetry delivery is currently on.
  ///
  /// Toggle at runtime — e.g. a user privacy opt-out. While off, events are
  /// dropped; the installed sink stays wired, so turning it back on needs no
  /// re-initialization. Defaults to on.
  static bool get telemetryEnabled => Telemetry.enabled;

  static set telemetryEnabled(bool value) => Telemetry.setEnabled(value);

  /// The screen loader chosen at [initialize] time.
  static ScreenLoader get screenLoader {
    final loader = SduiState.screenLoader;
    if (loader == null) {
      throw StateError('Sdui.initialize must run before Sdui.screenLoader.');
    }
    return loader;
  }

  /// Initializes the engine with the app's contract implementations.
  ///
  /// Every required seam ([ScreenLoader], [NetworkClient], media sources,
  /// storage) must be injected — where templates, data, storage, and media
  /// come from is the app's to define, and the engine refuses to guess it.
  /// Without them the app does not start. Optional seams carry package
  /// defaults: [telemetry] falls back to the no-op sink,
  /// [presentation]'s tap feedback to the stock ink ripple.
  ///
  /// **Drivers are sealed.** They are the engine's internal execution tools
  /// — they move with the engine, and apps cannot register or replace them.
  /// Needing a new driver means proposing a new engine capability for every
  /// consumer of this package (a contribution), not an app-side extension.
  /// App-specific capability ships as [services] ([SduiService] bundling
  /// [ExternalCommand]s): each command `type` becomes a template-callable
  /// `{ _type: ... }` and the engine routes to it knowing nothing else.
  static void initialize({
    required ScreenLoader screenLoader,
    required NetworkClient networkClient,
    Map<String, NetworkClient> networkProtocols = const {},
    required ImageSource imageSource,
    required VideoSource videoSource,
    required AppStorage appStorage,
    required SecureStorage secureStorage,
    List<SduiService> services = const [],
    TelemetrySink? telemetry,
    Map<String, WidgetSpec> widgets = const {},
    List<Motion> motions = const [],
    Map<String, Object? Function(List<Object?>)> functions = const {},
    SduiPresentation presentation = const SduiPresentation(),
    SduiToastPresenter? toastPresenter,
    LogLevel? debugLogLevel,
    void Function(String line)? logOutput,
  }) {
    // Reject re-initialization before any side effect (service hooks, loader
    // swap) — Engine.initialize would only fail after those mutations.
    if (Engine.catalog != null) {
      throw StateError(
        'Sdui.initialize was already called — engine configuration is '
        'process-wide and freezes at first boot.',
      );
    }
    for (final service in services) {
      service.onRegister();
    }
    SduiState.screenLoader = screenLoader;
    SduiState.toastPresenter = toastPresenter;
    Engine.initialize(
      imageSource: imageSource,
      videoSource: videoSource,
      appStorage: appStorage,
      secureStorage: secureStorage,
      networkClient: networkClient,
      networkProtocols: networkProtocols,
      externalCommands: [for (final service in services) ...service.commands],
      telemetry: telemetry ?? const NoopTelemetrySink(),
      widgets: widgets,
      motions: motions,
      functions: functions,
      presentation: presentation,
      debugLogLevel: debugLogLevel,
      logOutput: logOutput,
    );
  }

  /// Builds the app router.
  ///
  /// Every server-driven screen is served by the generic `/screens/:id` route;
  /// query parameters land in the root scope's state. Register additional
  /// [routes] for screens that need more than the generic path gives them:
  ///
  /// - **fast first paint** (pre-warm or bundle the template),
  /// - **bottom navigation / tab shells** (explicit `StatefulShellRoute`
  ///   branches so tab state survives switches),
  /// - custom transitions, guards, or deep-link aliases.
  ///
  /// @param initialLocation First screen, `/screens/home` by default.
  /// @param routes App routes matched before the generic screen route.
  /// @param loader Screen loader override; defaults to [screenLoader].
  /// @param loadingBuilder Loading surface for [SduiScreenPage].
  /// @param errorBuilder Error surface for [SduiScreenPage].
  static GoRouter router({
    String initialLocation = '/screens/home',
    List<RouteBase> routes = const [],
    ScreenLoader? loader,
    SduiLoadingBuilder? loadingBuilder,
    SduiErrorBuilder? errorBuilder,
  }) => GoRouter(
    initialLocation: initialLocation,
    routes: [
      ...routes,
      GoRoute(
        path: '/screens/:id',
        builder: (context, state) => SduiScreenPage(
          key: ValueKey(state.uri.toString()),
          screenId: state.pathParameters['id']!,
          loader: loader ?? screenLoader,
          params: state.uri.queryParameters,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
        ),
      ),
    ],
  );
}
