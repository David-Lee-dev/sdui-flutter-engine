import 'dart:async';

import '../log/engine_log.dart';
import '_base.dart';
import 'driver_error.dart';

/// Waits for a delay or live condition within the owning scope's lifetime.
final class WaitDriver extends Driver {
  const WaitDriver();

  @override
  String get type => 'wait';

  @override
  Set<String> get watchedParams => const {'until'};

  @override
  Future<Object?> run(DriverContext ctx) {
    final done = Completer<Object?>();
    Timer? timer;
    void Function() removeDispose = () {};
    void Function() removeWatch = () {};

    void complete([Object? error]) {
      if (done.isCompleted) return;
      timer?.cancel();
      removeWatch();
      removeDispose();
      if (error == null) {
        done.complete(null);
      } else {
        done.completeError(error);
      }
    }

    removeDispose = ctx.onOwnerDispose(complete);
    if (done.isCompleted) return done.future;

    if (ctx.params.containsKey('until')) {
      removeWatch = ctx.watchTruthy('until', complete);
      if (done.isCompleted) {
        removeWatch();
        return done.future;
      }
      final ms = _milliseconds(ctx.params['timeout'], minimum: 1);
      if (ms == 0) {
        complete(const DriverError('WAIT_TIMEOUT'));
      } else {
        timer = Timer(Duration(milliseconds: ms), () {
          complete(const DriverError('WAIT_TIMEOUT'));
        });
      }
      return done.future;
    }

    final ms = _milliseconds(ctx.params['duration']);
    if (ms == 0) {
      complete();
    } else {
      timer = Timer(Duration(milliseconds: ms), complete);
    }
    return done.future;
  }

  int _milliseconds(Object? value, {int minimum = 0}) {
    final number = value is num
        ? value
        : value is String
        ? num.tryParse(value)
        : null;
    if (number == null ||
        !number.isFinite ||
        number < minimum ||
        number > 1000000) {
      EngineLog.driver.skip(
        type,
        'invalid ${minimum == 0 ? 'duration' : 'timeout'}; using 0ms',
      );
      return 0;
    }
    return number.round();
  }
}
