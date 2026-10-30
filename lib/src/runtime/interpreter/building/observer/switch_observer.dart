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

  Directive? _match(Object? value) {
    for (final branch in directive.cases) {
      if (branch.value == value) return branch.branch;
    }
    return directive.fallback;
  }

  /// While the selector waits on an automatic skeleton, the first case that
  /// will draw the awaited data, else the fallback.
  Directive? _pendingMatch(Environment env) {
    for (final branch in directive.cases) {
      if (NodeBuilder.readsPending(branch.branch, env)) return branch.branch;
    }
    return directive.fallback;
  }

  Widget _resolve(BuildContext context, Environment env) {
    if (NodeBuilder.isPending(context, env, directive.roots)) {
      final branch = _pendingMatch(env);
      return branch == null
          ? const SizedBox.shrink()
          : NodeBuilder.build(branch);
    }
    final branch = _match(
      ExpressionEvaluator.evaluate(directive.selector, env),
    );
    if (branch == null) return const SizedBox.shrink();
    return NodeBuilder.build(branch);
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
