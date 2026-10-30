import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import '../../../environment/map_environment.dart';
import '../../../wrapper/scope/scope.dart';
import '../node_builder.dart';
import '../node_guard.dart';

/// Reassembles a plain directive when one of its compiled binding roots changes.
///
/// Static nodes avoid allocating a [ListenableBuilder].
class PlainObserver extends StatelessWidget {
  const PlainObserver({
    super.key,
    required this.directive,
    this.isolate = false,
  });

  final PlainDirective directive;

  /// Whether the node repaints continuously (it is the direct widget of a
  /// spring or repeating morph) and so sits in its own repaint boundary.
  final bool isolate;

  @override
  Widget build(BuildContext context) {
    final env = Scope.envOf(context) ?? MapEnvironment.empty;
    final listenable = env.listen(directive.roots);
    Widget assemble() => NodeGuard.run(
      directive.path,
      () => NodeBuilder.assemble(
        context,
        directive,
        env,
        isolate: isolate,
        pending: NodeBuilder.isPending(
          context,
          env,
          NodeBuilder.visualRoots(directive),
        ),
      ),
    );
    if (listenable == null) return assemble();
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) => assemble(),
    );
  }
}
