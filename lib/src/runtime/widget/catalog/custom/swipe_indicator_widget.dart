import 'package:flutter/widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../util/props_resolver.dart';
import '../../swipe/swipe_controller_scope.dart';

/// `swipe_indicator` — A page indicator that follows its `swipe_layout`'s [SwipeController].
///
/// Reads the controller's continuous `page`, so the active dot glides in step
/// with drags, ballistic snaps, autoplay, and taps alike — the chosen [effect]
/// shapes that transition (worm, expanding, scale, …). Tapping a dot seeks. It
/// is fully decoupled from the panes: place it anywhere between or beside them.
///
/// ```yaml
/// _type: swipe_indicator
/// controller: example
/// ```
///
/// Props:
/// - `controller` (`text`, default `null`) — optional `swipe_layout` id; omit it to use the nearest layout.
/// - `dot_width` (`size` (scaled by EngineMetrics), default `8.0`) — width of each indicator dot.
/// - `dot_height` (`size` (scaled by EngineMetrics), default `8.0`) — height of each indicator dot.
/// - `spacing` (`size` (scaled by EngineMetrics), default `8.0`) — gap between adjacent children or indicator dots.
/// - `radius` (`size` (scaled by EngineMetrics), default `8.0`) — corner radius of indicator dots.
/// - `color` (`color`, default `#66FFFFFF`) — color or tint.
/// - `active_color` (`color`, default `#FFFFFFFF`) — color used for the selected or active state.
/// - `effect` (`text`, default `worm`) — transition style of the active dot. Values: worm | expand | scale | jump | slide | scrolling | swap | color.
/// - `expansion_factor` (`number`, default `3`) — width multiplier for the active expanding dot.
/// - `scale` (`number`, default `1.6`) — size multiplier for the active scale-effect dot.
///
/// Child: none.
final class SwipeIndicatorWidget {
  const SwipeIndicatorWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return _SwipeIndicator(
      controllerId: PropsResolver.text(props['controller']),
      effect: _effect(context, props),
    );
  }

  /// Builds the [IndicatorEffect] named by `effect`, defaulting to a worm.
  ///
  /// Common dot geometry and colours apply to every effect; a few effects take
  /// extra shape parameters read from their own props.
  static IndicatorEffect _effect(
    BuildContext context,
    Map<String, Object?> props,
  ) {
    final dotWidth = PropsResolver.size(context, props['dot_width']) ?? 8.0;
    final dotHeight = PropsResolver.size(context, props['dot_height']) ?? 8.0;
    final spacing = PropsResolver.size(context, props['spacing']) ?? 8.0;
    final radius = PropsResolver.size(context, props['radius']) ?? 8.0;
    final dotColor =
        PropsResolver.color(props['color']) ?? const Color(0x66FFFFFF);
    final activeDotColor =
        PropsResolver.color(props['active_color']) ?? const Color(0xFFFFFFFF);

    switch (PropsResolver.text(props['effect'])) {
      case 'expand':
        return ExpandingDotsEffect(
          dotWidth: dotWidth,
          dotHeight: dotHeight,
          spacing: spacing,
          radius: radius,
          dotColor: dotColor,
          activeDotColor: activeDotColor,
          expansionFactor: PropsResolver.number(props['expansion_factor']) ?? 3,
        );
      case 'scale':
        return ScaleEffect(
          dotWidth: dotWidth,
          dotHeight: dotHeight,
          spacing: spacing,
          radius: radius,
          dotColor: dotColor,
          activeDotColor: activeDotColor,
          scale: PropsResolver.number(props['scale']) ?? 1.6,
        );
      case 'jump':
        return JumpingDotEffect(
          dotWidth: dotWidth,
          dotHeight: dotHeight,
          spacing: spacing,
          radius: radius,
          dotColor: dotColor,
          activeDotColor: activeDotColor,
        );
      case 'slide':
        return SlideEffect(
          dotWidth: dotWidth,
          dotHeight: dotHeight,
          spacing: spacing,
          radius: radius,
          dotColor: dotColor,
          activeDotColor: activeDotColor,
        );
      case 'scrolling':
        return ScrollingDotsEffect(
          dotWidth: dotWidth,
          dotHeight: dotHeight,
          spacing: spacing,
          radius: radius,
          dotColor: dotColor,
          activeDotColor: activeDotColor,
        );
      case 'swap':
        return SwapEffect(
          dotWidth: dotWidth,
          dotHeight: dotHeight,
          spacing: spacing,
          radius: radius,
          dotColor: dotColor,
          activeDotColor: activeDotColor,
        );
      case 'color':
        return ColorTransitionEffect(
          dotWidth: dotWidth,
          dotHeight: dotHeight,
          spacing: spacing,
          radius: radius,
          dotColor: dotColor,
          activeDotColor: activeDotColor,
        );
      case 'worm':
      default:
        return WormEffect(
          dotWidth: dotWidth,
          dotHeight: dotHeight,
          spacing: spacing,
          radius: radius,
          dotColor: dotColor,
          activeDotColor: activeDotColor,
        );
    }
  }
}

class _SwipeIndicator extends StatelessWidget {
  const _SwipeIndicator({required this.controllerId, required this.effect});

  final String? controllerId;
  final IndicatorEffect effect;

  @override
  Widget build(BuildContext context) {
    final swipe = SwipeControllerScope.of(context, controllerId);
    if (swipe == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: swipe,
      builder: (context, _) {
        final count = swipe.length;
        return SmoothIndicator(
          offset: swipe.logicalPage,
          count: count,
          size: effect.calculateSize(count),
          effect: effect,
          onDotClicked: swipe.goTo,
        );
      },
    );
  }
}
