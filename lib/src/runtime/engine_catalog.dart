import 'package:sdui_engine/src/compile/schema/command_schema.dart';
import 'package:sdui_engine/src/compile/schema/widget_schema_registry.dart';

import 'driver/driver_registry.dart';
import 'media/image_source_registry.dart';
import 'media/video_source_registry.dart';
import 'motion/motion_factory.dart';
import 'util/function_registry.dart';
import 'widget/factory.dart';

/// Coordinates freezing every engine extension registry after application boot.
///
/// Freezing prevents template semantics from changing while an engine is
/// mounted. Registration must be completed before [freeze] is called.
final class EngineCatalog {
  const EngineCatalog._();

  /// Freezes all extension registries after boot-time registration completes.
  static void freeze() {
    WidgetFactory.freeze();
    DriverRegistry.freeze();
    WidgetSchemaRegistry.freeze();
    CommandSchemaRegistry.freeze();
    MotionFactory.freeze();
    FunctionRegistry.freeze();
    ImageSourceRegistry.freeze();
    VideoSourceRegistry.freeze();
  }
}
