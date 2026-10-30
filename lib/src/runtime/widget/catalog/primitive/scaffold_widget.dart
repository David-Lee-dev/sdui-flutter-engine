import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `scaffold` — Assigns named engine slots to the corresponding [Scaffold] regions.
///
/// The `app_bar` slot becomes a fixed app bar: the scaffold adds the status-bar
/// inset and the toolbar height and hands the content the full width (see
/// [_appBar]), so the body stays free — a plain `column`/`list`, no slivers. Use
/// a `sliver_app_bar` in a `custom_scroll_view` body only when you actually want
/// a scroll-away or collapsing bar.
///
/// The `body` slot is always wrapped in a [SafeArea] (see [_body]) that clears
/// the top, left and right device intrusions. The bottom is left to the
/// content: vertical scroll views run under the home indicator and add the
/// inset after their last item, and fixed bottom content (a CTA) goes in the
/// `bottom_navigation_bar` slot or a `safe_area`. Set `inset_bottom` to clear
/// the bottom as before 0.8.0, and `extend_body`/`extend_body_behind_app_bar`
/// to opt an edge out.
///
/// On Android the body's bottom is covered by an opaque strip of the scaffold
/// background as tall as the real system bottom inset (see
/// [_BottomInsetCover]), so content scrolled under the system bar is hidden
/// there. `cover_bottom_inset` forces it on (`true`) or off (`false`).
///
/// ```yaml
/// _type: scaffold
/// background_color: example
/// _slots: { app_bar: { _type: text, value: app_bar }, body: { _type: text, value: body }, bottom_navigation_bar: { _type: text, value: bottom_navigation_bar }, bottom_sheet: { _type: text, value: bottom_sheet }, drawer: { _type: text, value: drawer }, end_drawer: { _type: text, value: end_drawer }, floating_action_button: { _type: text, value: floating_action_button } }
/// ```
///
/// Props:
/// - `background_color` (`color`, default `null`) — paints the widget background.
/// - `floating_action_button_location` (`fabLocation`, default `null`) — positions the floating action button in the scaffold. Values: start_float | center_float | end_float | start_top | center_top | end_top | start_docked | center_docked | end_docked | mini_start_float | mini_center_float | mini_end_float.
/// - `resize_to_avoid_bottom_inset` (`flag`, default `null`) — resizes the body around the keyboard and other bottom insets.
/// - `extend_body` (`flag`, default `false`) — lets the body extend behind the bottom navigation bar.
/// - `extend_body_behind_app_bar` (`flag`, default `false`) — lets the body extend behind the app bar.
/// - `app_bar_height` (`size` (scaled by EngineMetrics), default `kToolbarHeight`) — height reserved for the fixed app bar.
/// - `inset_bottom` (`flag`, default `false`) — clears the bottom system inset around the body (the behavior before 0.8.0).
/// - `cover_bottom_inset` (`flag`, default `null` = Android only) — covers the system bottom inset over the body with the scaffold background. Not applied with a `bottom_navigation_bar` slot or `inset_bottom`.
///
/// Child: `_slots: { app_bar, body, bottom_navigation_bar, bottom_sheet, drawer, end_drawer, floating_action_button }`.
final class ScaffoldWidget {
  const ScaffoldWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    Map<String, Widget> slots,
  ) {
    final appBar = slots['app_bar'];
    final extendBody = PropsResolver.flag(props['extend_body']) ?? false;
    final extendBodyBehindAppBar =
        PropsResolver.flag(props['extend_body_behind_app_bar']) ?? false;
    final insetBottom = PropsResolver.flag(props['inset_bottom']) ?? false;
    final backgroundColor = PropsResolver.color(props['background_color']);
    final body = _body(
      slots['body'],
      extendBody,
      extendBodyBehindAppBar,
      insetBottom,
    );
    // The bottom slot lays itself over the inset, and a bottom SafeArea leaves
    // nothing under it, so the cover applies only when the body reaches it.
    final cover =
        (PropsResolver.flag(props['cover_bottom_inset']) ??
            defaultTargetPlatform == TargetPlatform.android) &&
        slots['bottom_navigation_bar'] == null &&
        !(insetBottom && !extendBody);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar == null ? null : _appBar(context, props, appBar),
      body: body == null || !cover
          ? body
          : _BottomInsetCover(
              color:
                  backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
              child: body,
            ),
      drawer: slots['drawer'],
      endDrawer: slots['end_drawer'],
      bottomSheet: slots['bottom_sheet'],
      floatingActionButton: slots['floating_action_button'],
      floatingActionButtonLocation: PropsResolver.fabLocation(
        props['floating_action_button_location'],
      ),
      bottomNavigationBar: slots['bottom_navigation_bar'],
      resizeToAvoidBottomInset: PropsResolver.flag(
        props['resize_to_avoid_bottom_inset'],
      ),
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  /// Wraps the body slot in a [SafeArea] so screen content clears device
  /// intrusions (status bar, notch, side cut-outs) without every template
  /// opting in with its own `safe_area`.
  ///
  /// The top, left and right edges are enabled. This does not double up the
  /// top: [Scaffold] already strips the body's top padding when an app bar is
  /// present, so it resolves to zero here. The bottom is enabled only with
  /// [insetBottom]; otherwise the body keeps the bottom padding in its
  /// [MediaQuery] for the scroll views and `safe_area`s inside it. A top/bottom
  /// edge the template explicitly extends behind
  /// ([extendBodyBehindAppBar]/[extendBody]) is left un-inset so the opt-out
  /// stays meaningful.
  static Widget? _body(
    Widget? body,
    bool extendBody,
    bool extendBodyBehindAppBar,
    bool insetBottom,
  ) {
    if (body == null) return null;
    return SafeArea(
      top: !extendBodyBehindAppBar,
      bottom: insetBottom && !extendBody,
      child: body,
    );
  }

  /// Wraps the app-bar slot so it clears the status bar and has a real height.
  ///
  /// Engine slots are reactive-observer-wrapped, so a bare
  /// [PreferredSizeWidget] never reaches [Scaffold.appBar]. Instead the scaffold
  /// owns the bar frame: `top + app_bar_height` of height (top = status-bar
  /// inset) and a top [SafeArea], so the content sits below the status bar at a
  /// full toolbar height and — being handed the full width — never overflows.
  static PreferredSizeWidget _appBar(
    BuildContext context,
    Map<String, Object?> props,
    Widget content,
  ) {
    final height =
        PropsResolver.size(context, props['app_bar_height']) ??
        PropsResolver.size(context, kToolbarHeight)!;
    // Scaffold already grows the app-bar by the status-bar inset, so reserve only
    // the (adaptive) toolbar height here; the top SafeArea drops content below the
    // status bar. SizedBox pins the content to that height so the bar never
    // collapses to its tallest slot — e.g. `center_title` sizes its Stack to the
    // title alone, which would otherwise shrink the whole bar to the title height.
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: SafeArea(
        bottom: false,
        child: SizedBox(height: height, child: content),
      ),
    );
  }
}

