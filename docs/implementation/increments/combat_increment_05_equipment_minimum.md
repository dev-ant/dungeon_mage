---
title: 전투 5차 작업 체크리스트 - 장비 시스템 최소 버전
doc_type: plan
status: active
section: implementation
owner: runtime
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/progression_overview.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_level_rules.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 전투 5차 작업 체크리스트 - 장비 시스템 최소 버전

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 구현 기준

## 목표

이 문서는 [전투 우선 구현 계획](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md)의 다섯 번째 증분인 `장비 시스템 최소 버전`을 Claude가 바로 구현할 수 있도록 쪼갠 작업 체크리스트다.

이번 증분의 핵심은 `캐릭터 레벨 없이도 장비가 전투 운용과 화력에 즉시 영향을 주는 구조`를 만드는 것이다.

## 현재 기준

- 성장 문서는 [progression_overview.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/progression_overview.md)와 [skill_level_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_level_rules.md)를 기준으로 관리한다.
- 현재 프로젝트는 스킬 레벨, 마스터리, 버프, 조합 중심 성장 구조가 먼저 잡혀 있다.
- 장비 데이터 파일과 장비 전용 런타임 구조는 아직 기준 문서 수준에 머물러 있으므로, 이번 작업에서 최소 실전 버전을 만든다.
- 전투 샌드박스에서는 관리자 모드를 통해 장비를 즉시 지급하고 장착할 수 있어야 한다.

## 진행 상태

### 현재 완료

- [equipment.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/items/equipment.json) 추가
- [game_database.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd)에 장비 로더 추가
- [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)에 장비 프리셋, 장착 상태, 요약, 계산 함수 추가
- 장비가 스킬 피해, 쿨타임, 버프 지속, 설치 유지에 실제 반영되도록 연결
- 장비가 최대 HP, 최대 MP, MP 재생, 기본 피해 감소에 실제 반영되도록 연결
- 관리자 메뉴에서 장비 프리셋 적용 가능
- 관리자 메뉴에서 개별 슬롯 장비 교체 가능
- HUD에 장비 요약 표시 추가
- `fire_burst`, `wind_tempo`, `earth_deploy`, `sanctum_sustain`, `holy_guard`, `dark_shadow`, `arcane_pulse` 대표 프리셋이 실제 런타임 대표 GUT로 고정됨
- 대표 적 기준 1차 회귀가 실제 통과함
  - `brute`: 화염 피해 증가
  - `leaper`: 바람 투사체 운용 강화
  - `elite`: 설치형 누적 피해 증가
  - `Prismatic Guard` + sustain: barrier 잔량, 최대 MP, 마나 재생, 직접 피해 감소
  - `holy_radiant_burst` + guard: holy projectile 화력/속도 증가, barrier 출력 강화
  - `dark_void_bolt` + dark build: dark projectile 화력/속도 증가

### 아직 남은 작업

- 장비 인벤토리 표시
- 장비 지급과 장착을 별도 메뉴로 분리
- 장신구/방어구 차이를 더 크게 만드는 수치 보강
- 장신구/방어구 차이를 더 크게 만드는 수치 보강

## 플레이 경험 목표

- 장비를 바꾸면 화력과 운용감이 바로 달라져야 한다.
- 특정 장비는 단순 수치 증가가 아니라 속성 특화나 버프 운영 쪽에 강점을 줘야 한다.
- 장비 획득과 장착이 복잡하지 않고 바로 비교 가능해야 한다.
- 스킬, 마스터리, 버프, 장비가 한 계산식 안에서 자연스럽게 합쳐져야 한다.

## 전투 커버리지 우선 구체화 (2026-04-01)

### 첫 대표 검증 축

- 첫 장비 검증 축은 `속성 특화 장비가 대표 스킬 화력과 운용을 즉시 바꾸는지`로 고정한다.
- 장비는 이번 단계에서 빌드를 극단적으로 갈라놓지 않는다.
- 대신 장착 즉시 `더 세다`, `더 빠르다`, `더 오래 남는다` 같은 수치 차이가 전투 결과에 직접 반영되는지를 먼저 본다.

### 대표 장비 3빌드

- `속성 특화 1세트`
- `운용 특화 1세트`
- `생존/자원 1세트`

### 우선 고정 옵션 묶음

