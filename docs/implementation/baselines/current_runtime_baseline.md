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
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 현재 런타임 기준선

상태: 기준 문서  
최종 갱신: 2026-04-03

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
- 2026-04-03 save / UI / runtime 잔여 리스크 재검토와 hotbar hardening 결과는 아래와 같다.
  - `low`: 기본 hotbar, 기본 loadout, admin named preset은 proxy active row에 대해 계속 runtime spell ID를 사용한다. 현재 확인된 안전 축은 `holy_radiant_burst -> holy_healing_pulse`, `dark_void_bolt -> dark_abyss_gate`, `plant_vine_snare -> plant_root_bind`, `lightning_tempest_crown -> lightning_tempest_crown`이다.
  - `low`: `GameDatabase.get_skill_data(skill_id)`의 canonical alias lookup과 `GameState.get_skill_id_for_spell(spell_id)` fallback 덕분에 save / admin detail / 문서형 조회는 canonical row key 유지 이후에도 계속 읽힌다.
  - `low`: `GameState.set_hotbar_skill()`는 이제 입력된 `skill_id`를 runtime-castable hotbar ID로 먼저 정규화한다. `holy_healing_pulse -> holy_radiant_burst`, `dark_abyss_gate -> dark_void_bolt`, `plant_root_bind -> plant_vine_snare`처럼 proxy active / deploy canonical row를 직접 넣어도 저장값은 실제 시전 가능한 runtime ID로 수렴한다.
  - `low`: save payload의 canonical field는 이제 `spell_hotbar` 첫 10슬롯만 기록한다. 내부 13슬롯 런타임은 유지하되, 나머지 3슬롯은 `legacy_spell_hotbar_tail` 호환 필드에 분리 저장한다.
  - `low`: `load_save()`는 `10슬롯 canonical + legacy tail` 신규 save와 과거 `13슬롯 spell_hotbar` save를 둘 다 읽는다. 과거 save에 남은 stale invalid ID는 hotbar 초기화 시 proxy runtime ID로 치환되거나, 대응 runtime ID가 없으면 슬롯 기본값으로 되돌린다.
  - `low`: explicit `visible_hotbar_shortcuts` payload가 없는 old save도 첫 10슬롯의 `action + label`을 읽어 visible shortcut profile을 재구성한다. 이 경로 덕분에 legacy save는 HUD label과 keyboard input을 같이 복원할 수 있다.
  - `low`: owner_core는 GUI shell 연결용 비파괴 bridge API를 추가했다. `GameState.get_visible_spell_hotbar()`, `get_hotbar_slot()`, `clear_hotbar_skill()`, `swap_hotbar_skills()`와 `spell_manager/player` wrapper는 현재 `13슬롯` 저장 구조를 유지한 채 `첫 10슬롯 가시 row`, tooltip payload, unbind, swap 상호작용을 읽고 쓸 수 있게 한다.
  - `low`: visible hotbar shortcut rebind persistence는 이제 `GameState.get_visible_hotbar_shortcuts()`, `set_visible_hotbar_shortcut()`, `reset_visible_hotbar_shortcuts_to_default()`와 `player` wrapper까지 닫혀 있다. 현재 운영 결론은 GUI가 `10슬롯 visible HUD`를 구현할 때 canonical save field와 shortcut payload를 바로 사용하되, legacy 3슬롯 tail과 13슬롯 old save도 계속 호환할 수 있다는 것이다.
  - `low`: 전투 입력 canonical 은 이제 `spell_manager` 기준으로 visible 10슬롯만 읽는다. 즉 hidden legacy tail slot은 배열/호환 save에는 남아도 keyboard combat primary path에서는 더 이상 직접 시전되지 않는다.
  - 현재 운영 결론은 `Phase 6` row key 유지 자체와 hotbar/save hardening이 모두 안전하다는 것이다. 남은 후속 작업은 canonical 식별자 재판정이 아니라 대표 active / buff / deploy row의 effect 검증 확대다.
