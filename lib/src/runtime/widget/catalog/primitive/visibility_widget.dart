import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `visibility` — Builds Flutter's [Visibility] with independently resolved preservation flags.
///
/// ```yaml
/// _type: visibility
/// maintain_state: true
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `maintain_state` (`flag`, default `false`) — keeps the hidden child subtree mounted.
/// - `maintain_size` (`flag`, default `false`) — keeps the hidden child’s layout space.
/// - `visible` (`flag`, default `true`) — shows the child when true.
///
/// Child: `_child`.
final class VisibilityWidget {
  const VisibilityWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final maintainState = PropsResolver.flag(props['maintain_state']) ?? false;
    final maintainSize = PropsResolver.flag(props['maintain_size']) ?? false;
    return Visibility(
      visible: PropsResolver.flag(props['visible']) ?? true,
      maintainState: maintainSize ? true : maintainState,
      maintainAnimation: maintainSize,
      maintainSize: maintainSize,
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}
