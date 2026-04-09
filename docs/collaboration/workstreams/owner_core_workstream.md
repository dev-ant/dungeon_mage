---
title: 내 작업 스트림
doc_type: tracker
status: superseded
section: collaboration
owner: owner_core
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
update_when:
  - runtime_changed
  - handoff_changed
  - ownership_changed
last_updated: 2026-04-10
last_verified: 2026-04-10
---

# 내 작업 스트림

상태: superseded  
최종 갱신: 2026-04-10  
담당자: 프로젝트 오너  
AI 역할: 전투 코어 / 데이터 / 비 GUI 구현

이 문서는 역할 분리 운영 당시의 레거시 workstream이다. 2026-04-10부터 새 진행 로그는 [shared_ui_runtime_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/shared_ui_runtime_workstream.md)에만 남긴다.

## 역할 요약

이 문서는 `아이템창`, `스킬창`, `설정창`, `장비창` GUI 구현을 제외한 내 작업만 추적한다.

친구가 맡은 GUI 창 관련 파일은 수정하지 않는다.

2026-04-02 기준으로 장기 누적 로그는 아카이브로 롤오버했고, 이 문서는 `현재 우선순위`, `현재 상태`, `활성 교차 의존 요청`만 유지하는 경량 workstream 문서로 사용한다.

## 읽어야 할 기준 문서

- [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)
- [combat_first_build_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md)
- [combat_increment_02_spell_runtime.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_02_spell_runtime.md)
- [combat_increment_03_buff_action_loop.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_03_buff_action_loop.md)
- [combat_increment_04_enemy_combat_set.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_04_enemy_combat_set.md)
- [combat_increment_05_equipment_minimum.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_05_equipment_minimum.md)
- [combat_increment_09_soul_dominion_risk.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_09_soul_dominion_risk.md)
- [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)

## 내 작업 범위

- 전투 런타임 구조 보강
- 스킬 추가 구현
- 버프 조합과 리스크 시스템
- 몬스터 확장
- 샌드박스 전투 흐름
- 데이터 정리와 로더 유지보수
- GUI 창과 직접 관련되지 않은 테스트 보강

## 제외 범위

- 아이템창 GUI
- 스킬창 GUI
- 설정창 GUI
- 장비창 GUI
- 위 창들의 입력, 버튼, 패널, 드래그/드롭, 마우스 상호작용
- 친구 소유 파일 전체

## 수정 가능한 파일

- `data/**`
- `scripts/player/**`
- `scripts/enemies/**`
- `scripts/world/**`
- `scripts/autoload/**`
- `tests/test_player_controller.gd`
- `tests/test_spell_manager.gd`
- `tests/test_game_state.gd`
- `tests/test_enemy_base.gd`
- `tests/test_equipment_system.gd`
- 구현 문서와 조건부 소스 오브 트루스 문서 권한은 [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)의 `문서 권한 해석`과 owner_core 프롬프트를 따른다.

## 수정 금지 파일

- `scripts/admin/admin_menu.gd`
- `scripts/ui/game_ui.gd`
- `scripts/ui/**` 의 GUI 창 관련 파일
- `scenes/ui/**`
- `scenes/main/Main.tscn`
- `tests/test_admin_menu.gd`
- 상대 workstream, prompt, policy, governance 문서는 일반 구현 턴에서 수정하지 않는다.

## 현재 우선순위

1. GUI 창과 독립적인 전투 로직을 계속 전진시킨다.
2. 친구 GUI 작업이 요구할 수 있는 읽기 전용 데이터 구조를 안정적으로 유지한다.
3. GUI가 붙었을 때 바로 연결 가능한 런타임 상태를 문서와 테스트로 고정한다.

## 진행 체크리스트

- [ ] 다음 전투 코어 목표를 한 번에 하나씩 선택한다.
- [ ] 수정 파일이 내 소유 파일인지 먼저 확인한다.
- [ ] 적 스탯, 데미지 감쇠, 저항, 슈퍼아머, 브레이크 규칙을 바꿀 때 `enemy_stat_and_damage_rules.md`를 함께 수정한다.
- [ ] 구현 전 관련 GUT 테스트를 만들거나 보강한다.
- [ ] 구현 후 headless 체크와 GUT를 돌린다.
- [ ] 활성 상태와 교차 의존 요청만 이 문서에 갱신한다.

## 현재 상태

