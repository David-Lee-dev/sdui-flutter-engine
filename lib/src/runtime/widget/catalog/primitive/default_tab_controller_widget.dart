import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `default_tab_controller` — Provides one [DefaultTabController] to the node's first child.
///
/// ```yaml
/// _type: default_tab_controller
/// length: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `length` (`integer`, default `1`) — number of pages or tabs managed by the controller.
/// - `initial_index` (`integer`, default `0`) — page or tab selected initially.
///
/// Child: `_child`.
final class DefaultTabControllerWidget {
  const DefaultTabControllerWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return DefaultTabController(
      length: PropsResolver.integer(props['length']) ?? 1,
      initialIndex: PropsResolver.integer(props['initial_index']) ?? 0,
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}
