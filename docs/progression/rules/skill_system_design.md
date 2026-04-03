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
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 스킬 시스템 설계 기준

상태: 최신 기준 / 소스 오브 트루스  
최종 갱신: 2026-04-03  
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
| 워터 불릿 | `water_bullet` | runtime proxy는 `water_aqua_bullet` |
| 루트 바인드 | `plant_root_bind` | runtime proxy는 `plant_vine_snare` |
| 힐링 펄스 | `holy_healing_pulse` | runtime proxy는 `holy_radiant_burst` |
| 프로즌 도메인 | `ice_frozen_domain` | runtime proxy는 `ice_glacial_dominion` |

### 마이그레이션 진행 메모

- canonical 마이그레이션 턴은 설계 자체 변경 여부와 무관하게, 이 섹션의 진행 메모가 migration plan / tracker와 함께 갱신될 때만 닫은 것으로 본다.
- 2026-04-02 기준 row-level canonical 마이그레이션은 `42/42` row에서 완료됐다.
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
  - `ice_mastery`도 같은 방식으로 `SCHOOL_TO_MASTERY["ice"]`와 `register_skill_damage("frost_nova", dealt)`를 통한 mastery XP/레벨 progression hook까지 확인됐다.
  - `lightning_mastery`도 같은 방식으로 `SCHOOL_TO_MASTERY["lightning"]`와 `register_skill_damage("volt_spear", dealt)`를 통한 mastery XP/레벨 progression hook까지 확인됐다.
  - `wind_mastery`도 같은 방식으로 `SCHOOL_TO_MASTERY["wind"]`와 `register_skill_damage("wind_gale_cutter", dealt)`를 통한 mastery XP/레벨 progression hook까지 확인됐다.
  - `earth_mastery`도 같은 방식으로 `SCHOOL_TO_MASTERY["earth"]`와 `register_skill_damage("earth_tremor", dealt)`를 통한 mastery XP/레벨 progression hook까지 확인됐다.
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
    - `arcane_magic_mastery`의 `final_multiplier_per_level`는 일반 mastery보다 높은 `레벨당 최종 피해 +10%`다.
    - 최소 구현 완료 판정은 `fire_mastery` 10레벨에서 `fire_bolt` 피해 상승과 10레벨 milestone의 마나 또는 쿨다운 bonus가 GUT 1개로 검증되는 상태다.
  - 2026-04-03 구현 증분으로 일반 mastery의 school-specific runtime path는 공통 helper까지 실제 연결됐다.
    - fire school `active / deploy / toggle`는 `mastery -> 장비 / 버프 / 공명` 순서로 `damage + mana + cooldown`을 계산한다.
    - 이번 구조 개선 후속 증분에서 `GameState.get_mastery_runtime_modifiers_for_skill()`의 `fire_mastery` 단일 하드코딩을 제거했고, school-specific mastery row는 같은 공통 helper를 탄다.
    - 대표 계약 테스트는 `water_aqua_bullet` active, `plant_vine_snare` deploy, `dark_grave_echo` toggle로 잠갔다.
    - `arcane_magic_mastery`는 `applies_to_school = all`, `applies_to_element = all` 예외 규칙이므로 shared school-specific helper에 합치지 않고 다음 증분으로 남긴다.
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
  - 다음 후속 증분은 `arcane_magic_mastery` global modifier layer와 대표 proxy-active row의 effect 검증 확대다.
  - 필요하면 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)와 tracker 검증 상태를 같은 턴에 동기화한다.

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

## 코어 서클 라인업

