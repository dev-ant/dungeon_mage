---
title: 맵 4차 작업 체크리스트 - 10층 최심층
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_floor_structure.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_03_floor_7_gate.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 4차 작업 체크리스트 - 10층 최심층

상태: 진행 중  
최종 갱신: 2026-04-07  
섹션: 구현 기준

## 목표

이 문서는 `10층 최심층` 프로토타입을 현재 world runtime에 안전하게 추가하기 위한 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 계약 제단과 뒤집힌 마탑 감각이 함께 읽히는 최심층 룸 1개를 만든다.
- 일반 전투장과 구분되는 보스전 평면을 시각적으로 고정한다.
- 현재 메인 진행 루프를 건드리지 않고, room data와 builder 기준만 먼저 닫는다.

## 플레이 경험 목표

- 이 공간은 `왕의 사적 공간이 악마 의식장으로 고정된 곳`처럼 보여야 한다.
- 가장 높은 곳이 가장 깊은 곳이 되었다는 역전 감각이 배경 실루엣으로 읽혀야 한다.
- 일반 엘리트 방이 아니라 최종전에 가까운 제단 공간처럼 느껴져야 한다.

## 이번 범위

### 포함

- 10층 최심층 전용 room data 추가
- 최심층 테마용 최소 장식 레이어 추가
- 계약 제단, 뒤집힌 마탑, 보스전 평면 실루엣 구현
- builder 회귀 테스트 추가
- 왕실 canopy 잔해와 spire talon 실루엣을 추가해 `왕의 사적 공간 + 뒤집힌 탑` 중첩 감각을 더 또렷하게 고정
- central boss floor segment와 양측 perch를 조금 더 넓게 유지해, 최심층이 일반 통로가 아니라 `넓은 최종 평면 + flank read` 공간으로 읽히는 current navigation rhythm을 고정
- 현재 lock 기준으로 room width도 이전 소형 샌드박스보다 최소 1.5배 이상 넓히고, central boss floor가 side perch보다 압도적으로 넓은 최종 압축 평면으로 유지된다.
- 같은 기준으로 10층은 upper flank pocket을 하나 더 유지해, 최종전 직전의 짧은 관측 detour가 ritual floor 양옆에서 읽히도록 고정한다.
- upper flank pocket에는 관측 고리/줄 흔적 echo를 붙여, 우회 공간이 마지막 방을 내려다보던 사적 시선까지 ritual floor에 접혀 들어갔음을 읽는 자리로 유지한다.

### 제외

- 실제 최종 보스 이벤트
- 친구 B 조우 연출
- 페이즈 전환 컷신
- 메인 room_order 연결

## 필수 구현 포인트

- 새 룸은 보스전용 넓은 평면이 먼저 읽혀야 한다.
- 중앙에는 제단 또는 계약 문양 중심부가 있어야 한다.
- 상부 또는 배경에는 뒤집힌 마탑/왕실 흔적이 함께 보여야 한다.
- 장식은 위압적이어야 하지만 전투 가독성을 해치면 안 된다.
- 현재 기준으로 10층 랜드마크는 `tower mass / inverted spire / covenant dais / covenant ring / royal canopy remnant / spire talons` 묶음으로 읽히면 충분하다.

## 파일 터치포인트

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
- [scripts/world/room_builder.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/room_builder.gd)
- [tests/test_room_builder.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_room_builder.gd)

## 수용 기준

- 새 최심층 룸이 데이터에서 정상 로드되어야 한다.
- 최심층 테마 장식이 builder를 통해 생성되어야 한다.
- 제단, 보스전 평면, 뒤집힌 마탑 감각이 같은 화면 안에서 읽혀야 한다.
- 기존 룸의 충돌/장식 회귀를 깨지 않아야 한다.

## 검증 순서

1. 문서 기준 확인
2. 룸 데이터 추가
3. 최심층 테마 장식 추가
4. room builder GUT 검증
5. headless 실행 확인

## 다음 구현용 메모

- 이 증분이 안정화되면 대표 구간 4개 세트가 모두 준비된다.
- 그 다음 단계는 대표 구간들을 실제 동선 또는 선택형 prototype flow로 연결하는 작업이다.

## 연관 문서

- [dungeon_floor_structure.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_floor_structure.md)
- [dungeon_map_prototype_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md)
- [map_increment_03_floor_7_gate.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_03_floor_7_gate.md)
