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
last_updated: 2026-04-10
last_verified: 2026-04-10
---

# 현재 런타임 기준선

상태: 기준 문서  
최종 갱신: 2026-04-10

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

## 2026-04-07 공격 스킬 다단 / 무쿨 기준선

- active 공격 스킬 runtime source of truth:
  - `data/spells.json`
  - 현재 잠긴 필드: `cooldown`, `damage`, `multi_hit_count`, `hit_interval`, `source_skill_id`
  - linked active `skills.json` row의 `cooldown_base`는 mirror field이며 primary runtime spell cooldown과 같은 값으로 유지한다.
- deploy / toggle 공격 cadence source of truth:
  - `data/skills/skills.json`
  - 현재 잠긴 필드: `tick_interval`, `damage_cadence_reference_interval`
- active on-hit multi-hit runtime contract:
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd`는 active cast payload를 1회만 emit하고, `damage / total_damage / multi_hit_count / multi_hit_total / hit_interval` metadata를 싣는다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_projectile.gd`가 적중 후 대상별 sequence를 시작하고, 총합 피해를 authored hit 수만큼 분할해 순차 적용한다.
  - `attack_effect`는 `_ready()` 진입 시 1회만 재생하고, `hit_effect`만 실제 hit마다 반복 재생한다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd`의 `suppress_cast_lock`는 이제 cast follow-up hit가 아니라 장비 `projectile_count_bonus`로 추가 생성된 bonus projectile emit만 억제한다.
- deploy / toggle cadence normalization runtime contract:
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_data_driven_skill_base_runtime()`가 `damage_cadence_reference_interval`을 읽고 `min(duration, 3.0초)` window 기준 hit 수로 tick damage를 재분배한다.
  - 장비 cast speed bonus는 여전히 runtime reward로 남기고, authored cadence 변경분만 normalize한다.
- 1~4서클 무쿨 active baseline:
  - `fire_bolt`, `water_aqua_bullet`, `wind_arrow`, `earth_stone_shot`, `holy_halo_touch`, `fire_flame_bullet`, `water_aqua_spear`, `wind_gust_bolt`, `earth_rock_spear`, `ice_frost_needle`, `wind_gale_cutter`, `fire_flame_arc`, `water_tidal_ring`, `water_wave`, `holy_cure_ray`, `holy_radiant_burst`, `volt_spear`, `lightning_bolt`, `ice_spear`, `lightning_thunder_arrow`
- 1~4서클 무쿨 예외 baseline:
  - `earth_stone_spire`, `plant_vine_snare`, `dark_shadow_bind`, `ice_ice_wall`
- 지원 / 회복 중심 runtime 중 이번 턴 공격 cadence 제외 baseline:
  - `holy_bless_field`, `holy_sanctuary_of_reversal`, `holy_seraph_chorus`

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

