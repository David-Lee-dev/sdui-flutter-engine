/// How a structural directive (cond, switch, `_if`, eager loop, skeleton
/// swap) shows the content it inserts and removes, from `_presence`.
///
/// Enabled by default: inserted content grows into its space and removed
/// content plays its `on: exit` motions and collapses before it leaves.
/// [durationMs] and [curve] override the app-wide presence style for every
/// phase when set; a malformed curve falls back to that style.
final class PresenceConfig {
  const PresenceConfig({
    this.enabled = true,
    this.space = true,
    this.sequential = false,
    this.durationMs,
    this.curve,
  });

  /// `_presence: false` — structural changes are instant, as before 0.16.
  static const off = PresenceConfig(enabled: false);

  final bool enabled;

  /// Whether the slot animates the size of what it inserts and removes.
  final bool space;

  /// `order: sequential` — exit motions finish before the slot collapses and
  /// the slot expands before entrance motions start; otherwise both run
  /// together.
  final bool sequential;

  /// Phase length in milliseconds; `null` takes the presence style.
  final int? durationMs;

  /// A curve name or `[x1, y1, x2, y2]` list; `null` takes the style.
  final Object? curve;
}
