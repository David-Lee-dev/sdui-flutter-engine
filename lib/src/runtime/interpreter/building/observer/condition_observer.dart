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

  Widget _resolve(BuildContext context, Environment env) {
    if (NodeBuilder.isPending(context, env, directive.roots)) {
      return _resolvePending(env);
    }
    for (final branch in directive.branches) {
      if (ExpressionEvaluator.evaluateTruthy(branch.predicate, env)) {
        return NodeBuilder.build(branch.body);
      }
    }
    final fallback = directive.fallback;
    if (fallback == null) return const SizedBox.shrink();
    return NodeBuilder.build(fallback);
  }

  /// While the predicates wait on an automatic skeleton, shows the first
  /// branch that will draw the awaited data, else the fallback.
  Widget _resolvePending(Environment env) {
    for (final branch in directive.branches) {
      if (NodeBuilder.readsPending(branch.body, env)) {
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
    Widget resolve() =>
        NodeGuard.run(directive.path, () => _resolve(context, env));
    if (listenable == null) return resolve();
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) => resolve(),
    );
  }
}
