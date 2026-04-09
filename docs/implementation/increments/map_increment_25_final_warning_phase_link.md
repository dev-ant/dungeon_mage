---
title: 최심층 경고 단계 연동
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

# 최심층 경고 단계 연동

## 이번 증분에서 잠근 내용

- `inverted_spire`의 차단 경고는 이제 단순히 `제단 확인 전/후`만 보지 않는다.
- 이미 잠긴 `Threshold / Companion / Final` 진행 상태를 최심층 경고 문구에 반영한다.
- 직접 조우, 컷신, 보스전 페이즈 연출 없이도 플레이어가 어디까지 진실을 읽었는지 최종전 문턱에서 다시 확인할 수 있어야 한다.
- 현재 `Final Warning Preview`와 `Phase Cross-Check`의 source of truth는 `GameState.get_final_warning_preview_summary()`와 `GameState.get_phase_cross_check_summary()`다.

## 현재 경고 해석

- `Threshold`만 잠긴 상태:
  - 게이트가 혈통을 골랐다는 사실이 최심층 경고에 반영된다.
- `Companion`까지 잠긴 상태:
  - 게이트, 내성, 왕좌 접근이 하나의 의도로 이어졌다는 해석이 최심층 경고에 반영된다.
- `Final`까지 잠긴 상태:
  - 계약 제단 확인 후 경고는 기존 전투 시작 문구를 유지하되, 이미 확인한 단서를 더 직접적으로 묶어서 말한다.

## 구현 변경

- [main.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/main/main.gd)
  - `inverted_spire` 차단 문구를 `GameState.get_final_warning_preview_summary()` 기반 phase-aware 경로로 정리
- [admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
  - `Final Warning Preview` 상태를 `altar unread / threshold marked / companion marked / warning primed`로 확장하고, `Phase Cross-Check`도 중앙 summary를 소비하도록 정리

## 보류 유지

- 친구 B 직접 등장
- 생존자 NPC 직접 등장
- 보스전 페이즈별 고정 연출

위 항목은 여전히 사용자 결정이 필요한 범위이므로 이번 증분에서도 스킵한다.
