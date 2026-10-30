import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `semantics` — Describes its child to assistive technology.
///
/// ```yaml
/// _type: semantics
/// label: Home
/// button: true
/// selected: ${tab == 0}
/// _child: { _type: icon, name: home }
/// ```
///
/// Props:
/// - `label` (`text`, default `null`) — the spoken label, read before the
///   child's own text.
/// - `button` (`flag`, default `false`) — announces the node as a button.
/// - `selected` (`flag`, default `null`) — gives the node a selected state;
///   absent means the node has no selected state.
/// - `hidden` (`flag`, default `false`) — removes the node and its child from
///   the semantics tree (the child still paints).
///
/// An invalid value falls back to its default.
///
/// Child: `_child`.
final class SemanticsWidget {
  const SemanticsWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final child = children.isEmpty ? null : children.first;
    if (PropsResolver.flag(props['hidden']) ?? false) {
      return ExcludeSemantics(child: child ?? const SizedBox.shrink());
    }
    return Semantics(
      container: true,
      label: PropsResolver.text(props['label']),
      button: PropsResolver.flag(props['button']) ?? false,
      selected: PropsResolver.flag(props['selected']),
      child: child,
    );
  }
}
