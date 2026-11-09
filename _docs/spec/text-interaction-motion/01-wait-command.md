# TIM-01 · `wait` 명령

> 문서 규격: SDD 0.1 · 상태: 승인(구현 전) · 확정 결정(D-)과 이 명세의 제안(P-)·검토 항목(R-)을 구분한다.

## 01. 문서 관리

| 항목 | 내용 |
|---|---|
| 문서 ID / 버전 | TIM-01 / 0.4 |
| 최종 갱신 | 2026-11-09 |
| 책임자 / 검토자 | 미지정 |
| 승인 상태 | 승인 2026-11-09(사용자). P-1, P-2, P-3, P-6, P-7, P-8, P-9, R-1 모두 제안대로 승인. 구현 전 |
| 변경 범위 | 신규: 액션 명령 `wait`(시간 대기 `duration`, 조건 대기 `until` + `timeout`), `_requires` 기능 `wait_v1` |

## 02. 문제와 목표

액션 흐름에 시간 지연 수단이 없다(0.25.0 `docs/actions.md`, 내장 명령 목록). 그래서 "완료 표시 → N초 뒤 원래 상태" 같은 버튼 상태 시퀀스를 상태로 끝맺을 수 없다. 곡선으로 보이는 것만 되돌리는 우회는 상태와 접근성 라벨이 완료 단계에 남는다. 다른 곳에서 바뀌는 값(업로드 진행률, 준비 완료 표시)이 정해진 값이 될 때까지 기다렸다 진행할 수단도 없다.

목표: 순차 흐름 안에서 지정한 시간, 또는 조건식이 참이 될 때까지 기다린 뒤 다음 batch로 진행한다. 액션을 가진 scope가 사라지면 남은 흐름은 실행하지 않는다.
판정 기준: 08절 수용 조건 전부 통과.

## 03. 범위와 비범위

포함: `wait` 명령과 `duration` 파라미터, 조건 대기 `until` + `timeout`, 소유 scope 소멸 시 취소, `wait_v1` 기능 선언, `docs/commands/wait.md`, CHANGELOG 항목.

비범위: 반복 타이머·interval, 절대 시각까지 대기, 애니메이션이 끝날 때까지 대기(엔진에 애니메이션 완료 신호가 없음), 다른 화면에 가려졌을 때 일시정지, 진행 중인 wait를 끊는 별도 명령.

관련: 기획 [00-overview](../../planning/text-interaction-motion/00-overview.md) D6. 같은 영역 [02-progress-stroke-cap.md](02-progress-stroke-cap.md).

## 04. 사용자와 사용 시나리오

- 템플릿 작성자: 서버 템플릿에 액션 흐름을 적는 사람.
- 대표 흐름 — 받기 버튼: 로딩 → 완료 체크 1.5초 → 원래 버튼.

```yaml
_requires: [wait_v1]
_scope:
  _state: { phase: idle }
  _action:
    claim:
      - { _type: set, phase: loading }
      - _type: net
        # 요청 파라미터 생략
        _then:
          - { _type: set, phase: done }
          - { _type: wait, duration: 1500 }
          - { _type: set, phase: idle }
```

- 대표 흐름 — 조건 대기: 업로드 진행률(`progress`, 다른 액션이 갱신)이 1이 되면 완료 단계로 넘어간다. 10초 안에 안 되면 실패 단계로 간다.

```yaml
- _type: wait
  until: '${progress >= 1}'
  timeout: 10000
  _error:
    WAIT_TIMEOUT:
      - { _type: set, phase: failed }
- { _type: set, phase: done }
```

## 05. 정책·가정·제약

