import 'command_schema.dart';
import 'widget_schema.dart';

/// One immutable snapshot of every template-facing identifier the language
/// accepts: widget types (with their schemas), command types, motion names,
/// and expression function names.
///
/// This is the compile stage's single source of truth — the validator reads
/// only this, never a runtime factory. The runtime assembles the catalog once
/// at boot from what was registered ([Engine.initialize] → catalog freeze),
/// but nothing here depends on Flutter or the runtime: a build-time or
/// server-side compiler can construct the same catalog from declarations and
/// validate templates without a device.
final class LanguageCatalog {
  LanguageCatalog({
    required Map<String, WidgetSchema> widgets,
    required Set<String> commands,
    Set<String>? motions,
    Set<String>? functions,
  }) : widgets = Map.unmodifiable(widgets),
       commands = Set.unmodifiable(commands),
       motions = motions == null ? null : Set.unmodifiable(motions),
       functions = functions == null ? null : Set.unmodifiable(functions);

  /// Widget type → schema (kind, produced/required layout protocol).
  final Map<String, WidgetSchema> widgets;

  /// Every command `_type` an action may name.
  final Set<String> commands;

  /// Every `_motion` name (atoms and composite presets), or `null` when the
  /// assembler cannot enumerate them — validation of motion names is skipped.
  final Set<String>? motions;

  /// Every registered expression function name, or `null` when the assembler
  /// cannot enumerate them — validation of call names is skipped.
  final Set<String>? functions;

  /// The catalog as the compile-side registries currently stand.
  ///
  /// Widget and command identifiers live in compile-owned registries (seeded
  /// by the runtime before any compile), so this covers them; motion and
  /// function names are runtime-owned and unknown here — pass a full catalog
  /// (the engine's boot-time one) to validate those too.
  factory LanguageCatalog.fromRegistries() => LanguageCatalog(
    widgets: WidgetSchemaRegistry.all(),
    commands: CommandSchemaRegistry.all(),
  );
}