- `element damage`
- `projectile_speed_multiplier`
- `projectile_count_bonus`
- `cooldown_recovery`
- `installation_duration_multiplier`

### 대표 검증 스킬과 상황

- 대표 스킬 3종:
  - `fire_bolt`
  - `wind_gale_cutter`
  - `stone_spire`
- 대표 상황 3종:
  - `brute`: 기본 화력 차이 확인
  - `leaper`: 운용/제어 차이 확인
  - `elite`: 누적 효율 차이 확인

### 체감과 가독성 기준

- 이번 단계의 핵심 체감은 `수치만 확실히 오르면 충분`으로 둔다.
- 장비는 스킬/버프보다 앞서 빌드 정체성을 만들지 않는다.
- 가독성은 비교 텍스트와 요약 문자열이 명확하면 1차 완료로 본다.

### 1차 완료 기준

- 장착 즉시 실제 전투 결과가 달라져야 한다.
- `fire_bolt`는 속성 특화 장비에 따라 `brute` 상대로 피해 차이가 GUT로 고정 가능해야 한다.
- `wind_gale_cutter`는 운용 특화 장비에 따라 탄속/투사체 운용 차이가 `leaper` 상대 결과로 드러나야 한다.
- `stone_spire`는 설치 특화 장비에 따라 유지시간 또는 누적 피해 기대값 차이가 `elite` 상대 장면에서 드러나야 한다.
- 1차 GUT 완료 기준은 `대표 장비 3빌드 × 대표 스킬 3종 × 대표 적 3상황`이다.

### 1차 대표 GUT 구현 상태 (2026-04-02)

- `fire_burst -> fire_bolt -> brute`
  - 장착 전후 `payload.damage`가 달라지고, 실제 projectile hit path 결과도 증가해야 한다.
- `wind_tempo -> wind_gale_cutter -> leaper`
  - 장착 시 추가 spread projectile이 생기고, primary projectile 속도와 wind 피해가 함께 증가해야 한다.
  - 실제 projectile hit path에서 `leaper`에게 정상 피해가 들어가야 한다.
- `earth_deploy -> earth_stone_spire -> elite`
  - 설치 지속 타격 누적이 `elite` 상대로 baseline보다 높아야 한다.
- `sanctum_sustain -> Prismatic Guard / sustain runtime`
  - `Prismatic Guard` barrier가 no-equipment baseline보다 커지고, 같은 대표 히트 뒤 남는 barrier가 더 많아야 한다.
  - `max_mana`, 1초 기준 `mana_regen`, 직접 받는 피해가 no-equipment baseline보다 개선돼야 한다.
- `holy_guard -> holy_radiant_burst / Prismatic Guard`
  - `holy_radiant_burst`는 no-equipment baseline보다 payload damage, projectile speed, 실제 brute hit 결과가 함께 올라가야 한다.
  - `Prismatic Guard` barrier 총량은 `sanctum_sustain`보다 커야 한다.
- `dark_shadow -> dark_void_bolt / bomber`
  - `dark_void_bolt`는 no-equipment baseline보다 payload damage, projectile speed, 실제 brute hit 결과가 함께 올라가야 한다.
- `arcane_pulse -> arcane_force_pulse / brute`
  - `arcane_force_pulse`는 no-equipment baseline보다 payload damage와 실제 brute hit 결과가 함께 올라가야 한다.
- 위 6건은 `tests/test_equipment_system.gd`에서 실제 GUT 회귀로 고정되었다.
- 위 7건은 `tests/test_equipment_system.gd`에서 실제 GUT 회귀로 고정되었다.
- 다음 owner_core 장비 증분은 장비 프리셋 커버리지를 더 넓히는 후속 축을 재선정하는 것이다.

## 이번 범위

### 포함

- 장비 슬롯 정의
- 장비 데이터 JSON
- 장비 인벤토리 최소 구조
- 장비 지급
- 장비 장착/해제
- 장비 옵션 반영
- 스킬 피해, 마나, 쿨타임, 버프 지속시간 등 전투 수치 연결
- 전투 샌드박스용 장비 UI 최소 버전
- 장비 관련 GUT 테스트

### 제외

- 랜덤 옵션 재련
- 세트 효과
- 희귀도별 복잡한 성장
- 상점/제작/강화
- 장비 외형 커스터마이즈

## Claude 작업 순서

