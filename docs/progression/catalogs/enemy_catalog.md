---
title: 몬스터 카탈로그
doc_type: catalog
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - rule_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 몬스터 카탈로그

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 성장 시스템 / 몬스터 roster

## 목적

이 문서는 프로젝트의 정식 몬스터 roster, 전투 역할, 엘리트 후보, 신규 편입 우선순위를 관리하는 카탈로그입니다.

수치 공식, 저항, 슈퍼아머, 최종 피해 계산은 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)에서 관리하고, `enemies.json` 필드 구조는 [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md)에서 관리합니다.

현재 빌드에 실제 반영된 상태는 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)와 실제 코드/데이터를 우선합니다.

## 문서 사용 규칙

- 새 몬스터를 정식 편입할 때는 먼저 이 문서에 등록합니다.
- `enemy_id`의 정식 명칭은 이 문서와 `data/enemies/enemies.json`을 함께 맞춥니다.
- 자연어 `역할`은 기획 설명용 요약이고, 스키마/JSON과 직접 맞닿는 값은 `runtime role`로 따로 적습니다.
- 구현 증분 문서는 이 문서를 다시 정의하지 않고, 필요한 범위만 링크합니다.
- 에셋 후보, 역할, 우선순위가 바뀌면 이 문서를 먼저 갱신합니다.

## 현재 정식 roster

| enemy_id | 표시명 | 역할 | runtime role | 등급 | 엘리트 후보 | 비고 |
| --- | --- | --- | --- | --- | --- | --- |
| `brute` | Brute | 근접 추격 | `melee_chaser` | normal | 예 | 기본 근접 기준 적 |
| `ranged` | Ranged | 원거리 견제 | `ranged_harasser` | normal | 아니오 | 거리 유지형 |
| `boss` | Boss | 보스 볼리 | `boss_volley` | boss | 아니오 | 별도 종 |
| `dummy` | Training Dummy | 훈련 대상 | `training_target` | normal | 아니오 | 테스트 전용 |
| `dasher` | Dasher | 텔레그래프 돌진 | `telegraph_charger` | normal | 아니오 | 회피 학습용 |
| `sentinel` | Sentinel | 범위 제어 | `area_control` | normal | 예 | 중형 압박형 |
| `elite` | Elite | 버스트 체크 | `burst_check` | elite | 아니오 | standalone elite |
| `leaper` | Leaper | 점프 압박 | `mobile_burst` | normal | 아니오 | 착지 압박형 |
| `bomber` | Bomber | 억제형 원거리 | `slow_ranged_denial` | normal | 아니오 | 정지 패널티 |
| `charger` | Charger | 고속 돌진 | `punish_stationary` | normal | 예 | 위치 잠금형 |
| `bat` | Bat | 공중 견제 | `flying_ranged_harasser` | normal | 아니오 | 비교군 유지 |
| `worm` | Worm | 근접 압박 | `ground_charge_presser` | normal | 예 | 중형 압박형 |
| `mushroom` | Mushroom | 근접 기준 적 | `melee_stunner` | normal | 예 | 비교군 유지 |
| `rat` | Dungeon Rat | 군집형 약체 | `fast_melee_swarm` | normal | 아니오 | 신규 우선 편입 |
| `tooth_walker` | Tooth Walker | 둔중 추격 | `slow_bite_chaser` | normal | 조건부 | 신규 우선 편입 |
| `eyeball` | Eye Ball Monster | 공중 감시 | `flying_observer` | normal | 아니오 | 신규 우선 편입 |
| `trash_monster` | Trash Monster | 공간 점유 | `trash_tank` | normal | 예 | 신규 우선 편입 |
| `sword` | Living Sword | 부유 압박 | `agile_sword_fighter` | normal | 아니오 | 신규 우선 편입 |

## 역할군 정의

### 근접 추격형

- 플레이어에게 지속 접근 압박을 만든다.
- 버프 없는 기본 화력 검증용 기준 대상이다.
- 대표: `brute`, `mushroom`, `worm`, `rat`

### 원거리 견제형

- 일정 거리 유지와 투사체 압박을 담당한다.
- 이동 중 시전과 포지셔닝 가치를 드러낸다.
- 대표: `ranged`, `bat`, `sentinel`, `bomber`, `eyeball`

### 돌진 / 점프 압박형

- 준비 동작을 보여 준 뒤 빠르게 공간을 먹는다.
- 대시와 공중 회피의 가치를 드러낸다.
- 대표: `dasher`, `leaper`, `charger`, `sword`

### 공간 점유 / 둔중 압박형

- 빠르지 않지만 자리 점유와 밀어내기 체감을 만든다.
- 좁은 지형에서 플레이어 위치 선택을 강제한다.
- 대표: `trash_monster`, `tooth_walker`

### 엘리트 / 버스트 체크형

- 버프 폭발 타이밍을 요구한다.
- 긴 교전과 슈퍼아머 대응 감각을 검증한다.
- 대표: `elite`, 엘리트 승격 `brute/sentinel/mushroom/charger/worm/trash_monster`

## 엘리트 후보 원칙

엘리트는 `빠른 잡몹`보다 `중형 이상 압박형 적`을 우선합니다.

현재 권장 후보:

- `brute`
- `sentinel`
- `mushroom`
- `charger`
- `worm`
- `trash_monster`

현재 비권장 후보:

