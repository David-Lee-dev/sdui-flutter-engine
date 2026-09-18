import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `safe_area` — Builds Flutter's [SafeArea], supplying an empty child when required.
///
/// ```yaml
/// _type: safe_area
/// top: true
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `top` (`flag`, default `true`) — offset from the parent top edge.
/// - `bottom` (`flag`, default `true`) — offset from the parent bottom edge.
/// - `left` (`flag`, default `true`) — offset from the parent left edge.
/// - `right` (`flag`, default `true`) — offset from the parent right edge.
/// - `maintain_bottom_view_padding` (`flag`, default `false`) — preserves bottom view padding when the keyboard appears.
/// - `minimum` (`edge`, default `EdgeInsets.zero`) — minimum safe-area inset on each edge.
///
/// Child: `_child`.
final class SafeAreaWidget {
  const SafeAreaWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return SafeArea(
      top: PropsResolver.flag(props['top']) ?? true,
      bottom: PropsResolver.flag(props['bottom']) ?? true,
      left: PropsResolver.flag(props['left']) ?? true,
      right: PropsResolver.flag(props['right']) ?? true,
      maintainBottomViewPadding:
          PropsResolver.flag(props['maintain_bottom_view_padding']) ?? false,
      minimum: PropsResolver.edge(context, props['minimum']) ?? EdgeInsets.zero,
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}
