import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

import '../../../util/props_resolver.dart';

/// `auto_scroll` — A seamless, infinitely repeating scrolling marquee.
///
/// Repeats the node's positional children forever along the selected axis. The
/// loop has no wrap or jump-back, and the list is not user-scrollable.
///
/// ```yaml
/// _type: auto_scroll
/// scroll_direction: horizontal
/// speed: 40
/// spacing: 12
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - `scroll_direction` (`axis`, default `vertical`) — axis along which content scrolls. Values: horizontal | vertical.
/// - `height` (`size`, default `null`) — optional viewport height.
/// - `width` (`size`, default `null`) — optional viewport width.
/// - `speed` (`number`, default `40`) — forward scroll speed in logical pixels per second.
/// - `spacing` (`size`, default `0`) — gap after each repeated item.
/// - `reverse` (`flag`, default `false`) — reverses the scroll direction.
/// - `pause_on_interaction` (`flag`, default `false`) — pauses while a pointer is held down.
///
/// Child: `_children`.
final class AutoScrollWidget {
  const AutoScrollWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return _AutoScroll(
      scrollDirection:
          PropsResolver.axis(props['scroll_direction']) ?? Axis.vertical,
      height: PropsResolver.size(context, props['height']),
      width: PropsResolver.size(context, props['width']),
      speed: PropsResolver.number(props['speed']) ?? 40,
      spacing: PropsResolver.size(context, props['spacing']) ?? 0,
      reverse: PropsResolver.flag(props['reverse']) ?? false,
      pauseOnInteraction:
          PropsResolver.flag(props['pause_on_interaction']) ?? false,
      children: children,
    );
  }
}

class _AutoScroll extends StatefulWidget {
  const _AutoScroll({
    required this.scrollDirection,
    required this.height,
    required this.width,
    required this.speed,
    required this.spacing,
    required this.reverse,
    required this.pauseOnInteraction,
    required this.children,
  });

  final Axis scrollDirection;
  final double? height;
  final double? width;
  final double speed;
  final double spacing;
  final bool reverse;
  final bool pauseOnInteraction;
  final List<Widget> children;

  @override
  State<_AutoScroll> createState() => _AutoScrollState();
}

class _AutoScrollState extends State<_AutoScroll>
    with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  late final Ticker _ticker;
  Duration _elapsedBeforePause = Duration.zero;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    _lastElapsed = elapsed;
    if (!_controller.hasClients) return;
    final totalElapsed = _elapsedBeforePause + elapsed;
    final seconds =
        totalElapsed.inMicroseconds / Duration.microsecondsPerSecond;
    _controller.jumpTo(seconds * widget.speed);
  }

  void _pause() {
    if (!_ticker.isActive) return;
    _elapsedBeforePause += _lastElapsed;
    _ticker.stop();
  }

  void _resume() {
    if (_ticker.isActive) return;
    _lastElapsed = Duration.zero;
    _ticker.start();
  }

  Widget _item(Widget child) {
    return Padding(
      padding: widget.scrollDirection == Axis.horizontal
          ? EdgeInsets.only(right: widget.spacing)
          : EdgeInsets.only(bottom: widget.spacing),
      child: child,
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.children.length;
    if (count == 0) return const SizedBox.shrink();

    Widget list = ListView.builder(
      controller: _controller,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) => _item(widget.children[index % count]),
    );

    if (widget.pauseOnInteraction) {
      list = Listener(
        onPointerDown: (_) => _pause(),
        onPointerUp: (_) => _resume(),
        onPointerCancel: (_) => _resume(),
        child: list,
      );
    }

    if (widget.height != null || widget.width != null) {
      list = SizedBox(height: widget.height, width: widget.width, child: list);
    }
    return list;
  }
}
