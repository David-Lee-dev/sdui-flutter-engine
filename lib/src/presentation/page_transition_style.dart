/// App-owned defaults for screen page transitions.
final class PageTransitionStyle {
  const PageTransitionStyle({
    this.enabled = false,
    this.defaultType = 'platform',
    this.respectReducedMotion = true,
  });

  final bool enabled;
  final String defaultType;
  final bool respectReducedMotion;
}