- 2026-04-02 기준으로 당시 `data/skills/skills.json`의 전체 `42/42` row에 `canonical_skill_id`가 명시됐다.
- 2026-04-06 follow-up에서 `wind_cyclone_prison` canonical deploy row를 추가해 기준선이 `43/43` row로 올라갔다.
- 같은 날짜 fallback projectile / line 1차 파동으로 `wind_arrow`, `earth_stone_shot`, `holy_halo_touch`, `fire_flame_bullet`, `water_aqua_spear`, `wind_gust_bolt`, `earth_rock_spear`, `ice_spear`, `lightning_thunder_arrow` canonical row와 runtime spell row를 함께 추가했고, 기준선이 `54/54` row로 올라갔다.
- 같은 날짜 fallback field / aura 2차 파동으로 `fire_flame_storm`, `fire_hellfire_field` canonical deploy row를 추가해 기준선이 `56/56` row로 올라갔다.
- 같은 날짜 fallback field / aura 3차 파동으로 `holy_bless_field`, `wind_storm_zone`, `holy_seraph_chorus` canonical row를 추가했고, 현재 총량 기준선은 `59/59` row다.
- 같은 날짜 fallback field / aura 4차 파동으로 `ice_storm`, `earth_fortress`, `plant_world_root` canonical row를 추가했고, 현재 총량 기준선은 `62/62` row다.
- 같은 날짜 fallback projectile / line 6차 파동으로 `water_wave` canonical row와 runtime spell row를 함께 추가했고, 현재 총량 기준선은 `63/63` row다.
- 같은 날짜 fallback projectile / line 7차 파동으로 `lightning_bolt` canonical row와 runtime spell row를 함께 추가했고, 기준선이 `64/64` row로 올라갔다.
- 같은 날짜 fallback projectile / line 8차 파동으로 `ice_absolute_freeze` canonical row와 runtime spell row를 함께 추가했고, 현재 총량 기준선은 `65/65` row다.
- 같은 날짜 fallback projectile / line 9차 파동으로 `fire_inferno_buster` canonical row와 runtime spell row를 함께 추가했고, 현재 총량 기준선은 `66/66` row다.
- 같은 날짜 fallback projectile / line 10차 파동으로 `wind_storm` canonical row와 runtime spell row를 함께 추가했고, 현재 총량 기준선은 `67/67` row다.
- 같은 날짜 fallback projectile / line 11차 파동으로 `fire_meteor_strike` canonical row와 runtime spell row를 함께 추가했고, 현재 총량 기준선은 `68/68` row다.
- 같은 날짜 fallback projectile / line 12차 파동으로 `water_tsunami` canonical row와 runtime spell row를 함께 추가했고, 현재 총량 기준선은 `69/69` row다.
- 같은 날짜 fallback projectile / line 13차 파동으로 `earth_gaia_break` canonical row와 runtime spell row를 함께 추가했고, 현재 총량 기준선은 `70/70` row다.
- 같은 날짜 fallback projectile / line 14차 파동으로 `earth_continental_crush` canonical row와 runtime spell row를 함께 추가했고, 현재 총량 기준선은 `71/71` row다.
- 같은 날짜 fallback projectile / line 15차 파동으로 `fire_apocalypse_flame` canonical row와 runtime spell row를 함께 추가했고, 현재 총량 기준선은 `72/72` row다.
- 같은 날짜 fallback projectile / line 16차 파동으로 `water_ocean_collapse` canonical row와 runtime spell row를 함께 추가했고, 현재 총량 기준선은 `73/73` row다.
- 같은 날짜 fallback projectile / line 17차 파동으로 `wind_heavenly_storm` canonical row와 runtime spell row를 함께 추가했고, 현재 총량 기준선은 `74/74` row다.
- 같은 날짜 fallback projectile / line 18차 파동으로 `fire_solar_cataclysm` canonical row와 runtime spell row를 함께 추가했고, 현재 총량 기준선은 `75/75` row다.
- 같은 날짜 fallback projectile / line 19차 파동으로 `earth_world_end_break` canonical row와 runtime spell row를 함께 추가했고, 현재 총량 기준선은 `76/76` row다.
- 같은 날짜 fallback projectile / line 20차 파동으로 `ice_absolute_zero` canonical row와 runtime spell row를 함께 추가했고, 총량 기준선은 `77/77` row다.
- 같은 날짜 fallback field / aura 6차 파동으로 `wind_sky_dominion` canonical row를 추가했고, 현재 총량 기준선은 `78/78` row다.
- 같은 날짜 fallback buff guard 확장으로 `holy_dawn_oath` canonical row를 추가했고, 2026-04-09 후속으로 `arcane_force_pulse`, `fire_inferno_breath`, `earth_stone_rampart`, `water_aqua_geyser` canonical row까지 실제 `skills.json`에 추가해 현재 총량 기준선은 `83/83` row다.
- row-level canonical 마이그레이션은 현재 기준으로 완료됐고, 이후 후속 작업은 새 canonical 부착이 아니라 검증과 운영 문서 정리다. 단, 사용자 결정으로 source of truth가 새로 잠길 때는 예외적으로 same-turn canonical row 추가를 허용한다.
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
- 2026-04-06 fallback projectile / line 1차 파동 이후 현재 placeholder runtime으로 실제 시전 가능한 저서클 planned 액티브는 `wind_arrow`, `earth_stone_shot`, `holy_halo_touch`, `fire_flame_bullet`, `water_aqua_spear`, `wind_gust_bolt`, `earth_rock_spear`, `ice_spear`, `lightning_thunder_arrow`까지 확장됐다. 이들은 모두 `asset_sample/Effect` 기반 임시 family와 split effect attack/hit, representative GUT 회귀를 가진다.
- 2026-04-09 사용자 결정 후속으로 `arcane_force_pulse`도 더 이상 미정 prototype이 아니라 checked-in dedicated `arcane_force_pulse_attack / arcane_force_pulse / arcane_force_pulse_hit` family를 쓰는 독립 canonical active row가 됐다. 현재 baseline contract는 `source_skill_id = arcane_force_pulse`, low-circle zero-cooldown, split effect payload, level 1 대비 level 30 damage/range/knockback scaling이다.
- 같은 2026-04-09 follow-up으로 `fire_inferno_breath`도 checked-in dedicated `fire_inferno_breath_attack / fire_inferno_breath / fire_inferno_breath_hit` family를 쓰는 독립 canonical active row가 됐다. 현재 baseline contract는 `source_skill_id = fire_inferno_breath`, stationary five-hit cone pressure, level 1 대비 level 30 damage/range/cooldown/burn-chance scaling, 64x64 split-effect tile normalization이다.
- 같은 2026-04-09 후속 사이클로 `earth_stone_rampart`도 checked-in dedicated `earth_stone_rampart_attack / earth_stone_rampart / earth_stone_rampart_hit / earth_stone_rampart_end` family를 쓰는 독립 canonical deploy row가 됐다. 현재 baseline contract는 short stone wall, `phase_signature = earth_stone_rampart`, spawn burst + persistent block read, level 1 대비 level 30 duration/size scaling, contact `slow + root` control rider다.
- 같은 2026-04-09 후속 사이클로 `water_aqua_geyser`도 checked-in dedicated `water_aqua_geyser_attack / water_aqua_geyser / water_aqua_geyser_hit / water_aqua_geyser_end` family를 쓰는 독립 canonical active row가 됐다. 현재 baseline contract는 `source_skill_id = water_aqua_geyser`, keyboard-first fixed-forward burst spawn, dedicated geyser `phase_signature = water_aqua_geyser`, level 1 대비 level 30 damage/size/knockback scaling, launch read를 위한 high-knockback payload다.
- 같은 날짜 fallback field / aura 2차 파동 이후 planned field / aura 축은 `fire_flame_storm`, `holy_sanctuary_of_reversal`, `fire_hellfire_field`, `lightning_tempest_crown`, `dark_soul_dominion`까지 확장됐다. 이후 2026-04-09 follow-up으로 `fire_flame_storm`은 checked-in dedicated flame field family와 damage/duration/size/target scaling contract까지, `fire_hellfire_field`는 checked-in dedicated hellfire field family와 large-field damage/duration/size/target scaling contract까지, `holy_sanctuary_of_reversal`은 dedicated sanctuary family와 `self_heal + damage_taken_multiplier + poise_bonus` reversal survival contract까지, `dark_soul_dominion`도 checked-in dedicated 5-stage toggle family와 `0.4s` finisher cadence/aftershock-clear contract까지 verified 승격을 마쳤다.
- 같은 날짜 fallback field / aura 3차 파동 이후 planned field / aura 축은 `holy_bless_field`, `wind_storm_zone`, `holy_seraph_chorus`까지 추가 확장됐다. 이후 2026-04-09 follow-up으로 `holy_bless_field`는 dedicated blessing family와 `self_heal + poise_bonus` support field contract까지, `wind_storm_zone`은 dedicated storm-zone family와 `slow + pull_strength` enemy control zone contract까지, `holy_seraph_chorus`는 dedicated chorus family와 `damage + self_heal + poise_bonus` mixed holy aura contract까지 승격됐다.
- 같은 날짜 fallback field / aura 4차 파동 이후 planned field / aura 축은 `ice_storm`, `earth_fortress`, `plant_world_root`까지 추가 확장됐다. 이후 2026-04-09 follow-up으로 `ice_storm`은 checked-in dedicated frost-storm family와 `0.6s` cadence의 damage/duration/size/target scaling + slow/freeze control contract까지, `earth_fortress`는 dedicated fortress family와 `defense_multiplier + poise_bonus + status_resistance` pure guard toggle contract까지, `plant_world_root`는 checked-in dedicated world-root family와 `0.5s` cadence의 damage/duration/size/target scaling + root control contract까지 승격됐다.
- 같은 날짜 fallback field 5차 파동으로 `plant_genesis_arbor`도 실제 연결했다. 이후 2026-04-09 follow-up으로 `plant_genesis_arbor`는 checked-in dedicated genesis family와 `0.4s` cadence의 damage/duration/size/target scaling + root control contract, worldroot_bastion보다 더 큰 final-canopy hierarchy regression까지 verified 승격을 마쳤다.
- 같은 날짜 fallback field plant 후속 파동으로 `plant_worldroot_bastion`도 실제 연결했다. 이후 2026-04-09 follow-up으로 `plant_worldroot_bastion`은 checked-in dedicated bastion family와 `0.6s` cadence의 damage/duration/size/target scaling + root control contract, world-root/genesis-arbor 사이 visual hierarchy regression까지 verified 승격을 마쳤다.
- 같은 날짜 fallback dark field 후속 파동으로 `dark_shadow_bind`도 실제 연결했다. 이후 2026-04-09 follow-up으로 `dark_shadow_bind`는 checked-in dedicated curse-field family와 `0.75s` cadence의 damage/duration/size/target scaling + slow control contract까지 verified 승격을 마쳤다.
- 같은 2026-04-09 follow-up으로 `plant_vine_snare`도 `plant_vine_snare_attack / plant_vine_snare / plant_vine_snare_hit / plant_vine_snare_end` dedicated vine-bind family를 실제 runtime source of truth로 승격했다. 현재 `plant_root_bind` canonical alias는 dedicated deploy family, repeated root pulse contract, `phase_signature = plant_vine_snare` ground telegraph까지 함께 잠겼다.
- 같은 날짜 fallback field / aura 6차 파동으로 `wind_sky_dominion`도 `sky_dominion_activation/loop/end` family를 더 큰 pale mint-white ultimate aura 해석으로 실제 연결했다. 이후 2026-04-09 follow-up으로 zero-damage `move_speed_multiplier + jump_velocity_multiplier + gravity_multiplier + air_jump_bonus` aerial utility contract와 owner mobility/expiry regression까지 승격됐다.
- 같은 날짜 fallback aura dark 확장으로 `dark_grave_echo`도 `grave_echo_activation` / `grave_echo_loop` / `grave_echo_end` family를 muted violet curse aura 해석으로 실제 연결했다. 이후 2026-04-09 follow-up으로 checked-in dedicated toggle family, `0.6s` curse cadence, level scaling regression, dark toggle overlay priority regression까지 함께 잠겨 verified로 승격됐다.
- 같은 날짜 fallback buff guard 확장으로 `holy_dawn_oath`도 `holy_guard_activation` / `holy_guard_overlay` family를 더 큰 scale과 더 높은 overlay priority 해석으로 실제 연결했다. 이후 2026-04-09 follow-up으로 `holy_dawn_oath_activation / holy_dawn_oath_overlay` dedicated final-guard family와 `damage_taken_multiplier + super_armor_charges + status_resistance` final holy guard contract까지 승격됐다.
- 같은 날짜 fallback buff ritual 확장으로 `dark_throne_of_ash`도 `dark_throne_activation` / `dark_throne_overlay` family를 dark ash tint owner-follow ritual overlay 해석으로 실제 연결했다. 이후 2026-04-09 follow-up으로 checked-in dedicated ritual family, activation mana drain, `fire_final_damage_multiplier + dark_final_damage_multiplier + ash_residue_burst` dual-school finisher contract와 level scaling regression까지 함께 잠겨 verified로 승격됐다.
- 같은 날짜 fallback buff lightning 확장으로 `lightning_conductive_surge`도 `conductive_surge_activation` / `conductive_surge_overlay` family를 bright lightning tint owner-follow overlay 해석으로 실제 연결했다. 이후 2026-04-09 follow-up으로 checked-in dedicated buff family, `lightning_final_damage_multiplier + chain_bonus + extra_lightning_ping` offense contract, level scaling regression, `Overclock Circuit` active window representative regression까지 함께 잠겨 verified로 승격됐다.
- 같은 날짜 fallback buff plant 확장으로 `plant_verdant_overflow`도 `verdant_overflow_activation` / `verdant_overflow_overlay` family를 verdant tint owner-follow overlay 해석으로 실제 연결했다. 이후 2026-04-09 follow-up으로 checked-in dedicated buff family, `deploy_range_multiplier + deploy_duration_multiplier + deploy_target_bonus` 설치 증폭 contract, level scaling regression, `Funeral Bloom` 연계 representative regression까지 함께 잠겨 verified로 승격됐다.
- 같은 날짜 fallback buff dark 확장으로 `dark_grave_pact`도 `grave_pact_activation` / `grave_pact_overlay` family를 muted violet owner-follow pact overlay 해석으로 실제 연결했다. 이후 2026-04-09 follow-up으로 checked-in dedicated pact family, `dark_final_damage_multiplier + kill_leech + hp_drain_percent_per_second` dark risk contract, level scaling regression, dark-only amplification representative regression까지 함께 잠겨 verified로 승격됐다.
- 같은 날짜 후속 정리와 2026-04-07 canonical lock으로 `wind_tempest_drive`는 `tempest_drive_activation` family를 active startup visual로만 유지하고, activation 순간 중거리 전방 mobility burst + same-turn wind activation burst payload를 함께 쓰는 5서클 순수 active runtime으로 정리했다. current source of truth는 `spells.json.wind_tempest_drive` burst row와 `skills.json.wind_tempest_drive` active metadata + dash direct field다.
- 같은 날짜 fallback buff fire / ice / arcane 후속 확장으로 `fire_pyre_heart`, `ice_frostblood_ward`, `arcane_astral_compression`, `arcane_world_hourglass`도 각각 `pyre_heart_activation` / `pyre_heart_overlay`, `frostblood_ward_activation` / `frostblood_ward_overlay`, `astral_compression_activation` / `astral_compression_overlay`, `world_hourglass_activation` / `world_hourglass_overlay` family를 실제 연결했다. 2026-04-09 follow-up으로 네 row 모두 checked-in dedicated family와 level scaling regression까지 닫혀 verified로 승격됐다.
- 같은 follow-up 판단으로 buff overlay 위계는 `fire_pyre_heart < lightning_conductive_surge < arcane_astral_compression < dark_grave_pact < arcane_world_hourglass < ice_frostblood_ward < holy_mana_veil < holy_crystal_aegis < holy_dawn_oath < dark_throne_of_ash` 순서를 baseline으로 유지한다.
- 현재 baseline에서 `wind_tempest_drive`는 더 이상 buff slot이나 tempo buff semantics를 갖지 않는다. canonical 입력은 visible action slot이고, 기존 `G` 입력은 레거시 직접 시전만 허용 가능하다. `Overclock Circuit`는 current buff combo data가 아니라 runtime active-combo state이며, `Conductive Surge` 활성 중 `Tempest Drive` 시전 성공 시 `1.0초` window를 열고 다음 전기 액티브 1회에 `aftercast x0.88`, `chain +1`, `speed x1.18`을 적용한 뒤 소모한다.
- 같은 날짜 fallback projectile / line 6차 파동으로 `water_wave`도 `fallback_water_attack/line/hit` family를 더 넓은 control-wave 해석으로 실제 연결했다. 현재 3서클 물 line-control 축도 placeholder runtime 위에서 시전과 representative regression이 가능하다.
- 같은 날짜 fallback projectile / line 7차 파동으로 `lightning_bolt`도 `fallback_shard_attack/projectile/hit` family를 더 밝은 chain-control bolt 해석으로 실제 연결했다. 현재 4서클 전기 line-control 축도 placeholder runtime 위에서 시전과 representative regression이 가능하다.
- 같은 날짜 fallback projectile / line 8차 파동으로 `ice_absolute_freeze`도 `fallback_ice_field_attack/loop/hit` family를 더 넓은 cyan-white absolute burst 해석으로 실제 연결했다. 현재 6서클 얼음 광역 CC 축도 placeholder runtime 위에서 시전과 representative regression이 가능하다.
- 2026-04-03 save / UI / runtime 잔여 리스크 재검토와 hotbar hardening 결과는 아래와 같다.
  - `low`: 기본 hotbar, 기본 loadout, admin named preset은 proxy active row에 대해 계속 runtime spell ID를 사용한다. 현재 확인된 안전 축은 `holy_radiant_burst -> holy_healing_pulse`, `dark_void_bolt -> dark_abyss_gate`, `plant_vine_snare -> plant_root_bind`, `lightning_tempest_crown -> lightning_tempest_crown`이다.
  - `low`: `GameDatabase.get_skill_data(skill_id)`의 canonical alias lookup과 `GameState.get_skill_id_for_spell(spell_id)` fallback 덕분에 save / admin detail / 문서형 조회는 canonical row key 유지 이후에도 계속 읽힌다.
  - `low`: `GameState.set_hotbar_skill()`는 이제 입력된 `skill_id`를 runtime-castable hotbar ID로 먼저 정규화한다. `holy_healing_pulse -> holy_radiant_burst`, `dark_abyss_gate -> dark_void_bolt`, `plant_root_bind -> plant_vine_snare`처럼 proxy active / deploy canonical row를 직접 넣어도 저장값은 실제 시전 가능한 runtime ID로 수렴한다.
  - `low`: save payload의 canonical field는 이제 `spell_hotbar` 첫 10슬롯만 기록한다. 내부 13슬롯 런타임은 유지하되, 나머지 3슬롯은 `legacy_spell_hotbar_tail` 호환 필드에 분리 저장한다.
  - `low`: `load_save()`는 `10슬롯 canonical + legacy tail` 신규 save와 과거 `13슬롯 spell_hotbar` save를 둘 다 읽는다. 과거 save에 남은 stale invalid ID는 hotbar 초기화 시 proxy runtime ID로 치환되거나, 대응 runtime ID가 없으면 슬롯 기본값으로 되돌린다.
  - `low`: explicit `visible_hotbar_shortcuts` payload가 없는 old save도 첫 10슬롯의 `action + label`을 읽어 visible shortcut profile을 재구성한다. 이 경로 덕분에 legacy save는 HUD label과 keyboard input을 같이 복원할 수 있다.
  - `low`: owner_core는 GUI shell 연결용 비파괴 bridge API를 추가했다. `GameState.get_visible_spell_hotbar()`, `get_hotbar_slot()`, `clear_hotbar_skill()`, `swap_hotbar_skills()`와 `spell_manager/player` wrapper는 현재 `13슬롯` 저장 구조를 유지한 채 `첫 10슬롯 가시 row`, tooltip payload, unbind, swap 상호작용을 읽고 쓸 수 있게 한다.
  - `low`: visible hotbar shortcut rebind persistence는 legacy/bridge API로 유지된다. 현재 플레이어 GUI canonical 은 `1~0` fixed quickslot row이고, old save의 visible shortcut payload와 13슬롯 save는 계속 호환한다.
  - `low`: `GameState.action_hotkey_registry`가 `V / A / S / D / F / Shift / Ctrl / Alt` 8슬롯 확장 row를 저장하고, `get_action_hotkey_registry()`가 `13슬롯 hotbar + 8슬롯 확장 row = 21슬롯 fixed action registry` view를 노출한다.
  - `low`: 전투 입력 canonical 은 이제 `spell_manager` 기준으로 이 `21슬롯 fixed action registry` 전체를 읽는다. 즉 visible 10슬롯이 HUD primary row이고, hidden `Z / X / C` 및 확장 8슬롯도 keyboard combat primary path에서 직접 시전된다.
  - 현재 운영 결론은 `Phase 6` row key 유지 자체와 hotbar/save hardening이 모두 안전하다는 것이다. 남은 후속 작업은 canonical 식별자 재판정이 아니라 대표 active / buff / deploy row의 effect 검증 확대다.
