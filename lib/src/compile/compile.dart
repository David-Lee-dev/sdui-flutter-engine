import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/ui_node.dart';

import 'compiler/template_compiler.dart';
import 'schema/language_catalog.dart';
import 'template_parser.dart';
import 'template_validator.dart';

/// The validated compile output: the directive tree plus the parsed node count
/// (retained only for the mount's debug log).
typedef CompileResult = ({Directive directive, int nodeCount});

/// Turns a server template into validated engine IR.
final class Compile {
  const Compile._();

  /// Parses, compiles, and validates [template]; [rootDataKeys] are the
  /// outermost lexical declarations (root data). Throws
  /// [InvalidTemplateException] on any template defect.
  ///
  /// [catalog] is the language definition validation reads. When omitted it
  /// snapshots the compile-side registries (which the runtime seeds before
  /// any mount) — that covers widgets and commands but cannot enumerate
  /// motion/function names, so those checks are skipped. The engine passes
  /// its full boot-time catalog; a server-side compiler passes its own.
  static CompileResult build(
    Map<String, Object?> template,
    Set<String> rootDataKeys, {
    LanguageCatalog? catalog,
  }) {
    final node = TemplateParser.buildUiTree(template);
    final directive = TemplateCompiler.buildDirectiveTree(node);
    TemplateValidator.validate(directive, rootDataKeys, catalog: catalog);
    return (directive: directive, nodeCount: _countNodes(node));
  }

  static int _countNodes(UiNode node) =>
      1 +
      node.children.fold<int>(0, (count, child) => count + _countNodes(child)) +
      node.slots.values.fold<int>(
        0,
        (count, child) => count + _countNodes(child),
      );
}
