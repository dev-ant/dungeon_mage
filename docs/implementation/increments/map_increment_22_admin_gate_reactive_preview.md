---
title: 맵 22차 작업 체크리스트 - 관리자 7층 반응 프리뷰
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_21_hub_gate_reaction.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_20_gate_lore_chain.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 22차 작업 체크리스트 - 관리자 7층 반응 프리뷰

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 `7층 문턱 단서 -> 6층 허브 반응` 연결이 관리자 메뉴의 reactive preview에서도 바로 읽히도록 잠그는 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 허브 공지판이 7층 생존자 경고와 혈통 떡밥을 어떻게 받아 적는지 관리자 메뉴에서 즉시 확인할 수 있어야 한다.
- 플레이 검증 없이도 `문턱 단서가 허브 텍스트에 반영되는가`를 빠르게 검증할 수 있어야 한다.
- 더 깊은 층 반응이 있을 때 기존 우선순위 규칙이 유지되는지도 함께 확인할 수 있어야 한다.
- 현재 이 preview contract는 `GameState.get_room_reactive_preview_summary("seal_sanctum")`이 담당하며, 7층 단계 반응 우선순위도 여기서 잠긴다.

## 수용 기준

- Resources 탭에서 `seal_sanctum` 선택 시 `gate_threshold_survivor_trace`, `gate_threshold_bloodline_hint` 상태 변화가 reactive preview에 반영되어야 한다.
- 더 깊은 층 플래그가 켜지면 기존 deeper-state preview가 우선해야 한다.
- admin menu GUT와 headless 실행 검증이 통과해야 한다.

## 파일 터치포인트

- [tests/test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)
- [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
