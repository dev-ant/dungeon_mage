---
title: 현재 런타임 기준선
doc_type: baseline
status: active
section: implementation
owner: runtime
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
update_when:
  - runtime_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 현재 런타임 기준선

상태: 기준 문서  
최종 갱신: 2026-04-02

## 목적

이 문서는 `docs/implementation`, `docs/collaboration`, `docs/superpowers` 사이에서 실제 코드와 맞는 현재 기준선을 하나로 고정한다.

장기 플랜 문서나 초기 설계 문서에 남아 있는 과거 가정이 있더라도, 구현 판단은 이 문서를 우선한다.

## progression 문서와의 관계

- 최신 기획:
  - 스킬의 최신 이름, 속성, 서클, 컨셉, 레벨 성장 목표는 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)를 따른다.
- 몬스터 roster / 역할:
  - 어떤 적이 정식 편입 대상인지, 어떤 역할을 맡는지는 [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md)를 따른다.
- 실제 런타임 사실:
  - 현재 실제로 동작하는 runtime ID, 프록시 구현, 코드 경로는 이 문서와 실제 코드를 따른다.
- 상태 추적:
  - 구현 / asset / attack effect / hit effect / 레벨 스케일 상태는 [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)에서 관리한다.
- 몬스터 상태 추적:
  - 적의 구현 / 에셋 반영 / 테스트 반영 상태는 [enemy_content_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md)에서 관리한다.
- 데이터 스키마:
  - canonical `skill_id`, enum-like 허용값, JSON 필드 구조는 [skill_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md)를 따른다.
- 몬스터 데이터 스키마:
  - `data/enemies/enemies.json` 필드 구조와 validation 기준은 [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md)를 따른다.
- 충돌 처리:
  - 최신 기획과 현재 구현이 다르면 이 문서와 코드가 `현재 사실`을 결정한다.
  - 이후 [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)를 갱신하고, 필요하면 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)를 조정한다.

## 몬스터 문서 체계

몬스터 관련 문서는 아래 순서로 함께 읽는다.

1. roster / 역할 / 편입 우선순위:
   - [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md)
2. 필드 구조 / 허용값 / validation:
   - [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md)
3. 구현 / 에셋 / 테스트 반영 상태:
   - [enemy_content_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md)
4. 전투 수치 규칙 / 최종 피해 계산:
   - [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)
5. 현재 빌드 사실:
   - 이 문서와 실제 코드 / 데이터

## 스킬 식별자 규칙

- 현재 코드의 runtime ID와 최신 기획의 canonical `skill_id`는 다를 수 있다.
- 현재 빌드 사실을 설명할 때는 runtime ID를 우선 사용한다.
- 최신 설계나 장기 데이터 정렬이 필요할 때는 [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)의 `canonical skill_id` 열을 함께 본다.
- runtime ID가 바뀌더라도 canonical `skill_id`는 장기 식별자로 유지한다.

## canonical 마이그레이션 기준선

- 2026-04-02 기준으로 `data/skills/skills.json`의 전체 `42/42` row에 `canonical_skill_id`가 명시됐다.
- row-level canonical 마이그레이션은 완료됐고, 이후 후속 작업은 새 canonical 부착이 아니라 검증과 운영 문서 정리다.
- `GameDatabase.get_skill_data(skill_id)`의 alias lookup은 계속 호환 경로로 유지한다. save, hotbar, admin, runtime에서 예전 row key 또는 proxy를 참조하더라도 우선 이 경로를 기준으로 해석한다.
- `holy_healing_pulse`, `dark_abyss_gate`, `lightning_tempest_crown`, `plant_genesis_arbor`는 `Phase 6` 결론에 따라 row key rename 없이 유지한다.
- runtime proxy가 이미 존재하던 row는 canonical 명시 완료 이후에도 현재 연결을 그대로 유지한다.
  - `holy_healing_pulse` -> `holy_radiant_burst`
  - `dark_abyss_gate` -> `dark_void_bolt`
  - `water_bullet` -> `water_aqua_bullet`
  - `plant_root_bind` -> `plant_vine_snare`
- canonical `skill_id`와 runtime ID가 같아졌더라도, 현재 빌드 사실을 말할 때는 여전히 코드와 실제 런타임 경로를 우선 확인한다.
- 후속 운영 기준선의 우선 순위는 아래와 같다.
  - mastery / buff / deploy row의 effect / level scaling 검증 상태를 `verified`까지 끌어올린다.
  - mastery XP 검증은 school-bearing runtime entry가 있는 row부터 닫는다. 현재 `fire`/`water`/`ice`/`lightning`/`wind`/`earth`에 더해 `plant`도 `register_skill_damage()` 경유 progression hook을 확인했다. `plant_vine_snare`는 이제 `data/spells.json`의 plant school runtime spell entry로 유지한다.
  - `Phase 6` row key 유지 결론에 맞춰 save / UI / runtime 잔여 리스크를 재검토한다.
  - 필요하면 이 문서와 tracker의 검증 상태를 같은 턴에 함께 끌어올린다.

## 현재 구현 기준

