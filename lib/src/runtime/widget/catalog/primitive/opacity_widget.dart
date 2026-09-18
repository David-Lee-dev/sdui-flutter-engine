import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `opacity` — Builds Flutter's [Opacity] with a value clamped to Flutter's valid range.
///
/// ```yaml
/// _type: opacity
/// opacity: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `opacity` (`ratio01`, default `1.0`) — alpha applied to the child (0 invisible, 1 opaque).
///
/// Child: `_child`.
final class OpacityWidget {
  const OpacityWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Opacity(
      opacity: PropsResolver.ratio01(props['opacity']) ?? 1.0,
      child: children.isEmpty ? null : children.first,
    );
  }
}
