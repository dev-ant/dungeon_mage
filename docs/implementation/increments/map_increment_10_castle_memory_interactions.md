---
title: 맵 10차 작업 체크리스트 - 8층/9층 기억 상호작용
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_06_mid_castle_bridge.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_09_prototype_flow_preview.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 10차 작업 체크리스트 - 8층/9층 기억 상호작용

상태: 진행 중  
최종 갱신: 2026-04-07  
섹션: 구현 기준

## 목표

이 문서는 `royal_inner_hall` 과 `throne_approach` 를 단순 전투 통로가 아니라 `기억을 찍고 지나가는 공간` 으로 강화하기 위한 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 8층에는 왕실 생활 흔적을 읽는 기록물 상호작용을 둔다.
- 9층에는 왕권과 판결의 압박을 읽는 칙령 상호작용을 둔다.
- 두 상호작용은 저장 가능한 route anchor이자 향후 대사/허브 전개용 progression flag를 남긴다.
- 현재 맵 실루엣 기준으로도 8층은 archive cabinet과 ward tether가, 9층은 decree pillar와 procession rune이 같은 기억 상호작용의 공간 문맥을 먼저 깔아줘야 한다.
- 같은 기준으로 memory plinth와 companion/decree echo는 같은 상단 lane 안에서도 서로를 가리지 않는 간격을 유지하고, 같은 lane enemy spawn과 직접 겹치지 않도록 둔다.

## 수용 기준

- `royal_inner_hall` 에 상호작용 가능한 기억 오브젝트가 배치되어야 한다.
- `throne_approach` 에 상호작용 가능한 기억 오브젝트가 배치되어야 한다.
- 각 상호작용은 progression flag를 기록하고, 해당 room에 대한 저장 앵커가 될 수 있어야 한다.
- player interaction 회귀와 headless 실행 검증이 통과해야 한다.

## 파일 터치포인트

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
- [scripts/world/memory_plinth.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/memory_plinth.gd)
- [scripts/main/main.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/main/main.gd)
- [scripts/autoload/game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [tests/test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)
