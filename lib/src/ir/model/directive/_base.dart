import '../action/command.dart';
import '../event_timing.dart';
import '../lifecycle_hook.dart';
import '../scope_config.dart';
import 'package:sdui_engine/src/ir/compiled_value.dart';
import 'package:sdui_engine/src/ir/expression.dart';

part 'plain_directive.dart';
part 'condition_directive.dart';
part 'loop_directive.dart';
part 'morph_directive.dart';
part 'scope_directive.dart';
part 'switch_directive.dart';

/// Represents one rendering stage in the compiled directive tree.
///
/// Terminal nodes and structural wrappers use the same abstraction, leaving
/// expressions unresolved until interpretation. The sealed hierarchy keeps all
/// rendering variants exhaustive within this library.
sealed class Directive {
  const Directive();
}
