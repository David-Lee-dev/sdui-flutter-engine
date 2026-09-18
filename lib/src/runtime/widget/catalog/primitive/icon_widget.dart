import 'package:flutter/widgets.dart';

import '../../util/icon_catalog.dart';
import '../../../util/props_resolver.dart';

/// `icon` — Resolves an icon name through [IconCatalog] and builds a Material [Icon].
///
/// Unknown names produce an empty box instead of constructing invalid icon data.
///
/// ```yaml
/// _type: icon
/// name: example
/// ```
///
/// Props:
/// - `name` (`text`, default `null`) — icon catalog name to render.
/// - `size` (`size` (scaled by EngineMetrics), default `null`) — sets the icon or overflow-box size.
/// - `color` (`color`, default `null`) — color or tint.
/// - `semantic_label` (`text`, default `null`) — accessibility label.
///
/// Child: none.
final class IconWidget {
  const IconWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final code = IconCatalog.codePoint(props['name']);
    if (code == null) return const SizedBox.shrink();
    return Icon(
      IconData(code, fontFamily: 'MaterialIcons'),
      size: PropsResolver.size(context, props['size']),
      color: PropsResolver.color(props['color']),
      semanticLabel: PropsResolver.text(props['semantic_label']),
    );
  }
}
