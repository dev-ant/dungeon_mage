---
title: 관리자 대표 방 payoff density
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

# 관리자 대표 방 payoff density

## 이번 증분에서 잠근 내용

- 관리자 `Resources` 탭은 이제 현재 선택된 대표 방의 반응형 공간 요소 밀도를 `Payoff Density`로 요약한다.
- 이 밀도는 `board`, `echo repeat payoff`, `gate line` 같은 반응형 surface 개수를 바탕으로 `none / light / medium / dense`로 읽힌다.

## 의도

- 어떤 대표 방은 이미 반응형 공간 payoff가 충분하고, 어떤 방은 아직 얇은지 한 줄로 빠르게 판단할 수 있어야 한다.
- 따라서 이후 구현은 개별 reaction 추가뿐 아니라, 방 전체 payoff 밀도 균형도 함께 고려하는 방향으로 이어간다.
