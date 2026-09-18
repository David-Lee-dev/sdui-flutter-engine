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
/// The `body` slot is always wrapped in a [SafeArea] (see [_body]) so screen
/// content clears device intrusions without each template adding its own
/// `safe_area`. Set `extend_body`/`extend_body_behind_app_bar` to opt an edge
/// out.
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
    return Scaffold(
      backgroundColor: PropsResolver.color(props['background_color']),
      appBar: appBar == null ? null : _appBar(context, props, appBar),
      body: _body(slots['body'], extendBody, extendBodyBehindAppBar),
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
  /// intrusions (status bar, notch, home indicator) without every template
  /// opting in with its own `safe_area`.
  ///
  /// All edges are enabled by default. This does not double up existing
  /// insets: [Scaffold] already strips the body's top padding when an app bar
  /// is present and its bottom padding when a bottom navigation bar is present,
  /// so those edges resolve to zero here and only the genuinely exposed edges
  /// are inset. A top/bottom edge the template explicitly extends behind
  /// ([extendBodyBehindAppBar]/[extendBody]) is left un-inset so the opt-out
  /// stays meaningful.
  static Widget? _body(
    Widget? body,
    bool extendBody,
    bool extendBodyBehindAppBar,
  ) {
    if (body == null) return null;
    return SafeArea(
      top: !extendBodyBehindAppBar,
      bottom: !extendBody,
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
