# ADR-0001 · `wait` 명령과 `duration` 파라미터 이름

- 상태: 승인 2026-11-09(사용자)
- 출처: 명세 제안 P-1
- 관련: TIM-01 WAIT-R1, WAIT-R2

## 맥락

액션 흐름에 시간 지연 명령이 없다.

## 결정

명령 이름은 `wait`, 시간 파라미터는 `duration`(ms)이다.

## 근거

`_motion`·`scroll`의 `duration` ms 단위와 같아 배울 것이 적다.
