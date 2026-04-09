---
title: 맵 14차 작업 체크리스트 - 관리자 반응형 프리뷰
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_12_admin_interaction_preview.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_13_hub_reactive_notice.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 14차 작업 체크리스트 - 관리자 반응형 프리뷰

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 관리자 메뉴에서 `반응형 공간 상태`까지 바로 검증할 수 있도록 preview를 확장하는 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 허브의 반응형 공지판이 현재 progression flag 기준으로 어떤 텍스트를 보여줄지 관리자 메뉴에서 확인할 수 있어야 한다.
- room jump 전에 현재 빌드 상태의 `공간 반응 결과`를 미리 읽을 수 있어야 한다.
- 플레이 검증과 디버그 검증 사이의 왕복을 더 줄여야 한다.
- 현재 `Reactive Preview`의 source of truth는 `GameState.get_room_reactive_preview_summary(room_id)`이며, 관리자 메뉴는 같은 preview line 조합을 로컬에서 중복 계산하지 않는다.

## 수용 기준

- Resources 탭에서 `seal_sanctum` 선택 시 현재 progression flag 기준 공지판 프리뷰가 보여야 한다.
- 관련 progression flag가 바뀌면 프리뷰 텍스트도 같이 바뀌어야 한다.
- 다른 대표 구간은 기존 interaction preview를 유지하고, reactive preview가 없으면 생략돼야 한다.
- admin menu GUT와 headless 실행 검증이 통과해야 한다.

## 파일 터치포인트

- [scripts/admin/admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- [tests/test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)
- [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
