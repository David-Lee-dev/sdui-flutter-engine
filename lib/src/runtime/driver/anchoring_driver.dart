import 'package:flutter/widgets.dart';

import '../log/engine_log.dart';
import '../util/engine_curve.dart';
import '../util/props_resolver.dart';
import '_base.dart';

/// Runs commands against `anchor_scope`s — currently `method: move` only (see
/// `_docs/engine-v3/ANCHOR-SCOPE.md`; `spotlight` has no consumer yet).
///
/// `move` flies `count` copies of an `anchor_scope` item from one anchor to
/// another, staggered in launch time, and resolves when the **last** item
/// lands — so a template's `_then` runs after arrival. Every failure this
/// driver can hit locally (missing scope, missing anchor, unknown item) is
/// decoration going wrong, not a command failure: it no-ops with a debug log
/// and resolves immediately rather than throwing, so a bad template can never
/// break the reward flow it's decorating.
class AnchoringDriver extends Driver {
  const AnchoringDriver();

  /// Hard cap on `count` so a malformed template cannot spawn unbounded
  /// flights.
  static const _maxCount = 50;

  @override
  String get type => 'anchoring';

  @override
  Future<Object?> run(DriverContext ctx) async {
    switch (ctx.params['method']) {
      case 'move':
        return _move(ctx);
      default:
        throw ArgumentError.value(
          ctx.params['method'],
          'method',
          'unknown anchoring method',
        );
    }
  }

  Future<Object?> _move(DriverContext ctx) async {
    final params = ctx.params;

    final controller = ctx.registries?.anchorScopes.resolve(
      PropsResolver.text(params['scope']),
    );
    if (controller == null) {
      EngineLog.driver.skip(
        'anchoring',
        'no anchor_scope "${params['scope']}"',
      );
      return null;
    }

    final item = PropsResolver.text(params['item']);
    if (item == null || item.isEmpty || !controller.hasItem(item)) {
      EngineLog.driver.skip('anchoring', 'unknown item "${params['item']}"');
      return null;
    }

    final fromId = PropsResolver.text(params['from']);
    final toId = PropsResolver.text(params['to']);
    if (fromId == null || fromId.isEmpty || toId == null || toId.isEmpty) {
      EngineLog.driver.skip('anchoring', 'move requires "from" and "to"');
      return null;
    }
    // Coordinates are resolved once, here, for the whole launch — not
    // per staggered item and not per frame (§5/§7 of the design doc: layout
    // changes mid-flight are a known, accepted limitation).
    final fromRect = controller.rectFor(fromId);
    final toRect = controller.rectFor(toId);
    if (fromRect == null || toRect == null) {
      EngineLog.driver.skip(
        'anchoring',
        'anchor not mounted (from="$fromId" to="$toId")',
      );
      return null;
    }

    final count = (PropsResolver.integer(params['count']) ?? 1).clamp(
      1,
      _maxCount,
    );
    final stagger = PropsResolver.duration(params['stagger']) ?? Duration.zero;
    final duration =
        PropsResolver.duration(params['duration']) ??
        const Duration(milliseconds: 300);
    final curve = EngineCurve.resolve(PropsResolver.text(params['curve']));
    final from = fromRect.center;
    final to = _alignedPoint(toRect, PropsResolver.text(params['to_align']));

    Future<void>? last;
    for (var i = 0; i < count; i++) {
      if (ctx.isCancelled) break;
      if (i > 0 && stagger > Duration.zero) {
        await Future<void>.delayed(stagger);
        if (ctx.isCancelled) break;
      }
      last = controller.launch(
        item: item,
        from: from,
        to: to,
        duration: duration,
        curve: curve,
      );
    }
    if (last != null) await last;
    return null;
  }

  /// Resolves the named point of [rect] a flight should land on, defaulting
  /// to its center.
  static Offset _alignedPoint(Rect rect, String? align) => switch (align) {
    'top_left' => rect.topLeft,
    'top_center' => rect.topCenter,
    'top_right' => rect.topRight,
    'center_left' => rect.centerLeft,
    'center_right' => rect.centerRight,
    'bottom_left' => rect.bottomLeft,
    'bottom_center' => rect.bottomCenter,
    'bottom_right' => rect.bottomRight,
    _ => rect.center,
  };
}