/// Paints an opaque [color] strip over the bottom of the scaffold body, as tall
/// as the system bottom inset the body actually reaches, so content scrolled
/// under the Android system bar is hidden while scroll ends still stop above
/// the inset. The strip is purely visual and takes no hit tests.
///
/// The height is the smaller of the view's real inset and the body's
/// [MediaQuery] bottom padding. The real inset comes from the [View], because an
/// app shell may add a floating tab bar to the [MediaQuery] padding; the
/// [MediaQuery] bound drops the strip when something above already consumed
/// the inset (a parent `SafeArea`, an outer scaffold's bottom bar, a dialog) or
/// the keyboard is up. The view's keyboard inset is subtracted as well, in case
/// the platform keeps reporting the bar under the keyboard.
///
/// The tree keeps the same shape when the height changes, so the body keeps
/// its state while the keyboard opens and closes. The [Stack] fills the body
/// region and places the body at the top left with the loose constraints the
/// [Scaffold] gives it, so the body lays out as without the strip.
class _BottomInsetCover extends StatelessWidget {
  const _BottomInsetCover({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final view = View.maybeOf(context);
    final real = view == null
        ? 0.0
        : (view.padding.bottom - view.viewInsets.bottom) /
              view.devicePixelRatio;
    final reached = MediaQuery.maybePaddingOf(context)?.bottom ?? 0;
    final height = real.clamp(0.0, reached);

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: height,
            child: IgnorePointer(child: ColoredBox(color: color)),
          ),
        ],
      ),
    );
  }
}
