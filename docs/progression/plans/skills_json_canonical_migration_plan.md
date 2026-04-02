---
title: `skills.json` canonical `skill_id` 마이그레이션 계획
doc_type: plan
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# `skills.json` canonical `skill_id` 마이그레이션 계획

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 성장 시스템

## 목적

이 문서는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/skills/skills.json`을 최신 기획 기준의 canonical `skill_id` 구조로 **한 번에 깨지지 않게** 옮기기 위한 실행 계획이다.

이 계획의 목표는 다음 세 가지다.

- 최신 기획 기준의 안정적인 장기 식별자를 모든 스킬에 부여한다.
- 기존 runtime ID, save/테스트, proxy 구현을 즉시 깨지 않도록 단계적으로 전환한다.
- 각 단계는 `구현/데이터 수정 -> 검증 -> migration plan / tracker / design 문서 업데이트` 순서로 닫아, 최종 상태가 다시 일치하도록 만든다.

## 완료 기록 위치

canonical 마이그레이션 작업은 아래 위치에 완료를 기록해야만 `완료`로 간주한다.

### 1. 필수 완료 기록

- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/plans/skills_json_canonical_migration_plan.md`
  - `Phase 진행 상태` 섹션 갱신
  - 이번에 완료한 row
  - 마지막 갱신 날짜
  - 다음 안전 증분
- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md`
  - 해당 스킬 row의 canonical `skill_id`
  - 현재 runtime 참조
  - 구현 / asset / attack effect / hit effect / 레벨 스케일 상태
- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md`
  - 설계 자체가 바뀌지 않아도, canonical 전환 예시 / runtime proxy 메모 / blocked 상태 메모 중 하나가 달라졌다면 같은 턴에 갱신

### 2. 조건부 완료 기록

- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md`
  - runtime 사실, alias lookup, 현재 동작 설명이 바뀐 경우에만 갱신

### 3. 완료 판정 규칙

- 코드/데이터만 바꾸고 문서 기록이 없으면 완료로 보지 않는다.
- `Phase 진행 상태`, tracker, `skill_system_design.md`의 진행 메모가 모두 같은 턴에 갱신돼야 해당 증분을 닫는다.
- `skill_system_design.md`의 마이그레이션 진행 메모도 같은 턴에 갱신돼야 이번 턴을 닫은 것으로 본다.
- 다음 안전 증분이 문서에 남아 있어야 반복 작업용 handoff가 끝난 것으로 본다.

## 이 문서의 역할

- 이 문서는 `data/skills/skills.json` 전환 계획의 소스 오브 트루스다.
- 최신 이름/속성/서클/컨셉은 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md`를 따른다.
- 실제 현재 runtime 사실은 코드와 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md`를 따른다.
- 구현/asset/attack effect/hit effect/레벨 스케일 상태는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md`를 따른다.
- 과거 프로토타입 문서와 스냅샷 문서는 참고만 하며, 최신 문서와 충돌하면 항상 최신 문서를 우선한다.

## 현재 상태 스냅샷

2026-04-02 기준 `skills.json` 상태는 아래와 같다.

