import 'package:flutter/widgets.dart';

import '../../telemetry/telemetry.dart';
import 'scope.dart';
import 'scope_binding.dart';

/// Rebuilds a bound widget when its scoped value changes.
class BoundBuilder extends StatefulWidget {
  const BoundBuilder({
    super.key,
    required this.bind,
    required this.fieldId,
    this.validation,
    this.on = const {},
    required this.builder,
  });

  final String? bind;

  final String fieldId;

  final String? validation;

  final Map<String, String> on;

  final Widget Function(
    BuildContext context,
    Object? value,
    ValueChanged<Object?>? onChanged,
    ValueChanged<Object?>? onSubmit,
  )
  builder;

  @override
  State<BoundBuilder> createState() => _BoundBuilderState();
}

class _BoundBuilderState extends State<BoundBuilder> {
  Listenable? _listenable;
  int _changedCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebind();
  }

  @override
  void didUpdateWidget(BoundBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bind != widget.bind) _rebind();
  }

  void _rebind() {
    final next = widget.bind == null
        ? null
        : ScopeBinding.listenable(context, widget.bind!);
    if (identical(next, _listenable)) return;
    _listenable?.removeListener(_onChange);
    _listenable = next;
    _listenable?.addListener(_onChange);
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _listenable?.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sink = Scope.actionHost(context);
    final bind = widget.bind;
    final changeAction = widget.on['change'];
    final submitAction = widget.on['submit'];
    final value = bind == null ? null : ScopeBinding.read(context, bind);
    ValueChanged<Object?>? onChanged;
    if (bind != null || changeAction != null) {
      onChanged = (Object? v) {
        _changedCount++;
        _record(submitted: false);
        if (bind != null) ScopeBinding.write(context, bind, v);
        if (changeAction != null) sink?.handle(changeAction, event: v);
      };
    }
    final ValueChanged<Object?>? onSubmit = submitAction == null
        ? null
        : (Object? v) {
            _record(submitted: true);
            sink?.handle(submitAction, event: v);
          };
    return widget.builder(context, value, onChanged, onSubmit);
  }

  void _record({required bool submitted}) {
    final scope = TelemetryScope.maybeOf(context);
    Telemetry.record(
      'input_trail',
      screenId: scope?.screenId,
      screenViewId: scope?.screenViewId,
      properties: InputTrail.properties(
        fieldId: widget.fieldId,
        changedCount: _changedCount,
        submitted: submitted,
        validation: widget.validation,
      ),
    );
  }
}

/// Builds value-free form telemetry at the input boundary.
abstract final class InputTrail {
  /// Builds a form observation that cannot retain an input payload.
  static Map<String, Object?> properties({
    required String fieldId,
    required int changedCount,
    required bool submitted,
    String? validation,
  }) => {
    'field_id': fieldId,
    'changed_count': changedCount,
    'submitted': submitted,
    'validation': validation ?? 'unknown',
  };
}
