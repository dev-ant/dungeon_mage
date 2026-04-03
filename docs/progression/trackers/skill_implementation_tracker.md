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
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 스킬 구현 추적표

상태: 사용 중  
최종 갱신: 2026-04-03  
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
| `verified` | 구현 + 테스트 + 문서 동기화까지 완료 |

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

## 현재 runtime 과 직접 연결된 스킬

| canonical skill_id | 서클 | 속성 | 이름 | 타입 | 현재 runtime 참조 | 구현 | asset | attack effect | hit effect | 레벨 스케일 | 비고 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `fire_bolt` | 1 | 불 | 파이어 볼트 | 액티브 / 발사형 | `fire_bolt` | `runtime` | `applied` | `applied` | `applied` | `runtime_generic` | 현재 대표 기본 투사체. 2026-04-03 payload contract test로 hotbar action 기준 `spell_id / school / damage / cooldown / speed / velocity / split effect id`를 잠갔다 |
| `water_bullet` | 1 | 물 | 워터 불릿 | 액티브 / 발사형 | `water_aqua_bullet` | `runtime` | `applied` | `applied` | `applied` | `runtime_generic` | 기본 물 탄환 라인 |
| `ice_frost_needle` | 2 | 얼음 | 프로스트 니들 | 액티브 / 발사형 / 견제 | `frost_nova` | `prototype` | `applied` | `n/a` | `n/a` | `runtime_generic` | `ice_spear`에 흡수하지 않고 별도 canonical 유지 정렬 완료, 짧은 쿨 slow + pierce poke 축 |
| `earth_stone_spire` | 2 | 대지 | 어스 스파이크 | 설치형 / 즉발 cone | `earth_stone_spire` | `runtime` | `placeholder` | `n/a` | `n/a` | `runtime_generic` | `earth_spike` 3서클 core slot과 분리된 2서클 canonical 유지 row, 사용자 노출 지속. `earth_tremor`는 인접 earth burst proxy 참고축으로만 유지 |
| `wind_cutter` | 3 | 바람 | 윈드 커터 | 액티브 / 직선 / 다단 | `wind_gale_cutter` | `runtime` | `applied` | `applied` | `applied` | `runtime_generic` | 최신 기획과 가장 가깝게 정렬됨 |
| `fire_flame_arc` | 3 | 불 | 플레임 써클 | 액티브 / 원형 burst | `fire_flame_arc` | `prototype` | `placeholder` | `not_started` | `not_started` | `runtime_generic` | `fire_burst`에 흡수하지 않고 별도 canonical 유지 정렬 완료. 3서클 사냥형 광역 버스터이며 현재 runtime 축은 row 자체를 그대로 유지 |
| `water_tidal_ring` | 3 | 물 | 타이달 링 | 액티브 / 원형 push control | `water_tidal_ring` | `prototype` | `placeholder` | `not_started` | `not_started` | `runtime_generic` | `water_wave`에 흡수하지 않고 별도 canonical 유지 정렬 완료. 3서클 원형 밀쳐내기 제어기이며 현재 runtime 축은 row 자체를 그대로 유지 |
| `holy_mana_veil` | 2 | 백마법 | 마나 베일 | 버프 | `holy_mana_veil` | `runtime` | `placeholder` | `n/a` | `n/a` | `runtime_generic` | buff UI/시각 자산은 추가 정리 필요 |
| `fire_pyre_heart` | 4 | 불 | 파이어 하트 | 버프 / offense burst | `fire_pyre_heart` | `runtime` | `placeholder` | `n/a` | `n/a` | `runtime_generic` | Phase 5 버프 canonical 유지 정렬 완료. 화염 폭딜 창구를 여는 공격 버프이며 현재 runtime 축은 row 자체를 그대로 유지 |
| `ice_frostblood_ward` | 4 | 얼음 | 프로스트블러드 워드 | 버프 / defense reflect | `ice_frostblood_ward` | `runtime` | `placeholder` | `n/a` | `n/a` | `runtime_generic` | Phase 5 버프 canonical 유지 정렬 완료. 빙결 제어와 반사 파동으로 안정성을 높이는 냉기 방어 버프이며 현재 runtime 축은 row 자체를 그대로 유지 |
| `arcane_magic_mastery` | 1 | 아케인 | 아케인 마스터리 | 패시브 / mastery | `arcane_magic_mastery` | `runtime` | `n/a` | `n/a` | `n/a` | `runtime_specific` | Phase 5 패시브 canonical 유지 정렬 완료. 어떤 마법 스킬을 쓰든 숙련도가 오르는 공용 mastery row로 잠겼다. 모든 속성 스킬에 영향을 주며 `final_multiplier_per_level = +10%` 기준, `5/10/15/20/25/30` milestone의 damage / mana / cooldown bonus 규칙이 문서 잠금 완료됐고 runtime wiring은 후속 구현이다 |
| `fire_mastery` | 1 | 불 | 파이어 마스터리 | 패시브 / mastery | `fire_mastery` | `verified` | `n/a` | `n/a` | `n/a` | `verified` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["fire"]`와 `register_skill_damage("fire_bolt", dealt)` 경로를 통한 XP/레벨 progression hook은 계속 검증 상태다. 2026-04-03 증분에서 `GameState.get_spell_runtime()`, `GameState.get_skill_mana_cost()`, `scripts/player/spell_manager.gd`의 data-driven runtime builder에 fire school `active / deploy / toggle`용 fire mastery wiring을 연결했고, `final_multiplier_per_level = +5%`와 lv10 `cooldown_reduction = 0.03` milestone이 `fire_bolt` GUT로 잠겼다. 같은 날짜 구조 개선 증분부터는 active / deploy / toggle 공통 scaling 해석도 `GameState.build_common_runtime_stat_block()`과 `GameState.get_common_scaled_mana_value()` 기준으로 읽는다 |
| `water_mastery` | 1 | 물 | 워터 마스터리 | 패시브 / mastery | `water_mastery` | `verified` | `n/a` | `n/a` | `n/a` | `verified` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["water"]`와 `register_skill_damage("water_aqua_bullet", dealt)` 경로를 통한 XP/레벨 progression hook은 검증됐다. 이번 구조 개선 후속 증분에서 school-specific mastery modifier stack이 shared helper로 이동했고, `water_aqua_bullet` active의 damage / cooldown / mana contract까지 잠갔다 |
| `ice_mastery` | 1 | 얼음 | 아이스 마스터리 | 패시브 / mastery | `ice_mastery` | `runtime` | `n/a` | `n/a` | `n/a` | `runtime_specific` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["ice"]`와 `register_skill_damage("frost_nova", dealt)` 경로를 통한 XP/레벨 progression hook은 검증됐다. 2026-04-03 답변으로 해당 school의 active / deploy / toggle 전부에 `레벨당 최종 피해 +5%`, `5/10/15/20/25/30` milestone의 damage / mana / cooldown bonus를 적용하는 규칙이 잠겼고 runtime wiring만 남았다 |
| `lightning_mastery` | 1 | 전기 | 라이트닝 마스터리 | 패시브 / mastery | `lightning_mastery` | `runtime` | `n/a` | `n/a` | `n/a` | `runtime_specific` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["lightning"]`와 `register_skill_damage("volt_spear", dealt)` 경로를 통한 XP/레벨 progression hook은 검증됐다. 2026-04-03 답변으로 해당 school의 active / deploy / toggle 전부에 `레벨당 최종 피해 +5%`, `5/10/15/20/25/30` milestone의 damage / mana / cooldown bonus를 적용하는 규칙이 잠겼고 runtime wiring만 남았다 |
| `wind_mastery` | 1 | 바람 | 윈드 마스터리 | 패시브 / mastery | `wind_mastery` | `runtime` | `n/a` | `n/a` | `n/a` | `runtime_specific` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["wind"]`와 `register_skill_damage("wind_gale_cutter", dealt)` 경로를 통한 XP/레벨 progression hook은 검증됐다. 2026-04-03 답변으로 해당 school의 active / deploy / toggle 전부에 `레벨당 최종 피해 +5%`, `5/10/15/20/25/30` milestone의 damage / mana / cooldown bonus를 적용하는 규칙이 잠겼고 runtime wiring만 남았다 |
| `earth_mastery` | 1 | 대지 | 어스 마스터리 | 패시브 / mastery | `earth_mastery` | `runtime` | `n/a` | `n/a` | `n/a` | `runtime_specific` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["earth"]`와 `register_skill_damage("earth_tremor", dealt)` 경로를 통한 XP/레벨 progression hook은 검증됐다. 2026-04-03 답변으로 해당 school의 active / deploy / toggle 전부에 `레벨당 최종 피해 +5%`, `5/10/15/20/25/30` milestone의 damage / mana / cooldown bonus를 적용하는 규칙이 잠겼고 runtime wiring만 남았다 |
| `plant_mastery` | 1 | 자연(풀) | 플랜트 마스터리 | 패시브 / mastery | `plant_mastery` | `verified` | `n/a` | `n/a` | `n/a` | `verified` | Phase 5 패시브 canonical 유지 정렬 완료. `plant_vine_snare`를 plant school runtime spell entry로 정의한 뒤, `SCHOOL_TO_MASTERY["plant"]`와 `register_skill_damage("plant_vine_snare", dealt)` 경로를 통한 XP/레벨 progression hook까지 검증됐다. 이번 구조 개선 후속 증분에서 school-specific mastery modifier stack이 shared helper로 이동했고, `plant_vine_snare` deploy의 damage / cooldown / mana contract까지 잠갔다 |
| `dark_magic_mastery` | 3 | 흑마법 | 다크 매직 마스터리 | 패시브 / mastery | `dark_magic_mastery` | `verified` | `n/a` | `n/a` | `n/a` | `verified` | Phase 5 패시브 canonical 유지 정렬 완료. `SCHOOL_TO_MASTERY["dark"]`와 `register_skill_damage("dark_void_bolt", dealt)` 경로를 통한 XP/레벨 progression hook은 검증됐다. 이번 구조 개선 후속 증분에서 school-specific mastery modifier stack이 shared helper로 이동했고, `dark_grave_echo` toggle의 damage / cooldown / sustain mana contract까지 잠갔다 |
| `plant_root_bind` | 4 | 자연(풀) | 루트 바인드 | 설치형 / CC | `plant_vine_snare` | `prototype` | `placeholder` | `not_started` | `not_started` | `verified` | canonical alias와 데이터 표기 정렬 완료. `plant_vine_snare` runtime proxy 기준으로 deploy payload의 `duration`과 `size`가 level 1 대비 level 30에서 실제 증가함을 검증했다. 2026-04-03 payload contract test로 canonical 입력 `plant_root_bind`가 runtime payload의 `spell_id / school / damage / duration / size / target_count / root utility`까지 보장함을 잠갔다. 설치 연출은 미완 |
| `ice_ice_wall` | 4 | 얼음 | 아이스 월 | 설치형 / wall control | `ice_ice_wall` | `prototype` | `placeholder` | `not_started` | `not_started` | `runtime_generic` | 별도 canonical 유지 정렬 완료. 4서클 얼음 장벽 생성형 제어기이며 현재 runtime 축은 row 자체를 그대로 유지 |
| `holy_healing_pulse` | 4 | 백마법 | 힐링 펄스 | 액티브 / 회복 burst | `holy_radiant_burst` | `prototype` | `applied` | `applied` | `applied` | `runtime_generic` | row key rename 없이 유지, `canonical_skill_id = holy_healing_pulse` 명시 완료. 2026-04-03 payload contract test로 canonical hotbar 입력과 admin -> hotbar -> save -> cast 경로가 모두 `holy_radiant_burst` runtime payload의 `spell_id / school / damage / cooldown / speed` 계약으로 이어짐을 잠갔다 |
| `lightning_thunder_lance` | 4 | 전기 | 썬더 랜스 | 액티브 / 관통 burst | `volt_spear` | `prototype` | `applied` | `applied` | `applied` | `runtime_generic` | `lightning_bolt`, `lightning_thunder_arrow`에 흡수하지 않고 별도 canonical 유지 정렬 완료. 중간 쿨 직선 버스터 / 보스 대응 축 |
| `earth_quake_break` | 5 | 대지 | 퀘이크 브레이크 | 액티브 / 광역 burst | `earth_tremor` | `prototype` | `applied` | `applied` | `applied` | `runtime_generic` | canonical alias와 데이터 표기 정렬 완료, 퀘이크/가이아 계열 재정의는 후속 |
| `wind_tempest_drive` | 6 | 바람 | 템페스트 드라이브 | 액티브 / 이동기 | `wind_tempest_drive` | `prototype` | `placeholder` | `n/a` | `n/a` | `runtime_generic` | canonical row 한글 표기와 current buff proxy 설명 정렬 완료, 최종 6서클 액티브 전환은 후속 |
| `holy_crystal_aegis` | 6 | 백마법 | 크리스탈 이지스 | 버프 / 방어 | `holy_crystal_aegis` | `prototype` | `placeholder` | `n/a` | `n/a` | `runtime_generic` | canonical row 한글 표기와 상위 방어 버프 설명 정렬 완료, 실전 운용 검증은 후속 |
| `holy_sanctuary_of_reversal` | 7 | 백마법 | 생츄어리 오브 리버설 | 설치형 / 회복 필드 | `holy_sanctuary_of_reversal` | `prototype` | `placeholder` | `not_started` | `not_started` | `design_only` | canonical row 한글 표기와 회복/정화 성역 설명 정렬 완료, runtime 재검증은 후속 |
| `fire_inferno_sigil` | 7 | 불 | 인페르노 시길 | 설치형 / 반복 폭발 burst | `fire_inferno_sigil` | `prototype` | `placeholder` | `not_started` | `not_started` | `runtime_generic` | `fire_flame_storm`, `fire_inferno_buster`에 흡수하지 않고 별도 canonical 유지 정렬 완료. 7서클 대형 화염 마법진 반복 폭발형 보스 대응 광역 버스터이며 현재 runtime 축은 row 자체를 그대로 유지 |
| `ice_frozen_domain` | 8 | 물/얼음 | 프로즌 도메인 | 설치형 / 필드 CC | `ice_glacial_dominion` | `prototype` | `placeholder` | `n/a` | `n/a` | `runtime_generic` | canonical alias와 데이터 표기 정렬 완료, 현재는 토글 오라와 혼재 |
| `dark_abyss_gate` | 8 | 흑마법 | 어비스 게이트 | 액티브 / pull burst | `dark_void_bolt` | `prototype` | `applied` | `applied` | `applied` | `runtime_generic` | row key rename 없이 유지, `canonical_skill_id = dark_abyss_gate` 명시 완료. pull burst 보강은 후속 |
| `lightning_tempest_crown` | 9 | 전기 | 템페스트 크라운 | 토글 / 오라 | `lightning_tempest_crown` | `prototype` | `placeholder` | `n/a` | `n/a` | `verified` | row key rename 없이 유지, `canonical_skill_id = lightning_tempest_crown` 명시 완료. 토글 tick payload 기준으로 level 1의 base `pierce = 2`, level 24 milestone 이후 `pierce = 4`가 실제 반영됨을 검증했다. 2026-04-03 payload contract test로 hotbar action 기준 `spell_id / school / damage / pierce / size / duration`도 잠갔다. 자동 낙뢰/연쇄 오라 보강은 후속 |
| `plant_genesis_arbor` | 10 | 자연(풀) | 제네시스 아버 | 설치형 / 최종 장기전 | `plant_genesis_arbor` | `prototype` | `placeholder` | `not_started` | `not_started` | `runtime_generic` | row key rename 없이 유지, `canonical_skill_id = plant_genesis_arbor` 명시 완료. 광역 구속/연속 타격/흡수 보강은 후속 |
| `dark_soul_dominion` | 10 | 흑마법 | 소울 도미니언 | 토글 / 피니셔 | `dark_soul_dominion` | `prototype` | `placeholder` | `n/a` | `n/a` | `runtime_generic` | canonical row 한글 표기와 리스크 설명 정렬 완료, 최종 리스크/리턴 검증 전 |
| `plant_worldroot_bastion` | 6 | 자연(풀) | 월드루트 바스천 | 설치형 / 장기전 | `plant_worldroot_bastion` | `prototype` | `placeholder` | `not_started` | `not_started` | `design_only` | canonical row 한글 표기와 성채형 설치 설명 정렬 완료, runtime 사용성 정리는 후속 |
| `plant_verdant_overflow` | 7 | 자연(풀) | 버던트 오버플로 | 버프 / 설치 증폭 | `plant_verdant_overflow` | `prototype` | `placeholder` | `n/a` | `n/a` | `design_only` | canonical row 한글 표기와 설치 빌드 버프 설명 정렬 완료, 설치 시너지 수치 보강은 후속 |
| `dark_shadow_bind` | 3 | 흑마법 | 섀도우 바인드 | 설치형 / 디버프 | `dark_shadow_bind` | `prototype` | `placeholder` | `not_started` | `not_started` | `design_only` | canonical row 한글 표기와 설치형 디버프 설명 정렬 완료, 대표 흑마 설치형 |
| `dark_grave_echo` | 5 | 흑마법 | 그레이브 에코 | 토글 / 저주 오라 | `dark_grave_echo` | `prototype` | `placeholder` | `n/a` | `n/a` | `design_only` | canonical row 한글 표기와 저주 오라 설명 정렬 완료, 토글형 압박 보강은 후속 |
| `dark_grave_pact` | 6 | 흑마법 | 그레이브 팩트 | 버프 / 리스크 | `dark_grave_pact` | `prototype` | `placeholder` | `n/a` | `n/a` | `design_only` | canonical row 한글 표기와 리스크 버프 설명 정렬 완료, 방어 페널티 수치화는 후속 |
| `lightning_conductive_surge` | 5 | 전기 | 컨덕티브 서지 | 버프 / 폭딜 보조 | `lightning_conductive_surge` | `prototype` | `placeholder` | `n/a` | `n/a` | `design_only` | canonical row 한글 표기와 전기 버프 설명 정렬 완료, 연쇄/감전 보조 수치 보강은 후속 |
| `dark_throne_of_ash` | 10 | 흑마법 | 스론 오브 애시 | 버프 / 의식 피니셔 | `dark_throne_of_ash` | `prototype` | `placeholder` | `n/a` | `n/a` | `design_only` | canonical row 한글 표기와 의식 피니셔 설명 정렬 완료, 최종 버프 축 검증 전 |