- 총 스킬 row 수: `42`
- `canonical_skill_id`가 명시된 row 수: `42`
- 아직 `canonical_skill_id`가 명시되지 않은 row 수: `0`
- alias 해석은 이미 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`에서 지원한다.
- 현재 가장 작은 안전 증분: 없음. row-level canonical 명시는 모두 정렬 완료됐고 다음 작업은 `Phase 6` 결론 고정 또는 후속 검증 증분이다.
- `Phase 3`, `Phase 4`의 blocked row는 현재 모두 정리됐다.
- `Phase 6`은 마지막 단계이므로 `Phase 5`의 mastery / buff / arcane 정리가 끝나기 전까지 대체 증분으로 당겨 처리하지 않는다.
- `Phase 5`에서는 `row key = canonical_skill_id`, 현재 circle 유지, `hit_shape` 이름 기준 보수 추론 규칙을 기본값으로 먼저 적용한다.
- 단, 사용자가 기획 구체화 라운드를 명시적으로 요청한 경우에는 row 수정 대신 `10문항 인터뷰 -> 답변 반영 -> canonical 재판정` 순서의 smallest safe increment를 먼저 연다.

현재 명시적으로 canonical 전환을 시작한 row:

| 현재 `skill_id` | canonical `skill_id` | 상태 |
| --- | --- | --- |
| `fire_ember_dart` | `fire_bolt` | 1차 전환 완료 |
| `water_aqua_bullet` | `water_bullet` | 1차 전환 완료 |
| `wind_gale_cutter` | `wind_cutter` | 1차 전환 완료 |
| `holy_mana_veil` | `holy_mana_veil` | canonical 명시 완료 |
| `holy_healing_pulse` | `holy_healing_pulse` | Phase 6 rename 없이 유지 canonical 명시 완료 |
| `dark_abyss_gate` | `dark_abyss_gate` | Phase 6 rename 없이 유지 canonical 명시 완료 |
| `lightning_tempest_crown` | `lightning_tempest_crown` | Phase 6 rename 없이 유지 canonical 명시 완료 |
| `plant_genesis_arbor` | `plant_genesis_arbor` | Phase 6 rename 없이 유지 canonical 명시 완료 |
| `plant_vine_snare` | `plant_root_bind` | Phase 1 1차 증분 완료 |
| `ice_glacial_dominion` | `ice_frozen_domain` | Phase 1 1차 증분 완료 |
| `earth_terra_break` | `earth_quake_break` | Phase 1 종료 증분 완료 |
| `ice_frost_needle` | `ice_frost_needle` | Phase 3 별도 canonical 유지 정렬 완료 |
| `earth_stone_spire` | `earth_stone_spire` | Phase 3 별도 canonical 유지 정렬 완료 |
| `lightning_thunder_lance` | `lightning_thunder_lance` | Phase 3 별도 canonical 유지 정렬 완료 |
| `fire_flame_arc` | `fire_flame_arc` | Phase 3 별도 canonical 유지 정렬 완료 |
| `water_tidal_ring` | `water_tidal_ring` | Phase 3 별도 canonical 유지 정렬 완료 |
| `ice_ice_wall` | `ice_ice_wall` | Phase 4 별도 canonical 유지 정렬 완료 |
| `fire_inferno_sigil` | `fire_inferno_sigil` | Phase 4 별도 canonical 유지 정렬 완료 |
| `fire_mastery` | `fire_mastery` | Phase 5 패시브 canonical 유지 정렬 완료 |
| `water_mastery` | `water_mastery` | Phase 5 패시브 canonical 유지 정렬 완료 |
| `ice_mastery` | `ice_mastery` | Phase 5 패시브 canonical 유지 정렬 완료 |
| `lightning_mastery` | `lightning_mastery` | Phase 5 패시브 canonical 유지 정렬 완료 |
| `wind_mastery` | `wind_mastery` | Phase 5 패시브 canonical 유지 정렬 완료 |
| `earth_mastery` | `earth_mastery` | Phase 5 패시브 canonical 유지 정렬 완료 |
| `plant_mastery` | `plant_mastery` | Phase 5 패시브 canonical 유지 정렬 완료 |
| `dark_magic_mastery` | `dark_magic_mastery` | Phase 5 패시브 canonical 유지 정렬 완료 |
| `fire_pyre_heart` | `fire_pyre_heart` | Phase 5 버프 canonical 유지 정렬 완료 |
| `ice_frostblood_ward` | `ice_frostblood_ward` | Phase 5 버프 canonical 유지 정렬 완료 |
| `arcane_magic_mastery` | `arcane_magic_mastery` | Phase 5 패시브 canonical 유지 정렬 완료 |
| `arcane_astral_compression` | `arcane_astral_compression` | Phase 5 버프 canonical 유지 정렬 완료 |
| `arcane_world_hourglass` | `arcane_world_hourglass` | Phase 5 버프 canonical 유지 정렬 완료 |
| `dark_soul_dominion` | `dark_soul_dominion` | Phase 2 표기/설명 정렬 완료 |
| `dark_shadow_bind` | `dark_shadow_bind` | Phase 2 표기/설명 정렬 완료 |
| `dark_grave_echo` | `dark_grave_echo` | Phase 2 표기/설명 정렬 완료 |
| `dark_grave_pact` | `dark_grave_pact` | Phase 2 표기/설명 정렬 완료 |
| `lightning_conductive_surge` | `lightning_conductive_surge` | Phase 2 표기/설명 정렬 완료 |
| `plant_worldroot_bastion` | `plant_worldroot_bastion` | Phase 2 표기/설명 정렬 완료 |
| `plant_verdant_overflow` | `plant_verdant_overflow` | Phase 2 표기/설명 정렬 완료 |
| `holy_crystal_aegis` | `holy_crystal_aegis` | Phase 2 표기/설명 정렬 완료 |
| `holy_sanctuary_of_reversal` | `holy_sanctuary_of_reversal` | Phase 2 표기/설명 정렬 완료 |
| `dark_throne_of_ash` | `dark_throne_of_ash` | Phase 2 표기/설명 정렬 완료 |
| `wind_tempest_drive` | `wind_tempest_drive` | Phase 2 표기/프록시 설명 정렬 완료 |

## Phase 진행 상태

| Phase | 상태 | 이번 단계 범위 | 완료된 row | 남은 row / 다음 작업 | 마지막 갱신 |
| --- | --- | --- | --- | --- | --- |
| `Phase 0` | `completed` | alias 기반 전환 토대 구축 | `fire_ember_dart`, `water_aqua_bullet`, `wind_gale_cutter`, `holy_mana_veil` | 없음 | 2026-04-02 |
| `Phase 1` | `completed` | 즉시 안전한 runtime-connected alias 확장 | `plant_vine_snare`, `ice_glacial_dominion`, `earth_terra_break` | 없음 | 2026-04-02 |
| `Phase 2` | `completed` | canonical row의 최신 한글 표기/설명 정렬 | `holy_healing_pulse`, `dark_abyss_gate`, `lightning_tempest_crown`, `dark_soul_dominion`, `dark_shadow_bind`, `dark_grave_echo`, `dark_grave_pact`, `lightning_conductive_surge`, `plant_worldroot_bastion`, `plant_verdant_overflow`, `holy_crystal_aegis`, `holy_sanctuary_of_reversal`, `dark_throne_of_ash`, `wind_tempest_drive` | 없음 | 2026-04-02 |
| `Phase 3` | `completed` | 레거시 combat row의 1:1 재해석 확정 | `ice_frost_needle`, `earth_stone_spire`, `lightning_thunder_lance`, `fire_flame_arc`, `water_tidal_ring` | 없음 | 2026-04-02 |
| `Phase 4` | `completed` | 설치/유틸 보조 레거시 row 처리 | `ice_ice_wall`, `fire_inferno_sigil` | 없음 | 2026-04-02 |
| `Phase 5` | `completed` | 패시브 / 버프 / 미사용 row 일괄 정리 | `fire_mastery`, `water_mastery`, `ice_mastery`, `lightning_mastery`, `wind_mastery`, `earth_mastery`, `plant_mastery`, `dark_magic_mastery`, `fire_pyre_heart`, `ice_frostblood_ward`, `arcane_magic_mastery`, `arcane_astral_compression`, `arcane_world_hourglass` | 없음 | 2026-04-02 |
| `Phase 6` | `completed` | 최종 row key rename 필요성 재평가 | `holy_healing_pulse`, `dark_abyss_gate`, `lightning_tempest_crown`, `plant_genesis_arbor` | row key rename 없이 유지 결론 고정, 후속은 검증/정리 증분 | 2026-04-02 |

## 핵심 원칙

### 1. `skill_id`는 한 번에 갈아엎지 않는다

- 전환기에는 현재 row key를 유지한다.
- 최신 장기 식별자는 `canonical_skill_id`로 먼저 붙인다.
- 코드, 테스트, UI, save, admin 흐름이 모두 canonical 조회를 수용한 뒤에만 row key rename 여부를 다시 판단한다.

### 2. 최신 기획과 1:1 대응이 확정된 row만 먼저 옮긴다

- 최신 이름/컨셉이 명확하고 runtime 프록시가 이해 가능한 row부터 옮긴다.
- 역할이 애매한 row는 `canonical_skill_id`를 성급히 붙이지 않는다.
- 단, 2026-04-02 사용자 운영 규칙 기준으로 planning 공통 보강을 먼저 할 때는 아래 기본값을 우선 적용한다.
  - 다른 스킬에 흡수하지 않는다.
  - `canonical_skill_id = 현재 row key`
  - 서클은 현재 `skills.json` 값 유지
  - `hit_shape`는 스킬 이름과 현재 설명을 기준으로 보수 추론

### 3. 한 번의 증분은 1~3 row 수준으로 제한한다

- 데이터 전환은 작게 나눠야 테스트 실패 지점을 빠르게 좁힐 수 있다.
- 각 증분은 `구현/데이터 수정 -> 검증 -> migration plan / tracker / design 문서 갱신 -> 다음 안전 증분 명시` 순서로 닫는다.

### 4. `canonical_skill_id`는 장기 식별자이며 쉽게 바꾸지 않는다

- UI 표시 이름, runtime proxy, 이펙트 연결은 나중에 바뀔 수 있다.
- canonical `skill_id`는 바뀌지 않는 기준 키로 유지한다.

### 5. 기획 구체화 라운드에서 자동 보충 가능한 항목과 질문이 필요한 항목을 분리한다

- 2026-04-02 Phase 3~4 구체화 라운드 기준으로, 아래 조건이 이미 잠기면 문서와 데이터는 안전하게 자동 보충할 수 있다.
  - 다른 스킬에 흡수하지 않음
  - `canonical_skill_id = 현재 row key`
  - 현재 서클 유지
  - 현재 row 자체 또는 현재 proxy를 runtime 축으로 유지
  - 인접 최신 스킬과의 차별점이 이름이 아니라 `범위 모양`, `역할`, `burst 예산`, `관통/제어 성격` 중 하나로 설명 가능
- 위 조건이 잠긴 경우 이번 단계에서 자동 보충 가능한 항목:
  - `canonical_skill_id = 현재 row key`
  - 최신 한글 `display_name`
  - 핵심 전투 경험 1문장 `description`
  - `hit_shape`
  - 최소 `role_tags`
  - tracker의 runtime 축 / proxy / 차별점 메모
- 반대로 아래 항목은 사용자 의사결정 없이는 잠그지 않는다.
  - 사용자 hotbar/save 노출 여부
  - 핵심 전투 경험
  - 전투 역할
  - 인접 최신 스킬과의 차별점
  - 현재 runtime 축 / proxy 유지 여부
  - 최신 표시 이름
- `Phase 5`에서도 mastery / buff / user-facing row는 위 규칙을 재사용할 수 있다.
- `arcane_*` row도 canonical 식별자 자체는 위 규칙을 우선 적용할 수 있지만, 속성 / 계열 재분류 메모는 별도 후속 판단으로 남긴다.

### 5. tracker와 migration plan은 함께 움직인다

- row를 전환했으면 tracker의 이름, runtime 참조, 구현 상태를 같은 증분에서 갱신한다.
- tracker가 앞서 설계를 정의하지는 않지만, 전환 완료 여부는 반드시 tracker에서 보이게 해야 한다.

## 마이그레이션 클래스

`skills.json` row는 아래 5개 클래스로 나눠 관리한다.

### Class A. 이미 canonical인 row

- 현재 `skill_id`가 최신 장기 식별자와 사실상 같다.
- `canonical_skill_id`는 생략 가능하다.
- 필요한 작업은 `display_name`, `description`, `role_tags` 최신화 정도다.

예:

- `holy_healing_pulse`
- `dark_abyss_gate`
- `dark_soul_dominion`
- `lightning_tempest_crown`
- `dark_shadow_bind`

### Class B. legacy row key + 1:1 canonical 대상이 확정된 row

- 현재 `skill_id`는 legacy지만, 최신 기획의 대응 스킬이 분명하다.
- 이 경우 `canonical_skill_id`를 먼저 붙이고 row key는 유지한다.

예:

- `fire_ember_dart -> fire_bolt`
- `water_aqua_bullet -> water_bullet`
- `wind_gale_cutter -> wind_cutter`
- `plant_vine_snare -> plant_root_bind`
- `earth_terra_break -> earth_quake_break`
- `ice_glacial_dominion -> ice_frozen_domain`

### Class C. canonical row는 있으나 runtime proxy가 따로 있는 row

- `skills.json`의 장기 식별자는 이미 맞다.
- 실제 현재 빌드에서는 다른 runtime spell ID가 그 역할을 프록시하고 있다.
- 이 경우 `skills.json`보다 tracker/runtime mapping 정리가 우선이다.

예:

- `holy_healing_pulse` row <-> runtime `holy_radiant_burst`
- `dark_abyss_gate` row <-> runtime `dark_void_bolt`
- `lightning_tempest_crown` row <-> runtime `lightning_tempest_crown`
- `dark_soul_dominion` row <-> runtime `dark_soul_dominion`

### Class D. legacy row지만 최신 1:1 대응이 아직 애매한 row

- 성급히 canonical `skill_id`를 붙이면 나중에 다시 바뀔 가능성이 크다.
- 이 그룹은 `보류`로 두고, 최신 기획에서 대체/흡수/아카이브 여부를 먼저 결정한다.

예:

- `ice_frost_needle`
- `earth_stone_spire`
- `fire_flame_arc`
- `water_tidal_ring`
- `lightning_thunder_lance`
- `ice_ice_wall`
- `fire_inferno_sigil`

### Class E. arcane / 레거시 재분류 대기 row

- 2026-04-02 사용자 답변으로 source of truth를 잠갔다.
- canonical 식별자는 모두 `row key = canonical_skill_id` 기본값으로 유지한다.
- `arcane`은 현재 runtime에서 독립 `school / element` 축을 유지한다.
- 단, 각 row의 실제 적용 범위는 아래처럼 분리해서 읽는다.
  - `arcane_magic_mastery`: 아케인 스킬을 강화하는 대표 mastery이지만 패시브 효과 적용 범위는 `all`
  - `arcane_astral_compression`: 공용 `마나 효율 버프`
  - `arcane_world_hourglass`: 공용 `극딜 창구 버프`

예:

- `arcane_magic_mastery`
- `arcane_astral_compression`
- `arcane_world_hourglass`

## 단계별 실행 계획

### Phase 0. 기반 작업

상태: 완료

목표:

- canonical alias 해석 경로를 먼저 만들고, 문서 구조를 장기 운영형으로 고정한다.

완료 조건:

- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`가 `canonical_skill_id` alias 조회를 지원한다.
- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md`가 문서 우선순위를 고정한다.
- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md`가 canonical `skill_id` 기준으로 추적한다.
- 첫 4개 row가 canonical 전환 예시로 정렬되어 있다.

