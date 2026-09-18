/// Holds the typed runtime configuration compiled from a `_scope` map.
///
/// Raw template data does not cross the compile/runtime boundary. Scope schema
/// knowledge remains in [ScopeConfig.fromRaw], allowing the building layer to
/// pass this object through without parsing it.
final class ScopeConfig {
  const ScopeConfig({this.state = const {}});

  /// The initial state snapshot extracted from `_state` during compilation.
  final Map<String, Object?> state;

  /// Creates typed scope configuration from a raw `_scope` map.
  ///
  /// State values, including nested maps and lists, are preserved as literals;
  /// only keys are normalized to strings. Actions and lifecycle hooks are
  /// compiled separately.
  factory ScopeConfig.fromRaw(Map<String, Object?> raw) {
    final rawState = raw['_state'];
    return ScopeConfig(
      state: rawState is! Map
          ? const {}
          : {
              for (final entry in rawState.entries)
                entry.key.toString(): entry.value,
            },
    );
  }
}
