---
title: 성장 시스템 인덱스
doc_type: index
status: active
section: progression
owner: design
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/target_doc_structure.md
update_when:
  - structure_changed
  - rule_changed
last_updated: 2026-04-06
last_verified: 2026-04-06
---

# 성장 시스템 인덱스

상태: 사용 중  
최종 갱신: 2026-04-06

## 범위

이 섹션은 플레이어가 어떻게 강해지는지, 어떤 성장 시스템이 존재하는지, 현재 어떤 스킬 목록과 성장 구조가 정설인지 정의합니다.

2026-04-02 기준으로 이 섹션은 `rules / catalogs / schemas / trackers / plans / archive` 하위 폴더 1차 분리를 완료했습니다.

이 섹션의 상세 문서 등록 책임은 이 `README.md`가 가집니다. 루트 `docs/README.md`에는 대표 진입점만 유지합니다.

## 문서 구조

### `rules`

- [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)
  - 최신 스킬 기획 소스 오브 트루스
  - 속성 구조, 상성, 서클 라인업, 이름, 전투 컨셉은 이 문서를 우선한다.
- [progression_overview.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/progression_overview.md)
- [skill_level_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_level_rules.md)
- [circle_progression.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/circle_progression.md)
- [buff_system.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/buff_system.md)
- [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)

### `catalogs`

- [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md)
- [mastery_skills.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/mastery_skills.md)
- [buff_skill_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_skill_catalog.md)
- [buff_combo_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md)
- [buff_combo_effect_tag_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_effect_tag_catalog.md)
  - `buff_combos.json` `effect_tags`의 현재 운영 태그 목록과 의미
- [buff_combo_apply_status_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_apply_status_catalog.md)
  - `buff_combos.json` `trigger_rules[].apply_status`의 현재 운영 태그와 warning-only 관리 기준
- [buff_combo_stack_key_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_stack_key_catalog.md)
  - `buff_combos.json` `trigger_rules[].stack_name / scales_with_stack`의 현재 운영 관리 키
- [buff_category_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_category_catalog.md)
  - `skills.json` buff row `buff_category`의 현재 운영 관리 ID와 의미
- [buff_stack_rule_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_stack_rule_catalog.md)
  - `skills.json` buff row `stack_rule_id`의 현재 운영 관리 ID와 의미
- [buff_combo_tag_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_tag_catalog.md)
  - `skills.json` buff row `combo_tags`의 현재 운영 태그 목록과 의미
- [skill_role_tag_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/skill_role_tag_catalog.md)
  - `skills.json` `role_tags`의 현재 운영 태그 목록과 의미
- [skill_growth_track_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/skill_growth_track_catalog.md)
  - `skills.json` `growth_tracks`의 현재 운영 성장축 목록과 의미

### `schemas`

- [skill_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md)
  - 스킬 데이터 필드와 enum-like 허용값 정의
- [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md)
- [buff_combo_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/buff_combo_data_schema.md)

### `trackers`

- [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)
  - 구현 여부, asset 적용 여부, attack/hit effect 여부, 레벨 스케일 반영 여부 추적
- [enemy_content_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md)

### `plans`

- [skills_json_canonical_migration_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/plans/skills_json_canonical_migration_plan.md)
  - `data/skills/skills.json`을 canonical `skill_id` 기준으로 단계적으로 정렬하는 실행 계획
  - phase 진행 상태와 완료 기록도 이 문서에 누적한다.
- [skill_effect_asset_mapping_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/plans/skill_effect_asset_mapping_plan.md)
  - `asset_sample/Effect/new` 신규 이펙트를 기존 스킬, 보완 대상 스킬, 신규 스킬 후보로 분류한 반영 계획
  - direct attach 우선순위, 기획 보완안, 신규 스킬 기획 초안을 함께 관리한다.

### `archive`

- [spell_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/archive/spell_catalog.md)
  - 프로토타입 마법 카탈로그 아카이브
