---
title: 맵 증분 40 - 7층 성문 반복 상호작용 payoff
doc_type: increment
status: active
section: implementation
owner: runtime
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_premise.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 40 - 7층 성문 반복 상호작용 payoff

## 목표

`gate_threshold`를 단순 진입 단서 방에서 한 단계 더 밀어, 이미 확인한 생존자 경고와 혈통 판정이 같은 게이트 구조를 다시 읽게 만들도록 고정한다.

## 이번에 잠그는 내용

- 성문 하부의 inspection echo는 첫 상호작용에서 `gate_threshold_survivor_trace`를 직접 부여하고, 이후에는 `같은 경고가 살아남은 사람들 사이에서 반복된 문장`처럼 읽혀야 한다.
- 상부 arch echo는 첫 상호작용에서 `gate_threshold_bloodline_hint`를 직접 부여하고, 이후에는 `위로 올려 보이는 거짓 방향이 실제로는 소속을 판정하는 선택 장치`처럼 읽혀야 한다.
- 이 증분으로 7층 단서는 문서/관리자 메뉴에만 존재하는 추상 상태가 아니라, 실제 room interaction에서 바로 획득되고 반복 해석되는 현재 기준으로 잠긴다.

## 구현 메모

- `data/rooms.json`
  - `gate_threshold`의 두 echo에 `progression_event_id`와 `repeat_stage_messages`를 추가한다.
  - 같은 inspection/selection 패턴을 되돌려주는 secondary queue-line echo 1개를 추가해 7층을 dense payoff room으로 유지한다.
- `tests/test_player_controller.gd`
  - 7층 survivor/bloodline flag가 첫 상호작용에서 부여되고 두 번째 상호작용부터 payoff text로 바뀌는 회귀를 추가한다.

## 검증

- `test_echo_marker_repeat_text_can_react_to_gate_survivor_flag`
- `test_echo_marker_repeat_text_can_react_to_gate_bloodline_flag`
- `godot --headless --path . --quit-after 120`

## 보류

- 7층 생존자 NPC 직접 등장
- 혈통 판정 장면의 컷신 연출
- 성문 경비/문지기 직접 대사 시스템
