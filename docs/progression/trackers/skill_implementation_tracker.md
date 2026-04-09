---
title: 스킬 구현 추적표
doc_type: tracker
status: active
section: progression
owner: design
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - runtime_changed
  - status_changed
  - structure_changed
last_updated: 2026-04-09
last_verified: 2026-04-09
---

# 스킬 구현 추적표

상태: 사용 중  
최종 갱신: 2026-04-09  
섹션: 성장 시스템

## 이 문서의 역할

- 이 문서는 `최신 스킬 기획`이 인게임에 얼마나 반영됐는지 추적하는 운영 문서다.
- 스킬별 `구현 여부`, `asset 적용 여부`, `attack effect`, `hit effect`, `레벨 스케일 반영 여부`를 한 곳에서 관리한다.
- 스킬 컨셉과 수치 기준은 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)를 우선한다.
- canonical 마이그레이션 턴은 이 문서와 migration plan, design 문서가 함께 갱신될 때만 닫는다.
- 과거 프로토타입 문서는 이 추적표의 기준 문서가 아니다.

## 소스 오브 트루스 관계

- 최신 기획:
  - 이름, 속성, 서클, 타입, 목표 경험은 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)를 따른다.
- 실제 런타임 사실:
  - 현재 실제로 동작하는 구현과 runtime ID는 코드와 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)를 따른다.
  - 2026-04-03 구조 개선 증분부터 active / deploy / toggle 공통 scaling 해석 기준은 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_common_runtime_stat_block()`과 `get_common_scaled_mana_value()`다.
  - 같은 날짜 구조 개선 후속 증분부터 proxy-active / runtime spell ↔ canonical skill row 해석 기준은 `data/spells.json`의 `source_skill_id`와 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`가 구성하는 중앙 mapping table이다.
  - admin skill library의 배치 가능 목록도 같은 날짜 구조 개선 후속 증분부터 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`의 `get_runtime_castable_skill_catalog()`를 source of truth로 읽는다.
  - 같은 날짜 다음 구조 개선 증분부터 `skills.json / spells.json` 최소 validation 기준도 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`의 `validate_skill_entry()`, `validate_spell_entry()`, `validate_skill_spell_link()`, `validate_spell_skill_link()`로 고정한다.
  - 같은 날짜 다음 구조 개선 증분부터 mastery XP progression, school-specific mastery modifier, runtime tooltip/runtime summary school 표기는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `resolve_runtime_school()`를 공통 기준으로 본다.
  - 같은 날짜 다음 hardening 증분부터 active / deploy / toggle runtime scaling option 기본값도 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_active_spell_runtime_options()`와 `build_data_driven_skill_runtime_options()`를 공통 기준으로 본다.
  - 같은 날짜 다음 hardening 증분부터 data-driven deploy / toggle base runtime block도 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_data_driven_skill_base_runtime()`를 공통 기준으로 본다.
  - 같은 날짜 다음 hardening 후속 증분부터 data-driven deploy / toggle final runtime 조립과 sustain mana drain도 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `get_data_driven_skill_runtime()`와 `get_data_driven_skill_mana_drain_per_tick()`를 공통 기준으로 본다.
  - 같은 날짜 다음 hardening 증분부터 deploy / toggle cast payload seed도 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_data_driven_combat_payload()`를 공통 기준으로 본다.
  - 같은 날짜 다음 hardening 증분부터 representative runtime payload contract 검증 기준은 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_spell_manager.gd`와 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd`다. 새 스킬/새 구조 변경은 payload contract test를 같은 턴에 추가하는 것을 기본 운영 규칙으로 본다.
- 이 문서의 역할:
  - 이 문서는 `상태 보고 문서`다.
  - 구현 / asset / attack effect / hit effect / 레벨 스케일 상태만 추적한다.
  - 이 문서는 최신 기획이나 런타임 사실을 새로 정의하지 않는다.
- 충돌 처리:
  - tracker와 코드가 다르면 코드를 먼저 맞춘다.
  - tracker와 최신 기획이 다르면 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)를 먼저 맞춘다.
  - 충돌 상세 규칙은 [README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md)의 `우선순위 규칙`을 따른다.

## 상태 enum

### 구현 상태

| 값 | 의미 |
| --- | --- |
| `planned` | 아직 인게임 구현 없음 |
| `prototype` | 인게임에 유사/프록시 구현은 있으나 최신 기획과 완전히 일치하지 않음 |
| `runtime` | 최신 기획과 큰 방향이 맞는 플레이 가능한 구현이 있음 |
| `verified` | 전용 연출 + 구현 + 테스트 + 문서 동기화까지 완료 |

### asset 상태

| 값 | 의미 |
| --- | --- |
| `not_started` | 전용 시각 자산 연결 없음 |
| `placeholder` | 임시/프록시 자산 사용 중 |
| `applied` | 전용 자산이 연결됨 |
| `verified` | 자산 연결 + 검증 완료 |
| `n/a` | 해당 스킬은 이 항목이 의미 없음 |

### attack / hit effect 상태

| 값 | 의미 |
| --- | --- |
| `n/a` | 해당 스킬에 분리 effect 개념이 없음 |
| `not_started` | 분리 effect 미구현 |
| `placeholder` | 임시 effect 또는 통합 effect 사용 |
| `applied` | 분리 effect 연결 완료 |
| `verified` | effect 연결 + 가독성 검증 완료 |

### 레벨 스케일 상태

| 값 | 의미 |
| --- | --- |
| `design_only` | 문서에만 정의됨 |
| `runtime_generic` | 공용 레벨 스케일 공식을 사용 중 |
| `runtime_specific` | 스킬 전용 성장 규칙이 런타임에 반영됨 |
| `verified` | 성장 규칙과 실제 결과가 검증됨 |

## 업데이트 규칙

- 최신 기획 이름과 속성은 항상 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)에 맞춘다.
- 각 row는 반드시 `canonical skill_id`를 가진다.
- `canonical skill_id`는 최신 기획 기준의 안정적인 식별자다.
- 현재 runtime ID가 다르더라도 `canonical skill_id`는 유지하고, runtime 변경은 `현재 runtime 참조` 열에서만 추적한다.
- 현재 runtime ID가 다르더라도 `현재 runtime 참조` 열로 연결한다.
- 코드 기준과 다를 경우 tracker를 코드에 맞게 갱신한 뒤, 필요하면 설계 문서를 다시 조정한다.
- canonical 마이그레이션 증분은 `구현/데이터 수정 -> 검증 -> migration plan / tracker / design 문서 갱신` 순서로 닫는다.
- canonical 마이그레이션 턴은 row 전환이 없더라도 migration plan, tracker, design 문서의 진행 메모가 함께 갱신될 때만 닫는다.
- migration plan의 `Phase 진행 상태`만 갱신하고 이 문서 또는 design 문서를 건너뛴 턴은 완료로 보지 않는다.
- migration plan에 다음 안전 증분이 남지 않았다면 tracker 갱신만으로는 턴을 닫지 않는다.

## 2026-04-07 다단히트 / 무쿨 반영 현황

### 이번 턴에서 기준이 잠긴 source of truth

- active 공격 스킬 runtime 수치:
  - `data/spells.json`
  - 현재 잠긴 필드: `cooldown`, `damage`, `multi_hit_count`, `hit_interval`
  - linked active `skills.json` row의 `cooldown_base`는 mirror field로 유지하며 primary runtime spell cooldown과 동기화
- deploy / toggle 공격 스킬 cadence 보정:
  - `data/skills/skills.json`
  - 현재 잠긴 필드: `tick_interval`, `damage_cadence_reference_interval`
- canonical 입력 ↔ runtime cast ID 연결:
  - `data/spells.json.source_skill_id`
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`
- active 다단 구현 기준:
  - active cast payload는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd`에서 1회만 emit
  - 대상별 multi-hit sequence source는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_projectile.gd`
  - hit effect만 반복하고 attack effect / cast feedback은 1회만 유지
  - `suppress_cast_lock`는 follow-up hit가 아니라 bonus projectile emit 억제 용도로만 남긴다

### 이번 턴에 기준 반영이 끝난 스킬

- `1~4서클 무쿨 + 다단 active`:
  - `fire_bolt`, `water_aqua_bullet`, `wind_arrow`, `earth_stone_shot`, `holy_halo_touch`, `fire_flame_bullet`, `water_aqua_spear`, `wind_gust_bolt`, `earth_rock_spear`, `ice_frost_needle`, `wind_gale_cutter`, `fire_flame_arc`, `water_tidal_ring`, `water_wave`, `holy_cure_ray`, `holy_radiant_burst`, `volt_spear`, `lightning_bolt`, `ice_spear`, `lightning_thunder_arrow`
- `4~6서클 다단 active`:
  - `wind_storm`, `wind_tempest_drive`, `ice_absolute_freeze`, `fire_inferno_buster`
- `4~6서클 cadence 상향 deploy / toggle`:
  - `dark_grave_echo`, `fire_flame_storm`, `ice_storm`, `earth_fortress`, `plant_worldroot_bastion`
- `7서클 이상 다단 active`:
  - `fire_meteor_strike`, `water_tsunami`, `earth_gaia_break`, `dark_void_bolt`, `water_ocean_collapse`, `wind_heavenly_storm`, `earth_tremor`, `earth_continental_crush`, `earth_world_end_break`, `fire_apocalypse_flame`, `fire_solar_cataclysm`, `ice_absolute_zero`, `holy_judgment_halo`
- `7서클 이상 cadence 상향 deploy / toggle`:
  - `fire_inferno_sigil`, `wind_cyclone_prison`, `fire_hellfire_field`, `wind_storm_zone`, `plant_world_root`, `ice_glacial_dominion`, `lightning_tempest_crown`, `wind_sky_dominion`, `plant_genesis_arbor`, `dark_soul_dominion`