### Phase 1. 즉시 안전한 runtime-connected alias 확장

우선순위: 가장 높음

대상 row:

| 현재 `skill_id` | 목표 canonical `skill_id` | 이유 |
| --- | --- | --- |
| `plant_vine_snare` | `plant_root_bind` | tracker/design 모두 1:1 대응이 이미 잠겨 있음 |
| `ice_glacial_dominion` | `ice_frozen_domain` | tracker/design에서 `프로즌 도메인`으로 이미 정리됨 |
| `earth_terra_break` | `earth_quake_break` | 현재 burst 프록시가 `퀘이크 브레이크` 축으로 가장 가깝게 잠겨 있음 |

작업 범위:

1. `skills.json`
   - `canonical_skill_id` 추가
   - `display_name`를 최신 한글 이름으로 정렬
   - `description`, `role_tags`를 최신 설계 방향으로 최소 정리
2. tracker
   - 이름/상태/비고 동기화
3. 테스트
   - canonical alias 조회 GUT 추가/확장
4. 필요 시 UI 문자열 기대치 수정

비고:

- 이 단계에서는 row key를 rename 하지 않는다.
- runtime `spell_id`도 바꾸지 않는다.

완료 기준:

- `GameDatabase.get_skill_data(canonical_skill_id)` 조회가 성공한다.
- tracker에서 해당 row의 이름과 runtime 참조가 최신 기준으로 읽힌다.
- headless + GUT가 통과한다.

