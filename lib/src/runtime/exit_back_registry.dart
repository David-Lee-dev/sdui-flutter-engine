/// The scopes that currently take a system back that would close the app.
///
/// Each candidate is a scope's fire callback, kept here while the scope is
/// visible, not exiting and declares an `exit_back` hook. Process-wide: there
/// is one platform back.
abstract final class ExitBackRegistry {
  /// Insertion-ordered, as set literals are.
  static final _candidates = <void Function()>{};

  /// Adds [fire] as a candidate; adding it again keeps its place.
  static void add(void Function() fire) => _candidates.add(fire);

  /// Removes [fire]; a no-op when it is not a candidate.
  static void remove(void Function() fire) => _candidates.remove(fire);

  /// Fires every candidate and returns whether there was one.
  ///
  /// A callback may dispose or obscure another candidate; a candidate removed
  /// that way during this dispatch is skipped.
  static bool fire() {
    if (_candidates.isEmpty) return false;
    for (final fire in _candidates.toList()) {
      if (_candidates.contains(fire)) fire();
    }
    return true;
  }
}
