---
title: 맵 증분 45 - 허브 문장 final payoff 보강
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_36_hub_echo_payoff.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_44_final_room_overturned_furnishings_payoff.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 45 - 허브 문장 final payoff 보강

## 목표

`seal_sanctum`의 덮인 왕실 문장 echo가 companion 단계에서만 반응하는 데서 멈추지 않고, 10층 계약 확인 뒤에는 허브 자체가 `왕의 마지막 정의를 거부한 공간`으로 읽히도록 확장한다.

## 이번에 잠그는 내용

- 허브의 덮인 왕실 문장 echo는 기본적으로 `생존을 위해 왕실 권위를 덮어쓴 흔적`으로 남는다.
- 8층/9층 companion 패턴이 잠기면 이 문장은 `왜곡된 권위를 거부하는 표식`처럼 읽힌다.
- `inverted_spire_covenant` 이후에는 같은 문장이 더 강하게 `왕의 마지막 명령과 왕국 정의 자체를 거부한 verdict`처럼 읽혀야 한다.
- 이 증분은 직접 조우나 컷신 없이도 `10층 진실이 6층 refuge의 의미를 다시 확정한다`는 current flow를 world-side 반응으로 고정한다.

## 구현 변경

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
  - `seal_sanctum`의 crest echo에 `inverted_spire_covenant`용 repeat payoff 문장을 추가한다.
- [tests/test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)
  - 허브 crest echo가 final covenant 이후 다른 repeat 문장을 반환하는 회귀를 추가한다.

## 검증

- `test_echo_marker_repeat_text_can_react_to_combined_companion_flags`
- `test_echo_marker_repeat_text_can_react_to_hub_crest_final_covenant_flag`

## 보류

- 허브 컷신
- 생존자 NPC 대사 시스템
- 직접 조우가 필요한 refuge aftermath 연출
