import 'dart:async';

import 'package:flutter/foundation.dart';

import '../driver/driver_error.dart';

/// Severity levels emitted by [EngineLog].
enum LogLevel { trace, debug, info, warn, error }

/// Debug-only, structured diagnostics for the v3 engine.
final class EngineLog {
  const EngineLog._();

  static LogLevel _minLevel = LogLevel.debug;
  static bool _colors = true;
  static Set<String>? _tags;
  // `null` = the ambient [debugPrint], read at call time — tests (and
  // Flutter itself) swap that global, so binding it once here would freeze a
  // stale reference.
  static void Function(String line)? _output;

  /// Zone flag marking a scope whose engine logs are suppressed (see
  /// [runSilently]).
  static const Object _silentZoneKey = #engineLogSilent;

  /// Action execution diagnostics.
  static const action = _ActionLog();

  /// Driver execution diagnostics.
  static const driver = _DriverLog();

  /// Scope-state diagnostics.
  static const state = _StateLog();

  /// Screen compilation and mounting diagnostics.
  static const screen = _ScreenLog();

  /// Scope lifecycle diagnostics.
  static const scope = _ScopeLog();

  /// Widget contract diagnostics.
  static const widget = _WidgetLog();

  /// Runs [body] with engine logging suppressed for the whole (possibly async)
  /// duration of its execution, returning its result.
  ///
  /// The suppression rides a [Zone] value, so it follows the body across
  /// `await`s and scheduled continuations without threading a flag through every
  /// layer. Used for high-frequency, low-signal work — chiefly interval-driven
  /// lifecycle ticks, whose per-tick action/state logs would otherwise flood the
  /// debug console.
  static T runSilently<T>(T Function() body) =>
      runZoned(body, zoneValues: const {_silentZoneKey: true});

  /// Updates debug logging filters, presentation, and destination.
  ///
  /// [output] replaces where formatted lines go (default [debugPrint]) —
  /// route engine logs into the app's own logger without forking the engine.
  static void configure({
    LogLevel? minLevel,
    bool? colors,
    Set<String>? tags,
    void Function(String line)? output,
  }) {
    if (minLevel != null) _minLevel = minLevel;
    if (colors != null) _colors = colors;
    if (output != null) _output = output;
    _tags = tags == null ? null : Set<String>.unmodifiable(tags);
  }

  /// Writes a network diagnostic.
  static void net(String message) {
    _emit(LogLevel.debug, 'net', () => message);
  }

  /// Writes an action error and a compact stack trace.
  static void error(Object error, StackTrace stack, {String tag = 'action'}) {
    _emit(LogLevel.error, tag, () {
      final frames = stack.toString().trim().split('\n').take(5).join('\n');
      final renderedStack = _colors ? '\x1B[2m$frames\x1B[0m' : frames;
      return '$error\n$renderedStack';
    });
  }

  /// Produces a compact representation for diagnostic payloads.
  static String summarize(Object? value) {
    if (value is List) return '[${value.length}]';
    if (value is Map) {
      final keys = value.keys.take(6).join(', ');
      final suffix = value.length > 6 ? ', …' : '';
      return '{$keys$suffix}';
    }
    if (value is String) {
      const maxLength = 80;
      return value.length <= maxLength
          ? value
          : '${value.substring(0, maxLength)}…';
    }
    if (value is num || value is bool) return value.toString();
    if (value == null) return 'null';
    return value.runtimeType.toString();
  }