- 2026-04-03 `fire_mastery` runtime wiring 결과는 아래와 같다.
  - `data/skills/skills.json`의 `fire_mastery` row는 이제 `final_multiplier_per_level = 0.05`를 사용한다.
  - `GameState.get_spell_runtime()`와 `scripts/player/spell_manager.gd`의 data-driven runtime builder는 fire school `active / deploy / toggle`의 `damage`와 `cooldown`에 fire mastery를 먼저 적용한 뒤 장비 / 버프 / 공명을 적용한다.
  - `GameState.get_skill_mana_cost()`와 `spell_manager`의 toggle sustain cost helper는 fire mastery milestone의 마나 감소를 buff `mana_efficiency_multiplier`보다 먼저 읽는다.
  - GUT 기준선으로는 `fire_mastery` lv10에서 `fire_bolt` 피해가 `26`, `weapon_ember_staff` 장착 시 `34`, cooldown이 `0.2134`가 되는 상태를 잠갔다.
  - 이번 구조 개선 후속 증분에서 school-specific mastery modifier stack은 `fire_mastery` 단일 하드코딩이 아니라 `SCHOOL_TO_MASTERY` + mastery row data를 읽는 shared helper로 옮겼다.
  - representative regression은 `water_aqua_bullet` active, `plant_vine_snare` deploy, `dark_grave_echo` toggle의 damage / cooldown / mana contract로 잠갔다.
  - 2026-04-07 후속 증분부터 `arcane_magic_mastery`도 `applies_to_school = all`, `applies_to_element = all` global mastery layer로 shared helper에 실제 포함됐다.