1. 현재 장비 프리셋 구조와 개별 슬롯 교체 구조를 읽는다.
2. `equipment.json`의 장비 수치가 실제 체감 차이를 내는지 조정한다.
3. 관리자 메뉴에 장비 지급과 장착을 분리한 흐름을 추가한다.
4. 장비별 차이와 자원 보정을 HUD 또는 관리자 패널에 더 명확히 노출한다.
5. 인벤토리형 장비 UI는 범위가 커지므로 작은 증분 문서로 다시 쪼갠 뒤 구현한다.
6. GUT 테스트를 보강하고 헤드리스 검증을 통과시킨다.

## 장비 슬롯

### 기본 슬롯

- 무기
- 보조 마도구
- 머리
- 상의
- 하의
- 장신구 1
- 장신구 2

### 설계 원칙

- 슬롯 수는 적되 역할은 분명해야 한다.
- 무기와 보조 마도구는 공격/운용 핵심 축이다.
- 방어구는 생존과 자원 운용 보정 축이다.
- 장신구는 속성 특화, 버프 특화, 설치 특화 같은 세부 빌드 축이다.

## 최소 장비 옵션

### 공통 전투 옵션

- `magic_attack`
- `max_hp`
- `max_mp`
- `mp_regen`
- `cooldown_recovery`
- `cast_speed`
- `damage_taken_multiplier`

### 속성 특화 옵션

- `fire_damage_multiplier`
- `water_damage_multiplier`
- `ice_damage_multiplier`
- `lightning_damage_multiplier`
- `wind_damage_multiplier`
- `earth_damage_multiplier`
- `plant_damage_multiplier`
- `dark_damage_multiplier`
- `holy_damage_multiplier`

### 운용 특화 옵션

- `buff_duration_multiplier`
- `installation_duration_multiplier`
- `projectile_speed_multiplier`
- `projectile_count_bonus`
- `aoe_radius_multiplier`
- `barrier_power_multiplier`

## 데이터 구조 권장

### 권장 파일

- `data/items/equipment.json`

### 최소 필드

- `item_id`
- `display_name`
- `slot_type`
- `rarity`
- `description`
- `stat_modifiers`
- `tags`
- `icon_path`

### 예시 방향

- 화염 특화 지팡이
- 번개 연사 보조 마도구
- 버프 지속 투구
- 마나 회복 로브
- 설치 지속 장신구

## 인벤토리와 장착 구조

### 인벤토리 최소 요구사항

- 아이템 ID 목록 저장
- 중복 장비 보유 허용
- 관리자 모드에서 즉시 추가 가능

### 장착 최소 요구사항

- 슬롯별 현재 장착 아이템 ID
- 장비 교체 시 이전 장비는 인벤토리로 복귀
- 장비 해제 가능
- 장착 후 즉시 최종 스탯 재계산

## 계산 방향

### 최종 전투 계산 순서 권장

1. 기본 캐릭터 수치
2. 장비 평면 가산
3. 스킬 레벨 기반 변화
4. 일반 버프와 유지형 보정
5. 마스터리 최종 배수
6. 조합 효과 최종 배수 또는 특수 처리

### 장비 반영이 필요한 대상

- 스킬 피해
- 마나 소모
- 쿨타임
- 버프 지속시간
- 설치 유지시간
- 보호막량
- 투사체 속도
- 범위형 스킬 반경

## 전투 샌드박스 연결

### 최소 관리자 기능

- 장비 즉시 지급
- 슬롯별 장착
- 전 장비 해제
- 장비 프리셋 3개 정도 즉시 적용

### 권장 프리셋

- 화염 폭딜형
- 번개 연사형
- 버프 지속형

## 예상 구현 파일

