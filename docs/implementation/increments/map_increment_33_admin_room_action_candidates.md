---
title: 관리자 대표 방 액션 후보
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

# 관리자 대표 방 액션 후보

## 이번 증분에서 잠근 내용

- 관리자 `Resources` 탭은 이제 현재 선택된 대표 방에 대해 바로 수행 가능한 `Action Candidate`를 표시한다.
- 이 후보는 `Next Priority`를 실제 작업 문장으로 바꾼 것으로, 사용자 결정이 필요한 컷신/직접 조우/보스 페이즈 연출은 의도적으로 제외한다.

## 액션 후보 원칙

- 미확인 단서가 남아 있으면:
  - 그 단서를 구현하거나 검증하는 액션을 먼저 제안한다
- 단서가 모두 잠겼으면:
  - downstream reaction, admin preview polish, payoff polish 같은 안전 작업을 제안한다
- 직접 조우/컷신이 필요한 작업은:
  - 이번 후보군에 포함하지 않는다
