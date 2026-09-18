import '_base.dart';

/// Commits resolved command parameters to the current scope state.
class SetDriver extends Driver {
  const SetDriver();

  @override
  String get type => 'set';

  @override
  Future<Object?> run(DriverContext ctx) async {
    ctx.state.commit(ctx.params);
    return null;
  }
}