- 새 `data/items/equipment.json`
- [game_database.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd)
- [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- 새 `scripts/player/equipment_manager.gd`
- [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)
- 이후 관리자 메뉴 파일
- 새 테스트 파일 또는 기존 테스트 확장

## 세부 작업 체크리스트

### 1. 장비 데이터 추가

- JSON 스키마 정의
- 기본 장비 8~12개 작성
- 슬롯/희귀도/태그 구조 확정

### 2. 로더 추가

- 장비 JSON 파싱
- ID 기반 조회 함수
- 전체 목록 조회 함수

### 3. 장착 구조 추가

- 인벤토리
- 슬롯별 장착 정보
- 장착/해제/교체 함수

### 4. 최종 스탯 계산

- 기본 스탯 + 장비 합산
- 속성별 보정
- 버프 지속과 설치 지속 보정
- 스킬 계산식 연결

### 5. 샌드박스 연결

- 관리자 없이도 기본 장비 테스트 가능하도록 초기 장비 세트 지정 가능
- 이후 관리자 메뉴에서 즉시 지급/장착할 수 있는 훅 준비

## 수용 기준

- 장비를 장착하면 전투 수치가 즉시 바뀐다.
- 최소 3가지 빌드 차이가 실제로 체감된다.
- 장비 데이터는 JSON으로 분리되어 튜닝 가능하다.
- 스킬, 버프, 장비 계산이 서로 충돌하지 않는다.
- 대표 장비 3빌드가 `fire_bolt`, `wind_gale_cutter`, `stone_spire`에 대해 실제 전투 결과 차이를 만든다.
- `brute`, `leaper`, `elite` 3상황에서 장비 선택에 따른 차이가 GUT로 고정 가능하다.

## 테스트 체크포인트

### GUT

- 장비 데이터 로드
- 장비 장착/해제
- 슬롯 교체
- 최종 스탯 계산
- 속성별 피해 증가 반영
- 버프 지속시간 증가 반영
- `fire_bolt` + 속성 특화 장비 vs 비특화 장비의 `brute` 피해 차이
- `wind_gale_cutter` + 운용 특화 장비의 `leaper` 상대 운용 차이
- `stone_spire` + 설치 특화 장비의 `elite` 상대 유지시간 또는 누적 피해 차이
- 최소 `대표 장비 3빌드 × 대표 스킬 3종 × 대표 적 3상황` 교차 검증
- 현재 통과한 대표 회귀:
  - `fire_burst / fire_bolt / brute`
  - `wind_tempo / wind_gale_cutter / leaper`
  - `earth_deploy / earth_stone_spire / elite`
  - `sanctum_sustain / Prismatic Guard + sustain runtime`
- `holy_guard / holy_radiant_burst + Prismatic Guard`
- `dark_shadow / dark_void_bolt / brute`
- `arcane_pulse / arcane_force_pulse / brute`

### 헤드리스

- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

## 비목표

- 장비 등급업
- 랜덤 드롭 확률 튜닝
- 장비 세트 패시브
- 외형 장착 연출

## 다음 증분

이 작업이 끝나면 다음은 `전투 UI 구축`이다. 그때는 HP/MP, 스킬 슬롯, 버프, 조합, 장비 핵심 스탯, 대상 몬스터 상태를 읽기 쉬운 HUD로 정리한다.

## Claude 바로 다음 작업

Claude는 다음 순서로 이어서 작업하면 된다.

1. 관리자 메뉴에서 장비 프리셋뿐 아니라 `개별 슬롯 장비 교체`를 지원한다.
2. 장비 상태를 `무기`, `보조`, `장신구` 단위로 더 잘 보이게 만든다.
3. 전투 중 장비 차이가 더 강하게 느껴지도록 수치를 조정한다.

## 추가 구현 (2026-03-28)

### barrier_power_multiplier + cast_speed 전투 계산 연결

- `game_state.gd` — `get_equipment_barrier_power_multiplier()` 추가: `barrier_power_multiplier` stat 곱으로 계산. `ring_sanctum_loop` 장착 시 1.15 반환.
- `game_state.gd` — Prismatic Guard combo_barrier 계산에 `* get_equipment_barrier_power_multiplier()` 적용: 보호막 장비가 실제 배리어 크기에 반영됨.
- `game_state.gd` — `get_equipment_cast_speed_bonus()` 추가: `cast_speed` stat 합산 반환.
- `spell_manager.gd _build_skill_runtime()` — `tick_interval`에 `maxf(0.6, 1.0 - get_equipment_cast_speed_bonus())` 적용: `helm_spark_diadem` 장착 시 토글 틱이 빨라짐.
- GUT 2개 추가: `ring_sanctum_loop` 배리어 배율 검증, `helm_spark_diadem` 캐스트 속도 보너스 검증.
- 전체 211/211 통과.

### 적 사망 시 장비 드롭 시스템 (2026-03-29 완료)

- `game_database.gd` — `get_drop_pool_for_profile(profile)`: 프로필별 허용 희귀도 필터로 equipment_catalog에서 item_id 배열 반환.
  - `none`: 항상 빈 배열
  - `common`: `uncommon` 희귀도 아이템만
  - `elite`: `uncommon` + `rare`
  - `rare`: `uncommon` + `rare` + `epic` + `legendary`
- `game_database.gd` — `get_drop_for_profile(profile) -> String`: 프로필별 확률(common 20%, elite 35%, rare 50%) 롤 후 풀에서 랜덤 item_id 반환. 확률 미달 또는 풀 없으면 `""` 반환.
- `main.gd _on_enemy_died()` — `GameDatabase.get_enemy_data(enemy.enemy_type)`로 `drop_profile` 읽은 뒤 드롭 아이템 선정. 아이템 있으면 `GameState.grant_equipment_item()` + UI 메시지 표시.
- GUT 6개 추가 (test_equipment_system): none 풀 빈 배열, unknown 풀 빈 배열, common 풀 uncommon만, rare 풀 양쪽 포함, none 항상 빈 문자열 반환, elite 풀 rare 포함.
- 전체 248/248 통과.

### 세션 처치/드롭 카운터 + 관리자 자원 탭 통계 (2026-03-29 완료)

- `game_state.gd` — `session_kills: int`, `session_drops: int`, `last_drop_display: String` 변수 추가
- `notify_enemy_killed()` — `session_kills += 1` 추가
- `record_item_drop(item_id)` 함수 추가: `session_drops` 증가 + `last_drop_display` 갱신
- `reset_progress_for_tests()` — 세 변수 초기화 추가
- `main.gd _on_enemy_died()` — 드롭 발생 시 `GameState.record_item_drop(dropped_item)` 호출
- `admin_menu.gd _get_resource_tab_lines()` — `Session Kills/Hits/DMG/Drops` 한 줄 + `Last drop` 줄 추가
- GUT 3개 추가: notify_enemy_killed 처치 카운터, record_item_drop 드롭 카운터, reset 후 모두 초기화
- 전체 251/251 통과.

### common 희귀도 장비 추가 + 드롭 풀 확장 (2026-03-29 완료)

- `equipment.json` — `common` 희귀도 장비 4개 추가:
  - `weapon_worn_focus` (weapon, common): magic_attack +1.5
  - `armor_cloth_wrap` (body, common): max_hp +8
  - `ring_copper_band` (accessory_1, common): mp_regen +2
  - `helm_iron_band` (head, common): damage_taken_multiplier 0.97
- `game_database.gd DROP_RARITY_FILTER` — "common" 프로필에 `["common", "uncommon"]` 포함, "elite"에 `["common", "uncommon", "rare"]` 포함으로 확장
- 효과: common 적(brute, ranged 등) 처치 시 4종 common + 2종 uncommon 아이템 풀에서 드롭 가능 (이전: 2종 uncommon만)
- test_equipment_system.gd: `test_drop_pool_common_only_contains_uncommon_items` → `test_drop_pool_common_only_contains_common_and_uncommon_items` 로 교체 + `test_drop_pool_common_contains_common_rarity_items` 신규 추가
- test_admin_menu.gd: weapon 슬롯 아이템 수 3→4 변화로 `Items 1-3/3` → `Items 1-4/4`, `[1/3]` → `[1/4]`, `[2/3]` → `[2/4]` 일괄 수정 (13개 항목)
- 전체 252/252 통과.

### Owned/Candidate Detail 줄 설명+태그 분리 (2026-03-29 완료)

- **의도**: `_get_selected_owned_equipment_meta_line()` / `_get_selected_candidate_meta_line()`이 설명과 태그를 한 줄로 합쳐 반환 → side-by-side 패널에서 60자 컬럼 한계로 `~` 잘림 발생
- **파일**: `admin_menu.gd`
  - 두 함수 모두 `"...  Tags:%s"` 대신 `"...\nTags:%s"` 반환(개행 구분)
  - `_build_equipment_panel_content_section_lines()` — `detail_line.split("\n")` 반복으로 각 서브라인을 개별 줄로 추가
- **결과**: 설명 줄과 Tags: 줄이 분리되어 각각 컬럼 폭 이내로 렌더링. 긴 설명도 잘림 없이 표시 가능
- **검증**: 기존 테스트 259/259 통과 — Tags: 검색은 `body_label.text` 내 포함 여부만 확인하므로 줄 분리 후에도 통과
