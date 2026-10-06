import 'package:flutter/widgets.dart';

/// Coordinates route content with Hero discovery, before overlay shuttles build.
final class SharedTransitionController extends ChangeNotifier {
  bool discovered = false;
  bool hasFlight = false;
  bool landed = false;

  bool get waiting => !discovered || (hasFlight && !landed);

  void flightStarted() {
    if (hasFlight) return;
    hasFlight = true;
    landed = false;
  }

  void discoveryFinished() {
    discovered = true;
    notifyListeners();
  }

  void flightLanded() {
    landed = true;
    notifyListeners();
  }
}

class SharedTransitionScope extends InheritedWidget {
  const SharedTransitionScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final SharedTransitionController controller;

  static SharedTransitionController? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<SharedTransitionScope>()
      ?.controller;

  @override
  bool updateShouldNotify(SharedTransitionScope oldWidget) =>
      controller != oldWidget.controller;
}