- 대표 장비 회귀 축은 `fire_burst`, `wind_tempo`, `earth_deploy`, `sanctum_sustain`, `holy_guard`, `dark_shadow`, `arcane_pulse`까지 실제 런타임 GUT 기준으로 고정된 상태다.
- enemy/drop/room read-only API 축은 validation report, spawn summary, drop preview, deterministic drop resolver, drop profile summary, room spawn enemy roster summary까지 닫혀 있다.
- Combat HUD Cycle A의 owner_core 선행 의존으로 `10슬롯 visible hotbar` bridge API를 추가했다. 현재 `GameState`, `spell_manager`, `player`에서 visible bindings, slot tooltip payload, clear, swap wrapper를 제공한다.
- Combat HUD Cycle A의 두 번째 owner_core 선행 의존으로 save payload를 `canonical 10슬롯 spell_hotbar + legacy_spell_hotbar_tail` 구조로 분리했고, load는 신규 payload와 old 13슬롯 save를 모두 호환한다.
- Combat HUD Cycle A의 세 번째 owner_core 선행 의존으로 visible hotbar shortcut rebind persistence를 추가했다. 현재 `GameState`와 `player`에서 shortcut profile 조회, key rebind, default reset API를 제공하고, explicit shortcut payload가 없는 old save도 첫 10슬롯의 `action + label`로 keyboard/HUD shortcut을 복원한다.
- Combat HUD Cycle A의 네 번째 owner_core 정리는 2026-04-09 Maple-style UI 후속에서 `21슬롯 fixed action registry` 기준으로 확장됐다. 현재 `spell_manager`의 keyboard combat primary input 은 `visible 10슬롯 + hidden Z/X/C + V/A/S/D/F/Shift/Ctrl/Alt` 를 함께 읽고, `GameState.get_action_hotkey_registry()`가 플레이어 UI용 canonical view가 된다.
- 같은 날짜 InventoryWindow follow-up으로 `GameState.get_equipment_inventory_item_at()`, `get_equipment_inventory_occupied_count()`, `find_equipment_inventory_slot_by_item()`, `swap_equipment_inventory_items()`, `move_equipment_inventory_item()`, `organize_equipment_inventory()`도 추가됐다. 현재 장비 인벤토리 source of truth는 `20칸 fixed sparse slot` 레이아웃이므로, friend GUI는 장비 탭 `5x4` 셀을 구현할 때 admin 전용 정렬 로직이나 자체 sparse 모델을 복제하지 말고 이 API를 직접 사용하면 된다.
- 같은 날짜 follow-up으로 `소비 / 기타` 탭용 stack inventory owner_core API도 잠갔다. 현재 `GameState` 는 `consumable_inventory`, `other_inventory` save field와 `get_consumable_inventory_item_at()`, `get_other_inventory_item_at()`, `get_consumable_inventory_occupied_count()`, `get_other_inventory_occupied_count()`, `grant_consumable_item()`, `grant_other_item()`, `apply_stackable_inventory_drag_drop()`, `organize_stackable_inventory()`, `use_consumable_inventory_item()`를 제공한다. friend GUI는 `소비 / 기타` 탭을 구현할 때 자체 stack merge/save 모델을 만들지 말고 이 canonical API를 그대로 사용하면 된다.
- 2026-04-06 owner_core 증분으로 신규 effect import와 실제 runtime 연결을 닫았다. 현재 `dark_void_bolt`, `volt_spear`, `holy_radiant_burst`, `holy_cure_ray`, `holy_judgment_halo`, `earth_stone_spire`, `earth_tremor`(`earth_quake_break` proxy), `earth_gaia_break`, `earth_continental_crush`, `earth_world_end_break`, `fire_apocalypse_flame`, `fire_solar_cataclysm`, `wind_cyclone_prison`, `ice_frost_needle`, `water_tidal_ring`, `water_wave`, `water_tsunami`, `water_ocean_collapse`, `lightning_bolt`, `ice_absolute_freeze`, `ice_absolute_zero`, `fire_inferno_buster`, `fire_meteor_strike`, `wind_storm`, `wind_heavenly_storm`, `fire_inferno_sigil`, `fire_flame_storm`, `holy_bless_field`, `holy_sanctuary_of_reversal`, `fire_hellfire_field`, `ice_storm`, `dark_shadow_bind`, `plant_vine_snare`, `plant_world_root`, `plant_worldroot_bastion`, `plant_genesis_arbor`는 effect family를 쓰고, `water_aqua_bullet`, `wind_gale_cutter`는 저위험 refresh 기준의 projectile family까지 신규 에셋으로 교체됐다. `plant_vine_snare`는 2026-04-09 follow-up으로 dedicated `plant_vine_snare_attack/loop/hit/end` family와 `phase_signature = plant_vine_snare` ground telegraph까지 승격돼 `plant_root_bind` verified 기준을 닫았고, `fire_flame_storm`, `fire_hellfire_field`, `holy_bless_field`, `holy_sanctuary_of_reversal`, `ice_storm`, `dark_shadow_bind`, `earth_fortress`, `plant_world_root`, `plant_worldroot_bastion`, `plant_genesis_arbor`, `ice_glacial_dominion`, `lightning_tempest_crown`, `wind_storm_zone`, `holy_seraph_chorus`, `wind_sky_dominion`, `dark_throne_of_ash`, `lightning_conductive_surge`, `plant_verdant_overflow`, `dark_grave_pact`, `dark_grave_echo`, `dark_soul_dominion`도 같은 날짜 follow-up에서 각 전용 family + 대표 runtime contract + 회귀 검증까지 더해 verified 승격을 마쳤다. `fire_flame_arc`는 runtime spell row + sampled burst visual을 사용한다. `holy_mana_veil`, `holy_crystal_aegis`, `holy_dawn_oath`는 shared holy guard activation/overlay 훅을 사용한다. `wind_tempest_drive`는 2026-04-07 후속에서 별도 active startup 훅으로 전환했다.
- 2026-04-06 owner_core 증분으로 신규 effect import와 실제 runtime 연결을 닫았다. 현재 `dark_void_bolt`, `volt_spear`, `holy_radiant_burst`, `holy_cure_ray`, `holy_judgment_halo`, `earth_stone_spire`, `earth_tremor`(`earth_quake_break` proxy), `earth_gaia_break`, `earth_continental_crush`, `earth_world_end_break`, `fire_apocalypse_flame`, `fire_solar_cataclysm`, `wind_cyclone_prison`, `ice_frost_needle`, `water_tidal_ring`, `water_wave`, `water_tsunami`, `water_ocean_collapse`, `lightning_bolt`, `ice_absolute_freeze`, `ice_absolute_zero`, `fire_inferno_buster`, `fire_meteor_strike`, `wind_storm`, `wind_heavenly_storm`, `fire_inferno_sigil`, `fire_flame_storm`, `holy_bless_field`, `holy_sanctuary_of_reversal`, `fire_hellfire_field`, `ice_storm`, `dark_shadow_bind`, `plant_vine_snare`, `plant_world_root`, `plant_worldroot_bastion`, `plant_genesis_arbor`는 effect family를 쓰고, `water_aqua_bullet`, `wind_gale_cutter`는 저위험 refresh 기준의 projectile family까지 신규 에셋으로 교체됐다. `plant_vine_snare`는 2026-04-09 follow-up으로 dedicated `plant_vine_snare_attack/loop/hit/end` family와 `phase_signature = plant_vine_snare` ground telegraph까지 승격돼 `plant_root_bind` verified 기준을 닫았고, `fire_flame_storm`, `fire_hellfire_field`, `holy_bless_field`, `holy_sanctuary_of_reversal`, `ice_storm`, `dark_shadow_bind`, `earth_fortress`, `plant_world_root`, `plant_worldroot_bastion`, `plant_genesis_arbor`, `ice_glacial_dominion`, `lightning_tempest_crown`, `wind_storm_zone`, `holy_seraph_chorus`, `wind_sky_dominion`, `dark_throne_of_ash`, `lightning_conductive_surge`, `plant_verdant_overflow`, `dark_grave_pact`, `dark_grave_echo`, `dark_soul_dominion`도 같은 날짜 follow-up에서 각 전용 family + 대표 runtime contract + 회귀 검증까지 더해 verified 승격을 마쳤다. 2026-04-10 보강에서는 `fire_meteor_strike`도 checked-in dedicated meteor family + dedicated phase signature + level scaling regression까지 더해 verified active representative로 승격했다. `fire_flame_arc`는 runtime spell row + sampled burst visual을 사용한다. `holy_mana_veil`, `holy_crystal_aegis`, `holy_dawn_oath`는 shared holy guard activation/overlay 훅을 사용한다. `wind_tempest_drive`는 2026-04-07 후속에서 별도 active startup 훅으로 전환했다.
- 2026-04-07 owner_core 정정으로 공격 스킬 다단히트 semantics도 현재 runtime 기준으로 잠겼다. active 공격은 이제 `1회 시전 / 1회 attack effect / 1회 projectile·area spawn`만 허용하고, `multi_hit_count`는 cast-time payload 분할이 아니라 같은 공격 인스턴스가 적중한 대상에게 적용하는 on-hit sequence 총 hit 수를 뜻한다. 후속 hit는 `spell_projectile.gd`가 대상별로 처리하고, 반복되는 것은 `hit effect`뿐이며 `mana / cooldown / cast lock / camera shake`는 1회만 소비된다.
- 알려진 잔여 리스크는 `scripts/main/main.gd`의 `create_timer()` 기반 종료 시 leak warning이며, 현재 workstream 소유 범위 밖이라 직접 수정하지 않는다.
- `P1 전투 HUD 그래픽 GUI 최종 명세`는 이제 `ready_for_implementation`이고, 첫 GUI-owned handoff 증분은 [combat_increment_06_combat_ui.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_06_combat_ui.md)의 `2026-04-03 구현 handoff — Combat HUD Cycle A` 섹션으로 잠겼다.
- 2026-04-07 owner_core 후속으로 `4서클 이상 스킬 성장 체감` 보정을 runtime에 추가했다. 현재 `GameState.build_common_runtime_stat_block()`이 `circle >= 4` 액티브/설치형 스킬의 `range/size/duration`을 hit shape별로 추가 보정하고, `spell_projectile.gd`는 현재 반경을 기준으로 visual scale multiplier를 적용한다. 최신 대표 회귀는 이후 telegraph/phase contrast/대표 signature 후속까지 포함한 `tests/test_spell_manager.gd 296/296`다.
- 같은 날짜 후속으로 큰 정지형 광역기/장판은 procedural `GroundTelegraph`를 함께 쓰도록 잠갔다. 현재 `spell_projectile.gd`는 `radius >= 96`의 stationary burst / persistent field에 flattened ellipse telegraph를 자동 생성하고, persistent field는 inner ring를 하나 더 쓴다. 추가로 startup에는 짧은 `StartupRing`, 종료에는 `TerminalFlash`를 붙여 phase contrast를 분리했고, school profile로 `fire/lightning/wind`는 더 빠르게, `ice/earth/dark`는 더 무겁게, `holy/water/plant/arcane`는 중간군으로 분기한다. 그 위에 `fire_inferno_buster`, `fire_solar_cataclysm`, `earth_gaia_break`, `earth_world_end_break`는 spell signature override까지 잠갔다. moving projectile / line은 기존 travel-body read를 유지한다. 대표 회귀는 `tests/test_spell_manager.gd 296/296` 기준으로 잠갔다.
- 같은 날짜 추가 후속으로 `holy_judgment_halo`, `plant_genesis_arbor`, `ice_absolute_freeze`, `ice_absolute_zero`까지 school 내부 signature 분화를 더 잠갔다. 현재 holy는 `bless_field`보다 더 빠르고 선명한 verdict burst, plant는 `worldroot_bastion`보다 더 무겁고 넓은 final canopy, ice는 `absolute_freeze`보다 `absolute_zero`가 더 느리고 깊게 잠기는 final frost collapse로 읽히게 했다. 이번 잠금의 source of truth는 headless startup + `tests/test_spell_manager.gd` signature targeted `5/5`이며, 이후 summary/feedback localized baseline 정리까지 포함한 전체 파일은 `296/296` green 상태다.
- 같은 날짜 추가 후속으로 `dark` school high-circle telegraph 후보를 다시 대조했고, 현재 runtime에는 stationary burst / field 비교쌍이 부족해 그 레인은 스킵했다. 대신 `player.gd`의 toggle visual family에 `dark_grave_echo`, `dark_soul_dominion` stage signature를 잠가 grave_echo는 더 작고 탁한 curse aura, soul_dominion은 더 크고 밝은 final risk aura로 읽히게 했고, 종료 직후엔 `aftershock` pulse를 한 번 더 띄워 꺼짐과 여진 위험 구간을 분리했다. 2026-04-09 보강에서는 `dark_grave_echo`, `dark_soul_dominion` 모두 checked-in dedicated toggle family로 승격됐고, dark toggle 축은 representative cadence/aftershock regression까지 포함해 verified 기준을 충족했다.
- 같은 날짜 추가 정리로 owner_core 범위의 localized expectation drift도 닫았다. equipment summary/inventory, final warning residue, echo repeat regression은 이제 영어 literal이 아니라 `GameState`와 `echo_marker.gd`가 반환하는 현재 한국어 런타임 문구를 기준으로 검증한다. 최신 검증은 `tests/test_equipment_system.gd 59/59`, `tests/test_game_state.gd 322/322`, `tests/test_player_controller.gd 73/73`, `tests/test_spell_manager.gd 296/296`, full GUT `1033/1033`, headless startup이다.