- 스킬 런타임은 `Dictionary` 기반이다.
- 스킬 계산 진입점은 `GameState.get_spell_runtime(skill_id)` 이다.
- `SpellResource` 클래스 전제는 현재 코드 기준이 아니다.
- 플레이어/적 상태 차트는 런타임에 조립한다.
- `player_state_chart.tres` 같은 상태 차트 리소스는 현재 필수 파일이 아니다.
- 씬 조립의 기준점은 [`scenes/main/Main.tscn`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scenes/main/Main.tscn) 이다.
- 플레이어는 현재 `Main.tscn` 내부에서 조립되며 `scenes/player/Player.tscn` 전제는 사용하지 않는다.
- 런타임 에셋 참조는 반드시 `res://assets/...` 만 사용한다.
- `asset_sample/` 는 원본 드롭존이자 분석 소스이며, 코드/씬의 직접 참조 대상이 아니다.
- `GameState` 는 기존 public API 를 유지하면서 내부적으로 `CombatRuntimeState` 와 `ProgressionSaveState` 로 역할을 나누기 시작했다.
- 적 공통 런타임은 [`enemy_base.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/enemies/enemy_base.gd) 를 유지하되, 비주얼/공격 프로필은 helper 로 분리한다.
- 적 스탯 체계와 최종 피해 계산은 [`enemy_stat_and_damage_rules.md`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md) 를 기준으로 유지한다.
- 적 데이터는 `data/enemies/enemies.json` 에서 방어력, 속성 저항, 상태이상 저항, 슈퍼아머, 취약 배수까지 관리한다.
- `GameDatabase` enemy loader는 현재 `enemy_grade`, `drop_profile`, `role`, `attack_damage_type`, `attack_element` enum validation과 duplicate `enemy_id` 검증을 수행하며, `role`, `attack_damage_type`, `attack_element`, `attack_period`, `drop_profile`, `knockback_resistance` 필수 필드 존재, `super_armor_tags`의 `Array[String]` 구조, 속성 저항 10종과 상태이상 저항 8종의 필수 존재도 강제한다.
- `enemy_base.gd`는 fallback 경로를 유지하되, 런타임에 empty `display_name`은 타입명 기반 표시명으로, empty 또는 invalid `enemy_grade`는 타입 기본 등급으로, unknown `attack_damage_type`은 `physical`, unknown `attack_element`는 `none`으로 경고와 함께 정규화한다.
- 엘리트는 현재 `standalone enemy_type "elite"` 와 `3% variant 승격`이 함께 존재하는 하이브리드 단계다.
- 적 상태이상은 저항 계산 경로를 8종 모두 가지며, 런타임 행동 효과는 `slow`와 `root/stun/freeze`부터 우선 연결되어 있다.

## 현재 핵심 파일

- [`scripts/autoload/game_state.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [`scripts/autoload/combat_runtime_state.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/combat_runtime_state.gd)
- [`scripts/autoload/progression_save_state.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/progression_save_state.gd)
- [`scripts/player/spell_manager.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd)
- [`scripts/enemies/enemy_base.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/enemies/enemy_base.gd)
- [`scripts/enemies/enemy_visual_library.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/enemies/enemy_visual_library.gd)
- [`scripts/enemies/enemy_attack_profiles.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/enemies/enemy_attack_profiles.gd)
- [`scripts/main/main.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/main/main.gd)

## 과거 문서 해석 규칙

- 초기 설계 문서에 `SpellResource`, `player_state_chart.tres`, `scenes/player/Player.tscn` 이 나오면 현재 구현 기준으로는 폐기된 가정으로 본다.
- `asset_sample/` 경로 링크는 원본 출처 설명으로만 읽고, 런타임 경로로 해석하지 않는다.
- `Main.tscn` 외 별도 조립 루트를 전제한 설명은 현재 빌드보다 오래된 설명일 수 있으므로 실제 코드와 대조한다.
- 적 수치, 데미지 감쇠, 저항, 슈퍼아머 규칙이 포함된 오래된 문서는 [`enemy_stat_and_damage_rules.md`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md) 와 대조한다.
- 몬스터 roster나 에셋 우선순위를 설명하는 오래된 증분 문서는 [`enemy_catalog.md`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md) 와 대조한다.
- 몬스터 반영 상태를 설명하는 오래된 작업 로그는 [`enemy_content_tracker.md`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md) 와 대조한다.

## 현재 코드-문서 일치 체크리스트

- [x] 스킬 런타임은 `Dictionary` 기반으로 설명된다.
- [x] 상태 차트는 런타임 조립 기준으로 설명된다.
- [x] 메인 조립 씬은 `Main.tscn` 으로 설명된다.
- [x] `asset_sample/` 직접 참조 금지 규칙이 명시된다.
- [x] 런타임 에셋 경로는 `assets/` 로 설명된다.
- [x] `GameState` 는 전투 런타임과 진행/저장을 내부 helper 로 분리한 현재 상태를 반영한다.
- [x] `EnemyBase` 는 helper 분리 기준을 반영한다.
- [x] `Main` 오케스트레이션은 통합 테스트 대상이라는 점이 반영된다.
- [x] 적 스탯 체계와 최종 피해 계산 기준 문서가 별도로 연결되어 있다.
- [x] 몬스터 카탈로그 / 스키마 / 상태 추적 문서 체계가 별도로 연결되어 있다.
