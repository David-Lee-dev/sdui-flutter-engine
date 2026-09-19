import 'builtin_language.dart';
import 'command_schema.dart';
import 'widget_schema.dart';
import 'widget_schema_registry.dart';

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

  /// The catalog as the compile-side registries currently stand — builtins
  /// pre-seeded, plus whatever custom widgets/commands the runtime added.
  factory LanguageCatalog.fromRegistries() => LanguageCatalog(
    widgets: WidgetSchemaRegistry.all(),
    commands: CommandSchemaRegistry.all(),
    // Motion and function *names* for the built-in language are declared
    // compile-side; runtime-registered custom ones are only known to the
    // engine's boot catalog. Registry snapshots therefore validate against
    // the builtin sets — a mount configured through Engine.initialize gets
    // the full catalog instead.
    motions: BuiltinLanguage.motions,
    functions: BuiltinLanguage.functions,
  );

  /// The engine's built-in language, with no registry or runtime involved —
  /// what a build-time or server-side compiler validates against when the
  /// app adds no custom widgets/commands/motions/functions.
  factory LanguageCatalog.builtin() => LanguageCatalog(
    widgets: BuiltinLanguage.widgets,
    commands: BuiltinLanguage.commands,
    motions: BuiltinLanguage.motions,
    functions: BuiltinLanguage.functions,
  );
}
