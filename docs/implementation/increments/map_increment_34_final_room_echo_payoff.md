---
title: 최심층 에코 payoff 반응
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 최심층 에코 payoff 반응

## 이번 증분에서 잠근 내용

- `echo_marker`는 이제 progression flag에 따라 첫 문장과 반복 문장을 바꿀 수 있다.
- 이를 이용해 `inverted_spire`의 계약 문양 echo는 계약 확인 후 다른 의미로 읽히도록 바뀐다.
- 이 반응은 컷신이나 직접 조우 없이도 `최종 진실을 확인한 뒤 공간 자체가 다르게 읽히는 payoff`를 제공한다.

## 구현 변경

- [echo_marker.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/echo_marker.gd)
  - `stage_messages`
  - `repeat_stage_messages`
  - `required_flag`
  - `required_flags_all`
- [rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
  - `inverted_spire`의 covenant circle echo에 계약 확인 후 repeat payoff 문장 추가

## 보류 유지

- 직접 조우, 컷신, 보스전 페이즈 연출은 여전히 사용자 결정이 필요한 범위로 남긴다.
- 이번 증분은 이미 잠긴 계약 진실을 공간 상호작용의 반복 문장으로 재반영하는 범위까지만 다룬다.
