/// App-owned defaults for screen page transitions.
final class PageTransitionStyle {
  const PageTransitionStyle({
    this.enabled = false,
    this.defaultType = 'platform',
    this.preloadTimeout = const Duration(milliseconds: 300),
    this.respectReducedMotion = true,
  });

  final bool enabled;
  final String defaultType;
  final Duration preloadTimeout;
  final bool respectReducedMotion;
}
