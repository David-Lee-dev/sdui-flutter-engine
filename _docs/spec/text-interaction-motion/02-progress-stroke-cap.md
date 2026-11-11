# TIM-02 · 진행 링 끝 모양 `stroke_cap`

> 문서 규격: SDD 0.1 · 상태: 승인(구현 전) · 확정 결정과 이 명세의 제안(P-)을 구분한다.

## 01. 문서 관리

| 항목 | 내용 |
|---|---|
| 문서 ID / 버전 | TIM-02 / 0.1 |
| 최종 갱신 | 2026-11-09 |
| 책임자 / 검토자 | 미지정 |
| 승인 상태 | 승인 2026-11-09(사용자). P-4, P-5 모두 제안대로 승인. 구현 전 |
| 변경 범위 | `circular_progress_indicator`에 속성 `stroke_cap` 추가, `_requires` 기능 `progress_stroke_cap_v1` |

## 02. 문제와 목표

진행 링은 `circular_progress_indicator`의 `value`를 `_morph`로 움직여 이미 만들 수 있다. 그런데 선 끝 모양을 정할 수 없어 끝이 각지게 그려지고, 모던 UI에서 흔한 둥근 끝 링을 만들 수 없다.

목표: 템플릿이 선 끝 모양을 고를 수 있다. 지정하지 않은 템플릿은 지금과 똑같이 그려진다.
판정 기준: 08절 수용 조건 전부 통과.

## 03. 범위와 비범위

포함: `circular_progress_indicator`의 `stroke_cap` 속성, 기능 선언, 위젯 문서, CHANGELOG.

비범위: `linear_progress_indicator`의 끝 모양, 시작 각도 변경, 트랙 간격 등 다른 Flutter 진행 표시 옵션.

관련: 기획 [00-overview](../../planning/text-interaction-motion/00-overview.md) B3. 같은 영역 [01-wait-command.md](01-wait-command.md).

## 04. 사용자와 사용 시나리오

- 템플릿 작성자: 오늘 목표 72%처럼 차오르는 링을 만드는 사람.

```yaml
_requires: [progress_stroke_cap_v1]
_type: stack
_children:
  - _type: circular_progress_indicator
    _morph: { _from: 0, _to: 0.72, _as: v, _duration: 1200 }
    value: '${v}'
    stroke_width: 9
    stroke_cap: round
  - { _type: text, value: '${round(v * 100)}%' }
```

## 05. 정책·가정·제약

- 근거(소스 확인, 0.25.0): `lib/src/runtime/widget/catalog/primitive/circular_progress_indicator_widget.dart`는 `value`, `color`, `background_color`, `stroke_width`만 넘긴다. 위젯 스키마에 속성 목록이 없어 이전 엔진은 모르는 속성을 무시한다.
- Flutter 3.38 `CircularProgressIndicator`는 `strokeCap`(`StrokeCap?`)을 받는다. null이면 Flutter 기본 끝 모양을 쓴다.
- 기존 enum 값 처리 관례(`box_shadow` `blur_style`, 0.23.0): 모르는 값은 기본값으로 돌아가고 오류를 내지 않는다.

## 06. 요구사항 목록

| ID | 요구사항 요약 | 상세 위치 | 근거 | 수용 조건 |
|---|---|---|---|---|
| CAP-R1 | `stroke_cap`은 `butt` · `round` · `square`를 받아 Flutter `StrokeCap`의 같은 값으로 그린다 | 07.1 | 02 목표 | AC1, AC2, AC3 |
| CAP-R2 | `stroke_cap`은 식으로 바인딩할 수 있다 | 07.1 | 엔진 공통 속성 규칙 | AC4 |
| CAP-R3 | 없거나 모르는 값이면 `strokeCap`을 넘기지 않아 지금과 같은 모양으로 그린다. 오류를 내지 않는다 | 07.2 | enum 관례 | AC5, AC6 |
| CAP-R4 | `progress_stroke_cap_v1`은 선언만 하는 기능이다. 선언하지 않고 `stroke_cap`을 써도 컴파일된다 | 07.3 | `box_shadow_blur_style_v1` 관례(P-4) | AC7, AC8 |

## 07. 기능 상세

### 07.1 속성

| 속성 | 타입 | 허용 값 | 기본값 | 바인딩 | 설명 |
|---|---|---|---|---|---|
| `stroke_cap` | string | `butt`, `round`, `square` | 없음(Flutter 기본) | 가능 | 진행 선 양 끝 모양. 값이 있는 링과 값이 없는(무한 회전) 링 모두에 적용 |

### 07.2 잘못된 값