## 코어 라인업 설계 스킬

아래 스킬은 최신 기획에는 포함되지만 아직 위의 runtime 연결 표에 직접 올라오지 않은 항목들이다.

| canonical skill_id | 서클 | 속성 | 이름 | 타입 | 현재 runtime 참조 | 구현 | asset | attack effect | hit effect | 레벨 스케일 | 비고 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `wind_arrow` | 1 | 바람 | 윈드 애로우 | 액티브 / 발사형 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 1서클 wind 기본기 |
| `earth_stone_shot` | 1 | 대지 | 스톤 샷 | 액티브 / 발사형 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 1서클 earth 기본기 |
| `holy_halo_touch` | 1 | 백마법 | 헤일로 터치 | 액티브 / 단일 회복 | - | `planned` | `not_started` | `n/a` | `n/a` | `design_only` | 1서클 white 기본기 |
| `fire_flame_bullet` | 2 | 불 | 플레임 불릿 | 액티브 / 연사 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 불 연사형 |
| `water_aqua_spear` | 2 | 물 | 아쿠아 스피어 | 액티브 / 라인 / 관통 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 물 관통형 |
| `wind_gust_bolt` | 2 | 바람 | 거스트 볼트 | 액티브 / 유틸 발사형 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 넉백 강화 기본기 |
| `earth_rock_spear` | 2 | 대지 | 락 스피어 | 액티브 / 디버프 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 방어 감소 단일기 |
| `fire_burst` | 3 | 불 | 파이어 버스트 | 액티브 / AoE burst | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 광역 입문 |
| `water_wave` | 3 | 물 | 워터 웨이브 | 액티브 / 범위 제어 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 광역 둔화 입문 |
| `earth_spike` | 3 | 대지 | 어스 스파이크 | 설치형 / burst | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 지면 솟구침 설치기 |
| `holy_cure_ray` | 3 | 백마법 | 큐어 레이 | 액티브 / 직선 회복 | - | `planned` | `not_started` | `n/a` | `n/a` | `design_only` | line heal |
| `lightning_bolt` | 4 | 불/전기 | 라이트닝 볼트 | 액티브 / 연쇄 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 전기 입문 대표 |
| `ice_spear` | 4 | 물/얼음 | 아이스 스피어 | 액티브 / 발사형 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 빙결 확률 단일기 |
| `lightning_thunder_arrow` | 4 | 바람/전기 | 썬더 애로우 | 액티브 / 관통 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 빠른 감전 관통 |
| `fire_flame_storm` | 5 | 불 | 플레임 스톰 | 설치형 / 지속 AoE | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 화염 장판 |
| `ice_storm` | 5 | 물/얼음 | 아이스 스톰 | 설치형 / 지속 CC | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 냉기 장판 |
| `wind_storm` | 5 | 바람 | 윈드 스톰 | 액티브 / 다단 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 다단 히트 범위기 |
| `holy_bless_field` | 5 | 백마법 | 블레스 필드 | 설치형 / 힐 장판 | - | `planned` | `not_started` | `n/a` | `n/a` | `design_only` | 회복 장판 |
| `fire_inferno_buster` | 6 | 불 | 인페르노 버스터 | 액티브 / 광역 burst | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 전투 중심 극딜기 |
| `ice_absolute_freeze` | 6 | 물/얼음 | 앱솔루트 프리즈 | 액티브 / 광역 CC | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 광역 얼림 |
| `earth_fortress` | 6 | 대지 | 어스 포트리스 | 토글 / 방어 | - | `planned` | `not_started` | `n/a` | `n/a` | `design_only` | 대지 유지형 방어 |
| `fire_meteor_strike` | 7 | 불 | 메테오 스트라이크 | 액티브 / 딜레이 burst | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 낙하형 폭딜 |
| `water_tsunami` | 7 | 물 | 쓰나미 | 액티브 / 광역 제어 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 파도 제압기 |
| `wind_cyclone_prison` | 7 | 바람 | 사이클론 프리즌 | 설치형 / CC | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 회오리 감옥 |
| `earth_gaia_break` | 7 | 대지 | 가이아 브레이크 | 액티브 / 광역 붕괴 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 넓은 범위 붕괴 |
| `fire_hellfire_field` | 8 | 불 | 헬파이어 필드 | 설치형 / 장판 AoE | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 필드 지배 화염 장판 |
| `wind_storm_zone` | 8 | 바람 | 스톰 존 | 토글 / 버프 | - | `planned` | `not_started` | `n/a` | `n/a` | `design_only` | 공속/이속 토글 |
| `plant_world_root` | 8 | 대지/자연 | 월드 루트 | 설치형 / 광역 속박 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 광역 루트 |
| `holy_seraph_chorus` | 8 | 백마법 | 세라프 코러스 | 토글 / 지원 오라 | - | `planned` | `not_started` | `n/a` | `n/a` | `design_only` | 회복 증폭 오라 |
| `fire_apocalypse_flame` | 9 | 불 | 아포칼립스 플레임 | 액티브 / 광역 극딜 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 전략 궁극 화염 |
| `water_ocean_collapse` | 9 | 물 | 오션 콜랩스 | 액티브 / 광역 제압 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 광역 압박 물 궁극 |
| `wind_heavenly_storm` | 9 | 바람 | 헤븐리 스톰 | 액티브 / 다단 / 광역 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 다단 궁극 |
| `earth_continental_crush` | 9 | 대지 | 컨티넨탈 크러시 | 액티브 / 광역 극딜 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 대지 궁극 |
| `holy_dawn_oath` | 9 | 백마법 | 던 오스 | 버프 / 보호 | - | `planned` | `not_started` | `n/a` | `n/a` | `design_only` | 대형 보호 버프 |
| `fire_solar_cataclysm` | 10 | 불 | 솔라 카타클리즘 | 액티브 / 궁극기 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 최종 화염기 |
| `ice_absolute_zero` | 10 | 물/얼음 | 앱솔루트 제로 | 액티브 / 궁극기 / CC | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 최종 냉기기 |
| `wind_sky_dominion` | 10 | 바람 | 스카이 도미니언 | 토글 / 궁극 유틸 | - | `planned` | `not_started` | `n/a` | `n/a` | `design_only` | 최종 바람 토글 |
| `earth_world_end_break` | 10 | 대지 | 월드 엔드 브레이크 | 액티브 / 궁극기 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 최종 대지기 |
| `holy_judgment_halo` | 10 | 백마법 | 저지먼트 헤일로 | 액티브 / 빛 burst 지원 | - | `planned` | `not_started` | `not_started` | `not_started` | `design_only` | 최종 백마법기 |