- 2026-04-03 구조 개선 증분으로 common runtime scaling source of truth는 아래처럼 정리됐다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_common_runtime_stat_block()`이 active / deploy / toggle 공통의 level scaling, mastery modifier, equipment multiplier 적용을 담당한다.
  - 같은 파일의 `get_common_scaled_mana_value()`가 direct mana cost와 toggle sustain mana cost의 공통 scaling을 담당한다.
  - `GameState.get_spell_runtime()`와 `scripts/player/spell_manager.gd`의 `_build_skill_runtime()`는 공통 stat helper를 먼저 호출한 뒤 각 타입별 후처리를 얹는다.
  - `GameState.get_skill_mana_cost()`와 `scripts/player/spell_manager.gd`의 `_get_toggle_mana_drain_per_tick()`는 공통 mana helper를 먼저 호출한 뒤 buff 등 type-specific 후처리를 얹는다.
  - `GameState.get_mastery_runtime_modifiers_for_skill()`는 이제 school-specific mastery row와 `arcane_magic_mastery` global layer를 함께 data-driven으로 읽는다.
  - 현재 `arcane_magic_mastery` authored source of truth는 `final_multiplier_per_level = 0.003`, `5/15/25` mana 감소, `10/20/30` cooldown 감소다.
  - `register_skill_damage()`는 linked canonical skill row가 없는 arcane runtime spell에서도 global arcane XP를 적립하고, arcane school damage event에서 `arcane_magic_mastery` XP를 두 번 더하지 않도록 guard를 둔다.
  - 2026-04-07 후속 증분으로 `ice_glacial_dominion`, `lightning_tempest_crown`, `wind_storm_zone`, `earth_fortress`도 level 30 mastery representative verification을 통과했다. 이후 2026-04-09 follow-up으로 `earth_fortress`는 zero-damage pure defense toggle로 재정의된 뒤에도 cooldown / sustain mana shared helper contract를 유지하는 representative row로 다시 잠겼다. 이로써 school-specific helper representative coverage는 `water_aqua_bullet` active, `plant_vine_snare` deploy, `dark_grave_echo` toggle, `ice_glacial_dominion` toggle, `lightning_tempest_crown` toggle, `wind_storm_zone` toggle, `earth_fortress` toggle까지 닫혔다.
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
  - 2026-04-07 `wind_tempest_drive` active conversion과 같은 날짜 후속 잠금으로 `combo_overclock_circuit` row는 current buff combo data에서 제거했다. 기존 lightning aftercast / chain / dash_cast bundle은 historical note로만 남기고, current runtime contract는 `GameState`가 유지하는 `1.0초` active window 상태로 옮겼다.
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
- 2026-04-06 신규 effect/buff visual 기준선은 아래처럼 정리됐다.
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd`의 `SPLIT_EFFECT_PAYLOADS`와 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_projectile.gd`의 world effect registry가 projectile/hit one-shot visual ID source of truth다.
  - 현재 runtime split effect family는 `fire_bolt`, `water_aqua_bullet`, `water_tidal_ring`, `wind_gale_cutter`, `earth_tremor`, `dark_void_bolt`, `holy_radiant_burst`, `holy_cure_ray`, `holy_judgment_halo`, `volt_spear`, `earth_stone_spire`, `wind_cyclone_prison`, `ice_frost_needle`, `fire_inferno_sigil`, `ice_ice_wall` 15개다.
  - 2026-04-06 증분에서 `dark_void_bolt_*`, `volt_spear_*`, `holy_radiant_burst_*` frame set은 신규 에셋 기반 tile로 교체됐고, follow-up으로 `water_aqua_bullet_*`, `wind_gale_cutter_*`, `earth_stone_spire_*`, `earth_tremor_*`, `wind_cyclone_prison_*`, `ice_frost_needle_*`, `water_tidal_ring_*`, `holy_cure_ray_*`, `holy_judgment_halo_*`, `fire_inferno_sigil_*` split family도 실제 추가/교체됐다. 2026-04-09 후속으로 `ice_ice_wall_*`는 dedicated wall family와 wall 전용 phase signature 기준으로 다시 잠갔고, `earth_tremor`도 dedicated quake phase signature를 함께 잠갔다. `earth_tremor_*`는 canonical `earth_quake_break` proxy용 broad crack burst family고, `ice_ice_wall_*`는 별도 wall-control representative family다. runtime effect ID는 registry 기준을 유지한다.
  - sampled spell visual source of truth는 같은 파일의 `SPELL_VISUAL_SPECS`다. 현재 `water_aqua_bullet`, `wind_gale_cutter`, `earth_stone_spire`, `fire_flame_arc`, `holy_cure_ray`, `holy_judgment_halo`, `wind_cyclone_prison`, `ice_frost_needle`, `water_tidal_ring`, `fire_inferno_buster`, `wind_storm`, `water_tsunami`, `water_ocean_collapse`, `wind_heavenly_storm`, `fire_inferno_sigil`, `ice_ice_wall`, `ice_absolute_zero`, `earth_gaia_break`, `earth_continental_crush`, `earth_world_end_break`, `fire_apocalypse_flame`, `fire_solar_cataclysm`가 이 경로를 사용한다. `water_aqua_bullet`는 18프레임 WaterBall loop, `wind_gale_cutter`는 2프레임 cutter loop를 쓰고, `fire_inferno_buster`는 dedicated inferno burst loop를, `wind_storm`은 dedicated storm burst loop를, `water_tsunami`와 `water_ocean_collapse`는 각각 dedicated tidal/ocean lane loop를, `wind_heavenly_storm`는 dedicated heavenly burst loop를 쓴다. `fire_inferno_sigil`은 2026-04-07 cadence rework 이후 loop fps `7.0`, main scale `1.84`, brighter-white bias를 줄인 amber modulate와 `0.4s` pulse cadence를 함께 사용한다. `ice_ice_wall`는 dedicated wall loop를 `fps 7.0`, `scale 1.70`, pale ice-white modulate와 함께 사용한다.
  - terminal burst source of truth는 같은 파일의 `TERMINAL_EFFECT_SPECS`다. 현재 `water_tsunami_end`, `water_ocean_collapse_end`, `wind_cyclone_prison_end`, `holy_judgment_halo_end`, `fire_inferno_sigil_end`, `ice_ice_wall_end`, `ice_absolute_zero_end`, `earth_gaia_break_end`, `earth_continental_crush_end`, `earth_world_end_break_end`, `fire_apocalypse_flame_end`, `fire_solar_cataclysm_end`가 신규 연결됐다.
  - data-driven deploy payload seed source of truth는 `GameState.build_data_driven_combat_payload()`고, follow-up 기준 `pull_strength`, `target_count`도 이 경로에 포함된다.
  - buff activation/overlay visual authored source of truth는 `data/skills/skills.json` 각 buff row의 `buff_effects` 안 `activation_visual_effect_id`, `activation_visual_scale`, `activation_visual_color`, `overlay_visual_effect_id`, `overlay_visual_scale`, `overlay_visual_color` stat이다.
  - 런타임 hook은 버프 계열에서 `scripts/player/spell_manager.gd`의 buff cast path -> `GameState.get_buff_runtime(skill_id)` -> `player.on_buff_activated(skill_id)` -> `scripts/player/player.gd`의 `BUFF_VISUAL_SPECS` 순서로 닫혀 있다. 현재 `holy_mana_veil`, `holy_crystal_aegis`는 `holy_guard_activation`, `holy_guard_overlay` family를 공용 사용하고, `holy_dawn_oath`는 2026-04-09 follow-up으로 `holy_dawn_oath_activation`, `holy_dawn_oath_overlay` dedicated final-guard family를 사용한다. 이 중 `holy_mana_veil`은 base holy guard runtime contract, `holy_crystal_aegis`는 advanced guard runtime contract, `holy_dawn_oath`는 damage-reduction focused final guard runtime contract의 representative row다. `dark_throne_of_ash`는 2026-04-09 follow-up 기준 `dark_throne_activation`, `dark_throne_overlay` checked-in dedicated ritual family와 dual-school finisher contract의 representative row고, `lightning_conductive_surge`는 같은 날짜 follow-up 기준 `conductive_surge_activation`, `conductive_surge_overlay` checked-in dedicated lightning buff family와 offense/overclock contract의 representative row며, `plant_verdant_overflow`는 같은 날짜 follow-up 기준 `verdant_overflow_activation`, `verdant_overflow_overlay` checked-in dedicated verdant buff family와 deploy amplification/Funeral Bloom contract의 representative row다. `dark_grave_pact`는 같은 날짜 follow-up 기준 `grave_pact_activation`, `grave_pact_overlay` checked-in dedicated dark pact family와 dark-only finisher/leech/drain contract의 representative row고, `wind_tempest_drive`는 별도 active cast hook `player.on_active_skill_cast_started(skill_id, runtime)`에서 `tempest_drive_activation` startup과 central `dash_speed` / `dash_duration` runtime contract를 함께 사용한다.
  - toggle field visual source of truth는 `scripts/player/player.gd`의 `TOGGLE_VISUAL_SPECS` / `TOGGLE_VISUAL_FAMILIES`다. 현재 `ice_glacial_dominion`, `earth_fortress`, `lightning_tempest_crown`, `wind_storm_zone`, `holy_seraph_chorus`, `dark_grave_echo`, `dark_soul_dominion`, `wind_sky_dominion`이 각각 전용 activation/loop/end family를 사용하며, `ice_glacial_dominion`, `earth_fortress`, `lightning_tempest_crown`, `wind_storm_zone`, `holy_seraph_chorus`, `wind_sky_dominion`, `dark_grave_echo`, `dark_soul_dominion`은 2026-04-09 follow-up으로 checked-in dedicated family를 verified runtime source로 승격했다.
  - representative regression은 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_spell_manager.gd`의 split effect registry/cropped tile 검증, `water_aqua_bullet` WaterBall projectile loop, `water_wave` line-control slow projectile, `water_tsunami` dedicated tidal family + vortex terminal + damage/range/pierce scaling projectile, `water_ocean_collapse` dedicated ocean-collapse family + heavier vortex terminal + damage/range/pierce scaling projectile, `lightning_bolt` chain-control shock projectile, `lightning_thunder_lance -> volt_spear` canonical proxy contract + fast narrow lance payload + milestone pierce regression, `holy_healing_pulse -> holy_radiant_burst` canonical proxy contract + self-heal payload/read + level scaling regression, `holy_bless_field` dedicated blessing family + heal/stability support field contract + owner-leave expiry regression, `holy_sanctuary_of_reversal` dedicated sanctuary family + reversal survival contract + incoming-damage reduction + owner-leave guard expiry regression, `earth_fortress` dedicated fortress family + zero-damage defense multiplier/poise/status-resistance guard contract + toggle-off guard expiry regression, `fire_flame_storm` dedicated flame-storm field family + `0.6s` cadence + damage/duration/size/target scaling + burn 유지/deploy payload 검증, `fire_hellfire_field` dedicated hellfire field family + `0.5s` cadence + damage/duration/size/target scaling + burn 유지/large deploy payload 검증, `ice_storm` dedicated frost-storm field family + `0.6s` cadence + damage/duration/size/target scaling + slow/freeze 유지/deploy payload 검증, `plant_world_root` dedicated world-root field family + `0.5s` cadence + damage/duration/size/target scaling + root 유지/deploy payload 검증, `plant_worldroot_bastion` dedicated bastion field family + `0.6s` cadence + damage/duration/size/target scaling + root 유지 + world-root/genesis-arbor 사이 hierarchy 검증, `plant_genesis_arbor` dedicated genesis field family + `0.4s` cadence + damage/duration/size/target scaling + root 유지 + bastion보다 더 큰 final-canopy hierarchy 검증, `dark_shadow_bind` dedicated curse-field family + `0.75s` cadence + damage/duration/size/target scaling + slow 유지/deploy payload 검증, `ice_glacial_dominion` dedicated frozen-domain toggle family + `0.5s` cadence + damage/size/target scaling + slow 유지/simultaneous-toggle 검증, `lightning_tempest_crown` dedicated chain-lightning toggle family + `0.4s` cadence + damage/size/target/pierce scaling + payload contract 검증, `wind_storm_zone` dedicated toggle family + slow/inward-draft control contract + core enemy archetype regression, `holy_seraph_chorus` dedicated chorus family + damage/self-heal/poise mixed aura contract + same-pulse owner-heal/enemy-damage regression + toggle-off support expiry regression, `wind_sky_dominion` dedicated sky-dominion family + zero-damage aerial utility contract + move-speed/jump/low-gravity/extra-jump expiry regression, `ice_absolute_freeze` dedicated freeze family + freeze phase signature + damage/range/target scaling contract, `ice_absolute_zero` dedicated final-freeze family + zero phase signature + damage/range/target scaling + frost-collapse terminal contract, `fire_inferno_buster` dedicated inferno family + inferno phase signature + damage/range/target scaling + burn contract, `fire_meteor_strike` dedicated meteor family + delayed burst phase signature + damage/range/target scaling + ember terminal contract, `fire_apocalypse_flame` dedicated apocalypse family + apocalypse phase signature + damage/range/target scaling + ember-collapse terminal contract, `fire_solar_cataclysm` dedicated solar family + solar phase signature + damage/range/target scaling + strongest burn terminal contract, `earth_gaia_break` dedicated collapse family + damage/range/target scaling + dust terminal contract, `earth_continental_crush` dedicated collapse family + dedicated `phase_signature = earth_continental_crush` + damage/range/target scaling + heavier terminal dust contract, `earth_world_end_break` dedicated collapse family + world-end phase signature + damage/range/target scaling + heaviest terminal dust contract, `wind_storm` dedicated storm family + storm phase signature + damage/range/target scaling + slow contract, `wind_heavenly_storm` dedicated heavenly family + heavenly phase signature + damage/range/target scaling + stronger slow contract, `wind_gale_cutter` cutter loop + 좌우 반전, `earth_stone_spire` central deploy runtime contract + level scaling + grounded cone-burst regression, `earth_quake_break -> earth_tremor` canonical proxy contract + cast-origin centered startup crack visual + dedicated quake phase signature + level scaling regression, `ice_ice_wall` dedicated wall phase signature + startup/hit/terminal contract + contact slow/root control, `plant_root_bind -> plant_vine_snare` dedicated vine-bind family + repeated root contract + dedicated telegraph phase signature + level scaling regression, `fire_flame_arc` animated burst visual, `fire_inferno_sigil` deploy startup/hit/terminal contract + `0.4s` cadence + `0.2s` 중간 gap practical validation + boss 1체/잡몹 혼합 pressure sandbox 회귀, `holy_cure_ray` self-heal + ray contract, `holy_judgment_halo` dedicated holy verdict phase signature + stationary final burst + level scaling/terminal contract, `water_tidal_ring` central active runtime contract + level scaling + push-control regression, `wind_cyclone_prison` central deploy runtime contract + level scaling + pull/terminal runtime, `ice_frost_needle` slow projectile contract, `dark_grave_echo` dedicated dark toggle family + `0.6s` curse cadence + damage/size/target scaling + overlay priority/simultaneous-toggle 검증, `dark_soul_dominion` dedicated final-risk 5-stage toggle family + `0.4s` finisher cadence + damage/duration/size/target scaling + aftershock/clear/overlay-priority 검증, `holy_mana_veil` holy guard activation/overlay + central buff runtime contract + poise/guard scaling 검증, `holy_crystal_aegis` holy guard activation/overlay + central buff runtime contract + guard/super-armor scaling 검증, `holy_dawn_oath` dedicated final-guard activation/overlay + central buff runtime contract + damage-reduction/super-armor/resistance scaling 검증, `dark_throne_of_ash` dedicated ritual activation/overlay + activation mana drain + fire/dark final multiplier scaling + solo ash residue regression, `lightning_conductive_surge` dedicated lightning activation/overlay + lightning finisher scaling + extra ping + holy guard 아래 overlay priority + `Overclock Circuit` live consumer payload/cooldown 검증, `plant_verdant_overflow` dedicated verdant activation/overlay + deploy range/duration scaling + Funeral Bloom 연계 + lightning/holy 아래 overlay priority 검증, `dark_grave_pact` dedicated dark pact activation/overlay + dark finisher scaling + kill leech/hp drain risk contract + lightning above / holy below overlay priority 검증, `wind_tempest_drive` active startup visual + central dash runtime contract + level scaling + `Overclock Circuit` live consumer payload/cooldown 검증이다.
  - `ice_ice_wall`은 더 이상 generic runtime이나 temporary recolor attach로 남겨 두지 않는다. 현재 attach 기준은 checked-in wall family, `phase_signature = ice_ice_wall`, deploy payload의 `slow + short root`, level 1 대비 level 30 duration/size scaling regression까지 함께 잠긴 verified representative wall contract다.

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
- admin / main UI copy regression source of truth는 현재 `scripts/admin/admin_menu.gd`, `scripts/autoload/game_state.gd`, `scripts/main/main.gd`가 실제로 반환하는 한국어 런타임 문자열이다.
  - `tests/test_admin_menu.gd`, `tests/test_main_integration.gd`는 stale 영어 literal을 canonical contract로 취급하지 않는다.
  - 긴 body text는 현재 runtime summary/helper가 조립한 한국어 section label과 핵심 문구 fragment 기준으로 잠그고, 장비/버프/소환 이름은 `display_name` 기반 기대값을 우선한다.
