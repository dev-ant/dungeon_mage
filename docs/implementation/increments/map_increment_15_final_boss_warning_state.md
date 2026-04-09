---
title: 맵 15차 작업 체크리스트 - 최종전 경고 상태
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_11_final_covenant_anchor.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_14_admin_reactive_preview.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-06
last_verified: 2026-04-06
---

# 맵 15차 작업 체크리스트 - 최종전 경고 상태

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 `inverted_spire` 에서 계약 제단 상호작용 뒤 최종전 직전 경고 상태를 부여하는 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 계약 제단을 보기 전과 본 후의 최심층 상태가 다르게 읽혀야 한다.
- 첫 계약 확인 시 짧은 경고 메시지와 카메라 포커스가 발생해야 한다.
- 플레이어가 `이제 보스전이 진짜로 시작된다`는 감각을 짧게라도 받아야 한다.

## 수용 기준

- `inverted_spire_covenant` progression event가 발생하면 Main이 최심층 전용 경고 반응을 실행해야 한다.
- 경고 반응은 최종 보스 방향 포커스와 짧은 메시지를 포함해야 한다.
- 최심층 room clear 차단 문구는 제단 확인 전후 상태에 따라 달라져야 한다.
- main integration GUT와 headless 실행 검증이 통과해야 한다.

## 파일 터치포인트

- [scripts/autoload/game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [scripts/main/main.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/main/main.gd)
- [tests/test_main_integration.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_main_integration.gd)
- [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
