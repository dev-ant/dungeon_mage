---
title: 맵 8차 작업 체크리스트 - 프로토타입 룸 셀렉터
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_07_hub_anchor.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 8차 작업 체크리스트 - 프로토타입 룸 셀렉터

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 대표 구간 프로토타입을 빠르게 검증하기 위한 관리자 메뉴 기반 room selector를 추가하는 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 관리자 메뉴에서 대표 구간 목표 룸을 순환 선택할 수 있어야 한다.
- 선택한 룸으로 즉시 점프할 수 있어야 한다.
- prototype flow 검증과 스크린샷 검증 시간을 줄여야 한다.
- 현재 selector 계층의 source of truth는 `GameState.get_prototype_room_catalog()`다. `Proto Target`, room short label, jump button label은 모두 이 catalog를 소비한다.

## 수용 기준

- Resources 탭에서 현재 room과 prototype target room이 보여야 한다.
- 관리자 메뉴에서 prototype target room을 순환할 수 있어야 한다.
- Jump 실행 시 Main이 요청된 room을 즉시 로드해야 한다.
- admin/main integration GUT가 통과해야 한다.

## 파일 터치포인트

- [scripts/admin/admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- [scripts/main/main.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/main/main.gd)
- [tests/test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)
- [tests/test_main_integration.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_main_integration.gd)
