import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `interactive_viewer` — Lets users pan and scale a child.
///
/// ```yaml
/// _type: interactive_viewer
/// min_scale: 0.5
/// max_scale: 4
/// pan_enabled: true
/// boundary_margin: 20
/// _child: { _type: image, url: https://example.com/map.png }
/// ```
///
/// Props:
/// - `min_scale` (`number`, default `0.8`) — minimum zoom scale.
/// - `max_scale` (`number`, default `2.5`) — maximum zoom scale.
/// - `pan_enabled` (`flag`, default `true`) — whether panning is enabled.
/// - `scale_enabled` (`flag`, default `true`) — whether scaling is enabled.
/// - `constrained` (`flag`, default `true`) — whether the child is constrained to the viewport.
/// - `boundary_margin` (`edge`, default `zero`) — pan boundary outside the viewport.
///
/// Child: `_child`.
final class InteractiveViewerWidget {
  const InteractiveViewerWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) => InteractiveViewer(
    minScale: PropsResolver.number(props['min_scale']) ?? 0.8,
    maxScale: PropsResolver.number(props['max_scale']) ?? 2.5,
    panEnabled: PropsResolver.flag(props['pan_enabled']) ?? true,
    scaleEnabled: PropsResolver.flag(props['scale_enabled']) ?? true,
    constrained: PropsResolver.flag(props['constrained']) ?? true,
    boundaryMargin:
        PropsResolver.edge(context, props['boundary_margin']) ??
        EdgeInsets.zero,
    child: children.isEmpty ? const SizedBox.shrink() : children.first,
  );
}