- 2026-04-03 `fire_mastery` runtime wiring 결과는 아래와 같다.
  - `data/skills/skills.json`의 `fire_mastery` row는 이제 `final_multiplier_per_level = 0.05`를 사용한다.
  - `GameState.get_spell_runtime()`와 `scripts/player/spell_manager.gd`의 data-driven runtime builder는 fire school `active / deploy / toggle`의 `damage`와 `cooldown`에 fire mastery를 먼저 적용한 뒤 장비 / 버프 / 공명을 적용한다.
  - `GameState.get_skill_mana_cost()`와 `spell_manager`의 toggle sustain cost helper는 fire mastery milestone의 마나 감소를 buff `mana_efficiency_multiplier`보다 먼저 읽는다.
  - GUT 기준선으로는 `fire_mastery` lv10에서 `fire_bolt` 피해가 `26`, `weapon_ember_staff` 장착 시 `34`, cooldown이 `0.2134`가 되는 상태를 잠갔다.
  - 이번 구조 개선 후속 증분에서 school-specific mastery modifier stack은 `fire_mastery` 단일 하드코딩이 아니라 `SCHOOL_TO_MASTERY` + mastery row data를 읽는 shared helper로 옮겼다.
  - representative regression은 `water_aqua_bullet` active, `plant_vine_snare` deploy, `dark_grave_echo` toggle의 damage / cooldown / mana contract로 잠갔다.
  - `arcane_magic_mastery`는 `applies_to_school = all`, `applies_to_element = all`인 global mastery 예외라서 이번 school-specific helper 증분에는 포함하지 않았다.
- 2026-04-03 구조 개선 증분으로 common runtime scaling source of truth는 아래처럼 정리됐다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_common_runtime_stat_block()`이 active / deploy / toggle 공통의 level scaling, mastery modifier, equipment multiplier 적용을 담당한다.
  - 같은 파일의 `get_common_scaled_mana_value()`가 direct mana cost와 toggle sustain mana cost의 공통 scaling을 담당한다.
  - `GameState.get_spell_runtime()`와 `scripts/player/spell_manager.gd`의 `_build_skill_runtime()`는 공통 stat helper를 먼저 호출한 뒤 각 타입별 후처리를 얹는다.
  - `GameState.get_skill_mana_cost()`와 `scripts/player/spell_manager.gd`의 `_get_toggle_mana_drain_per_tick()`는 공통 mana helper를 먼저 호출한 뒤 buff 등 type-specific 후처리를 얹는다.
  - `GameState.get_mastery_runtime_modifiers_for_skill()`는 이제 school-specific mastery row를 data-driven으로 읽고, `applies_to_school = all` / `applies_to_element = all`인 global mastery 예외는 별도 후속 증분으로 남긴다.
  - active buff 후처리는 `_apply_buff_runtime_modifiers()`, deploy 전용 후처리는 `apply_deploy_buff_modifiers()`, toggle tick payload 후처리는 `apply_spell_modifiers()`에 남아 있다.
  - 이후 새 mastery / buff / equipment 계산 규칙은 이 공통 runtime helper에 먼저 추가하는 것이 구현 기준이다.
- 2026-04-03 구조 개선 후속 증분으로 runtime spell ↔ canonical skill 연결 source of truth는 아래처럼 정리됐다.
  - `data/spells.json`의 `source_skill_id`와 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`가 구성하는 중앙 mapping table이 forward / reverse lookup 기준이다.
  - `GameState.get_skill_id_for_spell()`와 `GameState.get_runtime_castable_hotbar_skill_id()`는 이제 코드 상수 역탐색이 아니라 이 `GameDatabase` mapping을 먼저 읽는다.
  - hotbar assignment normalization, saved hotbar normalization, admin library assignment, spell manager slot assignment는 같은 중앙 mapping source를 재사용한다.
  - 이후 새 proxy-active / runtime spell 연결은 코드 상수 추가가 아니라 `spells.json` `source_skill_id`와 `GameDatabase` mapping에 먼저 등록하는 것이 구현 기준이다.
- 2026-04-03 구조 개선 후속 증분으로 admin skill library source of truth는 아래처럼 정리됐다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`의 `get_runtime_castable_skill_catalog()`가 실제 배치 가능한 runtime-castable 전체 목록을 구성한다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd`는 더 이상 일부 active seed를 하드코딩하지 않고, 이 catalog에 빈 슬롯 항목만 덧붙여 렌더링한다.
  - admin -> hotbar assignment -> save/load -> runtime cast 흐름은 이제 runtime-castable ID 기준으로 같은 catalog/mapping 계약을 공유한다.
  - 이후 새 스킬을 admin에서 배치 가능하게 만들려면 하드코딩 목록이 아니라 `GameDatabase` 중앙 mapping과 runtime-castable 판정을 먼저 만족시켜야 한다.
