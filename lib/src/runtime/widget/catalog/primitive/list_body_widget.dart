import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `list_body` — Builds Flutter's [ListBody] from the node's children.
///
/// ```yaml
/// _type: list_body
/// main_axis: horizontal
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - `main_axis` (`axis`, default `vertical`) — axis along which children are laid out. Values: horizontal | vertical.
/// - `reverse` (`flag`, default `false`) — reverses scroll/paging direction.
///
/// Child: `_children`.
final class ListBodyWidget {
  const ListBodyWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return ListBody(
      mainAxis: PropsResolver.axis(props['main_axis']) ?? Axis.vertical,
      reverse: PropsResolver.flag(props['reverse']) ?? false,
      children: children,
    );
  }
}