### Phase 2. canonical row 자체는 맞는 스킬의 한글 표기/설명 정렬

우선순위: 높음

대상 row:

- `holy_healing_pulse`
- `dark_abyss_gate`
- `lightning_tempest_crown`
- `dark_soul_dominion`
- `dark_shadow_bind`
- `dark_grave_echo`
- `dark_grave_pact`
- `lightning_conductive_surge`
- `plant_worldroot_bastion`
- `plant_verdant_overflow`
- `holy_crystal_aegis`
- `holy_sanctuary_of_reversal`
- `dark_throne_of_ash`
- `wind_tempest_drive`

작업 범위:

1. `skills.json`
   - `display_name`를 최신 한글 발음 표기로 정렬
   - 최신 설계와 어긋나는 `description`, `role_tags`, `element`만 최소 수정
2. tracker
   - `planned/prototype/runtime` 상태와 비고 업데이트
3. 필요 시 테스트 문자열 갱신

완료 기준:

- canonical row 이름이 최신 설계와 맞다.
- tracker와 design 문서 간 이름 충돌이 사라진다.
- 테스트 문자열이 최신 표기를 따른다.

### Phase 3. 레거시 combat row의 1:1 재해석 확정

우선순위: 중간

대상 row:

- `ice_frost_needle`
- `earth_stone_spire`
- `fire_flame_arc`
- `water_tidal_ring`
- `lightning_thunder_lance`

