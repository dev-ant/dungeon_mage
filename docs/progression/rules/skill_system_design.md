---
title: 스킬 시스템 설계 기준
doc_type: rule
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - rule_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-09
last_verified: 2026-04-09
---

# 스킬 시스템 설계 기준

상태: 최신 기준 / 소스 오브 트루스  
최종 갱신: 2026-04-09  
섹션: 성장 시스템

## 이 문서의 역할

- 이 문서는 현재 프로젝트의 `최신 스킬 기획 기준`이다.
- 서클 라인업, 속성 구조, 상성, 전투 컨셉, 스킬 이름의 최신 정의는 이 문서를 우선한다.
- 이전 문서와 겹치는 내용이 있으면 이 문서가 우선한다.
- 실제 구현/에셋/effect 적용 현황은 [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)에서 관리한다.
- 데이터 필드 구조와 enum-like 허용값은 [skill_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md)에서 관리한다.
- canonical 마이그레이션 턴은 설계 변경 여부와 무관하게 이 문서의 진행 메모가 migration plan, tracker와 함께 갱신돼야 닫는다.
- 과거 프로토타입 기획과 리워크 초안은 아카이브 문서로만 유지한다.

## 소스 오브 트루스 관계

- 최신 기획:
  - 이름, 속성, 서클, 타입, 전투 컨셉, 목표 경험은 이 문서가 결정한다.
- 실제 런타임 사실:
  - 현재 실제로 어떤 runtime ID로 구현되어 있는지는 코드와 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)를 따른다.
- 상태 추적:
  - 구현 / asset / attack effect / hit effect / 레벨 스케일 상태는 [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)에서만 관리한다.
- 데이터 스키마:
  - canonical `skill_id`, enum-like 허용값, JSON 구조는 [skill_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md)를 따른다.
- 충돌 처리:
  - 설계와 현재 구현이 다르면 `현재 사실`은 코드와 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)가 결정하고, 이후 tracker를 맞춘다.
  - 최신 기획을 바꿔야 할지 여부는 이 문서에서 결정한다.

## 스킬 식별자 규칙

- 이 문서는 가독성을 위해 `한글 표시 이름` 중심으로 라인업을 정리한다.
- 하지만 장기 식별자는 항상 canonical `skill_id`를 사용한다.
- canonical `skill_id` 형식과 허용 규칙은 [skill_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md)를 따른다.
- 현재 구현 상태나 runtime proxy 연결은 [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)의 `canonical skill_id` 열을 기준으로 찾는다.
- 이 문서에 새 스킬을 추가하거나 이름을 바꿀 때는 같은 턴에 tracker와 schema 기준도 함께 확인한다.
- canonical 마이그레이션 증분은 `구현/데이터 수정 -> 검증 -> migration plan / tracker / design 진행 메모 갱신` 순서로 닫는다.
- migration plan의 `Phase 진행 상태`만 갱신하고 tracker 또는 이 문서의 진행 메모를 건너뛴 canonical 마이그레이션 턴은 완료로 보지 않는다.
- migration plan에 다음 안전 증분 또는 blocked 사유가 남아 있지 않다면 이 문서의 진행 메모만 갱신해도 턴을 닫지 않는다.

### canonical `skill_id` 예시

| 표시 이름 | canonical `skill_id` | 비고 |
| --- | --- | --- |
| 파이어 볼트 | `fire_bolt` | 현재 runtime ID와 동일 |
| 아케인 포스 펄스 | `arcane_force_pulse` | 현재 runtime ID와 동일 |
| 워터 불릿 | `water_bullet` | runtime proxy는 `water_aqua_bullet` |
| 루트 바인드 | `plant_root_bind` | runtime proxy는 `plant_vine_snare` |
| 힐링 펄스 | `holy_healing_pulse` | runtime proxy는 `holy_radiant_burst` |
| 프로즌 도메인 | `ice_frozen_domain` | runtime proxy는 `ice_glacial_dominion` |

### 마이그레이션 진행 메모

- canonical 마이그레이션 턴은 설계 자체 변경 여부와 무관하게, 이 섹션의 진행 메모가 migration plan / tracker와 함께 갱신될 때만 닫은 것으로 본다.
- 2026-04-02 기준 당시 row-level canonical 마이그레이션은 `42/42` row에서 완료됐다.
- 2026-04-06에 `wind_cyclone_prison` canonical row가 실제 `skills.json`에 추가되면서 기준선이 `43/43` row로 올라갔다.
- 같은 날짜 fallback projectile / line 1차 파동으로 `wind_arrow`, `earth_stone_shot`, `holy_halo_touch`, `fire_flame_bullet`, `water_aqua_spear`, `wind_gust_bolt`, `earth_rock_spear`, `ice_spear`, `lightning_thunder_arrow` canonical row가 추가되어 기준선이 `54/54` row로 올라갔다.
- 같은 날짜 fallback field / aura 2차 파동으로 `fire_flame_storm`, `fire_hellfire_field` canonical deploy row가 추가되어 기준선이 `56/56` row로 올라갔다.
- 같은 날짜 fallback field / aura 3차 파동으로 `holy_bless_field`, `wind_storm_zone`, `holy_seraph_chorus` canonical row가 추가되어 현재 총량 기준선은 `59/59` row다.
- 같은 날짜 fallback field / aura 4차 파동으로 `ice_storm`, `earth_fortress`, `plant_world_root` canonical row가 추가되어 현재 총량 기준선은 `62/62` row다.
- 같은 날짜 fallback projectile / line 6차 파동으로 `water_wave` canonical row가 추가되어 현재 총량 기준선은 `63/63` row다.
- 같은 날짜 fallback projectile / line 7차 파동으로 `lightning_bolt` canonical row가 추가되어 기준선이 `64/64` row로 올라갔다.
- 같은 날짜 fallback projectile / line 8차 파동으로 `ice_absolute_freeze` canonical row가 추가되어 현재 총량 기준선은 `65/65` row다.
- 같은 날짜 fallback projectile / line 9차 파동으로 `fire_inferno_buster` canonical row가 추가되어 현재 총량 기준선은 `66/66` row다.
- 같은 날짜 fallback projectile / line 10차 파동으로 `wind_storm` canonical row가 추가되어 현재 총량 기준선은 `67/67` row다.
- 같은 날짜 fallback projectile / line 11차 파동으로 `fire_meteor_strike` canonical row가 추가되어 현재 총량 기준선은 `68/68` row다.
- 같은 날짜 fallback projectile / line 12차 파동으로 `water_tsunami` canonical row가 추가되어 현재 총량 기준선은 `69/69` row다.
- 같은 날짜 fallback projectile / line 13차 파동으로 `earth_gaia_break` canonical row가 추가되어 현재 총량 기준선은 `70/70` row다.
- 같은 날짜 fallback projectile / line 14차 파동으로 `earth_continental_crush` canonical row가 추가되어 현재 총량 기준선은 `71/71` row다.
- 같은 날짜 fallback projectile / line 15차 파동으로 `fire_apocalypse_flame` canonical row가 추가되어 현재 총량 기준선은 `72/72` row다.
- 같은 날짜 fallback projectile / line 16차 파동으로 `water_ocean_collapse` canonical row가 추가되어 현재 총량 기준선은 `73/73` row다.
- 같은 날짜 fallback projectile / line 17차 파동으로 `wind_heavenly_storm` canonical row가 추가되어 현재 총량 기준선은 `74/74` row다.
- 같은 날짜 fallback projectile / line 18차 파동으로 `fire_solar_cataclysm` canonical row가 추가되어 현재 총량 기준선은 `75/75` row다.
- 같은 날짜 fallback projectile / line 19차 파동으로 `earth_world_end_break` canonical row가 추가되어 현재 총량 기준선은 `76/76` row다.
- 같은 날짜 fallback projectile / line 20차 파동으로 `ice_absolute_zero` canonical row가 추가되어 현재 총량 기준선은 `77/77` row다.
- 같은 날짜 fallback field / aura 6차 파동으로 `wind_sky_dominion` canonical row가 추가되어 현재 총량 기준선은 `78/78` row다.
- 같은 날짜 fallback buff guard 확장으로 `holy_dawn_oath` canonical row가 추가됐고, 2026-04-09 후속으로 `arcane_force_pulse`, `fire_inferno_breath`, `earth_stone_rampart`, `water_aqua_geyser` canonical row도 실제 `skills.json`에 추가되어 현재 총량 기준선은 `83/83` row다.
- 같은 2026-04-09 사용자 결정으로 `arcane_force_pulse`는 더 이상 미정 arcane prototype이 아니다. 현재 잠긴 경험은 `2서클 아케인 기본 단일기`, `현재 runtime ID 유지`, `low-circle zero-cooldown`, `checked-in dedicated shard family`, `split effect attack/hit`, `level scaling verified`다.
- Phase별 완료 범위는 아래와 같이 정리한다.
  - `Phase 1`: canonical alias 1차 전환
    - `fire_ember_dart -> fire_bolt`
    - `water_aqua_bullet -> water_bullet`
    - `wind_gale_cutter -> wind_cutter`
    - `holy_mana_veil -> holy_mana_veil`
    - `plant_vine_snare -> plant_root_bind`
    - `ice_glacial_dominion -> ice_frozen_domain`
    - `earth_terra_break -> earth_quake_break`
  - `Phase 2`: 최신 한글 표기와 runtime proxy 설명 정렬
    - `holy_healing_pulse`, `dark_abyss_gate`, `lightning_tempest_crown`
    - `dark_soul_dominion`, `dark_shadow_bind`, `dark_grave_echo`, `dark_grave_pact`
    - `lightning_conductive_surge`, `plant_worldroot_bastion`, `plant_verdant_overflow`
    - `holy_crystal_aegis`, `holy_sanctuary_of_reversal`, `dark_throne_of_ash`, `wind_tempest_drive`
  - `Phase 3~4`: legacy combat / deploy row의 별도 canonical 유지 확정
    - `ice_frost_needle`, `earth_stone_spire`, `lightning_thunder_lance`
    - `fire_flame_arc`, `water_tidal_ring`, `ice_ice_wall`, `fire_inferno_sigil`
  - `Phase 5`: mastery / buff / arcane row canonical 정렬
    - mastery: `fire_mastery`, `water_mastery`, `ice_mastery`, `lightning_mastery`, `wind_mastery`, `earth_mastery`, `plant_mastery`, `dark_magic_mastery`, `arcane_magic_mastery`
    - buff: `fire_pyre_heart`, `ice_frostblood_ward`, `arcane_astral_compression`, `arcane_world_hourglass`
  - `Phase 6`: row key rename 재평가 결론
    - `holy_healing_pulse`, `dark_abyss_gate`, `lightning_tempest_crown`, `plant_genesis_arbor`는 row key rename 없이 유지

- 이번 canonical 마이그레이션에서 반복적으로 잠긴 공통 규칙은 아래와 같다.
  - 다른 최신 스킬에 성급히 흡수하지 않는다.
  - 현재 `skill_id` row key를 canonical 이름의 기준으로 본다.
  - `canonical_skill_id`는 기본적으로 현재 row key와 같은 값으로 유지한다.
  - 서클은 현재 `skills.json` 값을 유지한다.
  - `hit_shape`는 값이 비어 있거나 기획 메모가 모자랄 때 스킬 이름과 핵심 경험을 기준으로 보수적으로 추론한다.
  - 사용자 노출, hotbar/save 유지, 현재 runtime 축 유지, 인접 스킬과의 차별점이 분명하면 별도 canonical row로 먼저 유지한다.

- 위 규칙으로 고정한 canonical 식별자는 후속 구현 단계에서 asset, effect, 레벨 스케일을 강화하더라도 다시 흔들지 않는다.
- arcane 축은 현재 runtime의 독립 `school / element`로 유지하되, 실제 적용 범위는 아래처럼 분리해서 읽는다.
  - `arcane_magic_mastery`: 아케인 대표 mastery row, 표기명 `아케인 마스터리`, 적용 범위 `all`
  - `arcane_astral_compression`: 표기명 `아스트랄 압축`, 공용 `마나 효율 버프`
  - `arcane_world_hourglass`: 표기명 `월드 아워글래스 오브 아케인`, 공용 `극딜 창구 버프`
- `holy_healing_pulse`, `dark_abyss_gate`, `lightning_tempest_crown`, `plant_genesis_arbor`는 모두 row key rename 없이 유지하며, 현재 runtime proxy나 runtime row도 그대로 유지한다.
- 2026-04-09 사용자 결정으로 canonical-proxy 구조는 최종 빌드까지 계속 유지한다.
- `Phase 6` row key 유지 결론을 다시 검토한 결과, canonical row key 유지 자체는 계속 안전하다. 2026-04-03 hardening 증분부터는 admin library / hotbar assignment와 `spell_hotbar` save path도 runtime-castable ID 기준으로 정규화한다.
  - `holy_healing_pulse`를 hotbar에 넣으면 저장값은 `holy_radiant_burst`로 정규화한다.
  - `dark_abyss_gate`를 hotbar에 넣으면 저장값은 `dark_void_bolt`로 정규화한다.
  - `plant_root_bind`를 hotbar에 넣으면 저장값은 `plant_vine_snare`로 정규화한다.
  - hotbar가 해석할 수 없는 stale invalid ID는 assignment에서 거부하고, 과거 save에 남은 값은 hotbar 초기화 시 slot default로 정리한다.
