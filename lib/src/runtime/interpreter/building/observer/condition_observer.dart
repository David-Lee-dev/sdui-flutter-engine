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

  Widget _resolve(Environment env, Widget Function(Directive) childOf) {
    for (final (index, branch) in directive.branches.indexed) {
      if (ExpressionEvaluator.evaluateTruthy(branch.predicate, env)) {
        return _show(index, branch.body, childOf);
      }
    }
    return _show('else', directive.fallback, childOf);
  }

  Widget _show(
    Object key,
    Directive? body,
    Widget Function(Directive) childOf,
  ) => NodeBuilder.branch(
    directive,
    directive.presence,
    key,
    body,
    childOf: childOf,
  );

  @override
  Widget build(BuildContext context) {
    final env = Scope.envOf(context) ?? MapEnvironment.empty;
    final listenable = env.listen(directive.roots);
    Widget resolve(Widget Function(Directive) childOf) => NodeGuard.run(
      directive.path,
      () => _resolve(env, childOf),
      produces: NodeBuilder.produces(directive),
    );
    if (listenable == null) return resolve(NodeBuilder.build);
    final childOf = NodeBuilder.memo();
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) => resolve(childOf),
    );
  }
}
