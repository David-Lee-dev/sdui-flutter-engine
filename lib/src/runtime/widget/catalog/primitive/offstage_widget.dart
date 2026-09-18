import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `offstage` — Builds Flutter's [Offstage] for an `offstage` node.
///
/// ```yaml
/// _type: offstage
/// offstage: true
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `offstage` (`flag`, default `true`) — lays out the child without painting or hit testing it.
///
/// Child: `_child`.
final class OffstageWidget {
  const OffstageWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Offstage(
      offstage: PropsResolver.flag(props['offstage']) ?? true,
      child: children.isEmpty ? null : children.first,
    );
  }
}