## 활성 진행 로그

### 2026-04-06

- `asset_sample/Effect/new` 분석안 기준으로 신규 effect frame을 `assets/effects/` runtime 경로로 가져와 `dark_void_bolt`, `volt_spear`, `holy_radiant_burst` split effect를 실제 교체했다.
- `spell_manager.gd`, `player.gd`, `data/skills/skills.json`, `tests/test_spell_manager.gd`를 함께 갱신해 `holy_mana_veil`, `holy_crystal_aegis`의 shared holy guard activation/overlay 훅을 추가했다.
- 후속 follow-up으로 `holy_dawn_oath`도 같은 shared holy guard activation/overlay 훅 위에 실제 연결했고, 2026-04-09 보강에서 `holy_dawn_oath_activation` / `holy_dawn_oath_overlay` dedicated final-guard family와 damage-reduction focused final guard contract까지 함께 잠갔다.
- 후속 follow-up으로 `dark_throne_of_ash`도 fallback ritual buff 계획 기준 `dark_throne_activation`, `dark_throne_overlay` family를 실제 연결했고, 2026-04-09 보강에서 checked-in dedicated ritual family + dual-school finisher scaling + activation mana drain + solo ash residue regression까지 함께 잠갔다.
- 후속 follow-up으로 `lightning_conductive_surge`도 fallback lightning buff 계획 기준 `conductive_surge_activation`, `conductive_surge_overlay` family를 실제 연결했고, 2026-04-09 보강에서 checked-in dedicated buff family + lightning finisher scaling + extra ping contract + `Overclock Circuit` regression까지 함께 잠갔다.
- 후속 follow-up으로 `plant_verdant_overflow`도 fallback plant buff 계획 기준 `verdant_overflow_activation`, `verdant_overflow_overlay` family를 실제 연결했고, 2026-04-09 보강에서 checked-in dedicated verdant family + deploy amplification scaling + `Funeral Bloom` regression까지 함께 잠갔다.
- 후속 follow-up으로 `dark_grave_pact`도 fallback dark buff 계획 기준 `grave_pact_activation`, `grave_pact_overlay` family를 실제 연결했고, 2026-04-09 보강에서 checked-in dedicated pact family + dark-only finisher scaling + `kill_leech` 유지 + `hp_drain_percent_per_second` risk contract + overlay priority regression까지 함께 잠갔다.
- 후속 follow-up으로 `wind_tempest_drive`도 fallback wind 계획 기준 `tempest_drive_activation` family를 실제 연결했고, activation 순간 짧은 전방 mobility burst까지 함께 잠갔다.
- 후속 follow-up으로 `fire_pyre_heart`, `ice_frostblood_ward`, `arcane_astral_compression`, `arcane_world_hourglass`도 fallback buff 계획 기준 `pyre_heart_*`, `frostblood_ward_*`, `astral_compression_*`, `world_hourglass_*` family를 실제 연결했고, `일반 offense < arcane tempo < defense ward < holy guard < dark ritual` overlay 우선순위까지 함께 잠갔다. 2026-04-09 보강 기준 네 row 모두 dedicated family + runtime scaling regression까지 닫아 verified로 승격됐다.
- 같은 2026-04-09 사용자 결정 후속으로 `arcane_force_pulse`도 독립 canonical active row로 확정했다. 현재 source of truth는 `skills.json.arcane_force_pulse`와 `spells.json.arcane_force_pulse.source_skill_id`이며, checked-in dedicated `arcane_force_pulse_attack / arcane_force_pulse / arcane_force_pulse_hit` family, low-circle zero-cooldown contract, split effect payload, level scaling regression까지 owner_core 범위에서 함께 잠갔다.
- 같은 2026-04-09 follow-up으로 `fire_inferno_breath`도 독립 canonical active row로 확정했다. 현재 source of truth는 `skills.json.fire_inferno_breath`와 `spells.json.fire_inferno_breath.source_skill_id`이며, checked-in dedicated `fire_inferno_breath_attack / fire_inferno_breath / fire_inferno_breath_hit` family, stationary five-hit cone pressure contract, burn `chance_per_level` scaling, 64x64 split-effect normalization, full-file `test_game_state.gd` / `test_spell_manager.gd` green까지 owner_core 범위에서 함께 잠갔다.
- 같은 2026-04-09 후속 사이클로 `earth_stone_rampart`도 독립 canonical deploy row로 확정했다. 현재 source of truth는 `skills.json.earth_stone_rampart`이며, checked-in dedicated `earth_stone_rampart_attack / earth_stone_rampart / earth_stone_rampart_hit / earth_stone_rampart_end` family, short stone wall deploy contract, contact `slow + root` control rider, dedicated wall telegraph regression, full-file `test_game_state.gd` / `test_spell_manager.gd` green까지 owner_core 범위에서 함께 잠갔다.
- 같은 2026-04-09 후속 사이클로 `water_aqua_geyser`도 독립 canonical active row로 확정했다. 현재 source of truth는 `skills.json.water_aqua_geyser`와 `spells.json.water_aqua_geyser.source_skill_id`이며, checked-in dedicated `water_aqua_geyser_attack / water_aqua_geyser / water_aqua_geyser_hit / water_aqua_geyser_end` family, keyboard-first fixed-forward burst spawn, dedicated geyser telegraph regression, representative damage/size/knockback scaling까지 owner_core 범위에서 함께 잠갔다.
- 같은 날짜 추가 증분으로 `wind_tempest_drive`는 fallback wind active burst payload도 함께 연결했다.
- 2026-04-07 사용자 결정 반영 후 `wind_tempest_drive`를 5서클 순수 active canonical로 전환했다. current source of truth는 `spells.json.wind_tempest_drive` activation burst row와 `skills.json.wind_tempest_drive` active metadata + dash direct field다.
- 같은 정리에서 `tempest_drive_overlay` 및 buff slot semantics는 current runtime에서 제거했고, visible action slot을 canonical 입력으로 잠갔다. 기존 `G` 계열 직접 시전은 레거시 호환으로만 남긴다.
- `Overclock Circuit`는 더 이상 current buff combo source가 아니며, 2026-04-07 후속 잠금으로 `lightning_conductive_surge` 활성 중 `wind_tempest_drive` 시전 성공 시 여는 `1.0초` active window로 정리했다. 다음 전기 액티브 1회는 `aftercast x0.88`, `chain +1`, `speed x1.18`을 적용한 뒤 window를 소비한다.
- 후속으로 `earth_stone_spire`, `fire_flame_arc`, `wind_cyclone_prison` visual/runtime 보완안을 실제 연결했고, `game_state` / `spell_manager` GUT 회귀 범위도 함께 늘렸다. `earth_stone_spire`는 2026-04-09 follow-up에서 deploy runtime contract, level scaling, grounded cone-burst representative regression 기준으로 verified로 승격했다.
- 같은 2026-04-09 Maple-style UI follow-up에서 owner_core가 friend GUI에 넘겨 줄 입력/저장 API도 더 잠갔다. 현재 `GameState` 는 `action_hotkey_registry` save field와 `get_action_hotkey_registry()`, `get_action_hotkey_labels_for_skill()`, `set_action_hotkey_skill()`, `clear_action_hotkey_skill()`, `get_action_hotkey_slot()`를 제공하고, friend GUI는 `SkillWindow`/`KeyBindingsWindow`에서 이 registry만 직접 읽으면 된다.
- 후속 follow-up으로 `ice_frost_needle` canonical/runtime 정리를 마치고, 기본 ice hotbar/runtime를 `ice_frost_needle` projectile 기준으로 승격했다. `frost_nova`는 legacy freeze burst runtime으로 남겨 old save/preset 호환과 area-burst 회귀 기준선을 유지한다.
- 후속 follow-up으로 `water_tidal_ring` active row와 `ice_frozen_domain` visual family 연결도 닫았다. `water_tidal_ring`는 startup ring / main ring / splash hit를 쓰고, `ice_glacial_dominion`은 `ice_frozen_domain`의 activation / loop / end overlay family를 사용한다. 2026-04-09 보강에서는 damage/size/target scaling과 slow 유지 representative regression까지 더해 verified proxy row로 승격했다.
- 후속 follow-up으로 `holy_cure_ray`, `holy_judgment_halo` runtime row와 holy effect family 연결도 닫았다. `holy_cure_ray`는 solo runtime 제약상 self-heal rider를 포함한 ray support로, `holy_judgment_halo`는 startup / main / hit / closing burst 4단 final burst로 정리했다. 2026-04-10 보강에서는 `holy_judgment_halo`의 level 1 대비 level 30 damage/range/target scaling과 dedicated `phase_signature = holy_judgment_halo` ground telegraph regression까지 더해 verified 승격을 마쳤다.
- 후속 follow-up으로 `earth_quake_break`도 runtime proxy `earth_tremor` 위에서 새 대지 burst family로 갱신했다. `Earth Bump` 기반 centered startup crack과 `Impact` strip hit를 써서 `earth_stone_spire`의 솟구침 설치기와 시각 역할을 분리했고, canonical hotbar 입력 `earth_quake_break -> earth_tremor` 회귀도 함께 잠갔다.
- 후속 follow-up으로 `fire_inferno_sigil` deploy effect family 연결도 닫았다. `Fire Effect 2`의 linger 폭발군을 startup / loop / tick hit / terminal burst 4단으로 나눠 `fire_inferno_sigil_attack`, `fire_inferno_sigil`, `fire_inferno_sigil_hit`, `fire_inferno_sigil_end` runtime hook에 연결했고, 현재 기준 cadence 잠금은 짧은 pulse 반복이 분명히 읽히는 `0.4s` tick interval, brightness down, scale down 튜닝이다.
- 추가 practical validation follow-up으로 `fire_inferno_sigil`은 `deploy_lab` 프리셋에서도 바로 반복 검증 가능하도록 열었고, inferno 전용 회귀에 `hit flash duration < 0.4s pulse gap`, `direct-hit 이후 다음 pulse 재개 시점`, `보스 1체 + 잡몹 혼합` pressure sandbox 시나리오, 기존 projectile archetype coverage race 안정화까지 반영했다.
- 후속 follow-up으로 `water_aqua_bullet`, `wind_gale_cutter` 저위험 refresh도 실제 runtime attach까지 닫았다. `WaterBall` startup / projectile loop / impact family와 `Wind Projectile` / `Wind Hit Effect` family를 각각 적용했고, split effect frame count + projectile body AnimatedSprite2D load/좌우 반전 회귀를 함께 잠갔다.
- 후속 follow-up으로 기존 `asset_sample/Effect` fallback 우선순위를 실제 runtime 1차 파동으로 연결했다. 현재 `wind_arrow`, `earth_stone_shot`, `holy_halo_touch`, `fire_flame_bullet`, `water_aqua_spear`, `wind_gust_bolt`, `earth_rock_spear`, `ice_spear`, `lightning_thunder_arrow`는 placeholder projectile/line family와 split effect attack/hit, 대표 상태이상 회귀까지 실제 연결된 상태다.
- 후속 follow-up으로 같은 fallback 계획의 `field / aura` 2차 파동도 실제 runtime에 연결했다. 이후 2026-04-09 보강에서 `fire_flame_storm`은 `fire_flame_storm_attack/loop/hit/end` dedicated field family와 cadence/field scaling contract를 사용하도록 승격됐고, `fire_hellfire_field`는 `fire_hellfire_field_attack/loop/hit/end` dedicated field family와 large-field cadence/scaling contract를 사용하도록 승격됐고, `holy_sanctuary_of_reversal`은 `holy_sanctuary_of_reversal_attack/loop/hit/end` dedicated sanctuary family와 deploy reversal survival contract를 사용하도록 승격됐고, `lightning_tempest_crown`은 `tempest_crown_activation/loop/end` dedicated toggle family와 cadence/chain-depth scaling contract를 사용하도록 승격됐다.
- 후속 follow-up으로 같은 fallback 계획의 `field / aura` 3차 파동도 실제 runtime에 연결했다. 이후 2026-04-09 보강에서 `holy_bless_field`는 `holy_bless_field_attack/loop/hit/end` dedicated blessing family와 deploy support contract를, `wind_storm_zone`은 `wind_storm_zone_activation/loop/end` dedicated toggle family와 `slow + pull_strength` control-zone contract를, `holy_seraph_chorus`는 `holy_seraph_chorus_activation/loop/end` dedicated toggle family와 `damage + self_heal + poise_bonus` mixed aura contract를 사용하도록 승격됐다.
- 후속 follow-up으로 같은 fallback 계획의 `field / aura` 4차 파동도 실제 runtime에 연결했다. 이후 2026-04-09 보강에서 `ice_storm`은 `ice_storm_attack/loop/hit/end` dedicated frost-storm family와 slow/freeze verified deploy contract를, `earth_fortress`는 brown-earth fortress family와 pure guard toggle contract를, `plant_world_root`는 `plant_world_root_attack/loop/hit/end` dedicated world-root family와 root verified deploy contract를 사용하도록 승격됐다.
- 같은 날짜 fallback field 5차 파동으로 `plant_genesis_arbor`도 `fallback_plant_field_*` family를 더 큰 canopy tint/scale로 재해석해 실제 deploy runtime에 연결했다. 현재 10서클 자연 최종 설치기도 placeholder field contract와 representative regression까지 닫힌 상태다.
- 같은 날짜 fallback field plant 후속 파동으로 `plant_worldroot_bastion`도 실제 deploy runtime에 연결했다. 이후 2026-04-09 follow-up으로 `plant_worldroot_bastion`은 checked-in dedicated bastion family와 root verified contract, `plant_world_root`와 `plant_genesis_arbor` 사이 visual hierarchy regression까지 승격을 마쳤다.
- 같은 날짜 fallback dark field 후속 파동으로 `dark_shadow_bind`도 실제 deploy runtime에 연결했다. 이후 2026-04-09 follow-up으로 `dark_shadow_bind`는 checked-in dedicated curse-field family와 `0.75s` cadence의 damage/duration/size/target scaling + slow control contract까지 verified 승격을 마쳤다.
- 같은 날짜 fallback plant field 저서클 보강으로 `plant_vine_snare`도 `fallback_plant_field_attack/loop/hit/end` family를 early snare scale/tint로 재해석해 실제 deploy runtime에 연결했다. 현재 `plant_root_bind` canonical alias까지 placeholder field contract와 representative regression으로 닫힌 상태다.
- 같은 날짜 fallback projectile / line 6차 파동으로 `water_wave`도 `fallback_water_attack/line/hit` family를 넓은 control-wave 해석으로 실제 active runtime에 연결했다. 현재 3서클 물 crowd-control line 축도 placeholder contract와 representative regression까지 닫힌 상태다.
- 같은 날짜 fallback projectile / line 7차 파동으로 `lightning_bolt`도 `fallback_shard_attack/projectile/hit` family를 밝은 chain-control bolt 해석으로 실제 active runtime에 연결했다. 현재 4서클 전기 crowd-control line 축도 placeholder contract와 representative regression까지 닫힌 상태다.
- 같은 날짜 fallback projectile / line 9-10차 파동의 `fire_inferno_buster`, `wind_storm`은 2026-04-10 보강에서 각각 checked-in dedicated inferno / storm family를 runtime source of truth로 승격했고, `fire_inferno_buster` existing phase signature와 `wind_storm` dedicated phase signature, level 1 대비 level 30 damage/range/target scaling, dedicated family path regression까지 더해 verified 승격을 마쳤다.
- 같은 날짜 fallback projectile 냉기 후속 파동으로 `ice_absolute_freeze`도 2026-04-10 보강에서 checked-in dedicated freeze family를 runtime source of truth로 승격했고, existing freeze phase signature + level 1 대비 level 30 damage/range/target scaling + dedicated family path regression까지 함께 잠가 verified 승격을 마쳤다.
- 같은 날짜 fallback projectile / line 17차 파동으로 `wind_heavenly_storm`도 `fallback_wind_attack/projectile/hit` family를 더 큰 heavenly burst로 재해석해 실제 active runtime에 연결했고, 2026-04-10 보강에서는 checked-in dedicated heavenly family + dedicated `phase_signature = wind_heavenly_storm` + level scaling regression까지 더해 verified 승격을 마쳤다.
- 같은 날짜 fallback projectile / line 18차 파동으로 `fire_solar_cataclysm`도 `fallback_fire_field_attack/loop/hit/end` family를 더 큰 solar burst와 terminal collapse로 재해석해 실제 active runtime에 연결했다. 2026-04-10 보강에서는 `fire_apocalypse_flame`과 함께 checked-in dedicated apocalypse / solar family와 각 전용 phase signature, level scaling regression까지 더해 verified 승격을 마쳤다.
- 같은 날짜 fallback projectile earth 붕괴 후속 파동으로 `earth_gaia_break`, `earth_continental_crush`, `earth_world_end_break`도 2026-04-10 보강에서 각 checked-in dedicated collapse family를 runtime source of truth로 승격했고, `earth_continental_crush` 전용 phase signature, level 1 대비 level 30 damage/range/target scaling, dedicated family path regression까지 함께 잠가 verified 승격을 마쳤다.
- 같은 날짜 fallback projectile 냉기 최종 후속 파동으로 `ice_absolute_zero`도 2026-04-10 보강에서 checked-in dedicated final-freeze family를 runtime source of truth로 승격했고, existing zero phase signature + level 1 대비 level 30 damage/range/target scaling + dedicated family path regression까지 함께 잠가 verified 승격을 마쳤다.
- 같은 날짜 fallback field / aura 6차 파동으로 `wind_sky_dominion`도 `sky_dominion_activation/loop/end` family를 더 큰 pale mint-white ultimate aura로 재해석해 실제 toggle runtime에 연결했다. 2026-04-09 보강에서 zero-damage aerial utility contract와 owner mobility/expiry regression까지 함께 잠가 verified 승격을 마쳤다.
- 같은 날짜 fallback aura dark 후속 파동으로 `dark_grave_echo`도 `grave_echo_activation/loop/end` family를 muted violet curse aura로 재해석해 실제 toggle runtime에 연결했다. 2026-04-09 보강에서는 checked-in dedicated grave_echo family + `0.6s` curse cadence + damage/size/target scaling + dark toggle overlay priority regression까지 함께 잠갔다.
- 같은 날짜 fallback buff / ritual 후속 파동으로 `dark_throne_of_ash`도 `dark_throne_activation`, `dark_throne_overlay` family를 dark ash tint owner-follow ritual overlay로 재해석해 실제 buff runtime에 연결했다. 2026-04-09 보강에서 dedicated ritual family, activation mana drain, fire/dark finisher scaling, solo ash residue regression까지 더해 verified 승격을 마쳤다.
- 2026-04-07 follow-up으로 `arcane_magic_mastery` global modifier layer도 shared runtime helper에 실제 연결했다. 현재 authored source of truth는 `final_multiplier_per_level = 0.003`, `5/15/25` mana 감소, `10/20/30` cooldown 감소이며, active / deploy / toggle 전부가 같은 helper를 읽는다. `register_skill_damage()`는 linked canonical skill row가 없는 arcane runtime spell에서도 global arcane XP를 적립하고, arcane school damage event에서 double-count가 나지 않도록 guard를 함께 잠갔다.
- 같은 follow-up 판단으로 `ice_ice_wall`도 verified 승격까지 닫았다. 현재 `ice_ice_wall_attack / ice_ice_wall / ice_ice_wall_hit / ice_ice_wall_end` dedicated wall family와 wall 전용 `phase_signature = ice_ice_wall`를 실제 runtime source of truth로 잠갔고, `SpellManager` deploy payload는 `attack / hit / terminal` effect id와 `slow + short root` control rider를 함께 싣는다.
- 같은 follow-up 판단으로 `ice_ice_wall`의 현재 잠금 기준도 같이 갱신했다. `생성/유지/파괴` 3단 family, `가로 2.2 플레이어 폭`, `세로 1.3 플레이어 높이`, `0.20초` 이내 wall-read, centered startup / `loop fps 7` / `scale 1.70` / wall phase signature / level 1 대비 level 30 duration·size scaling을 현 기준선으로 유지한다. art refresh는 이 wall-read를 넘길 때만 후속 교체 대상으로 검토한다.
- 같은 2026-04-09 follow-up으로 `earth_quake_break`도 verified 승격까지 닫았다. canonical `earth_quake_break -> earth_tremor` proxy-active contract, centered startup crack, `Impact` strip hit, dedicated `phase_signature = earth_tremor`, level 1 대비 level 30 damage/size/cooldown scaling, `earth_gaia_break`보다 가볍게 읽히는 quake signature hierarchy까지 실제 회귀로 잠갔다.
- 같은 2026-04-09 follow-up으로 `lightning_thunder_lance`도 verified 승격까지 닫았다. canonical `lightning_thunder_lance -> volt_spear` proxy-active contract, fast narrow lance payload, level 1 대비 level 30 damage/range scaling, milestone pierce progression, split effect attack/hit direct attach까지 실제 회귀로 잠갔다.
- 같은 2026-04-09 follow-up으로 `holy_healing_pulse`도 verified 승격까지 닫았다. canonical `holy_healing_pulse -> holy_radiant_burst` proxy-active contract 위에 `self_heal` rider를 실제 연결했고, cast 시 즉시 회복 read, level 1 대비 level 30 damage/range/self-heal scaling, proxy payload self-heal contract까지 실제 회귀로 잠갔다.
- 같은 2026-04-09 follow-up으로 `holy_crystal_aegis`도 verified 승격까지 닫았다. `GameState.get_buff_runtime()` 중앙 helper를 추가해 holy guard buff runtime source를 한곳으로 모았고, cast 시 active buff remaining/cooldown sync, `damage_taken_multiplier`, `super_armor_charges`, `status_resistance` guard contract, level 1 대비 level 30 duration/cooldown/guard scaling 회귀까지 실제로 잠갔다.
- 같은 2026-04-09 follow-up으로 `holy_mana_veil`도 verified 승격까지 닫았다. 같은 `GameState.get_buff_runtime()` 중앙 helper 위에 base holy guard contract를 연결했고, cast 시 active buff remaining/cooldown sync, `damage_taken_multiplier`, `poise_bonus` guard contract, level 1 대비 level 30 duration/cooldown/poise scaling 회귀까지 실제로 잠갔다.
- 같은 2026-04-09 follow-up으로 `wind_tempest_drive`도 verified 승격까지 닫았다. `GameState.get_spell_runtime("wind_tempest_drive")`가 `dash_speed` / `dash_duration`를 실제 active runtime contract로 내리도록 정리했고, `player.on_active_skill_cast_started(skill_id, runtime)`가 이를 직접 소비하게 바꿨다. cast 시 dash state/velocity/timer sync, level 1 대비 level 30 damage/range/dash scaling, `Overclock Circuit` live consumer payload/cooldown 회귀까지 함께 잠갔다.
- 같은 2026-04-09 follow-up으로 `wind_cyclone_prison`도 verified 승격까지 닫았다. `GameState.get_data_driven_skill_runtime()`가 `duration / size / pull_strength / target_count`를 중앙 deploy runtime contract로 보장하도록 정리했고, `SpellManager._cast_deploy()`는 이를 그대로 payload에 싣는다. representative regression도 level 1 대비 level 30 duration/size/pull/target scaling, `slow + root` utility 유지, terminal end read까지 함께 잠갔다.
- 같은 2026-04-09 follow-up으로 `water_tidal_ring`도 verified 승격까지 닫았다. `knockback_scale_per_level` authored field를 `GameState.get_spell_runtime("water_tidal_ring")` 중앙 active runtime contract에 연결했고, cast payload sync와 실제 hit push regression을 함께 붙였다. level 1 대비 level 30 damage/size/knockback scaling이 이제 같은 helper 위에서 잠긴 상태다.
- 2026-04-07 arcane mastery 후속 검증으로 headless startup, `test_game_state.gd 265/265`, `test_spell_manager.gd 273/273`, full GUT `920/920`까지 다시 통과했다. 종료 시 leak warning은 계속 기존 `scripts/main/main.gd` timer 경로와 동일한 알려진 잔여 이슈다.
- 같은 날짜 owner_core follow-up으로 hotbar preset central API도 먼저 준비했다. 현재 `GameState.get_hotbar_preset_ids()`, `get_hotbar_preset_catalog()`, `get_hotbar_preset_label()`, `get_hotbar_preset_data()`, `apply_hotbar_preset()`가 `default / ritual / overclock / deploy_lab / ashen_rite / apex_toggles / funeral_bloom` preset row를 runtime-castable ID로 정규화해 제공한다. `scripts/admin/admin_menu.gd`는 친구 소유라 이번 턴에는 소비 전환까지는 하지 않고, owner_core 범위에서 source API와 회귀 테스트만 먼저 닫았다.
- 같은 follow-up으로 equipment preset central API도 owner_core 범위에서 먼저 열었다. 현재 `GameState.get_equipment_preset_ids()`, `get_equipment_preset_catalog()`, `get_admin_equipment_preset_ids()`, `get_admin_equipment_preset_catalog()`, `get_equipment_preset_label()`, `get_equipment_preset_data()`가 `fire_burst / ritual_control / storm_tempo / earth_deploy / wind_tempo / holy_guard / sanctum_sustain / dark_shadow / arcane_pulse` preset source를 노출하고, admin cycle seed 3종도 별도 API로 고정한다.
- 같은 follow-up으로 buff runtime seed도 data-driven 쪽으로 더 좁혔다. 현재 `GameState.get_registered_buff_skill_ids()`가 `skills.json`의 `skill_type = buff` row를 읽고, buff cooldown 초기화와 cooldown summary도 이 경로를 source of truth로 사용한다.
- 같은 2026-04-07 후속 잠금으로 linked active `skills.json` row의 `cooldown_base`도 primary runtime spell cooldown mirror로 동기화했다. low-circle 무쿨 active와 proxy-active(`holy_healing_pulse`, `lightning_thunder_lance`, `dark_abyss_gate`, `earth_terra_break`)까지 실제 data drift를 정리했고, `GameDatabase.validate_skill_spell_link()`와 `test_game_state.gd`가 이후 mismatch를 에러로 잡는다.
- 같은 follow-up으로 default hotbar seed도 helper 기준으로 더 좁혔다. 현재 `GameState.get_default_spell_hotbar_template()`가 기본 13슬롯 template를 제공하고, reset/init/restore 경로도 이 helper를 source of truth로 사용한다.
- 같은 follow-up으로 default visible shortcut key map도 helper 기준으로 더 좁혔다. 현재 `GameState.get_default_visible_hotbar_keycode_map()`가 기본 `Z/C/V/U/I/P/O/K/L/M` profile을 제공하고, shortcut default restore path도 이 helper를 source of truth로 사용한다.
- 같은 follow-up의 추가 정리로 preset catalog payload helper도 열었다. 현재 `GameState.get_hotbar_preset_catalog()`, `get_equipment_preset_catalog()`, `get_admin_equipment_preset_catalog()`가 `preset_id + label + payload`를 한 번에 제공하므로, friend_gui는 `ids -> label -> data`를 여러 번 왕복하지 않고 바로 버튼/목록 모델을 만들 수 있다.
- 같은 follow-up의 추가 정리로 preset next-id helper도 열었다. 현재 `GameState.get_next_hotbar_preset_id()`와 `get_next_admin_equipment_preset_id()`가 catalog order/wrap 규칙을 owner_core 쪽 source of truth로 제공하므로, friend_gui는 local index 계산 없이 current preset id만 들고 순환할 수 있다.
- 같은 follow-up의 추가 정리로 current preset resolve helper도 열었다. 현재 `GameState.resolve_current_hotbar_preset_id()`와 `resolve_current_admin_equipment_preset_id()`가 live runtime/hotbar/equipment 상태를 기준으로 현재 preset match를 판정하므로, friend_gui는 local selected preset state 없이도 active button highlight와 상태 줄을 그릴 수 있다.
- 같은 follow-up의 추가 정리로 preset state snapshot helper도 열었다. 현재 `GameState.get_hotbar_preset_state()`와 `get_admin_equipment_preset_state()`가 `catalog + current_preset_id + current_label + next_preset_id + next_label`을 한 번에 제공하므로, friend_gui는 개별 helper 조합 없이 바로 preset UI model을 읽을 수 있다.
- 같은 follow-up의 추가 정리로 preset apply-next helper도 열었다. 현재 `GameState.apply_next_hotbar_preset()`와 `apply_next_admin_equipment_preset()`가 snapshot의 `next_preset_id`를 그대로 소비하므로, friend_gui는 local cycle index나 next-id 재계산 없이 버튼 입력을 바로 연결할 수 있다.
- 같은 날짜 map/admin follow-up으로 prototype room weakest-link source API도 먼저 준비했다. 현재 `GameState.get_room_weakest_link_summary()`와 `get_room_weakest_link_summaries()`가 대표 방 6개의 `message + is_locked + next_focus + blocking_flags`를 runtime progression flag 기준으로 노출한다. `scripts/admin/admin_menu.gd`는 친구 소유라 이번 턴에는 소비 전환까지 하지 않고 owner_core 범위에서 source API와 회귀 테스트만 먼저 닫았다.
- 같은 follow-up 검증으로 headless startup과 `test_game_state.gd 297/297`까지 다시 통과했다. 이번 테스트 추가분은 hotbar preset central API, preset catalog payload helper, preset next-id helper, current preset resolve helper, preset state snapshot helper, preset apply-next helper, equipment preset catalog/API, admin preset catalog seed, data-driven buff registry, default hotbar template accessor, default shortcut key map accessor, `arcane_magic_mastery` global layer 회귀, canonical skill data assertions, prototype room weakest-link summary API 쪽이다.
- 같은 follow-up 검증으로 `test_game_state.gd`의 preset 계열 회귀도 더 넓혔다. 이번 추가분은 equipment preset catalog, admin equipment preset cycle seed, duplicate-safe preset data accessor를 잠그는 테스트다.
- 같은 날짜 문서 후속으로 [combat_increment_08_admin_tabs_and_inventory.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_08_admin_tabs_and_inventory.md)에 admin preset 소비 handoff도 잠갔다. friend_gui는 이제 `admin_menu.gd`의 local `PRESET_*` / `HOTBAR_PRESET_*` / equipment cycle seed 하드코딩을 더 늘리지 않고 `GameState` preset API로 전환하면 된다.
- 같은 날짜 전투 체감 후속으로 `4서클 이상 성장 체감` 보정도 닫았다. `circle >= 4` 스킬은 shape별 추가 range/size/duration bonus를 받고, 고서클 광역기의 effect sprite도 현재 반경에 따라 함께 커진다. `spell_projectile._finish_projectile()`는 terminal effect 재진입 시 즉시 free하지 않도록 안전장치를 추가했고, 이후 procedural telegraph와 school phase profile, 대표 signature 후속까지 포함한 최신 대표 회귀는 `test_spell_manager.gd 296/296`, headless startup 기준으로 잠갔다.
- 같은 날짜 다음 후속으로 큰 정지형 burst / field의 floor read도 닫았다. `holy_judgment_halo`, `fire_hellfire_field` 같은 대표 스킬은 실제 판정 반경을 따라가는 procedural `GroundTelegraph`를 갖고, persistent field는 inner ring까지 포함한다. 추가로 startup에는 짧은 `StartupRing`, 종료에는 `TerminalFlash`를 붙여 attack/startup, steady zone, terminal burst를 단계별로 분리했고, school별로도 fire-vs-ice, wind-vs-earth처럼 속도/두께/확산 폭 대비를 분기했다. 이어서 `fire_inferno_buster` 대 `fire_solar_cataclysm`, `earth_gaia_break` 대 `earth_world_end_break`는 같은 school 안에서도 다른 signature로 읽히도록 override를 잠갔다. 최신 회귀는 `test_spell_manager.gd`의 ground telegraph + phase contrast + signature 검증까지 포함한 전체 `296/296`, headless startup이다.
- 같은 날짜 마지막 phase follow-up으로 `holy_judgment_halo` 대 `holy_bless_field`, `plant_genesis_arbor` 대 `plant_worldroot_bastion`, `ice_absolute_zero` 대 `ice_absolute_freeze` 비교도 추가했다. 대표 대형 광역기 안에서 상위기일수록 startup 두께와 terminal 잔향이 더 무겁게 읽히도록 잠갔고, 관련 회귀는 signature targeted `5/5`, headless startup 기준으로 닫았다. 이어서 hotbar/toggle/feedback/current progression summary의 localized string baseline도 정리해 `tests/test_game_state.gd 322/322`, `tests/test_spell_manager.gd 296/296`, headless startup까지 모두 green으로 회복했다.
- 같은 날짜 GUI follow-up으로 enemy HP read도 등급별로 분리했다. 현재 `boss`는 상단 target panel만 사용하고 머리 위 체력바는 숨기며, `normal/elite`는 머리 위 체력바만 유지한다. 관련 회귀는 `test_enemy_base.gd`, `test_game_ui.gd`, headless startup으로 다시 잠갔다.
- 같은 날짜 GUI follow-up으로 `Soul Dominion aftershock`의 HUD read도 더 잠갔다. 현재 `scripts/ui/game_ui.gd`는 상단 `warning row`를 active와 aftershock에서 다른 tint로 그리며, aftershock 동안은 amber pulse를 준다. MP bar도 blue -> deep red(active) -> amber pulse(aftershock)로 분기하고, full-screen `screen edge overlay`도 active red border / aftershock amber pulse border로 따라간다. 추가로 `aftershock -> safe` 전환 시에는 MP bar와 overlay를 즉시 끄지 않고 약 `0.30초` clear beat 뒤에 neutral 상태로 복귀시킨다. 관련 회귀는 `tests/test_game_ui.gd 15/15`, headless startup 기준으로 잠갔다.
- 같은 날짜 dark toggle follow-up으로 `Soul Dominion`의 player-side 종료 감각도 더 잠갔다. 현재 `scripts/player/player.gd`는 종료 직후 `soul_dominion_aftershock` pulse로 위험 잔여를 읽히게 하고, `aftershock -> safe` 전환 시에는 더 작고 차가운 `soul_dominion_clear` beat를 한 번 더 띄워 해제 감각을 닫는다. 관련 회귀는 `tests/test_spell_manager.gd 297/297`, headless startup 기준으로 잠갔다.
- 같은 날짜 main-layer / world-hit follow-up으로 `Soul Dominion` 해제 감각을 전장 전체로도 확장했다. 현재 `scripts/main/main.gd`는 `aftershock -> safe` 전환 시 HUD 뒤 canvas layer에 아주 약한 cool-blue `SoulRiskReleaseOverlay`를 약 `0.22초` 동안만 띄워 release pulse를 남기고, player camera zoom도 `active` 인줌, `aftershock` 완만한 이완, `clear` 짧은 아웃줌 복귀로 나눠 위험 단계의 시선 압력을 분리한다. 동시에 `scripts/ui/damage_label.gd`도 `Soul Dominion` 리스크 단계를 읽어 적 피격 숫자를 `active`에서는 더 크고 더 차가운 violet highlight, `aftershock`에서는 더 약하고 더 warm한 tint로 조정한다. 관련 회귀는 `tests/test_main_integration.gd 19/19`, headless startup 기준으로 잠갔다.
- 같은 날짜 world-hit follow-up을 한 단계 더 이어 `scripts/enemies/enemy_base.gd`의 enemy hit flash도 `Soul Dominion` 리스크 단계를 읽도록 잠갔다. active 중 피격 flash는 더 차갑고 violet 쪽으로 압력을 주고, aftershock 중에는 조금 더 warm하게 풀어 same-world read가 HUD / main release pulse / damage label 위계와 맞물리게 했다. 관련 회귀는 `tests/test_enemy_base.gd 93/93`, `tests/test_main_integration.gd 19/19`, headless startup 기준으로 잠갔다.

