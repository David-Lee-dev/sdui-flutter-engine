/// Immutable transition metadata declared at a screen template's root.
final class PageTransitionSpec {
  PageTransitionSpec({
    required this.type,
    this.durationMs,
    this.reverseDurationMs,
    this.curve,
    this.contentTiming = PageTransitionContentTiming.duringShared,
    Map<String, Object?> params = const {},
  }) : params = Map.unmodifiable({
         for (final entry in params.entries) entry.key: _freeze(entry.value),
       });

  final String type;
  final int? durationMs;
  final int? reverseDurationMs;
  final String? curve;
  final PageTransitionContentTiming contentTiming;
  final Map<String, Object?> params;

  static Object? _freeze(Object? value) => switch (value) {
    Map<Object?, Object?> value => Map.unmodifiable({
      for (final entry in value.entries) entry.key: _freeze(entry.value),
    }),
    List<Object?> value => List.unmodifiable([
      for (final item in value) _freeze(item),
    ]),
    _ => value,
  };
}

/// When a destination's content appears relative to shared visual elements.
enum PageTransitionContentTiming { duringShared, afterShared }
