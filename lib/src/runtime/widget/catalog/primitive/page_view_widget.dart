import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';
import '../../contract/action_sink.dart';

/// `page_view` — Builds a stateful [PageView] and dispatches page indices as event data.
///
/// The internal controller is replaced when `viewportFraction` changes so its
/// construction-only configuration remains synchronized with props.
///
/// ```yaml
/// _type: page_view
/// on_page_changed: example
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - `on_page_changed` (`text`, default `null`) — action dispatched with the new page index.
/// - `viewport_fraction` (`number`, default `1.0`) — fraction of the viewport each page occupies (1.0 = full width).
/// - `scroll_direction` (`axis`, default `horizontal`) — axis along which content scrolls. Values: horizontal | vertical.
/// - `reverse` (`flag`, default `false`) — reverses scroll/paging direction.
/// - `physics` (`scrollPhysics`, default `null`) — scroll physics. Values: never | bouncing | clamping | always.
/// - `page_snapping` (`flag`, default `true`) — snaps scrolling to whole-page boundaries.
/// - `pad_ends` (`flag`, default `true`) — centers the first and last page when pages are narrower than the viewport.
///
/// Child: `_children`.
final class PageViewWidget {
  const PageViewWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
    ActionSink? dispatch,
  ) {
    final onPageChanged = PropsResolver.text(props['on_page_changed']);
    return _ControlledPageView(
      viewportFraction: PropsResolver.number(props['viewport_fraction']) ?? 1.0,
      scrollDirection:
          PropsResolver.axis(props['scroll_direction']) ?? Axis.horizontal,
      reverse: PropsResolver.flag(props['reverse']) ?? false,
      physics: PropsResolver.scrollPhysics(props['physics']),
      pageSnapping: PropsResolver.flag(props['page_snapping']) ?? true,
      padEnds: PropsResolver.flag(props['pad_ends']) ?? true,
      onPageChanged: onPageChanged == null || dispatch == null
          ? null
          : (index) => dispatch.handle(onPageChanged, event: index),
      children: children,
    );
  }
}

class _ControlledPageView extends StatefulWidget {
  const _ControlledPageView({
    required this.viewportFraction,
    required this.scrollDirection,
    required this.reverse,
    required this.physics,
    required this.pageSnapping,
    required this.padEnds,
    required this.onPageChanged,
    required this.children,
  });

  final double viewportFraction;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool pageSnapping;
  final bool padEnds;
  final ValueChanged<int>? onPageChanged;
  final List<Widget> children;

  @override
  State<_ControlledPageView> createState() => _ControlledPageViewState();
}

class _ControlledPageViewState extends State<_ControlledPageView> {
  late PageController _controller = _createController();

  PageController _createController() =>
      PageController(viewportFraction: widget.viewportFraction);

  @override
  void didUpdateWidget(_ControlledPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewportFraction != widget.viewportFraction) {
      _controller.dispose();
      _controller = _createController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageView(
    controller: _controller,
    scrollDirection: widget.scrollDirection,
    reverse: widget.reverse,
    physics: widget.physics,
    pageSnapping: widget.pageSnapping,
    padEnds: widget.padEnds,
    onPageChanged: widget.onPageChanged,
    children: widget.children,
  );
}