- [spell_concept_rework_2026-04-02.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/archive/spell_concept_rework_2026-04-02.md)
  - 리워크 이력용 스냅샷 아카이브

## 우선순위 규칙

이 섹션은 단일 숫자 우선순위보다 `질문 종류별 소스 오브 트루스`를 먼저 따른다.

### 최신 기획

- 질문:
  - 이 스킬의 최신 이름은 무엇인가
  - 어느 서클 / 속성 / 타입에 속하는가
  - 원래 의도한 컨셉과 레벨 성장 목표는 무엇인가
- 기준 문서:
  - [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)
- 규칙:
  - 이름, 속성, 서클, 역할, 라인업, 목표 경험은 항상 이 문서를 최우선으로 본다.
  - 다른 문서는 최신 기획을 재정의할 수 없다.

### 런타임 사실

- 질문:
  - 지금 빌드에서 실제로 어떤 스킬이 돌아가는가
  - 실제 runtime ID, 현재 동작, 프록시 구현, 검증 통과 상태는 무엇인가
- 기준 문서:
  - [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)
  - 실제 코드와 데이터 파일
- 규칙:
  - 런타임 사실은 `기획 문서`가 아니라 코드와 runtime baseline이 결정한다.
  - 코드와 runtime baseline이 다르면 코드를 먼저 사실로 보고, 이후 baseline을 맞춘다.

### 상태 추적

- 질문:
  - 구현되었는가
  - asset이 붙었는가
  - attack effect / hit effect가 붙었는가
  - 레벨 스케일이 반영되었는가
- 기준 문서:
  - [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)
- 규칙:
  - tracker는 `상태 보고 문서`다.
  - tracker는 최신 기획이나 런타임 사실을 정의하지 않는다.
  - tracker는 항상 `skill_system_design.md`와 `current_runtime_baseline.md` 또는 실제 코드를 따라가며 갱신한다.

### 데이터 스키마

- 질문:
  - 어떤 필드를 채워야 하는가
  - 어떤 enum-like 값이 허용되는가
  - canonical `skill_id`와 JSON 구조는 어떻게 관리하는가
- 기준 문서:
  - [skill_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md)
- 규칙:
  - 스키마 문서는 데이터 형식과 허용값을 정의한다.
  - 스키마 문서는 최신 기획 이름이나 현재 구현 상태를 직접 결정하지 않는다.

### 몬스터 문서 체계

- 질문:
  - 어떤 몬스터가 현재 정식 편입 대상인가
  - 각 몬스터의 역할, 차별점, 엘리트 후보 여부는 무엇인가
  - `enemies.json`에는 어떤 필드를 어떤 기준으로 채워야 하는가
  - 적 스탯/저항/슈퍼아머 계산 규칙은 어디서 고정하는가
  - 어떤 몬스터가 실제 구현 / 에셋 반영 / 테스트 반영 상태인가
- 기준 문서:
  - [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md)
  - [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md)
  - [enemy_content_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md)
  - [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)
  - [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)
- 규칙:
  - 몬스터 roster, 역할, 엘리트 후보, 우선 편입 순서는 `enemy_catalog.md`를 우선한다.
  - `data/enemies/enemies.json`의 필드 구조, enum-like 값, validation 기준은 `enemy_data_schema.md`를 우선한다.
  - 구현 / 에셋 / 테스트 반영 상태는 `enemy_content_tracker.md`를 우선한다.
  - 방어력, 속성 저항, 상태이상 저항, 슈퍼아머, 최종 피해 계산은 `enemy_stat_and_damage_rules.md`를 우선한다.
  - 실제 현재 빌드 반영 상태는 코드와 `current_runtime_baseline.md`가 결정한다.

### 레거시 / 아카이브

- 기준 문서:
  - [spell_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/archive/spell_catalog.md)
  - [spell_concept_rework_2026-04-02.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/archive/spell_concept_rework_2026-04-02.md)
