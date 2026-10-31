import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import '../../../environment/_base.dart';
import '../../../environment/map_environment.dart';
import '../../../wrapper/scope/scope.dart';
import '../../expression_evaluator.dart';
import '../node_builder.dart';
import '../node_guard.dart';

/// Selects an equal switch case and observes the selector's binding roots.
class SwitchObserver extends StatelessWidget {
  const SwitchObserver({super.key, required this.directive});

  final SwitchDirective directive;

  (Object, Directive?) _match(Object? value) {
    for (final (index, branch) in directive.cases.indexed) {
      if (branch.value == value) return (index, branch.branch);
    }
    return ('default', directive.fallback);
  }

  Widget _resolve(Environment env, Widget Function(Directive) childOf) {
    final (key, branch) = _match(
      ExpressionEvaluator.evaluate(directive.selector, env),
    );
    return NodeBuilder.branch(
      directive,
      directive.presence,
      key,
      branch,
      childOf: childOf,
    );
  }

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