이 단계의 핵심 질문:

- 이 row를 최신 코어 라인업의 어떤 canonical 스킬로 흡수할 것인가?
- 아니면 레거시 row로 아카이브하고 새 canonical row를 별도로 만들 것인가?

권장 규칙:

- 동작과 컨셉이 최신 스킬과 70% 이상 겹치면 `canonical_skill_id`를 붙인다.
- 그렇지 않으면 새 canonical row를 만들고, 기존 row는 `legacy_notes` 수준으로만 유지하거나 추후 제거 대상으로 분류한다.

2026-04-02 확정:

- `ice_frost_needle`는 `ice_spear`에 흡수하지 않는다.
- canonical `skill_id`는 row key와 같은 `ice_frost_needle`로 유지한다.
- 최신 운영 기준 역할은 `짧은 쿨마다 끼워 넣는 slow + pierce projectile poke`이며, 화력 예산은 `3서클급 준메인 딜`까지 허용한다.
- 현재 runtime proxy는 `frost_nova`로 유지하고, save / hotbar의 레거시 runtime 흐름은 자동 치환 우선 원칙으로 해석한다.

완료 기준:

- 각 row가 `흡수 / 분리 / 아카이브` 중 하나로 결정된다.
- tracker의 `레거시 / 재분류 대기` 목록과 design 문서가 일치한다.

### Phase 4. 설치/유틸 보조 레거시 row 처리

우선순위: 중간

대상 row:

- `ice_ice_wall`
- `fire_inferno_sigil`

이 그룹은 코어 4속성 라인업보다 `보조 설치형/특수 라인`에 가깝다.

처리 원칙:

- 최신 설계에 정식 자리가 있으면 canonical 축에 편입한다.
- 정식 자리가 없으면 레거시 row로 명시하고 당장 canonical 전환하지 않는다.

### Phase 5. 패시브 / 버프 / 미사용 row 일괄 정리

우선순위: 중간

대상 row:

- `arcane_magic_mastery`
- `fire_mastery`
- `water_mastery`
- `ice_mastery`
- `lightning_mastery`
- `wind_mastery`
- `earth_mastery`
- `plant_mastery`
- `dark_magic_mastery`
- `fire_pyre_heart`
- `ice_frostblood_ward`
- `arcane_astral_compression`
- `arcane_world_hourglass`

처리 원칙:

- canonical `skill_id`가 이미 현재 row key와 같으면 row key 유지
- `display_name`, `description`, `school`, `element`만 최신 설계에 맞춰 정리
- arcane 재분류가 끝나기 전까지는 `arcane_*` row를 성급히 이동시키지 않음

### Phase 6. 최종 row key 정리 여부 재평가

우선순위: 마지막

이 단계는 **필수 아님**이다.

질문:

- `skill_id` 자체도 canonical 값으로 바꿀 것인가?
- 아니면 row key는 legacy를 유지하고 `canonical_skill_id` + alias 조회 구조로 장기 운영할 것인가?

권장 판단:

- save 파일, 런타임 lookup, admin/debug 명령, 테스트 문자열이 모두 canonical 기준으로 정리되기 전에는 row key rename을 하지 않는다.
- canonical 조회가 충분히 안정적이면 row key rename 없이 운영하는 것도 허용한다.

