---
title: 관리자 대표 방 검증 상태 요약
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
last_updated: 2026-04-06
last_verified: 2026-04-06
---

# 관리자 대표 방 검증 상태 요약

## 이번 증분에서 잠근 내용

- 관리자 `Resources` 탭은 이제 현재 선택된 대표 방의 서사 검증 상태를 `Verification Status` 한 줄로 요약한다.
- 이 상태는 `Room Note`, `Path Note`, `Clue Check`보다 상위에서 현재 방이 `스캐폴드만 잠겼는지`, `부분 잠금인지`, `완전 잠금인지`를 빠르게 읽게 하기 위한 것이다.

## 현재 상태 기준

- `entrance`
  - 암시형 환경 역할 잠김
- `seal_sanctum`
  - 허브 구조는 잠겼고, 봉인상 앵커 여부에 따라 최종 확인 상태가 갈린다
- `gate_threshold`
  - 생존자 경고/혈통 떡밥 2개 기준으로 부분/완전 잠금이 갈린다
- `royal_inner_hall`
  - 전조/기록 2개 기준으로 부분/완전 잠금이 갈린다
- `throne_approach`
  - 전조/칙령 2개 기준으로 부분/완전 잠금이 갈린다
- `inverted_spire`
  - 계약 제단 기록 확인 여부로 최종 잠금이 갈린다

## 보류 유지

- 직접 조우, 컷신, 보스전 페이즈 연출은 여전히 사용자 결정이 필요한 범위로 남긴다.
- 이번 증분은 이미 잠긴 환경 단서를 관리자 검증 상태 요약으로 압축하는 범위까지만 다룬다.
