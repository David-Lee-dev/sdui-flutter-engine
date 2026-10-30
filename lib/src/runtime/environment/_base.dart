import 'package:flutter/foundation.dart';

/// Defines one lexical layer used to resolve and observe template bindings.
///
/// Lookup methods inspect only this layer; expression evaluation follows [parent].
abstract class Environment {
  const Environment();

  Environment? get parent;

  bool has(String name);

  Object? read(String name);

  Listenable? listen(Set<String> keys);
}
