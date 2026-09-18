import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `constrained_box` — Builds Flutter's [ConstrainedBox] with unconstrained defaults for invalid props.
///
/// ```yaml
/// _type: constrained_box
/// constraints: example
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `constraints` (`constraints`, default `unconstrained`) — minimum and maximum dimensions imposed on the child.
///
/// Child: `_child`.
final class ConstrainedBoxWidget {
  const ConstrainedBoxWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return ConstrainedBox(
      constraints:
          PropsResolver.constraints(context, props['constraints']) ??
          const BoxConstraints(),
      child: children.isEmpty ? null : children.first,
    );
  }
}
