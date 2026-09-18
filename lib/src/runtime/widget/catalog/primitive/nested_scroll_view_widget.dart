import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `nested_scroll_view` — Builds a [NestedScrollView] using positional child roles.
///
/// Every child except the last is treated as a header sliver; the last child is
/// the box body. An empty node receives an empty body.
///
/// ```yaml
/// _type: nested_scroll_view
/// scroll_direction: horizontal
/// _children:
///   - { _type: sliver_app_bar, pinned: true }
///   - { _type: list_view, shrink_wrap: true }
/// ```
///
/// Props:
/// - `scroll_direction` (`axis`, default `vertical`) — axis along which content scrolls. Values: horizontal | vertical.
/// - `reverse` (`flag`, default `false`) — reverses scroll/paging direction.
/// - `physics` (`scrollPhysics`, default `null`) — scroll physics. Values: never | bouncing | clamping | always.
/// - `float_header_slivers` (`flag`, default `false`) — coordinates outer floating headers with inner scrolling.
///
/// Child: `_children` (header slivers followed by one box body).
final class NestedScrollViewWidget {
  const NestedScrollViewWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final headerSlivers = children.length <= 1
        ? const <Widget>[]
        : children.sublist(0, children.length - 1);
    final body = children.isEmpty ? const SizedBox.shrink() : children.last;
    return NestedScrollView(
      scrollDirection:
          PropsResolver.axis(props['scroll_direction']) ?? Axis.vertical,
      reverse: PropsResolver.flag(props['reverse']) ?? false,
      physics: PropsResolver.scrollPhysics(props['physics']),
      floatHeaderSlivers:
          PropsResolver.flag(props['float_header_slivers']) ?? false,
      headerSliverBuilder: (context, innerBoxIsScrolled) => headerSlivers,
      body: body,
    );
  }
}
