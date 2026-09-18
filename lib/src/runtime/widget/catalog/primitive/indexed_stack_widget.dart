import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `indexed_stack` — Builds Flutter's [IndexedStack] for an `indexedStack` node.
///
/// ```yaml
/// _type: indexed_stack
/// index: 1
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - `index` (`integer`, default `0`) — externally controlled current page index.
/// - `alignment` (`alignment`, default `AlignmentDirectional.topStart`) — positions the child or children within the available space. Values: top_left | top_center | top_right | center_left | center | center_right | bottom_left | bottom_center | bottom_right.
/// - `text_direction` (`textDirection`, default `null`) — resolves start/end ordering and alignment. Values: ltr | rtl.
/// - `sizing` (`stackFit`, default `loose`) — determines whether the scrollbar thumb uses fixed or dynamic sizing. Values: loose | expand | passthrough.
/// - `clip_behavior` (`clip`, default `hard_edge`) — edge clipping behavior. Values: none | hard_edge | anti_alias | anti_alias_with_save_layer.
///
/// Child: `_children`.
final class IndexedStackWidget {
  const IndexedStackWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    if (children.isEmpty) return const SizedBox.shrink();
    final i = (PropsResolver.integer(props['index']) ?? 0).clamp(
      0,
      children.length - 1,
    );
    return IndexedStack(
      index: i,
      alignment:
          PropsResolver.alignment(props['alignment']) ??
          AlignmentDirectional.topStart,
      textDirection: PropsResolver.textDirection(props['text_direction']),
      sizing: PropsResolver.stackFit(props['sizing']) ?? StackFit.loose,
      clipBehavior: PropsResolver.clip(props['clip_behavior']) ?? Clip.hardEdge,
      children: children,
    );
  }
}