- 2026-04-03 구조 개선 후속 증분으로 progression data validation source of truth는 아래처럼 정리됐다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`가 로드 시점에 `validate_skill_entry()`, `validate_spell_entry()`, `validate_skill_spell_link()`, `validate_spell_skill_link()`, `validate_buff_combo_entry()`, `validate_buff_combo_links()`를 실행한다.
  - 현재 hardening 범위에서 `skills.json`은 최상위 `{"skills": [...]}` 구조를 고정하고, 각 row의 `canonical_skill_id`, `role_tags`, `growth_tracks`, `unlock_state`, active-family `hit_shape`, buff 전용 `buff_category` / `stack_rule_id` / `combo_tags`를 조기 검출한다.
  - `buff_category`는 open tag가 아니라 closed 관리 ID라서, [buff_category_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_category_catalog.md) 밖 값이 들어오면 바로 `error`로 막는다.
  - buff row는 `buff_category`와 같은 값을 `role_tags`에도 포함해야 한다. 이 교차 필드 계약이 깨지면 로드 시점 `error`다.
  - `stack_rule_id`는 open tag가 아니라 closed 관리 ID라서, [buff_stack_rule_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_stack_rule_catalog.md) 밖 값이 들어오면 바로 `error`로 막는다.
  - `role_tags`, `growth_tracks`, `combo_tags`는 current catalog 기준과 어긋나면 `warning`을 남기고, 구조 위반만 `error`로 막는다.
  - `lightning_conductive_surge.extra_lightning_ping`, `ice_frostblood_ward.ice_reflect_wave`처럼 후속 payload를 발사하는 buff row는 같은 `buff_effects` 안에 `*_effect_id / *_damage_ratio / *_radius / *_school / *_color` companion row를 함께 둔다. 이 config row는 `mode = set`으로 고정하고, load-time validation이 누락/타입/school drift를 조기 검출한다.
  - `dark_throne_of_ash`의 solo ash residue gate source of truth는 같은 row의 `buff_effects.ash_residue_burst`다. 이 stat은 현재 runtime trigger flag라서 `mode = add`와 양수 numeric value를 유지해야 하며, validator가 깨진 row를 조기 검출한다.
  - `skills.json`의 `element = none`은 스킬 row에서만 허용하고, `spells.json.school`은 계속 runtime cast school enum만 허용한다.
  - `spells.json`은 필수 runtime 필드, proxy-active 연결 누락, spell school ↔ skill element drift를 계속 조기 검출한다.
  - `buff_combos.json`은 최상위 `{"combos": [...]}` 구조, 최소 필수 필드, `combo_type` enum, `required_buffs -> actual buff row` 링크를 조기 검출한다.
  - `buff_combos.json`의 `applied_effects[].mode` / `penalties[].mode`는 현재 `set` / `add` / `mul`, `trigger_rules[].event`는 현재 runtime이 읽는 4개 event만 허용한다.
  - 같은 hardening 축에서 `trigger_rules[].damage_school`은 runtime spell school enum으로 잠그고, `trigger_rules[].stack_name / scales_with_stack`는 현재 `ash` closed key와 same-combo reference 규칙으로 잠근다.
  - `trigger_rules[].apply_status`는 아직 generic consumer가 없어서 current catalog 기준 warning-only drift check로만 관리한다.
  - `buff_combos.json`의 `effect_tags`는 current catalog 기준과 어긋나면 `warning`을 남기고, 구조 위반만 `error`로 막는다.
  - 2026-04-05 준비 증분으로 `Prismatic Guard`의 `effect_tags.poise_ignore / shield / shockwave`를 runtime 승격 후보 태그 세트로 분류했다. validator는 각각 `holy_crystal_aegis.buff_effects.super_armor_charges`, `combo_prismatic_guard.applied_effects.max_hp_barrier_ratio`, `combo_prismatic_guard.trigger_rules[on_barrier_break].spawn_effect / radius` backing source를 `warning-only`로 감시한다.
  - 같은 날짜 다음 증분으로 `Prismatic Guard` barrier source도 `combo_prismatic_guard.applied_effects.max_hp_barrier_ratio`를 직접 읽는다. 이 stat은 현재 `mode = add`와 양수 numeric value를 유지하는 required runtime contract이고, barrier break effect도 계속 `trigger_rules.on_barrier_break.spawn_effect / radius`를 직접 읽는다.
  - 같은 날짜 다음 정리로 `combo_prismatic_guard`의 예전 `hitstun_resist_mode` row는 제거했다. 현재 운영 기준에서 combo 자체가 읽는 안정성 field는 barrier ratio뿐이며, 피격 경직 무시는 계속 `holy_crystal_aegis.buff_effects.super_armor_charges`가 담당한다.
  - 같은 날짜 다음 증분으로 `Overclock Circuit`도 `combo_overclock_circuit.applied_effects.lightning_aftercast_multiplier / lightning_chain_bonus / dash_cast_speed_multiplier`를 직접 소비하는 required runtime contract로 승격됐다. 현재 운영 기준은 각각 `mul`, `add`, `mul` mode와 numeric value다.
  - 같은 날짜 다음 증분으로 `Time Collapse` opening charge도 더 이상 코드 상수 `3`이 아니라 `combo_time_collapse.applied_effects.discounted_cast_charges`를 직접 읽는다. 이 stat은 현재 runtime required contract라서 `mode = set`과 양수 numeric value를 유지해야 한다.
  - 같은 날짜 후속 증분으로 `GameState.notify_deploy_kill()`의 Funeral Bloom payload와 ICD도 더 이상 하드코딩하지 않고 `combo_funeral_bloom` row의 `internal_cooldown`과 `on_deploy_kill` rule(`spawn_effect`, `radius`, `damage_school`, `apply_status`, `color`)을 직접 읽는다.
  - 같은 날짜 다음 증분으로 `Ashen Rite`도 `combo_ashen_rite` row에서 `on_spell_hit.max_stacks`, `applied_effects.ash_residue_interval / ash_residue_effect_id / ash_residue_damage / ash_residue_damage_per_stack / ash_residue_radius / ash_residue_school / ash_residue_color`, `on_combo_end.spawn_effect / damage_school / color / damage / damage_per_stack / radius / radius_per_stack`, `penalties`를 직접 읽는다.
  - 같은 날짜 다음 증분으로 Funeral Bloom `on_deploy_kill` payload field와 Ashen Rite residue/end payload field는 이제 combo 전용 required runtime contract로 승격됐다. validator가 누락/잘못된 타입을 먼저 막기 때문에, runtime은 더 이상 이전 gameplay fallback literal에 의존하지 않는다.
  - 같은 날짜 다음 증분으로 `GameState.apply_spell_modifiers()`의 `lightning_ping`, `ice_reflect_wave` 후속 payload도 literal dict를 하드코딩하지 않고, 각각 `lightning_conductive_surge`, `ice_frostblood_ward` row의 companion `buff_effects` authored 값을 직접 읽는다.
  - 같은 날짜 다음 증분으로 solo `ash_residue_burst` 발사 조건도 generic active effect 스캔이 아니라 `dark_throne_of_ash` row의 `ash_residue_burst` trigger flag를 직접 읽게 정리했다.
  - 현재 정상 데이터는 이 validation을 통과해야 하고, 이후 새 skill / spell / proxy 연결 추가 시 validation 갱신도 같은 구현 단위에 포함된다.
- 2026-04-03 구조 개선 후속 증분으로 runtime school source of truth는 아래처럼 정리됐다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `resolve_runtime_school()`가 school 판정의 단일 helper다.
  - 우선순위는 `runtime spell row.school -> linked/canonical skill row.element -> linked/canonical skill row.school -> caller hint`다.
  - `register_spell_use()`, `register_skill_damage()`, `get_mastery_runtime_modifiers_for_skill()`, `get_spell_runtime()`, `scripts/player/spell_manager.gd`의 tooltip/runtime payload는 이 helper를 같이 본다.
  - school 충돌은 기존 validation이 spell school ↔ skill element drift를 먼저 잡고, 런타임에서는 위 우선순위로 해석한다.
- 2026-04-03 hardening 증분으로 runtime scaling option 기본값 source of truth도 아래처럼 정리됐다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_active_spell_runtime_options()`와 `build_data_driven_skill_runtime_options()`가 active / deploy / toggle 경로가 `build_common_runtime_stat_block()`에 넘기는 scaling option 세트를 만든다.
  - `GameState.get_spell_runtime()`와 `scripts/player/spell_manager.gd`의 `_build_skill_runtime()`는 이제 level / school / mastery / equipment scaling option 기본값을 개별 딕셔너리로 중복 정의하지 않고 이 builder를 먼저 읽는다.
