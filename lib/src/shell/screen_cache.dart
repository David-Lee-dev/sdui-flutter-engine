import 'package:flutter/widgets.dart';

import '../compile/page_transition_decoder.dart';
import '../contract/error_observer.dart';
import '../contract/screen_loader.dart';
import '../engine.dart';
import '../ir/model/page_transition.dart';
import '../runtime/engine_errors.dart';

/// One cached screen: the body without its root `_transition`, and that
/// declaration decoded once per load (`null` when absent or invalid).
final class CachedScreen {
  const CachedScreen({required this.screen, required this.transition});

  final LoadedScreen screen;
  final PageTransitionSpec? transition;
}

/// SDK-owned in-memory screens listed at `Sdui.initialize(preloadScreens:)`.
final class ScreenCache {
  final _entries = <String, CachedScreen>{};
  final _refreshing = <String, Future<void>>{};

  /// Loads every distinct id in parallel. Failures are reported as
  /// [SduiErrorScope.screenLoad] and leave that id uncached.
  Future<void> warm(List<String> ids, ScreenLoader loader) async {
    await Future.wait([for (final id in ids.toSet()) _fetch(id, loader)]);
  }

  CachedScreen? peek(String id) => _entries[id];

  /// Reloads a cached [id] for the next open, coalescing concurrent calls.
  /// A failure is reported and keeps the previous entry; pages already
  /// showing the old entry are never touched.
  Future<void> refresh(String id, ScreenLoader loader) {
    if (!_entries.containsKey(id)) return Future.value();
    return _refreshing[id] ??= _fetch(id, loader).whenComplete(() {
      _refreshing.remove(id);
    });
  }

  Future<void> _fetch(String id, ScreenLoader loader) async {
    try {
      _entries[id] = _decode(await loader.load(id), id);
    } catch (error, stack) {
      EngineErrors.report(
        SduiError(
          scope: SduiErrorScope.screenLoad,
          error: error,
          stack: stack,
          screenId: id,
        ),
      );
    }
  }

  /// Validates the root `_transition` once, reporting an invalid declaration
  /// as [SduiErrorScope.templateCompile], and strips it from the body.
  CachedScreen _decode(LoadedScreen screen, String id) {
    if (!screen.template.containsKey('_transition')) {
      return CachedScreen(screen: screen, transition: null);
    }
    PageTransitionSpec? transition;
    try {
      transition = PageTransitionDecoder.decode(
        screen.template['_transition'],
        catalog: Engine.catalog ?? Engine.snapshotCatalog(),
      );
    } catch (error, stack) {
      EngineErrors.report(
        SduiError(
          scope: SduiErrorScope.templateCompile,
          error: error,
          stack: stack,
          screenId: id,
        ),
      );
    }
    return CachedScreen(
      screen: (
        template: Map<String, Object?>.of(screen.template)
          ..remove('_transition'),
        modals: screen.modals,
      ),
      transition: transition,
    );
  }
}

/// The cache entry an engine page captured when its decision was made,
/// for the [SduiScreenPage] mounted below it. A `null` [screen] is an
/// explicit miss: the page loads asynchronously.
final class ScreenSnapshot extends InheritedWidget {
  const ScreenSnapshot({
    super.key,
    required this.screenId,
    required this.screen,
    required super.child,
  });

  final String screenId;
  final CachedScreen? screen;

  @override
  bool updateShouldNotify(ScreenSnapshot oldWidget) => false;
}
