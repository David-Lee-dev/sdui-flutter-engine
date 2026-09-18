import 'contract/external_command.dart';
import 'dependency/image_source.dart';
import 'dependency/app_storage.dart';
import 'dependency/secure_storage.dart';
import 'dependency/telemetry_sink.dart';
import 'dependency/video_source.dart';
import 'runtime/driver/app_storage_driver.dart';
import 'runtime/driver/secure_storage_driver.dart';
import 'dependency/api_client.dart';
import 'runtime/driver/_base.dart';
import 'runtime/driver/api_driver.dart';
import 'runtime/driver/driver_registry.dart';
import 'runtime/driver/external_driver.dart';
import 'runtime/engine_catalog.dart';
import 'runtime/log/engine_log.dart';
import 'runtime/media/image_source_registry.dart';
import 'runtime/media/video_source_registry.dart';
import 'runtime/telemetry/telemetry.dart';
import 'runtime/widget/factory.dart';

/// The engine's one-time startup entry point.
///
/// Wires the app's concrete services into the engine's static catalog and
/// freezes it. Call exactly once when the app builds, before any screen mounts.
/// There is no engine instance — this configures process-wide engine state and
/// locks it (see [EngineCatalog.freeze]).
final class Engine {
  const Engine._();

  /// Installs application services and freezes the process-wide engine state.
  ///
  /// App-configured drivers keep platform services outside the engine's
  /// dependency surface.
  ///
  /// @param drivers Drivers to install before the engine catalog is frozen.
  /// @param telemetry Optional app-owned telemetry delivery boundary.
  /// @param widgets App-owned widget specs keyed by their template `_type`.
  ///   Use this for widgets that need an SDK the engine must not depend on —
  ///   the engine only routes the type, exactly as it does for
  ///   [ExternalCommand].
  static void initialize({
    required ApiClient apiClient,
    required ImageSource imageSource,
    required VideoSource videoSource,
    required AppStorage appStorage,
    required SecureStorage secureStorage,
    List<ExternalCommand> externalCommands = const [],
    TelemetrySink? telemetry,
    Map<String, WidgetSpec> widgets = const {},
    LogLevel? debugLogLevel,
  }) {
    if (debugLogLevel != null) {
      EngineLog.configure(minLevel: debugLogLevel, colors: true);
    }
    ImageSourceRegistry.install(imageSource);
    VideoSourceRegistry.install(videoSource);
    DriverRegistry.installEngineOwned(ApiDriver(client: apiClient));
    DriverRegistry.installEngineOwned(AppStorageDriver(store: appStorage));
    DriverRegistry.installEngineOwned(SecureStorageDriver(store: secureStorage));
    for (final command in externalCommands) {
      DriverRegistry.register(ExternalDriver(command));
    }
    if (telemetry != null) Telemetry.install(telemetry);
    WidgetFactory.registerAll(widgets);
    EngineCatalog.freeze();
  }
}
