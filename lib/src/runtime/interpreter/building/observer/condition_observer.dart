import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import '../../../environment/_base.dart';
import '../../../environment/map_environment.dart';
import '../../../wrapper/scope/scope.dart';
import '../../expression_evaluator.dart';
import '../node_builder.dart';
import '../node_guard.dart';

/// Selects the first truthy conditional branch and observes its predicate roots.
class ConditionObserver extends StatelessWidget {
  const ConditionObserver({super.key, required this.directive});

  final ConditionDirective directive;

  Widget _resolve(Environment env) {
    for (final branch in directive.branches) {
      if (ExpressionEvaluator.evaluateTruthy(branch.predicate, env)) {
        return NodeBuilder.build(branch.body);
      }
    }
    final fallback = directive.fallback;
    if (fallback == null) return const SizedBox.shrink();
    return NodeBuilder.build(fallback);
  }

  @override
  Widget build(BuildContext context) {
    final env = Scope.envOf(context) ?? MapEnvironment.empty;
    final listenable = env.listen(directive.roots);
    Widget resolve() => NodeGuard.run(directive.path, () => _resolve(env));
    if (listenable == null) return resolve();
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) => resolve(),
    );
  }
}