  static void _emit(LogLevel level, String tag, String Function() message) {
    if (!kDebugMode || level.index < _minLevel.index) return;
    if (Zone.current[_silentZoneKey] == true) return;
    if (_tags != null && !_tags!.contains(tag)) return;

    final now = DateTime.now();
    final time =
        '${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}.'
        '${_three(now.millisecond)}';
    final levelText = level.name.toUpperCase().padRight(5);
    final tagText = '[$tag]'.padRight(8);
    final line =
        '${_segment(time, '\x1B[90m')}'
        '  ${_segment(levelText, _levelColor(level))}'
        '  ${_segment(tagText, '\x1B[2m')}'
        '  ${message()}';
    (_output ?? (l) => debugPrint(l))(line);
  }

  static String _segment(String text, String color) =>
      _colors ? '$color$text\x1B[0m' : text;

  static String _levelColor(LogLevel level) => switch (level) {
    LogLevel.trace => '\x1B[90m',
    LogLevel.debug => '\x1B[36m',
    LogLevel.info => '\x1B[32m',
    LogLevel.warn => '\x1B[33m',
    LogLevel.error => '\x1B[1;31m',
  };

  static String _two(int value) => value.toString().padLeft(2, '0');
  static String _three(int value) => value.toString().padLeft(3, '0');
}

final class _ActionLog {
  const _ActionLog();

  void start(String name) =>
      EngineLog._emit(LogLevel.info, 'action', () => '$name ▶ start');

  void done(String name, Duration elapsed) => EngineLog._emit(
    LogLevel.info,
    'action',
    () => '$name ✔ done ${elapsed.inMilliseconds}ms',
  );

  void deduped(String name) => EngineLog._emit(
    LogLevel.debug,
    'action',
    () => '$name ⤾ deduped (in-flight)',
  );
}

final class _DriverLog {
  const _DriverLog();

  void start(String type, Map params) => EngineLog._emit(
    LogLevel.debug,
    'driver',
    () => '$type ▶ ${EngineLog.summarize(params)}',
  );

  void ok(String type, Duration elapsed, Object? data) => EngineLog._emit(
    LogLevel.debug,
    'driver',
    () =>
        '$type ◀ ok ${elapsed.inMilliseconds}ms '
        '${EngineLog.summarize(data)}',
  );

  void fail(String type, Duration elapsed, Object error) {
    final level = error is DriverError ? LogLevel.warn : LogLevel.error;
    EngineLog._emit(level, 'driver', () {
      final code = error is DriverError ? error.code : error.runtimeType;
      final message = error is DriverError
          ? error.message ?? ''
          : error.toString();
      return '$type ✗ $code "$message" ${elapsed.inMilliseconds}ms';
    });
  }

  void background(String type) =>
      EngineLog._emit(LogLevel.debug, 'driver', () => '$type ⇢ background');

  /// Logs a driver that no-op'd instead of running (a benign, expected
  /// condition — e.g. a decorative command whose target isn't mounted).
  void skip(String type, String reason) =>
      EngineLog._emit(LogLevel.debug, 'driver', () => '$type ⤫ skip ($reason)');
}

final class _StateLog {
  const _StateLog();

  void commit(Map<String, Object?> changed) => EngineLog._emit(
    LogLevel.debug,
    'state',
    () => changed.entries
        .map((entry) => '${entry.key} ${EngineLog.summarize(entry.value)}')
        .join(', '),
  );

  void undeclared(String key) => EngineLog._emit(
    LogLevel.error,
    'state',
    () => 'undeclared key "$key" — declare in _state',
  );
}

final class _ScreenLog {
  const _ScreenLog();

  void compiling() =>
      EngineLog._emit(LogLevel.debug, 'screen', () => 'compiling');

  void compiled(int nodes, Duration elapsed) => EngineLog._emit(
    LogLevel.info,
    'screen',
    () => 'compiled $nodes nodes ${elapsed.inMilliseconds}ms',
  );

  void compileFailed(Object error) =>
      EngineLog._emit(LogLevel.error, 'screen', () => '$error');

  void mount(String rootType) =>
      EngineLog._emit(LogLevel.debug, 'screen', () => 'mount $rootType');
}

final class _ScopeLog {
  const _ScopeLog();

  void lifecycle(String trigger, String action, {Duration? delay}) =>
      EngineLog._emit(LogLevel.debug, 'scope', () {
        final suffix = delay == null ? '' : ' +${delay.inMilliseconds}ms';
        return '$trigger → $action$suffix';
      });
}

final class _WidgetLog {
  const _WidgetLog();

  void unknownProps(String type, Iterable<String> props, String path) =>
      EngineLog._emit(
        LogLevel.warn,
        'widget',
        () => '$type ignored prop(s): ${props.join(', ')} @$path',
      );
}
