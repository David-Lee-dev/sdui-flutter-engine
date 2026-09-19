import 'contract/error_observer.dart';
import 'contract/external_command.dart';
import 'contract/image_source.dart';
import 'contract/app_storage.dart';
import 'contract/secure_storage.dart';
import 'contract/telemetry_sink.dart';
import 'contract/video_source.dart';
import 'runtime/driver/app_storage_driver.dart';
import 'runtime/driver/secure_storage_driver.dart';
import 'contract/network_client.dart';
import 'runtime/driver/net_driver.dart';
import 'runtime/motion/_base.dart';
import 'presentation/presentation.dart';
import 'runtime/engine_presentation.dart';
import 'package:sdui_engine/src/compile/schema/command_schema.dart';
import 'package:sdui_engine/src/compile/schema/language_catalog.dart';
import 'package:sdui_engine/src/compile/schema/widget_schema.dart';
import 'runtime/motion/composite/presets.dart';
import 'runtime/motion/motion_factory.dart';
import 'runtime/util/function_registry.dart';
import 'runtime/driver/driver_registry.dart';
import 'runtime/driver/external_driver.dart';
import 'runtime/engine_catalog.dart';
import 'runtime/engine_errors.dart';
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
  /// Drivers are sealed engine internals — apps extend the template language
  /// through [externalCommands]/services, custom [widgets], [motions], and
  /// [functions], never by registering drivers.
  ///
  /// @param telemetry Optional app-owned telemetry delivery boundary.
  /// @param widgets App-owned widget specs keyed by their template `_type`.
  ///   Use this for widgets that need an SDK the engine must not depend on —
  ///   the engine only routes the type, exactly as it does for
  ///   [ExternalCommand].
  static void initialize({
    required NetworkClient networkClient,
    Map<String, NetworkClient> networkProtocols = const {},
    required ImageSource imageSource,
    required VideoSource videoSource,
    required AppStorage appStorage,
    required SecureStorage secureStorage,
    List<ExternalCommand> externalCommands = const [],
    TelemetrySink? telemetry,
    Map<String, WidgetSpec> widgets = const {},
    List<Motion> motions = const [],
    Map<String, Object? Function(List<Object?>)> functions = const {},
    SduiPresentation presentation = const SduiPresentation(),
    SduiErrorObserver? errorObserver,
    LogLevel? debugLogLevel,
    void Function(String line)? logOutput,
  }) {
    // Single-shot: a second initialize would partially mutate frozen global
    // state (services registered, loader swapped) before failing — reject it
    // atomically, before any side effect.
    if (_catalog != null) {
      throw StateError(
        'Engine.initialize was already called — engine configuration is '
        'process-wide and freezes at first boot.',
      );
    }
    if (debugLogLevel != null) {
      EngineLog.configure(minLevel: debugLogLevel, colors: true);
    }
    if (logOutput != null) EngineLog.configure(output: logOutput);
    EnginePresentation.value = presentation;
    if (errorObserver != null) EngineErrors.observer = errorObserver;
    ImageSourceRegistry.install(imageSource);
    VideoSourceRegistry.install(videoSource);
    DriverRegistry.installEngineOwned(
      NetDriver(client: networkClient, protocols: networkProtocols),
    );
    DriverRegistry.installEngineOwned(AppStorageDriver(store: appStorage));
    DriverRegistry.installEngineOwned(SecureStorageDriver(store: secureStorage));
    for (final command in externalCommands) {
      DriverRegistry.register(ExternalDriver(command));
    }
    if (telemetry != null) Telemetry.install(telemetry);
    WidgetFactory.registerAll(widgets);
    MotionFactory.registerAll(motions);
    FunctionRegistry.registerAll(functions);
    // Built-in catalogs are lazily seeded — force them before the freeze and
    // the snapshot, or a boot with no custom widgets would assemble an empty
    // catalog (or throw on post-freeze seeding).
    WidgetFactory.ensureRegistered();
    DriverRegistry.ensureRegistered();
    EngineCatalog.freeze();
    _catalog = LanguageCatalog(
      widgets: WidgetSchemaRegistry.all(),
      commands: CommandSchemaRegistry.all(),
      motions: {...MotionFactory.types(), ...MotionPresets.names()},
      functions: FunctionRegistry.names(),
    );
  }

  /// The frozen language catalog assembled at [initialize], or `null` before
  /// boot (bare test mounts compile against a registry snapshot instead).
  static LanguageCatalog? get catalog => _catalog;

  static LanguageCatalog? _catalog;

  /// Clears the boot-time catalog so tests can initialize again.
  static void resetForTest() => _catalog = null;
}
