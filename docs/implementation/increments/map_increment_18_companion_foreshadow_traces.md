---
title: 맵 18차 작업 체크리스트 - 친구 B 전조 흔적
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/story_arc.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-06
last_verified: 2026-04-07
---

# 맵 18차 작업 체크리스트 - 친구 B 전조 흔적

상태: 진행 중  
최종 갱신: 2026-04-07  
섹션: 구현 기준

## 목표

이 문서는 `친구 B 직접 조우`를 확정하기 전, 8층과 9층에서 먼저 잠글 수 있는 환경 전조를 구현하기 위한 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 8층에는 `친숙하지만 어긋난 지원 마법 흔적`을 둔다.
- 9층에는 `왕권에 흡수된 지원 마법 흔적`을 둔다.
- 플레이어가 직접 조우 전에 친구 B가 이 구역을 지나갔고, 이미 영향을 받았다는 감각을 환경으로 먼저 받아야 한다.
- 각 방은 단서 1회 발견에서 멈추지 않고, 같은 왜곡이 반복 상호작용 surface 두 면 이상으로 남아야 한다.

## 현재 잠금 범위

- `직접 조우 대사`, `컷신`, `버프 이벤트 타이밍`은 아직 사용자 결정이 필요한 항목으로 남긴다.
- 이번 증분에서는 환경 상호작용과 progression flag까지만 잠근다.

## 수용 기준

- `royal_inner_hall` 에 친구 B 전조용 echo trace가 1개 있어야 한다.
- `throne_approach` 에 친구 B 전조용 echo trace가 1개 있어야 한다.
- 각 전조 trace는 progression flag를 기록하고 반복 상호작용 문구를 가져야 한다.
- `royal_inner_hall`, `throne_approach`는 각각 support-magic 왜곡을 되돌려주는 secondary echo surface를 1개 더 가져 dense payoff room으로 유지한다.
- player interaction 회귀와 headless 실행 검증이 통과해야 한다.

## 파일 터치포인트

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
- [scripts/world/echo_marker.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/echo_marker.gd)
- [scripts/autoload/game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [tests/test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)