- prototype room의 `Payoff Density / Surface Mix / Weakest Link` source of truth는 `GameDatabase.get_room_reactive_surface_summary()`와 `GameState.get_room_weakest_link_summary()`다. `scripts/admin/admin_menu.gd`는 더 이상 raw `rooms.json`을 다시 해석해 같은 요약을 로컬 계산하지 않는다.
- prototype progression의 `Progression Chain / Phase Summary / Lore Handoff` source of truth는 `GameState.get_progression_chain_summary()`, `GameState.get_progression_phase_summary()`, `GameState.get_lore_handoff_summary()`다. 이 세 요약도 현재 잠긴 progression flag와 환경 서사 문구만 재조합하며, 직접 조우/컷신처럼 사용자 결정이 필요한 영역은 계속 포함하지 않는다.
- prototype preview의 `Final Warning Preview / Phase Cross-Check / Reactive Residue` source of truth는 `GameState.get_final_warning_preview_summary()`, `GameState.get_phase_cross_check_summary()`, `GameState.get_room_reactive_residue_summary(room_id)`다. `admin_menu.gd`와 `main.gd`는 더 이상 같은 phase-aware 경고 문구나 reactive stage 선택 로직을 각각 로컬 계산하지 않는다.
- `royal_inner_hall`과 `throne_approach`는 현재 각각 `echo 3` 구조의 dense payoff room으로 잠겼다. 두 방 모두 progression flag를 새로 늘리지 않고, 이미 잠긴 support-magic distortion / decree / covenant 해석을 secondary echo surface로 되돌려준다.
- `royal_inner_hall`의 room-side silhouette는 현재 `portrait row + archive cabinet + ward tether`, `throne_approach`의 room-side silhouette는 `throne dais + decree pillar + procession rune` 묶음으로 잠겼다. 이 보강도 room builder landmark layer에서만 처리하고, 직접 조우/컷신 판단은 여전히 포함하지 않는다.
- representative room object placement도 현재 `key interaction lane와 combat spawn lane를 겹치지 않게 유지`하는 기준으로 잠겼다. 특히 7층 queue-line echo, 8층 memory plinth, 9층 decree stand / companion trace는 같은 좌표 또는 같은 상단 lane enemy spawn과 직접 겹치지 않아야 한다.
- 같은 placement 기준으로 8층 portrait echo와 9층 center corridor echo도 ranged spawn과 같은 접근 lane을 직접 공유하지 않는다. 현재 representative room 전투 진입선은 `읽는 자리`와 `맞붙는 자리`를 한 번 분리한 상태를 baseline으로 유지한다.
- representative floor-segment rhythm도 현재 잠겼다. 4층은 top debris platform을 더 높고 넓게 둔 false-ascent silhouette, 7층은 upper checkpoint floor를 더 높고 넓게 둔 inspection lane, 9층은 오른쪽으로 갈수록 엄격히 높아지는 procession stair cadence, 10층은 넓어진 central boss floor와 양측 perch를 유지한다.
- `scripts/world/room_builder.gd`는 계속 `data/rooms.json`의 `floor_segments`를 직접 읽어 `StaticBody2D + CollisionShape2D`를 만든다. 이때 `size.y <= ROOM_FLOOR_THRESHOLD`인 얇은 세그먼트는 이제 decor뿐 아니라 충돌도 one-way platform profile로 분기된다.
- `scripts/world/room_builder.gd` runtime path는 `floor_segment_format` metadata를 전혀 읽지 않는다. floor collision branch는 `floor_segments` canonical shape와 per-segment override(`decor_kind`, `collision_mode`)만 source of truth로 사용한다.
- `floor_segments` canonical authoring format은 이제 dictionary `{position: [x, y], size: [width, height]}`다. `decor_kind`, `collision_mode` override는 필요할 때만 적는 additive field이며, `scripts/world/room_builder.gd` runtime build path는 이제 canonical dictionary만 읽는다.
- `decor_kind` override는 세그먼트 두께와 무관하게 visual branch를 잠근다. 현재 허용 값은 `ground`, `platform`이며, 생략 시 thin 여부로 자동 판단한다.
- `collision_mode` override는 세그먼트 두께와 무관하게 충돌 branch를 잠근다. 현재 허용 값은 `solid`, `one_way_platform`이며, 생략 시 thin 여부로 자동 판단한다.
- `scripts/autoload/game_database.gd`는 현재 room load 시 `floor_segments` authoring contract도 함께 검증한다. checked-in room과 generated prototype room은 `room_floor_segment_validation_errors` report 기준으로 현재 0-error 상태를 유지해야 한다.
- floor segment validator는 canonical dictionary authoring만 허용한다. non-dictionary entry, malformed `position/size`, legacy `x/y/width/height` fallback, non-positive size, invalid `decor_kind`, invalid `collision_mode`, retired `floor_segment_format` metadata 키 사용은 모두 authoring error다.
- legacy raw entry 회귀를 빠르게 식별하기 위해 runtime/validator 메시지 모두 `legacy floor segment array`, `legacy floor segment dictionary` 토큰을 공통으로 유지한다.
- 같은 canonical lock follow-up으로 `GameDatabase` validator helper의 내부 parse 경로도 `position/size` array-only로 단순화됐다. `x/y/width/height`를 읽는 fallback parse 분기는 source에 남아 있지 않다.
- floor-segment rhythm 회귀에 쓰는 `tests/test_game_state.gd` helper도 canonical `position/size` array만 해석한다. legacy array 또는 `x/y/width/height` 입력은 이 helper 경로에서 더 이상 좌표로 변환되지 않는다.
- generated prototype room은 이제 모두 canonical dictionary floor-segment emit을 사용한다. `floor_segment_format` metadata는 live data에서 더 이상 필수가 아니다.
- checked-in `rooms.json`은 이제 전 room이 room 단위 canonical migration을 마쳤다. 현재 canonical checked-in room은 `entrance`, `conduit`, `deep_gate`, `vault_sector`, `seal_sanctum`, `gate_threshold`, `royal_inner_hall`, `throne_approach`, `inverted_spire`, `arcane_core`, `void_rift` 열한 곳 전체다.
- 즉 current contract는 `generated rooms canonical dict + all checked-in rooms canonical dict + runtime/validation canonical-only`다. checked-in data 기준 전면 canonical migration은 끝났고, legacy shape 해석은 더 이상 runtime이나 room validation contract에 남아 있지 않다.
- canonical migration tooling도 canonical-only로 잠겼다. `scripts/tools/floor_segment_canonicalizer.gd`는 이제 자체 parse helper를 두지 않고 `GameDatabase.normalize_floor_segment_to_canonical_dictionary()` 단일 helper에 위임한다. 결과적으로 canonical dictionary 입력만 정규화하고, legacy array / `x/y/width/height` shape는 공통 helper에서 거부한다.
- offline canonicalizer 실행 계약 검증 seam도 잠겼다. static helper `build_floor_segment_normalization_result(room_id, floor_segments)`는 `{ok, segments, error}` payload를 반환하고, mixed 입력에서는 첫 invalid segment index를 포함한 에러 문구를 돌려준다.
- offline canonicalizer CLI selection 계약도 static seam으로 잠겼다. `build_requested_room_match_result(requested_room_ids, rooms)`는 `인자 없음 -> usage error`, `미매치 -> no-match error`, `성공 -> catalog order 기준 matched index`를 `{ok, matched_indices, error}` payload로 반환한다.
- offline canonicalizer는 이제 room rewrite 때 `floor_segment_format` metadata를 다시 쓰지 않는다. canonical room payload는 `floor_segments` shape만 source of truth로 유지한다.
- `floor_segment_format`는 현재 retired/forbidden metadata다. live generated room과 checked-in room은 이 필드를 기록하지 않는 canonical contract를 사용하며, 값이 무엇이든 key가 들어오면 validator가 authoring error로 거부한다.
- 얇은 `floor_segments`의 충돌은 full rectangle이 아니라 상단 strip one-way collision으로 생성된다. 현재 baseline은 아래/옆 통과, 점프 상승 중 관통, 위에서 낙하할 때만 착지하는 MapleStory식 공중 발판 감각을 목표로 한다.
- `scripts/player/player.gd`는 현재 밟고 있는 `one_way_platform` body를 slide collision 기준으로 추적하고, `move_down + jump` 입력 시 해당 body에 짧은 collision exception window를 걸어 platform 아래로 내려간다.
- 현재 드롭다운 helper는 `PLATFORM_DROP_THROUGH_TIME` 동안 현재 platform만 무시하는 최소 구현이다. 일반 ground segment와 좌우 boundary wall은 이 경로의 영향을 받지 않는다.
- 같은 helper 경로의 시작 gate는 현재 `dead/hit-stun/OnRope/active-window` 상태를 차단하고, 대상 platform이 런타임에서 해제되면 stale exception state를 다음 tick에 자동 정리한다.
- 일반 지면 세그먼트와 좌우 boundary wall은 계속 full solid collision을 유지한다. 즉 thin platform과 solid ground/wall의 충돌 규칙 source of truth는 이제 room builder collision profile helper다.
- 현재 build fact는 one-way landing뿐 아니라 `아래 + 점프` 드롭다운 입력까지 지원한다. `floor_segments`의 checked-in data migration, runtime legacy cleanup, offline canonicalizer/helper legacy cleanup까지 끝났다. drop-through helper는 여전히 현재 요구만 닫는 최소 범위다.
- prototype flow scale도 현재 잠겼다. active prototype room은 `4층 13개 / 5층 11개 / 6층 9개 / 7층 7개 / 8층 5개 / 9층 3개 / 10층 1개`, 총 49개다. story anchor width는 계속 `entrance 2400`, `seal_sanctum 3000`, `gate_threshold 3120`, `royal_inner_hall 3240`, `throne_approach 3360`, `inverted_spire 3480` 기준을 유지하고, generated route room도 모두 이와 같은 labyrinth-scale traversal span 계열로 유지한다.
- prototype flow detour contract도 현재 잠겼다. story anchor 6개와 generated route room 전체는 모두 본선에서 잠깐 벗어났다가 다시 합류하는 `side pocket / loop-back segment`를 최소 1개 이상 유지한다. anchor 기준으로는 4층 upper debris pocket, 6층 refuge pocket, 7층 holding pocket, 8층 living pocket, 9층 waiting pocket, 10층 upper flank pocket을 current lock으로 본다.
- 같은 detour contract 기준으로 각 pocket은 최소 1개의 읽을 가치가 있는 reactive echo를 가진다. 즉 pocket은 단순 점프 발판이 아니라 `잠깐 우회해서 환경 정보를 회수하는 짧은 방갈래`로 유지한다.
- dungeon/labyrinth 구조 참고 기준도 현재 잠겼다. 대표 방은 공통적으로 `wider traversal span + branch-and-rejoin + landmark-guided lane + short detour pocket + safe or pressure cadence + final compression` 원칙을 따르고, 각 방의 floor segments와 object/spawn 배치는 이 구조를 먼저 읽히게 유지한다.
- `entrance`와 `gate_threshold`도 현재 각각 `echo 3` 구조의 dense payoff room으로 잠겼다. 두 방 모두 새 progression flag 없이 이미 잠긴 역전 규칙 / inspection-selection 해석을 secondary echo surface로 되돌려준다.
- `seal_sanctum`은 현재 `board 1 + echo 3`, `inverted_spire`는 `echo 3 + gate 1` 구조의 dense payoff room으로 잠겼다. 두 방 모두 새 progression flag 없이 이미 잠긴 refuge refusal / covenant conversion 해석을 secondary echo surface로 되돌려준다.
- representative room silhouette도 현재 4층 `watchtower + signal mast`, 6층 `seal statue + ward boundary`, 7층 `gate arch + judgement beam`, 10층 `inverted spire + royal canopy remnant` 묶음이 먼저 읽히는 방향으로 잠겼다. 이 보강은 모두 room builder landmark layer에서만 처리하고, 충돌/동선 계약은 그대로 유지한다.
- prototype preview의 `Interaction Preview / Reactive Preview` source of truth는 `GameState.get_room_interaction_preview_summary(room_id)`와 `GameState.get_room_reactive_preview_summary(room_id)`다. 관리자 메뉴는 더 이상 room object type 해석과 preview line 조합을 로컬에서 중복 계산하지 않는다.
- prototype room metadata의 `Proto Title / Proto Summary / Prototype Flow` source of truth는 `GameState.get_prototype_room_overview_summary(room_id)`와 `GameState.get_prototype_flow_preview_summary(selected_room_id)`다. 관리자 메뉴는 더 이상 선택 방 제목/요약과 flow caption을 raw room data에서 직접 조립하지 않는다.
- 현재 representative `Proto Summary` authored text는 각 방의 실루엣/interaction 문맥까지 포함한다. 4층은 `outer wall breach + signal mast`, 6층은 `seal refuge + ward boundary`, 7층은 `judgment threshold + queue line + inspection beam`, 8층은 `royal living hall + archive traces + support wards`, 9층은 `throne line + decree stand + judgment ascent`, 10층은 `inverted spire + covenant dais + overturned royal chamber` 묶음을 한 줄에서 바로 읽히게 유지한다.
- prototype room selector의 `Proto Target / short label / jump label` source of truth는 `GameState.get_prototype_room_catalog()`다. 관리자 메뉴는 더 이상 prototype room id 배열과 floor short-label map을 로컬 상수로 유지하지 않고, 현재는 같은 catalog를 `paged room window`로만 렌더링한다.
- prototype room order source of truth는 `GameState.get_prototype_room_order()`다. `main.gd`는 더 이상 prototype flow 순서를 로컬 상수로 유지하지 않고, 관리자 selector와 같은 catalog 기반 order를 읽는다.
- prototype room의 `Verification Status / Next Priority / Action Candidate` source of truth는 `GameState.get_room_verification_status_summary()`, `GameState.get_room_next_priority_summary()`, `GameState.get_room_action_candidate_summary()`다. 이 세 요약은 이미 잠긴 환경 단서와 progression flag만 사용하고, 직접 조우/컷신/보스 페이즈 연출처럼 사용자 결정이 필요한 범위는 계속 제외한다.
- prototype room의 `Room Note / Path Note / Clue Check` source of truth는 `GameState.get_room_note_summary()`, `GameState.get_room_path_note_summary()`, `GameState.get_room_clue_check_summary()`다. 이들도 대표 방 환경 단서와 현재 progression 상태만 요약하고, 직접 조우나 컷신처럼 미잠금 영역은 포함하지 않는다.
- `skills.json / spells.json` validation source of truth는 `GameDatabase`의 validation helper 묶음이다.
- runtime school source of truth는 `GameState.resolve_runtime_school()`다.
- buff runtime seed source of truth는 `GameState.get_registered_buff_skill_ids()`다. 현재 buff cooldown 초기화와 buff cooldown summary는 더 이상 고정 배열을 직접 들지 않고 `skills.json`의 `skill_type = buff` row를 읽는다.
- default hotbar seed source of truth는 `GameState.get_default_spell_hotbar_template()`다. reset/init/restore 경로는 더 이상 기본 13슬롯 배열을 직접 복제하지 않고 이 helper를 읽는다.
- default visible shortcut key map source of truth는 `GameState.get_default_visible_hotbar_keycode_map()`이다. 기본 `Z/C/V/U/I/P/O/K/L/M` profile을 참조하는 경로는 이 helper를 통해 같은 기준을 읽는다.
- `SpellResource` 클래스 전제는 현재 코드 기준이 아니다.
- 플레이어/적 상태 차트는 런타임에 조립한다.
- `player_state_chart.tres` 같은 상태 차트 리소스는 현재 필수 파일이 아니다.
- 씬 조립의 기준점은 [`scenes/main/Main.tscn`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scenes/main/Main.tscn) 이다.
- 플레이어는 현재 `Main.tscn` 내부에서 조립되며 `scenes/player/Player.tscn` 전제는 사용하지 않는다.
- 런타임 에셋 참조는 반드시 `res://assets/...` 만 사용한다.
- `asset_sample/` 는 원본 드롭존이자 분석 소스이며, 코드/씬의 직접 참조 대상이 아니다.
- `GameState` 는 기존 public API 를 유지하면서 내부적으로 `CombatRuntimeState` 와 `ProgressionSaveState` 로 역할을 나누기 시작했다.
- prototype map runtime은 현재 `4층 13개 -> 5층 11개 -> 6층 9개 -> 7층 7개 -> 8층 5개 -> 9층 3개 -> 10층 1개`의 49-room floor flow를 실제 사용한다.
  - floor anchor placement는 `entrance(4층-01)`, `seal_sanctum(6층-01)`, `gate_threshold(7층-07)`, `royal_inner_hall(8층-01)`, `throne_approach(9층-03)`, `inverted_spire(10층-01)` 기준으로 잠겼다.
  - room generation source of truth는 `scripts/autoload/game_database.gd`의 `GameDatabase._expand_prototype_rooms()`와 그 helper들이다. `data/rooms.json`은 story anchor와 legacy room의 base data 입력이며, 49-room flow 전체를 직접 나열하는 단독 truth가 아니다.
  - catalog/order source of truth는 `scripts/autoload/game_state.gd`의 `GameState.get_prototype_room_catalog()`와 `GameState.get_prototype_room_order()`다.
  - runtime shift/load source of truth는 `scripts/main/main.gd`다.
  - admin selector consumer source of truth는 `scripts/admin/admin_menu.gd`다. selector는 room data를 다시 계산하지 않고 `GameState` catalog/order를 paged window로만 소비한다.
  - 5층 generated floor theme source of truth는 `scripts/autoload/game_database.gd`가 주입하는 `transition_corridor`이며, bent checkpoint / repeated arch / false-ascent stair / loop-back pocket motif를 유지한다.
  - generated route room은 floor identity, traversal pressure, detour pocket, branch-and-rejoin cadence를 담당하고 story anchor progression flag를 새로 늘리지 않는다.
  - 4층 `entrance`의 wall-crest echo도 `inverted_spire_covenant` 이후 반복 문장이 한 단계 더 바뀌며, 외곽 구조물 자체가 처음부터 왕국을 아래로 가르치던 표식이었다는 final-stage 해석을 되돌려준다.
  - 7층 `gate_threshold`의 arch echo도 `inverted_spire_covenant` 이후 반복 문장이 한 단계 더 바뀌며, gate가 최종 계약의 첫 약속과 선택 구조를 미리 수행한 공간이라는 final-stage 해석을 되돌려준다.
  - 8층 `royal_inner_hall`의 portrait-frame echo도 `inverted_spire_covenant` 이후 반복 문장이 한 단계 더 바뀌며, 왕실 삭제가 최종 계약 준비의 일부였다는 final-stage 해석을 되돌려준다.
  - 9층 `throne_approach`의 중심 복도 echo도 `inverted_spire_covenant` 이후 반복 문장이 한 단계 더 바뀌며, 왕좌 복도가 계약을 법처럼 통과시키기 위한 rehearsal space였다는 final-stage 해석을 되돌려준다.
  - 최종 방 `inverted_spire`는 `covenant_altar`, multiple echo payoff surface, phase-aware gate warning line을 함께 유지한다.
  - 계약 문양/왕실 잔해 계열 echo는 `inverted_spire_covenant` 이후 반복 문장이 바뀌며, 최종 진실이 방 전체 해석을 다시 쓰는 payoff를 제공한다.
  - 허브 `seal_sanctum`의 crest echo도 `inverted_spire_covenant` 이후 반복 문장이 한 단계 더 바뀌며, refuge가 왕의 마지막 정의를 거부한 공간이라는 final-stage 해석을 되돌려준다.
  - story anchor 6개(`entrance`, `seal_sanctum`, `gate_threshold`, `royal_inner_hall`, `throne_approach`, `inverted_spire`)는 모두 `inverted_spire_covenant` 기반 repeat payoff surface를 최소 1개 이상 유지해야 한다.
  - 이 구조 불변식의 source of truth regression은 `tests/test_game_state.gd`의 representative-room final-payoff coverage test다.
  - room-side reactive payoff read-only summary source of truth는 `GameDatabase.get_room_reactive_surface_summary()`와 `get_room_reactive_surface_summaries()`다.
  - 이 summary는 `board_count`, `echo_count`, `gate_count`, `total_reactive_surfaces`, `payoff_density`, `final_payoff_surface_count`를 노출한다.
  - prototype room weakest-link read-only summary source of truth는 `GameState.get_room_weakest_link_summary()`와 `get_room_weakest_link_summaries()`다.
  - 이 summary는 `message`, `is_locked`, `next_focus`, `blocking_flags`를 노출하고, 현재 `Weakest Link` 문구 해석의 owner_core 기준선을 잠근다.
  - equipment summary/inventory summary copy source of truth는 `GameState.get_equipment_summary()`, `get_equipment_inventory_summary()`, `get_equipment_slot_inventory_summary()`다. regression은 stale English item name이나 preset id가 아니라 equipment `display_name`과 `GameState.get_equipment_preset_label()`을 기준으로 맞춘다.
  - echo default repeat copy source of truth는 `scripts/world/echo_marker.gd`의 `repeat_text` 기본값이고, final warning line source of truth는 `GameState.get_final_warning_preview_summary()`다. room-side reactive residue payoff 문구는 checked-in room object의 `repeat_stage_messages`가 그대로 반환되므로, regression은 legacy English full-string보다 현재 한국어 핵심 문구를 우선 검증한다.
  - representative regression은 `tests/test_player_controller.gd`의 final-room echo repeat tests와 `tests/test_main_integration.gd`의 covenant warning flow tests다.
