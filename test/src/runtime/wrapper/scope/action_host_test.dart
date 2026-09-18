import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/dependency/telemetry_sink.dart';
import 'package:sdui_engine/src/ir/model/action/command.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_environment.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_error.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/action_host.dart';
import 'package:sdui_engine/src/runtime/telemetry/telemetry.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';

/// 테스트가 완료 시점을 쥐는 async driver 더블 — completer로 resolve/reject, 호출 수 셈.
class _AsyncDriver extends Driver {
  _AsyncDriver(this.completer);

  final Completer<Object?> completer;
  int calls = 0;

  @override
  String get type => 'async';

  @override
  Future<Object?> run(DriverContext ctx) {
    calls++;
    return completer.future;
  }
}

/// `await` 재개 시점의 `ctx.isCancelled`를 기록하는 driver — host가 라이브 dispose 신호를
/// driver까지 흘리는지 관찰한다.
class _CancelProbeDriver extends Driver {
  _CancelProbeDriver(this.gate, this.seen);

  final Completer<void> gate;
  final List<bool> seen;

  @override
  String get type => 'probe';

  @override
  Future<Object?> run(DriverContext ctx) async {
    await gate.future;
    seen.add(ctx.isCancelled);
    return null;
  }
}

/// toString까지 던지는 적대적 예외 — 에러 정규화 자체가 던지는 경로를 만든다.
class _EvilError implements Exception {
  @override
  String toString() => throw StateError('toString exploded');
}

/// params의 `value`를 그대로 돌려주는 driver — 중첩 `_then`의 층마다 다른 `$data`를 만든다.
class _EchoDriver extends Driver {
  const _EchoDriver();

  @override
  String get type => 'echo';

  @override
  Future<Object?> run(DriverContext ctx) async => ctx.params['value'];
}

/// 즉시 [_EvilError]를 던지는 driver.
class _EvilDriver extends Driver {
  const _EvilDriver();

  @override
  String get type => 'evil';

  @override
  Future<Object?> run(DriverContext ctx) async => throw _EvilError();
}

class _TelemetryDriver extends Driver {
  _TelemetryDriver(this.driverType, {this.error});

  final String driverType;
  final Object? error;
  final List<DriverContext> contexts = [];

  @override
  String get type => driverType;

  @override
  Future<Object?> run(DriverContext ctx) async {
    contexts.add(ctx);
    if (error != null) throw error!;
    return const {'ok': true};
  }
}

class _TelemetrySink implements TelemetrySink {
  final events = <TelemetryEvent>[];
  final completions = <Map<String, Object?>>[];

  @override
  void record(TelemetryEvent event) => events.add(event);

  @override
  Future<TelemetryReservation> reserve(TelemetryEvent event) async {
    events.add(event);
    return _TelemetryCompletion(completions);
  }
}

class _TelemetryCompletion implements TelemetryReservation {
  const _TelemetryCompletion(this.completions);

  final List<Map<String, Object?>> completions;

  @override
  void complete({Map<String, Object?> properties = const {}}) {
    completions.add(properties);
  }
}

Command _set(String target, String expr) =>
    Command(type: 'set', params: {target: Expression.compile(expr)});

Action _action(Command command, {bool dedupe = true}) => Action(
  steps: [
    [command],
  ],
  dedupe: dedupe,
);

/// 'net' 는 이제 엔진 소유 — 테스트 driver 는 내부 설치 경로로 넣는다.
void _register(Driver driver) {
  if (driver.type == 'net') {
    DriverRegistry.installEngineOwned(driver);
  } else {
    DriverRegistry.register(driver);
  }
}

