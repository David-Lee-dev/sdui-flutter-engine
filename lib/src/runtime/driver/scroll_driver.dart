import 'package:flutter/widgets.dart';

import '../engine_registries.dart';
import '_base.dart';

/// Reveals a registered anchor without coupling templates to a scroll controller.
class ScrollDriver extends Driver {
  const ScrollDriver({AnchorRegistry? anchors}) : _anchors = anchors;

  final AnchorRegistry? _anchors;

  @override
  String get type => 'scroll';

  @override
  Future<Object?> run(DriverContext ctx) async {
    final anchor = ctx.params['anchor'];
    if (anchor is! String || anchor.isEmpty) {
      throw ArgumentError.value(
        ctx.params['anchor'],
        'anchor',
        'scroll requires a non-empty "anchor"',
      );
    }
    final registry = _anchors ?? ctx.registries?.anchors;
    final target = registry?.keyFor(anchor)?.currentContext;
    // Missing and not-yet-mounted anchors are benign in dynamic templates.
    if (target == null) return null;

    await Scrollable.ensureVisible(
      target,
      alignment: _double(ctx.params['alignment']) ?? 0.5,
      duration: Duration(milliseconds: _int(ctx.params['duration']) ?? 300),
      curve: Curves.easeInOut,
    );
    return null;
  }

  static double? _double(Object? value) =>
      value is num ? value.toDouble() : null;

  static int? _int(Object? value) => value is num ? value.toInt() : null;
}