- 전투 HUD 연동용 hotbar API는 현재 `13슬롯 저장 + 10슬롯 가시 layer`의 이중 구조를 가진다.
  - 런타임 내부 배열과 호환 save 기준선은 아직 `GameState.spell_hotbar` 전체 13슬롯이다.
  - save payload의 canonical field는 `spell_hotbar` 첫 10슬롯이고, 나머지 3슬롯은 `legacy_spell_hotbar_tail` 호환 필드로 분리된다.
  - visible shortcut canonical field는 `visible_hotbar_shortcuts`이고, old save에 이 필드가 없으면 첫 10슬롯의 legacy `action + label`에서 shortcut profile을 복원한다.
  - GUI 소비자는 `GameState.get_visible_spell_hotbar()` 또는 `player.get_visible_hotbar_bindings()`로 첫 10슬롯만 읽는다.
  - GUI tooltip / unbind / drag-swap / shortcut rebind는 `get_hotbar_slot()`, `get_hotbar_slot_tooltip_data()`, `clear_hotbar_skill()/clear_hotbar_slot()`, `swap_hotbar_skills()/swap_hotbar_slots()`, `get_visible_hotbar_shortcuts()`, `set_visible_hotbar_shortcut()`, `reset_visible_hotbar_shortcuts_to_default()` 경로를 사용한다.
  - 2026-04-07 owner_core follow-up으로 `GameState.get_hotbar_preset_ids()`, `get_hotbar_preset_catalog()`, `get_next_hotbar_preset_id()`, `resolve_current_hotbar_preset_id()`, `get_hotbar_preset_state()`, `get_hotbar_preset_label()`, `get_hotbar_preset_data()`, `apply_hotbar_preset()`, `apply_next_hotbar_preset()`도 추가됐다. owner_core 쪽 hotbar preset seed는 이제 이 API로 읽을 수 있고, preset row는 모두 runtime-castable ID로 정규화된다.
  - 같은 날짜 다음 follow-up으로 `GameState.get_equipment_preset_ids()`, `get_equipment_preset_catalog()`, `get_admin_equipment_preset_ids()`, `get_admin_equipment_preset_catalog()`, `get_next_admin_equipment_preset_id()`, `resolve_current_admin_equipment_preset_id()`, `get_admin_equipment_preset_state()`, `get_equipment_preset_label()`, `get_equipment_preset_data()`, `apply_next_admin_equipment_preset()`도 추가됐다. 장비 preset source of truth는 이제 `GameState`에 있고, admin의 현재 `fire_burst / ritual_control / storm_tempo` cycle seed도 별도 API로 노출된다.
  - GUI 소비자는 hotbar/equipment preset row를 자체 상수로 복제하지 않고 위 `GameState` API를 직접 읽는다. 버튼/목록을 만들 때는 가능하면 `*_preset_catalog()` payload를 그대로 소비한다.
  - 2026-04-07 follow-up으로 `scripts/admin/admin_menu.gd`의 hotbar preset 버튼/active state/next-preset cycle도 local `PRESET_*`/`HOTBAR_PRESET_*` 하드코딩이 아니라 `GameState.get_hotbar_preset_ids()`, `get_hotbar_preset_label()`, `get_hotbar_preset_state()`, `apply_hotbar_preset()`, `apply_next_hotbar_preset()` 기준으로 전환됐다.
  - 같은 follow-up으로 admin의 equipment preset cycle도 local `["fire_burst", "ritual_control", "storm_tempo"]` 배열이 아니라 `GameState.get_admin_equipment_preset_state()`와 `apply_next_admin_equipment_preset()`를 기준으로 돈다.
  - 같은 날짜 다음 follow-up으로 `scripts/admin/admin_menu.gd` 장비 탭은 `res://assets/ui/pixel_rpg/Equipment.png` 상단 panel과 `res://assets/ui/pixel_rpg/Inventory.png` 우측 panel을 직접 읽는 visual shell을 갖는다. source-of-truth geometry는 `Inventory` 기준 `5x4` viewport, `origin (10,17)`, `cell fill 14x14`, `pitch 16`이며, overflow는 `스크롤`이 아니라 현재 `Y/H` page navigation을 따르는 page-based 규칙으로 잠겼다.
  - current first shell은 기존 `EQUIPMENT_PAGE_SIZE=5` semantics를 유지하므로 viewport 전체 20칸을 당장 다 채우지 않는다. 지금은 현재 page의 최대 5개 항목만 셀에 매핑하고, 나머지 칸은 향후 icon atlas / multi-cell occupancy / drag-drop 확장을 위한 reserve slot으로 남긴다.
  - keyboard combat primary input 은 `spell_manager.handle_input()` 기준으로 첫 10슬롯 가시 row만 읽는다.
  - `scripts/ui/game_ui.gd`의 현재 전투 HUD 셸은 programmatic GUI 기준으로 아래를 실제 구현했다.
  - 상단 좌측 primary target HP panel
  - 상단 좌측 `방 제목 + 즉시 경고 + 관리자 디버그` readout
  - 화면 중앙 맨아래에 고정된 세로 2열 slim `HP(위) / MP(아래)` bar cluster
  - 하단 좌측 좁은 폭의 `공명 + 버프 + 콤보 + active buff chip row` status panel
  - `Action_panel.png` atlas-backed outer frame / slot shell 과 pseudo-icon 을 쓰는 visible `10슬롯` action row
  - hover tooltip, 좌클릭 cast, 우클릭 clear, 좌클릭 hold 후 release swap
  - unavailable slot dim 처리와 tooltip/current-state 기반 label 갱신
  - runtime local hide toggle `set_show_primary_action_row()` / `set_show_active_buff_row()`
