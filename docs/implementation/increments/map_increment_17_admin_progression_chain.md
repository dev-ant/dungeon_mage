---
title: 맵 17차 작업 체크리스트 - 관리자 진행 체인 요약
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_16_admin_final_warning_preview.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-06
last_verified: 2026-04-06
---

# 맵 17차 작업 체크리스트 - 관리자 진행 체인 요약

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 관리자 메뉴에서 대표 구간 progression chain 전체를 한 줄로 읽을 수 있게 하는 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- `8층 기록`, `9층 칙령`, `10층 계약`, `6층 허브 반응`의 진행 상태를 메뉴에서 즉시 확인할 수 있어야 한다.
- 현재 build가 `환경 상호작용 -> 허브 반응 -> 최종전 경고` 체인을 어디까지 밟았는지 room jump 없이 읽을 수 있어야 한다.
- 미잠금 영역과 이미 잠긴 영역을 디버그 시 빠르게 구분할 수 있어야 한다.

## 수용 기준

- Resources 탭에 대표 구간 progression chain 요약이 보여야 한다.
- 관련 progression flag가 바뀌면 요약도 즉시 갱신되어야 한다.
- 기존 interaction/reactive/final warning preview와 함께 유지되어야 한다.
- admin menu GUT와 headless 실행 검증이 통과해야 한다.

## 파일 터치포인트

- [scripts/admin/admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- [tests/test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)
- [docs/implementation/plans/dungeon_map_prototype_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md)
- [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