- 근거(소스 확인, 0.25.0): `lib/src/runtime/wrapper/scope/action_host.dart`의 `_runFlow`는 batch마다 소유 scope 소멸 여부를 확인하고 멈춘다. `_always`도 소멸 뒤에는 실행하지 않는다. `DriverContext.onOwnerDispose`로 소멸 시 정리 작업을 등록할 수 있다.
- 근거(소스 확인, 0.25.0): 컴파일된 식(`lib/src/ir/expression.dart`)은 읽는 바인딩 이름(`roots`)을 기록한다. `Environment.listen(keys)`는 그 이름의 상태가 바뀔 때 알린다. 화면의 반응형 갱신이 이미 이 경로를 쓴다. `DriverContext`는 패키지 공개 API(`lib/sdui_engine.dart`)로 내보내지 않는 내부 타입이다.
- 확정 결정: D6 — `wait` 도중 화면을 떠나거나 액션을 가진 위젯이 사라지면 남은 흐름을 취소한다.
- 해석(R-1, 승인 2026-11-09 [ADR-0008](decisions/0008-cancel-on-owner-scope-disposal.md)): "화면을 떠나면"은 액션을 정의한 scope가 소멸할 때로 본다. 다른 화면을 push해 덮은 경우 scope는 살아 있으므로 wait는 계속되고 이후 명령도 실행된다.
- 제약: 대기는 Dart 타이머 기준이다. 이벤트 루프·프레임 지연만큼 늦을 수 있고, 앱이 백그라운드일 때 OS가 타이머를 늦출 수 있다. ms 단위 정확도는 보장하지 않는다.
- 기기의 «동작 줄이기» 설정은 `wait`에 영향을 주지 않는다. 애니메이션이 아니라 흐름 제어다.

## 06. 요구사항 목록

| ID | 요구사항 요약 | 상세 위치 | 근거 | 수용 조건 |
|---|---|---|---|---|
| WAIT-R1 | `wait`는 `duration` ms만큼 기다린 뒤 성공으로 끝나고, 같은 흐름의 다음 batch가 이어진다 | 07.1 | 02 목표 | AC1, AC2 |
| WAIT-R2 | `duration`은 식으로 바인딩할 수 있다 | 07.1 | 엔진 공통 파라미터 규칙 | AC3 |
| WAIT-R3 | `duration`이 잘못된 값이면 0으로 보고 기다리지 않고 끝난다. 숫자 문자열은 숫자로 읽는다 | 07.2 | 엔진의 잘못된 값 정책(P-2) | AC4, AC5, AC6, AC7 |
| WAIT-R4 | 기다리는 도중(시간·조건 대기 모두) 소유 scope가 소멸하면 wait는 즉시 끝나고, 이후 batch·`_then`·`_always`는 실행되지 않으며 남은 타이머가 없다 | 07.3 | D6 | AC8, AC9 |
| WAIT-R5 | 동시 batch 안의 `wait`는 그 batch를 `duration`만큼 붙잡고, 같은 batch의 다른 명령은 막지 않는다 | 07.1 | 기존 batch 의미 | AC10 |
| WAIT-R6 | `wait`를 쓰는 템플릿이 `_requires`에 `wait_v1`을 선언하지 않으면 컴파일 오류다 | 07.5 | 기존 기능 선언 규칙(P-3) | AC11, AC12 |
| WAIT-R7 | `wait`의 결과 `$data`는 null이다 | 07.1 | 다른 흐름 제어 명령(`set`)과 같음 | AC13 |
| WAIT-R8 | `until` 조건식이 참이 되면 wait가 끝나고 다음 batch가 이어진다. 조건은 식이 읽는 상태가 바뀔 때마다 다시 평가한다 | 07.4 | 사용자 요청 | AC15, AC16 |
| WAIT-R9 | 시작할 때 이미 `until`이 참이면 기다리지 않고 끝난다 | 07.4 | 사용자 요청 | AC17 |
| WAIT-R10 | `timeout` ms 안에 `until`이 참이 되지 않으면 오류 코드 `WAIT_TIMEOUT`으로 끝나 `_error` 흐름을 탄다. 그 뒤 흐름은 다른 명령 실패와 같다(`_then`은 건너뛰고 다음 batch는 이어진다) | 07.4 | P-7, ADR-0011 | AC18, AC19 |
| WAIT-R11 | `until`에 `timeout`이 없거나, `duration`과 `until`을 함께 쓰면 컴파일 오류다 | 07.4 | P-6, P-8 | AC20, AC21 |
| WAIT-R12 | `until` 식 평가가 실패하면 오류 관측기로 보고하고 거짓으로 보아 계속 기다린다 | 07.4 | `_when` 평가 오류 보고 관례 | AC22 |

## 07. 기능 상세

### 07.1 정상 흐름