4서클부터는 기본 4속성 라인이 각자의 서브 속성 성격을 일부 끌어오기 시작한다. 즉, `불 라인 -> 전기 활용`, `물 라인 -> 얼음 활용`, `대지 라인 -> 자연(풀) 활용`, `바람 라인 -> 유틸/가속 특화`가 본격화된다. 백마법은 별도 지원 라인으로 유지한다.

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
| 백마법 | 마나 베일 | 버프 / 보호 | 피해 감소 + 경직 안정화 | 16 MP, 24초, 4초 지속, 직접 피해 없음 | 지속시간 `+1%`, 피해 감소량 `+0.5%p` |

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
| 불/전기 라인 | 라이트닝 볼트 | 액티브 / 연쇄 / 중단거리 | 강한 딜과 최대 3~5명 연쇄 | 24 MP, 2.4초, `(마공 x 1.78) + 28` | 계수 `+0.036`, 고정치 `+3`, 10/20/30레벨 연쇄 수 +1 |
| 물/얼음 라인 | 아이스 스피어 | 액티브 / 발사형 / 단일 | 빙결 확률을 가진 중간 딜 관통 창 | 22 MP, 1.35초, `(마공 x 1.34) + 21` | 계수 `+0.03`, 고정치 `+2`, 빙결 확률 `+0.5%p` |
| 바람/전기 활용 라인 | 썬더 애로우 | 액티브 / 관통 / 짧은 쿨 | 빠른 관통과 감전 부여 | 21 MP, 0.68초, `(마공 x 1.18) + 16` | 계수 `+0.025`, 고정치 `+2`, 관통 수 10/20/30레벨 +1 |
| 대지/자연 라인 | 루트 바인드 | 설치형 / CC | 약한 피해와 핵심 속박 유틸 | 22 MP, 6.0초, `틱 피해 = (마공 x 0.42) + 7` | 틱 계수 `+0.008`, 지속 `+1%`, 속박 지속 `+1%` |
| 백마법 | 힐링 펄스 | 액티브 / 원형 회복 | 즉시 회복과 짧은 안정화 | 24 MP, 10초, `회복 = (마공 x 1.40) + 35` | 회복 계수 `+0.02`, 고정치 `+3` |

### 5서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 플레임 스톰 | 설치형 / 지속 AoE | 지속 화염으로 광역 중상급 압박 | 30 MP, 12초, `틱 피해 = (마공 x 0.85) + 13` | 틱 계수 `+0.012`, 지속 `+1%`, 반경 `+0.8%` |
| 물/얼음 라인 | 아이스 스톰 | 설치형 / 지속 CC | 지속 피해와 빙결 압박 | 30 MP, 13초, `틱 피해 = (마공 x 0.78) + 12` | 틱 계수 `+0.011`, 지속 `+1%`, 빙결 확률 `+0.4%p` |
| 바람 라인 | 윈드 스톰 | 액티브 / 다단 / 중거리 | 다단 히트 중심의 범위 제압 | 28 MP, 2.4초, `(마공 x 1.65) + 24` | 계수 `+0.034`, 고정치 `+3`, 타격 수 12/24레벨 +1 |
| 대지 라인 | 퀘이크 브레이크 | 액티브 / 광역 burst / CC | 강한 광역 타격과 짧은 기절 | 32 MP, 9.5초, `(마공 x 2.20) + 34` | 계수 `+0.044`, 고정치 `+4`, 기절 지속 `+1%` |
| 백마법 | 블레스 필드 | 설치형 / 힐 장판 | 소규모 치유 장판과 상태이상 완화 | 30 MP, 18초, `초당 회복 = (마공 x 0.36) + 8` | 회복 계수 `+0.01`, 지속 `+1%`, 반경 `+0.8%` |

### 6서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 인페르노 버스터 | 액티브 / 광역 burst | 큰 범위 폭발의 전투 중심 극딜기 | 40 MP, 14초, `(마공 x 2.75) + 42` | 계수 `+0.052`, 고정치 `+5`, 반경 `+0.8%` |
| 물/얼음 라인 | 앱솔루트 프리즈 | 액티브 / 광역 CC | 광역 얼림 중심의 중간 딜 기술 | 38 MP, 16초, `(마공 x 1.58) + 24` | 계수 `+0.03`, 고정치 `+3`, 빙결 지속 `+1%` |
| 바람 라인 | 템페스트 드라이브 | 액티브 / 이동기 / 돌진 | 돌진 후 공격하는 전투형 이동기 | 30 MP, 1.8초, `(마공 x 1.42) + 20` | 계수 `+0.028`, 고정치 `+2`, 돌진 거리 `+0.8%` |
| 대지 라인 | 어스 포트리스 | 토글 / 방어 | 방어력과 슈퍼아머를 크게 끌어올리는 유지형 | 초당 10 MP, 1초, 직접 피해 없음 | 피해 감소 `+0.4%p`, 슈퍼아머 강도 `+1%`, 유지 효율 `+1%` |
| 백마법 | 크리스탈 이지스 | 버프 / 방어 | 고등 방어 강화와 상태 안정화 | 34 MP, 40초, 10초 지속, 직접 피해 없음 | 지속 `+1%`, 피해 감소 `+0.4%p`, 보호막 효율 강화 |

