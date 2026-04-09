---
title: 맵 12차 작업 체크리스트 - 관리자 상호작용 프리뷰
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_09_prototype_flow_preview.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_11_final_covenant_anchor.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 12차 작업 체크리스트 - 관리자 상호작용 프리뷰

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 관리자 메뉴의 prototype preview를 `방 제목 확인` 수준에서 `상호작용 검증 패널` 수준으로 확장하기 위한 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- Resources 탭에서 대표 구간의 핵심 상호작용 오브젝트를 바로 읽을 수 있어야 한다.
- 플레이어가 room jump 전에도 그 방이 `허브 / 기억 기록 / 최종 제단` 중 어떤 성격인지 확인할 수 있어야 한다.
- 플레이 테스트 전 검증 시간을 더 줄여야 한다.
- 현재 `Interaction Preview`의 source of truth는 `GameState.get_room_interaction_preview_summary(room_id)`이며, 관리자 메뉴는 더 이상 room object type을 직접 분기해서 같은 라인을 중복 조합하지 않는다.

## 수용 기준

- Resources 탭에 현재 선택된 prototype room의 상호작용 요약이 보여야 한다.
- `seal_statue`, `memory_plinth`, `covenant_altar`, `rest`, `echo` 계열이 요약에 반영되어야 한다.
- 대표 구간을 바꾸면 상호작용 프리뷰도 같이 바뀌어야 한다.
- admin menu GUT와 headless 실행 검증이 통과해야 한다.

## 파일 터치포인트

- [scripts/admin/admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- [tests/test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)
- [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