### 2026-04-02

- 장기 누적 로그를 [owner_core_workstream_archive_2026-03-30_to_2026-04-02_session_57.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/archive/owner_core_workstream_archive_2026-03-30_to_2026-04-02_session_57.md)로 롤오버했다.
- 현재 운영용 workstream은 `현재 상태`, `다음 우선 작업`, `교차 의존 요청`만 유지하도록 경량화했다.

## 아카이브

- 전체 누적 로그: [owner_core_workstream_archive_2026-03-30_to_2026-04-02_session_57.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/archive/owner_core_workstream_archive_2026-03-30_to_2026-04-02_session_57.md)

## 다음 우선 작업

1. friend GUI가 `Combat HUD Cycle A`와 Maple-style 플레이어 창을 구현하는 동안 현재 공개 hotbar/read-only API, `action_hotkey_registry` API, tooltip payload, canonical save field, hotbar/equipment preset central API만으로 충분한지 확인한다.
2. high-circle buff placeholder 축은 현재 닫혔다. `plant_root_bind`, `holy_bless_field`, `holy_sanctuary_of_reversal`, `earth_fortress`, `wind_storm_zone`, `holy_seraph_chorus`, `holy_dawn_oath`, `wind_sky_dominion`, `dark_throne_of_ash`, `lightning_conductive_surge`, `plant_verdant_overflow`, `dark_grave_pact`는 모두 verified 기준을 충족했다. 다음 작업은 다른 placeholder 축 재분류나 남은 representative row로 이동하면 된다.
3. `scripts/main/main.gd` timer leak warning은 소유 경계 안에서 우회 가능한 검증만 남기고, 직접 수정은 계속 피한다.