즉, 이 단계는 “정리 욕심”보다 “실제 안정성”을 우선한다.

## 증분 단위 작업 절차

각 증분은 아래 순서로 반복한다.

1. 대상 row 1~3개 선택
2. 최신 설계와 tracker 확인
3. `skills.json` 수정
4. 필요 시 `spells.json`, UI 기대 문자열, 테스트 기대값 수정
5. alias/GUT 검증
6. tracker / runtime baseline / 관련 문서 동기화
7. 다음 증분 선택

## 각 증분의 필수 검증

- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

추가 체크:

- `GameDatabase.get_skill_data(skill_id)` 기존 조회 유지
- `GameDatabase.get_skill_data(canonical_skill_id)` alias 조회 성공
- tracker 이름/상태와 실제 데이터 row가 일치

## 반복 실행 프롬프트 템플릿

아래 프롬프트를 반복 입력용 기본 템플릿으로 사용한다.

```text
너는 시니어 게임 개발자이자 Dungeon Mage의 데이터 마이그레이션 작업자다.

이번 작업은 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/skills/skills.json`을
canonical `skill_id` 기준으로 단계적으로 정렬하는 것이다.

가장 중요한 기준 문서:
1. `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/plans/skills_json_canonical_migration_plan.md`
2. `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md`
3. `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md`
4. `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md`
5. `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md`
6. `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md`

핵심 규칙:
- 최신 운영 문서를 우선한다.
- `skill_id` row key는 바꾸지 않고 `canonical_skill_id`만 먼저 붙인다.
- 한 번에 1~3 row만 처리한다.
- 각 증분은 `구현 -> 검증 -> 문서 업데이트`까지 닫는다.
- 현재 가장 작은 안전 증분이 없고 문서도 이미 최신이면, 억지로 추가 파일 수정을 만들지 말고 중단 이유만 남긴다.
- 작업 완료로 인정하려면 반드시 아래 문서를 갱신한다.
  1. `docs/progression/plans/skills_json_canonical_migration_plan.md`
     - `Phase 진행 상태`
     - 이번에 완료한 row
     - 다음 안전 증분
  2. `docs/progression/trackers/skill_implementation_tracker.md`
     - 해당 row 상태
  3. `docs/progression/rules/skill_system_design.md`
     - canonical 전환 예시 / runtime proxy 메모 / blocked 상태 메모
  4. 필요 시 `docs/implementation/baselines/current_runtime_baseline.md`

세션 시작 순서:
1. `git status --short`
2. 기준 문서 읽기
3. migration plan의 현재 `Phase 진행 상태` 확인
4. 지금 가장 작은 안전 증분 1개 선택

이번 턴 작업:
1. 대상 row 1~3개를 고른다.
2. 왜 지금 안전한지 짧게 설명한다.
3. 필요한 범위만 수정한다.
4. 아래 검증을 수행한다.
   - `godot --headless --path . --quit`
   - `godot --headless --path . --quit-after 120`
   - `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
5. 검증 통과 후 문서 완료 기록까지 반영한다.

최종 출력에 반드시 포함:
1. 이번에 완료한 phase / row
2. 수정한 파일
3. 검증 결과
4. migration plan에 반영한 완료 내용
5. tracker에 반영한 상태 변화
6. 다음 안전 증분
```

## 파일별 책임

### 반드시 같이 볼 파일

- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/skills/skills.json`
- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd`
- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md`
- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md`
- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md`
- `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md`

### 상황별 추가 파일

- runtime 표기 변경 시:
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/spells.json`
- 문자열 기대값 변경 시:
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd`
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_spell_manager.gd`
- alias 조회 테스트 확장 시:
  - `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_state.gd`

## 당장 다음 증분

현재 가장 작은 안전한 row-level canonical 증분은 없다. 2026-04-02 사용자 결정으로 `holy_healing_pulse`, `dark_abyss_gate`, `lightning_tempest_crown`, `plant_genesis_arbor`는 모두 row key rename 없이 유지하기로 잠겼고, 이번 증분에서 네 row 모두 row key와 같은 `canonical_skill_id` 명시를 마쳤다.

또한 뒤 단계인 `Phase 5`, `Phase 6`은 현재 blocked 상태를 우회하기 위한 대체 작업으로 올리지 않는다.

최신 기획, 현재 runtime 사실, 문서 규칙 중 새로 바뀐 사실이 없다면 blocked 상태에서는 추가 repo 수정을 만들지 않고 중단 이유만 남긴다. 단, 사용자가 기획 구체화를 직접 요청한 턴에는 질문 라운드를 먼저 연다.

순서:

