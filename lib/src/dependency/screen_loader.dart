/// A composed template split into its screen body and modal templates.
///
/// `template` is the screen's root node tree; `modals` is the content of the
/// template's top-level `_modals` key (empty when absent) — the loader splits
/// it out so the engine receives the two maps separately.
typedef LoadedScreen = ({
  Map<String, Object?> template,
  Map<String, Object?> modals,
});

/// Fetches composed SDUI templates by screen id.
///
/// The engine does not know where templates come from — this contract is the
/// app's point of freedom over transport, caching, and refresh policy.
/// Anything that returns a [LoadedScreen] is valid: plain HTTP, etag or
/// content-hash revalidation, disk caches, bundled fallbacks, or no network
/// at all.
///
/// A faithful implementation must:
///
/// - send the app version (`x-app-version` on the default protocol) so the
///   server picks the right template version threshold — without it, servers
///   fall back to the oldest declared one;
/// - split the template's top-level `_modals` key into [LoadedScreen.modals].
///
/// There is NO default implementation — where templates come from is the
/// app's contract with its server, so `Sdui.initialize` requires one.
/// Caching is deliberately not part of the contract either: implementations
/// add whatever strategy fits (the starter kit ships `EtagScreenLoader`,
/// etag/304 revalidation over plain HTTP, as a reference).
abstract class ScreenLoader {
  Future<LoadedScreen> load(String screenId);
}
