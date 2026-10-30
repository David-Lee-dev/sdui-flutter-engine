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

  Widget _resolve(Environment env) {
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
    Widget resolve() => NodeGuard.run(directive.path, () => _resolve(env));
    if (listenable == null) return resolve();
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) => resolve(),
    );
  }
}
