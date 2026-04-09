---
title: 맵 11차 작업 체크리스트 - 10층 계약 제단 앵커
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_04_floor_10_core.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_10_castle_memory_interactions.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-06
last_verified: 2026-04-06
---

# 맵 11차 작업 체크리스트 - 10층 계약 제단 앵커

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 `inverted_spire` 최심층을 최종전 전투장만이 아니라 `계약의 진실을 찍는 지점`으로 강화하기 위한 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 10층 중앙의 계약 제단을 실제 상호작용 오브젝트로 만든다.
- 제단은 최심층 저장 앵커와 story progression flag를 함께 담당한다.
- 플레이어가 보스전 직전, 왕과 악마의 계약이 어떤 방식으로 왕국을 뒤집었는지 환경 상호작용만으로 이해할 수 있어야 한다.

## 수용 기준

- `inverted_spire` 에 상호작용 가능한 계약 제단이 배치되어야 한다.
- 상호작용 시 최심층 저장 앵커가 기록되어야 한다.
- 첫 상호작용 시 `inverted_spire_covenant` progression flag가 기록되어야 한다.
- player interaction 회귀와 headless 실행 검증이 통과해야 한다.

## 파일 터치포인트

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
- [scripts/world/covenant_altar.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/covenant_altar.gd)
- [scripts/main/main.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/main/main.gd)
- [scripts/autoload/game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [tests/test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)
