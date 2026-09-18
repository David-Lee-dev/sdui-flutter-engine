import 'package:flutter/widgets.dart';

/// `intrinsic_height` — Builds Flutter's [IntrinsicHeight] for an `intrinsicHeight` node.
///
/// ```yaml
/// _type: intrinsic_height
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - None.
///
/// Child: `_child`.
final class IntrinsicHeightWidget {
  const IntrinsicHeightWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return IntrinsicHeight(child: children.isEmpty ? null : children.first);
  }
}