- row-level canonical 마이그레이션 다음 단계는 새 canonical 추가가 아니라 후속 검증이다.
  - 첫 post-migration verification 기준선 `fire_mastery`는 2026-04-03 runtime wiring까지 닫았다.
    - `SCHOOL_TO_MASTERY["fire"]`와 `register_skill_damage("fire_bolt", dealt)`를 통한 mastery XP/레벨 progression hook 검증 완료
    - `GameState.get_spell_runtime()`, `GameState.get_skill_mana_cost()`, `scripts/player/spell_manager.gd`의 data-driven runtime builder가 fire school `active / deploy / toggle`에 `fire_mastery`를 먼저 적용
    - 실제 GUT 잠금은 `fire_mastery` lv10의 `fire_bolt` 피해 상승과 lv10 `cooldown_reduction = 0.03` milestone 반영
  - `water_mastery`도 같은 방식으로 `SCHOOL_TO_MASTERY["water"]`와 `register_skill_damage("water_aqua_bullet", dealt)`를 통한 mastery XP/레벨 progression hook까지 확인됐고, 이번 구조 개선 후속 증분에서 shared helper 경로의 active damage / cooldown / mana contract까지 잠갔다.
  - `ice_mastery`도 같은 방식으로 `SCHOOL_TO_MASTERY["ice"]`와 `register_skill_damage("ice_frost_needle", dealt)`를 통한 mastery XP/레벨 progression hook까지 확인됐고, 2026-04-07 후속 증분에서 `ice_glacial_dominion` toggle의 damage / cooldown / sustain mana contract까지 shared helper 대표 검증으로 잠갔다.
  - `lightning_mastery`도 같은 방식으로 `SCHOOL_TO_MASTERY["lightning"]`와 `register_skill_damage("volt_spear", dealt)`를 통한 mastery XP/레벨 progression hook까지 확인됐고, 2026-04-07 후속 증분에서 `lightning_tempest_crown` toggle의 damage / cooldown / sustain mana contract까지 shared helper 대표 검증으로 잠갔다.
  - `wind_mastery`도 같은 방식으로 `SCHOOL_TO_MASTERY["wind"]`와 `register_skill_damage("wind_gale_cutter", dealt)`를 통한 mastery XP/레벨 progression hook까지 확인됐고, 2026-04-07 후속 증분에서 `wind_storm_zone` toggle의 damage / cooldown / sustain mana contract까지 shared helper 대표 검증으로 잠갔다.
  - `earth_mastery`도 같은 방식으로 `SCHOOL_TO_MASTERY["earth"]`와 `register_skill_damage("earth_tremor", dealt)`를 통한 mastery XP/레벨 progression hook까지 확인됐고, 2026-04-07 후속 증분에서 `earth_fortress` toggle의 damage / cooldown / sustain mana contract까지 shared helper 대표 검증으로 잠갔다.
  - `plant_mastery`도 `plant_vine_snare`를 plant school runtime spell entry로 정의한 뒤, `SCHOOL_TO_MASTERY["plant"]`와 `register_skill_damage("plant_vine_snare", dealt)`를 통한 mastery XP/레벨 progression hook까지 확인됐고, 이번 구조 개선 후속 증분에서 shared helper 경로의 deploy damage / cooldown / mana contract까지 잠갔다.
  - `dark_magic_mastery`도 같은 방식으로 `SCHOOL_TO_MASTERY["dark"]`와 `register_skill_damage("dark_void_bolt", dealt)`를 통한 mastery XP/레벨 progression hook까지 확인됐고, 이번 구조 개선 후속 증분에서 `dark_grave_echo` toggle의 damage / cooldown / sustain mana contract까지 shared helper로 잠갔다.
  - 토글 대표 row `lightning_tempest_crown`는 level 1의 base `pierce = 2`, level 24 milestone 이후 `pierce = 4`가 실제 tick payload에 반영됨을 검증했다.
  - 설치형 대표 row `plant_root_bind`는 `plant_vine_snare` runtime proxy 기준으로 deploy payload의 `duration`과 `size`가 level 1 대비 level 30에서 실제 증가함을 검증했다.
  - burst 대표 row `arcane_world_hourglass`는 buff activation 후 cooldown 압축, downside penalty, level 1 대비 level 30 duration scaling이 실제 runtime에 반영됨을 검증했다.
  - 2026-04-03 사용자 답변으로 mastery `data-only` 규칙은 구현 스펙 수준으로 잠겼다.
    - 일반 mastery(`fire`/`water`/`ice`/`lightning`/`wind`/`earth`/`plant`/`dark`)의 핵심 경험은 `해당 school의 active / deploy / toggle을 모두 강화하는 범용 숙련 패시브`다.
    - 일반 mastery의 `final_multiplier_per_level`는 `레벨당 최종 피해 +5%`다.
    - mastery 시스템 전체는 `최종 피해 + 마나 비용 + 쿨다운`에 영향을 준다. per-level 기본 성장축은 최종 피해로 읽고, `threshold_bonuses`는 `damage + mana + cooldown` bonus slot으로 쓴다.
    - `threshold_bonuses`는 `5/10/15/20/25/30` milestone마다 열린다.
    - 일반 mastery의 적용 대상은 `해당 school의 active / deploy / toggle` 전부다.
    - 계산 순서는 `mastery를 먼저 적용하고 그 뒤에 장비 / 버프 / 공명 등 다른 최종 배수 계열을 곱연산`으로 올린다.
    - `arcane_magic_mastery`는 예외 규칙이다. 어떤 마법 스킬을 쓰든 숙련도가 오르고, 모든 속성 스킬에 영향을 주는 공용 mastery로 유지한다.
    - 현재 authored source of truth 기준 `arcane_magic_mastery.final_multiplier_per_level = 0.003`이고, 일반 mastery보다 별도 milestone 배치로 운용한다.
    - `arcane_magic_mastery` milestone은 `5/15/25`의 mana 감소와 `10/20/30`의 cooldown 감소만 사용한다. 현재 row에는 damage threshold bonus를 두지 않는다.
    - 최소 구현 완료 판정은 `fire_mastery` 10레벨에서 `fire_bolt` 피해 상승과 10레벨 milestone의 마나 또는 쿨다운 bonus가 GUT 1개로 검증되는 상태다.
  - 2026-04-03 구현 증분으로 일반 mastery의 school-specific runtime path는 공통 helper까지 실제 연결됐다.
    - fire school `active / deploy / toggle`는 `mastery -> 장비 / 버프 / 공명` 순서로 `damage + mana + cooldown`을 계산한다.
    - 이번 구조 개선 후속 증분에서 `GameState.get_mastery_runtime_modifiers_for_skill()`의 `fire_mastery` 단일 하드코딩을 제거했고, school-specific mastery row는 같은 공통 helper를 탄다.
    - 대표 계약 테스트는 `water_aqua_bullet` active, `plant_vine_snare` deploy, `dark_grave_echo` toggle로 잠갔다.
    - `arcane_magic_mastery`는 `applies_to_school = all`, `applies_to_element = all` 예외 규칙이지만, 2026-04-07 후속 증분부터는 `GameState.get_mastery_runtime_modifiers_for_skill()` shared helper 위의 global layer로 실제 연결됐다.
    - 현재 global layer는 active / deploy / toggle 전부에 같은 방식으로 적용되며, school mastery와 arcane global mastery를 곱연산으로 합성한다.
    - `register_skill_damage()`는 arcane school runtime spell에서도 `arcane_magic_mastery` XP를 한 번만 적립한다. linked canonical skill row가 없는 spell row라도 school 판정이 가능하면 global arcane XP는 계속 적립한다.
  - 2026-04-03 구조 개선 증분으로 active와 deploy/toggle는 공통 runtime 계산 경로를 먼저 공유한다.
    - 공통 source of truth는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_common_runtime_stat_block()`과 `get_common_scaled_mana_value()`다.
    - `GameState.get_spell_runtime()`와 `scripts/player/spell_manager.gd`의 `_build_skill_runtime()`는 level scaling, mastery modifier, equipment multiplier, 공통 mana scaling을 이 helper에서 먼저 읽는다.
    - type-specific 후처리는 그대로 바깥에 남긴다. active buff 후처리는 `_apply_buff_runtime_modifiers()`, deploy 전용 후처리는 `apply_deploy_buff_modifiers()`, toggle tick payload 후처리는 `apply_spell_modifiers()`가 담당한다.
    - 향후 스킬 구현은 이 공통 runtime 계산 경로를 기준으로 진행한다.
    - 새 mastery / buff / equipment 계산 규칙은 타입별 개별 구현보다 공통 runtime 계산 경로에 먼저 추가하고, 정말 필요한 type-specific 후처리만 각 캐스트 타입에 남긴다.
  - 2026-04-03 구조 개선 후속 증분으로 proxy-active / runtime spell ↔ canonical skill 연결도 중앙 mapping 구조 기준으로 잠근다.
    - source of truth는 `data/spells.json`의 `source_skill_id`와 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`가 구성하는 forward / reverse mapping table이다.
    - `GameState.get_skill_id_for_spell()`, `GameState.get_runtime_castable_hotbar_skill_id()`, hotbar/save normalization, admin assignment, cast 진입 전 정규화는 이 중앙 mapping을 먼저 읽는다.
    - 이후 새 proxy-active / runtime spell 연결은 코드 상수 추가가 아니라 이 중앙 mapping 구조에 먼저 등록한다.
    - 이후 스킬 구현은 공통 runtime 계산 경로와 함께 이 mapping 구조를 기준으로 진행한다.
  - 2026-04-03 구조 개선 후속 증분으로 admin skill library도 runtime-castable 전체 기준의 data-driven catalog를 source of truth로 잠근다.
    - source of truth는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`의 `get_runtime_castable_skill_catalog()`다.
    - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd`는 빈 슬롯 UI 항목만 별도로 붙이고, 실제 배치 가능한 스킬 목록은 이 catalog만 렌더링한다.
    - canonical-only row는 admin 배치 대상에 직접 섞이지 않고, proxy-active row는 대응 runtime spell ID로만 노출한다.
    - 이후 새 스킬의 admin 배치 가능 여부는 하드코딩 목록 추가가 아니라 중앙 mapping + runtime-castable 구조를 만족하는지로 결정한다.
    - 이후 스킬 구현은 공통 runtime 계산 경로, 중앙 mapping 구조와 함께 이 admin/library 구조를 기준으로 진행한다.
  - 2026-04-03 구조 개선 후속 증분으로 `skills.json / spells.json` 최소 validation도 구현 기준으로 잠근다.
    - source of truth는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`의 `validate_skill_entry()`, `validate_spell_entry()`, `validate_skill_spell_link()`, `validate_spell_skill_link()`다.
    - 로드 시점에 식별자/타입 필드, `skill_type` 최소 계약, runtime spell 기본 필드, proxy-active 연결 누락, spell school ↔ skill element drift를 먼저 검증한다.
    - 이후 새 skill / spell / proxy 연결 추가 시 구현 완료 판정은 이 validation 통과를 전제로 한다.
    - 이후 새 proxy-active / mastery / deploy / toggle 규칙을 추가하면 validation도 같은 턴에 함께 갱신한다.
    - 이후 스킬 구현은 공통 runtime 계산 경로, 중앙 mapping 구조, admin/library 구조와 함께 이 validation 구조를 기준으로 진행한다.
  - 2026-04-03 구조 개선 후속 증분으로 school 판정도 공통 resolver 기준으로 잠근다.
    - source of truth는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `resolve_runtime_school()`다.
    - 우선순위는 `runtime spell row.school -> linked/canonical skill row.element -> linked/canonical skill row.school -> caller hint`다.
    - mastery XP progression, school-specific mastery runtime modifier, runtime tooltip/runtime summary school 표기는 이 helper를 먼저 읽는다.
    - school 충돌은 기존 `skills.json / spells.json` validation이 spell school ↔ skill element drift를 먼저 잡고, 런타임에서는 위 우선순위로 해석한다.
    - 이후 새 mastery / deploy / toggle / proxy-active 구현은 개별 함수마다 school 규칙을 따로 넣지 않고 이 공통 school resolver를 기준으로 진행한다.
  - 2026-04-03 hardening 증분으로 runtime scaling option 기본값도 공통 builder 기준으로 잠근다.
    - source of truth는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_active_spell_runtime_options()`와 `build_data_driven_skill_runtime_options()`다.
    - `GameState.get_spell_runtime()`와 `scripts/player/spell_manager.gd`의 data-driven runtime builder는 이제 공통 stat helper에 넘기는 level / school / mastery / equipment scaling option 세트를 이 builder에서 먼저 읽는다.
    - 이후 새 mastery / deploy / toggle / active scaling 규칙은 개별 call site에 딕셔너리를 덧붙이지 말고 이 공통 option builder에 먼저 반영한다.
  - 2026-04-03 hardening 증분으로 data-driven deploy / toggle base runtime block도 공통 helper 기준으로 잠근다.
    - source of truth는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_data_driven_skill_base_runtime()`다.
    - `scripts/player/spell_manager.gd`의 `_build_skill_runtime()`는 damage formula, base cooldown / duration / size, tick interval, knockback, milestone pierce, utility_effects의 초기 블록을 이 helper에서 먼저 읽는다.
    - 이후 새 deploy / toggle runtime 기본 필드를 추가할 때는 `SpellManager` call site에 직접 딕셔너리를 늘리지 말고 이 base runtime helper를 먼저 갱신한다.
  - 2026-04-03 hardening 후속 증분으로 data-driven deploy / toggle 최종 runtime 조립도 공통 entrypoint 기준으로 잠근다.
    - source of truth는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `get_data_driven_skill_runtime()`와 `get_data_driven_skill_mana_drain_per_tick()`다.
    - `scripts/player/spell_manager.gd`의 `_build_skill_runtime()`와 toggle sustain cost helper는 이제 이 공통 entrypoint에 위임만 한다.
    - 이후 새 deploy / toggle 후처리는 `SpellManager`에 직접 추가하지 말고 이 공통 runtime entrypoint를 먼저 갱신한다.
  - 2026-04-03 hardening 다음 증분으로 deploy / toggle cast payload seed도 공통 helper 기준으로 잠근다.
    - source of truth는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd`의 `build_data_driven_combat_payload()`다.
    - `scripts/player/spell_manager.gd`의 `_cast_deploy()`와 toggle tick payload path는 공통 payload 필드를 이 helper에서 먼저 읽고, 위치/타입별 후처리만 덧붙인다.
    - 이후 새 deploy / toggle payload 필드는 `SpellManager` call site에 직접 딕셔너리를 늘리지 말고 이 공통 payload helper를 먼저 갱신한다.
  - 2026-04-03 hardening 다음 증분으로 representative runtime payload contract test도 구현 기준으로 잠근다.
    - representative coverage는 `fire_bolt` active, `plant_root_bind -> plant_vine_snare` deploy, `lightning_tempest_crown` toggle, `holy_healing_pulse -> holy_radiant_burst` proxy-active다.
    - 이후 새 스킬 구현이나 payload 구조 변경은 내부 helper 수정만으로 완료로 보지 않고, 같은 턴에 representative payload contract test를 먼저 또는 함께 추가한다.
    - 이후 새 active / deploy / toggle / proxy-active 규칙은 “payload에 어떤 필드가 최종 보장되는가”를 계약 테스트로 남기는 것을 기본 원칙으로 한다.
  - mastery / buff / deploy row의 effect / level scaling 상태를 `verified`까지 끌어올린다.
  - `Phase 6` row key 유지 결론에 맞춘 save / UI / runtime 잔여 리스크 재검토와 hotbar/save hardening은 완료했다.
  - 다음 후속 증분은 `plant_root_bind`의 startup/main/hit family 위에 deploy runtime contract, level scaling, grounded root-control representative regression을 더해 verified 승격 후보를 이어가는 것이다.
  - 필요하면 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)와 tracker 검증 상태를 같은 턴에 동기화한다.

