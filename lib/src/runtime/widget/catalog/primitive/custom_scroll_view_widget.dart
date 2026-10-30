import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';
import '../../../util/scroll_inset.dart';

/// `custom_scroll_view` — Builds a [CustomScrollView] from children that are already slivers.
///
/// A vertical view that reaches the bottom of the screen scrolls under the
/// bottom system inset and ends with a sliver of that height (see
/// [ScrollInset]).
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
/// - `inset_end` (`flag`, default `null`) — adds the bottom system inset after the content of a vertical view: by default only when the view reaches the bottom inset of the screen; `true` always, `false` never.
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
    final axis = PropsResolver.axis(props['scroll_direction']) ?? Axis.vertical;
    final reverse = PropsResolver.flag(props['reverse']) ?? false;
    final insetEnd = PropsResolver.flag(props['inset_end']);
    return ScrollInset.build(
      context,
      axis: axis,
      insetEnd: insetEnd,
      builder: (context, extent) => CustomScrollView(
        scrollDirection: axis,
        reverse: reverse,
        primary: PropsResolver.flag(props['primary']),
        physics: PropsResolver.scrollPhysics(props['physics']),
        keyboardDismissBehavior: PropsResolver.keyboardDismissBehavior(
          props['keyboard_dismiss_behavior'],
        ),
        shrinkWrap: PropsResolver.flag(props['shrink_wrap']) ?? false,
        clipBehavior:
            PropsResolver.clip(props['clip_behavior']) ?? Clip.hardEdge,
        slivers: _withInset(children, axis, reverse, insetEnd, extent),
      ),
    );
  }

  /// Adds a sliver of [extent] height on the physical bottom edge: the scroll
  /// end, or the scroll start of a `reverse` view.
  ///
  /// The sliver stays when the extent is 0 (keyboard up, or the view does not
  /// reach the bottom), so the other slivers keep their position in the list
  /// and their state.
  static List<Widget> _withInset(
    List<Widget> slivers,
    Axis axis,
    bool reverse,
    bool? insetEnd,
    double extent,
  ) {
    if (axis != Axis.vertical || insetEnd == false) return slivers;
    final inset = SliverToBoxAdapter(child: SizedBox(height: extent));
    return reverse ? [inset, ...slivers] : [...slivers, inset];
  }
}
