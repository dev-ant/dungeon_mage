---
title: 허브 에코 payoff 반응
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

# 허브 에코 payoff 반응

## 이번 증분에서 잠근 내용

- `seal_sanctum`의 일반 echo도 이제 progression에 따라 다른 의미로 읽히도록 바뀐다.
- 7층 단서가 잠기면 허브의 미완성 연구 노트는 `선택에 저항하는 규칙`처럼 읽힌다.
- 8층/9층 companion 패턴이 잠기면 덮인 왕실 문장은 `왜곡된 권위를 거부하는 표식`처럼 읽힌다.
- 10층 계약이 잠기면 허브 노트는 `왕국의 마지막 명령을 거부한 생존의 기록`처럼 읽힌다.

## 구현 변경

- [rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
  - `seal_sanctum`의 두 echo에 repeat payoff 문장 추가
  - 같은 refuge refusal 축을 되돌려주는 secondary ward-anchor echo 1개를 추가해 허브를 board 1 + echo 3 구조로 유지
- [echo_marker.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/echo_marker.gd)
  - 이전 증분에서 추가한 progression-aware repeat 로직을 허브에도 적용

## 보류 유지

- 직접 조우, 컷신, 보스전 페이즈 연출은 여전히 사용자 결정이 필요한 범위로 남긴다.
- 이번 증분은 이미 잠긴 허브-게이트-궁정-계약 체인을 반복 상호작용 payoff로 재반영하는 범위까지만 다룬다.