## 2026-04-09 완성 단계 잠금 결정

- `holy_bless_field`의 최종 정체성은 `힐+버프 혼합 장판`으로 잠근다.
- `holy_sanctuary_of_reversal`의 최종 정체성은 `순간 역전용 생존기`로 잠근다.
- `holy_seraph_chorus`의 최종 정체성은 `공격-지원 혼합 오라`로 잠근다.
- `wind_storm_zone`의 최종 정체성은 `적 둔화 제어 존`으로 잠근다.
- `holy_dawn_oath`의 상위 차별점은 `피해 경감`으로 잠근다.
- `earth_fortress`의 최종 정체성은 `순수 방어 토글`로 잠근다.
- `wind_sky_dominion`의 최종 정체성은 `공중전/비행 계열 궁극 유틸`로 잠근다.
- canonical-proxy 구조는 현재처럼 유지한다. canonical 입력과 저장 구조는 계속 장기 식별자를 보존하고, 실제 cast는 runtime-castable ID로 정규화한다.
- `verified`는 이제 `전용 연출 + 구현 + 테스트 + 문서 동기화`까지 완료된 상태로 해석한다. fallback family나 placeholder 연출만으로는 `runtime` 또는 `prototype`까지만 허용한다.
- 상위 서클 스킬은 단순히 `더 크고 더 센 하위기의 확장판`으로 닫지 않는다. 상위 서클일수록 전투 역할이 명확히 바뀌어야 하며, 검증도 그 역할 전환을 기준으로 잡는다.

### 잠금 결정의 직접 영향

- `holy_seraph_chorus`, `wind_storm_zone`, `earth_fortress`, `holy_dawn_oath`, `wind_sky_dominion`은 현재 fallback read만 확보한 상태로는 `verified`에 올리지 않는다.
- `holy_bless_field`는 공격 placeholder 장판이 아니라 `회복 + 버프 부여`가 함께 읽히는 support field로 닫아야 한다.
- `holy_sanctuary_of_reversal`은 장기 회복 필드가 아니라 `짧은 역전 창구`라는 순간 생존 경험으로 닫아야 한다.
- `holy_seraph_chorus`는 순수 회복 오라가 아니라 `공격 기여와 지원 기여가 동시에 있는 최종 holy aura`로 닫아야 한다.
- `wind_storm_zone`은 아군 버프 존이 아니라 `적 둔화/제어 존`으로 닫아야 한다.
- `earth_fortress`는 earth control aura가 아니라 `순수 방어 토글`로 닫아야 한다.
- `holy_dawn_oath`는 holy guard 상위축 중에서도 `피해 경감`을 핵심 차별점으로 닫아야 한다.
- `wind_sky_dominion`은 큰 wind aura가 아니라 `공중전/비행 utility`를 실제 runtime contract와 전용 연출로 닫아야 한다.

## 목적

이 문서는 초기 프로토타입 중심 마법 목록을 장기 운영 가능한 `속성 구조 + 서클 라인업 + 전투 컨셉` 기준으로 다시 정리한 최신 설계 문서다.

## 전제

- 속성군은 `백마법`, `흑마법`, `불`, `물`, `바람`, `대지`, `전기`, `얼음`, `자연(풀)`로 관리한다.
- 기본 4속성은 `불`, `물`, `바람`, `대지`다.
- 서브 속성은 아래처럼 붙인다.
  - `불 -> 전기`
  - `물 -> 얼음`
  - `대지 -> 자연(풀)`
  - `바람 -> 서브 속성 없음`, 대신 이동/회피/위치 조작/버프/유틸의 고유 정체성을 가진다.
- 기존 구현 데이터 호환을 위해, 구현 단계에서는 아래 매핑을 유지한다.
  - 기획 표기 `전기` = 구현 키 `lightning`
  - 기획 표기 `자연(풀)` = 구현 키 `plant`
- 모든 마법 이름은 번역어 대신 `영문식 이름의 한글 발음 표기`를 사용한다.

## 속성 구조

| 속성 | 전투 정체성 | 대표 역할 | 대표 상태/부가효과 |
| --- | --- | --- | --- |
| 백마법 | 안정성, 보호, 회복 | 힐러, 버퍼, 보호막 서포터 | 보호막, 회복, 정화 |
| 흑마법 | 디버프, 리스크/리턴 | 하이리스크 딜러, 보스 디버퍼 | 저주, HP 소모, 생명력 교환 |
| 불 | 순간 폭딜 + 긴 쿨타임 | 보스 딜러, 마무리 딜 | 화상 |
| 전기 | 광역 중딜 + 연쇄 | 사냥 특화, 다수 처리 | 감전, 추가 타격, 마비 확률 |
| 물 | 안정성 + 소프트 CC | 컨트롤러, 파티 안정화 | 슬로우, 명중 감소 |
| 얼음 | 하드 CC | 패턴 차단, 행동 봉쇄 | 빙결 |
| 대지 | 탱킹 + 안정성 | 전면 유지, 버티기 | 슈퍼아머, 경직 저항 |
| 자연(풀) | 지속딜 + 흡혈 | 장기전 딜러, 안정형 DoT | 중독, 생명 흡수, 구속 |
| 바람 | 유틸 특화 | 컨트롤, 이동, 위치 조작 | 넉백, 에어본, 대시, 은신, 헤이스트 |

## 속성 상성표

포켓몬식 상성 구조를 참고하되, 이 프로젝트는 숫자 단계만 `1.4 / 1.2 / 0.8 / 0.6`으로 고정한다.

| 공격 속성 | 1.4배 | 1.2배 | 0.8배 | 0.6배 |
| --- | --- | --- | --- | --- |
| 백마법 | 흑마법 | 자연(풀) | 대지 | - |
| 흑마법 | 백마법 | 바람 | 자연(풀) | - |
| 불 | 자연(풀) | 얼음 | 대지 | 물 |
| 전기 | 물 | 바람 | 자연(풀) | 대지 |
| 물 | 불 | 대지 | 얼음 | 전기 |
| 얼음 | 바람 | 자연(풀) | 물 | 불 |
| 대지 | 전기 | 불 | 자연(풀) | 물 |
| 자연(풀) | 물 | 대지 | 얼음 | 불 |
| 바람 | 자연(풀) | 대지 | 전기 | 얼음 |

비고:
- 표에 없는 조합은 `1.0배` 중립이다.
- 백마법과 흑마법은 서로에게 `1.4배`를 주는 특수 대립축으로 운용한다.
- 바람은 상성보다 `유틸 우위`로 가치를 만든다.

## 서클 설계 원칙

- `백마법 + 기본 4속성(불/물/바람/대지)`은 `1~10서클` 전 구간에 최소 1개씩 존재해야 한다.
- 한 속성이 특정 컨셉을 가져도, 그 속성 안에는 최소한 `지속딜`, `폭딜`, `범위딜` 중 1개 이상은 반드시 존재하도록 분산한다.
- 각 스킬은 최소한 아래 정보가 잠겨 있어야 한다.
  - 이름
  - 타입
  - 전투 컨셉
  - 기본 수치
  - 레벨 성장 규칙
- 레벨이 있는 스킬은 `1~30레벨`을 기본 전제로 잡고, 성장 규칙은 [skill_level_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_level_rules.md)와 호환 가능해야 한다.

## 2026-04-07 다단히트 / 무쿨 운영 규칙

### 정정 목표

- 이미 runtime 또는 prototype 이상으로 연결된 공격 스킬 전체를 한 번에 재정렬한다.
- 상위 서클일수록 다단히트 체감이 확실해야 한다.
- `1~4서클` 공격 액티브는 기본적으로 `쿨타임 0`을 적용한다.
- 설치형 / 토글형은 `반복 tick`과 `burst 분할 히트`를 구분해서 다룬다.
- 기본 원칙은 `총합 피해 유지, 1히트당 피해 분할`이다.

### 정정 전 사실

- 2026-04-07 후속 작업 시점 기준 active runtime은 `data/spells.json`에 `multi_hit_count / hit_interval`을 이미 갖고 있다.
- 하지만 직전 구현은 이를 `1회 시전 안의 on-hit 다단`이 아니라 `cast 시점 payload 분할 emit`으로 해석했다.
- 그 결과 일부 active는 `1회 시전 -> 여러 payload emit -> follow-up hit payload` 구조로 동작하며, 이는 이번 턴의 타격감 목표와 다르다.
- deploy / toggle 계열은 이미 `tick_interval` 기반 반복 피해가 가능하지만, 다수의 고서클 스킬이 `1.0초` 전후 cadence에 머물러 상위 서클 다단 체감이 약하다.
- active runtime의 수치 source of truth는 현재 `data/spells.json` spell row이고, deploy / toggle runtime의 수치 source of truth는 `data/skills/skills.json` row를 `GameState.get_data_driven_skill_runtime()`이 해석한 결과다.
- canonical `skill_id`와 runtime cast ID 연결 source of truth는 계속 `data/spells.json.source_skill_id + GameDatabase` 중앙 mapping이다.

### 현재 잠금 결과

- active 다단히트는 이제 `1회 시전 -> 1회 payload emit -> 1회 attack effect / projectile or area spawn -> 적중 후 대상별 multi-hit sequence`로 동작한다.
- `multi_hit_count / hit_interval`은 cast follow-up emit이 아니라 `spell_projectile.gd`의 on-hit sequence에서 소비한다.
- cast payload의 `damage`와 `total_damage`는 총합 피해를 뜻하고, 실제 적중 시점에 hit별 피해로 분할한다.
- `hit effect`만 타수만큼 반복되고, `attack effect / mana / cooldown / cast lock / cast_start / camera shake`는 1회만 발생한다.
- deploy / toggle 공격 스킬은 이번 턴에도 `반복 tick cadence`를 우선적인 다단 source로 유지한다.

### 소스 오브 트루스 잠금

- active 공격 스킬의 현재 runtime 수치 source of truth:
  - `data/spells.json`
  - 포함 범위: `damage`, `cooldown`, `speed`, `range`, `duration`, `pierce`, `multi_hit_count`, `hit_interval`
  - linked active `skills.json` row의 `cooldown_base`는 runtime source가 아니라 mirror field로만 유지하고, primary runtime spell cooldown과 같은 값으로 동기화한다.
- deploy / toggle 공격 스킬의 현재 runtime 수치 source of truth:
  - `data/skills/skills.json`
  - 포함 범위: `cooldown_base`, `duration_base`, `tick_interval`, `damage_formula`, `target_count_base`, `utility_effects`