- 규칙:
  - 과거 문서는 참고만 한다.
  - 최신 운영 문서와 충돌하면 항상 최신 운영 문서를 따른다.

### 충돌 해결 순서

1. 최신 기획 충돌:
   - `skill_system_design.md`를 기준으로 정리한다.
2. 실제 동작 충돌:
   - 코드 -> `current_runtime_baseline.md` 순으로 사실을 확정한다.
3. 구현 상태 충돌:
   - `skill_implementation_tracker.md`를 실제 코드와 runtime baseline에 맞춰 수정한다.
4. 필드 / enum 충돌:
   - `skill_data_schema.md`를 기준으로 JSON 구조를 정리한다.
5. 아카이브 충돌:
   - 아카이브는 절대 최신 기준을 덮어쓰지 않는다.

### 요약 우선순위

질문별로 아래처럼 고정해서 읽는다.

1. 최신 기획: `skill_system_design.md`
2. 실제 런타임 사실: 코드 -> `current_runtime_baseline.md`
3. 구현 / asset / effect / 레벨 스케일 상태: `skill_implementation_tracker.md`
4. 데이터 형식 / enum-like 허용값: `skill_data_schema.md`
5. 과거 참고: 레거시 / 아카이브 문서

몬스터 관련 질문은 아래처럼 고정해서 읽는다.

1. 몬스터 roster / 역할 / 편입 우선순위: `enemy_catalog.md`
2. 실제 런타임 사실: 코드 -> `current_runtime_baseline.md`
3. 수치 규칙 / 피해 계산 / 저항 / 슈퍼아머: `enemy_stat_and_damage_rules.md`
4. 적 데이터 형식 / 필수 필드 / 허용값: `enemy_data_schema.md`
5. 구현 / 에셋 / 테스트 반영 상태: `enemy_content_tracker.md`
6. 구현 증분 핸드오프: `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`

## 수정 규칙

- 문서 타입에 따라 아래 하위 폴더를 먼저 확인한다.
  - 규칙 변경: `rules/`
  - 콘텐츠 목록 변경: `catalogs/`
  - 필드/허용값 변경: `schemas/`
  - 구현 상태 변경: `trackers/`
  - 마이그레이션/증분 계획 변경: `plans/`
  - 과거 기준 보존: `archive/`
- 성장 구조와 숙련 규칙은 `progression_overview.md`를 수정한다.
- 스킬 경험치와 레벨 계산식은 `skill_level_rules.md`를 수정한다.
- 적 스탯 체계와 최종 피해 순서는 `enemy_stat_and_damage_rules.md`를 수정한다.
- 적 roster, 역할, 엘리트 후보, 신규 몬스터 편입 우선순위는 `enemy_catalog.md`를 수정한다.
- 적 JSON 필드와 허용값은 `enemy_data_schema.md`를 수정한다.
- 적 구현 / 에셋 / 테스트 반영 상태는 `enemy_content_tracker.md`를 수정한다.
- 스킬 종합 레벨과 서클 승급은 `circle_progression.md`를 수정한다.
- 마스터리 패시브는 `mastery_skills.md`를 수정한다.
- 버프 중첩/조합/부작용 규칙은 `buff_system.md`를 수정한다.
- 실제 버프 스킬 목록과 수치는 `buff_skill_catalog.md`를 수정한다.
- 버프 조합의 발동 조건과 효과는 `buff_combo_catalog.md`를 수정한다.
- 스킬의 최신 이름/속성/서클/컨셉/라인업은 `skill_system_design.md`를 수정한다.
- 스킬 JSON 필드와 허용값은 `skill_data_schema.md`를 수정한다.
- 스킬 구현 상태와 asset/effect/레벨 스케일 상태는 `skill_implementation_tracker.md`를 수정한다.
- `skills.json` canonical 마이그레이션 완료 기록은 `skills_json_canonical_migration_plan.md`의 `Phase 진행 상태` 섹션에 누적한다.
- `spell_catalog.md`, `spell_concept_rework_2026-04-02.md`는 신규 기준 문서로 쓰지 않고, 아카이브 목적의 최소 유지보수만 한다.