void main() {
  // env.set이 SchedulerBinding.instance를 참조하므로 바인딩을 세운다.
  TestWidgetsFlutterBinding.ensureInitialized();

  // 커스텀 driver 등록 뒤엔 빌트인으로 되돌린다(set은 pre-seed).
  tearDown(() {
    DriverRegistry.reset();
    Telemetry.reset();
  });

  group('ActionHost', () {
    group('command telemetry', () {
      test('api reserves before execution and masks variable values', () async {
        final sink = _TelemetrySink();
        Telemetry.install(sink);
        final driver = _TelemetryDriver('net');
        _register(driver);
        final host = ActionHost(
          actions: {
            'load': _action(
              const Command(
                type: 'net',
                params: {
                  'query': 'Viewer',
                  'variables': {
                    'partnerId': 'partner-1',
                    'keyword': 'secret',
                    'nested': {'password': 'never'},
                  },
                },
              ),
            ),
          },
          env: ScopeEnvironment(const {}),
        );
        const invocation = ActionInvocation(
          invocationId: 'invocation-1',
          origin: ActionOrigin.tap,
        );

        await host.handleAwaitable('load', invocation: invocation);

        expect(sink.events, hasLength(1));
        expect(sink.events.single.correlationId, 'invocation-1');
        expect(sink.events.single.properties['param_keys'], [
          'query',
          'variables',
        ]);
        // Parameter *values* never leave the engine — request vocabulary is
        // implementation-owned, so telemetry records shapes only.
        expect(
          sink.events.single.properties.containsKey('vars'),
          isFalse,
        );
        expect(sink.completions.single['outcome'], 'success');
      });

      test(
        '_then keeps invocation id and changes only branch origin',
        () async {
          final sink = _TelemetrySink();
          Telemetry.install(sink);
          final driver = _TelemetryDriver('net');
          _register(driver);
          final host = ActionHost(
            actions: {
              'load': _action(
                const Command(
                  type: 'net',
                  params: {'query': 'First'},
                  then: [
                    [
                      Command(type: 'net', params: {'query': 'Second'}),
                    ],
                  ],
                ),
              ),
            },
            env: ScopeEnvironment(const {}),
          );

          await host.handleAwaitable(
            'load',
            invocation: const ActionInvocation(
              invocationId: 'same-id',
              origin: ActionOrigin.tap,
            ),
          );

          expect(driver.contexts.map((ctx) => ctx.correlationId), [
            'same-id',
            'same-id',
          ]);
          expect(driver.contexts.map((ctx) => ctx.branchOrigin), [
            null,
            ActionOrigin.then,
          ]);
        },
      );

      test('handled failure completes with handled outcome', () async {
        final sink = _TelemetrySink();
        Telemetry.install(sink);
        _register(
          _TelemetryDriver(
            'net',
            error: const DriverError(DriverError.handled),
          ),
        );
        final host = ActionHost(
          actions: {'load': _action(const Command(type: 'net'))},
          env: ScopeEnvironment(const {}),
        );

        await host.handleAwaitable('load');

        expect(sink.completions.single['outcome'], 'handled');
        expect(sink.completions.single['error_code'], DriverError.handled);
      });

      test('successful non-api command is not recorded', () async {
        final sink = _TelemetrySink();
        Telemetry.install(sink);
        DriverRegistry.register(_TelemetryDriver('probe_telemetry'));
        final host = ActionHost(
          actions: {'run': _action(const Command(type: 'probe_telemetry'))},
          env: ScopeEnvironment(const {}),
        );

        await host.handleAwaitable('run');

        expect(sink.events, isEmpty);
      });

      test(
        'failed non-api command is recorded after the failure is known',
        () async {
          final sink = _TelemetrySink();
          Telemetry.install(sink);
          DriverRegistry.register(
            _TelemetryDriver(
              'probe_telemetry',
              error: const DriverError('PROBE_FAILED'),
            ),
          );
          final host = ActionHost(
            actions: {
              'run': _action(
                const Command(type: 'probe_telemetry', onError: {'_': []}),
              ),
            },
            env: ScopeEnvironment(const {}),
          );

          await host.handleAwaitable('run');

          expect(sink.events.single.properties['outcome'], 'error');
          expect(sink.events.single.properties['error_code'], 'PROBE_FAILED');
        },
      );

      test(
        'overlapping actions keep their explicitly passed invocation ids',
        () async {
          final driver = _TelemetryDriver('probe_telemetry');
          _register(driver);
          final host = ActionHost(
            actions: {
              'run': const Action(
                steps: [
                  [Command(type: 'probe_telemetry')],
                ],
                dedupe: false,
              ),
            },
            env: ScopeEnvironment(const {}),
          );

          host.handle(
            'run',
            invocation: const ActionInvocation(
              invocationId: 'invocation-a',
              origin: ActionOrigin.tap,
            ),
          );
          host.handle(
            'run',
            invocation: const ActionInvocation(
              invocationId: 'invocation-b',
              origin: ActionOrigin.tap,
            ),
          );
          await pumpEventQueue();

          expect(driver.contexts.map((ctx) => ctx.correlationId).toSet(), {
            'invocation-a',
            'invocation-b',
          });
        },
      );
    });
    group('동기 set', () {
      test('set 커맨드가 env를 즉시 갱신한다', () {
        final env = ScopeEnvironment({'count': 0});
        final host = ActionHost(
          actions: {'inc': _action(_set('count', r'count + 1'))},
          env: env,
        );

        host.handle('inc'); // 동기 set은 이 턴에 반영

        expect(env.read('count'), 1);
      });

      test('이 scope에 없으면 부모 host로 walk', () {
        final parentEnv = ScopeEnvironment({'count': 0});
        final parent = ActionHost(
          actions: {'inc': _action(_set('count', r'count + 1'))},
          env: parentEnv,
        );
        final child = ActionHost(
          actions: const {},
          env: ScopeEnvironment(const {}),
          parent: parent,
        );

        child.handle('inc');

        expect(parentEnv.read('count'), 1);
      });

      test('정의 없는 이름은 조용히 무동작', () {
        final env = ScopeEnvironment({'count': 0});
        final host = ActionHost(actions: const {}, env: env);
        expect(() => host.handle('nope'), returnsNormally);
        expect(env.read('count'), 0);
      });
    });

    group('\$event 페이로드', () {
      test('handle(event:)가 \$event 그림자로 주입돼 액션이 읽는다', () {
        final env = ScopeEnvironment({'picked': 0});
        final host = ActionHost(
          actions: {'save': _action(_set('picked', r'event.value'))},
          env: env,
        );

        host.handle('save', event: {'value': 7});

        expect(env.read('picked'), 7); // 동기 set이 $event.value=7을 반영
      });

      test('event 없이 부르면 \$event는 없다(기존 동작 불변)', () {
        final env = ScopeEnvironment({'picked': -1});
        final host = ActionHost(
          actions: {'save': _action(_set('picked', r'event.value'))},
          env: env,
        );

        // $event 미주입 — 예외 없이 돌고 7로 덮지 않는다.
        expect(() => host.handle('save'), returnsNormally);
        expect(env.read('picked'), isNot(7));
      });

      test('부모로 walk해도 event가 함께 전달된다', () {
        final parentEnv = ScopeEnvironment({'picked': 0});
        final parent = ActionHost(
          actions: {'save': _action(_set('picked', r'event.value'))},
          env: parentEnv,
        );
        final child = ActionHost(
          actions: const {},
          env: ScopeEnvironment(const {}),
          parent: parent,
        );

        child.handle('save', event: {'value': 9});

        expect(parentEnv.read('picked'), 9);
      });
    });

    group('async 체인', () {
      test('성공 → _then이 \$data로 set한다', () async {
        final completer = Completer<Object?>();
        DriverRegistry.register(_AsyncDriver(completer));
        final env = ScopeEnvironment({'result': 0});
        final host = ActionHost(
          actions: {
            'load': _action(
              Command(
                type: 'async',
                then: [
                  [_set('result', r'data')],
                ],
              ),
            ),
          },
          env: env,
        );

        host.handle('load');
        expect(env.read('result'), 0); // 아직 안 옴

        completer.complete(42);
        await pumpEventQueue();

        expect(env.read('result'), 42); // then이 $data=42를 set
      });

      // 서버 템플릿의 `/throttled_popup`이 이 층위에 기댄다 — 바깥 커맨드(알림 권한 확인)의
      // 결과로 안쪽 커맨드를 걸러내고, 그 안쪽 결과로 다시 모달을 건다. 두 층이 같은 이름
      // `data`를 쓰므로 안쪽 그림자가 바깥을 가리지 않으면 조건이 엉킨다.
      test('중첩 _then — 안쪽 \$data가 바깥 \$data를 가리고, 사이의 _when은 바깥을 본다', () async {
        DriverRegistry.register(const _EchoDriver());
        final env = ScopeEnvironment({'result': 'none'});
        final host = ActionHost(
          actions: {
            'prompt': _action(
              Command(
                type: 'echo',
                params: {'value': 'denied'},
                then: [
                  [
                    Command(
                      type: 'echo',
                      params: {'value': 'inner'},
                      // 바깥 $data('denied')를 본다
                      when: Expression.compile(r'data != "granted"'),
                      then: [
                        [_set('result', r'data')],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          },
          env: env,
        );

        host.handle('prompt');
        await pumpEventQueue();

        expect(env.read('result'), 'inner'); // 안쪽 $data가 이긴다
      });

      test('중첩 _then — 사이의 _when이 바깥 \$data로 막으면 안쪽은 아예 안 돈다', () async {
        DriverRegistry.register(const _EchoDriver());
        final env = ScopeEnvironment({'result': 'none'});
        final host = ActionHost(
          actions: {
            'prompt': _action(
              Command(
                type: 'echo',
                params: {'value': 'granted'},
                then: [
                  [
                    Command(
                      type: 'echo',
                      params: {'value': 'inner'},
                      when: Expression.compile(r'data != "granted"'),
                      then: [
                        [_set('result', r'data')],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          },
          env: env,
        );

        host.handle('prompt');
        await pumpEventQueue();

        expect(env.read('result'), 'none');
      });

      test('DriverError → code에 맞는 _error 가지가 \$error로 돈다', () async {
        final completer = Completer<Object?>();
        DriverRegistry.register(_AsyncDriver(completer));
        final env = ScopeEnvironment({'code': ''});
        final host = ActionHost(
          actions: {
            'load': _action(
              Command(
                type: 'async',
                onError: {
                  'RW1': [
                    [_set('code', r'error.code')],
                  ],
                },
              ),
            ),
          },
          env: env,
        );

        host.handle('load');
        completer.completeError(const DriverError('RW1'));
        await pumpEventQueue();

        expect(env.read('code'), 'RW1');
      });
    });

    group('_dismiss', () {
      test('DISMISSED → _dismiss 가지가 돈다 (에러 아님)', () async {
        final completer = Completer<Object?>();
        DriverRegistry.register(_AsyncDriver(completer));
        final env = ScopeEnvironment({'closed': false});
        final host = ActionHost(
          actions: {
            'open': _action(
              Command(
                type: 'async',
                dismiss: [
                  [_set('closed', 'true')],
                ],
              ),
            ),
          },
          env: env,
        );

        host.handle('open');
        completer.completeError(const DriverError(DriverError.dismissed));
        await pumpEventQueue();

        expect(env.read('closed'), true);
      });

      test('_dismiss 없으면 no-op — _error 안 돌고 _always만 돈다', () async {
        final completer = Completer<Object?>();
        DriverRegistry.register(_AsyncDriver(completer));
        final env = ScopeEnvironment({'erred': false, 'done': false});
        final host = ActionHost(
          actions: {
            'open': _action(
              Command(
                type: 'async',
                onError: {
                  '_': [
                    [_set('erred', 'true')],
                  ],
                },
                always: [
                  [_set('done', 'true')],
                ],
              ),
            ),
          },
          env: env,
        );

        host.handle('open');
        completer.completeError(const DriverError(DriverError.dismissed));
        await pumpEventQueue();

        expect(env.read('erred'), false); // dismiss는 _error로 가지 않는다
        expect(env.read('done'), true); // _always는 정상 실행
      });
    });

    group('DriverError.handled', () {
      test('_error로 가지 않고 _always만 돈다 — 이미 경계에서 처리된 실패', () async {
        final reported = <Object>[];
        final prev = FlutterError.onError;
        FlutterError.onError = (details) => reported.add(details.exception);
        addTearDown(() => FlutterError.onError = prev);

        final completer = Completer<Object?>();
        DriverRegistry.register(_AsyncDriver(completer));
        final env = ScopeEnvironment({'erred': false, 'done': false});
        final host = ActionHost(
          actions: {
            'load': _action(
              Command(
                type: 'async',
                onError: {
                  '_': [
                    [_set('erred', 'true')],
                  ],
                },
                always: [
                  [_set('done', 'true')],
                ],
              ),
            ),
          },
          env: env,
        );

        host.handle('load');
        completer.completeError(const DriverError(DriverError.handled));
        await pumpEventQueue();

        expect(env.read('erred'), false); // 이미 처리된 실패는 _error로 가지 않는다
        expect(env.read('done'), true); // _always는 정상 실행
        expect(reported, isEmpty); // 경계에서 이미 다룬 실패 — 재보고 안 함
      });

      test('_then도 돌지 않는다', () async {
        final completer = Completer<Object?>();
        DriverRegistry.register(_AsyncDriver(completer));
        final env = ScopeEnvironment({'result': 'none'});
        final host = ActionHost(
          actions: {
            'load': _action(
              Command(
                type: 'async',
                then: [
                  [_set('result', r'data')],
                ],
              ),
            ),
          },
          env: env,
        );

        host.handle('load');
        completer.completeError(const DriverError(DriverError.handled));
        await pumpEventQueue();

        expect(env.read('result'), 'none');
      });
    });

    group('dedupe', () {
      test('기본(true): 도는 중 같은 액션 재호출은 drop', () async {
        final completer = Completer<Object?>();
        final driver = _AsyncDriver(completer);
        _register(driver);
        final host = ActionHost(
          actions: {'load': _action(const Command(type: 'async'))},
          env: ScopeEnvironment(const {}),
        );

        host.handle('load');
        host.handle('load'); // 도는 중 → drop
        await pumpEventQueue();
        expect(driver.calls, 1);

        completer.complete(null); // 첫 호출 종료 → inflight 해제
        await pumpEventQueue();
        host.handle('load'); // 이제 다시 됨
        await pumpEventQueue();
        expect(driver.calls, 2);
      });

      test('false: 도는 중에도 겹쳐 실행', () async {
        final completer = Completer<Object?>();
        final driver = _AsyncDriver(completer);
        _register(driver);
        final host = ActionHost(
          actions: {
            'log': _action(const Command(type: 'async'), dedupe: false),
          },
          env: ScopeEnvironment(const {}),
        );

        host.handle('log');
        host.handle('log'); // 등록 안 하니 또 실행
        await pumpEventQueue();

        expect(driver.calls, 2);
      });
    });

    group('격리·수명', () {
      test('toString까지 던지는 예외도 _error 가지가 정상 처리한다 (R1)', () async {
        // 옛 구조는 _errorData의 error.toString()이 던지면 그 2차 예외가 외곽 catch 없이
        // unawaited future로 새서 zone error가 됐다(테스트가 여기서 터졌을 것). 이제
        // 정규화가 타입명으로 폴백하고, 남는 어떤 2차 예외도 외곽 catch가 보고로 격리한다.
        DriverRegistry.register(const _EvilDriver());
        final env = ScopeEnvironment({'msg': ''});
        final host = ActionHost(
          actions: {
            'boom': _action(
              Command(
                type: 'evil',
                onError: {
                  '_': [
                    [_set('msg', r"'failed'")],
                  ],
                },
              ),
            ),
          },
          env: env,
        );

        expect(() => host.handle('boom'), returnsNormally);
        await pumpEventQueue(); // 미처리 zone error가 있으면 여기서 테스트가 터진다

        expect(env.read('msg'), 'failed'); // 적대적 예외에도 에러 가지는 돈다
      });

      test('dispose 뒤엔 진행 중 flow의 후속이 중단된다 (R2)', () async {
        final completer = Completer<Object?>();
        DriverRegistry.register(_AsyncDriver(completer));
        final env = ScopeEnvironment({'result': 0});
        final host = ActionHost(
          actions: {
            'load': _action(
              Command(
                type: 'async',
                then: [
                  [_set('result', '1')],
                ],
              ),
            ),
          },
          env: env,
        );

        host.handle('load');
        host.dispose(); // 화면 제거
        completer.complete(null); // 요청은 그 뒤 완료
        await pumpEventQueue();

        expect(env.read('result'), 0); // _then이 유령 실행되지 않는다
      });

      test('driver는 ctx.isCancelled로 host dispose를 라이브로 본다 (A-2)', () async {
        final gate = Completer<void>();
        final seen = <bool>[];
        DriverRegistry.register(_CancelProbeDriver(gate, seen));
        final host = ActionHost(
          actions: {'go': _action(const Command(type: 'probe'))},
          env: ScopeEnvironment(const {}),
        );

        host.handle('go'); // driver는 gate에서 멈춰 있음
        host.dispose(); // await 재개 전에 화면 제거
        gate.complete();
        await pumpEventQueue();

        expect(seen, [true]); // 재개 시점엔 이미 dispose — 스냅샷이었다면 false였을 것
      });

      test('dispose 뒤 handle은 no-op (R2)', () async {
        final completer = Completer<Object?>();
        final driver = _AsyncDriver(completer);
        _register(driver);
        final host = ActionHost(
          actions: {'load': _action(const Command(type: 'async'))},
          env: ScopeEnvironment(const {}),
        );

        host.dispose();
        host.handle('load');
        await pumpEventQueue();

        expect(driver.calls, 0);
      });

      test(
        'un-terminating background future가 dedupe를 brick하지 않는다 (foreground 완료 시 해제)',
        () async {
          // 예전 계약(bg 완료까지 dedupe)에선 콜백을 흘리는 bg driver의 **안 끝나는 future** 하나가
          // 그 액션을 영구 brick했다(재실행 영영 drop). 이제 foreground flow가 끝나면 해제되므로
          // background는 재실행을 막지 않는다. (foreground async 커맨드는 여전히 완료까지 dedupe —
          // 위 "기본(true)" 테스트가 지킨다.)
          final never = Completer<Object?>(); // 영영 안 끝나는 bg
          final driver = _AsyncDriver(never);
          _register(driver);
          final host = ActionHost(
            actions: {
              'fire': const Action(
                steps: [
                  [Command(type: 'async', background: true)],
                ],
              ),
            },
            env: ScopeEnvironment(const {}),
          );

          host.handle('fire');
          await pumpEventQueue();
          expect(driver.calls, 1);

          // bg는 영영 안 끝나지만 foreground flow는 끝났으니 재실행돼야 한다(brick 아님).
          host.handle('fire');
          await pumpEventQueue();
          expect(driver.calls, 2);
        },
      );
    });

    group('background', () {
      test('쏘되 flow가 안 기다린다 (같은 배치 다음 커맨드가 바로 돎)', () async {
        final completer = Completer<Object?>(); // 절대 안 끝냄
        final driver = _AsyncDriver(completer);
        _register(driver);
        final env = ScopeEnvironment({'done': false});
        final host = ActionHost(
          actions: {
            'fire': Action(
              steps: [
                [
                  const Command(type: 'async', background: true), // 쏘고 잊음
                  _set('done', 'true'), // 안 기다리면 이 set이 바로 반영
                ],
              ],
            ),
          },
          env: env,
        );

        host.handle('fire');
        await pumpEventQueue();

        expect(driver.calls, 1); // background driver는 쏨
        expect(env.read('done'), true); // completer 미완이어도 set 실행 — flow가 안 기다림
      });

      test(
        'background의 DriverError(예상된 도메인 실패)는 삼켜진다 — 보고 안 함 (§0.2)',
        () async {
          final reported = <Object>[];
          final prev = FlutterError.onError;
          FlutterError.onError = (details) => reported.add(details.exception);
          addTearDown(() => FlutterError.onError = prev);

          DriverRegistry.register(
            _AsyncDriver(
              Completer<Object?>()..completeError(const DriverError('X')),
            ),
          );
          final env = ScopeEnvironment({'done': false});
          final host = ActionHost(
            actions: {
              'fire': Action(
                steps: [
                  [
                    const Command(type: 'async', background: true),
                    _set('done', 'true'),
                  ],
                ],
              ),
            },
            env: env,
          );

          expect(() => host.handle('fire'), returnsNormally);
          await pumpEventQueue();

          expect(env.read('done'), true); // flow 무손상
          expect(reported, isEmpty); // DriverError는 예상된 무시 → 보고 없음
        },
      );

      test('background의 일반 예외(driver 버그)는 보고되고 flow는 무손상 (§0.2)', () async {
        final reported = <Object>[];
        final prev = FlutterError.onError;
        FlutterError.onError = (details) => reported.add(details.exception);
        addTearDown(() => FlutterError.onError = prev);

        DriverRegistry.register(
          _AsyncDriver(Completer<Object?>()..completeError(StateError('bug'))),
        );
        final env = ScopeEnvironment({'done': false});
        final host = ActionHost(
          actions: {
            'fire': Action(
              steps: [
                [
                  const Command(type: 'async', background: true),
                  _set('done', 'true'),
                ],
              ],
            ),
          },
          env: env,
        );

        expect(() => host.handle('fire'), returnsNormally);
        await pumpEventQueue();

        expect(env.read('done'), true); // flow는 여전히 non-blocking
        expect(reported, hasLength(1)); // 삼키지 않고 보고
        expect(reported.first, isA<StateError>());
      });

      test('background의 미등록 driver type도 보고된다 (§0.2 — resolve 실패)', () async {
        final reported = <Object>[];
        final prev = FlutterError.onError;
        FlutterError.onError = (details) => reported.add(details.exception);
        addTearDown(() => FlutterError.onError = prev);

        final host = ActionHost(
          actions: {
            'fire': _action(const Command(type: 'ghost', background: true)),
          },
          env: ScopeEnvironment(const {}),
        );

        expect(() => host.handle('fire'), returnsNormally);
        await pumpEventQueue();

        expect(reported, hasLength(1)); // resolve 실패(StateError)도 조용히 삼키지 않음
        expect(reported.first, isA<StateError>());
      });
    });

    group('_when', () {
      test('truthy guard runs the driver', () async {
        final completer = Completer<Object?>()..complete(null);
        final driver = _AsyncDriver(completer);
        _register(driver);
        final host = ActionHost(
          actions: {
            'run': _action(
              Command(type: 'async', when: Expression.compile('enabled')),
            ),
          },
          env: ScopeEnvironment({'enabled': true}),
        );

        await host.handleAwaitable('run');

        expect(driver.calls, 1);
      });

      test('falsy guard skips the driver and all handlers', () async {
        final completer = Completer<Object?>()..complete(null);
        final driver = _AsyncDriver(completer);
        _register(driver);
        final env = ScopeEnvironment({'enabled': false, 'thenRan': false});
        final host = ActionHost(
          actions: {
            'run': _action(
              Command(
                type: 'async',
                when: Expression.compile('enabled'),
                then: [
                  [_set('thenRan', 'true')],
                ],
              ),
            ),
          },
          env: env,
        );

        await host.handleAwaitable('run');

        expect(driver.calls, 0);
        expect(env.read('thenRan'), false);
      });

      test('command without a guard still runs the driver', () async {
        final completer = Completer<Object?>()..complete(null);
        final driver = _AsyncDriver(completer);
        _register(driver);
        final host = ActionHost(
          actions: {'run': _action(const Command(type: 'async'))},
          env: ScopeEnvironment(const {}),
        );

        await host.handleAwaitable('run');

        expect(driver.calls, 1);
      });

      test(r'guard inside _then reads the parent command $data', () async {
        final completer = Completer<Object?>();
        final driver = _AsyncDriver(completer);
        _register(driver);
        final env = ScopeEnvironment({'ran': false, 'skipped': false});
        final host = ActionHost(
          actions: {
            'run': _action(
              Command(
                type: 'async',
                then: [
                  [
                    Command(
                      type: 'set',
                      when: Expression.compile('data != null'),
                      params: {'ran': true},
                    ),
                    Command(
                      type: 'set',
                      when: Expression.compile('data == null'),
                      params: {'skipped': true},
                    ),
                  ],
                ],
              ),
            ),
          },
          env: env,
        );

        host.handle('run');
        completer.complete(42);
        await pumpEventQueue();

        expect(driver.calls, 1);
        expect(env.read('ran'), true);
        expect(env.read('skipped'), false);
      });

      test('falsy guard skips a background command', () async {
        final completer = Completer<Object?>();
        final driver = _AsyncDriver(completer);
        _register(driver);
        final host = ActionHost(
          actions: {
            'run': _action(
              Command(
                type: 'async',
                background: true,
                when: Expression.compile('false'),
              ),
            ),
          },
          env: ScopeEnvironment(const {}),
        );

        await host.handleAwaitable('run');

        expect(driver.calls, 0);
      });

      test('throwing guard is reported and skipped without escaping', () async {
        final reported = <Object>[];
        final prev = FlutterError.onError;
        FlutterError.onError = (details) => reported.add(details.exception);
        addTearDown(() => FlutterError.onError = prev);
        final completer = Completer<Object?>()..complete(null);
        final driver = _AsyncDriver(completer);
        _register(driver);
        final host = ActionHost(
          actions: {
            'run': _action(
              Command(type: 'async', when: Expression.compile('missing + 1')),
            ),
          },
          env: ScopeEnvironment(const {}),
        );

        await expectLater(host.handleAwaitable('run'), completes);

        expect(driver.calls, 0);
        expect(reported, hasLength(1));
      });
    });
  });
}
