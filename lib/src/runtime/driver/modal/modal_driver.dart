import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../engine_host.dart';
import '../_base.dart';
import '../driver_error.dart';
import 'modal_frame.dart';

/// Signals that a modal ended without an explicit return value.
class ModalDismissed implements Exception {
  const ModalDismissed();
}

/// Opens and closes engine-rendered modal templates on the host overlay.
///
/// Dialogs fade in. Bottom sheets slide their full height from below the screen
/// without fading their content, while the backdrop fades. An open command's
/// `motion` preset replaces the native sheet slide with the preset plus fade.
class ModalDriver extends Driver {
  const ModalDriver();

  @override
  String get type => 'modal';

  @override
  Future<Object?> run(DriverContext ctx) async {
    switch (ctx.params['method'] ?? 'open') {
      case 'open':
        return _open(ctx);
      case 'close':
        _close(ctx);
        return null;
      default:
        throw ArgumentError.value(
          ctx.params['method'],
          'method',
          'unknown modal method',
        );
    }
  }

  Future<Object?> _open(DriverContext ctx) async {
    final params = ctx.params;
    final id = params['modal'];
    if (id is! String || id.isEmpty) {
      throw ArgumentError.value(
        params['modal'],
        'modal',
        'modal open requires a non-empty string "modal" id',
      );
    }
    final template = ctx.modalTemplates[id];
    if (template is! Map) {
      throw DriverError('MODAL_NOT_FOUND', 'no modal template for id "$id"');
    }
    final host = ctx.host;
    final overlay = host?.overlay;
    if (host == null || overlay == null) throw const DriverError('NO_OVERLAY');

    final open = _OpenModal(overlay: overlay, stack: host.modalStack);
    open.entry = overlay.insert(
      (_) => ModalFrame(
        content: template,
        data: _map(params['params']),
        host: host,
        // The modal's own surface identity (TELEMETRY.md §2): the id names
        // which modal it is, the host's screen names the visit it belongs to.
        modalId: id,
        screenId: host.screenId,
        variant: _variant(params['variant']),
        align: _str(params['align']),
        motion: _str(params['motion']),
        dismissible: params['dismissible'] != false,
        controller: open.controller,
        onClosed: (result, dismissed) => _finish(open, result, dismissed),
      ),
    );
    host.modalStack.add(open);
    open.deregister = ctx.onOwnerDispose(() => _abandon(open));
    try {
      return await open.completer.future;
    } on ModalDismissed {
      throw const DriverError(DriverError.dismissed);
    }
  }

  void _finish(_OpenModal open, Object? result, bool dismissed) {
    open.deregister?.call();
    final entry = open.entry;
    if (entry != null) open.overlay.remove(entry);
    open.stack.remove(open);
    if (open.completer.isCompleted) return;
    if (dismissed) {
      open.completer.completeError(const ModalDismissed());
    } else {
      open.completer.complete(result);
    }
  }

  void _abandon(_OpenModal open) {
    if (open.completer.isCompleted) return;
    open.deregister?.call();
    final entry = open.entry;
    if (entry != null) open.overlay.remove(entry);
    open.stack.remove(open);
    open.completer.complete(null);
  }

  void _close(DriverContext ctx) {
    final stack = ctx.host?.modalStack;
    if (stack == null || stack.isEmpty) return;
    stack.last.requestClose(ctx.params['return']);
  }

  static ModalVariant _variant(Object? value) =>
      value == 'bottom_sheet' ? ModalVariant.bottomSheet : ModalVariant.dialog;

  static String? _str(Object? value) => value is String ? value : null;

  static Map<String, Object?>? _map(Object? value) =>
      value is Map ? Map<String, Object?>.from(value) : null;
}

class _OpenModal implements ModalHandle {
  _OpenModal({required this.overlay, required this.stack});

  final OverlayHandle overlay;
  final List<ModalHandle> stack;

  final ModalCloseController controller = ModalCloseController();
  final Completer<Object?> completer = Completer<Object?>();
  OverlayEntry? entry;

  void Function()? deregister;

  @override
  void requestClose(Object? result) => controller.requestClose(result);
}