- 2026-04-03 hardening 증분으로 data-driven deploy / toggle base runtime block source of truth도 아래처럼 정리됐다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_data_driven_skill_base_runtime()`가 damage formula, base cooldown / duration / size, tick interval, knockback, milestone pierce, utility_effects의 초기 블록을 만든다.
  - `scripts/player/spell_manager.gd`의 `_build_skill_runtime()`는 이제 이 초기 블록을 공통 runtime stat helper에 넘기고, 이후 toggle drain / tick speed 같은 후처리만 덧붙인다.
- 2026-04-03 hardening 후속 증분으로 data-driven deploy / toggle final runtime source of truth도 아래처럼 정리됐다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `get_data_driven_skill_runtime()`가 common stat helper, tick interval post-scale, sustain mana drain까지 포함한 최종 runtime을 조립한다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `get_data_driven_skill_mana_drain_per_tick()`가 toggle sustain mana drain 계산을 담당한다.
  - `scripts/player/spell_manager.gd`의 `_build_skill_runtime()`와 `_get_toggle_mana_drain_per_tick()`는 이제 이 helper들에 위임만 한다.
- 2026-04-03 hardening 다음 증분으로 data-driven deploy / toggle cast payload seed source of truth도 아래처럼 정리됐다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_data_driven_combat_payload()`가 deploy / toggle payload의 공통 필드를 조립한다.
  - `scripts/player/spell_manager.gd`의 `_cast_deploy()`와 toggle tick payload path는 이 helper를 먼저 읽고, 위치와 타입별 후처리만 덧붙인다.
