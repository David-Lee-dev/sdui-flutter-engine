import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `baseline` — Builds Flutter's [Baseline], supplying an empty child when the node has none.
///
/// ```yaml
/// _type: baseline
/// baseline: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `baseline` (`size` (scaled by EngineMetrics), default `0`) — distance from the top edge to the text baseline.
/// - `baseline_type` (`textBaseline`, default `alphabetic`) — baseline system used to position the child. Values: alphabetic | ideographic.
///
/// Child: `_child`.
final class BaselineWidget {
  const BaselineWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Baseline(
      baseline: PropsResolver.size(context, props['baseline']) ?? 0,
      baselineType:
          PropsResolver.textBaseline(props['baseline_type']) ??
          TextBaseline.alphabetic,
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}
