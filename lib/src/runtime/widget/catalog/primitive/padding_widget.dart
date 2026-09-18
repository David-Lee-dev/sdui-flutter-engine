import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `padding` — Builds Flutter's [Padding], defaulting malformed padding to zero.
///
/// ```yaml
/// _type: padding
/// padding: example
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `padding` (`edge`, default `EdgeInsets.zero`) — inner spacing.
///
/// Child: `_child`.
final class PaddingWidget {
  const PaddingWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Padding(
      padding: PropsResolver.edge(context, props['padding']) ?? EdgeInsets.zero,
      child: children.isEmpty ? null : children.first,
    );
  }
}