## 교차 의존 요청

### [2026-03-31] admin spawn 탭에 bat/worm 타입 추가 요청

- **이유:** `scripts/admin/admin_menu.gd`는 친구 소유 파일. bat과 worm이 `enemies.json`에 추가되었으나 admin spawn 탭의 소환 가능 타입 목록이 자동 갱신되는지 확인이 필요.
- **필요 입력:** admin_menu.gd에서 소환 타입 목록을 hardcode하고 있다면 "bat", "worm" 추가 필요.
- **예상 파일:** `scripts/admin/admin_menu.gd`
- **우선순위:** 낮음 (게임 진행은 가능, admin 편의성 문제)

### [2026-03-31] admin spawn 탭에 mushroom 타입 추가 요청

- **이유:** mushroom이 enemy_base.gd와 enemies.json에 독립 타입으로 추가되었으나 admin spawn 탭 소환 키 미할당.
- **필요 입력:** admin_menu.gd의 spawn 타입 목록과 키 바인딩에 "mushroom" 추가.
- **예상 파일:** `scripts/admin/admin_menu.gd`
- **우선순위:** 낮음 (게임 내 방 배치를 통해 소환 가능)

### [2026-03-31] admin spawn 탭에 5종 신규 몬스터 추가 요청

- **이유:** 6차 세션에서 rat, tooth_walker, eyeball, trash_monster, sword가 enemy_base.gd와 enemies.json에 추가되었으나 admin spawn 탭의 소환 가능 타입 목록에 없음.
- **필요 입력:** admin_menu.gd의 spawn 타입 목록에 다음 추가: "rat", "tooth_walker", "eyeball", "trash_monster", "sword"
- **예상 파일:** `scripts/admin/admin_menu.gd`
- **우선순위:** 낮음 (rooms.json에 spawn 배치로 인게임 등장 가능)