| 파라미터 | 타입 | 범위 | 기본값 | 바인딩 | 설명 |
|---|---|---|---|---|---|
| `duration` | number(ms) 또는 숫자 문자열 | 0–1,000,000 | 없음(없으면 07.2에 따라 0) | 가능 | 기다릴 시간. 소수는 반올림한다 |

- 다른 키는 무시한다. 공통 메타데이터(`_when`, `_then`, `_error`, `_always`, `_dismiss`, `_background`)는 다른 명령과 같다.
- 결과 `$data`는 null이다.
- 동시 batch(`[[...]]`) 안에서는 batch가 가장 늦게 끝나는 명령을 기다리는 기존 규칙대로 동작한다.
- `_background: true`는 허용하지만 흐름을 막지 않으므로 효과가 없다.
- 실패 경로가 없으므로 `_error`는 실행되지 않는다.

### 07.2 잘못된 값

다음은 모두 0으로 보고 기다리지 않는다: 없음, null, 음수, 1,000,000 초과, 숫자로 읽을 수 없는 문자열, bool·list·map.
debug 빌드는 잘못된 값이 쓰일 때마다(실행마다) 한 줄 로그를 남긴다. 오류 관측기(`SduiErrorObserver`)로 보고하지 않는다.

### 07.3 소멸 시 취소

- `wait`는 `onOwnerDispose`에 타이머 취소를 등록한다. 소유 scope가 소멸하면 타이머를 취소하고 wait를 즉시 끝낸다. 그래서 액션이 대기 상태로 붙잡히지 않는다(중복 실행 방지 창도 닫힌다).
- 소멸 뒤 이후 batch·`_then`·`_always`가 실행되지 않는 것은 기존 `_runFlow` 규칙이다.
- 정상 종료 시 등록한 정리 작업은 해제한다.

### 07.4 조건 대기

| 파라미터 | 타입 | 범위 | 기본값 | 바인딩 | 설명 |
|---|---|---|---|---|---|
| `until` | 식 문자열 `'${…}'` | — | 없음 | 식 자체 | 참이 될 때까지 기다릴 조건. 한 번 계산하고 끝나는 다른 파라미터와 달리, 식을 그대로 보관해 읽는 상태가 바뀔 때마다 다시 평가한다 |
| `timeout` | number(ms) 또는 숫자 문자열 | 1–1,000,000 | 없음(`until`이 있으면 필수) | 가능(시작할 때 한 번 계산) | 최대 대기 시간 |

- 평가 시점: 시작할 때 한 번, 그 뒤 식이 읽는 상태(`$data`·`$event` 포함, 바깥 scope 상태 포함)가 바뀔 때마다. 프레임마다 평가하지 않는다.
- 참 판정은 템플릿 진리값 규칙(`docs/expressions.md` «Truthiness»)을 따른다.
- 시간이 초과되면 `DriverError('WAIT_TIMEOUT')`로 끝난다. `_error`에 `WAIT_TIMEOUT` 또는 `_` 분기가 있으면 그 흐름을 탄다. 분기가 없으면 기존 규칙대로 오류 관측기로 보고한다. 어느 경우든 `wait`의 `_then`은 실행하지 않고, 같은 흐름의 다음 batch는 다른 명령이 실패했을 때처럼 이어진다([ADR-0011](decisions/0011-timeout-follows-failure-flow.md)). 성공했을 때만 할 일은 `wait`의 `_then`에 둔다.
- 실행 중 `timeout` 값이 잘못되면(0 이하, 상한 초과, 숫자 아님) 07.2처럼 0으로 보아 곧바로 시간 초과로 끝난다.
- `until`이 참이 되거나 시간이 초과되거나 소유 scope가 소멸하면 상태 감시와 타이머를 모두 해제한다.
- 컴파일 오류: `until`이 있는데 `timeout`이 없음, `duration`과 `until`을 함께 씀, `until`이 식 문자열이 아님.

### 07.5 기능 선언

- `wait_v1`을 `knownFeatures`에 추가한다.
- 템플릿에 `wait` 명령이 있는데 `_requires`에 `wait_v1`이 없으면 컴파일 오류다. 메시지: `"wait" needs "wait_v1" in "_requires".` `anchored_overlay_v1`의 강제 확인과 같은 방식이다.
- 0.25.0 이하 엔진은 `wait_v1`을 모르는 기능으로, `wait`를 모르는 명령으로 거부하므로 서버가 앱 버전으로 거를 수 있다.