## 레거시 / 재분류 대기 스킬

| 이름 | 현재 runtime 참조 | 현재 상태 | 메모 |
| --- | --- | --- | --- |
| 프로스트 노바 | `frost_nova` | `prototype` | 최신 설계 기준의 정식 자리 미정 |
| 아케인 포스 펄스 | `arcane_force_pulse` | `prototype` | 독립 `arcane` 축의 기본 액티브 runtime 참조로 유지 |
| 아스트랄 컴프레션 | `arcane_astral_compression` | `prototype` | 공용 마나 효율 버프로 canonical row key 유지 정렬 완료 |
| 월드 아워글래스 | `arcane_world_hourglass` | `verified` | 공용 극딜 창구 버프로 canonical row key 유지 정렬 완료. buff activation 후 cooldown 압축, downside penalty, level 1 대비 level 30 duration scaling까지 검증됐다 |

## 다음 우선 작업

현재 상태: `Phase 6 completed`

row-level canonical 마이그레이션 상태: `42/42 completed`

반복 재평가 규칙: 최신 기획 또는 현재 runtime 사실이 바뀌지 않았다면 같은 blocked row를 다시 canonical 후보로 올리지 않는다. 단, 사용자 답변으로 source of truth를 잠그는 구체화 인터뷰는 예외다.

