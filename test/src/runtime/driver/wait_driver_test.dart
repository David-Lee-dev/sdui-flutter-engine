// Inspect listener cleanup without adding a test-only runtime API.
// ignore_for_file: invalid_use_of_protected_member

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:sdui_engine/src/contract/error_observer.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import 'package:sdui_engine/src/ir/model/action/command.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/driver/driver_error.dart';
import 'package:sdui_engine/src/runtime/util/function_registry.dart';
import 'package:sdui_engine/src/runtime/engine_errors.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_environment.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/action_host.dart';

class _Errors implements SduiErrorObserver {
  final errors = <SduiError>[];
  @override
  void onError(SduiError error) => errors.add(error);
}

Command set(Map<String, Object?> values) =>
    Command(type: 'set', params: values);

void main() {
  late ScopeEnvironment env;
  late ActionHost host;
  late _Errors errors;

  setUp(() {
    DriverRegistry.reset();
    errors = _Errors();
    EngineErrors.observer = errors;
    env = ScopeEnvironment({
      'x': 0,
      'y': 0,
      'a': 0,
      'b': 0,
      'd': 300,
      'p': 0,
      'f': 0,
      't': 0,
      'r': 'x',
    });
    host = ActionHost(actions: {}, env: env);
  });
  tearDown(() {
    host.dispose();
    env.dispose();
    EngineErrors.reset();
    FunctionRegistry.reset();
    DriverRegistry.reset();
  });

  void run(Command wait) {
    host.actions['go'] = Action(
      steps: [
        [wait],
        [
          set({'x': 1}),
        ],
      ],
    );
    host.handle('go');
  }

  test('until watches ancestors through an event shadow in background', () {
    fakeAsync((clock) {
      final parent = ScopeEnvironment({'ready': false});
      env.parent = parent;
      var evaluations = 0;
      FunctionRegistry.register('observe', (args) {
        evaluations++;
        return args.single;
      });
      host.actions['go'] = Action(
        steps: [
          [
            Command(
              type: 'wait',
              background: true,
              params: {
                'until': Expression.compile('observe(ready and event.allowed)'),
                'timeout': Expression.compile('d'),
              },
            ),
          ],
          [
            set({'x': 1}),
          ],
        ],
      );
      host.handle('go', event: {'allowed': true});
      clock.flushMicrotasks();
      expect(env.read('x'), 1);
      expect(evaluations, 1);
      expect(clock.pendingTimers.length, 1);
      clock.elapse(const Duration(milliseconds: 100));
      expect(evaluations, 1);
      parent.commit({'ready': true});
      clock.flushMicrotasks();
      expect(evaluations, 2);
      expect(clock.pendingTimers, isEmpty);
      expect(
        (parent.listen({'ready'})! as ChangeNotifier).hasListeners,
        isFalse,
      );
      parent.commit({'ready': false});
      expect(evaluations, 2);
      host.dispose();
      env.parent = null;
      parent.dispose();
    });
  });

  test('until reads data shadow and releases its watch on disposal', () {
    fakeAsync((clock) {
      host.actions['go'] = Action(
        steps: [
          [
            Command(
              type: 'set',
              params: const {'a': 1},
              then: [
                [
                  Command(
                    type: 'wait',
                    params: {
                      'until': Expression.compile('data == null and p >= 1'),
                      'timeout': 5000,
                    },
                    then: [
                      [
                        set({'x': 1}),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ],
        ],
      );
      var completed = false;
      host.handleAwaitable('go').then((_) => completed = true);
      clock.flushMicrotasks();
      expect(completed, isFalse);
      final notifier = env.listen({'p'})! as ChangeNotifier;
      expect(notifier.hasListeners, isTrue);
      host.dispose();
      clock.flushMicrotasks();
      expect(completed, isTrue);
      expect(env.read('x'), 0);
      expect(notifier.hasListeners, isFalse);
      expect(clock.pendingTimers, isEmpty);
    });
  });

  test('invalid timeouts immediately fail and release the watch', () {
    for (final timeout in [
      null,
      0,
      -1,
      2000000,
      'abc',
      double.nan,
      double.infinity,
    ]) {
      fakeAsync((clock) {
        env.commit({'x': 0});
        errors.errors.clear();
        run(
          Command(
            type: 'wait',
            params: {'until': Expression.compile('p >= 1'), 'timeout': timeout},
          ),
        );
        clock.flushMicrotasks();
        expect(env.read('x'), 1);
        expect(errors.errors, hasLength(1), reason: '$timeout');
        expect(
          errors.errors.single.error,
          isA<DriverError>().having((e) => e.code, 'code', 'WAIT_TIMEOUT'),
        );
        expect(clock.pendingTimers, isEmpty);
        expect((env.listen({'p'})! as ChangeNotifier).hasListeners, isFalse);
      });
    }
  });

  test('duration rounds finite values and accepts a numeric timeout', () {
    fakeAsync((clock) {
      run(const Command(type: 'wait', params: {'duration': 1.5}));
      clock.elapse(const Duration(milliseconds: 1));
      expect(env.read('x'), 0);
      clock.elapse(const Duration(milliseconds: 1));
      expect(env.read('x'), 1);
      env.commit({'x': 0});
      run(
        Command(
          type: 'wait',
          params: {'until': Expression.compile('p >= 1'), 'timeout': '250'},
        ),
      );
      clock.elapse(const Duration(milliseconds: 249));
      expect(errors.errors, isEmpty);
      clock.elapse(const Duration(milliseconds: 1));
      expect(errors.errors, hasLength(1));
    });
  });

  test('WAIT-AC1 waits duration then continues', () {
    fakeAsync((clock) {
      run(const Command(type: 'wait', params: {'duration': 1500}));
      clock.flushMicrotasks();
      clock.elapse(const Duration(milliseconds: 1499));
      expect(env.read('x'), 0);
      clock.elapse(const Duration(milliseconds: 1));
      expect(env.read('x'), 1);
      expect(errors.errors, isEmpty);
    });
  });
  test('WAIT-AC15', () {
    fakeAsync((clock) {
      final notifier = env.listen({'p'})! as ChangeNotifier;
      run(
        Command(
          type: 'wait',
          params: {'until': Expression.compile('p >= 1'), 'timeout': 5000},
        ),
      );
      clock.elapse(const Duration(milliseconds: 200));
      expect(env.read('x'), 0);
      expect(notifier.hasListeners, isTrue);
      host.actions['update'] = Action(
        steps: [
          [
            set({'p': 1}),
          ],
        ],
      );
      host.handle('update');
      clock.flushMicrotasks();
      expect(env.read('x'), 1);
      expect(clock.pendingTimers, isEmpty);
      expect(notifier.hasListeners, isFalse);
      expect(errors.errors, isEmpty);
    });
  });
  test('WAIT-AC15 disposal during initial evaluation releases listener', () {
    fakeAsync((clock) {
      final notifier = env.listen({'p'})! as ChangeNotifier;
      FunctionRegistry.register('dispose_owner', (_) {
        host.dispose();
        return false;
      });
      run(
        Command(
          type: 'wait',
          params: {
            'until': Expression.compile('dispose_owner(p)'),
            'timeout': 5000,
          },
        ),
      );
      clock.flushMicrotasks();
      expect(env.read('x'), 0);
      expect(clock.pendingTimers, isEmpty);
      expect(notifier.hasListeners, isFalse);
    });
  });
  test('WAIT-AC2', () {
    fakeAsync((clock) {
      run(const Command(type: 'wait', params: {'duration': 0}));
      clock.flushMicrotasks();
      expect(env.read('x'), 1);
      expect(clock.elapsed, Duration.zero);
    });
  });
  test('WAIT-AC3', () {
    fakeAsync((clock) {
      run(Command(type: 'wait', params: {'duration': Expression.compile('d')}));
      clock.elapse(const Duration(milliseconds: 299));
      expect(env.read('x'), 0);
      clock.elapse(const Duration(milliseconds: 1));
      expect(env.read('x'), 1);
    });
  });
  test('WAIT-AC4', () {
    fakeAsync((clock) {
      run(const Command(type: 'wait', params: {'duration': -5}));
      clock.flushMicrotasks();
      expect(env.read('x'), 1);
      expect(errors.errors, isEmpty);
    });
  });
  test('WAIT-AC5', () {
    fakeAsync((clock) {
      run(const Command(type: 'wait', params: {'duration': 'abc'}));
      clock.flushMicrotasks();
      expect(env.read('x'), 1);
    });
  });
  test('WAIT-AC6', () {
    fakeAsync((clock) {
      run(const Command(type: 'wait', params: {'duration': 2000000}));
      clock.flushMicrotasks();
      expect(env.read('x'), 1);
    });
  });
  test('WAIT-AC7', () {
    fakeAsync((clock) {
      run(const Command(type: 'wait', params: {'duration': '250'}));
      clock.elapse(const Duration(milliseconds: 249));
      expect(env.read('x'), 0);
      clock.elapse(const Duration(milliseconds: 1));
      expect(env.read('x'), 1);
    });
  });
  test('WAIT-AC8', () {
    fakeAsync((clock) {
      host.actions['go'] = Action(
        steps: [
          [
            const Command(type: 'wait', params: {'duration': 1000}),
          ],
          [
            set({'x': 1}),
          ],
        ],
      );
      var completed = false;
      host.handleAwaitable('go').then((_) => completed = true);
      clock.elapse(const Duration(milliseconds: 400));
      expect(completed, isFalse);
      host.dispose();
      clock.flushMicrotasks();
      expect(completed, isTrue);
      expect(clock.pendingTimers.length, 0);
      clock.elapse(const Duration(milliseconds: 1000));
      expect(env.read('x'), 0);
    });
  });
  test('WAIT-AC9', () {
    fakeAsync((clock) {
      run(
        Command(
          type: 'wait',
          params: const {'duration': 1000},
          always: [
            [
              set({'y': 1}),
            ],
          ],
        ),
      );
      clock.elapse(const Duration(milliseconds: 400));
      host.dispose();
      clock.elapse(const Duration(milliseconds: 1000));
      expect(env.read('y'), 0);
      expect(clock.pendingTimers.length, 0);
    });
  });
  test('WAIT-AC10', () {
    fakeAsync((clock) {
      host.actions['go'] = Action(
        steps: [
          [
            const Command(type: 'wait', params: {'duration': 300}),
            set({'a': 1}),
          ],
          [
            set({'b': 1}),
          ],
        ],
      );
      host.handle('go');
      clock.flushMicrotasks();
      expect(env.read('a'), 1);
      expect(env.read('b'), 0);
      clock.elapse(const Duration(milliseconds: 299));
      expect(env.read('b'), 0);
      clock.elapse(const Duration(milliseconds: 1));
      expect(env.read('b'), 1);
    });
  });
  test('WAIT-AC13', () {
    fakeAsync((clock) {
      run(
        Command(
          type: 'wait',
          params: const {'duration': 0},
          then: [
            [
              set({'r': Expression.compile('data')}),
            ],
          ],
        ),
      );
      clock.flushMicrotasks();
      expect(env.read('r'), isNull);
    });
  });
  test('WAIT-AC16', () {
    fakeAsync((clock) {
      run(
        Command(
          type: 'wait',
          params: {'until': Expression.compile('p >= 1'), 'timeout': 5000},
        ),
      );
      clock.elapse(const Duration(milliseconds: 200));
      host.actions['update'] = Action(
        steps: [
          [
            set({'p': 0.5}),
          ],
        ],
      );
      host.handle('update');
      clock.flushMicrotasks();
      expect(env.read('x'), 0);
      expect(clock.pendingTimers.length, 1);
      host.dispose();
      clock.flushMicrotasks();
      expect(clock.pendingTimers, isEmpty);
    });
  });
  test('WAIT-AC17', () {
    fakeAsync((clock) {
      env.commit({'p': 1});
      run(
        Command(
          type: 'wait',
          params: {'until': Expression.compile('p >= 1'), 'timeout': 5000},
        ),
      );
      clock.flushMicrotasks();
      expect(env.read('x'), 1);
      expect(clock.elapsed, Duration.zero);
      expect(clock.pendingTimers, isEmpty);
      expect((env.listen({'p'})! as ChangeNotifier).hasListeners, isFalse);
    });
  });
  test('WAIT-AC18', () {
    fakeAsync((clock) {
      run(
        Command(
          type: 'wait',
          params: {'until': Expression.compile('p >= 1'), 'timeout': 300},
          then: [
            [
              set({'t': 1}),
            ],
          ],
          onError: {
            'WAIT_TIMEOUT': [
              [
                set({'f': 1}),
              ],
            ],
          },
        ),
      );
      clock.elapse(const Duration(milliseconds: 299));
      expect(env.read('f'), 0);
      expect(env.read('x'), 0);
      clock.elapse(const Duration(milliseconds: 1));
      expect(env.read('f'), 1);
      expect(env.read('t'), 0);
      expect(env.read('x'), 1);
      expect(errors.errors, isEmpty);
      expect(clock.pendingTimers, isEmpty);
      expect((env.listen({'p'})! as ChangeNotifier).hasListeners, isFalse);
    });
  });
  test('WAIT-AC19', () {
    fakeAsync((clock) {
      run(
        Command(
          type: 'wait',
          params: {'until': Expression.compile('p >= 1'), 'timeout': 300},
          then: [
            [
              set({'t': 1}),
            ],
          ],
        ),
      );
      clock.elapse(const Duration(milliseconds: 300));
      expect(env.read('t'), 0);
      expect(env.read('x'), 1);
      expect(errors.errors, hasLength(1));
      expect(
        errors.errors.single.error,
        isA<DriverError>().having((e) => e.code, 'code', 'WAIT_TIMEOUT'),
      );
    });
  });
  test('WAIT-AC22', () {
    fakeAsync((clock) {
      var evaluations = 0;
      FunctionRegistry.register('explode', (_) {
        evaluations++;
        throw StateError('app function failed');
      });
      run(
        Command(
          type: 'wait',
          params: {'until': Expression.compile('explode(p)'), 'timeout': 300},
        ),
      );
      clock.flushMicrotasks();
      expect(env.read('x'), 0);
      expect(errors.errors, hasLength(1));
      expect(evaluations, 1);
      env.commit({'p': 0.5});
      clock.flushMicrotasks();
      expect(evaluations, 2);
      expect(env.read('x'), 0);
      clock.elapse(const Duration(milliseconds: 300));
      expect(
        errors.errors.last.error,
        isA<DriverError>().having((e) => e.code, 'code', 'WAIT_TIMEOUT'),
      );
      final count = evaluations;
      env.commit({'p': 1});
      clock.flushMicrotasks();
      expect(evaluations, count);
      expect(clock.pendingTimers, isEmpty);
    });
  });
}
