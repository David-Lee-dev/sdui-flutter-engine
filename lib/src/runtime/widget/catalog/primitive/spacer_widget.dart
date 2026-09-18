import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `spacer` — Builds Flutter's [Spacer] for use inside a flex layout.
///
/// ```yaml
/// _type: spacer
/// flex: 1
/// ```
///
/// Props:
/// - `flex` (`integer`, default `1`) — share of remaining main-axis space assigned to this child.
///
/// Child: none.
final class SpacerWidget {
  const SpacerWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Spacer(flex: PropsResolver.integer(props['flex']) ?? 1);
  }
}