### 7서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 메테오 스트라이크 | 액티브 / 딜레이 burst | 딜레이 후 초고폭딜 낙하 메테오 | 46 MP, 18초, `(마공 x 3.00) + 46` | 계수 `+0.056`, 고정치 `+5`, 폭발 반경 `+0.8%` |
| 물 라인 | 쓰나미 | 액티브 / 광역 제어 | 밀어내기와 광역 압박을 겸한 대파도 | 44 MP, 16초, `(마공 x 2.20) + 34` | 계수 `+0.042`, 고정치 `+4`, 파동 길이 `+0.8%` |
| 바람 라인 | 사이클론 프리즌 | 설치형 / CC | 적을 가두는 회오리 감옥 | 36 MP, 10초, `틱 피해 = (마공 x 0.55) + 9` | 틱 계수 `+0.01`, 지속 `+1%`, 구속 지속 `+1%` |
| 대지 라인 | 가이아 브레이크 | 액티브 / 광역 붕괴 | 넓은 범위의 지면 붕괴 | 46 MP, 18초, `(마공 x 2.70) + 42` | 계수 `+0.05`, 고정치 `+5`, 범위 `+0.8%` |
| 백마법 | 생츄어리 오브 리버설 | 설치형 / 회복/정화 | 회복과 정화 성역 | 40 MP, 24초, `초당 회복 = (마공 x 0.55) + 12` | 회복 계수 `+0.01`, 지속 `+1%`, 반경 `+0.8%` |

### 8서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 헬파이어 필드 | 설치형 / 장판 AoE | 강한 딜을 누적하는 지속 장판 | 50 MP, 20초, `틱 피해 = (마공 x 1.00) + 16` | 틱 계수 `+0.014`, 지속 `+1%`, 반경 `+0.8%` |
| 물/얼음 라인 | 프로즌 도메인 | 설치형 / 필드 CC | 범위 CC 필드로 얼림 전초전 형성 | 48 MP, 18초, `틱 피해 = (마공 x 0.82) + 13` | 틱 계수 `+0.012`, 지속 `+1%`, 둔화/빙결 강화 |
| 바람 라인 | 스톰 존 | 토글 / 버프 | 공격속도와 이동속도 증가의 필드 지배 토글 | 초당 12 MP, 1초, 직접 피해 없음 | 이동속도 `+0.5%p`, 공격속도 `+0.5%p`, 반경 `+0.8%` |
| 대지/자연 라인 | 월드 루트 | 설치형 / 광역 속박 | 광역 속박과 누적 자연 피해 | 48 MP, 19초, `틱 피해 = (마공 x 0.68) + 11` | 틱 계수 `+0.011`, 지속 `+1%`, 대상 수 milestone |
| 백마법 | 세라프 코러스 | 토글 / 오라 / 지원 | 주변 아군 회복 증폭과 정화 오라 | 초당 12 MP, 1초, 직접 피해 없음 | 반경 `+0.8%`, 회복 증폭 `+0.4%p`, 정화 주기 단축 |

### 9서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 아포칼립스 플레임 | 액티브 / 광역 극딜 | 매우 긴 쿨의 광역 대폭발 | 58 MP, 26초, `(마공 x 3.20) + 52` | 계수 `+0.06`, 고정치 `+6`, 반경 `+0.8%` |
| 물 라인 | 오션 콜랩스 | 액티브 / 광역 제압 | 광역으로 밀어눌러 전장을 붕괴 | 56 MP, 24초, `(마공 x 2.65) + 42` | 계수 `+0.05`, 고정치 `+5`, 반경 `+0.8%` |
| 바람 라인 | 헤븐리 스톰 | 액티브 / 다단 / 광역 | 광역 다단 히트 중심의 전략 궁극 | 54 MP, 22초, `(마공 x 2.55) + 40` | 계수 `+0.048`, 고정치 `+5`, 타격 수 milestone |
| 대지 라인 | 컨티넨탈 크러시 | 액티브 / 광역 극딜 | 지형 파괴급 대지 충돌 | 60 MP, 28초, `(마공 x 3.25) + 54` | 계수 `+0.062`, 고정치 `+6`, 범위 `+0.8%` |
| 백마법 | 던 오스 | 버프 / 보호 | 대형 보호막과 짧은 무력화 면역 | 52 MP, 55초, 8초 지속, 직접 피해 없음 | 지속 `+1%`, 보호막 계수 `+0.02`, 정화 강도 증가 |

### 10서클

