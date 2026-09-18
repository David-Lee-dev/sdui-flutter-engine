import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `custom_scroll_view` — Builds a [CustomScrollView] from children that are already slivers.
///
/// ```yaml
/// _type: custom_scroll_view
/// scroll_direction: horizontal
/// _children:
///   - { _type: sliver_list, _children: [{ _type: text, value: a }] }
///   - { _type: sliver_fill_remaining, _child: { _type: text, value: b } }
/// ```
///
/// Props:
/// - `scroll_direction` (`axis`, default `vertical`) — axis along which content scrolls. Values: horizontal | vertical.
/// - `reverse` (`flag`, default `false`) — reverses scroll/paging direction.
/// - `primary` (`flag`, default `null`) — uses the route primary scroll controller when true.
/// - `physics` (`scrollPhysics`, default `null`) — scroll physics. Values: never | bouncing | clamping | always.
/// - `keyboard_dismiss_behavior` (`keyboardDismissBehavior`, default `null`) — chooses whether dragging dismisses the keyboard. Values: manual | on_drag.
/// - `shrink_wrap` (`flag`, default `false`) — sizes the scroll view to its content along the scroll axis.
/// - `clip_behavior` (`clip`, default `hard_edge`) — edge clipping behavior. Values: none | hard_edge | anti_alias | anti_alias_with_save_layer.
///
/// Child: `_children`.
///
/// Children must produce slivers.
final class CustomScrollViewWidget {
  const CustomScrollViewWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return CustomScrollView(
      scrollDirection:
          PropsResolver.axis(props['scroll_direction']) ?? Axis.vertical,
      reverse: PropsResolver.flag(props['reverse']) ?? false,
      primary: PropsResolver.flag(props['primary']),
      physics: PropsResolver.scrollPhysics(props['physics']),
      keyboardDismissBehavior: PropsResolver.keyboardDismissBehavior(
        props['keyboard_dismiss_behavior'],
      ),
      shrinkWrap: PropsResolver.flag(props['shrink_wrap']) ?? false,
      clipBehavior: PropsResolver.clip(props['clip_behavior']) ?? Clip.hardEdge,
      slivers: children,
    );
  }
}
