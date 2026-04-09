---
title: 관리자 대표 방 단서 체크
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 관리자 대표 방 단서 체크

## 이번 증분에서 잠근 내용

- 관리자 `Resources` 탭은 이제 현재 선택된 대표 방에서 확인 가능한 핵심 단서를 `Clue Check`로 표시한다.
- 이 체크는 `Room Note`와 `Path Note`가 설명하는 역할과 연결이 실제로 어떤 룸 단서에 의해 잠기는지 빠르게 검증하기 위한 것이다.
- 현재 `Clue Check`의 source of truth는 `GameState.get_room_clue_check_summary()`이며, 관리자 메뉴는 그 결과를 그대로 렌더링한다.

## 현재 체크 범위

- `6F seal_sanctum`
  - 봉인상 앵커
  - 허브 공지판 반응
- `7F gate_threshold`
  - 생존자 경고
  - 혈통 떡밥
- `8F royal_inner_hall`
  - 친구 B 전조
  - 지워진 가계/생활 기록
- `9F throne_approach`
  - 친구 B 전조
  - 공포 칙령
- `10F inverted_spire`
  - 계약 제단 기록
  - 최심층 경고 단계 연동

## 보류 유지

- 직접 조우, 컷신, 보스전 페이즈 연출은 여전히 사용자 결정이 필요한 범위로 남긴다.
- 이번 증분은 이미 잠긴 환경 단서를 관리자 검증 체크리스트로 재표현하는 범위까지만 다룬다.
