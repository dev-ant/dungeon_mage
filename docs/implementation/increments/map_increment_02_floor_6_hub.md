---
title: 맵 2차 작업 체크리스트 - 6층 허브
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_floor_structure.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_01_floor_4_start_zone.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 2차 작업 체크리스트 - 6층 허브

상태: 진행 중  
최종 갱신: 2026-04-07  
섹션: 구현 기준

## 목표

이 문서는 `6층 허브` 프로토타입을 현재 world runtime에 안전하게 추가하기 위한 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 친구 A 봉인상과 임시 성역 감각이 읽히는 허브 룸 1개를 만든다.
- 전투장보다 `정비와 생존`이 먼저 읽히는 공간 정체성을 고정한다.
- 현재 메인 진행 루프는 건드리지 않고, 룸 데이터와 builder 기준만 먼저 닫는다.

## 플레이 경험 목표

- 이 공간은 폐허 안에서 겨우 유지되는 안전지대처럼 보여야 한다.
- 일반 전투 룸처럼 적이 가득한 대신, 결계와 봉인상, 잔존 성역이 먼저 보여야 한다.
- 밝고 평화로운 마을이 아니라 `버텨낸 쉼터`처럼 읽혀야 한다.

## 이번 범위

### 포함

- 6층 허브 전용 room data 추가
- 허브 테마용 최소 장식 레이어 추가
- 봉인상/결계/쉼터 실루엣 구현
- builder 회귀 테스트 추가
- 결계 경계가 한 장면에서 더 먼저 읽히도록 좌우 ward boundary 실루엣 고정
- 현재 lock 기준으로 room width도 이전 소형 샌드박스보다 최소 1.5배 이상 넓히고, 중앙 refuge를 감싸는 좌우 side lane을 유지해 `머무르고 둘러볼 수 있는 쉼터`로 읽히게 한다.
- 같은 기준으로 6층은 중앙 refuge 근처의 낮은 shelter pocket을 하나 유지해, 짧게 숨고 둘러보는 detour 감각도 함께 남긴다.
- shelter pocket에는 침상 자국 echo를 붙여, 이 우회 공간이 실제 피난 흔적과 결계 교대의 쉼을 읽는 자리로 남도록 유지한다.

### 제외

- 친구 A 실제 NPC 구현
- 메인 room_order 연결
- 상호작용 이벤트 체인
- 허브 상점/NPC/대사 시스템

## 필수 구현 포인트

- 새 룸은 적이 없는 허브형 구조여야 한다.
- rest point는 허브 성격과 맞는 위치에 있어야 한다.
- 봉인상과 결계가 전투 지형보다 먼저 읽혀야 한다.
- 장식은 안전지대 정체성을 주되, 추후 NPC/오브젝트 확장이 가능하도록 중앙 공간을 남겨야 한다.
- 현재 기준으로 허브 랜드마크는 `seal statue / ward ring / shelters / ward boundary` 묶음으로 읽히면 충분하다.

## 파일 터치포인트

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
- [scripts/world/room_builder.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/room_builder.gd)
- [tests/test_room_builder.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_room_builder.gd)

## 수용 기준

- 새 허브 룸이 데이터에서 정상 로드되어야 한다.
- 허브 테마 장식이 builder를 통해 생성되어야 한다.
- 휴식/정비 공간처럼 읽히는 중앙 공간이 확보되어야 한다.
- 기존 룸의 충돌/장식 회귀를 깨지 않아야 한다.

## 검증 순서

1. 문서 기준 확인
2. 룸 데이터 추가
3. 허브 테마 장식 추가
4. room builder GUT 검증
5. headless 실행 확인

## 다음 구현용 메모

- 이 증분이 안정화되면 다음은 `7층 성문` 증분으로 간다.
- 그 단계에서는 `문턱`, `검문`, `거대한 게이트` 실루엣이 핵심이다.

## 연관 문서

- [dungeon_floor_structure.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_floor_structure.md)
- [dungeon_map_prototype_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md)
- [map_increment_01_floor_4_start_zone.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_01_floor_4_start_zone.md)