## 08. 수용 조건

| ID | 요구사항 ID | 조건 Given | 행동 When | 기대 결과 Then | 테스트 (층위) | 상태 |
|---|---|---|---|---|---|---|
| AC1 | WAIT-R1 | 흐름 `[wait duration 1500, set x: 1]`, x=0 | 액션 실행 후 1499ms, 1500ms 경과 | 1499ms에 x=0, 1500ms에 x=1 | `wait_driver_test: waits duration then continues` (액션 호스트, fake_async) | 미실행 |
| AC2 | WAIT-R1 | 흐름 `[wait duration 0, set x: 1]` | 액션 실행 | 시간 경과 없이 x=1 | `wait_driver_test: zero duration continues at once` | 미실행 |
| AC3 | WAIT-R2 | state d=300, `duration: '${d}'` 다음 `set x: 1` | 실행 후 300ms 경과 | 299ms에 x=0, 300ms에 x=1 | `wait_driver_test: bound duration` | 미실행 |
| AC4 | WAIT-R3 | `duration: -5` 다음 `set x: 1` | 실행 | 시간 경과 없이 x=1, 오류 관측기 보고 없음 | `wait_driver_test: negative duration waits zero` | 미실행 |
| AC5 | WAIT-R3 | `duration: 'abc'` 다음 `set x: 1` | 실행 | 시간 경과 없이 x=1 | `wait_driver_test: non-numeric duration waits zero` | 미실행 |
| AC6 | WAIT-R3 | `duration: 2000000` 다음 `set x: 1` | 실행 | 시간 경과 없이 x=1 | `wait_driver_test: over-limit duration waits zero` | 미실행 |
| AC7 | WAIT-R3 | `duration: '250'` 다음 `set x: 1` | 실행 후 250ms 경과 | 249ms에 x=0, 250ms에 x=1 | `wait_driver_test: numeric string duration` | 미실행 |
| AC8 | WAIT-R4 | `[wait duration 1000, set x: 1]` | 실행 400ms 뒤 scope 소멸, 이후 1000ms 더 경과 | x는 끝까지 0, 액션 future가 소멸 시점에 완료, 남은 타이머 0개 | `wait_driver_test: owner dispose cancels remaining flow` | 미실행 |
| AC9 | WAIT-R4 | `wait duration 1000`에 `_always: set y: 1` | 실행 400ms 뒤 scope 소멸 | y는 0 | `wait_driver_test: owner dispose skips always` | 미실행 |
| AC10 | WAIT-R5 | `[[wait duration 300, set a: 1]], set b: 1` | 실행 | a=1은 즉시, b=1은 300ms에 | `wait_driver_test: concurrent batch` | 미실행 |
| AC11 | WAIT-R6 | `wait`를 쓰고 `_requires` 없음 | 컴파일 | `InvalidTemplateException`, 메시지에 `wait_v1` | `template_compiler_test: wait needs wait_v1` (컴파일러) | 미실행 |
| AC12 | WAIT-R6 | `wait`를 쓰고 `_requires: [wait_v1]` | 컴파일 | 성공 | `template_compiler_test: wait_v1 accepted` (컴파일러) | 미실행 |
| AC13 | WAIT-R7 | `wait duration 0`의 `_then: set r: '${data}'`, r='x' | 실행 | r=null | `wait_driver_test: data is null` | 미실행 |
| AC14 | WAIT-R4 | 대기 중 다른 route를 push(소유 scope 유지) | 1500ms 경과 | 다음 batch 실행됨 | `wait_driver_test: covered route keeps waiting` (위젯) | 미실행 |
| AC15 | WAIT-R8 | state p=0, `[wait until '${p >= 1}' timeout 5000, set x: 1]` | 실행 후 200ms에 다른 액션이 p=1로 commit | commit 직후 x=1, 타이머·감시 해제 | `wait_driver_test: until resolves on state change` | 미실행 |
| AC16 | WAIT-R8 | AC15와 같음 | 다른 액션이 p=0.5로 commit | x=0 유지, 계속 대기 | `wait_driver_test: until ignores unmet change` | 미실행 |
| AC17 | WAIT-R9 | state p=1, `[wait until '${p >= 1}' timeout 5000, set x: 1]` | 실행 | 시간 경과 없이 x=1 | `wait_driver_test: until already true` | 미실행 |
| AC18 | WAIT-R10 | p=0, `wait until '${p >= 1}' timeout 300`에 `_then: [set t: 1]`, `_error: { WAIT_TIMEOUT: [set f: 1] }`, 다음 batch `set x: 1` | 300ms 경과 | f=1, t=0, x=1 | `wait_driver_test: timeout runs error branch` | 미실행 |
| AC19 | WAIT-R10 | AC18에서 `_error` 없음 | 300ms 경과 | 오류 관측기에 `WAIT_TIMEOUT` 1건, t=0, x=1 | `wait_driver_test: unhandled timeout reported` | 미실행 |
| AC20 | WAIT-R11 | `wait until '${p}'`, `timeout` 없음 | 컴파일 | `InvalidTemplateException` | `template_compiler_test: until needs timeout` (컴파일러) | 미실행 |
| AC21 | WAIT-R11 | `wait duration 100 until '${p}' timeout 500` | 컴파일 | `InvalidTemplateException` | `template_compiler_test: duration and until exclusive` (컴파일러) | 미실행 |
| AC22 | WAIT-R12 | 평가 중 예외를 던지는 앱 함수를 쓴 `until`(테스트용 함수 등록), timeout 300 | 실행, 300ms 경과 | 오류 관측기 보고 1건 이상, 대기 계속 후 `WAIT_TIMEOUT` | `wait_driver_test: until evaluation error counts false` | 미실행 |

