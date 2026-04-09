---
title: 맵 3차 작업 체크리스트 - 7층 성문
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_floor_structure.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_02_floor_6_hub.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 3차 작업 체크리스트 - 7층 성문

상태: 진행 중  
최종 갱신: 2026-04-07  
섹션: 구현 기준

## 목표

이 문서는 `7층 성문` 프로토타입을 현재 world runtime에 안전하게 추가하기 위한 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 권력 중심부 진입 감각이 먼저 읽히는 성문형 룸 1개를 만든다.
- 거대한 게이트, 검문 광장, 문턱 통과 압박을 실루엣으로 고정한다.
- 현재 메인 진행 루프를 건드리지 않고, room data와 builder 기준만 먼저 닫는다.

## 플레이 경험 목표

- 화면에 들어서는 순간 `허브 이후 다시 긴장이 올라간다`는 감각이 있어야 한다.
- 이 공간은 왕성 내부보다 `왕성 안으로 들어가기 직전의 문턱`처럼 보여야 한다.
- 검문, 심판, 방어선 같은 느낌이 전투 플랫폼보다 먼저 읽혀야 한다.

## 이번 범위

### 포함

- 7층 성문 전용 room data 추가
- 성문 테마용 최소 장식 레이어 추가
- 게이트, 문지기, 검문 광장 실루엣 구현
- builder 회귀 테스트 추가
- 상부 judgement beam과 chain array를 추가해 `검문 장치`와 `압박되는 문턱` 감각을 더 분명하게 고정
- 상부 checkpoint floor segment도 조금 더 높고 넓게 유지해, bloodline hint와 upper gate lane이 실제 동선에서도 `검문대`처럼 읽히게 고정
- 현재 lock 기준으로 room width도 이전 소형 샌드박스보다 최소 1.5배 이상 넓히고, gate court -> inspection floor -> bloodline lane의 3단 구조를 유지한다.
- 같은 기준으로 7층은 inspection lane 옆 holding pocket을 하나 유지해, 선별 전 대기 공간처럼 잠깐 옆으로 빠지는 detour 감각을 남긴다.
- holding pocket에는 발끝 자국 echo를 붙여, 우회 공간이 `불리지 않은 이들이 밀려나 기다리던 자리`로 읽히도록 유지한다.

### 제외

- 메인 room_order 연결
- 보스/이벤트 전투 연출
- 실제 성문 개폐 기믹
- 친구 B 조우 이벤트

## 필수 구현 포인트

- 새 룸은 허브가 아니라 다시 전투 긴장이 올라가는 구조여야 한다.
- 거대한 문 실루엣이 중앙 또는 배경 중심부에서 먼저 읽혀야 한다.
- 넓은 진입 광장과 상부 방어선 느낌이 동시에 있어야 한다.
- 장식은 압박을 주되 전투 가독성을 해치지 않아야 한다.
- 현재 기준으로 7층 랜드마크는 `gate arch / gate void / guardians / inspection dais / judgement beam / chain array` 묶음으로 읽히면 충분하다.

## 파일 터치포인트

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
- [scripts/world/room_builder.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/room_builder.gd)
- [tests/test_room_builder.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_room_builder.gd)

## 수용 기준

- 새 성문 룸이 데이터에서 정상 로드되어야 한다.
- 성문 테마 장식이 builder를 통해 생성되어야 한다.
- 게이트, 광장, 상부 방어선이 같은 화면 안에서 읽혀야 한다.
- 기존 룸의 충돌/장식 회귀를 깨지 않아야 한다.

## 검증 순서

1. 문서 기준 확인
2. 룸 데이터 추가
3. 성문 테마 장식 추가
4. room builder GUT 검증
5. headless 실행 확인

## 다음 구현용 메모

- 이 증분이 안정화되면 다음은 `10층 최심층` 증분으로 간다.
- 그 단계에서는 계약 제단, 뒤집힌 마탑, 보스전 평면이 핵심이다.

## 연관 문서

- [dungeon_floor_structure.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_floor_structure.md)
- [dungeon_map_prototype_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md)
- [map_increment_02_floor_6_hub.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_02_floor_6_hub.md)
