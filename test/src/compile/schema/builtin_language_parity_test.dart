import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/schema/builtin_language.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/motion/composite/presets.dart';
import 'package:sdui_engine/src/runtime/motion/motion_factory.dart';
import 'package:sdui_engine/src/runtime/util/function_registry.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

/// The drift guard between the compile-side language declaration and the
/// runtime's registrations. [BuiltinLanguage] is the SSOT a server-side
/// compiler validates against; the runtime is what a device actually does —
/// these must be the same language, identifier for identifier.
void main() {
  WidgetFactory.ensureRegistered();
  DriverRegistry.ensureRegistered();

  group('BuiltinLanguage parity', () {
    test('widget schemas: same types, same kind and protocols', () {
      final runtime = <String, String>{};
      for (final type in WidgetFactory.types()) {
        final schema = WidgetFactory.schemaOf(type)!;
        runtime[type] =
            '${schema.kind.name}/${schema.produces.name}/${schema.childProtocol?.name}';
      }
      final declared = BuiltinLanguage.widgets.map(
        (type, schema) => MapEntry(
          type,
          '${schema.kind.name}/${schema.produces.name}/${schema.childProtocol?.name}',
        ),
      );
      expect(runtime, declared);
    });

    test('command types match the sealed driver set', () {
      expect(DriverRegistry.builtinTypes, BuiltinLanguage.commands);
    });

    test('motion names match atoms + composite presets', () {
      expect(
        {...MotionFactory.types(), ...MotionPresets.names()},
        BuiltinLanguage.motions,
      );
    });

    test('expression function names match the registry', () {
      expect(FunctionRegistry.names(), BuiltinLanguage.functions);
    });
  });
}