## 새 스킬 작성 절차

처음 보는 사람도 아래 순서대로만 수정하면 구조를 깨지 않고 새 스킬을 추가할 수 있다.

1. 최신 기획 위치 결정
   - 새 스킬의 속성, 서클, 타입, 컨셉, 기본 수치, 레벨 성장 규칙을 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)에 먼저 추가한다.
2. canonical `skill_id` 확정
   - 영문 `snake_case`로 canonical `skill_id`를 정한다.
   - 이름이 바뀌어도 canonical `skill_id`는 쉽게 바꾸지 않는다.
3. 데이터 스키마 검증
   - 허용 가능한 `school`, `element`, `skill_type`, `hit_shape`를 [skill_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md)에서 확인한다.
   - `role_tags` 후보는 [skill_role_tag_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/skill_role_tag_catalog.md)에서, `growth_tracks` 후보는 [skill_growth_track_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/skill_growth_track_catalog.md)에서 확인한다.
   - 버프 스킬의 `buff_category` 후보는 [buff_category_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_category_catalog.md)에서 확인한다.
   - 버프 스킬의 `stack_rule_id` 후보는 [buff_stack_rule_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_stack_rule_catalog.md)에서 확인한다.
   - 버프 스킬의 `combo_tags` 후보는 [buff_combo_tag_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_tag_catalog.md)에서 확인한다.
   - 새 enum 값이 필요하면 스키마와 runtime 해석 코드를 같이 갱신한다.
4. 구현 추적표 등록
   - [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)에 새 row를 추가한다.
   - 최소한 `canonical skill_id`, `이름`, `타입`, `구현`, `asset`, `attack effect`, `hit effect`, `레벨 스케일` 상태를 채운다.
5. 특수 계열 문서 반영
   - 버프면 `buff_skill_catalog.md`
   - 패시브면 `mastery_skills.md`
   - 성장 규칙 예외가 있으면 `skill_level_rules.md`
   - 이런 식으로 해당 전문 문서도 같이 갱신한다.
   - 버프라면 아래 3가지를 같이 점검한다:
   - `buff_category`: 버프의 대표 전투 역할을 하나만 고른다
   - `stack_rule_id`: 중첩 강도/의식 규칙을 current closed ID 중 하나로 고른다
   - `combo_tags`: 조합 이름이 아니라 조합 힌트 태그를 `1~3`개 정도 붙인다
   - 버프 조합 발동 조건이나 named combo 의미가 바뀌면 `buff_combo_catalog.md`도 같은 턴에 맞춘다.
6. runtime 연결 여부 기록
   - 이미 구현된 runtime proxy가 있으면 tracker의 `현재 runtime 참조`와 `비고`에 연결한다.
   - 아직 없으면 `planned`로 두고 proxy를 만들 때 갱신한다.
7. 자산과 effect 상태 초기화
   - 전용 asset이 없으면 `not_started`
   - 임시 asset이면 `placeholder`
   - 분리 `attack/hit effect`가 필요 없는 스킬이면 `n/a`
8. 구현 후 상태 갱신
   - 코드 반영 -> 검증 -> tracker 상태 갱신 -> 필요 시 설계/스키마 문서 동기화 순서로 닫는다.

## 새 스킬 작성 체크리스트

- [ ] [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)에 기획 추가
- [ ] canonical `skill_id` 생성
- [ ] [skill_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md) 허용값 확인
- [ ] [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md) row 추가
- [ ] 필요 시 버프/마스터리/성장 규칙 문서 갱신
- [ ] runtime proxy / 레거시 매핑 여부 기록
- [ ] asset / attack effect / hit effect / 레벨 스케일 상태 초기화