1. `fire_mastery` post-migration verification 기준선은 유지한다. 현재 확인된 사실은 `SCHOOL_TO_MASTERY["fire"]`와 `register_skill_damage("fire_bolt", dealt)` 경유 XP/레벨 progression hook까지이며, `final_multiplier_per_level` / `threshold_bonuses`의 전투 적용은 아직 data-only다.
2. `water_mastery`도 같은 패턴으로 검증했다. 현재 확인된 사실은 `SCHOOL_TO_MASTERY["water"]`와 `register_skill_damage("water_aqua_bullet", dealt)` 경유 XP/레벨 progression hook까지이며, `final_multiplier_per_level` / `threshold_bonuses`의 전투 적용은 아직 data-only다.
3. `ice_mastery`도 같은 패턴으로 검증했다. 현재 확인된 사실은 `SCHOOL_TO_MASTERY["ice"]`와 `register_skill_damage("frost_nova", dealt)` 경유 XP/레벨 progression hook까지이며, `final_multiplier_per_level` / `threshold_bonuses`의 전투 적용은 아직 data-only다.
4. `lightning_mastery`도 같은 패턴으로 검증했다. 현재 확인된 사실은 `SCHOOL_TO_MASTERY["lightning"]`와 `register_skill_damage("volt_spear", dealt)` 경유 XP/레벨 progression hook까지이며, `final_multiplier_per_level` / `threshold_bonuses`의 전투 적용은 아직 data-only다.
5. `wind_mastery`도 같은 패턴으로 검증했다. 현재 확인된 사실은 `SCHOOL_TO_MASTERY["wind"]`와 `register_skill_damage("wind_gale_cutter", dealt)` 경유 XP/레벨 progression hook까지이며, `final_multiplier_per_level` / `threshold_bonuses`의 전투 적용은 아직 data-only다.
6. `earth_mastery`도 같은 패턴으로 검증했다. 현재 확인된 사실은 `SCHOOL_TO_MASTERY["earth"]`와 `register_skill_damage("earth_tremor", dealt)` 경유 XP/레벨 progression hook까지이며, `final_multiplier_per_level` / `threshold_bonuses`의 전투 적용은 아직 data-only다.
7. `plant_vine_snare`를 `data/spells.json`의 plant school runtime spell entry로 정의했고, `plant_mastery`도 같은 패턴으로 검증했다. 현재 확인된 사실은 `SCHOOL_TO_MASTERY["plant"]`와 `register_skill_damage("plant_vine_snare", dealt)` 경유 XP/레벨 progression hook까지이며, `final_multiplier_per_level` / `threshold_bonuses`의 전투 적용은 아직 data-only다.
8. `dark_magic_mastery`도 같은 패턴으로 검증했다. 현재 확인된 사실은 `SCHOOL_TO_MASTERY["dark"]`와 `register_skill_damage("dark_void_bolt", dealt)` 경유 XP/레벨 progression hook까지이며, `final_multiplier_per_level` / `threshold_bonuses`의 전투 적용은 아직 data-only다.
9. 토글 대표 row로 `lightning_tempest_crown`를 골라 level 1의 base `pierce = 2`, level 24 milestone 이후 `pierce = 4`가 실제 tick payload에 반영됨을 검증했다. 따라서 이 row의 level scaling 상태는 `verified`로 끌어올린다.
10. 설치형 대표 row로 `plant_root_bind`를 골라 `plant_vine_snare` runtime proxy의 deploy payload `duration`과 `size`가 level 1 대비 level 30에서 실제 증가함을 검증했다. 따라서 이 row의 level scaling 상태는 `verified`로 끌어올린다.
11. burst 대표 row로 `arcane_world_hourglass`를 골라 buff activation 후 cooldown 압축, downside penalty, level 1 대비 level 30 duration scaling이 실제 runtime에 반영됨을 검증했다. 따라서 이 row의 검증 상태는 `verified`로 끌어올린다.
12. `Phase 6` rename 유지 결론을 기준으로 save/UI/runtime 잔여 리스크를 재검토한다.
13. 필요하면 `current_runtime_baseline.md`와 tracker의 검증 상태를 후속 증분으로 끌어올린다.

