# 조사 — 모던 UI 애니메이션 분류와 엔진 0.25.0 기준 가능 여부

조사일 2026-11-09. 근거: `docs/motion.md`, `docs/control-flow.md`, `docs/interaction.md`, `docs/expressions.md`, `docs/actions.md`, `docs/widgets/**`, `lib/src/runtime/motion/**`, `lib/src/runtime/wrapper/scope/morph_scope.dart`.
문서와 소스를 읽고 판단했다. 기기에서 실행해 확인한 것은 아니다.

## 엔진이 이미 가진 것

- `_motion` 원자 9종(fade, move, scale, rotate, blur, tint, reveal, saturate, shimmer)과 프리셋 30여 종. 반복 횟수, 반복 사이 대기.
- 곡선: Material 3 easing, cubic bezier, spring 곡선, 구간별 곡선(`curve_segments_v1`).
- `_morph`: tween · spring 값 보간, `_velocity`, `_trigger` 재시작.
- `_presence`: 구조 변화 때 크기 애니메이션, exit 모션, 크로스페이드, `exit_delay`.
- `pressed_as`(누르는 동안 true), 페이지 전환 10종, SDF `shape`, 스켈레톤, 햅틱 패턴.
- `loading_indicator`(스피너 21종), `circular_progress_indicator`(`value` 바인딩 가능).

## 분류별 판단

| 분류 | 예 | 지금 가능? | 방법 또는 빠진 것 |
|---|---|---|---|
| 진입 시차 | 카드 순서대로 등장 | 가능 | `delay: ${index*N}` |
| 누르면 눌림 | 스프링 복귀 | 가능 | `pressed_as` + `_morph _spring` |
| 체크 후 복귀 | 복사 → ✓ → 복사 | 가능 | `trigger` + 구간별 곡선(마지막 `to: 0`) |
| 아이콘 교체 팝 | ♡ → ♥ | 가능 | `switch` + `_presence` + `pop_in` |
| 숫자 카운트업 | 0 → 12,340 | 가능(번거로움) | `_morph` + `comma(round(v))` → A2 `count`로 프리셋화 |
| 타자기 | 한 글자씩 | 가능(번거로움) | `_morph` + `rich_text` 앞 span/투명 span → A1 `typewriter`로 프리셋화 |
| 텍스트 빛 훑기 | 하이라이트 sweep | 가능 | `shimmer` 원자가 글자 모양 안쪽만 칠함 |
| 탭 인디케이터 이동 | 스프링 슬라이드 | 가능 | `_morph _spring` |
| 진입·퇴장 | 배너 넣고 빼기 | 가능 | `_presence` + `on: exit` |
| 오류 흔들기 | 입력 오류 | 가능 | `shake` + `repeat` 횟수 |
| 진행 링 | 72%까지 차오름 | 가능 | `circular_progress_indicator` + `_morph`. 끝 모양만 각짐 → B3 |
| 버튼 상태 시퀀스 | 로딩 → 체크 → 복귀 | 대부분 가능 | 단계 전환은 가능. 자동 복귀 대기가 없음 → B2 |
| 글자별 상승·블러·scramble | 헤드라인 연출 | 불가 | `_loop`로 글자마다 위젯을 만들면 자간·줄바꿈·이모지가 깨짐 → A1 |
| 슬롯머신 숫자 | 자릿수 굴림 | 불가(실용적으로) | → A2 `roll` |
| 선 그리기 | ✓가 그려짐 | 불가 | `shape`는 면만 칠함 → B1 |
| Lottie · 파티클 | 하트 버스트 | 불가 | 범위 제외 |

## 구현 방향 메모

- A1: 문단을 한 번 배치하고 grapheme별 위치를 구한 뒤 단위마다 투명도 · 이동 · 크기 · 블러를 그린다. 투명도 · 색만 쓰는 효과(타자기, 페이드, scramble)는 span 분할로도 되므로 위험이 낮다.
- A2: 이전 값을 기억하고 새 값으로 보간한다. `roll`은 자릿수마다 0–9 띠를 잘라 보이고 이동한다. 자릿수가 늘거나 줄 때의 정렬은 명세에서 정한다.
- B1: `PathMetric.extractPath`로 경로 일부를 그린다.
- B2: 순차 batch 안에서만 의미가 있다. 소유 위젯이 사라지면 흐름 수명 규칙을 따른다.

데모(브라우저 시연): https://claude.ai/artifact/3ikbWAFLJwH5RFiQ9U5xXu
