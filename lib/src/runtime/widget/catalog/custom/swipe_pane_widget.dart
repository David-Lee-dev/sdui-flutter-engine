import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';
import '../../swipe/swipe_controller.dart';
import '../../swipe/swipe_controller_scope.dart';

/// `swipe_pane` — A swipe area bound to its `swipe_layout`'s [SwipeController].
///
/// Renders a [PageView] whose pages are the node's positional children, and
/// links its [PageController] to the shared controller so any number of panes
/// stay in continuous lockstep: while this pane is dragged it *drives* the
/// controller frame-by-frame; otherwise it *follows*. Flutter's [PageView] and
/// [PageController] surface is exposed 1:1 through snake_case props.
///
/// ```yaml
/// _type: swipe_pane
/// controller: example
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - `controller` (`text`, default `null`) — optional `swipe_layout` id; omit it to use the nearest layout.
/// - `scroll_direction` (`axis`, default `horizontal`) — axis along which content scrolls. Values: horizontal | vertical.
/// - `viewport_fraction` (`number`, default `1.0`) — fraction of the viewport each page occupies (1.0 = full width).
/// - `reverse` (`flag`, default `false`) — reverses scroll/paging direction.
/// - `physics` (`scrollPhysics`, default `null`) — scroll physics. Values: never | bouncing | clamping | always.
/// - `page_snapping` (`flag`, default `true`) — snaps scrolling to whole-page boundaries.
/// - `pad_ends` (`flag`, default `true`) — centers the first and last page when pages are narrower than the viewport.
///
/// Child: `_children`.
final class SwipePaneWidget {
  const SwipePaneWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return _SwipePane(
      controllerId: PropsResolver.text(props['controller']),
      scrollDirection:
          PropsResolver.axis(props['scroll_direction']) ?? Axis.horizontal,
      viewportFraction: PropsResolver.number(props['viewport_fraction']) ?? 1.0,
      reverse: PropsResolver.flag(props['reverse']) ?? false,
      physics: PropsResolver.scrollPhysics(props['physics']),
      pageSnapping: PropsResolver.flag(props['page_snapping']) ?? true,
      padEnds: PropsResolver.flag(props['pad_ends']) ?? true,
      pages: children,
    );
  }
}

/// The controller-side of a pane: converts logical pages to its own pixels so
/// panes with differing viewport fractions stay synchronized by page index.
class _PaneLink implements SwipePaneLink {
  _PaneLink(this.owner, this.pageController);

  @override
  final Object owner;

  final PageController pageController;

  @override
  double? get currentPage =>
      pageController.hasClients ? pageController.page : null;

  @override
  void syncTo(double page) {
    if (!pageController.hasClients) return;
    final position = pageController.position;
    final current = pageController.page;
    if (current == null) return;
    // Pixels-per-page is a constant slope, so a delta from the *current*
    // pixels avoids depending on PageView's private initial-page offset.
    final slope = position.viewportDimension * pageController.viewportFraction;
    if (slope <= 0) return;
    position.jumpTo(position.pixels + (page - current) * slope);
  }

  @override
  Future<void> moveTo(int index, {bool animate = true}) async {
    if (!pageController.hasClients) return;
    if (!animate) {
      pageController.jumpToPage(index);
      return;
    }
    await pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
}

class _SwipePane extends StatefulWidget {
  const _SwipePane({
    required this.controllerId,
    required this.scrollDirection,
    required this.viewportFraction,
    required this.reverse,
    required this.physics,
    required this.pageSnapping,
    required this.padEnds,
    required this.pages,
  });

  final String? controllerId;
  final Axis scrollDirection;
  final double viewportFraction;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool pageSnapping;
  final bool padEnds;
  final List<Widget> pages;

  @override
  State<_SwipePane> createState() => _SwipePaneState();
}

class _SwipePaneState extends State<_SwipePane> {
  SwipeController? _swipe;
  PageController? _pageController;
  _PaneLink? _link;
  bool _dragging = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final swipe = SwipeControllerScope.of(context, widget.controllerId);
    if (identical(swipe, _swipe)) return;
    _detach();
    _swipe = swipe;
    if (swipe != null) _attach(swipe);
  }

  @override
  void didUpdateWidget(_SwipePane oldWidget) {
    super.didUpdateWidget(oldWidget);
    // viewportFraction is fixed at PageController construction, so a change
    // requires rebuilding the controller (and re-linking) to take effect.
    if (oldWidget.viewportFraction != widget.viewportFraction &&
        _swipe != null) {
      final swipe = _swipe!;
      _detach();
      _swipe = swipe;
      _attach(swipe);
    }
  }

  void _attach(SwipeController swipe) {
    final controller = PageController(
      initialPage: swipe.virtualBase + swipe.index,
      viewportFraction: widget.viewportFraction,
    );
    controller.addListener(_onTick);
    final link = _PaneLink(this, controller);
    _pageController = controller;
    _link = link;
    swipe.registerLink(link);
  }

  void _detach() {
    if (_link != null) _swipe?.unregisterLink(_link!);
    _pageController?.removeListener(_onTick);
    _pageController?.dispose();
    _pageController = null;
    _link = null;
  }

  /// Rebroadcasts every movement so the indicator repaints, and — only while
  /// this pane owns the gesture — drives the shared position.
  void _onTick() {
    final swipe = _swipe;
    final controller = _pageController;
    if (swipe == null || controller == null) return;
    swipe.notifyTick();
    if (_dragging) swipe.drive(this, controller.page ?? swipe.page);
  }

  bool _onScroll(ScrollNotification notification) {
    // Only the pane's own PageView scroll is depth 0; any nested scrollable
    // (e.g. an auto_scroll marquee on a page) bubbles up at depth >= 1 and must
    // not be mistaken for this pane's drag. This is Flutter's canonical
    // defaultScrollNotificationPredicate condition.
    if (notification.depth != 0) return false;
    // Ignore inner scrollables (e.g. a vertical list inside a page).
    if (notification.metrics.axis != widget.scrollDirection) return false;
    final swipe = _swipe;
    if (swipe == null) return false;
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _dragging = true;
      swipe.beginInteraction(this);
    } else if (notification is ScrollEndNotification && _dragging) {
      _dragging = false;
      final landed =
          _pageController?.page?.round() ?? (swipe.virtualBase + swipe.index);
      swipe.endInteraction(this, landed);
    }
    return false;
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _pageController;
    final swipe = _swipe;
    if (controller == null || swipe == null) return const SizedBox.shrink();
    final pages = widget.pages;
    // Looping renders an endless builder: virtual page `i` shows `pages[i %
    // n]`, with no item count, so dragging off either end continues into the
    // wrap seam (last→first is forward, not a rewind) and a viewport fraction
    // below 1 always has a neighbour to peek — no blank first/last edge.
    final Widget pager = (swipe.loop && pages.isNotEmpty)
        ? PageView.builder(
            controller: controller,
            scrollDirection: widget.scrollDirection,
            reverse: widget.reverse,
            physics: widget.physics,
            pageSnapping: widget.pageSnapping,
            padEnds: widget.padEnds,
            itemBuilder: (context, index) => pages[index % pages.length],
            itemCount: null,
          )
        : PageView(
            controller: controller,
            scrollDirection: widget.scrollDirection,
            reverse: widget.reverse,
            physics: widget.physics,
            pageSnapping: widget.pageSnapping,
            padEnds: widget.padEnds,
            children: pages,
          );
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: pager,
    );
  }
}
