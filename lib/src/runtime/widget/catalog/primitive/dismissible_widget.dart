import 'package:flutter/widgets.dart';

import '../../contract/action_sink.dart';
import '../../../util/props_resolver.dart';

/// `dismissible` — Builds a [Dismissible] that dispatches the configured dismissal action.
///
/// A missing key uses a stable fallback, and dismissal remains functional when
/// no dispatcher is available.
///
/// ```yaml
/// _type: dismissible
/// on_dismissed: example
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `on_dismissed` (`text`, default `null`) — action dispatched after dismissal.
/// - `key` (`text`, default `'_dismissible'`) — stable identity used by the dismissible widget.
/// - `direction` (`dismissDirection`, default `DismissDirection.horizontal`) — selects the layout or dismissal axis. Values: horizontal | vertical | end_to_start | start_to_end | up | down | none.
///
/// Child: `_child`.
final class DismissibleWidget {
  const DismissibleWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
    ActionSink? dispatch,
  ) {
    final action = PropsResolver.text(props['on_dismissed']);
    final keyValue = PropsResolver.text(props['key']) ?? '_dismissible';
    return Dismissible(
      key: ValueKey(keyValue),
      direction:
          PropsResolver.dismissDirection(props['direction']) ??
          DismissDirection.horizontal,
      onDismissed: (_) {
        if (action != null && dispatch != null) dispatch.handle(action);
      },
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}
