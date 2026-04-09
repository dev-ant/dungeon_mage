---
title: 맵 증분 41 - 4층 외곽 시작 반복 상호작용 payoff
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

# 맵 증분 41 - 4층 외곽 시작 반복 상호작용 payoff

## 목표

`entrance`를 단순 시작 방에서 한 단계 더 밀어, 플레이어가 미궁의 역전 규칙을 반복 상호작용으로 다시 읽게 만든다.

## 이번에 잠그는 내용

- 외곽 조사 흔적 echo는 첫 상호작용 뒤 `sensible escape route조차 이미 더 깊은 쪽으로 기울어 있었다`는 의미로 재해석되어야 한다.
- 성벽 문장 echo는 첫 상호작용 뒤 `외곽 구조물조차 왕국 중심을 향해 아래를 가리키는 상태`로 재해석되어야 한다.
- 이 증분으로 4층은 단순 생존 시작 공간이 아니라, `올라가고 있다고 느끼지만 더 깊어진다`는 미궁 핵심 규칙을 가장 먼저 학습시키는 공간으로 고정된다.

## 구현 메모

- `data/rooms.json`
  - `entrance`의 두 echo에 `repeat_stage_messages`를 추가한다.
  - 기존 기본 progression event 매핑 `echo_entrance_1`, `echo_entrance_2`를 그대로 사용한다.
  - 같은 역전 규칙을 되돌려주는 secondary guidepost echo 1개를 추가해 4층을 dense payoff room으로 유지한다.
- `tests/test_player_controller.gd`
  - 4층 첫 번째/두 번째 echo가 첫 상호작용 뒤 반복 문장을 다르게 보여주는 회귀를 추가한다.

## 검증

- `test_echo_marker_repeat_text_can_react_to_entrance_first_flag`
- `test_echo_marker_repeat_text_can_react_to_entrance_second_flag`
- `godot --headless --path . --quit-after 120`

## 보류

- 4층 추락 직후 컷신 연출
- 친구들과의 분리 순간 직접 회상
- 시험장 사고 장면의 연속 카메라 연출