- 플레이어 창 UI runtime 기준선은 현재 아래까지 실제 구현됐다.
  - `scripts/autoload/ui_state.gd`가 `ui_opacity`, `brightness`, `effect_opacity`, `music_volume`, `sfx_volume`, `special_effects`, `screen_shake`, `window_positions`를 `user://ui_settings.cfg` 에 저장한다.
  - `scripts/ui/window_manager.gd`가 `ESC / I / K / E / T / Q` 입력, topmost close, focus/z-order, window opacity, settings pause를 담당한다.
  - `GameState.ensure_input_map()` 기준 player window reserved key는 `ESC / I / K / E / T / Q` 로 잠겼고, 기존 `Q/T` 충돌 buff 기본키는 `Z/X/C/V` 로 옮겼다.
  - `scripts/ui/windows/settings_window.gd`는 `오디오 / 그래픽 / 효과 / HUD` 탭과 기본 설정 control 을 제공한다.
  - `scripts/ui/windows/inventory_window.gd`는 `장비 / 소비 / 기타` 3탭과 `20칸` inventory grid를 제공하고, 장비/소비/기타 탭 모두 실데이터 셀 바인딩, 상세 패널, `정리 / 장착·사용 / 장비창` action row를 가진다.
  - `scripts/autoload/game_database.gd`는 `data/items/consumables.json`, `data/items/other_items.json`을 함께 로드하고 `get_consumable_item()`, `get_other_item()` accessor를 제공한다.
  - `scripts/autoload/game_state.gd`는 `consumable_inventory`, `other_inventory` save field와 `grant_consumable_item()`, `grant_other_item()`, `apply_stackable_inventory_drag_drop()`, `organize_stackable_inventory()`, `use_consumable_inventory_item()` 경로를 제공한다.
  - 같은 follow-up으로 `GameState.get_equipment_inventory_item_at()`, `get_equipment_inventory_occupied_count()`, `find_equipment_inventory_slot_by_item()`, `swap_equipment_inventory_items()`, `move_equipment_inventory_item()`, `organize_equipment_inventory()`가 추가돼 GUI가 `20칸 fixed sparse` 장비 인벤토리 레이아웃을 직접 다룰 수 있다.
  - `scripts/ui/windows/equipment_window.gd`는 paper-doll slot shell, slot별 보유 장비 목록, 장착/해제 button, drag 장착/해제, slot/owned-item hover compare panel, tooltip text, 비교 요약, 더블클릭 장착/해제를 제공한다.
  - `scripts/ui/windows/stat_window.gd`는 현재 HP/MP/마나 재생/서클, 장비 반영 파생 수치, 공명 요약을 제공한다.
  - `scripts/ui/windows/quest_window.gd`는 `진행 가능 / 진행 중 / 완료` 3탭, 검색, 현재 지역 필터, empty state + future hook shell 을 제공한다.
  - `scripts/ui/windows/skill_window.gd`, `scripts/ui/windows/key_bindings_window.gd`, `scripts/ui/widgets/skill_bind_drag_button.gd`, `scripts/ui/widgets/hotkey_drop_button.gd`, `scripts/ui/widgets/skill_hotbar_drop_button.gd`, `scripts/ui/widgets/skill_visual_helper.gd`, `scripts/ui/game_ui.gd` 조합으로 `SkillWindow -> Key Bindings`, `SkillWindow -> HUD quickslot` direct drag-and-drop bind, 학교별 pseudo-icon / drag ghost preview, hover-near tooltip edge flip 이 실제 동작한다.
  - `scripts/main/main.gd`, `scripts/ui/game_ui.gd`, `scripts/player/player.gd`, `scripts/player/spell_projectile.gd` 는 brightness overlay, special effect suppression, screen shake guard, effect opacity multiplier 를 실제로 읽는다.
  - `scripts/autoload/ui_state.gd`, `scripts/ui/windows/settings_window.gd`, `scripts/ui/game_ui.gd` 조합으로 `show_primary_action_row`, `show_active_buff_row` HUD visibility setting 이 persistence와 런타임 적용까지 실제 동작한다.
  - `scripts/autoload/ui_state.gd` 는 `Music / SFX / Effect` audio bus 를 런타임에서 idempotent하게 보장하고, `music_volume / sfx_volume` 변경을 해당 bus volume db 에 즉시 반영한다.
  - `scripts/ui/widgets/ui_window_frame.gd`는 공통 창 프레임에 Maple-like warm hover/pressed close button skin, 창별 accent strip, shared tab/action button style helper 를 제공하고, `inventory_window.gd`, `quest_window.gd`, `settings_window.gd` 가 이를 실제로 사용한다.
  - 같은 shared helper 층에서 `settings_window.gd` 는 slider/checkbox row panel surface, custom slider track/knob, custom checkbox icon skin 도 실제로 사용한다.
  - 같은 shared helper 층에서 `ui_window_frame.gd` 는 gloss/stripe/shadow가 들어간 procedural textured shell style 도 제공하고, `inventory_window.gd`, `equipment_window.gd`, `skill_window.gd`, `key_bindings_window.gd`, `settings_window.gd` row card 가 이를 실제로 사용한다.
  - 같은 날짜 follow-up으로 `ui_window_frame.gd` 의 main shell 은 `assets/ui/pixel_rpg/Settings.png` atlas region 을 직접 읽는 asset-backed shared frame 으로 올라왔고, close button state 는 `assets/ui/pixel_rpg/Buttons.png` atlas 를 직접 사용한다.
  - 같은 follow-up으로 `scripts/admin/admin_menu.gd` 도 `UiWindowFrame` helper 를 재사용해 atlas-backed outer shell, compact tab shell, accent-aware action button skin 을 실제로 사용한다. 장비 atlas crop shell 자체는 기존 `Equipment.png` / `Inventory.png` geometry 계약을 유지한다.
  - 같은 날짜 다음 follow-up으로 `scripts/ui/game_ui.gd` 도 HUD quickslot outer frame 과 slot shell 을 `assets/ui/pixel_rpg/Action_panel.png` atlas region 기반 `StyleBoxTexture` 로 실제 전환했다.
  - 같은 날짜 다음 follow-up으로 `scripts/ui/windows/inventory_window.gd` 는 grid panel 을 shared compact atlas shell 로, inventory slot button 을 `assets/ui/pixel_rpg/Action_panel.png` atlas 기반 `StyleBoxTexture` shell 로 전환했다.
  - 같은 follow-up으로 `scripts/ui/windows/skill_window.gd`, `scripts/ui/windows/key_bindings_window.gd` 도 핵심 panel shell 을 shared compact atlas shell 로 전환했다. 다만 `KeyBindingsWindow` slot state 자체는 hover/selected 구분 border 계약을 유지하기 위해 flat state box를 계속 쓴다.