| 라인 | 이름 | 타입 | 컨셉 | 기본 수치 | 레벨 성장 |
| --- | --- | --- | --- | --- | --- |
| 불 라인 | 솔라 카타클리즘 | 액티브 / 궁극기 | 필드 전체를 타격하는 초장 쿨 최종기 | 70 MP, 40초, `(마공 x 3.60) + 60` | 계수 `+0.068`, 고정치 `+6`, 반경 `+0.8%` |
| 물/얼음 라인 | 앱솔루트 제로 | 액티브 / 궁극기 / CC | 광역 완전 정지에 가까운 최종 냉기 기술 | 68 MP, 38초, `(마공 x 2.90) + 44` | 계수 `+0.05`, 고정치 `+5`, 빙결 지속 `+1%` |
| 바람 라인 | 스카이 도미니언 | 토글 / 궁극 유틸 | 공중 지배와 지속 공격을 여는 숙련자 궁극 토글 | 초당 18 MP, 1초, `틱 피해 = (마공 x 1.30) + 20` | 틱 계수 `+0.018`, 유지 효율 `+1%`, 이동 지배력 강화 |
| 대지 라인 | 월드 엔드 브레이크 | 액티브 / 궁극기 / 광역 극딜 | 초광역 붕괴를 일으키는 최종 대지 기술 | 72 MP, 42초, `(마공 x 3.70) + 62` | 계수 `+0.07`, 고정치 `+6`, 범위 `+0.8%` |
| 백마법 | 저지먼트 헤일로 | 액티브 / 빛 burst 지원 | 회복과 심판을 동시에 여는 최종 백마법 | 64 MP, 32초, `피해 = (마공 x 2.30) + 34`, `회복 = (마공 x 1.10) + 20` | 피해 계수 `+0.04`, 회복 계수 `+0.02`, 반경 `+0.8%` |

## 서브 속성 및 흑마법 대표 라인

상단 코어 라인보다 한 단계 보조적인 성장축이다. 동일 컨셉의 기술이 상단 코어 라인에 새 이름으로 들어갔다면 상단 코어 라인을 우선한다.

### 전기 라인

| 서클 | 이름 | 타입 | 컨셉 | 기본 수치 | 성장 |
| --- | --- | --- | --- | --- | --- |
| 4 | 라이트닝 볼트 | 액티브 / 연쇄 | 중간 쿨의 연쇄 공격 대표기 | 24 MP, 2.4초, `(마공 x 1.78) + 28` | 계수 `+0.036`, 연쇄 수 10/20/30 +1 |
| 4 | 썬더 애로우 | 액티브 / 관통 / 짧은 쿨 | 빠른 관통과 감전 부여 | 21 MP, 0.68초, `(마공 x 1.18) + 16` | 계수 `+0.025`, 관통 수 10/20/30 +1 |
| 5 | 컨덕티브 서지 | 버프 / 폭딜 보조 | 연쇄/감전 burst 보조 | 30 MP, 38초, 7초 지속 | 지속 `+1%`, 연쇄 보너스 강화 |
| 9 | 템페스트 크라운 | 토글 / 오라 | 자동 낙뢰와 연쇄 공격 | 초당 14 MP, 1초, `낙뢰 피해 = (마공 x 1.85) + 24` | 계수 `+0.018`, 12/24레벨 연쇄 수 +1 |

### 얼음 라인

| 서클 | 이름 | 타입 | 컨셉 | 기본 수치 | 성장 |
| --- | --- | --- | --- | --- | --- |
| 4 | 아이스 스피어 | 액티브 / 발사형 | 빙결 확률을 가진 단일 제어 창 | 22 MP, 1.35초, `(마공 x 1.34) + 21` | 계수 `+0.03`, 빙결 확률 `+0.5%p` |
| 5 | 아이스 스톰 | 설치형 / 지속 CC | 지속 피해와 빙결 압박 | 30 MP, 13초, `틱 피해 = (마공 x 0.78) + 12` | 틱 계수 `+0.011`, 지속 `+1%` |
| 6 | 앱솔루트 프리즈 | 액티브 / 광역 CC | 광역 얼림 중심 기술 | 38 MP, 16초, `(마공 x 1.58) + 24` | 계수 `+0.03`, 빙결 지속 `+1%` |
| 8 | 프로즌 도메인 | 설치형 / 필드 CC | 범위 CC 필드 | 48 MP, 18초, `틱 피해 = (마공 x 0.82) + 13` | 틱 계수 `+0.012`, 지속 `+1%` |
| 10 | 앱솔루트 제로 | 액티브 / 궁극기 | 광역 완전 정지형 최종 냉기 기술 | 68 MP, 38초, `(마공 x 2.90) + 44` | 계수 `+0.05`, 빙결 지속 `+1%` |

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

## 구현 핸드오프 기준

- 현재 구현 상태와 effect/asset 적용 여부는 [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)를 우선 본다.
- 실제 코드와 문서가 충돌하면 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)와 코드가 최종 구현 기준이다.
- 과거 기획과의 차이나 리워크 이력은 [spell_concept_rework_2026-04-02.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/archive/spell_concept_rework_2026-04-02.md)에서만 참고한다.