- 2026-04-03 hardening 다음 증분으로 representative runtime payload contract coverage도 아래처럼 정리됐다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_spell_manager.gd`는 `fire_bolt` active, `plant_root_bind -> plant_vine_snare` deploy, `lightning_tempest_crown` toggle, `holy_healing_pulse -> holy_radiant_burst` canonical proxy-active의 payload 계약을 잠근다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd`는 admin library assignment 이후 hotbar/save/runtime cast가 `holy_radiant_burst` payload 계약으로 이어지는지 잠근다.
  - 현재 운영 기준은 새 스킬/새 payload 구조 변경 시 source helper와 함께 representative payload contract test도 같은 턴에 갱신하는 것이다.

## 현재 구현 기준

- 스킬 런타임은 `Dictionary` 기반이다.
- 스킬 계산 진입점은 `GameState.get_spell_runtime(skill_id)` 이다.
- active / deploy / toggle 공통 scaling source of truth는 `GameState.build_common_runtime_stat_block()`과 `GameState.get_common_scaled_mana_value()`다.
- active / deploy / toggle scaling option 기본값 source of truth는 `GameState.build_active_spell_runtime_options()`와 `GameState.build_data_driven_skill_runtime_options()`다.
- data-driven deploy / toggle base runtime block source of truth는 `GameState.build_data_driven_skill_base_runtime()`다.
- data-driven deploy / toggle final runtime source of truth는 `GameState.get_data_driven_skill_runtime()`와 `GameState.get_data_driven_skill_mana_drain_per_tick()`다.
- data-driven deploy / toggle cast payload seed source of truth는 `GameState.build_data_driven_combat_payload()`다.
- representative runtime payload contract regression 기준은 `tests/test_spell_manager.gd`와 `tests/test_admin_menu.gd`의 payload contract tests다.
- runtime spell ↔ canonical skill 연결 source of truth는 `GameDatabase`의 중앙 mapping table이다.
- admin skill library source of truth는 `GameDatabase.get_runtime_castable_skill_catalog()`다.
- `skills.json / spells.json` validation source of truth는 `GameDatabase`의 validation helper 묶음이다.
- runtime school source of truth는 `GameState.resolve_runtime_school()`다.
- `SpellResource` 클래스 전제는 현재 코드 기준이 아니다.
- 플레이어/적 상태 차트는 런타임에 조립한다.
- `player_state_chart.tres` 같은 상태 차트 리소스는 현재 필수 파일이 아니다.
- 씬 조립의 기준점은 [`scenes/main/Main.tscn`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scenes/main/Main.tscn) 이다.
- 플레이어는 현재 `Main.tscn` 내부에서 조립되며 `scenes/player/Player.tscn` 전제는 사용하지 않는다.
- 런타임 에셋 참조는 반드시 `res://assets/...` 만 사용한다.
- `asset_sample/` 는 원본 드롭존이자 분석 소스이며, 코드/씬의 직접 참조 대상이 아니다.
- `GameState` 는 기존 public API 를 유지하면서 내부적으로 `CombatRuntimeState` 와 `ProgressionSaveState` 로 역할을 나누기 시작했다.
- 전투 HUD 연동용 hotbar API는 현재 `13슬롯 저장 + 10슬롯 가시 layer`의 이중 구조를 가진다.
  - 런타임 내부 배열과 호환 save 기준선은 아직 `GameState.spell_hotbar` 전체 13슬롯이다.
  - save payload의 canonical field는 `spell_hotbar` 첫 10슬롯이고, 나머지 3슬롯은 `legacy_spell_hotbar_tail` 호환 필드로 분리된다.
  - visible shortcut canonical field는 `visible_hotbar_shortcuts`이고, old save에 이 필드가 없으면 첫 10슬롯의 legacy `action + label`에서 shortcut profile을 복원한다.
  - GUI 소비자는 `GameState.get_visible_spell_hotbar()` 또는 `player.get_visible_hotbar_bindings()`로 첫 10슬롯만 읽는다.
  - GUI tooltip / unbind / drag-swap / shortcut rebind는 `get_hotbar_slot()`, `get_hotbar_slot_tooltip_data()`, `clear_hotbar_skill()/clear_hotbar_slot()`, `swap_hotbar_skills()/swap_hotbar_slots()`, `get_visible_hotbar_shortcuts()`, `set_visible_hotbar_shortcut()`, `reset_visible_hotbar_shortcuts_to_default()` 경로를 사용한다.
  - keyboard combat primary input 은 `spell_manager.handle_input()` 기준으로 첫 10슬롯 가시 row만 읽는다.