- `rat`
- `bat`
- `ranged`
- `bomber`
- `dasher`
- `eyeball`
- `sword`

## 신규 편입 우선순위

아래 5종은 기존 무료 에셋 3종보다 우선 구현 / 우선 적용 대상으로 유지합니다.

1. `rat`
2. `tooth_walker`
3. `eyeball`
4. `trash_monster`
5. `sword`

우선순위 기준:

- 바로 런타임에 붙이기 쉬운 분리 시트인가
- gif와 sprite sheet가 함께 있어 해석 기준을 먼저 고정해야 하는가
- 현재 미궁 서사와 전투 압박 역할에 잘 맞는가

비교군 2순위:

- `bat`
- `worm`
- `mushroom`

## 공통 에셋 적용 원칙

- `.gif`는 런타임 리소스가 아니라 미리보기 / 타이밍 참조용으로 취급합니다.
- 실제 런타임에는 `png` 분리 시트 또는 `sprite sheet png`를 소스 오브 트루스로 사용합니다.
- `.aseprite`는 원본 편집 파일로 보관하되, 구현 단계에서 직접 의존하지 않습니다.
- 기본 기준 상태는 `idle`, `run` 또는 `walk`, `attack`, `hurt` 또는 `damaged`, `death`입니다.
- `cover`, `attack2`, `stun` 같은 확장 상태는 기본 전투 루프 뒤에 추가합니다.

## 신규 5종 상세 초안

### rat

- 표시명: `Dungeon Rat`
- 역할: `근접 추격형 기본 적` 또는 `군집 압박형 약체`
- runtime role: `fast_melee_swarm`
- 핵심 압박: 빠른 접근과 다수전 체감
- 정식 `enemy_id`: `rat`
- 실제 적용 폴더:
  - [NoneOutlinedRat](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Monster/Rat/NoneOutlinedRat)
  - [OutlinedRat](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Monster/Rat/OutlinedRat)
- 런타임 기준:
  - `NoneOutlinedRat`를 기본 런타임 세트로 사용
  - `OutlinedRat`는 비교용 대안 비주얼로 유지
- 현재 반영 상태:
  - 구현 / 에셋 / 테스트 상태는 [enemy_content_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md)를 따른다.

### tooth_walker

- 표시명: `Tooth Walker`
- 역할: `근접 매복형` 또는 `짧은 돌진 추격형`
- runtime role: `slow_bite_chaser`
- 핵심 압박: 느리지만 묵직한 전진 압박
- 정식 `enemy_id`: `tooth_walker`
- 실제 적용 폴더:
  - [tooth walker](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Monster/tooth%20walker)
- 런타임 기준:
  - `tooth walker sprite-Sheet.png`를 실제 시트로 사용
  - 각 gif는 상태 길이 해석용 참조로만 사용
- 현재 반영 상태:
  - 구현 / 에셋 / 테스트 상태는 [enemy_content_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md)를 따른다.

### eyeball

- 표시명: `Eye Ball Monster`
- 역할: `공중 감시형` 또는 `원거리 견제형`
- runtime role: `flying_observer`
- 핵심 압박: 느린 공중 감시와 시선 압박
- 정식 `enemy_id`: `eyeball`
- 실제 적용 폴더:
  - [Eye ball Monster](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Monster/Eye%20ball%20Monster)
- 런타임 기준:
  - `EyeBall Monster-Sheet.png`를 실제 시트로 사용
  - gif는 프레임 순서 확인용 참조
- 현재 반영 상태:
  - 구현 / 에셋 / 테스트 상태는 [enemy_content_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md)를 따른다.

### trash_monster

- 표시명: `Trash Monster`
- 역할: `둔중 전진형` 또는 `근거리 공간 점유형`
- runtime role: `trash_tank`
- 핵심 압박: 느리지만 체형으로 밀어내는 공간 장악
- 정식 `enemy_id`: `trash_monster`
- 실제 적용 폴더:
  - [Trash Monster](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Monster/Trash%20Monster)
- 런타임 기준:
  - `Trash Monster-Sheet.png`를 1차 시트로 사용
  - `Sprite V2`는 비교 후보로 유지
- 현재 반영 상태:
  - 구현 / 에셋 / 테스트 상태는 [enemy_content_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md)를 따른다.

### sword

- 표시명: `Living Sword`
- 역할: `부유 돌진형` 또는 `짧은 간격 압박형`
- runtime role: `agile_sword_fighter`
- 핵심 압박: 떠다니며 빈틈을 찌르는 근거리 접근
- 정식 `enemy_id`: `sword`
- 실제 적용 폴더:
  - [Sword](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Monster/Sword)
- 런타임 기준:
  - `Sword.png`를 실제 시트로 사용
  - gif와 aseprite는 참고 자료로만 유지
- 현재 반영 상태:
  - 구현 / 에셋 / 테스트 상태는 [enemy_content_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md)를 따른다.

## 구현자 체크리스트

- [ ] 새 몬스터의 `enemy_id`가 이 문서와 `enemies.json`에서 일치하는가
- [ ] 전투 역할이 기존 roster와 겹치더라도 차별점이 한 줄로 설명되는가
- [ ] 엘리트 후보 여부가 규칙에 맞게 표시되어 있는가
- [ ] 에셋 적용 기준이 gif 참조 / png 소스 오브 트루스로 분리되어 있는가
- [ ] 구현 증분 문서가 이 카탈로그를 다시 장기 정의하지 않는가