없음·null·모르는 문자열·문자열이 아닌 값은 `strokeCap: null`로 그린다. 보고하지 않는다.

### 07.3 기능 선언

- `progress_stroke_cap_v1`을 `knownFeatures`에 추가한다(선언 전용, 컴파일러가 사용 여부를 확인하지 않는다).
- 0.25.0 이하 엔진은 속성을 무시하고 지금처럼 각진 끝으로 그린다. 끝 모양이 꼭 필요한 템플릿은 `_requires`로 선언해 이전 엔진에서 컴파일 오류가 나게 한다.

## 08. 수용 조건

| ID | 요구사항 ID | 조건 Given | 행동 When | 기대 결과 Then | 테스트 (층위) | 상태 |
|---|---|---|---|---|---|---|
| AC1 | CAP-R1 | `stroke_cap: round`, `value: 0.5` | 렌더 | `CircularProgressIndicator.strokeCap == StrokeCap.round` | `circular_progress_indicator_test: round cap` (위젯) | 미실행 |
| AC2 | CAP-R1 | `stroke_cap: butt` | 렌더 | `strokeCap == StrokeCap.butt` | `circular_progress_indicator_test: butt cap` | 미실행 |
| AC3 | CAP-R1 | `stroke_cap: square`, `value` 없음(무한 회전) | 렌더 | `strokeCap == StrokeCap.square` | `circular_progress_indicator_test: square cap indeterminate` | 미실행 |
| AC4 | CAP-R2 | state cap='round', `stroke_cap: '${cap}'` | 렌더 후 cap='butt'로 변경 | 처음 round, 변경 후 butt | `circular_progress_indicator_test: bound cap` | 미실행 |
| AC5 | CAP-R3 | `stroke_cap: pill` | 렌더 | `strokeCap == null`, 오류 관측기 보고 없음 | `circular_progress_indicator_test: unknown cap falls back` | 미실행 |
| AC6 | CAP-R3 | `stroke_cap` 없음 | 렌더 | `strokeCap == null`(0.25.0과 같은 위젯 설정) | `circular_progress_indicator_test: no cap unchanged` | 미실행 |
| AC7 | CAP-R4 | `stroke_cap: round`, `_requires` 없음 | 컴파일 | 성공 | `template_compiler_test: stroke_cap is declare-only` (컴파일러) | 미실행 |
| AC8 | CAP-R4 | `_requires: [progress_stroke_cap_v1]` | 컴파일 | 성공(알려진 기능) | `template_compiler_test: progress_stroke_cap_v1 known` (컴파일러) | 미실행 |

## 09. 비기능 요구사항과 관측

해당 없음. 속성 하나를 Flutter 위젯에 넘기는 변경이라 성능·관측 영향이 없다.

## 10. 구현 계획

| 작업 | 위치 | 요구사항 |
|---|---|---|
| `stroke_cap` 해석 후 `strokeCap` 전달 | `lib/src/runtime/widget/catalog/primitive/circular_progress_indicator_widget.dart` (필요하면 `PropsResolver`에 해석 함수) | R1–R3 |
| 기능 이름 추가 | `lib/src/compile/compiler/template_compiler.dart` `knownFeatures` | R4 |
| 문서 | `docs/widgets/feedback/circular_progress_indicator.md` | 전체 |
| CHANGELOG, 버전 | 0.26.0(TIM-01과 함께) | 전체 |
| 테스트 | 위젯 테스트, 컴파일러 테스트 | AC1–AC8 |

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
| P-4 | 기능 선언 방식 | `progress_stroke_cap_v1` 선언 전용. 이전 엔진은 속성을 무시할 뿐 깨지지 않으므로 강제하지 않는다 | R4 | 승인 2026-11-09, [ADR-0009](decisions/0009-stroke-cap-declare-only.md) |
| P-5 | 허용 값 | Flutter `StrokeCap`의 세 값 그대로(`butt`, `round`, `square`) | R1 | 승인 2026-11-09, [ADR-0010](decisions/0010-stroke-cap-values.md) |

변경 이력: 0.1(2026-11-09) 신규 작성. 승인(2026-11-09): P-4, P-5 제안대로.

## 13. 참고 기준

- sdui_engine 0.25.0 소스(2026-11-09 확인): `circular_progress_indicator_widget.dart`, `builtin_language.dart`, `template_compiler.dart`.
- Flutter 3.38.9 `packages/flutter/lib/src/material/progress_indicator.dart`(`strokeCap` 인자 확인).
- 엔진 `CHANGELOG.md` 0.23.0 `box_shadow_blur_style_v1`(선언 전용 관례).