- 현재 GUI 미완료 범위는 아래처럼 정리한다.
  - target HP panel은 현재 `플레이어와 가장 가까운 살아 있는 적`을 primary target으로 읽는 휴리스틱 단계다. explicit lock-on / keyboard selection target source는 아직 없다.
  - `SkillWindow` 는 Maple-like 3분할 구조, 현재 등록 키 요약, `Key Bindings` / `HUD quickslot` direct drag source 까지 들어갔다. 다만 checked-in icon atlas 기반의 최종 아이콘 skin은 아직 없다.
  - `Key Bindings` 플레이어 창은 실제로 있고, 현재는 fixed 21슬롯 선택 등록/우클릭 해제/skill direct drop bind/허용 키 직접 입력 등록까지 닫혔다.
  - HUD tooltip 은 더 이상 하단 고정 중앙이 아니라 hover 슬롯 근처에 붙고, viewport edge를 넘기면 좌/하 방향으로 자동 flip 된다.
  - `Key Bindings` 는 selected border와 hover border를 별도 색으로 분리해 키보드 선택 대상과 마우스 hover 대상을 동시에 읽을 수 있다.
  - HUD quickslot 은 occupied idle overlay, hover overlay, drag-source overlay를 실제로 구분한다.
  - `InventoryWindow`, `QuestWindow`, `SettingsWindow` 탭은 현재 창별 accent color 를 가진 shared Maple-like tab skin 을 사용한다.
  - `InventoryWindow` action row 는 현재 accent 기반 shared action button skin 을 사용하고, 모든 `UiWindowFrame` 창은 warm close-button hover/pressed skin 을 공유한다.
  - `InventoryWindow` header 는 현재 accent `count pill` 을 사용하고, `SettingsWindow`/`QuestWindow` 를 포함한 공통 창은 상단 accent strip 으로 창 종류를 시각 구분한다.
  - `SettingsWindow` 는 현재 기본 Godot control 외형이 아니라 accent panel card + custom slider/checkbox skin 을 사용한다.
  - `admin_menu` 는 여전히 debug/admin 정보량이 많은 별도 레이아웃을 유지하지만, 바깥 panel과 tab/action button skin 은 이제 player 창과 같은 shared Maple-like visual helper를 사용한다.
  - player 창 UI는 이제 flat placeholder만 쓰는 단계가 아니라 `Settings.png`/`Buttons.png` atlas-backed shared outer frame, `Action_panel.png` atlas-backed HUD quickslot shell, `InventoryWindow` slot shell, `SkillWindow`/`KeyBindingsWindow` compact panel shell 까지 올라왔다. 다만 `tab/button/icon` 전부를 external atlas 기반 final shell 로 바꾸는 pass 는 아직 남아 있다.
  - `소비 / 기타` 인벤토리는 실제 stack inventory/runtime detail/use path까지 연결됐다. 다만 실제 전장 드롭/경제 루프는 아직 장비 위주다.
  - 장비 인벤토리 drag-and-drop 은 `occupied cell swap + explicit empty-slot move + organize 시 좌상단 압축` 범위까지 닫혔다.
  - `EquipmentWindow` 는 drag-and-drop 장착/해제, slot hover equipped-context preview, owned-item hover compare, tooltip text까지 닫혔다.
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
