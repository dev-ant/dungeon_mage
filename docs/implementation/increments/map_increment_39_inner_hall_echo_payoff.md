---
title: 맵 증분 39 - 8층 내부 홀 반복 상호작용 payoff
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

# 맵 증분 39 - 8층 내부 홀 반복 상호작용 payoff

## 목표

`royal_inner_hall`을 단순 단서 발견 방에서 한 단계 더 밀어, 이미 확인한 진실이 같은 공간의 반복 상호작용에서 다시 읽히도록 만든다.

## 이번에 잠그는 내용

- 왕실 생활 공간의 빈 초상 프레임은 `royal_inner_hall_archive` 확인 전에는 단순 폐허처럼 보이지만, 확인 후에는 `왕가 삭제가 생활 공간 내부에서 먼저 집행되었다`는 의미로 재해석된다.
- 벽면에 남은 지원 마법 흔적은 `royal_inner_hall_companion_trace` 확인 전에는 희망과 위화감이 섞인 잔흔처럼 읽히지만, 확인 후에는 `지원 마법이 복종 교육으로 꺾였다`는 의미로 재해석된다.
- 이 증분은 직접 조우 없이도 8층이 `혈통 삭제`와 `지원 왜곡`을 함께 품은 공간이라는 현재 기준을 강화한다.
- room builder 실루엣도 같은 기준으로 `archive cabinet + ward tether`를 추가해, 반복 상호작용 전에 이미 `정리된 생활 공간`과 `복종용 보조 마법` 감각이 먼저 읽히게 한다.

## 구현 메모

- `data/rooms.json`
  - `royal_inner_hall`의 기존 두 echo에 `repeat_stage_messages`를 추가한다.
  - 같은 support distortion 축을 되돌려주는 secondary household-ward echo 1개를 추가해 8층을 dense payoff room으로 유지한다.
- `tests/test_player_controller.gd`
  - 8층 archive/companion flag에 따라 repeat text가 바뀌는 회귀 테스트를 추가한다.

## 검증

- `test_echo_marker_repeat_text_can_react_to_inner_hall_archive_flag`
- `test_echo_marker_repeat_text_can_react_to_inner_hall_companion_flag`
- `godot --headless --path . --quit-after 120`

## 보류

- 친구 B 직접 조우 장면
- 왕실 생존자 NPC 직접 등장
- 컷신형 왕실 회상 연출