## 09. 비기능 요구사항과 관측

- 실행 중인 `wait`마다 타이머는 하나, 조건 대기는 상태 감시 하나를 더 가진다. 끝나거나 소멸한 뒤 남는 타이머·감시는 없다(AC8, AC15로 확인).
- 조건은 상태가 바뀔 때만 평가한다. 프레임마다 평가하지 않는다.
- debug 로그: 잘못된 `duration` 한 줄(07.2). 측정 텔레메트리 대상(`measured`)이 아니다.
- 성능 목표 수치는 두지 않는다. 대기 자체가 목적이다.

## 10. 구현 계획

| 작업 | 위치 | 요구사항 |
|---|---|---|
| `WaitDriver` 추가(`type: wait`, 타이머 + `onOwnerDispose`) | `lib/src/runtime/driver/wait_driver.dart` | R1–R5, R7 |
| `until`을 계산하지 않고 식으로 보관해 드라이버에 넘기기, 상태 감시 | `lib/src/compile/compiler/action_compiler.dart`, `lib/src/ir/model/action/command.dart`, `lib/src/runtime/driver/_base.dart`(`DriverContext`에 식 감시 기능, 내부 타입이라 공개 API 변화 없음 — P-9), `lib/src/runtime/wrapper/scope/action_host.dart` | R8–R12 |
| 내장 명령 등록 | `lib/src/compile/schema/builtin_language.dart` `commands`, 드라이버 레지스트리 | R1 |
| `wait_v1` 기능과 컴파일 확인 | `lib/src/compile/compiler/template_compiler.dart` | R6 |
| 문서 | `docs/commands/wait.md`, `docs/actions.md` 링크 | 전체 |
| CHANGELOG, 버전 | `CHANGELOG.md`, `pubspec.yaml` 0.26.0(TIM-02와 함께) | 전체 |
| 테스트 | `test/src/runtime/driver/wait_driver_test.dart`, 컴파일러 테스트 | AC1–AC22 |

명세는 2026-11-09 승인됐다. 구현 착수는 별도 지시로 한다.

## 11. 검증 결과와 출시 판정

| 검사 | 결과 | 증거 / 미실행 이유 |
|---|---|---|
| 문서 링크·ID 검사 | 작성 시 실행 | 메인 세션 스크립트 |
| 기능 테스트 | 미실행 | 구현 전 |

판정: 명세 승인(2026-11-09)·미구현.

## 12. 미결정 사항과 변경 이력

