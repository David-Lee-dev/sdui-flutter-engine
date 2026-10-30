import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../environment/_base.dart';
import '../../environment/map_environment.dart';
import 'scope.dart';

/// Exposes whether a node's `tap` is held down as the bool variable [name]
/// (`_on: { tap: { do, pressed_as: name } }`).
///
/// It sits above the node, so the node's own props read the variable too;
/// the node's interaction layer reports presses through [of].
class PressScope extends StatefulWidget {
  const PressScope({super.key, required this.name, required this.child});

  final String name;
  final Widget child;

  /// Sets the press state of the nearest [PressScope] above [context]; a call
  /// after that scope is gone does nothing.
  static ValueChanged<bool>? of(BuildContext context) =>
      context.findAncestorStateOfType<_PressScopeState>()?._set;

  @override
  State<PressScope> createState() => _PressScopeState();
}

class _PressScopeState extends State<PressScope> {
  final ValueNotifier<bool> _down = ValueNotifier(false);
  Environment _parent = MapEnvironment.empty;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parent = Scope.envOf(context) ?? MapEnvironment.empty;
  }

  void _set(bool down) {
    if (mounted) _down.value = down;
  }

  @override
  void dispose() {
    _down.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scope.provideEnv(
    env: _PressEnvironment(parent: _parent, name: widget.name, down: _down),
    child: widget.child,
  );
}

class _PressEnvironment extends Environment {
  _PressEnvironment({
    required this.parent,
    required this.name,
    required this.down,
  });

  @override
  final Environment? parent;
  final String name;
  final ValueListenable<bool> down;

  @override
  bool has(String n) => n == name;

  @override
  Object? read(String n) => n == name ? down.value : null;

  @override
  Listenable? listen(Set<String> keys) {
    if (!keys.contains(name)) return parent?.listen(keys);
    final rest = parent?.listen(keys.difference({name}));
    return rest == null ? down : Listenable.merge([down, rest]);
  }
}