- `scripts/ui/game_ui.gd`의 현재 전투 HUD 셸은 programmatic GUI 기준으로 아래를 실제 구현했다.
  - 상단 좌측 primary target HP panel
  - 하단 중앙 `HP/MP + 캐릭터 정보` resource cluster
  - 상단 좌측 active buff chip row
  - `Buttons.png` / `Action_panel.png` 스킨을 쓰는 visible `10슬롯` action row
  - hover tooltip, 좌클릭 cast, 우클릭 clear, 좌클릭 hold 후 release swap
  - unavailable slot dim 처리와 tooltip/current-state 기반 label 갱신
  - runtime local hide toggle `set_show_primary_action_row()` / `set_show_active_buff_row()`
- 현재 GUI 미완료 범위는 아래처럼 정리한다.
  - target HP panel은 현재 `플레이어와 가장 가까운 살아 있는 적`을 primary target으로 읽는 휴리스틱 단계다. explicit lock-on / keyboard selection target source는 아직 없다.
  - HUD show/hide 설정의 persistence와 설정창 연결은 아직 없다.
  - 키보드 선택 테두리와 마우스 hover overlay의 시각 동기화는 아직 전용 테두리 연출로 닫히지 않았다.
  - hotbar는 아직 실제 아이콘 atlas 기반이 아니라 text + slot skin 중심이다.
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
- [`scripts/ui/game_ui.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)
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
- [x] 전투 HUD용 `10슬롯 visible hotbar` bridge API가 현재 런타임 구조와 분리된 저장 기준선을 함께 설명한다.
- [x] `EnemyBase` 는 helper 분리 기준을 반영한다.
- [x] `Main` 오케스트레이션은 통합 테스트 대상이라는 점이 반영된다.
- [x] 적 스탯 체계와 최종 피해 계산 기준 문서가 별도로 연결되어 있다.
- [x] 몬스터 카탈로그 / 스키마 / 상태 추적 문서 체계가 별도로 연결되어 있다.
