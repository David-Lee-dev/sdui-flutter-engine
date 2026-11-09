# ADR-0010 · `stroke_cap` 허용 값

- 상태: 승인 2026-11-09(사용자)
- 출처: 명세 제안 P-5
- 관련: TIM-02 CAP-R1, CAP-R3

## 맥락

끝 모양 값 목록이 필요하다.

## 결정

`butt`, `round`, `square`(Flutter `StrokeCap` 그대로). 그 밖의 값은 Flutter 기본 모양.

## 근거

Flutter 값과 1:1로 대응해 설명이 쉽다.
