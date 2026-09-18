import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `absorb_pointer` — Builds Flutter's [AbsorbPointer] to absorb pointer events.
///
/// Use this to disable an interactive section, for example while loading.
///
/// ```yaml
/// _type: absorb_pointer
/// absorbing: true
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `absorbing` (`flag`, default `true`) — when true, the subtree looks normal but
///   absorbs pointer events so neither it nor anything below receives them.
///
/// Child: `_child`.
final class AbsorbPointerWidget {
  const AbsorbPointerWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return AbsorbPointer(
      absorbing: PropsResolver.flag(props['absorbing']) ?? true,
      child: children.isEmpty ? null : children.first,
    );
  }
}
