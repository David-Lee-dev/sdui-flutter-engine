import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../ir/model/page_transition.dart';
import '../runtime/transition/transition_factory.dart';
import '../runtime/util/engine_curve.dart';

Page<void> sduiTransitionPage({
  required LocalKey key,
  required Widget child,
  required PageTransitionSpec spec,
}) => _TransitionPage(key: key, child: child, spec: spec);

final class _TransitionPage extends Page<void> {
  const _TransitionPage({super.key, required this.child, required this.spec});

  final Widget child;
  final PageTransitionSpec spec;

  @override
  Route<void> createRoute(BuildContext context) => _TransitionRoute(this);
}

final class _TransitionRoute extends PageRoute<void> {
  _TransitionRoute(_TransitionPage page) : super(settings: page);

  _TransitionRoute? _nextRoute;

  // Limit route-pair effects to engine neighbours. In particular, do not
  // receive a platform delegated transition or supply one to a legacy route.
  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is _TransitionRoute;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      previousRoute is _TransitionRoute;

  @override
  void didChangeNext(Route<dynamic>? nextRoute) {
    _nextRoute = nextRoute is _TransitionRoute ? nextRoute : null;
    super.didChangeNext(nextRoute);
  }

  @override
  void didPopNext(Route<dynamic> nextRoute) {
    _nextRoute = nextRoute is _TransitionRoute ? nextRoute : null;
    super.didPopNext(nextRoute);
  }

  _TransitionPage get page => settings as _TransitionPage;

  @override
  Duration get transitionDuration =>
      PageTransitionFactory.resolve(page.spec.type).duration(page.spec);

  @override
  Duration get reverseTransitionDuration =>
      PageTransitionFactory.resolve(page.spec.type).reverseDuration(page.spec);

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => page.child;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final effect = PageTransitionFactory.resolve(page.spec.type);
    final next = _nextRoute;
    final outgoing = next == null
        ? null
        : PageTransitionFactory.resolve(next.page.spec.type).buildOutgoing(
            context,
            secondaryAnimation.drive(
              CurveTween(curve: EngineCurve.resolve(next.page.spec.curve)),
            ),
            child,
            next.page.spec,
          );
    // One curve maps the route value in both directions, so pop and edge
    // scrubbing retrace push without a direction-dependent visual jump.
    final transitioned = effect.build(
      context,
      animation.drive(CurveTween(curve: EngineCurve.resolve(page.spec.curve))),
      outgoing == null ? secondaryAnimation : const AlwaysStoppedAnimation(0),
      outgoing ?? child,
      page.spec,
    );
    if (Theme.of(context).platform != TargetPlatform.iOS) return transitioned;
    return _BackSwipe(
      route: this,
      controller: controller!,
      child: transitioned,
    );
  }
}

/// Cupertino's edge gesture semantics with the route's own effect. The effect
/// remains driven by the same controller for push, drag, cancel and pop.
final class _BackSwipe extends StatefulWidget {
  const _BackSwipe({
    required this.route,
    required this.controller,
    required this.child,
  });

  final PageRoute<void> route;
  final AnimationController controller;
  final Widget child;

  @override
  State<_BackSwipe> createState() => _BackSwipeState();
}

final class _BackSwipeState extends State<_BackSwipe> {
  late final HorizontalDragGestureRecognizer _recognizer;
  NavigatorState? _navigator;
  AnimationStatusListener? _settled;

  double _logical(double value) =>
      Directionality.of(context) == TextDirection.rtl ? -value : value;

  @override
  void initState() {
    super.initState();
    _recognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = (_) {
        _navigator = widget.route.navigator!;
        _navigator!.didStartUserGesture();
      }
      ..onUpdate = (details) {
        widget.controller.value -= _logical(
          details.primaryDelta! / context.size!.width,
        );
      }
      ..onEnd = (details) {
        _end(
          _logical(details.velocity.pixelsPerSecond.dx / context.size!.width),
        );
      }
      ..onCancel = () => _end(0);
  }

  void _stop() {
    final settled = _settled;
    if (settled != null) widget.controller.removeStatusListener(settled);
    _settled = null;
    final navigator = _navigator;
    _navigator = null;
    if (navigator?.mounted ?? false) navigator!.didStopUserGesture();
  }

  void _end(double velocity) {
    if (_navigator == null) return;
    final route = widget.route;
    final forward = !route.isCurrent
        ? route.isActive
        : velocity.abs() >= 1
        ? velocity <= 0
        : widget.controller.value > 0.5;
    if (forward) {
      widget.controller.animateTo(
        1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    } else {
      if (route.isCurrent) _navigator!.pop();
      if (widget.controller.isAnimating) {
        widget.controller.animateBack(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.fastEaseInToSlowEaseOut,
        );
      }
    }
    if (widget.controller.isAnimating) {
      _settled = (_) => _stop();
      widget.controller.addStatusListener(_settled!);
    } else {
      _stop();
    }
  }

  @override
  void dispose() {
    _recognizer.dispose();
    final navigator = _navigator;
    final settled = _settled;
    if (settled != null) widget.controller.removeStatusListener(settled);
    _navigator = null;
    if (navigator != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigator.mounted) navigator.didStopUserGesture();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final inset = Directionality.of(context) == TextDirection.ltr
        ? padding.left
        : padding.right;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          width: math.max(20, inset),
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) {
              if (widget.route.isCurrent &&
                  widget.route.popGestureEnabled &&
                  widget.route.secondaryAnimation!.isDismissed &&
                  !(widget.route.navigator?.userGestureInProgress ?? true)) {
                _recognizer.addPointer(event);
              }
            },
          ),
        ),
      ],
    );
  }
}
