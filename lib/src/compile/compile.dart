import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/ui_node.dart';

import 'compiler/template_compiler.dart';
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
  /// Callers must ensure the widget/command schema registries are seeded (the
  /// runtime does this at mount) before calling — validation reads them.
  static CompileResult build(
    Map<String, Object?> template,
    Set<String> rootDataKeys,
  ) {
    final node = TemplateParser.buildUiTree(template);
    final directive = TemplateCompiler.buildDirectiveTree(node);
    TemplateValidator.validate(directive, rootDataKeys);
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
