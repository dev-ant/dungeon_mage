---
title: 맵 7차 작업 체크리스트 - 6층 허브 봉인상 앵커
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_02_floor_6_hub.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_06_mid_castle_bridge.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-06
last_verified: 2026-04-06
---

# 맵 7차 작업 체크리스트 - 6층 허브 봉인상 앵커

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 `seal_sanctum` 허브를 단순 비주얼 프로토타입이 아니라 실제 상호작용 거점으로 승격하기 위한 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 허브 중앙의 봉인상을 실제 상호작용 오브젝트로 만든다.
- 봉인상은 허브 앵커 저장, 자원 회복, progression flag 부여를 담당한다.
- rest point와 역할이 겹치지 않도록 `허브의 기준점` 역할을 더 강하게 준다.

## 수용 기준

- `seal_sanctum`에 봉인상 오브젝트가 실제 배치되어야 한다.
- 상호작용 시 현재 룸 저장과 전체 회복이 일어나야 한다.
- 첫 상호작용 시 `seal_sanctum_anchor` progression flag가 기록되어야 한다.
- player interaction 회귀가 통과해야 한다.

## 파일 터치포인트

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
- [scripts/world/seal_statue.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/seal_statue.gd)
- [scripts/main/main.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/main/main.gd)
- [scripts/autoload/game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [tests/test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)