| ID | 질문 | 제안 | 영향받는 요구사항 | 결정 담당 / 시점 |
|---|---|---|---|---|
| P-1 | 명령·파라미터 이름 | `wait` / `duration`(ms). `_motion`의 `duration`, `scroll`의 `duration`과 같은 단위 | R1, R2 | 승인 2026-11-09, [ADR-0001](decisions/0001-wait-command-name.md) |
| P-2 | 잘못된 `duration` 처리 | 0으로 보고 즉시 진행(오류 아님). 모션·morph의 잘못된 값 정책과 같다 | R3 | 승인 2026-11-09, [ADR-0002](decisions/0002-invalid-duration-zero.md) |
| P-3 | 기능 선언 방식 | `wait_v1` 강제 확인(새 이름 기능의 기존 방식) | R6 | 승인 2026-11-09, [ADR-0003](decisions/0003-wait-v1-enforced.md) |
| P-6 | `until`의 `timeout`을 필수로 할지 | 필수(없으면 컴파일 오류). 조건이 끝내 맞지 않으면 흐름이 영영 멈추기 때문. 기본값을 두려면 값을 정해야 하는데 근거가 없다 | R11 | 승인 2026-11-09, [ADR-0004](decisions/0004-until-requires-timeout.md) |
| P-7 | 시간 초과 처리 | 오류 코드 `WAIT_TIMEOUT`으로 `_error` 흐름. 다른 안: 성공으로 보고 `$data: { timed_out: true }`로 계속 | R10 | 승인 2026-11-09, [ADR-0005](decisions/0005-until-timeout-error.md). 흐름 중단 부분은 [ADR-0011](decisions/0011-timeout-follows-failure-flow.md)로 대체 |
| P-8 | `duration`과 `until`을 함께 쓰는 경우 | 컴파일 오류(둘 중 하나만). 다른 안: `duration`을 최소 대기 시간으로 보고 그 뒤 `until` 확인 | R11 | 승인 2026-11-09, [ADR-0006](decisions/0006-duration-until-exclusive.md) |
| P-9 | `until`을 식으로 넘기는 방법 | 엔진 내부 타입 `DriverContext`에 식 감시 기능을 더한다. 공개 API·앱 등록 명령(`external`)에는 영향 없음 | R8 | 승인 2026-11-09, [ADR-0007](decisions/0007-until-expression-watch.md) |
| R-1 | "화면을 떠나면"의 뜻 | 소유 scope 소멸로 본다. push로 덮인 동안은 계속 | R4, AC14 | 승인 2026-11-09, [ADR-0008](decisions/0008-cancel-on-owner-scope-disposal.md) |

변경 이력: 0.1(2026-11-09) 신규 작성. 0.2(2026-11-09) 사용자 요청으로 조건 대기 `until` + `timeout` 추가(WAIT-R8–R12, AC15–AC22, P-6–P-9). 승인(2026-11-09): P-1, P-2, P-3, P-6, P-7, P-8, P-9, R-1 제안대로. 0.3(2026-11-09) 구조 검토에서 기존 엔진은 명령 실패 뒤에도 다음 batch를 이어 실행함을 확인(`action_host.dart` `_runFlow`·`_runCommand`). 사용자 결정으로 시간 초과도 같은 규칙을 따르게 07.4 · WAIT-R10 · AC18 · AC19를 고침(ADR-0011). 0.4(2026-11-09) 07.2 debug 로그를 "노드·이유별 한 줄"에서 "실행마다 한 줄"로 고침(사용자 결정, 구현과 일치).

## 13. 참고 기준

- sdui_engine 0.25.0 소스(2026-11-09 확인): `lib/src/runtime/wrapper/scope/action_host.dart`, `lib/src/runtime/driver/_base.dart`, `lib/src/compile/compiler/template_compiler.dart`, `lib/src/compile/schema/builtin_language.dart`.
- 엔진 문서: `docs/actions.md`, `docs/motion.md`(값 상한 1,000,000), `docs/expressions.md`(진리값), `docs/state.md`(식이 읽는 이름만 감시).
- 소스(조건 대기 근거): `lib/src/ir/expression.dart`, `lib/src/runtime/environment/_base.dart`, `lib/src/runtime/environment/scope/scope_environment.dart`, `lib/sdui_engine.dart`(공개 export 확인).
