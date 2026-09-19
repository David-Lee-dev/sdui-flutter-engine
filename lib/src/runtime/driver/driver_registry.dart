import 'package:flutter/foundation.dart';

import '../log/logging_driver.dart';
import 'package:sdui_engine/src/compile/schema/command_schema.dart';
import '_base.dart';
import 'anchoring_driver.dart';
import 'net_driver.dart';
import 'app_storage_driver.dart';
import 'haptic_driver.dart';
import 'secure_storage_driver.dart';
import 'navigate_driver.dart';
import 'scroll_driver.dart';
import 'set_driver.dart';
import 'toast_driver.dart';
import 'modal/modal_driver.dart';

/// Owns the process-wide mapping from command types to drivers.
final class DriverRegistry {
  const DriverRegistry._();

  static const Map<String, Driver> _builtins = {
    'set': SetDriver(),
    'net': NetDriver(),
    'sys_haptic': HapticDriver(),
    'anchoring': AnchoringDriver(),
    'app_storage': AppStorageDriver(),
    'secure_storage': SecureStorageDriver(),
    'scroll': ScrollDriver(),
    'navigate': NavigateDriver(),
    'toast': ToastDriver(),
    'modal': ModalDriver(),
  };

  static final Map<String, Driver> _drivers = _buildDrivers();

  static Map<String, Driver> _buildDrivers() {
    CommandSchemaRegistry.registerAll(_builtins.keys);
    return {..._builtins};
  }

  static bool _frozen = false;

  /// Prevents further registration for the current engine configuration.
  static void freeze() {
    _drivers;
    _frozen = true;
  }

  /// Seeds the compile-time [CommandSchemaRegistry] from the built-in drivers.
  ///
  /// The validator reads the command schema registry without touching this
  /// registry, so a mount must trigger its lazy init before validating.
  static void ensureRegistered() {
    _drivers;
  }

  /// Returns whether [type] can currently be resolved.
  static bool knows(String type) => _drivers.containsKey(type);

  /// Installs or replaces [driver] before the registry is frozen.
  ///
  /// Engine-owned driver types (the built-ins) cannot be replaced — their
  /// semantics are part of the template language, and swapping one out can
  /// break the engine in ways validation cannot catch. Apps add capability
  /// under their own types (`sys_*` by convention).
  static void register(Driver driver) {
    if (_frozen) {
      throw StateError('DriverRegistry is frozen — register before freeze().');
    }
    if (_builtins.containsKey(driver.type)) {
      throw ArgumentError.value(
        driver,
        'driver',
        "'${driver.type}' is engine-owned and cannot be replaced",
      );
    }
    _drivers[driver.type] = driver;
    CommandSchemaRegistry.register(driver.type);
  }

  /// Wires a configured instance of an engine-owned driver at boot.
  ///
  /// Engine internal — `Engine.initialize` injects app services (api client,
  /// stores) into the engine-owned drivers through this path; it accepts only
  /// types that already exist as built-ins, so it can never *add* capability.
  static void installEngineOwned(Driver driver) {
    if (_frozen) {
      throw StateError('DriverRegistry is frozen — register before freeze().');
    }
    if (!_builtins.containsKey(driver.type) || driver.type == 'set') {
      throw ArgumentError.value(
        driver,
        'driver',
        "'${driver.type}' is not a configurable engine-owned driver",
      );
    }
    _drivers[driver.type] = driver;
  }

  /// Registers each driver in iteration order.
  static void registerAll(Iterable<Driver> drivers) {
    for (final driver in drivers) {
      register(driver);
    }
  }

  /// Restores built-in drivers and unfreezes the registry.
  static void reset() {
    _frozen = false;
    CommandSchemaRegistry.reset();
    _drivers
      ..clear()
      ..addAll(_builtins);
    CommandSchemaRegistry.registerAll(_builtins.keys);
  }

  /// Returns the driver for [type].
  ///
  /// Throws [StateError] when no driver is registered for [type].
  /// Returns the driver for [type], or `null` when none is registered.
  static Driver? resolveOrNull(String type) => _drivers[type];

  static Driver resolve(String type) {
    final driver = _drivers[type];
    if (driver == null) {
      throw StateError('Unknown driver type: "$type".');
    }
    if (kDebugMode && driver.type != 'set') return LoggingDriver(driver);
    return driver;
  }
}
