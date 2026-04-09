---
title: 맵 9차 작업 체크리스트 - 프로토타입 플로우 프리뷰
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_08_prototype_room_selector.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 9차 작업 체크리스트 - 프로토타입 플로우 프리뷰

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 대표 구간 selector를 `순환 선택 도구`에서 `빠른 프리뷰 패널`로 확장하는 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- Resources 탭에서 대표 구간을 개별 버튼으로 바로 선택할 수 있어야 한다.
- 본문에서 prototype flow 전체 목록과 현재 선택 구간이 함께 보여야 한다.
- 플레이어가 현재 target room의 역할을 텍스트만 보고도 빠르게 검증할 수 있어야 한다.
- 현재 `Proto Title / Proto Summary / Prototype Flow`의 source of truth는 `GameState.get_prototype_room_overview_summary(room_id)`와 `GameState.get_prototype_flow_preview_summary(selected_room_id)`다.
- 현재 `Proto Summary` 문구는 방별 실루엣과 대표 interaction lane까지 반영해, 4층 breach/signal mast, 6층 ward boundary, 7층 queue line/judgement beam, 8층 archive cabinet/ward tether, 9층 decree stand/procession line, 10층 overturned royal chamber 감각을 한 줄 안에서 바로 읽히게 유지한다.

## 수용 기준

- Resources 탭에 `4F / 6F / 7F / 8F / 9F / 10F` 대표 구간 빠른 선택 버튼이 보여야 한다.
- 선택된 prototype room은 버튼과 본문 목록 모두에서 강조되어야 한다.
- Jump는 여전히 현재 선택된 target room으로 이동해야 한다.
- admin menu GUT와 headless 부팅 검증이 통과해야 한다.

## 파일 터치포인트

- [scripts/admin/admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- [tests/test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)
- [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
