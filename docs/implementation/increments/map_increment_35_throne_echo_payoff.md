---
title: 왕좌 접근 에코 payoff 반응
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

# 왕좌 접근 에코 payoff 반응

## 이번 증분에서 잠근 내용

- `throne_approach`의 중심 복도 echo도 이제 단서가 잠긴 뒤 다른 의미로 읽히도록 바뀐다.
- `throne_approach_companion_trace`와 `throne_approach_decree`가 모두 확인되면, 같은 복도는 단순한 왕좌 접근 공간이 아니라 `복종을 학습시키는 구조`로 해석된다.
- 이 반응은 직접 조우 없이도 9층 단서가 실제 공간 해석을 바꾸는 payoff를 제공한다.
- room builder 실루엣도 같은 기준으로 `decree pillar + procession rune`를 추가해, 반복 상호작용 전부터 이 복도가 `판결을 통과 연습시키는 공간`처럼 읽히게 한다.

## 구현 변경

- [rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
  - `throne_approach` 중심 echo에 combined repeat payoff 문장 추가
  - support distortion을 다른 각도에서 되돌려주는 stair-rail reinforcement echo 1개를 추가해 9층을 dense payoff room으로 유지
- [echo_marker.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/echo_marker.gd)
  - 이전 증분에서 추가한 `repeat_stage_messages` 기능을 9층에도 적용

## 보류 유지

- 직접 조우, 컷신, 보스전 페이즈 연출은 여전히 사용자 결정이 필요한 범위로 남긴다.
- 이번 증분은 이미 잠긴 9층 단서를 반복 상호작용 payoff로 재반영하는 범위까지만 다룬다.