- canonical ↔ runtime 연결 source of truth:
  - `data/spells.json.source_skill_id`
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`
- 같은 스킬의 cooldown이 `skills.json`과 `spells.json`에 함께 있어도, active runtime은 `spells.json`, deploy / toggle runtime은 `skills.json`을 우선한다.
- 단, active row의 `cooldown_base`는 UI / progression / 문서 표의 drift를 막기 위해 primary runtime spell cooldown과 항상 같은 값으로 잠근다.
- `frost_nova`처럼 같은 active skill에 연결된 legacy 보조 spell row는 예외로 둘 수 있고, validation은 primary runtime spell link만 비교한다.

### 다단히트 판정 규칙

- `4~6서클` 공격 스킬은 최소 `2타`, 기본 목표는 `2~6타`다.
- `7서클 이상` 공격 스킬은 최소 `6타`다.
- `연사`, `연쇄`, `반복 폭발`, `지속 타격`, `자동 낙뢰`, `연속 타격`, `다단` 뉘앙스가 있는 스킬은 동서클 평균보다 높은 타수를 우선 부여한다.
- `메테오`, `아포칼립스`, `컨티넨탈`, `월드 엔드`, `저지먼트`, `가이아 브레이크` 같은 초중량 burst는 `0.05~0.12초` 분할 히트로 나누되 체감은 한 방으로 남긴다.
- 다단히트의 의미는 `여러 번 공격`이 아니라 `한 번의 공격 인스턴스가 적중 후 같은 대상에게 여러 번 hit를 적용`하는 것이다.
- active burst / projectile / line는 `multi_hit_count + hit_interval` 기준의 `on-hit sequence`로 처리한다.
- active는 `1회 시전`, `1회 payload emit`, `1회 attack effect`, `1회 projectile/body/area spawn`만 허용한다.
- `hit effect`만 `multi_hit_count`에 맞춰 반복 재생한다.
- 같은 공격 인스턴스가 여러 적을 맞출 수는 있지만, 같은 적에게는 같은 인스턴스의 multi-hit sequence가 중복 시작되면 안 된다.
- deploy / toggle는 별도 burst_count를 늘리기보다 `tick_interval` 조정으로 다단 체감을 만든다.
- deploy / toggle의 반복 tick은 `여러 번의 tick`이고, 한 tick 내부 multi-hit와는 구분해서 읽는다.
- 이번 턴 기준 구현에서는 deploy / toggle 공격 스킬의 다단 체감은 우선 `반복 tick cadence`를 source로 유지하고, tick 내부 multi-hit는 별도 authored 근거가 있는 스킬에만 후속 검토한다.
- deploy는 `min(duration, 3.0초)` 구간의 체감 타수로 다단 기준을 판단한다.
- toggle은 `3.0초 sustain window` 기준 체감 타수로 다단 기준을 판단한다.
- pure heal / pure defense / pure cleanse / pure buff / direct damage 없는 utility는 다단 개편 대상에서 제외한다.
- 공격과 회복이 함께 있는 혼합형은 공격 파트만 다단 규칙과 무쿨 규칙을 적용한다.

### 총합 피해 유지 원칙

- 기본 원칙은 `총합 피해 유지`다.
- active 스킬은 기존 1히트 총합을 `on-hit multi-hit sequence`로 쪼갤 때 hit당 피해를 분할한다.
- cast payload의 `damage`는 기본적으로 총합 피해를 뜻하고, 실제 hit 적용 시점에 hit별 피해로 나눈다.
- deploy / toggle는 cadence를 빠르게 할 때 tick당 피해를 낮춰 같은 sustain 총합을 유지한다.
- `연쇄`, `자동 낙뢰`, `반복 폭발`, `오라 tick` 계열만 예외적으로 소폭 총합 조정을 허용한다.
- 총합을 조정한 경우에는 tracker와 테스트에서 조정 이유를 남긴다.

### 1~4서클 무쿨 규칙

- `1~4서클 공격 액티브`는 기본적으로 `쿨타임 0`을 적용한다.
- 혼합형 공격/회복 액티브인 `holy_halo_touch`, `holy_cure_ray`, `holy_healing_pulse`도 공격 파트가 있으므로 무쿨 대상에 포함한다.
- `1~4서클`의 pure heal / pure defense / pure buff는 이번 규칙의 기본 무쿨 대상이 아니다.
- `1~4서클 설치형 / wall / control deploy`는 전투 루프 붕괴를 막기 위해 예외 판단을 둔다.

### 1~4서클 무쿨 적용 / 예외

| canonical skill_id | runtime cast ID | 타입 | 이번 턴 판단 | 근거 |
| --- | --- | --- | --- | --- |
| `fire_bolt` | `fire_bolt` | active | `무쿨 적용` | 기본 투사체 starter. 자주 눌러도 field spam이 생기지 않는다 |
| `water_bullet` | `water_aqua_bullet` | active | `무쿨 적용` | 저피해 기본기 + soft CC. low-damage frequent cast 의도 |
| `wind_arrow` | `wind_arrow` | active | `무쿨 적용` | 저서클 push starter. 무쿨이어도 투사체 기본기 범주 |
| `earth_stone_shot` | `earth_stone_shot` | active | `무쿨 적용` | 무거운 기본기지만 투사체 단발형이라 루프 붕괴가 작다 |
| `holy_halo_touch` | `holy_halo_touch` | active / mixed heal | `무쿨 적용` | 공격+자가 회복 혼합형 기본기. 공격 파트 기준 적용 |
| `fire_flame_bullet` | `fire_flame_bullet` | active | `무쿨 적용` | 연사형 단일기. 무쿨 기본기 체감과 가장 잘 맞는다 |
| `water_aqua_spear` | `water_aqua_spear` | active | `무쿨 적용` | line / pierce 기본기. 투사선 루프 유지 목적 |
| `wind_gust_bolt` | `wind_gust_bolt` | active | `무쿨 적용` | push basic. 이동 제어 기본기로 자주 쓰는 감각 우선 |
| `earth_rock_spear` | `earth_rock_spear` | active | `무쿨 적용` | 저서클 single-target pressure. 투사체형이라 spam 리스크가 제한적 |
| `ice_frost_needle` | `ice_frost_needle` | active | `무쿨 적용` | poke / slow 기본기. low-circle weave 의도 |
| `wind_cutter` | `wind_gale_cutter` | active | `무쿨 적용` | 근중거리 다단 기본기. 바람 루프의 기본 클릭감 우선 |
| `fire_flame_arc` | `fire_flame_arc` | active | `무쿨 적용` | 3서클 광역 입문기지만 stationary burst 1회성이라 loop 파괴가 작다 |
| `water_tidal_ring` | `water_tidal_ring` | active | `무쿨 적용` | 근접 원형 제어기. AoE지만 지속 field가 아니므로 무쿨 허용 |
| `water_wave` | `water_wave` | active | `무쿨 적용` | 전방 line control 기본기. 저서클 crowd-control loop 유지 목적 |
| `holy_cure_ray` | `holy_cure_ray` | active / mixed heal | `무쿨 적용` | 회복+직선 견제 혼합형. 공격 파트 기준 적용 |
| `holy_healing_pulse` | `holy_radiant_burst` | active / mixed heal | `무쿨 적용` | 회복 burst proxy지만 현재 runtime에 공격 파트와 self-heal rider가 함께 존재한다 |
| `arcane_force_pulse` | `arcane_force_pulse` | active | `무쿨 적용` | 2서클 아케인 기본 단일기. 이번 결정으로 독립 canonical row와 zero-cooldown runtime contract를 함께 잠갔다 |
| `lightning_thunder_lance` | `volt_spear` | active | `무쿨 적용` | 4서클 lightning line burst. 현재 source of truth는 fast narrow lance read와 milestone pierce 성장이다 |
| `lightning_bolt` | `lightning_bolt` | active | `무쿨 적용` | 4서클 chain/lightning 입문기. 이번 턴 핵심 적용 대상 |
| `ice_spear` | `ice_spear` | active | `무쿨 적용` | 4서클 projectile control. 공격 액티브 우선 적용 대상 |
| `lightning_thunder_arrow` | `lightning_thunder_arrow` | active | `무쿨 적용` | 4서클 관통 lightning basic. 공격 액티브 우선 적용 대상 |
| `earth_stone_spire` | `earth_stone_spire` | deploy | `예외: 무쿨 미적용` | 설치 cone burst 반복 spam 시 진입선 봉쇄가 과도하다 |
| `plant_root_bind` | `plant_vine_snare` | deploy | `예외: 무쿨 미적용` | root field spam 시 초반 루프를 과도하게 잠근다 |
| `dark_shadow_bind` | `dark_shadow_bind` | deploy | `예외: 무쿨 미적용` | 3서클 curse field는 control value가 높아 cooldown gate 유지 |
| `ice_ice_wall` | `ice_ice_wall` | deploy / wall | `예외: 무쿨 미적용` | wall shell은 공간 차단 read가 우선이라 재설치 연타를 막아야 한다 |

### 구현된 공격 스킬 잠금 타수

#### 1~4서클 공격 액티브

| canonical skill_id | runtime cast ID | 직전 구현 | 현재 잠금 결과 |
| --- | --- | --- | --- |
| `fire_bolt` | `fire_bolt` | `1hit`, cooldown `0.22s` | `2hit @0.06s`, cooldown `0` |
| `water_bullet` | `water_aqua_bullet` | `1hit`, cooldown `0.28s` | `2hit @0.06s`, cooldown `0` |
| `wind_arrow` | `wind_arrow` | `1hit`, cooldown `0.30s` | `2hit @0.05s`, cooldown `0` |
| `earth_stone_shot` | `earth_stone_shot` | `1hit`, cooldown `0.55s` | `2hit @0.08s`, cooldown `0` |
| `holy_halo_touch` | `holy_halo_touch` | `1hit`, cooldown `1.8s` | `2hit @0.08s`, cooldown `0` |
| `fire_flame_bullet` | `fire_flame_bullet` | `1hit`, cooldown `0.18s` | `3hit @0.05s`, cooldown `0` |
| `water_aqua_spear` | `water_aqua_spear` | `1hit`, cooldown `0.75s` | `2hit @0.06s`, cooldown `0` |
| `wind_gust_bolt` | `wind_gust_bolt` | `1hit`, cooldown `0.42s` | `2hit @0.05s`, cooldown `0` |
| `earth_rock_spear` | `earth_rock_spear` | `1hit`, cooldown `0.88s` | `2hit @0.07s`, cooldown `0` |
| `ice_frost_needle` | `ice_frost_needle` | `1hit`, cooldown `0.45s` | `2hit @0.05s`, cooldown `0` |
| `wind_cutter` | `wind_gale_cutter` | `1hit`, cooldown `0.20s` | `3hit @0.05s`, cooldown `0` |
| `fire_flame_arc` | `fire_flame_arc` | `1hit`, cooldown `1.4s` | `3hit @0.06s`, cooldown `0` |
| `water_tidal_ring` | `water_tidal_ring` | `1hit`, cooldown `2.0s` | `2hit @0.08s`, cooldown `0` |
| `water_wave` | `water_wave` | `1hit`, cooldown `1.45s` | `3hit @0.08s`, cooldown `0` |
| `holy_cure_ray` | `holy_cure_ray` | `1hit`, cooldown `1.4s` | `2hit @0.08s`, cooldown `0` |
| `holy_healing_pulse` | `holy_radiant_burst` | `1hit`, cooldown `0.35s` | `2hit @0.07s`, cooldown `0` |
| `lightning_thunder_lance` | `volt_spear` | `1hit`, cooldown `0.55s` | `3hit @0.05s`, cooldown `0` |
| `lightning_bolt` | `lightning_bolt` | `1hit`, cooldown `0.92s` | `4hit @0.08s`, cooldown `0` |
| `ice_spear` | `ice_spear` | `1hit`, cooldown `0.85s` | `2hit @0.08s`, cooldown `0` |
| `lightning_thunder_arrow` | `lightning_thunder_arrow` | `1hit`, cooldown `0.38s` | `3hit @0.06s`, cooldown `0` |

#### 1~4서클 설치형 / field / wall 예외

| canonical skill_id | runtime cast ID | 직전 구현 | 현재 잠금 결과 |
| --- | --- | --- | --- |
| `earth_stone_spire` | `earth_stone_spire` | `0.2s cadence`, cooldown `1.2s` | cooldown 유지, `0.2s cadence` 유지. 저서클 main deploy 예외 |
| `plant_root_bind` | `plant_vine_snare` | `1.0s cadence`, cooldown `4.5s` | cooldown 유지, `0.75s cadence`로 조정해 3초 기준 `4hit` |
| `dark_shadow_bind` | `dark_shadow_bind` | `1.0s cadence`, cooldown `6.0s` | cooldown 유지, `0.75s cadence`로 조정해 3초 기준 `4hit` |
| `ice_ice_wall` | `ice_ice_wall` | spawn burst `1hit`, cooldown `9.0s` | cooldown 유지. wall-control placeholder는 이번 턴에 cadence보다 control read를 우선한다 |

#### 5~6서클 구현 공격 스킬

| canonical skill_id | runtime cast ID | 직전 구현 | 현재 잠금 결과 |
| --- | --- | --- | --- |
| `dark_grave_echo` | `dark_grave_echo` | `1.0s cadence` | `0.6s cadence`, toggle 3초 기준 `5hit` |
| `fire_flame_storm` | `fire_flame_storm` | `1.0s cadence` | `0.6s cadence`, deploy 3초 기준 `5hit` |
| `ice_storm` | `ice_storm` | `1.0s cadence` | `0.6s cadence`, deploy 3초 기준 `5hit` |
| `wind_storm` | `wind_storm` | `1hit`, cooldown `3.4s` | `5hit @0.10s`, dedicated storm family + phase signature |
| `wind_tempest_drive` | `wind_tempest_drive` | `1hit`, cooldown `1.8s` | `3hit @0.06s` |
| `earth_fortress` | `earth_fortress` | `1.1s cadence` | 방어 pulse 유지 시 `0.6s cadence`, toggle 3초 기준 `5pulse` |
| `plant_worldroot_bastion` | `plant_worldroot_bastion` | `1.0s cadence` | `0.6s cadence`, deploy 3초 기준 `5hit` |
| `ice_absolute_freeze` | `ice_absolute_freeze` | `1hit`, cooldown `7.8s` | `4hit @0.08s` |
| `fire_inferno_buster` | `fire_inferno_buster` | `1hit`, cooldown `6.8s` | `4hit @0.08s`, dedicated inferno family + phase signature |

#### 7서클 이상 구현 공격 스킬

| canonical skill_id | runtime cast ID | 직전 구현 | 현재 잠금 결과 |
| --- | --- | --- | --- |
| `fire_meteor_strike` | `fire_meteor_strike` | `1hit`, cooldown `8.6s` | `6hit @0.06s` burst 분할 |
| `water_tsunami` | `water_tsunami` | `1hit`, cooldown `4.8s` | `6hit @0.08s`, dedicated tidal family + terminal vortex |
| `wind_cyclone_prison` | `wind_cyclone_prison` | `1.0s cadence` | `0.5s cadence`, deploy 3초 기준 `6hit` |
| `earth_gaia_break` | `earth_gaia_break` | `1hit`, cooldown `5.6s` | `6hit @0.07s` burst 분할 |
| `fire_inferno_sigil` | `fire_inferno_sigil` | `2.4s cadence` | `0.4s cadence`, deploy 3초 기준 `8hit` |
| `dark_abyss_gate` | `dark_void_bolt` | `1hit`, cooldown `0.45s` | `6hit @0.06s` pull burst 분할 |
| `fire_hellfire_field` | `fire_hellfire_field` | `1.0s cadence` | `0.5s cadence`, deploy 3초 기준 `6hit` |
| `wind_storm_zone` | `wind_storm_zone` | `1.0s cadence` | `0.5s cadence`, toggle 3초 기준 `6hit` |
| `plant_world_root` | `plant_world_root` | `1.0s cadence` | `0.5s cadence`, deploy 3초 기준 `6hit` |
| `ice_glacial_dominion` | `ice_glacial_dominion` | `1.0s cadence` | `0.5s cadence`, toggle 3초 기준 `6hit` |
| `lightning_tempest_crown` | `lightning_tempest_crown` | `1.2s cadence` | `0.4s cadence`, toggle 3초 기준 `8hit` |
| `water_ocean_collapse` | `water_ocean_collapse` | `1hit`, cooldown `9.6s` | `7hit @0.07s` burst 분할, dedicated ocean-collapse family |
| `wind_heavenly_storm` | `wind_heavenly_storm` | `1hit`, cooldown `9.2s` | `8hit @0.07s`, dedicated heavenly family + phase signature |
| `earth_quake_break` | `earth_tremor` | `1hit`, cooldown `0.90s` | `6hit @0.06s` burst 분할 |
| `earth_continental_crush` | `earth_continental_crush` | `1hit`, cooldown `9.8s` | `6hit @0.06s` burst 분할 |
| `earth_world_end_break` | `earth_world_end_break` | `1hit`, cooldown `11.0s` | `8hit @0.06s` burst 분할 |
| `fire_apocalypse_flame` | `fire_apocalypse_flame` | `1hit`, cooldown `10.4s` | `7hit @0.06s` burst 분할 |
| `fire_solar_cataclysm` | `fire_solar_cataclysm` | `1hit`, cooldown `11.2s` | `8hit @0.06s` burst 분할 |
| `ice_absolute_zero` | `ice_absolute_zero` | `1hit`, cooldown `11.1s` | `8hit @0.06s` burst 분할 |
| `wind_sky_dominion` | `wind_sky_dominion` | `0.9s cadence` | `0.45s cadence`, toggle 3초 기준 `6hit` |
| `plant_genesis_arbor` | `plant_genesis_arbor` | `1.0s cadence` | `0.4s cadence`, deploy 3초 기준 `8hit` |
| `dark_soul_dominion` | `dark_soul_dominion` | `1.0s cadence` | `0.4s cadence`, toggle 3초 기준 `8hit` |
| `holy_judgment_halo` | `holy_judgment_halo` | `1hit`, cooldown `8.5s` | `6hit @0.06s` burst 분할 |

## 코어 서클 라인업

4서클부터는 기본 4속성 라인이 각자의 서브 속성 성격을 일부 끌어오기 시작한다. 즉, `불 라인 -> 전기 활용`, `물 라인 -> 얼음 활용`, `대지 라인 -> 자연(풀) 활용`, `바람 라인 -> 유틸/가속 특화`가 본격화된다. 백마법은 별도 지원 라인으로 유지한다.

비고:
- 아래 라인업 표는 장기 서클 roster와 컨셉 기준선이다.
- 이미 구현된 공격 스킬의 `2026-04-07 다단히트 / 무쿨 / cadence` 세부 수치는 바로 위 운영 규칙 표를 우선한다.

### 1서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 파이어 볼트 | 액티브 / 발사형 / 단일 | 약한 딜, 짧은 쿨, 기본 DPS 유지용 | 8 MP, 0.42초, `(마공 x 1.00) + 10` | 계수 `+0.022`, 고정치 `+2`, 사거리 `+0.8%` |
| 물 라인 | 워터 불릿 | 액티브 / 발사형 / 단일 | 낮은 피해 + 미세 둔화 | 8 MP, 0.46초, `(마공 x 0.96) + 9` | 계수 `+0.021`, 고정치 `+2`, 둔화 지속 `+1%` |
| 바람 라인 | 윈드 애로우 | 액티브 / 발사형 / 유틸 | 히트 시 약한 넉백을 주는 스타터 | 9 MP, 0.48초, `(마공 x 0.92) + 9` | 계수 `+0.02`, 고정치 `+1`, 넉백 거리 `+1%` |
| 대지 라인 | 스톤 샷 | 액티브 / 발사형 / 단일 | 느리지만 단일 피해가 더 높은 묵직한 기본기 | 10 MP, 0.72초, `(마공 x 1.18) + 14` | 계수 `+0.024`, 고정치 `+2`, 투사체 속도 `+0.5%` |
| 백마법 | 헤일로 터치 | 액티브 / 단일 회복 | 짧은 단일 회복과 약한 정화 | 10 MP, 3.5초, `회복 = (마공 x 0.95) + 18` | 회복 계수 `+0.018`, 고정치 `+2` |

### 2서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 플레임 불릿 | 액티브 / 발사형 / 연사 | 연사형 화염탄으로 단일 DPS 상승 | 12 MP, 0.34초, `(마공 x 0.90) + 8` | 계수 `+0.02`, 고정치 `+1`, 10/20/30레벨 투사체 수 +1 |
| 물 라인 | 아쿠아 스피어 | 액티브 / 라인 / 관통 | 관통하는 라인 공격, 중간 쿨 | 14 MP, 1.1초, `(마공 x 1.28) + 18` | 계수 `+0.028`, 고정치 `+2`, 관통 길이 `+0.8%` |
| 바람 라인 | 거스트 볼트 | 액티브 / 발사형 / 유틸 | 강화된 밀어내기로 거리 조절 | 13 MP, 0.55초, `(마공 x 1.12) + 14` | 계수 `+0.024`, 고정치 `+2`, 넉백 거리 `+1%` |
| 대지 라인 | 락 스피어 | 액티브 / 발사형 / 디버프 | 중간 피해와 방어 감소 디버프 | 15 MP, 1.25초, `(마공 x 1.30) + 19` | 계수 `+0.03`, 고정치 `+2`, 방어 감소 지속 `+1%` |
| 백마법 | 마나 베일 | 버프 / 보호 | 피해 감소 + 경직 안정화 | 16 MP, 24초, 4초 지속, 직접 피해 없음 | 지속시간 `+1%`, 피해 감소량 `+0.2%p`, poise `+1` |

### 3서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 파이어 버스트 | 액티브 / 원형 burst / AoE | 범위 폭발로 광역 입문 | 18 MP, 1.8초, `(마공 x 1.55) + 24` | 계수 `+0.034`, 고정치 `+3`, 반경 `+0.8%` |
| 물 라인 | 워터 웨이브 | 액티브 / 범위 / 소프트 CC | 광역 둔화로 안정적인 제어 시작 | 19 MP, 1.9초, `(마공 x 1.42) + 22` | 계수 `+0.032`, 고정치 `+3`, 둔화 지속 `+1%` |
| 바람 라인 | 윈드 커터 | 액티브 / 직선 / 다단 | 다수 타격 가능한 빠른 풍압 참격 | 18 MP, 0.92초, `(마공 x 1.38) + 20` | 계수 `+0.03`, 고정치 `+3`, 12/24레벨 추가 타격 +1 |
| 대지 라인 | 어스 스파이크 | 설치형 / burst | 지면에서 솟아오르는 설치형 타격 | 20 MP, 3.4초, `(마공 x 1.48) + 23` | 계수 `+0.032`, 고정치 `+3`, 범위 `+0.8%` |
| 백마법 | 큐어 레이 | 액티브 / 직선 회복 | 전방 직선 아군 회복과 약한 정화 | 20 MP, 7초, `회복 = (마공 x 1.10) + 24` | 회복 계수 `+0.02`, 고정치 `+3` |

### 4서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불/전기 라인 | 라이트닝 볼트 | 액티브 / 연쇄 / 중단거리 | 강한 딜과 4연쇄 분할 타격 | 23 MP, `0초`, 총합 피해 `26`, `4hit @0.08s` | 연쇄 감각 유지, 총합 피해는 유지하고 1히트당 분할 |
| 물/얼음 라인 | 아이스 스피어 | 액티브 / 발사형 / 단일 | 빙결 확률을 가진 무쿨 관통 창 | 22 MP, `0초`, 총합 피해 `24`, `2hit @0.08s` | 빙결 확률 유지, 총합 피해는 유지하고 1히트당 분할 |
| 바람/전기 활용 라인 | 썬더 애로우 | 액티브 / 관통 / 짧은 쿨 | 빠른 관통과 감전 부여 | 21 MP, `0초`, 총합 피해 `22`, `3hit @0.06s` | 감전 운용 유지, 총합 피해는 유지하고 1히트당 분할 |
| 대지/자연 라인 | 루트 바인드 | 설치형 / CC | 약한 피해와 핵심 속박 유틸 | 22 MP, 6.0초, `틱 피해 = (마공 x 0.42) + 7` | 틱 계수 `+0.008`, 지속 `+1%`, 속박 지속 `+1%` |
| 백마법 | 힐링 펄스 | 액티브 / 원형 회복 | 즉시 회복과 짧은 안정화 | 24 MP, 10초, `회복 = (마공 x 1.40) + 35` | 회복 계수 `+0.02`, 고정치 `+3` |

### 5서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 플레임 스톰 | 설치형 / 지속 AoE | 지속 화염으로 광역 중상급 압박 | 28 MP, 8초, `0.6초 cadence`, 3초 기준 `5hit` | 총합 피해 유지 기준으로 틱당 피해 분할, 반경 성장 유지 |
| 물/얼음 라인 | 아이스 스톰 | 설치형 / 지속 CC | 지속 피해와 빙결 압박 | 29 MP, 9초, `0.6초 cadence`, 3초 기준 `5hit` | 총합 피해 유지 기준으로 틱당 피해 분할, 빙결 압박 유지 |
| 바람 라인 | 윈드 스톰 | 액티브 / 다단 / 중거리 | 다단 히트 중심의 범위 제압 | 30 MP, 3.4초, 총합 피해 `40`, `5hit @0.10s` | 대표 다단기, 총합 피해는 유지하고 1히트당 분할 |
| 바람 기동 라인 | 템페스트 드라이브 | 액티브 / 이동기 / 돌진 | 전방 중거리 돌진 후 소형 바람 충격파를 연속 분할 | 28 MP, 1.8초, 총합 피해 `32`, `3hit @0.06s` | 이동 burst 감각 유지, 짧은 분할 히트로 타격감 강화 |
| 대지 라인 | 퀘이크 브레이크 | 액티브 / 광역 burst / CC | 강한 광역 타격과 짧은 기절 | 32 MP, 9.5초, `(마공 x 2.20) + 34` | 계수 `+0.044`, 고정치 `+4`, 기절 지속 `+1%` |
| 백마법 | 블레스 필드 | 설치형 / 힐 장판 | 소규모 치유 장판과 상태이상 완화 | 30 MP, 18초, `초당 회복 = (마공 x 0.36) + 8` | 회복 계수 `+0.01`, 지속 `+1%`, 반경 `+0.8%` |

### 6서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 인페르노 버스터 | 액티브 / 광역 burst | 큰 범위 폭발의 전투 중심 극딜기 | 38 MP, 6.8초, 총합 피해 `48`, `4hit @0.08s` | burst 무게감 유지용 짧은 분할 히트, 반경 성장 유지 |
| 물/얼음 라인 | 앱솔루트 프리즈 | 액티브 / 광역 CC | 광역 얼림 중심의 중간 딜 기술 | 36 MP, 7.8초, 총합 피해 `42`, `4hit @0.08s` | 얼림 중심 CC 감각 유지, 총합 피해는 유지하고 1히트당 분할 |
| 대지 라인 | 어스 포트리스 | 토글 / 방어 / 반격장 | 방어력과 슈퍼아머를 끌어올리며 근접 적에게 지속 타격 | 시전 13 MP, 유지 5 MP/s, 1초, `0.6초 cadence`, 3초 기준 `5hit` | 방어 유틸 유지, 공격 tick은 cadence만 상향하고 총합 기대 피해 보정 |
| 백마법 | 크리스탈 이지스 | 버프 / 방어 | 고등 방어 강화와 상태 안정화 | 34 MP, 40초, 10초 지속, 직접 피해 없음 | 지속 `+1%`, 피해 감소 `+0.4%p`, 상태 저항 `+0.3%p` |

### 7서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 메테오 스트라이크 | 액티브 / 딜레이 burst | 딜레이 후 초고폭딜 낙하 메테오 | 44 MP, 8.6초, 총합 피해 `54`, `6hit @0.06s` | 한 방 체감 유지용 짧은 분할 히트, 폭발 반경 성장 유지 |
| 물 라인 | 쓰나미 | 액티브 / 광역 제어 | 밀어내기와 광역 압박을 겸한 대파도 | 34 MP, 4.8초, 총합 피해 `40`, `6hit @0.08s` | 파도 압박감을 살리는 연속 타격, 총합 피해는 유지 |
| 바람 라인 | 사이클론 프리즌 | 설치형 / CC | 적을 가두는 회오리 감옥 | 36 MP, 10초, `0.5초 cadence`, 3초 기준 `6hit` | 구속 유지, 지속 타격 체감 강화 |
| 대지 라인 | 가이아 브레이크 | 액티브 / 광역 붕괴 | 넓은 범위의 지면 붕괴 | 42 MP, 5.6초, 총합 피해 `52`, `6hit @0.07s` | 붕괴 burst 무게감 유지용 짧은 분할 히트 |
| 백마법 | 생츄어리 오브 리버설 | 설치형 / 회복/정화 | 회복과 정화 성역 | 40 MP, 24초, `초당 회복 = (마공 x 0.55) + 12` | 회복 계수 `+0.01`, 지속 `+1%`, 반경 `+0.8%` |

### 8서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 헬파이어 필드 | 설치형 / 장판 AoE | 강한 딜을 누적하는 지속 장판 | 46 MP, 18초, `0.5초 cadence`, 3초 기준 `6hit` | 장판 누적 딜 감각 강화, 총합 기대 피해는 cadence 보정 |
| 물/얼음 라인 | 프로즌 도메인 | 토글 / 필드 CC | 범위 CC 필드로 얼림 전초전 형성 | 시전 12 MP, 유지 4 MP/s, 1초, `0.5초 cadence`, 3초 기준 `6hit` | 둔화/빙결 강화, 공격 tick은 cadence 보정 |
| 바람 라인 | 스톰 존 | 토글 / 제어 존 | 둔화와 inward draft로 적을 묶는 폭풍 제어 존 | 시전 12 MP, 유지 5 MP/s, 1초, `0.5초 cadence`, 3초 기준 `6hit` | 반경 `+0.8%`, inward draft `+1.0%`, target milestone 확장 |
| 대지/자연 라인 | 월드 루트 | 설치형 / 광역 속박 | 광역 속박과 누적 자연 피해 | 42 MP, 18초, `0.5초 cadence`, 3초 기준 `6hit` | 속박 유지, 누적 피해는 cadence 보정으로 다단 체감 강화 |
| 백마법 | 세라프 코러스 | 토글 / 오라 / 공격-지원 혼합 | 성광 파동으로 적을 타격하면서 시전자를 치유/안정화하는 최종 holy aura | 시전 13 MP, 유지 5 MP/s, 1.1초 cadence, holy pulse 피해 + self-heal + `poise_bonus` | 반경 `+0.8%`, 피해/치유 동시 성장, target milestone 확장, stability 강화 |

### 9서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 아포칼립스 플레임 | 액티브 / 광역 극딜 | 매우 긴 쿨의 광역 대폭발 | 56 MP, 10.4초, 총합 피해 `68`, `7hit @0.06s` | 초중량 burst를 짧은 연속 히트로 분할해 체감 한 방 유지 |
| 물 라인 | 오션 콜랩스 | 액티브 / 광역 제압 | 광역으로 밀어눌러 전장을 붕괴 | 52 MP, 9.6초, 총합 피해 `52`, `7hit @0.07s` | 파도 붕괴 감각 유지, 총합 피해는 유지 |
| 바람 라인 | 헤븐리 스톰 | 액티브 / 다단 / 광역 | 광역 다단 히트 중심의 전략 궁극 | 50 MP, 9.2초, 총합 피해 `60`, `8hit @0.07s` | 상위 서클 다단 대표기, 타격 수 체감 우선 |
| 대지 라인 | 컨티넨탈 크러시 | 액티브 / 광역 극딜 | 지형 파괴급 대지 충돌 | 54 MP, 9.8초, 총합 피해 `64`, `6hit @0.06s` | 초중량 붕괴 감각 유지용 짧은 분할 히트 |
| 백마법 | 던 오스 | 버프 / 보호 | 대형 보호막과 짧은 무력화 면역 | 52 MP, 55초, 8초 지속, 직접 피해 없음 | 지속 `+1%`, 보호막 계수 `+0.02`, 정화 강도 증가 |

### 10서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 솔라 카타클리즘 | 액티브 / 궁극기 | 필드 전체를 타격하는 초중량 최종기 | 62 MP, 11.2초, 총합 피해 `74`, `8hit @0.06s` | 필드 전역 폭발 체감은 유지하고 짧은 연속 히트로 분할 |
| 물/얼음 라인 | 앱솔루트 제로 | 액티브 / 궁극기 / CC | 광역 완전 정지에 가까운 최종 냉기 기술 | 61 MP, 11.1초, 총합 피해 `70`, `8hit @0.06s` | 냉기 궁극 체감 유지, 총합 피해는 유지 |
| 바람 라인 | 스카이 도미니언 | 토글 / 궁극 공격 | 공중 지배와 지속 공격을 여는 숙련자 궁극 토글 | 시전 16 MP, 유지 6.5 MP/s, 1초, `0.4초 cadence`, 3초 기준 `8hit` | 궁극 유틸+공격 혼합형, 지속 타격 체감 우선 |
| 대지 라인 | 월드 엔드 브레이크 | 액티브 / 궁극기 / 광역 극딜 | 초광역 붕괴를 일으키는 최종 대지 기술 | 60 MP, 11.0초, 총합 피해 `72`, `8hit @0.06s` | 초광역 붕괴 감각을 짧은 연속 히트로 분할 |
| 백마법 | 저지먼트 헤일로 | 액티브 / 빛 burst 지원 | 회복과 심판을 동시에 여는 최종 백마법 | 62 MP, 8.5초, 공격 총합 피해 `78`, `6hit @0.06s` | 공격 파트는 burst 분할, 회복 파트는 기존 감각 유지 |

## 서브 속성 및 흑마법 대표 라인

상단 코어 라인보다 한 단계 보조적인 성장축이다. 동일 컨셉의 기술이 상단 코어 라인에 새 이름으로 들어갔다면 상단 코어 라인을 우선한다.

### 전기 라인

| 서클 | 이름 | 타입 | 컨셉 | 기본 수치 | 성장 |
| --- | --- | --- | --- | --- | --- |
| 4 | 라이트닝 볼트 | 액티브 / 연쇄 | 무쿨 4연쇄 대표기 | 23 MP, `0초`, 총합 피해 `26`, `4hit @0.08s` | 연쇄 수 감각 유지, 총합 피해는 유지 |
| 4 | 썬더 애로우 | 액티브 / 관통 / 짧은 쿨 | 무쿨 3연타 관통기 | 21 MP, `0초`, 총합 피해 `22`, `3hit @0.06s` | 감전 감각 유지, 총합 피해는 유지 |
| 5 | 컨덕티브 서지 | 버프 / 폭딜 보조 | 연쇄/감전 burst 보조 | 30 MP, 38초, 7초 지속 | 지속 `+1%`, 연쇄 보너스 강화 |
| 9 | 템페스트 크라운 | 토글 / 오라 | 자동 낙뢰와 연쇄 공격 | 시전 14 MP, 유지 6 MP/s, 1초, `0.4초 cadence`, 3초 기준 `8hit` | 자동 낙뢰 체감 우선, cadence 보정으로 총합 기대 피해 정렬 |

### 얼음 라인

| 서클 | 이름 | 타입 | 컨셉 | 기본 수치 | 성장 |
| --- | --- | --- | --- | --- | --- |
| 4 | 아이스 스피어 | 액티브 / 발사형 | 빙결 확률을 가진 단일 제어 창 | 22 MP, 1.35초, `(마공 x 1.34) + 21` | 계수 `+0.03`, 빙결 확률 `+0.5%p` |
| 5 | 아이스 스톰 | 설치형 / 지속 CC | 지속 피해와 빙결 압박 | 30 MP, 13초, `틱 피해 = (마공 x 0.78) + 12` | 틱 계수 `+0.011`, 지속 `+1%` |
| 6 | 앱솔루트 프리즈 | 액티브 / 광역 CC | 광역 얼림 중심 기술 | 38 MP, 16초, `(마공 x 1.58) + 24` | 계수 `+0.03`, 빙결 지속 `+1%` |
| 8 | 프로즌 도메인 | 설치형 / 필드 CC | 범위 CC 필드 | 48 MP, 18초, `틱 피해 = (마공 x 0.82) + 13` | 틱 계수 `+0.012`, 지속 `+1%` |
| 10 | 앱솔루트 제로 | 액티브 / 궁극기 | 광역 완전 정지형 최종 냉기 기술 | 61 MP, 11.1초, 총합 피해 `70`, `8hit @0.06s` | 상위 냉기 burst를 짧은 연속 히트로 분할 |

### 자연(풀) 라인

| 서클 | 이름 | 타입 | 컨셉 | 기본 수치 | 성장 |
| --- | --- | --- | --- | --- | --- |
| 4 | 루트 바인드 | 설치형 / CC | 약한 피해와 핵심 속박 유틸 | 22 MP, 6.0초, `틱 피해 = (마공 x 0.42) + 7` | 틱 계수 `+0.008`, 지속 `+1%`, 속박 지속 `+1%` |
| 6 | 월드루트 바스천 | 설치형 / 장기전 | 구속 + 누적 피해 성채 | 36 MP, 14초, `틱 피해 = (마공 x 0.88) + 14` | 계수 `+0.014`, 대상 수 milestone |
| 7 | 버던트 오버플로 | 버프 / 설치 빌드 증폭 | 설치형 빌드 burst 창구 | 40 MP, 48초, 12초 지속 | 지속 `+1%`, 설치형 시너지 강화 |
| 8 | 월드 루트 | 설치형 / 광역 속박 | 광역 속박과 자연 누적 피해 | 48 MP, 19초, `틱 피해 = (마공 x 0.68) + 11` | 틱 계수 `+0.011`, 지속 `+1%` |
| 10 | 제네시스 아버 | 설치형 / 최종 장기전 | 광역 구속 + 연속 타격 + 흡수 | 60 MP, 28초, `틱 피해 = (마공 x 1.28) + 20` | 계수 `+0.02`, 대상 수 10/20/30 +1 |

### 흑마법 라인

| 서클 | 이름 | 타입 | 컨셉 | 기본 수치 | 성장 |
| --- | --- | --- | --- | --- | --- |
| 3 | 섀도우 바인드 | 설치형 / 디버프 | 둔화 + 지속 피해 | 22 MP, 6초, `틱 피해 = (마공 x 0.52) + 8` | 계수 `+0.011`, 대상 수 10/20/30 +1 |
| 5 | 그레이브 에코 | 토글 / 저주 오라 | 지속 저주와 누적 압박 | 초당 8 MP, 1초, `틱 피해 = (마공 x 0.70) + 10` | 계수 `+0.012`, 반경 `+0.8%` |
| 6 | 그레이브 팩트 | 버프 / 리스크 | HP/방어를 대가로 흑마법 증폭 | 34 MP, 42초, 8초 지속 | 지속 `+1%`, 리스크/배수 강화 |
| 8 | 어비스 게이트 | 액티브 / pull burst | 끌어당긴 뒤 폭발 | 48 MP, 20초, `(마공 x 2.75) + 44` | 계수 `+0.055`, 대상 수 10/20/30 +1 |
| 10 | 소울 도미니언 | 토글 / 룰 브레이크 | 규칙 변조, 하이리스크 피니셔 | 초당 18 MP, 45초, `틱 피해 = (마공 x 1.65) + 26` | 계수 `+0.022`, 대상 수 10/20/30 +1 |
| 10 | 스론 오브 애시 | 버프 / 의식 피니셔 | 흑마법 + 불 최종 배수 강화 | 64 MP, 90초, 6초 지속 | 지속 `+1%`, 최종 배수 강화 |

## 2026-04-06 신규 이펙트 자산 연동 메모

이번 라운드는 `asset_sample/Effect/new`의 실제 이펙트 시트를 기준으로 기존 스킬 기획과의 연결 방향을 잠근다. 압축 파일은 제외했고, 시트 흐름과 프레임 구성을 함께 봤다.

### 즉시 적용 우선 조합

| 에셋군 | 우선 대상 | 현재 runtime anchor | 판단 |
| --- | --- | --- | --- |
| `Dark VFX 1-2` | `dark_abyss_gate` | `dark_void_bolt` | 흑구체 투사체와 붕괴 hit가 현재 pull burst proxy와 가장 가깝다. 우선 projectile / hit 교체부터 잠근다 |
| `Thunder Effect 01-02` | `lightning_thunder_lance` | `volt_spear` | 직선 랜스와 impact strike의 역할 분리가 명확해 관통 burst 가독성이 좋다. 2026-04-09 follow-up으로 canonical hotbar payload, fast narrow lance contract, milestone pierce regression까지 함께 잠갔다 |
| `PixelHolyEffectsPack01/Heal`, `HolyNova` | `holy_healing_pulse` | `holy_radiant_burst` | 회복 burst read가 명확하다. 회복 표식과 solo-runtime self-heal rider를 함께 쓰는 것을 기본값으로 잠근다 |
| `PixelHolyEffectsPack01/HolyShield` | `holy_crystal_aegis` | 현재 runtime에서는 `holy_mana_veil`, `holy_dawn_oath`에 같은 family 확장 적용 가능 | 방어/보호막 스킬임이 즉시 읽히므로 백마법 방어군 기본 실루엣으로 잠근다 |

`Water Effect 2 -> water_bullet`, `Wind Effect 01 -> wind_cutter`는 저위험 visual refresh 후보였고, 2026-04-06 follow-up에서 실제 runtime attach까지 완료했다. `water_aqua_bullet`는 `WaterBall` startup / projectile loop / impact family로, `wind_gale_cutter`는 `Wind Projectile` / `Wind Hit Effect` family로 교체했다.

### 2026-04-06 보완안 실제 연결 결과

| 대상 스킬 | 적용 에셋 | 실제 연결 결과 |
| --- | --- | --- |
| `earth_stone_spire` | `Earth Effect 01` | deploy startup 균열은 `earth_stone_spire_attack`, 본체 솟구침은 `earth_stone_spire`, 반복 타격 impact는 `earth_stone_spire_hit`으로 분리 연결했다. 2026-04-09 follow-up으로 deploy runtime contract, level scaling, grounded cone-burst representative regression까지 닫아 verified 승격을 마쳤다 |
| `earth_quake_break` | `Earth Effect 01`, `Earth Effect 02/Earth Bump` | runtime proxy `earth_tremor`의 startup을 `Earth Bump` 균열 계열로, hit를 `Impact` strip으로 재배정해 광역 균열 burst read를 실제 연결했다. startup effect는 중심 정렬로 고정해 `stone_spire`와 읽힘을 분리했고, 2026-04-09 follow-up으로 dedicated `phase_signature = earth_tremor`와 level scaling regression까지 함께 잠갔다 |
| `fire_flame_arc` | `Fire Effect 2` | `spells.json` runtime spell row를 추가하고, 정지형 원형 burst `fire_flame_arc` 16프레임 시퀀스를 메인 visual로 연결했다 |
| `fire_inferno_sigil` | `Fire Effect 2` | startup `fire_inferno_sigil_attack`, 지속 loop `fire_inferno_sigil`, 반복 타격 `fire_inferno_sigil_hit`, 종료 burst `fire_inferno_sigil_end` 4단 family를 실제 deploy runtime에 연결했고, 2026-04-07 follow-up으로 `0.4s` cadence의 8-hit inferno pulse와 cadence-normalized tick damage 기준을 반영했다 |
| `holy_cure_ray` | `PixelHolyEffectsPack01/Heal`, `Holy VFX 01-02` | 시전자 heal glyph `holy_cure_ray_attack`, 직선 ray `holy_cure_ray`, impact flash `holy_cure_ray_hit`을 실제 연결했다. 현재 solo runtime 한계상 self-heal rider를 함께 쓴다 |
| `holy_judgment_halo` | `Smite`, `SwordOfJustice`, `HeavensFury` | startup `holy_judgment_halo_attack`, main judgment `holy_judgment_halo`, hit burst `holy_judgment_halo_hit`, closing burst `holy_judgment_halo_end`까지 실제 연결했다. 2026-04-10 follow-up으로 dedicated `phase_signature = holy_judgment_halo`와 level 1 대비 level 30 damage/range/target scaling regression까지 함께 잠가 verified stationary final burst 기준을 닫았다 |
| `ice_frost_needle` | `Ice Effect 01 - VFX1` | canonical/runtime 정리를 끝내고 `ice_frost_needle_attack`, `ice_frost_needle`, `ice_frost_needle_hit` 3단 family를 실제 projectile runtime에 연결했다 |
| `water_tidal_ring` | `Water Effect 01` | `Water StartUp` ring과 `Water Splash`를 조합해 `water_tidal_ring_attack`, `water_tidal_ring`, `water_tidal_ring_hit` family를 실제 stationary burst runtime에 연결했다. 2026-04-09 follow-up으로 `knockback_scale_per_level` authored field를 `GameState.get_spell_runtime("water_tidal_ring")` 중앙 active runtime contract에 연결했고, cast payload sync와 실제 hit push regression까지 함께 잠갔다 |
| `wind_cyclone_prison` | `Wind Effect 02` | canonical deploy row를 실제 추가하고, 준비 `attack`, 유지 `loop`, 반복 hit, 종료 `end`, `pull_strength` payload를 함께 연결했다. 2026-04-09 follow-up으로 `GameState.get_data_driven_skill_runtime()`가 `duration / size / pull_strength / target_count`를 중앙 deploy runtime contract로 보장하고, representative regression도 level scaling + pull/terminal read까지 함께 잠갔다 |
| `ice_frozen_domain` | `Ice Effect 01 - VFX2` | canonical alias는 유지하되 runtime proxy `ice_glacial_dominion` 위에 `activation / loop / end` toggle visual family를 실제 연결했다. 2026-04-09 follow-up 기준 damage/size/target scaling과 slow 유지 regression까지 verified proxy contract로 잠겼다 |

### 기획 보완 / 보류 메모

| 대상 스킬 | 권장 에셋 | 보완 메모 |
| --- | --- | --- |
| `ice_ice_wall` | `ice_ice_wall` dedicated family | checked-in `ice_ice_wall_attack / ice_ice_wall / ice_ice_wall_hit / ice_ice_wall_end` family와 wall 전용 phase signature를 current runtime source of truth로 잠근다. art refresh는 더 강한 장벽 read가 필요할 때만 후속 교체 대상으로 검토한다 |

### 기존 팩 fallback 임시 적용 원칙

`img2img` 재생성 전까지는 `asset_sample/Effect/new` 외에 기존 `asset_sample/Effect` 팩도 임시 placeholder 소스로 허용한다. 이 단계의 목표는 완성형 아트가 아니라 `역할 판독`과 `테스트 가능 상태`다.

| family | 우선 소스 | 임시 적용 원칙 |
| --- | --- | --- |
| 저서클 투사체 / 관통기 | `Everything/Classic`, `Alternative 1-3`, `FXpack13`, `Fx_pack` | 속성별 hue shift와 `alpha 0.80~0.90` 보정으로 `wind_arrow`, `earth_stone_shot`, `holy_halo_touch`, `fire_flame_bullet`, `water_aqua_spear`, `wind_gust_bolt`, `earth_rock_spear`, `ice_spear`, `lightning_thunder_arrow`를 우선 덮는다 |
| 장판 / 설치형 field | `Free/Part 1`, `Part 10`, `Part 14` | startup ring, loop flame/halo, end burst를 분리해 `fire_flame_storm`, `holy_bless_field`, `holy_sanctuary_of_reversal`, `fire_hellfire_field`의 기본 read를 먼저 확보한다 |
| 오라 / 토글 / 버프 overlay | `Free/Part 13`, `Part 14` | activation은 밝게, 유지 loop는 `alpha 0.40~0.55`로 낮춰 `earth_fortress`, `wind_storm_zone`, `holy_seraph_chorus`, `lightning_tempest_crown`, `dark_soul_dominion`을 임시 잠근다 |
| 자연 / 얼음 분출 / CC | `Free/Part 4`, `Part 11`, `Part 15` | `plant`는 뿌리/식생 문양, `ice`는 서리 십자/빙결 pulse로 재해석해 `ice_storm`, `ice_absolute_freeze`, `plant_world_root`, `plant_genesis_arbor`를 먼저 테스트 가능 상태로 만든다 |
| 대형 burst / 궁극기 | `FXpack13`, `Fx_pack`, `Free/Part 10`, `Part 14` | 원형 core burst + 잔류 flame/halo 조합으로 `fire_meteor_strike`, `fire_apocalypse_flame`, `earth_continental_crush`, `fire_solar_cataclysm`의 family를 분리한다. 2026-04-10 follow-up으로 `fire_meteor_strike_*`, `fire_apocalypse_flame_*`, `fire_solar_cataclysm_*`, `earth_gaia_break_*`, `earth_continental_crush_*`, `earth_world_end_break_*`는 checked-in dedicated family를 runtime source of truth로 사용하며, `earth_continental_crush`를 포함한 earth/final burst row는 전용 phase signature와 level scaling regression 기준까지 verified 승격을 마쳤다 |

`ice_ice_wall`은 현재 checked-in `ice_ice_wall_*` family와 wall 전용 phase signature를 source of truth로 사용한다. 초기 direct attach 출발점은 blue tremor recolor였지만, 현재 runtime에서는 장벽 전용 경로와 회귀 테스트를 가진 dedicated family로 취급한다.

`ice_ice_wall` acceptance 기준은 아래처럼 잠근다.

- 생성/유지/파괴 3단이 명확히 분리되어야 한다. 현재 runtime은 `ice_ice_wall_attack / ice_ice_wall / ice_ice_wall_end`로 이 조건을 충족한다.
- 유지 구간 기준 최소 가시 폭은 플레이어 2.2명 이상, 높이는 플레이어 1.3명 이상으로 읽혀야 한다.
- 첫 프레임 0.20초 안에 `장벽이 세워진다`는 판단이 가능해야 하고, 일반 원형 field나 세로 기둥으로 오독되면 실패다.
- 장벽 중앙보다 양 끝 실루엣이 먼저 죽지 않아야 한다. 벽 끝이 사라지면 통로 차단 read가 무너진다.
- loop alpha는 낮춰도 되지만, silhouette edge contrast는 유지해야 한다. 내부 안개형 연출은 허용해도 외곽선이 녹아선 안 된다.
- 접촉 시 `slow + short root` control rider가 실제 runtime payload와 enemy status path에 함께 전달되어야 한다.
- level 30 runtime은 level 1 대비 wall duration과 size가 모두 증가해야 하며, regression test로 이를 잠근다.
- 현재 dedicated family 하한선은 centered startup, `loop fps 7`, `scale 1.70`, `terminal collapse`, `phase_signature = ice_ice_wall`까지 포함한다. 이후 art refresh는 이 장벽 read를 넘길 때만 교체 승인한다.

2026-04-06 fallback projectile / line 1차 연결 결과:

- `wind_arrow`, `wind_gust_bolt`는 wind placeholder projectile family를 공유하며 실제 active runtime에 연결했다.
- `earth_stone_shot`, `earth_rock_spear`는 sepia stone projectile + impact placeholder family를 실제 연결했다.
- `holy_halo_touch`는 halo projectile family와 self-heal rider를 함께 써 현재 solo runtime에서도 역할이 읽히도록 맞췄다.
- `fire_flame_bullet`, `water_aqua_spear`, `ice_spear`, `lightning_thunder_arrow`도 각 속성 placeholder family와 split effect attack/hit을 실제 연결했다.
- 이 파동은 `asset_sample/Effect` 기반 임시 family를 쓰는 단계이며, 최종 미술 기준선은 이후 `img2img` 재생성본으로 교체한다.

2026-04-06 fallback field / aura 2차 연결 결과:

- `fire_flame_storm`은 2026-04-09 follow-up 기준 checked-in `fire_flame_storm_attack / fire_flame_storm / fire_flame_storm_hit / fire_flame_storm_end` dedicated field family를 실제 visual source of truth로 사용하고, `0.6s` cadence와 damage/duration/size/target scaling까지 함께 잠겼다. `fire_hellfire_field`도 같은 날짜 follow-up 기준 checked-in `fire_hellfire_field_attack / fire_hellfire_field / fire_hellfire_field_hit / fire_hellfire_field_end` dedicated field family와 `0.5s` cadence + large-field scaling contract까지 함께 잠겼다.
- `holy_sanctuary_of_reversal`은 2026-04-09 follow-up으로 `holy_sanctuary_of_reversal_attack / holy_sanctuary_of_reversal / holy_sanctuary_of_reversal_hit / holy_sanctuary_of_reversal_end` dedicated sanctuary family를 실제 deploy runtime source of truth로 승격했다.
- `holy_sanctuary_of_reversal`은 현재 `self_heal + damage_taken_multiplier + poise_bonus` reversal survival contract, owner-inside heal/guard window, owner-leave expiry representative regression, dedicated `phase_signature = holy_sanctuary_of_reversal` ground telegraph까지 닫혀 있다. current verified baseline은 장기 회복 성역이 아니라 짧은 반전 창구다.
- `lightning_tempest_crown`은 2026-04-09 follow-up 기준 checked-in `tempest_crown_activation / loop / end` dedicated toggle family를 실제 visual source of truth로 사용하고, `0.4s` cadence와 damage/size/target/pierce scaling까지 함께 잠겼다. `dark_soul_dominion`은 같은 날짜 follow-up 기준 checked-in `soul_dominion_activation / loop / end / aftershock / clear` 5-stage family를 사용한다.
- 이 파동의 목적은 최종 아트가 아니라 `field / aura` 역할 판독, payload contract, representative regression을 먼저 잠그는 데 있다.

2026-04-06 fallback field / aura 3차 연결 결과:

- `holy_bless_field`는 2026-04-09 follow-up으로 `holy_bless_field_attack / holy_bless_field / holy_bless_field_hit / holy_bless_field_end` dedicated blessing family를 실제 deploy runtime source of truth로 승격했다.
- `wind_storm_zone`은 2026-04-09 follow-up으로 `wind_storm_zone_activation/loop/end` dedicated family를 실제 toggle visual source of truth로 승격했다.
- `holy_seraph_chorus`는 2026-04-09 follow-up으로 `holy_seraph_chorus_activation/loop/end` dedicated family를 실제 toggle visual source of truth로 승격해 gold-white chorus activation/overlay/end read를 잠갔다.
- `holy_bless_field`는 현재 `self_heal + poise_bonus` support field contract, owner-inside tick / owner-leave expiry representative regression, dedicated `phase_signature = holy_bless_field` ground telegraph까지 닫혀 있다. solo runtime 제약상 ally-facing 전체 파티 지원으로 확장되기 전까지는 owner-facing heal/stability field를 current verified baseline으로 본다.
- `wind_storm_zone`은 현재 `slow + pull_strength` enemy control zone contract와 dedicated storm-zone family를 사용한다. level 1 대비 level 30 damage/size/pull/target scaling, core enemy archetype slow/pull regression까지 닫힌 현재 baseline은 verified다.
- `holy_seraph_chorus`는 현재 `damage + self_heal + poise_bonus` mixed holy aura contract, 같은 pulse의 owner-heal/enemy-damage representative regression, toggle off 후 support expiry regression까지 닫혀 있다. solo runtime 제약상 ally-facing 전체 파티 오라로 확장되기 전까지는 owner-facing 공격-지원 혼합 오라를 current verified baseline으로 본다.
- 이 파동에서 `holy_bless_field`, `wind_storm_zone`, `holy_seraph_chorus`은 각각 verified support/control/mixed-aura baseline까지 닫혔다.

2026-04-06 fallback field / aura 4차 연결 결과:

- `ice_storm`은 2026-04-09 follow-up으로 `ice_storm_attack/loop/hit/end` dedicated frost-storm family를 실제 deploy runtime source of truth로 승격해 냉기 장판 read와 `slow + freeze` verified control contract를 잠갔다.
- `earth_fortress`는 2026-04-09 follow-up으로 `earth_fortress_activation/loop/end` family를 실제 toggle visual source of truth로 승격해 brown earth fortress read와 on/off overlay contract를 잠갔다.
- `plant_world_root`는 2026-04-09 follow-up으로 `plant_world_root_attack/loop/hit/end` dedicated world-root family를 실제 deploy runtime source of truth로 승격해 root field read와 verified root control contract를 잠갔다.
- `earth_fortress`는 현재 `defense_multiplier + poise_bonus + status_resistance` pure guard contract, zero-damage support pulse, toggle off 후 guard expiry representative regression까지 닫혀 있다. `holy_dawn_oath`의 피해 경감 상위축과 겹치지 않도록, current verified baseline은 damage-reduction이 아니라 earth-style defense/stability shield-up read에 둔다.
- 이 파동에서 `ice_storm`, `earth_fortress`, `plant_world_root`는 verified baseline까지 승격됐다.

2026-04-06 fallback field 5차 연결 결과:

- `plant_genesis_arbor`는 2026-04-09 follow-up으로 `plant_genesis_arbor_attack/loop/hit/end` dedicated genesis family를 실제 deploy runtime source of truth로 승격했고, `plant_worldroot_bastion`보다 더 크고 더 밝은 final canopy hierarchy를 verified baseline으로 잠갔다.
- 이번 연결은 거목 소환의 실루엣을 완성하는 최종 art가 아니라, 광역 root field / 장기 지속 / 최종 장판 위계를 내부 플레이테스트 가능 상태로 만드는 placeholder 단계다.

2026-04-06 fallback field plant 후속 연결 결과:

- `plant_worldroot_bastion`은 2026-04-09 follow-up으로 `plant_worldroot_bastion_attack/loop/hit/end` dedicated bastion family를 실제 deploy runtime source of truth로 승격했고, `plant_world_root`보다 크고 `plant_genesis_arbor`보다 작은 scale과 muted bastion tint hierarchy를 verified baseline으로 잠갔다.
- 이번 연결은 성채/보루 실루엣을 완성하는 최종 art가 아니라, mid-tier bastion field read와 representative regression을 내부 플레이테스트 가능 상태로 만드는 placeholder 단계다.

2026-04-06 fallback dark field 후속 연결 결과:

- `dark_shadow_bind`는 2026-04-09 follow-up으로 `dark_shadow_bind_attack/loop/hit/end` dedicated curse-field family를 실제 deploy runtime source of truth로 승격했고, owner-follow 오라가 아니라 고정형 curse field로 유지한 채 `slow` 중심 control contract를 verified baseline으로 잠갔다.
- 이번 연결은 묘비, 원혼, 바닥 저주문 같은 최종 흑마법 연출을 완성하는 단계가 아니라, `slow + dot field` read와 representative regression을 내부 플레이테스트 가능 상태로 만드는 placeholder 단계다.

2026-04-06 fallback plant field 저서클 보강 결과:

- `plant_root_bind` proxy인 `plant_vine_snare`는 2026-04-09 follow-up에서 `plant_vine_snare_attack/loop/hit/end` dedicated vine-bind family를 실제 deploy runtime source of truth로 승격했고, `plant_world_root`보다 작은 early snare scale로 저서클 자연 설치기 위계를 유지했다.
- representative regression도 canonical `plant_root_bind -> plant_vine_snare` deploy payload contract, repeated root pulse, level 1 대비 level 30 `duration/size` scaling, dedicated `phase_signature = plant_vine_snare` ground telegraph까지 함께 잠겼다. 현재 `plant_root_bind`는 verified 기준인 전용 연출 + 구현 + 테스트 + 문서 동기화를 충족한다.

2026-04-06 fallback field / aura 6차 연결 결과:

- `wind_sky_dominion`은 2026-04-09 follow-up으로 `sky_dominion_activation/loop/end` family를 verified toggle visual source로 유지한 채 `move_speed_multiplier + jump_velocity_multiplier + gravity_multiplier + air_jump_bonus` aerial utility runtime contract를 실제 연결했다.
- 대표 회귀도 zero-damage utility payload, owner의 이동속도/점프 강화/저중력/추가 점프 read, toggle off 후 mobility expiry, level 1 대비 level 30 range/mobility scaling까지 함께 잠겨 있다.
- 따라서 current verified baseline에서 `wind_sky_dominion`은 더 큰 wind damage aura가 아니라 `공중전/비행 계열 궁극 유틸`의 source of truth다.

2026-04-06 fallback buff guard 확장 결과:

- `holy_dawn_oath`는 2026-04-09 follow-up으로 `holy_dawn_oath_activation`, `holy_dawn_oath_overlay` dedicated final-guard family를 실제 buff visual source of truth로 승격해 final holy guard read와 owner-follow overlay contract를 잠갔다.
- `holy_dawn_oath`는 현재 `damage_taken_multiplier + super_armor_charges + status_resistance` damage-reduction focused final guard contract, cast 시 remaining/cooldown sync, level 1 대비 level 30 duration/cooldown/guard/resistance scaling regression까지 닫혀 있다.
- 이번 확장의 목적도 이제 placeholder 재사용이 아니라 `백마법 최종 보호 버프 위계`를 전용 final holy guard family와 damage-reduction contract까지 포함해 verified로 잠그는 데 있다.
- 2026-04-09 follow-up으로 `holy_mana_veil`은 같은 family 위에 base holy guard runtime contract까지 닫았다. `GameState.get_buff_runtime("holy_mana_veil")`가 duration / cooldown / `damage_taken_multiplier` / `poise_bonus` source of truth를 구성하고, cast 시 active buff remaining / cooldown sync와 level 1 대비 level 30 scaling regression까지 verified로 잠겼다.

2026-04-06 fallback buff ritual 확장 결과:

- `dark_throne_of_ash`는 2026-04-09 follow-up 기준 `dark_throne_activation`, `dark_throne_overlay` checked-in dedicated ritual family를 실제 buff visual source of truth로 사용하고, `fire_final_damage_multiplier + dark_final_damage_multiplier + ash_residue_burst` 계약과 activation mana drain까지 함께 잠겼다.
- 이번 확장의 목적도 이제 placeholder ritual read를 넘어서 `흑마법 최종 의식 버프 위계`, `dual-school finisher scaling`, `solo ash residue trigger`, `holy_dawn_oath`보다 높은 ritual overlay priority를 verified 기준으로 고정하는 데 있다.

2026-04-06 fallback buff lightning 확장 결과:

- `lightning_conductive_surge`는 2026-04-09 follow-up 기준 `conductive_surge_activation`, `conductive_surge_overlay` checked-in dedicated buff family를 실제 visual source of truth로 사용하고, `lightning_final_damage_multiplier + chain_bonus + extra_lightning_ping` offense contract와 `Overclock Circuit` active window 연계까지 함께 잠겼다.
- 이번 확장의 목적도 이제 placeholder lightning read를 넘어서 `전기 폭딜 창 가시성`, `lightning finisher scaling`, `extra ping read`, `holy guard보다 낮은 overlay priority`, `Tempest Drive` 연계 active window를 verified 기준으로 고정하는 데 있다.

2026-04-06 fallback buff plant 확장 결과:

- `plant_verdant_overflow`는 2026-04-09 follow-up 기준 `verdant_overflow_activation`, `verdant_overflow_overlay` checked-in dedicated verdant buff family를 실제 visual source of truth로 사용하고, `deploy_range_multiplier + deploy_duration_multiplier + deploy_target_bonus` 설치 증폭 contract와 `Funeral Bloom` 연계까지 함께 잠겼다.
- 이번 확장의 목적도 이제 placeholder verdant read를 넘어서 `설치기 증폭 가시성`, `deploy amplification scaling`, `Funeral Bloom` 연계 유지, `lightning/holy보다 낮은 overlay priority`를 verified 기준으로 고정하는 데 있다.

2026-04-06 fallback buff dark 확장 결과:

- `dark_grave_pact`는 2026-04-09 follow-up 기준 `grave_pact_activation`, `grave_pact_overlay` checked-in dedicated pact family를 실제 visual source of truth로 사용하고, `dark_final_damage_multiplier + kill_leech + hp_drain_percent_per_second` dark risk contract와 dark-only finisher scaling까지 함께 잠겼다.
- 이번 확장의 목적은 이제 placeholder pact read를 넘어서 `생명 소모 기반 흑마법 폭딜`, `처치 흡수 유지`, `전용 pact family`, `lightning보다 높고 holy guard보다 낮은 overlay priority`를 verified 기준으로 고정하는 데 있다.

2026-04-07 Tempest Drive canonical lock 결과:

- `wind_tempest_drive`는 5서클 `skill_type = active`로 잠갔다. 현재 기준 경험은 `전방 중거리 돌진 + 소형 바람 충격파`다.
- `tempest_drive_activation` family는 persistent overlay 없이 active cast startup visual로만 유지한다.
- activation burst의 수치 source of truth는 계속 `spells.json.wind_tempest_drive` row이고, mobility authored source는 `skills.json.wind_tempest_drive`의 `dash_speed_base`, `dash_duration_base`, `dash_*_scale_per_level`이다.
- 2026-04-09 follow-up으로 live cast mobility source도 `GameState.get_spell_runtime("wind_tempest_drive")`의 `dash_speed`, `dash_duration` 중앙 runtime contract로 올렸다. `player.on_active_skill_cast_started(skill_id, runtime)`는 이제 raw skill row가 아니라 이 runtime 값을 직접 소비한다.
- visible action slot이 canonical 입력이고, 기존 `G` 계열 단축키는 레거시 직접 입력으로만 남길 수 있다. 더 이상 버프 슬롯이나 tempo buff semantics를 갖지 않는다.
- `Overclock Circuit`는 더 이상 buff combo data row가 아니다. 현재는 `lightning_conductive_surge`가 활성 중일 때 `wind_tempest_drive` 시전 성공으로 여는 runtime active-combo window다.
- window 지속시간은 `1.0초`이고, 다음 `lightning` 계열 `active` 스킬 1회가 이를 소비한다.
- 효과는 `aftercast x0.88`, `chain +1`, `cast speed x1.18`이며, 시간이 지나거나 다음 전기 액티브가 발동하면 소멸한다.
- 같은 2026-04-09 follow-up으로 representative regression도 닫았다. level 1 대비 level 30에서 burst damage / range와 함께 dash speed / duration이 함께 증가하고, live cast 기준 `volt_spear` consumer payload와 cooldown에도 `Overclock Circuit` 보너스가 실제 반영된 뒤 즉시 소모된다.
- 이번 정리의 목적은 `진입용 이동기`, `읽히는 activation burst`, `중거리 전방 돌진`, `순수 active canonical`을 먼저 잠그는 데 있다.

2026-04-07 fallback buff fire / ice / arcane 확장 결과:

- `fire_pyre_heart`는 2026-04-09 follow-up으로 checked-in dedicated `pyre_heart_activation`, `pyre_heart_overlay` family를 실제 buff visual에 연결했고, `fire_final_damage_multiplier + fire_melee_burst` offense contract와 level scaling regression까지 잠가 verified row가 됐다.
- `ice_frostblood_ward`는 2026-04-09 follow-up으로 checked-in dedicated `frostblood_ward_activation`, `frostblood_ward_overlay` family를 실제 buff visual에 연결했고, `ice_status_duration_multiplier + ice_reflect_wave` defense/reflect contract와 level scaling regression까지 잠가 verified row가 됐다.
- `arcane_astral_compression`은 2026-04-09 follow-up으로 checked-in dedicated `astral_compression_activation`, `astral_compression_overlay` family를 실제 buff visual에 연결했고, `final_damage_multiplier + mana_efficiency_multiplier` universal arcane contract와 level scaling regression까지 잠가 verified row가 됐다.
- `arcane_world_hourglass`는 2026-04-09 follow-up으로 checked-in dedicated `world_hourglass_activation`, `world_hourglass_overlay` family를 실제 buff visual에 연결했고, `cast_speed_multiplier + cooldown_flow_multiplier` burst-window contract와 level scaling/downside regression까지 잠가 verified row가 됐다.
- `arcane_force_pulse`는 2026-04-09 사용자 결정 후속으로 checked-in dedicated `arcane_force_pulse_attack`, `arcane_force_pulse`, `arcane_force_pulse_hit` family를 실제 active runtime에 연결했고, `source_skill_id = arcane_force_pulse` 중앙 mapping, low-circle zero-cooldown, split effect payload, level 1 대비 level 30 damage/range/knockback scaling regression까지 닫아 verified row가 됐다.
- 이번 확장에서는 버프 overlay 위계도 같이 잠갔다. 기본 원칙은 `일반 offense/utility < arcane tempo < defense ward < holy guard < dark ritual finisher`다.
- current runtime 우선순위는 `fire_pyre_heart < lightning_conductive_surge < arcane_astral_compression < dark_grave_pact < arcane_world_hourglass < ice_frostblood_ward < holy_mana_veil < holy_crystal_aegis < holy_dawn_oath < dark_throne_of_ash`다.
- 초기 확장의 목적은 `Phase 5 buff row 가시성 closure`, `fallback aura family의 school tint 재해석`, `버프 overlay 위계 regression`을 먼저 닫는 데 있었다. 2026-04-09 follow-up 기준으로 fire / ice / arcane row 전부가 dedicated family와 verified regression까지 완료됐다.

2026-04-06 fallback aura dark 확장 결과:

- `dark_grave_echo`는 2026-04-09 follow-up 기준 `grave_echo_activation`, `grave_echo_loop`, `grave_echo_end` checked-in dedicated toggle family를 실제 visual source of truth로 사용하고, `0.6s` curse cadence와 level scaling, dark toggle overlay priority contract까지 함께 잠겼다.
- 이번 확장의 목적은 최종 묘비/망령 파문 장면 연출을 완성하는 것이 아니라 `흑마법 지속 압박 오라 가시성`, `fallback aura family의 muted violet curse tint 재해석`, `dark_soul_dominion보다 낮은 overlay priority를 유지하는 대표 regression`을 먼저 닫는 데 있다.

2026-04-06 fallback projectile / line 6차 연결 결과:

- `water_wave`는 `fallback_water_attack`, `fallback_water_line`, `fallback_water_hit` family를 실제 active runtime에 연결했고, `water_aqua_spear`보다 더 넓은 scale과 slow utility로 crowd-control wave read를 먼저 확보했다.
- 이번 연결의 목적은 최종 수평 파도 볼륨을 완성하는 것이 아니라, `water_tidal_ring`과 분리된 전방 line-control 역할, multi-target slow contract, representative regression을 내부 플레이테스트 가능 상태로 잠그는 데 있다.

2026-04-06 fallback projectile / line 7차 연결 결과:

- `lightning_bolt`는 `fallback_shard_attack`, `fallback_shard_projectile`, `fallback_shard_hit` family를 실제 active runtime에 연결했고, `lightning_thunder_arrow`보다 더 넓은 scale과 높은 base pierce로 chain-control bolt read를 먼저 확보했다.
- 이번 연결의 목적은 실제 chain beam 시스템을 닫는 것이 아니라, 4서클 전기 입문기의 fast line-control 역할, shock utility contract, representative regression을 내부 플레이테스트 가능 상태로 잠그는 데 있다.

2026-04-06 fallback projectile / line 8차 연결 결과:

- `ice_absolute_freeze`는 현재 `ice_absolute_freeze_attack`, `ice_absolute_freeze`, `ice_absolute_freeze_hit` checked-in dedicated family를 실제 active runtime source of truth로 사용하고, existing freeze phase signature + level scaling regression까지 함께 잠겨 `ice_storm`보다 더 무거운 late-game freeze burst read를 만든다.
- 이번 연결의 목적은 최종 절대영도 원본 연출을 완성하는 것이 아니라, 6서클 냉기 광역 CC의 stationary burst 역할, freeze utility contract, representative regression을 내부 플레이테스트 가능 상태로 잠그는 데 있다.

### 신규 에셋 기반 확장 후보

| `skill_id` | 이름 | 제안 서클 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- | --- |
| `water_aqua_geyser` | 아쿠아 가이저 | 3 | 액티브 / forward burst / launch | 전방 고정 지점 수기둥으로 적을 띄우는 물 제어기 | 22 MP, 6.0초, `(마공 x 1.48) + 20` | 계수 `+0.03`, knockback `+1.2%`, 반경 `+0.8%` |
| `earth_stone_rampart` | 스톤 램파트 | 4 | 설치형 / wall control | 짧은 석벽으로 진입을 막는 대지 설치기 | 26 MP, 12초, `생성 피해 = (마공 x 0.82) + 12`, 4초 지속 | 생성 계수 `+0.014`, 지속 `+1%`, 벽 길이 `+0.8%` |
| `fire_inferno_breath` | 인페르노 브레스 | 4 | 액티브 / cone / 다단 | 전방 부채꼴 화염으로 근중거리 압박 | 28 MP, 5.2초, `총합 피해 = (마공 x 1.95) + 30` | 계수 `+0.038`, 점화 확률 `+0.4%p`, 사거리 `+0.8%` |

`PixelHolyEffectsPack01/HolySlash A/B/C`와 `Effects/Thrust`는 현재 마도사 스킬풀의 원거리/필드 중심 톤과 충돌하므로 이번 확장 후보에서는 제외한다.

- 2026-04-09 후속 사이클로 `earth_stone_rampart`는 실제 구현까지 완료됐다. 현재 source of truth는 독립 canonical deploy row, checked-in `Earth Wall` 기반 dedicated family, short stone wall control contract, contact `slow + root` rider, dedicated wall telegraph regression이다.
- 2026-04-09 follow-up으로 `fire_inferno_breath`는 실제 구현까지 완료됐다. 현재 source of truth는 독립 canonical active row + `source_skill_id = fire_inferno_breath`, checked-in `Fire Breath` family, stationary five-hit cone pressure, burn chance per-level scaling, dedicated split effect regression이다.
- 2026-04-09 follow-up으로 `water_aqua_geyser`도 실제 구현까지 완료됐다. 현재 source of truth는 독립 canonical active row + `source_skill_id = water_aqua_geyser`, fixed-forward stationary burst spawn, checked-in `water_aqua_geyser_attack / water_aqua_geyser / water_aqua_geyser_hit / water_aqua_geyser_end` family, dedicated geyser phase signature, level 1 대비 level 30 damage/size/knockback scaling regression이다.

## 구현 핸드오프 기준

- 현재 구현 상태와 effect/asset 적용 여부는 [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)를 우선 본다.
- 실제 코드와 문서가 충돌하면 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)와 코드가 최종 구현 기준이다.
- 신규 에셋 direct attach 우선순위, 보완안, 신규 스킬 handoff는 [skill_effect_asset_mapping_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/plans/skill_effect_asset_mapping_plan.md)를 함께 본다.
- 과거 기획과의 차이나 리워크 이력은 [spell_concept_rework_2026-04-02.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/archive/spell_concept_rework_2026-04-02.md)에서만 참고한다.
