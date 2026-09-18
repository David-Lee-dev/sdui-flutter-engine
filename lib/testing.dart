/// Test-only hooks for apps writing widget tests against the engine.
///
/// Re-exports the app barrel, so this is a sufficient single import for test
/// files. The engine's catalogs are process-wide and freeze at
/// `Sdui.initialize` / `Engine.initialize`; tests that boot the engine must
/// reset them between cases:
///
/// ```dart
/// tearDown(resetEngineForTest);
/// ```
///
/// Import this library **only from test code** — none of it is part of the
/// app-facing API in `package:sdui_engine/sdui_engine.dart`.
library;

import 'src/compile/schema/widget_schema.dart';
import 'src/dependency/network_client.dart';
import 'src/runtime/driver/net_driver.dart';
import 'src/runtime/driver/driver_registry.dart';
import 'src/runtime/media/image_source_registry.dart';
import 'src/runtime/media/video_source_registry.dart';
import 'src/runtime/motion/motion_factory.dart';
import 'src/runtime/telemetry/telemetry.dart';
import 'src/runtime/util/function_registry.dart';
import 'src/runtime/widget/factory.dart';
import 'src/engine.dart';
import 'src/runtime/presentation.dart';
import 'src/shell/sdui_state.dart';

export 'sdui_engine.dart';
export 'src/runtime/driver/driver_registry.dart' show DriverRegistry;

/// Installs [client] as the `net` driver's backend for a bare test mount —
/// the widget-test equivalent of `Sdui.initialize(networkClient: ...)`.
void installTestNetworkClient(NetworkClient client) {
  DriverRegistry.installEngineOwned(NetDriver(client: client));
}

/// Restores every process-wide engine state to its unfrozen built-in default:
/// catalogs, the facade's screen loader, and the telemetry sink/toggle.
///
/// Call from `tearDown` in any test that ran `Sdui.initialize` or
/// `Engine.initialize`, so the next case can initialize again.
void resetEngineForTest() {
  Engine.resetForTest();
  EnginePresentation.reset();
  SduiState.reset();
  Telemetry.reset();
  // Schema registry first — WidgetFactory.reset() re-seeds it.
  WidgetSchemaRegistry.reset();
  WidgetFactory.reset();
  DriverRegistry.reset();
  FunctionRegistry.reset();
  MotionFactory.reset();
  ImageSourceRegistry.reset();
  VideoSourceRegistry.reset();
}
