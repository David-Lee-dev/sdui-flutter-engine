import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `ignore_pointer` — Builds Flutter's [IgnorePointer] to pass pointer events through.
///
/// Unlike `absorb_pointer`, which absorbs pointer events, this makes the subtree
/// invisible to hit-testing so pointer events pass through to widgets below.
///
/// ```yaml
/// _type: ignore_pointer
/// ignoring: true
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `ignoring` (`flag`, default `true`) — when true, the subtree is invisible to
///   hit-testing so pointer events pass through to widgets below.
///
/// Child: `_child`.
final class IgnorePointerWidget {
  const IgnorePointerWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return IgnorePointer(
      ignoring: PropsResolver.flag(props['ignoring']) ?? true,
      child: children.isEmpty ? null : children.first,
    );
  }
}
