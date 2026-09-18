import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import '../../environment/_base.dart';
import '../../environment/map_environment.dart';
import '../expression_evaluator.dart';

/// Evaluates a loop source into binding frames with stable child keys.
///
/// Non-list sources produce no items. Duplicate or non-scalar keys are rejected
/// because Flutter cannot preserve child identity across reordering without them.
final class LoopResolver {
  const LoopResolver._();

  static List<({Map<String, Object?> frame, String key})> resolve(
    LoopDirective loop,
    Environment env,
  ) {
    final items = ExpressionEvaluator.resolveValue(loop.source, env);
    if (items is! List) return const [];
    final result = <({Map<String, Object?> frame, String key})>[];
    final firstIndex = <String, int>{};
    for (var i = 0; i < items.length; i++) {
      final entry = _item(loop, items[i], i, env);
      final prev = firstIndex[entry.key];
      if (prev != null) {
        throw FormatException(
          '_loop at ${loop.path}: duplicate key "${entry.key}" '
          '(index $prev and $i). reconciliation/reorder requires unique keys.',
        );
      }
      firstIndex[entry.key] = i;
      result.add(entry);
    }
    return result;
  }

  static ({Map<String, Object?> frame, String key}) _item(
    LoopDirective loop,
    Object? item,
    int index,
    Environment env,
  ) {
    final frame = {loop.as: item, loop.index: index};
    final value = ExpressionEvaluator.evaluate(
      loop.keyExpression,
      MapEnvironment(frame, parent: env),
    );
    return (frame: frame, key: _key(loop, value));
  }

  static String _key(LoopDirective loop, Object? value) {
    if (value is String) return value;
    if (value is num && value.isFinite) return value.toString();
    throw FormatException(
      '_loop.key "${loop.keyExpression.source}" at ${loop.path} resolved to '
      '${value.runtimeType} ($value); key must be a String or finite number.',
    );
  }
}