단계 우회 금지 규칙: `Phase 5`, `Phase 6` pending row는 현재 blocked 상태를 우회하기 위한 대체 증분으로 당겨 처리하지 않는다.

blocked 중단 규칙: 최신 기획, 현재 runtime 사실, 문서 규칙 중 새로 잠글 변화가 없다면 추가 repo 수정 없이 중단하고 중단 이유만 남긴다. 사용자 구체화 라운드를 시작한 턴에는 질문 세트를 남기고 답변 전까지 row 수정은 보류한다.

1. school-specific mastery modifier stack은 이제 shared runtime helper로 읽는다. 다음 최소 안전 증분은 `arcane_magic_mastery`의 `+10%` global mastery 예외 규칙을 이 경로에 별도 layer로 얹는 것이다
2. `ice`/`lightning`/`wind`/`earth` mastery는 school-specific helper를 타지만 대표 contract test가 아직 없으므로, arcane 예외 뒤에 school별 representative verification을 순차 확장한다
3. 대표 proxy-active row의 effect/runtime verification 확대는 `holy_healing_pulse` payload contract 기준선 이후 effect 세부 검증으로 이어간다. 다음 후보는 hit/impact effect coverage 확장이다
4. 이후 새 proxy-active / runtime spell 연결은 코드 상수 추가가 아니라 `data/spells.json` `source_skill_id` + `GameDatabase` 중앙 mapping 구조에 먼저 등록하는 것을 기준으로 유지한다. 남은 구조 개선 1순위는 default hotbar / admin preset seed도 같은 source로 좁히는 것이다