Phase 2의 canonical row 표기 정렬은 종료됐다. `holy_healing_pulse`, `dark_abyss_gate`, `lightning_tempest_crown`, `dark_soul_dominion`, `dark_shadow_bind`, `dark_grave_echo`, `dark_grave_pact`, `lightning_conductive_surge`, `plant_worldroot_bastion`, `plant_verdant_overflow`, `holy_crystal_aegis`, `holy_sanctuary_of_reversal`, `dark_throne_of_ash`, `wind_tempest_drive`는 최신 한글 표기와 현재 runtime 기준의 프록시 설명 정렬을 마쳤다. `ice_frost_needle`는 2026-04-02 답변으로 `ice_spear`에 흡수하지 않고 별도 canonical row로 유지하기로 잠겼으며, 현재 runtime proxy는 `frost_nova`로 유지한다. `earth_stone_spire`도 2026-04-02 답변으로 `earth_spike` 3서클 core slot에 흡수하지 않고 별도 canonical row로 유지하기로 잠겼고, `canonical_skill_id`는 row key와 같은 `earth_stone_spire`로 먼저 명시한다. 최신 운영 표기명은 `어스 스파이크`, 역할은 `2서클 즉발 cone 주력 설치기`로 정리하고 사용자 노출을 유지한다. `lightning_thunder_lance`도 2026-04-02 답변으로 `lightning_bolt`, `lightning_thunder_arrow`에 흡수하지 않고 별도 canonical row로 유지하기로 잠겼고, `canonical_skill_id`는 row key와 같은 `lightning_thunder_lance`로 먼저 명시한다. 최신 운영 표기명은 `썬더 랜스`, 역할은 `중간 쿨 강한 일직선 보스용 버스터`로 정리하고 사용자 노출을 유지한다. 현재 runtime proxy는 `volt_spear`로 유지하며, `lightning_bolt`와의 차이는 관통, `lightning_thunder_arrow`와의 차이는 burst 계수로 정리한다. `fire_flame_arc`도 2026-04-02 답변으로 `fire_burst`에 흡수하지 않고 별도 canonical row로 유지하기로 잠겼고, `canonical_skill_id`는 row key와 같은 `fire_flame_arc`로 먼저 명시한다. 최신 운영 표기명은 `플레임 써클`, 역할은 `3서클 원형 폭발 사냥형 광역 버스터`로 정리하고 사용자 노출을 유지한다. 현재 runtime 축은 row 자체를 그대로 유지하며, `fire_burst`와의 차별점은 범위 모양으로 정리한다. `water_tidal_ring`도 2026-04-02 답변으로 `water_wave`에 흡수하지 않고 별도 canonical row로 유지하기로 잠겼고, `canonical_skill_id`는 row key와 같은 `water_tidal_ring`으로 먼저 명시한다. 최신 운영 표기명은 `타이달 링`, 역할은 `3서클 원형 밀쳐내기 물 제어기`로 정리하고 사용자 노출을 유지한다. 현재 runtime 축은 row 자체를 그대로 유지하며, `water_wave`와의 차별점은 범위 모양으로 정리한다. `ice_ice_wall`도 2026-04-02 답변을 기준으로 `canonical_skill_id`를 row key와 같은 `ice_ice_wall`로 유지하는 별도 canonical row로 정리한다. 최신 운영 표기명은 `아이스 월`, 역할은 `4서클 얼음 장벽 생성형 제어기`이며, 현재 runtime 축은 row 자체를 그대로 유지한다. `fire_inferno_sigil`도 2026-04-02 답변으로 `fire_flame_storm`, `fire_inferno_buster`에 흡수하지 않고 별도 canonical row로 유지하기로 잠겼고, 이번 증분에서 `canonical_skill_id = fire_inferno_sigil`, 최신 운영 표기명 `인페르노 시길`, 반복 폭발 기반 설명, `circle` hit shape, `boss_burst`/`mob_clear` role tag 정렬까지 반영했다. 이어서 `fire_mastery`, `water_mastery`, `ice_mastery`, `lightning_mastery`, `wind_mastery`, `earth_mastery`, `plant_mastery`, `dark_magic_mastery`도 `row key = canonical_skill_id` 기본값에 따라 패시브 canonical 유지 row로 순차 정렬했다. `fire_pyre_heart`, `ice_frostblood_ward`도 같은 기본값으로 정렬해 non-arcane Phase 5 row는 모두 닫혔다. 2026-04-02 사용자 답변으로는 남은 `arcane_*` 3개 row의 source of truth도 잠겼고, `arcane_magic_mastery`, `arcane_astral_compression`, `arcane_world_hourglass`까지 이번 단계에서 정렬을 마쳤다. `canonical_skill_id = arcane_magic_mastery`, 최신 운영 표기명 `아케인 마스터리`, 아케인 축을 대표하면서 모든 마법의 효율과 이해도를 높이는 1서클 공용 마스터리 설명, alias 테스트까지 반영했다. `arcane_astral_compression`은 `canonical_skill_id = arcane_astral_compression`, 최신 운영 표기명 `아스트랄 압축`, 모든 마법의 마나 효율을 끌어올리는 8서클 공용 아케인 버프 설명, alias 테스트까지 반영했다. `arcane_world_hourglass`는 `canonical_skill_id = arcane_world_hourglass`, 최신 운영 표기명 `월드 아워글래스 오브 아케인`, 모든 마법의 극딜 창구를 여는 9서클 공용 아케인 버프 설명, alias 테스트까지 반영했다. 또한 2026-04-02 사용자 결정으로 `holy_healing_pulse`, `dark_abyss_gate`, `lightning_tempest_crown`, `plant_genesis_arbor`는 모두 row key rename 없이 유지하기로 잠겼고, 이번 증분에서는 `plant_genesis_arbor`까지 포함해 네 row 모두 row key와 같은 `canonical_skill_id`를 명시했다. 따라서 row-level canonical 마이그레이션은 문서 기준으로 모두 정렬 완료됐고, 다음 단계는 검증/후속 정리 증분이다.

## 비목표

- 이 문서는 한 번에 모든 row key를 rename 하지 않는다.
- 이 문서는 save 호환성까지 한 번에 닫지 않는다.
- 이 문서는 `arcane_force_pulse` 같은 미정 계열을 성급히 canonical 구조에 넣지 않는다.
- 이 문서는 effect/asset 구현 자체를 정의하지 않는다. 그것은 tracker와 구현 사이클의 다음 단계다.