### [2026-04-03] Combat HUD Cycle A 구현 요청

- **이유:** `P1 전투 HUD 그래픽 GUI 최종 명세`가 `ready_for_implementation`으로 잠겼고, 실제 GUI 파일은 friend_gui 소유 범위다.
- **필요 입력:** [combat_increment_06_combat_ui.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_06_combat_ui.md)의 `2026-04-03 구현 handoff — Combat HUD Cycle A` 섹션을 그대로 구현한다. 이번 증분은 `10슬롯 가시 action row`, `상단 좌측 활성 버프 row`, `하단 중앙 자원 클러스터`, `dimmed unavailable state`, `hover tooltip`, `우클릭 언바인드`, `drag swap`, `HUD hide 시 mouse target 제거`까지를 목표로 하고, owner_core 파일은 건드리지 않는다.
- **예상 파일:** `scripts/ui/game_ui.gd`, `scripts/ui/widgets/**`, `scenes/ui/**`, GUI 전용 신규 테스트 파일
- **우선순위:** 높음 (현재 HUD GUI 구현의 첫 안전 증분)

### [2026-04-07] admin preset central API 소비 전환 요청

- **이유:** owner_core가 `GameState`에 hotbar/equipment preset source of truth를 이미 중앙화했지만, `scripts/admin/admin_menu.gd`는 아직 local `PRESET_*`, `HOTBAR_PRESET_*`, `["fire_burst", "ritual_control", "storm_tempo"]` 하드코딩을 사용한다. 이 상태를 계속 두면 GUI 쪽 preset 추가나 문서 동기화 때 다시 분기된다.
- **필요 입력:** hotbar preset 버튼/active state/순환은 `GameState.get_hotbar_preset_state()`와 `apply_next_hotbar_preset()`를 우선 사용하고, equipment preset active state/순환은 `GameState.get_admin_equipment_preset_state()`와 `apply_next_admin_equipment_preset()`를 우선 사용하도록 전환한다. preset row payload는 `GameState`가 이미 runtime-castable ID로 정규화하므로 `admin_menu.gd` 내부에서 별도 정규화나 `wind_tempest_drive` 특수 분기를 추가하지 않는다.
- **예상 파일:** `scripts/admin/admin_menu.gd`, `tests/test_admin_menu.gd`
- **우선순위:** 높음 (다음 GUI 통합 증분에서 바로 반영 가능한 handoff)

### [2026-04-07] admin room weakest-link 소비 전환 요청

- **이유:** owner_core가 `GameState.get_room_weakest_link_summary()`와 `get_room_weakest_link_summaries()`로 representative room 6개의 weakest-link 판정 기준을 중앙화했지만, `scripts/admin/admin_menu.gd`는 아직 room별 조건문으로 같은 문구를 로컬 계산한다. 이 상태를 계속 두면 후속 map payoff나 flag 규칙 변경 때 admin과 runtime 문구가 다시 분기된다.
- **필요 입력:** `admin_menu.gd`의 `Weakest Link` 블록은 room별 `match` 하드코딩 대신 `GameState.get_room_weakest_link_summary(selected_room_id)`를 읽어 `message`를 그대로 표시하고, 필요하면 `is_locked`/`next_focus`/`blocking_flags`를 부가 상태 줄이나 정렬 기준에 재사용한다.
- **예상 파일:** `scripts/admin/admin_menu.gd`, `tests/test_admin_menu.gd`
- **우선순위:** 높음 (reactive surface summary API 다음 단계 handoff)
