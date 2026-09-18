import 'package:flutter/widgets.dart';

import 'engine_registries.dart';

/// Provides runtime services scoped to one engine mount.
///
/// Mount isolation prevents concurrent screens from affecting each other's
/// overlays, routing, or modal stacks. Drivers depend only on the abstract
/// handles exposed here, while the host remains independent of driver details.
final class EngineHost {
  EngineHost({
    this.registries,
    this.modalTemplates = const {},
    this.overlay,
    this.navigate,
    this.toast,
    this.screenId,
    List<ModalHandle>? modalStack,
  }) : modalStack = modalStack ?? [];

  /// The widget registries available to identifier-based drivers.
  final EngineRegistries? registries;

  /// The screen this mount renders, for telemetry attribution only.
  ///
  /// A modal is a surface of its own but it belongs to the screen that opened
  /// it (TELEMETRY.md §2), and `ModalDriver` has no other route to that fact:
  /// it is reached through a `DriverContext`, which carries command inputs and
  /// mount capabilities — not screen identity. The visit identifier is
  /// deliberately *not* here; it changes per activation while a host is built
  /// once per mount, so it would go stale on a kept-alive tab.
  final String? screenId;

  /// Maps modal identifiers to raw templates for this mount.
  final Map<String, Object?> modalTemplates;

  /// The overlay used by context-free drivers, or `null` when unavailable.
  final OverlayHandle? overlay;

  /// The application-provided navigation callbacks, if available.
  final NavigateHandle? navigate;

  /// The application-provided toast callback, if available.
  final ToastHandle? toast;

  /// Tracks open modals so close operations affect only this mount's top modal.
  ///
  /// Opaque [ModalHandle] entries keep the host independent of modal internals.
  final List<ModalHandle> modalStack;

  /// Creates a host for a modal body with isolated [registries].
  ///
  /// Other services and the modal stack remain shared so nested close operations
  /// reach the opening mount, while anchor and focus identifiers cannot collide.
  EngineHost forkForModalBody(EngineRegistries? registries) => EngineHost(
    registries: registries,
    modalTemplates: modalTemplates,
    overlay: overlay,
    navigate: navigate,
    toast: toast,
    screenId: screenId,
    modalStack:
        modalStack, // Modal bodies must operate on the opening host's stack.
  );
}

/// Manages overlay entries owned by one engine mount.
///
/// Tracking entries locally supports idempotent removal and complete teardown
/// without relying on a global overlay attachment.
final class OverlayHandle {
  OverlayHandle(this._overlay);

  final OverlayState _overlay;
  final Set<OverlayEntry> _entries = {};

  /// Inserts and tracks an overlay entry built by [builder].
  OverlayEntry insert(WidgetBuilder builder) {
    final entry = OverlayEntry(builder: builder);
    _overlay.insert(entry);
    _entries.add(entry);
    return entry;
  }

  /// Removes [entry] if this handle still owns it.
  ///
  /// Removal is idempotent so normal closure and owner teardown may overlap.
  void remove(OverlayEntry entry) {
    if (_entries.remove(entry)) entry.remove();
  }

  /// Removes every remaining entry during mount teardown.
  void dispose() {
    for (final entry in _entries.toList()) {
      entry.remove();
    }
    _entries.clear();
  }
}

/// Defines application-owned navigation callbacks without coupling to a router package.
final class NavigateHandle {
  const NavigateHandle({this.push, this.go, this.pop});

  /// Pushes [location] and completes with its pop result.
  final Future<Object?> Function(String location)? push;

  /// Replaces the current location with [location].
  final void Function(String location)? go;

  /// Pops the top location with an optional result.
  final void Function([Object? result])? pop;
}

/// Exposes application-owned toast presentation to the engine.
///
/// Variants remain strings so the engine does not depend on an application enum.
final class ToastHandle {
  const ToastHandle(this.show);

  final void Function(String message, String variant) show;
}

/// Defines the opaque close contract stored in [EngineHost.modalStack].
abstract interface class ModalHandle {
  /// Requests that this modal close with an optional [result].
  void requestClose(Object? result);
}

/// Exposes an [EngineHost] to the mounted widget subtree.
class EngineHostScope extends InheritedWidget {
  const EngineHostScope({super.key, required this.host, required super.child});

  final EngineHost host;

  /// Returns the nearest [EngineHost], or `null` outside an engine mount.
  static EngineHost? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EngineHostScope>()?.host;

  @override
  bool updateShouldNotify(EngineHostScope oldWidget) => host != oldWidget.host;
}
