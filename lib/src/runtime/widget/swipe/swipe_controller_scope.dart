import 'package:flutter/widgets.dart';

import 'swipe_controller.dart';

/// Provides a [SwipeController] to the descendants of a `swipe_layout`.
///
/// A `swipe_pane` or `swipe_indicator` resolves its controller with [of]. When
/// [id] is given the lookup targets the matching ancestor, so nested swipe
/// layouts can be addressed unambiguously; otherwise the nearest one wins.
class SwipeControllerScope extends InheritedWidget {
  const SwipeControllerScope({
    super.key,
    required this.controller,
    this.id,
    required super.child,
  });

  /// The shared controller exposed to descendants.
  final SwipeController controller;

  /// Optional name distinguishing nested swipe layouts.
  final String? id;

  /// Resolves the controller a descendant should bind to.
  ///
  /// With no [id], returns the nearest scope. With an [id], walks ancestors for
  /// the scope whose [SwipeControllerScope.id] matches, establishing a
  /// dependency so the descendant rebuilds if that controller is replaced.
  static SwipeController? of(BuildContext context, [String? id]) {
    if (id == null) {
      return context
          .dependOnInheritedWidgetOfExactType<SwipeControllerScope>()
          ?.controller;
    }
    SwipeController? found;
    context.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is SwipeControllerScope && widget.id == id) {
        context.dependOnInheritedElement(element as InheritedElement);
        found = widget.controller;
        return false;
      }
      return true;
    });
    return found;
  }

  @override
  bool updateShouldNotify(SwipeControllerScope oldWidget) =>
      !identical(controller, oldWidget.controller) || id != oldWidget.id;
}
