import '_base.dart';

/// Shows a host-provided toast with a normalized presentation variant.
class ToastDriver extends Driver {
  const ToastDriver();

  @override
  String get type => 'toast';

  @override
  Future<Object?> run(DriverContext ctx) async {
    final message = ctx.params['message'];
    ctx.host?.toast?.show(
      message is String ? message : '',
      _variant(ctx.params['variant']),
    );
    return null;
  }

  static String _variant(Object? value) => switch (value) {
    'success' => 'success',
    'warn' => 'warn',
    'error' => 'error',
    _ => 'info',
  };
}