### 이번 턴 예외 / 후속 분리 대상

- `1~4서클 무쿨 예외`:
  - `earth_stone_spire`, `plant_vine_snare`, `dark_shadow_bind`, `ice_ice_wall`
- 공격 placeholder가 남아 있어도 이번 턴 다단 개편 대상에서 제외한 지원계:
  - `holy_bless_field`, `holy_sanctuary_of_reversal`, `holy_seraph_chorus`
- 후속으로 더 다듬을 placeholder / read 개선 과제:
  - `ice_ice_wall` wall read
  - 지원계 heal/cleanse/toggle의 공격 placeholder 분리 여부
  - placeholder effect family를 전용 원본으로 교체할지 여부

## 현재 runtime 과 직접 연결된 스킬

| canonical skill_id | 서클 | 속성 | 이름 | 타입 | 현재 runtime 참조 | 구현 | asset | attack effect | hit effect | 레벨 스케일 | 비고 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `fire_bolt` | 1 | 불 | 파이어 볼트 | 액티브 / 발사형 | `fire_bolt` | `runtime` | `applied` | `applied` | `applied` | `runtime_generic` | 현재 대표 기본 투사체. 2026-04-03 payload contract test로 hotbar action 기준 `spell_id / school / damage / cooldown / speed / velocity / split effect id`를 잠갔다 |
| `water_bullet` | 1 | 물 | 워터 불릿 | 액티브 / 발사형 | `water_aqua_bullet` | `runtime` | `verified` | `verified` | `verified` | `runtime_generic` | 기본 물 탄환 라인. 2026-04-06 follow-up에서 `Water Effect 2/WaterBall` 기반 `attack / projectile loop / hit` family로 실제 refresh를 완료했고, split effect + projectile body AnimatedSprite2D 회귀를 GUT로 잠갔다 |
| `ice_frost_needle` | 2 | 얼음 | 프로스트 니들 | 액티브 / 발사형 / 견제 | `ice_frost_needle` | `runtime` | `verified` | `verified` | `verified` | `runtime_generic` | `ice_spear`에 흡수하지 않고 별도 canonical 유지 정렬 완료. 2026-04-06 증분에서 기본 ice hotbar/runtime를 `ice_frost_needle`로 승격했고, `Ice Effect 01 - VFX1` 기반 `attack / projectile loop / hit` family와 slow poke contract를 GUT로 잠갔다. `frost_nova`는 legacy freeze burst runtime으로 유지한다 |
| `earth_stone_spire` | 2 | 대지 | 어스 스파이크 | 설치형 / 즉발 cone | `earth_stone_spire` | `verified` | `verified` | `verified` | `verified` | `verified` | `earth_spike` 3서클 core slot과 분리된 2서클 canonical 유지 row, 사용자 노출 지속. `earth_tremor`는 인접 earth burst proxy 참고축으로만 유지. 2026-04-06 후속 증분에서 `Earth Effect 01` 기반 startup 균열 / 솟구침 본체 / 반복 impact를 실제 runtime hook으로 연결했고, 2026-04-09 follow-up으로 deploy runtime contract, level scaling, grounded cone-burst representative regression까지 닫아 verified 승격을 마쳤다 |
| `wind_cutter` | 3 | 바람 | 윈드 커터 | 액티브 / 직선 / 다단 | `wind_gale_cutter` | `runtime` | `verified` | `verified` | `verified` | `runtime_generic` | 최신 기획과 가장 가깝게 정렬됨. 2026-04-06 follow-up에서 `Wind Effect 01/Wind Projectile`, `Wind Hit Effect` 기반 `attack / projectile / hit` family로 실제 refresh를 완료했고, 좌우 반전 포함 projectile body 회귀를 GUT로 잠갔다 |
| `fire_flame_arc` | 3 | 불 | 플레임 써클 | 액티브 / 원형 burst | `fire_flame_arc` | `runtime` | `verified` | `n/a` | `n/a` | `runtime_generic` | `fire_burst`에 흡수하지 않고 별도 canonical 유지 정렬 완료. 3서클 사냥형 광역 버스터이며 2026-04-06 후속 증분에서 `spells.json` runtime row와 `Fire Effect 2` 16프레임 burst visual을 실제 연결했다 |
| `water_tidal_ring` | 3 | 물 | 타이달 링 | 액티브 / 원형 push control | `water_tidal_ring` | `verified` | `verified` | `verified` | `verified` | `verified` | `water_wave`에 흡수하지 않고 별도 canonical 유지 정렬 완료. 2026-04-06 증분에서 active spell row를 실제 추가하고 `Water Effect 01`의 startup ring + main ring + splash family를 `water_tidal_ring_attack`, `water_tidal_ring`, `water_tidal_ring_hit`으로 연결했다. 2026-04-09 follow-up으로 `GameState.get_spell_runtime("water_tidal_ring")` 위에 `knockback_scale_per_level` authored field를 연결해 damage / duration / size / knockback active runtime contract를 중앙 helper로 잠갔고, cast payload sync와 실제 hit push regression까지 함께 닫아 verified 승격을 마쳤다 |
| `holy_mana_veil` | 2 | 백마법 | 마나 베일 | 버프 | `holy_mana_veil` | `verified` | `verified` | `n/a` | `n/a` | `verified` | 2026-04-06 증분에서 `PixelHolyEffectsPack01/HolyShield` 기반 `holy_guard_activation` / `holy_guard_overlay` 공용 버프 비주얼 훅을 실제 연결했다. 2026-04-09 follow-up으로 `GameState.get_buff_runtime()` 중앙 helper 위에 base holy guard duration/cooldown/effects 계약을 잠갔고, cast 시 active buff remaining/cooldown sync, `damage_taken_multiplier`, `poise_bonus` guard contract, level 1 대비 level 30 duration/cooldown/guard scaling 대표 회귀까지 함께 닫아 verified 승격을 마쳤다 |
| `fire_pyre_heart` | 4 | 불 | 파이어 하트 | 버프 / offense burst | `fire_pyre_heart` | `verified` | `verified` | `n/a` | `n/a` | `verified` | Phase 5 버프 canonical 유지 정렬 완료. 2026-04-07 fallback buff fire 확장으로 canonical buff row에 `pyre_heart_activation` / `pyre_heart_overlay` authored 값을 추가했고, 2026-04-09 follow-up으로 checked-in dedicated `pyre_heart_activation` / `pyre_heart_overlay` family, `fire_final_damage_multiplier + fire_melee_burst` offense contract, level 1 대비 level 30 duration/cooldown/fire finisher scaling 대표 회귀까지 함께 닫아 verified 승격을 마쳤다 |
| `ice_frostblood_ward` | 4 | 얼음 | 프로스트블러드 워드 | 버프 / defense reflect | `ice_frostblood_ward` | `verified` | `verified` | `n/a` | `n/a` | `verified` | Phase 5 버프 canonical 유지 정렬 완료. 2026-04-07 fallback buff ice 확장으로 canonical buff row에 `frostblood_ward_activation` / `frostblood_ward_overlay` authored 값을 추가했고, 2026-04-09 follow-up으로 checked-in dedicated `frostblood_ward_activation` / `frostblood_ward_overlay` family, `ice_status_duration_multiplier + ice_reflect_wave` defense/reflect contract, level 1 대비 level 30 duration/cooldown/control-window scaling 대표 회귀까지 함께 닫아 verified 승격을 마쳤다 |
| `arcane_magic_mastery` | 1 | 아케인 | 아케인 마스터리 | 패시브 / mastery | `arcane_magic_mastery` | `runtime` | `n/a` | `n/a` | `n/a` | `verified` | Phase 5 패시브 canonical 유지 정렬 완료. 어떤 마법 스킬을 쓰든 숙련도가 오르는 공용 mastery row로 잠겼고, 2026-04-07 후속 증분에서 `GameState.get_mastery_runtime_modifiers_for_skill()` shared helper 위에 global mastery layer를 실제 연결했다. 현재 authored source of truth는 `final_multiplier_per_level = 0.003`, `5/15/25` mana 감소, `10/20/30` cooldown 감소이며 active / deploy / toggle 전부가 같은 helper를 읽는다. `register_skill_damage()`도 arcane school runtime spell에서 global arcane XP를 한 번만 적립하도록 double-count guard까지 함께 잠겼다 |
| `fire_mastery` | 1 | 불 | 파이어 마스터리 | 패시브 / mastery | `fire_mastery` | `verified` | `n/a` | `n/a` | `n/a` | `verified` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["fire"]`와 `register_skill_damage("fire_bolt", dealt)` 경로를 통한 XP/레벨 progression hook은 계속 검증 상태다. 2026-04-03 증분에서 `GameState.get_spell_runtime()`, `GameState.get_skill_mana_cost()`, `scripts/player/spell_manager.gd`의 data-driven runtime builder에 fire school `active / deploy / toggle`용 fire mastery wiring을 연결했고, `final_multiplier_per_level = +5%`와 lv10 `cooldown_reduction = 0.03` milestone이 `fire_bolt` GUT로 잠겼다. 같은 날짜 구조 개선 증분부터는 active / deploy / toggle 공통 scaling 해석도 `GameState.build_common_runtime_stat_block()`과 `GameState.get_common_scaled_mana_value()` 기준으로 읽는다 |
| `water_mastery` | 1 | 물 | 워터 마스터리 | 패시브 / mastery | `water_mastery` | `verified` | `n/a` | `n/a` | `n/a` | `verified` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["water"]`와 `register_skill_damage("water_aqua_bullet", dealt)` 경로를 통한 XP/레벨 progression hook은 검증됐다. 이번 구조 개선 후속 증분에서 school-specific mastery modifier stack이 shared helper로 이동했고, `water_aqua_bullet` active의 damage / cooldown / mana contract까지 잠갔다 |
| `ice_mastery` | 1 | 얼음 | 아이스 마스터리 | 패시브 / mastery | `ice_mastery` | `verified` | `n/a` | `n/a` | `n/a` | `verified` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["ice"]`와 `register_skill_damage("ice_frost_needle", dealt)` 경로를 통한 XP/레벨 progression hook은 검증됐고, 2026-04-07 후속 증분에서 `ice_glacial_dominion` toggle의 damage / cooldown / sustain mana contract까지 shared helper 대표 검증으로 잠갔다 |
| `lightning_mastery` | 1 | 전기 | 라이트닝 마스터리 | 패시브 / mastery | `lightning_mastery` | `verified` | `n/a` | `n/a` | `n/a` | `verified` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["lightning"]`와 `register_skill_damage("volt_spear", dealt)` 경로를 통한 XP/레벨 progression hook은 검증됐고, 2026-04-07 후속 증분에서 `lightning_tempest_crown` toggle의 damage / cooldown / sustain mana contract까지 shared helper 대표 검증으로 잠갔다 |
| `wind_mastery` | 1 | 바람 | 윈드 마스터리 | 패시브 / mastery | `wind_mastery` | `verified` | `n/a` | `n/a` | `n/a` | `verified` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["wind"]`와 `register_skill_damage("wind_gale_cutter", dealt)` 경로를 통한 XP/레벨 progression hook은 검증됐고, 2026-04-07 후속 증분에서 `wind_storm_zone` toggle의 damage / cooldown / sustain mana contract까지 shared helper 대표 검증으로 잠갔다 |
| `earth_mastery` | 1 | 대지 | 어스 마스터리 | 패시브 / mastery | `earth_mastery` | `verified` | `n/a` | `n/a` | `n/a` | `verified` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["earth"]`와 `register_skill_damage("earth_tremor", dealt)` 경로를 통한 XP/레벨 progression hook은 검증됐고, 2026-04-09 후속 증분에서 `earth_fortress` toggle의 zero-damage defense runtime + cooldown / sustain mana contract까지 shared helper 대표 검증으로 다시 잠갔다 |
| `plant_mastery` | 1 | 자연(풀) | 플랜트 마스터리 | 패시브 / mastery | `plant_mastery` | `verified` | `n/a` | `n/a` | `n/a` | `verified` | Phase 5 패시브 canonical 유지 정렬 완료. `plant_vine_snare`를 plant school runtime spell entry로 정의한 뒤, `SCHOOL_TO_MASTERY["plant"]`와 `register_skill_damage("plant_vine_snare", dealt)` 경로를 통한 XP/레벨 progression hook까지 검증됐다. 이번 구조 개선 후속 증분에서 school-specific mastery modifier stack이 shared helper로 이동했고, `plant_vine_snare` deploy의 damage / cooldown / mana contract까지 잠갔다 |
| `dark_magic_mastery` | 3 | 흑마법 | 다크 매직 마스터리 | 패시브 / mastery | `dark_magic_mastery` | `verified` | `n/a` | `n/a` | `n/a` | `verified` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["dark"]`와 `register_skill_damage("dark_void_bolt", dealt)` 경로를 통한 XP/레벨 progression hook은 검증됐다. 이번 구조 개선 후속 증분에서 school-specific mastery modifier stack이 shared helper로 이동했고, `dark_grave_echo` toggle의 damage / cooldown / sustain mana contract까지 잠갔다 |
| `plant_root_bind` | 4 | 자연(풀) | 루트 바인드 | 설치형 / CC | `plant_vine_snare` | `verified` | `verified` | `verified` | `verified` | `verified` | canonical alias와 데이터 표기 정렬 완료. 2026-04-09 follow-up으로 `plant_vine_snare_attack / plant_vine_snare / plant_vine_snare_hit / plant_vine_snare_end` dedicated vine-bind family를 실제 runtime source of truth로 승격했고, canonical 입력 `plant_root_bind`는 계속 `plant_vine_snare` deploy payload와 설치 연출까지 함께 보장한다. representative regression은 deploy payload의 repeated root contract, level 1 대비 level 30 `duration`/`size` scaling, dedicated `phase_signature = plant_vine_snare` ground telegraph, startup/loop/terminal read까지 함께 잠갔다 |
| `ice_ice_wall` | 4 | 얼음 | 아이스 월 | 설치형 / wall control | `ice_ice_wall` | `verified` | `verified` | `verified` | `verified` | `verified` | 별도 canonical 유지 정렬 완료. 4서클 얼음 장벽 생성형 제어기이며 현재 source of truth는 checked-in `ice_ice_wall_attack / ice_ice_wall / ice_ice_wall_hit / ice_ice_wall_end` dedicated family와 wall 전용 `phase_signature = ice_ice_wall`이다. deploy payload는 `slow + short root` control rider를 직접 싣고, representative regression은 wall startup/loop/terminal read, contact control, level 1 대비 level 30 duration/size scaling까지 함께 잠갔다 |
| `holy_healing_pulse` | 4 | 백마법 | 힐링 펄스 | 액티브 / 회복 burst | `holy_radiant_burst` | `verified` | `verified` | `verified` | `verified` | `verified` | row key rename 없이 유지, `canonical_skill_id = holy_healing_pulse` 명시 완료. 2026-04-03 payload contract test로 canonical hotbar 입력과 admin -> hotbar -> save -> cast 경로가 모두 `holy_radiant_burst` runtime payload의 `spell_id / school / damage / cooldown / speed` 계약으로 이어짐을 잠갔다. 2026-04-06 증분에서 `PixelHolyEffectsPack01/Heal`, `HolyNova` frame set을 실제 `holy_radiant_burst_attack/hit` runtime asset으로 교체했고 split effect 회귀 GUT도 통과했다. 2026-04-09 follow-up으로 `holy_radiant_burst`에 solo-runtime self-heal rider를 실제 연결했고 canonical payload의 `self_heal` 계약, cast 시 즉시 회복 read, level 1 대비 level 30 damage/range/self-heal scaling 회귀까지 잠가 verified 승격을 닫았다 |
| `lightning_thunder_lance` | 4 | 전기 | 썬더 랜스 | 액티브 / 관통 burst | `volt_spear` | `verified` | `verified` | `verified` | `verified` | `verified` | `lightning_bolt`, `lightning_thunder_arrow`에 흡수하지 않고 별도 canonical 유지 정렬 완료. 중간 쿨 직선 버스터 / 보스 대응 축. `Thunder Effect 01-02` 랜스/strike 군을 `volt_spear_attack/hit` runtime asset으로 실제 교체했고, canonical hotbar 입력 `lightning_thunder_lance -> volt_spear` payload 계약, fast narrow lance contract, level 1 대비 level 30 damage/range scaling, milestone pierce progression까지 GUT로 잠갔다 |
| `earth_quake_break` | 5 | 대지 | 퀘이크 브레이크 | 액티브 / 광역 burst | `earth_tremor` | `verified` | `verified` | `verified` | `verified` | `verified` | canonical alias와 데이터 표기 정렬 완료, 퀘이크/가이아 계열 재정의는 후속. runtime proxy `earth_tremor`는 `Earth Bump` 기반 centered startup crack, `Impact` 7프레임 hit strip, dedicated `phase_signature = earth_tremor`를 source of truth로 사용한다. canonical hotbar 입력 `earth_quake_break -> earth_tremor` payload 계약과 level 1 대비 level 30 damage/size/cooldown scaling, `gaia_break`보다 가볍게 읽히는 quake signature hierarchy까지 GUT로 잠갔다 |
| `wind_tempest_drive` | 5 | 바람 | 템페스트 드라이브 | 액티브 / 이동기 | `wind_tempest_drive` | `verified` | `verified` | `n/a` | `n/a` | `verified` | 2026-04-07 사용자 결정 기준으로 5서클 순수 active canonical을 잠갔다. `tempest_drive_activation` family는 persistent overlay 없이 active startup visual로만 유지하고, `spells.json` row는 activation burst source of truth, `skills.json` row는 active metadata + dash authored field source로 정리했다. 2026-04-09 follow-up으로 `GameState.get_spell_runtime("wind_tempest_drive")` 위에 `dash_speed` / `dash_duration` 중앙 runtime contract를 실제 연결했고, `player.on_active_skill_cast_started(skill_id, runtime)`가 이를 직접 소비하도록 정리했다. cast 시 dash state/velocity/timer sync, level 1 대비 level 30 damage/range/dash scaling, `Conductive Surge` 이후 `Overclock Circuit` live consumer payload/cooldown 회귀까지 함께 닫아 verified 승격을 마쳤다 |
| `holy_crystal_aegis` | 6 | 백마법 | 크리스탈 이지스 | 버프 / 방어 | `holy_crystal_aegis` | `verified` | `verified` | `n/a` | `n/a` | `verified` | canonical row 한글 표기와 상위 방어 버프 설명 정렬 완료. 2026-04-06 증분에서 `PixelHolyEffectsPack01/HolyShield` 기반 공용 buff activation / owner aura hook을 실제 연결했고 `holy_mana_veil`보다 높은 overlay 우선순위, activation spawn, overlay 유지까지 GUT로 잠갔다. 2026-04-09 follow-up으로 `GameState.get_buff_runtime()` 중앙 helper 위에 duration/cooldown/effects 계약을 잠갔고, cast 시 active buff remaining/cooldown sync, `damage_taken_multiplier`, `super_armor_charges`, `status_resistance` guard contract, level 1 대비 level 30 duration/cooldown/guard scaling 대표 회귀까지 함께 닫아 verified 승격을 마쳤다 |
| `holy_sanctuary_of_reversal` | 7 | 백마법 | 생츄어리 오브 리버설 | 설치형 / 순간 생존기 | `holy_sanctuary_of_reversal` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-09 follow-up으로 `holy_sanctuary_of_reversal_attack / holy_sanctuary_of_reversal / holy_sanctuary_of_reversal_hit / holy_sanctuary_of_reversal_end` dedicated sanctuary family를 실제 runtime source of truth로 승격했고, deploy payload도 장기 회복 placeholder가 아니라 `self_heal + support_effects(damage_taken_multiplier, poise_bonus)` reversal survival contract로 재정의했다. representative regression은 dedicated `phase_signature = holy_sanctuary_of_reversal` ground telegraph, cast payload contract, owner-inside heal/guard window, incoming damage reduction, owner-leave 후 guard expiry, level 1 대비 level 30 heal/range/guard scaling까지 함께 잠갔다 |
| `fire_inferno_sigil` | 7 | 불 | 인페르노 시길 | 설치형 / 반복 폭발 burst | `fire_inferno_sigil` | `runtime` | `verified` | `verified` | `verified` | `runtime_generic` | `fire_flame_storm`, `fire_inferno_buster`에 흡수하지 않고 별도 canonical 유지 정렬 완료. 2026-04-06 follow-up 증분에서 `Fire Effect 2` 반복 폭발 군을 `fire_inferno_sigil_attack`, `fire_inferno_sigil`, `fire_inferno_sigil_hit`, `fire_inferno_sigil_end` 4단 family로 실제 연결했고, 2026-04-07 후속으로 `0.4s` cadence의 8-hit inferno pulse와 cadence-normalized tick damage 기준까지 반영했다 |
| `wind_cyclone_prison` | 7 | 바람 | 사이클론 프리즌 | 설치형 / CC | `wind_cyclone_prison` | `verified` | `verified` | `verified` | `verified` | `verified` | canonical deploy row 유지 정렬 완료. `Wind Effect 02` 기반 `wind_cyclone_prison_attack / wind_cyclone_prison / wind_cyclone_prison_hit / wind_cyclone_prison_end` family와 position nudge형 pull runtime을 source of truth로 유지한다. 2026-04-09 follow-up으로 `GameState.get_data_driven_skill_runtime()` 위에 `duration / size / pull_strength / target_count` 중앙 deploy runtime contract를 잠갔고, `SpellManager._cast_deploy()`는 이를 그대로 payload에 싣는다. representative regression은 level 1 대비 level 30 duration/size/pull/target scaling, `slow + root` utility 유지, terminal end read까지 함께 닫혔다 |
| `ice_frozen_domain` | 8 | 물/얼음 | 프로즌 도메인 | 설치형 / 필드 CC | `ice_glacial_dominion` | `verified` | `verified` | `n/a` | `n/a` | `verified` | canonical alias와 데이터 표기 정렬 완료. runtime proxy는 `ice_glacial_dominion` 토글 오라를 유지하되, 2026-04-09 follow-up 기준 checked-in `ice_frozen_domain_activation / loop / end` family, level 1 대비 level 30 damage/size/target scaling, slow 유지 regression, simultaneous toggle regression까지 함께 잠긴 verified proxy row다 |
| `dark_abyss_gate` | 8 | 흑마법 | 어비스 게이트 | 액티브 / pull burst | `dark_void_bolt` | `prototype` | `verified` | `verified` | `verified` | `runtime_generic` | row key rename 없이 유지, `canonical_skill_id = dark_abyss_gate` 명시 완료. 2026-04-06 증분에서 `Dark VFX 1-2`를 `dark_void_bolt_attack/hit` runtime asset으로 실제 교체했고 split effect payload/world-effect sync 및 64x64 cropped tile 회귀 GUT를 통과했다. pull burst 보강은 후속이다 |
| `lightning_tempest_crown` | 9 | 전기 | 템페스트 크라운 | 토글 / 오라 | `lightning_tempest_crown` | `verified` | `verified` | `n/a` | `n/a` | `verified` | row key rename 없이 유지, `canonical_skill_id = lightning_tempest_crown` 명시 완료. 2026-04-09 follow-up으로 `tempest_crown_activation` / `tempest_crown_loop` / `tempest_crown_end` checked-in dedicated toggle family를 runtime source of truth로 승격했고, fast lightning cadence `0.4s`, level 1 대비 level 30 damage/size/target/pierce scaling, toggle payload contract, dedicated visual regression까지 함께 잠갔다 |
| `plant_genesis_arbor` | 10 | 자연(풀) | 제네시스 아버 | 설치형 / 최종 장기전 | `plant_genesis_arbor` | `verified` | `verified` | `verified` | `verified` | `verified` | row key rename 없이 유지, `canonical_skill_id = plant_genesis_arbor` 명시 완료. 2026-04-09 follow-up으로 `plant_genesis_arbor_attack` / `plant_genesis_arbor` / `plant_genesis_arbor_hit` / `plant_genesis_arbor_end` checked-in dedicated genesis field family를 runtime source of truth로 승격했고, level 1 대비 level 30 damage/duration/size/target scaling, root control 유지, worldroot_bastion보다 더 큰 final-canopy hierarchy regression, dedicated deploy payload/field visual regression까지 함께 잠갔다 |
| `dark_soul_dominion` | 10 | 흑마법 | 소울 도미니언 | 토글 / 피니셔 | `dark_soul_dominion` | `verified` | `verified` | `n/a` | `n/a` | `verified` | 2026-04-09 follow-up으로 `soul_dominion_activation` / `soul_dominion_loop` / `soul_dominion_end` / `soul_dominion_aftershock` / `soul_dominion_clear` checked-in dedicated toggle family를 runtime source of truth로 승격했고, fast finisher cadence `0.4s`, level 1 대비 level 30 damage/duration/size/target scaling, aftershock/clear beat regression, dark_grave_echo 위 overlay priority regression까지 함께 잠갔다 |
| `plant_worldroot_bastion` | 6 | 자연(풀) | 월드루트 바스천 | 설치형 / 장기전 | `plant_worldroot_bastion` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-09 follow-up으로 `plant_worldroot_bastion_attack` / `plant_worldroot_bastion` / `plant_worldroot_bastion_hit` / `plant_worldroot_bastion_end` checked-in dedicated bastion field family를 runtime source of truth로 승격했고, level 1 대비 level 30 damage/duration/size/target scaling, root control 유지, world_root보다 크고 genesis_arbor보다 작은 visual hierarchy regression, dedicated deploy payload/field visual regression까지 함께 잠갔다 |
| `plant_verdant_overflow` | 7 | 자연(풀) | 버던트 오버플로 | 버프 / 설치 증폭 | `plant_verdant_overflow` | `verified` | `verified` | `n/a` | `n/a` | `verified` | 2026-04-09 follow-up으로 `verdant_overflow_activation` / `verdant_overflow_overlay` checked-in dedicated buff family를 runtime source of truth로 승격했고, `deploy_range_multiplier + deploy_duration_multiplier + deploy_target_bonus` 설치 증폭 contract, level 1 대비 level 30 duration/cooldown/buff-power scaling, `Funeral Bloom` 연계와 overlay priority regression까지 함께 잠갔다 |
| `dark_shadow_bind` | 3 | 흑마법 | 섀도우 바인드 | 설치형 / 디버프 | `dark_shadow_bind` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-09 follow-up으로 `dark_shadow_bind_attack` / `dark_shadow_bind` / `dark_shadow_bind_hit` / `dark_shadow_bind_end` checked-in dedicated curse-field family를 runtime source of truth로 승격했고, level 1 대비 level 30 damage/duration/size/target scaling, slow control 유지, dedicated deploy payload/field visual regression까지 함께 잠갔다 |
| `dark_grave_echo` | 5 | 흑마법 | 그레이브 에코 | 토글 / 저주 오라 | `dark_grave_echo` | `verified` | `verified` | `n/a` | `n/a` | `verified` | 2026-04-09 follow-up으로 `grave_echo_activation` / `grave_echo_loop` / `grave_echo_end` checked-in dedicated toggle family를 runtime source of truth로 승격했고, fast curse cadence `0.6s`, level 1 대비 level 30 damage/size/target scaling, dark toggle overlay priority regression과 simultaneous toggle regression까지 함께 잠갔다 |
| `dark_grave_pact` | 6 | 흑마법 | 그레이브 팩트 | 버프 / 리스크 | `dark_grave_pact` | `verified` | `verified` | `n/a` | `n/a` | `verified` | 2026-04-09 follow-up으로 `grave_pact_activation` / `grave_pact_overlay` checked-in dedicated buff family를 runtime source of truth로 승격했고, `dark_final_damage_multiplier + kill_leech + hp_drain_percent_per_second` dark risk contract, level 1 대비 level 30 duration/cooldown/buff-power scaling, dark-only finisher amplification regression, lightning above / holy below overlay priority regression까지 함께 잠갔다 |
| `lightning_conductive_surge` | 5 | 전기 | 컨덕티브 서지 | 버프 / 폭딜 보조 | `lightning_conductive_surge` | `verified` | `verified` | `n/a` | `n/a` | `verified` | 2026-04-09 follow-up으로 `conductive_surge_activation` / `conductive_surge_overlay` checked-in dedicated buff family를 runtime source of truth로 승격했고, `lightning_final_damage_multiplier + chain_bonus + extra_lightning_ping` offense contract, level 1 대비 level 30 duration/cooldown/buff-power scaling, `holy_dawn_oath` 아래 overlay priority regression, `Tempest Drive` 성공 시 여는 `Overclock Circuit` active window contract까지 함께 잠갔다 |
| `dark_throne_of_ash` | 10 | 흑마법 | 스론 오브 애시 | 버프 / 의식 피니셔 | `dark_throne_of_ash` | `verified` | `verified` | `n/a` | `n/a` | `verified` | 2026-04-09 follow-up으로 `dark_throne_activation` / `dark_throne_overlay` checked-in dedicated ritual family를 runtime source of truth로 승격했고, `fire_final_damage_multiplier + dark_final_damage_multiplier + ash_residue_burst` dual-school finisher contract, activation mana drain, level 1 대비 level 30 duration/cooldown/buff-power scaling, owner-follow overlay priority regression까지 함께 잠갔다 |

## 코어 라인업 설계 스킬

아래 스킬은 최신 기획에는 포함되지만 아직 위의 runtime 연결 표에 직접 올라오지 않은 항목들이다.

| canonical skill_id | 서클 | 속성 | 이름 | 타입 | 현재 runtime 참조 | 구현 | asset | attack effect | hit effect | 레벨 스케일 | 비고 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `wind_arrow` | 1 | 바람 | 윈드 애로우 | 액티브 / 발사형 | `wind_arrow` | `runtime` | `placeholder` | `verified` | `verified` | `runtime_generic` | 2026-04-06 fallback projectile 1차 파동에서 `Everything` 기반 placeholder projectile/hit family를 실제 연결했다 |
| `earth_stone_shot` | 1 | 대지 | 스톤 샷 | 액티브 / 발사형 | `earth_stone_shot` | `runtime` | `placeholder` | `verified` | `verified` | `runtime_generic` | 2026-04-06 fallback projectile 1차 파동에서 `Everything` projectile + `FXpack13` hit 기반 대지 placeholder family를 실제 연결했다 |
| `holy_halo_touch` | 1 | 백마법 | 헤일로 터치 | 액티브 / 단일 회복 | `holy_halo_touch` | `runtime` | `placeholder` | `verified` | `verified` | `runtime_self_heal` | 2026-04-06 fallback projectile 1차 파동에서 `Free/Part 1,14` halo family를 실제 연결했고, 현재 solo runtime 제약상 self-heal rider를 함께 사용한다 |
| `fire_flame_bullet` | 2 | 불 | 플레임 불릿 | 액티브 / 연사 | `fire_flame_bullet` | `runtime` | `placeholder` | `verified` | `verified` | `runtime_generic` | 2026-04-06 fallback projectile 1차 파동에서 `FXpack13/Effect1` + `Fx_pack/2` fire placeholder family를 실제 연결했다 |
| `water_aqua_spear` | 2 | 물 | 아쿠아 스피어 | 액티브 / 라인 / 관통 | `water_aqua_spear` | `runtime` | `placeholder` | `verified` | `verified` | `runtime_generic` | 2026-04-06 fallback projectile 1차 파동에서 기존 `asset_sample/Effect` 기반 water line placeholder family를 실제 연결했다 |
| `wind_gust_bolt` | 2 | 바람 | 거스트 볼트 | 액티브 / 유틸 발사형 | `wind_gust_bolt` | `runtime` | `placeholder` | `verified` | `verified` | `runtime_generic` | 2026-04-06 fallback projectile 1차 파동에서 `wind_arrow`와 같은 placeholder wind family를 공유 연결했다 |
| `earth_rock_spear` | 2 | 대지 | 락 스피어 | 액티브 / 디버프 | `earth_rock_spear` | `runtime` | `placeholder` | `verified` | `verified` | `runtime_generic` | 2026-04-06 fallback projectile 1차 파동에서 대지 spear placeholder family를 실제 연결했다. 방어 감소 디버프는 후속 상태 계약 정리 뒤 붙인다 |
| `fire_burst` | 3 | 불 | 파이어 버스트 | 액티브 / AoE burst | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 광역 입문 |
| `water_wave` | 3 | 물 | 워터 웨이브 | 액티브 / 범위 제어 | `water_wave` | `runtime` | `placeholder` | `verified` | `verified` | `runtime_generic` | 2026-04-06 fallback projectile / line 6차 파동에서 기존 `fallback_water_attack/line/hit` family를 더 넓은 line-control wave로 재해석해 actual spell row와 함께 실제 연결했다. 현재는 수평 파동 + slow crowd-control read를 먼저 잠근 placeholder 단계다 |
| `earth_spike` | 3 | 대지 | 어스 스파이크 | 설치형 / burst | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 지면 솟구침 설치기. 2026-04-06 검토 기준 `Earth Effect 01` 차선 공용 후보이며, 현재는 `earth_stone_spire`와의 역할 분리를 먼저 잠근다 |
| `holy_cure_ray` | 3 | 백마법 | 큐어 레이 | 액티브 / 직선 회복 | `holy_cure_ray` | `runtime` | `verified` | `verified` | `verified` | `runtime_self_heal` | 2026-04-06 증분에서 `Heal` + `Holy VFX 02` + `Holy VFX 01 Impact` family를 실제 연결했고, 현재 solo runtime 제약상 self-heal rider를 함께 사용한다 |
| `lightning_bolt` | 4 | 불/전기 | 라이트닝 볼트 | 액티브 / 연쇄 | `lightning_bolt` | `runtime` | `placeholder` | `verified` | `verified` | `runtime_generic` | 2026-04-06 fallback projectile / line 7차 파동에서 기존 `fallback_shard_attack/projectile/hit` family를 더 밝은 yellow-white chain-control bolt로 재해석해 actual spell row와 함께 실제 연결했다. 현재는 연쇄 대신 high-pierce + shock crowd-control read를 먼저 잠근 placeholder 단계다 |
| `ice_spear` | 4 | 물/얼음 | 아이스 스피어 | 액티브 / 발사형 | `ice_spear` | `runtime` | `placeholder` | `verified` | `verified` | `runtime_generic` | 2026-04-06 fallback projectile 1차 파동에서 shard placeholder projectile family를 실제 연결했고, forced roll 회귀로 freeze utility까지 잠갔다 |
| `lightning_thunder_arrow` | 4 | 바람/전기 | 썬더 애로우 | 액티브 / 관통 | `lightning_thunder_arrow` | `runtime` | `placeholder` | `verified` | `verified` | `runtime_generic` | 2026-04-06 fallback projectile 1차 파동에서 lightning placeholder projectile/hit family를 실제 연결했고, forced roll 회귀로 shock utility까지 잠갔다 |
| `fire_flame_storm` | 5 | 불 | 플레임 스톰 | 설치형 / 지속 AoE | `fire_flame_storm` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-09 follow-up으로 `fire_flame_storm_attack` / `fire_flame_storm` / `fire_flame_storm_hit` / `fire_flame_storm_end` checked-in dedicated field family를 runtime source of truth로 승격했고, level 1 대비 level 30 damage/duration/size/target scaling, burn 유지 regression, dedicated deploy payload/field visual regression까지 함께 잠갔다 |
| `ice_storm` | 5 | 물/얼음 | 아이스 스톰 | 설치형 / 지속 CC | `ice_storm` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-09 follow-up으로 `ice_storm_attack` / `ice_storm` / `ice_storm_hit` / `ice_storm_end` checked-in dedicated frost-storm field family를 runtime source of truth로 승격했고, level 1 대비 level 30 damage/duration/size/target scaling, slow+freeze control 유지, dedicated deploy payload/field visual regression까지 함께 잠갔다 |
| `wind_storm` | 5 | 바람 | 윈드 스톰 | 액티브 / 다단 | `wind_storm` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 fallback projectile / line 10차 파동에서 기존 `fallback_wind_attack/projectile/hit` family를 대형 stationary wind burst로 재해석해 actual spell row와 함께 실제 연결했고, 2026-04-10 follow-up으로 `wind_storm_attack / wind_storm / wind_storm_hit` checked-in dedicated storm family, dedicated `phase_signature = wind_storm`, level 1 대비 level 30 damage/range/target scaling, dedicated family path regression까지 함께 잠가 verified stationary wind burst 기준을 닫았다 |
| `holy_bless_field` | 5 | 백마법 | 블레스 필드 | 설치형 / 힐+버프 장판 | `holy_bless_field` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-09 follow-up으로 `holy_bless_field_attack / holy_bless_field / holy_bless_field_hit / holy_bless_field_end` dedicated blessing family를 실제 runtime source of truth로 승격했고, deploy payload도 공격 placeholder가 아니라 `self_heal + support_effects(poise_bonus)` support field contract로 재정의했다. representative regression은 dedicated `phase_signature = holy_bless_field` ground telegraph, cast payload contract, owner-inside heal/stability tick, owner-leave 후 stability 만료, level 1 대비 level 30 heal/range/poise scaling까지 함께 잠갔다 |
| `fire_inferno_buster` | 6 | 불 | 인페르노 버스터 | 액티브 / 광역 burst | `fire_inferno_buster` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 fallback projectile / line 9차 파동에서 기존 `fallback_fire_field_attack/loop/hit` family를 대형 instant inferno burst로 재해석해 actual spell row와 함께 실제 연결했고, 2026-04-10 follow-up으로 `fire_inferno_buster_attack / fire_inferno_buster / fire_inferno_buster_hit` checked-in dedicated inferno family, existing `phase_signature = fire_inferno_buster`, level 1 대비 level 30 damage/range/target scaling, dedicated family path regression까지 함께 잠가 verified inferno burst 기준을 닫았다 |
| `ice_absolute_freeze` | 6 | 물/얼음 | 앱솔루트 프리즈 | 액티브 / 광역 CC | `ice_absolute_freeze` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 fallback projectile / line 8차 파동에서 기존 `fallback_ice_field_attack/loop/hit` family를 대형 absolute-freeze burst로 재해석해 actual spell row와 함께 실제 연결했고, 2026-04-10 follow-up으로 `ice_absolute_freeze_attack / ice_absolute_freeze / ice_absolute_freeze_hit` checked-in dedicated family와 existing `phase_signature = ice_absolute_freeze`, level 1 대비 level 30 damage/range/target scaling, dedicated family path regression까지 함께 잠가 verified freeze burst 기준을 닫았다 |
| `earth_fortress` | 6 | 대지 | 어스 포트리스 | 토글 / 순수 방어 | `earth_fortress` | `verified` | `verified` | `n/a` | `n/a` | `verified` | 2026-04-09 follow-up으로 `earth_fortress_activation / earth_fortress_loop / earth_fortress_end` dedicated fortress family를 실제 toggle visual source of truth로 승격했고, toggle runtime도 earth control aura placeholder가 아니라 `support_effects(defense_multiplier + poise_bonus + status_resistance)` pure guard contract로 재정의했다. representative regression은 dedicated activation/overlay/end read, zero-damage cast payload contract, owner guard pulse의 incoming-damage reduction + stability + status-resistance 부여, toggle off 후 guard expiry, level 1 대비 level 30 defense/size/stability scaling까지 함께 잠갔다 |
| `fire_meteor_strike` | 7 | 불 | 메테오 스트라이크 | 액티브 / 딜레이 burst | `fire_meteor_strike` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 fallback projectile / line 11차 파동에서 기존 `fallback_fire_field_attack/loop/hit/end` family를 대형 낙하 meteor burst로 재해석해 actual spell row와 함께 실제 연결했고, 2026-04-10 follow-up으로 `fire_meteor_strike_attack / fire_meteor_strike / fire_meteor_strike_hit / fire_meteor_strike_end` checked-in dedicated family와 dedicated `phase_signature = fire_meteor_strike`, level 1 대비 level 30 damage/range/target scaling regression까지 함께 잠가 verified delayed meteor burst 기준을 닫았다 |
| `water_tsunami` | 7 | 물 | 쓰나미 | 액티브 / 광역 제어 | `water_tsunami` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 fallback projectile / line 12차 파동에서 기존 `fallback_water_attack/line/hit` family를 대형 tidal lane과 trailing vortex terminal로 재해석해 actual spell row와 함께 실제 연결했고, 2026-04-10 follow-up으로 `water_tsunami_attack / water_tsunami / water_tsunami_hit / water_tsunami_end` checked-in dedicated tidal family, level 1 대비 level 30 damage/range/pierce scaling, dedicated family path regression까지 함께 잠가 verified control-wave 기준을 닫았다 |
| `earth_gaia_break` | 7 | 대지 | 가이아 브레이크 | 액티브 / 광역 붕괴 | `earth_gaia_break` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 fallback projectile / line 13차 파동에서 기존 `fallback_stone_attack/projectile/hit` family를 대형 stationary collapse burst와 dust terminal로 재해석해 actual spell row와 함께 실제 연결했고, 2026-04-10 follow-up으로 `earth_gaia_break_attack / earth_gaia_break / earth_gaia_break_hit / earth_gaia_break_end` checked-in dedicated family와 level 1 대비 level 30 damage/range/target scaling, dedicated collapse family path regression까지 함께 잠가 verified earth collapse burst 기준을 닫았다 |
| `fire_hellfire_field` | 8 | 불 | 헬파이어 필드 | 설치형 / 장판 AoE | `fire_hellfire_field` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-09 follow-up으로 `fire_hellfire_field_attack` / `fire_hellfire_field` / `fire_hellfire_field_hit` / `fire_hellfire_field_end` checked-in dedicated field family를 runtime source of truth로 승격했고, level 1 대비 level 30 damage/duration/size/target scaling, burn 유지 regression, large deploy payload/field visual regression까지 함께 잠갔다 |
| `wind_storm_zone` | 8 | 바람 | 스톰 존 | 토글 / 제어 존 | `wind_storm_zone` | `verified` | `verified` | `n/a` | `n/a` | `verified` | 2026-04-09 follow-up으로 `wind_storm_zone_activation / wind_storm_zone_loop / wind_storm_zone_end` dedicated storm-zone family를 실제 toggle visual source of truth로 승격했고, toggle runtime도 단순 owner aura placeholder가 아니라 `slow + pull_strength` enemy control zone contract로 재정의했다. representative regression은 dedicated activation/overlay/end read, cast payload의 inward draft contract, core enemy archetype slow/pull control, level 1 대비 level 30 damage/size/pull/target scaling까지 함께 잠갔다 |
| `plant_world_root` | 8 | 대지/자연 | 월드 루트 | 설치형 / 광역 속박 | `plant_world_root` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-09 follow-up으로 `plant_world_root_attack` / `plant_world_root` / `plant_world_root_hit` / `plant_world_root_end` checked-in dedicated world-root field family를 runtime source of truth로 승격했고, level 1 대비 level 30 damage/duration/size/target scaling, root control 유지, dedicated deploy payload/field visual regression까지 함께 잠갔다 |
| `holy_seraph_chorus` | 8 | 백마법 | 세라프 코러스 | 토글 / 공격-지원 혼합 오라 | `holy_seraph_chorus` | `verified` | `verified` | `n/a` | `n/a` | `verified` | 2026-04-09 follow-up으로 `holy_seraph_chorus_activation / holy_seraph_chorus_loop / holy_seraph_chorus_end` dedicated chorus family를 실제 toggle visual source of truth로 승격했고, toggle runtime도 순수 지원 placeholder가 아니라 `damage + self_heal + support_effects(poise_bonus)` mixed holy aura contract로 재정의했다. representative regression은 dedicated activation/overlay/end read, cast payload contract, 같은 pulse에서 owner heal + stability 부여와 enemy damage 동시 기여, toggle off 후 support expiry, level 1 대비 level 30 damage/heal/size/stability scaling까지 함께 잠갔다 |
| `fire_apocalypse_flame` | 9 | 불 | 아포칼립스 플레임 | 액티브 / 광역 극딜 | `fire_apocalypse_flame` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 fallback projectile / line 15차 파동에서 기존 `fallback_fire_field_attack/loop/hit/end` family를 더 큰 apocalypse burst와 ember-collapse terminal로 재해석해 actual spell row와 함께 실제 연결했고, 2026-04-10 follow-up으로 `fire_apocalypse_flame_attack / fire_apocalypse_flame / fire_apocalypse_flame_hit / fire_apocalypse_flame_end` checked-in dedicated family와 dedicated `phase_signature = fire_apocalypse_flame`, level 1 대비 level 30 damage/range/target scaling regression까지 함께 잠가 verified apocalyptic fire collapse 기준을 닫았다 |
| `water_ocean_collapse` | 9 | 물 | 오션 콜랩스 | 액티브 / 광역 제압 | `water_ocean_collapse` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 fallback projectile / line 16차 파동에서 기존 `fallback_water_attack/line/hit` family를 더 넓은 ocean lane과 heavier vortex terminal로 재해석해 actual spell row와 함께 실제 연결했고, 2026-04-10 follow-up으로 `water_ocean_collapse_attack / water_ocean_collapse / water_ocean_collapse_hit / water_ocean_collapse_end` checked-in dedicated ocean-collapse family, level 1 대비 level 30 damage/range/pierce scaling, dedicated family path regression까지 함께 잠가 verified ultimate wave-control 기준을 닫았다 |
| `wind_heavenly_storm` | 9 | 바람 | 헤븐리 스톰 | 액티브 / 다단 / 광역 | `wind_heavenly_storm` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 fallback projectile / line 17차 파동에서 기존 `fallback_wind_attack/projectile/hit` family를 더 큰 heavenly burst로 재해석해 actual spell row와 함께 실제 연결했고, 2026-04-10 follow-up으로 `wind_heavenly_storm_attack / wind_heavenly_storm / wind_heavenly_storm_hit` checked-in dedicated heavenly family, dedicated `phase_signature = wind_heavenly_storm`, level 1 대비 level 30 damage/range/target scaling, dedicated family path regression까지 함께 잠가 verified final wind burst 기준을 닫았다 |
| `earth_continental_crush` | 9 | 대지 | 컨티넨탈 크러시 | 액티브 / 광역 극딜 | `earth_continental_crush` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 fallback projectile / line 14차 파동에서 기존 `fallback_stone_attack/projectile/hit` family를 더 큰 ultimate collapse burst와 terminal dust로 재해석해 actual spell row와 함께 실제 연결했고, 2026-04-10 follow-up으로 `earth_continental_crush_attack / earth_continental_crush / earth_continental_crush_hit / earth_continental_crush_end` checked-in dedicated family와 dedicated `phase_signature = earth_continental_crush`, level 1 대비 level 30 damage/range/target scaling, dedicated collapse family path regression까지 함께 잠가 verified ultimate earth collapse 기준을 닫았다 |
| `holy_dawn_oath` | 9 | 백마법 | 던 오스 | 버프 / 피해 경감 특화 보호 | `holy_dawn_oath` | `verified` | `verified` | `n/a` | `n/a` | `verified` | 2026-04-09 follow-up으로 `holy_dawn_oath_activation / holy_dawn_oath_overlay` dedicated final-guard family를 실제 buff visual source of truth로 승격했고, buff runtime도 stronger guard placeholder가 아니라 `damage_taken_multiplier + super_armor_charges + status_resistance` damage-reduction focused final guard contract로 재정의했다. representative regression은 dedicated activation/overlay read, cast 시 active buff remaining / cooldown sync, final guard의 incoming-damage reduction + super armor + resistance read, level 1 대비 level 30 duration/cooldown/guard/resistance scaling까지 함께 잠갔다 |
| `fire_solar_cataclysm` | 10 | 불 | 솔라 카타클리즘 | 액티브 / 궁극기 | `fire_solar_cataclysm` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 fallback projectile / line 18차 파동에서 기존 `fallback_fire_field_attack/loop/hit/end` family를 더 큰 solar burst와 terminal collapse로 재해석해 actual spell row와 함께 실제 연결했고, 2026-04-10 follow-up으로 `fire_solar_cataclysm_attack / fire_solar_cataclysm / fire_solar_cataclysm_hit / fire_solar_cataclysm_end` checked-in dedicated family와 dedicated `phase_signature = fire_solar_cataclysm`, level 1 대비 level 30 damage/range/target scaling regression까지 함께 잠가 verified final solar collapse 기준을 닫았다 |
| `ice_absolute_zero` | 10 | 물/얼음 | 앱솔루트 제로 | 액티브 / 궁극기 / CC | `ice_absolute_zero` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 fallback projectile / line 20차 파동에서 기존 `fallback_ice_field_attack/loop/hit/end` family를 더 큰 final freeze burst와 terminal frost collapse로 재해석해 actual spell row와 함께 실제 연결했고, 2026-04-10 follow-up으로 `ice_absolute_zero_attack / ice_absolute_zero / ice_absolute_zero_hit / ice_absolute_zero_end` checked-in dedicated family와 existing `phase_signature = ice_absolute_zero`, level 1 대비 level 30 damage/range/target scaling, dedicated family path regression까지 함께 잠가 verified final freeze burst 기준을 닫았다 |
| `wind_sky_dominion` | 10 | 바람 | 스카이 도미니언 | 토글 / 공중전 궁극 유틸 | `wind_sky_dominion` | `verified` | `verified` | `n/a` | `n/a` | `verified` | 2026-04-09 follow-up으로 `sky_dominion_activation / sky_dominion_loop / sky_dominion_end` family를 dedicated final wind toggle source로 유지한 채, toggle runtime도 광역 피해/둔화 placeholder가 아니라 `move_speed_multiplier + jump_velocity_multiplier + gravity_multiplier + air_jump_bonus` aerial mobility contract로 재정의했다. representative regression은 dedicated activation/overlay/end read, zero-damage utility payload contract, owner의 이동속도/점프 강화/저중력/추가 점프 부여와 toggle off 후 expiry, level 1 대비 level 30 range/mobility scaling까지 함께 잠갔다 |
| `earth_world_end_break` | 10 | 대지 | 월드 엔드 브레이크 | 액티브 / 궁극기 | `earth_world_end_break` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 fallback projectile / line 19차 파동에서 기존 `fallback_stone_attack/projectile/hit` family를 더 큰 final collapse burst와 terminal dust로 재해석해 actual spell row와 함께 실제 연결했고, 2026-04-10 follow-up으로 `earth_world_end_break_attack / earth_world_end_break / earth_world_end_break_hit / earth_world_end_break_end` checked-in dedicated family와 existing `phase_signature = earth_world_end_break`, level 1 대비 level 30 damage/range/target scaling, dedicated collapse family path regression까지 함께 잠가 verified final earth collapse 기준을 닫았다 |
| `holy_judgment_halo` | 10 | 백마법 | 저지먼트 헤일로 | 액티브 / 빛 burst 지원 | `holy_judgment_halo` | `verified` | `verified` | `verified` | `verified` | `verified` | 2026-04-06 증분에서 `Smite` startup/hit, `SwordOfJustice` main, `HeavensFury` closing burst를 실제 연결했고, 2026-04-10 follow-up으로 level 1 대비 level 30 damage/range/target scaling과 dedicated `phase_signature = holy_judgment_halo` ground telegraph regression까지 함께 잠가 self-centered stationary final burst verified 기준을 닫았다 |

## 신규 에셋 기반 확장 후보

아래 스킬은 `asset_sample/Effect/new` 검토 기준으로 기존 스킬과 억지 매칭하지 않고 별도 신규 기획으로 분리한 후보들이다.

| canonical skill_id | 서클 | 속성 | 이름 | 타입 | 현재 runtime 참조 | 구현 | asset | attack effect | hit effect | 레벨 스케일 | 비고 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `water_aqua_geyser` | 3 | 물 | 아쿠아 가이저 | 액티브 / forward burst / launch | `water_aqua_geyser` | `verified` | `verified` | `verified` | `verified` | `verified` | `Water Effect 01`의 수직 분출 실루엣을 core로 쓰는 독립 canonical active row다. 2026-04-09 follow-up에서 checked-in `water_aqua_geyser_attack / water_aqua_geyser / water_aqua_geyser_hit / water_aqua_geyser_end` family를 실제 runtime에 연결했고, keyboard-first fixed-forward spawn contract, dedicated geyser telegraph phase signature, level 1 대비 level 30 damage/size/knockback scaling representative regression까지 함께 닫았다 |
| `earth_stone_rampart` | 4 | 대지 | 스톤 램파트 | 설치형 / wall control | `earth_stone_rampart` | `verified` | `verified` | `verified` | `verified` | `verified` | `Earth Effect 02 / Earth Wall` 기반의 독립 canonical deploy row로 정리했고, checked-in `earth_stone_rampart_attack / earth_stone_rampart / earth_stone_rampart_hit / earth_stone_rampart_end` family와 wall 전용 `phase_signature = earth_stone_rampart`를 source of truth로 잠갔다. representative regression은 wall deploy payload, startup/loop/terminal read, contact slow+root control, level 1 대비 level 30 duration/size scaling까지 함께 닫았다 |
| `fire_inferno_breath` | 4 | 불 | 인페르노 브레스 | 액티브 / cone / 다단 | `fire_inferno_breath` | `verified` | `verified` | `verified` | `verified` | `verified` | `Fire Effect 1 / Fire Breath`를 split startup / main breath / hit flare family로 checked-in 연결했고, 독립 canonical active row + `source_skill_id`, five-hit cone pressure contract, level 1 대비 level 30 damage/range/cooldown/burn-chance scaling 회귀까지 함께 닫았다 |

## 레거시 / 재분류 대기 스킬

| 이름 | 현재 runtime 참조 | 현재 상태 | 메모 |
| --- | --- | --- | --- |
| 프로스트 노바 | `frost_nova` | `legacy_runtime` | `ice_frost_needle` canonical 아래에 남겨 둔 freeze burst 대표 runtime. old save/preset 호환과 순간 area burst 회귀 기준선 유지용 |
| 아케인 포스 펄스 | `arcane_force_pulse` | `verified` | 2026-04-09 사용자 결정으로 독립 `arcane` 축의 기본 액티브 canonical row로 확정했다. `data/spells.json` `source_skill_id`, checked-in dedicated `arcane_force_pulse_attack / arcane_force_pulse / arcane_force_pulse_hit` family, low-circle zero-cooldown runtime contract, level 1 대비 level 30 damage/range/knockback scaling regression까지 함께 닫아 verified 승격을 마쳤다 |
| 아스트랄 컴프레션 | `arcane_astral_compression` | `verified` | 공용 마나 효율 버프로 canonical row key 유지 정렬 완료. 2026-04-09 follow-up으로 checked-in dedicated `astral_compression_activation` / `astral_compression_overlay` family, `final_damage_multiplier + mana_efficiency_multiplier` universal arcane contract, level 1 대비 level 30 duration/cooldown/final-multiplier scaling regression까지 함께 닫아 verified 승격을 마쳤다 |
| 월드 아워글래스 | `arcane_world_hourglass` | `verified` | 공용 극딜 창구 버프로 canonical row key 유지 정렬 완료. 2026-04-09 follow-up으로 checked-in dedicated `world_hourglass_activation` / `world_hourglass_overlay` family, `cast_speed_multiplier + cooldown_flow_multiplier` burst-window contract, level 1 대비 level 30 duration/cooldown/tempo scaling regression과 downside penalty regression까지 함께 닫아 verified 승격을 마쳤다 |

## 2026-04-09 완성 단계 남은 작업표

| canonical skill_id | 최종 잠금 의미 | 현재 상태 | verified를 막는 핵심 공백 | 남은 작업 |
| --- | --- | --- | --- | --- |
| `plant_root_bind` | 저서클 rooted bind 설치 제어기 | `verified` | 없음 | 완료. dedicated vine-bind family, repeated root deploy contract, dedicated telegraph phase signature, tracker/baseline 동기화까지 반영 |
| `holy_bless_field` | 힐+버프 혼합 장판 | `verified` | 없음 | 완료. dedicated blessing family, heal + poise support field contract, owner-inside/outside representative regression, tracker/baseline/design 동기화까지 반영 |
| `holy_sanctuary_of_reversal` | 순간 역전용 생존기 | `verified` | 없음 | 완료. dedicated sanctuary family, heal + damage-reduction + poise reversal bundle, owner-inside/outside representative regression, tracker/baseline/design 동기화까지 반영 |
| `earth_fortress` | 순수 방어 토글 | `verified` | 없음 | 완료. dedicated fortress toggle family, zero-damage defense multiplier + poise + status-resistance guard contract, owner guard pulse/expiry regression, tracker/baseline/design 동기화까지 반영 |
| `wind_storm_zone` | 적 둔화 제어 존 | `verified` | 없음 | 완료. dedicated storm-zone toggle family, slow + inward draft control contract, core enemy archetype regression, tracker/baseline/design 동기화까지 반영 |
| `holy_seraph_chorus` | 공격-지원 혼합 오라 | `verified` | 없음 | 완료. dedicated chorus toggle family, damage + self_heal + poise mixed aura contract, owner-heal/enemy-damage same-pulse regression, tracker/baseline/design 동기화까지 반영 |
| `holy_dawn_oath` | 피해 경감 특화 최종 holy guard | `verified` | 없음 | 완료. dedicated final holy guard family, damage-reduction + super-armor + resistance contract, cast/runtime scaling regression, tracker/baseline/design 동기화까지 반영 |
| `wind_sky_dominion` | 공중전/비행 계열 궁극 유틸 | `verified` | 없음 | 완료. dedicated sky-dominion toggle family, move-speed + jump + low-gravity + extra-jump aerial utility contract, owner mobility/expiry regression, tracker/baseline/design 동기화까지 반영 |
| `dark_throne_of_ash` | 화염/흑마법 이중 증폭 최종 의식 버프 | `verified` | 없음 | 완료. dedicated ritual activation/overlay family, fire + dark final multiplier scaling, solo ash residue trigger, activation mana drain, tracker/baseline/design 동기화까지 반영 |
| `lightning_conductive_surge` | 연쇄 강화 전기 폭딜 보조 버프 | `verified` | 없음 | 완료. dedicated conductive activation/overlay family, lightning final multiplier scaling, extra ping/chain contract, Overclock Circuit runtime 연계, tracker/baseline/design 동기화까지 반영 |
| `plant_verdant_overflow` | 설치기 증폭 + 장송 개화 연계 버프 | `verified` | 없음 | 완료. dedicated verdant activation/overlay family, deploy range/duration scaling, Funeral Bloom 연계 유지, tracker/baseline/design 동기화까지 반영 |
| `dark_grave_pact` | 생명 소모 기반 흑마법 폭딜/처치 흡수 리스크 버프 | `verified` | 없음 | 완료. dedicated grave pact activation/overlay family, dark-only finisher scaling, kill leech + hp drain risk contract, overlay priority regression, tracker/baseline/design 동기화까지 반영 |
| `dark_grave_echo` | 빠른 cadence 기반 흑마법 저주 압박 오라 | `verified` | 없음 | 완료. dedicated grave echo activation/loop/end family, `0.6s` curse cadence, damage/size/target scaling, dark overlay priority + simultaneous toggle regression, tracker/baseline/design 동기화까지 반영 |
| `dark_soul_dominion` | aftershock/clear beat까지 포함한 최종 흑마법 피니셔 오라 | `verified` | 없음 | 완료. dedicated soul dominion 5-stage family, `0.4s` finisher cadence, damage/duration/size/target scaling, aftershock/clear risk beat regression, tracker/baseline/design 동기화까지 반영 |

## 다음 우선 작업

현재 상태: `Phase 6 completed`

row-level canonical 마이그레이션 상태: `83/83 completed`

반복 재평가 규칙: 최신 기획 또는 현재 runtime 사실이 바뀌지 않았다면 같은 blocked row를 다시 canonical 후보로 올리지 않는다. 단, 사용자 답변으로 source of truth를 잠그는 구체화 인터뷰는 예외다.

단계 우회 금지 규칙: `Phase 5`, `Phase 6` pending row는 현재 blocked 상태를 우회하기 위한 대체 증분으로 당겨 처리하지 않는다.

blocked 중단 규칙: 최신 기획, 현재 runtime 사실, 문서 규칙 중 새로 잠글 변화가 없다면 추가 repo 수정 없이 중단하고 중단 이유만 남긴다. 사용자 구체화 라운드를 시작한 턴에는 질문 세트를 남기고 답변 전까지 row 수정은 보류한다.

1. 2026-04-06 신규 에셋 direct attach 1차 적용과 follow-up 보완 연결은 `dark_abyss_gate`, `lightning_thunder_lance`, `holy_healing_pulse`, `holy_crystal_aegis`, `earth_stone_spire`, `earth_quake_break`, `fire_flame_arc`, `wind_cyclone_prison`, `ice_frost_needle`, `water_tidal_ring`, `ice_frozen_domain`, `holy_cure_ray`, `holy_judgment_halo`, `fire_inferno_sigil`까지 닫혔고, 2026-04-09 후속으로 `earth_stone_spire`는 deploy runtime contract + level scaling + grounded cone-burst representative regression 기준으로, `ice_ice_wall`은 dedicated wall family + wall phase signature + contact control contract 기준으로, `earth_quake_break`는 dedicated quake phase signature + scaling regression 기준으로, `lightning_thunder_lance`는 canonical proxy contract + milestone pierce regression 기준으로, `holy_healing_pulse`는 self-heal burst read + damage/range/self-heal scaling regression 기준으로, `holy_crystal_aegis`는 central buff runtime + guard/super-armor regression 기준으로, `holy_mana_veil`은 base holy guard runtime + poise/guard regression 기준으로, `wind_tempest_drive`는 active dash runtime + `Overclock Circuit` regression 기준으로, `wind_cyclone_prison`은 central deploy runtime + pull/terminal regression 기준으로, `water_tidal_ring`은 central active runtime + push-control regression 기준으로 verified 승격까지 닫혔다.
2. 2026-04-06 fallback projectile / line 20차 파동, fallback field / aura 6차 파동, fallback buff guard / ritual 확장으로 `ice_absolute_zero`, `wind_sky_dominion`, `holy_dawn_oath`, `dark_throne_of_ash`까지 placeholder family를 실제 runtime에 올렸다. 2026-04-07 후속으로 `fire_pyre_heart`, `ice_frostblood_ward`, `arcane_astral_compression`, `arcane_world_hourglass`까지 fallback buff overlay ladder에 편입했다. 2026-04-09 보강으로 `dark_throne_of_ash`는 dedicated ritual family + dual-school finisher scaling + solo ash residue contract 기준으로, `fire_pyre_heart`는 dedicated pyre family + fire finisher scaling 기준으로, `ice_frostblood_ward`는 dedicated frostblood family + control/reflect scaling 기준으로, `arcane_astral_compression`은 dedicated astral family + universal arcane scaling 기준으로, `arcane_world_hourglass`는 dedicated hourglass family + burst-window tempo scaling 기준으로 verified 승격을 마쳤다. `ice_ice_wall`도 blocked lane이나 active placeholder wall shell이 아니라 dedicated runtime wall contract를 가진 verified row다.
3. school-specific mastery modifier stack 위의 `arcane_magic_mastery` global layer도 이제 shared runtime helper로 실제 연결됐다. 현재 authored source of truth는 `final_multiplier_per_level = 0.003`, `5/15/25` mana 감소, `10/20/30` cooldown 감소이며 active / deploy / toggle 전부가 같은 helper를 읽는다
4. school-specific mastery representative verification은 이제 `water_aqua_bullet`, `plant_vine_snare`, `dark_grave_echo`, `ice_glacial_dominion`, `lightning_tempest_crown`, `wind_storm_zone`, `earth_fortress`까지 닫혔다. `holy_mana_veil`도 이제 shared holy guard visual 위에 base guard runtime contract와 poise/guard 대표 회귀를 더해 verified row로 승격됐다.
5. `wind_tempest_drive` canonical은 이번 턴에 5서클 순수 active로 잠겼고, `Overclock Circuit`도 `Conductive Surge` 활성 중 `Tempest Drive` 성공 시 여는 `1.0초` active window로 runtime 재정의가 닫혔다. current runtime 기준 `GameState.try_activate_buff("wind_tempest_drive")`와 buff combo source는 제거된 상태를 유지한다
6. `plant_root_bind`, `holy_bless_field`, `holy_sanctuary_of_reversal`, `wind_storm_zone`, `holy_seraph_chorus`, `earth_fortress`, `holy_dawn_oath`, `wind_sky_dominion`, `dark_throne_of_ash`, `lightning_conductive_surge`, `plant_verdant_overflow`, `dark_grave_pact`는 2026-04-09 follow-up으로 verified 승격을 마쳤다. high-circle buff placeholder 축은 현재 runtime 기준으로 모두 verified 정렬을 마쳤다.
7. `dark_grave_echo`, `dark_soul_dominion`도 2026-04-09 follow-up으로 각각 dedicated toggle family + representative cadence/aftershock regression 기준 verified 승격을 마쳤다. dark toggle 축은 현재 runtime 기준으로 verified 정렬을 마쳤다.
8. 이후 새 proxy-active / runtime spell 연결은 코드 상수 추가가 아니라 `data/spells.json` `source_skill_id` + `GameDatabase` 중앙 mapping 구조에 먼저 등록하는 것을 기준으로 유지한다. 남은 구조 개선 1순위는 default hotbar / admin preset seed도 같은 source로 좁히는 것이다
9. 2026-04-09 사용자 결정으로 `arcane_force_pulse`도 더 이상 미정 prototype이 아니라 독립 canonical active row로 잠겼다. 현재 source of truth는 `skills.json.arcane_force_pulse` active metadata와 `spells.json.arcane_force_pulse.source_skill_id`, checked-in dedicated shard family, zero-cooldown low-circle runtime contract, split effect regression이다.
10. 같은 2026-04-09 follow-up으로 `fire_inferno_breath`도 더 이상 신규 planned 후보가 아니라 독립 canonical active row + checked-in `fire_inferno_breath_attack / fire_inferno_breath / fire_inferno_breath_hit` family를 쓰는 verified row가 됐다. 현재 source of truth는 five-hit stationary cone contract, burn utility의 `chance_per_level` scaling, full-file `test_game_state.gd` / `test_spell_manager.gd` green이다.
11. 같은 2026-04-09 후속 사이클로 `earth_stone_rampart`도 더 이상 신규 planned 후보가 아니라 독립 canonical deploy row + checked-in `earth_stone_rampart_attack / earth_stone_rampart / earth_stone_rampart_hit / earth_stone_rampart_end` family를 쓰는 verified row가 됐다. 현재 source of truth는 short-duration stone wall contract, contact `slow + root` control rider, dedicated wall phase signature, full-file `test_game_state.gd` / `test_spell_manager.gd` green이다.
12. 같은 2026-04-09 후속 사이클로 `water_aqua_geyser`도 더 이상 신규 planned 후보가 아니라 독립 canonical active row + checked-in `water_aqua_geyser_attack / water_aqua_geyser / water_aqua_geyser_hit / water_aqua_geyser_end` family를 쓰는 verified row가 됐다. 현재 source of truth는 keyboard-first fixed-forward burst spawn contract, dedicated geyser phase signature, high-knockback launch read, representative `test_game_state.gd` / `test_spell_manager.gd` regression이다.
