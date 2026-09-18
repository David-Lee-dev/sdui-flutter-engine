import '../driver/_base.dart';
import 'engine_log.dart';

/// Adds debug diagnostics around a driver without changing its result.
final class LoggingDriver extends Driver {
  LoggingDriver(this._inner);

  final Driver _inner;

  @override
  String get type => _inner.type;

  @override
  Future<Object?> run(DriverContext ctx) async {
    final sw = Stopwatch()..start();
    EngineLog.driver.start(type, ctx.params);
    try {
      final data = await _inner.run(ctx);
      EngineLog.driver.ok(type, sw.elapsed, data);
      return data;
    } catch (error) {
      EngineLog.driver.fail(type, sw.elapsed, error);
      rethrow;
    }
  }
}
