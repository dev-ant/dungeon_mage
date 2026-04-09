---
title: 몬스터 데이터/런타임 마이그레이션 계획
doc_type: plan
status: active
section: implementation
owner: runtime
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - runtime_changed
  - schema_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 몬스터 데이터/런타임 마이그레이션 계획

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 구현 기준 / 마이그레이션

## 목표

문서 구조 개편 이후, 몬스터 관련 `기획 문서`, `데이터 스키마`, `상태 추적`, `실제 런타임` 사이의 불일치를 줄이고 장기 운영 가능한 상태로 맞춥니다.

핵심 방향은 아래 두 가지입니다.

- 플레이 감각을 바꾸지 않고 `문서-데이터-로더-테스트` 정합성을 높인다.
- 이후 새 몬스터를 추가할 때 `문서 등록 -> JSON 추가 -> 로더 검증 -> 런타임 연결 -> 테스트` 흐름이 자동으로 닫히게 만든다.

## 현재 판단

즉시 전투 감각을 바꾸는 필수 런타임 수정은 아닙니다.  
다만 장기 운영 실무 기준에서는 아래 항목은 실제 데이터/로직 마이그레이션이 필요합니다.

1. `enemy_data_schema.md`의 enum-like 허용값과 실제 `enemies.json` 값이 일부 어긋나 있다.
2. `game_database.gd`의 enemy validation 범위가 새 스키마 문서보다 좁다.
3. `enemy_base.gd`는 일부 필드를 느슨하게 fallback 처리해서, 스키마 누락이 런타임에서 조용히 지나갈 수 있다.
4. `enemy_content_tracker.md`는 상태 근거를 수동으로 적고 있어, validation/tests와의 연결을 더 분명히 할 필요가 있다.

## 확인된 현재 불일치

### 1. role taxonomy 불일치

`docs/progression/schemas/enemy_data_schema.md`의 대표 role 값과 `data/enemies/enemies.json`의 실제 role 값이 완전히 같지 않습니다.

대표 예시:

- 문서값: `burst_check_elite`
- 실제값: `burst_check`

- 문서값: `jumping_leaper`
- 실제값: `mobile_burst`

- 문서값: `locked_charge_brute`
- 실제값: `punish_stationary`

- 문서값: `flying_harasser`
- 실제값: `flying_ranged_harasser`

- 문서값: `burrow_brute`
- 실제값: `ground_charge_presser`

- 문서값: `melee_spore`
- 실제값: `melee_stunner`

- 문서값: `heavy_area_brute`
- 실제값: `trash_tank`

이 값들은 현재 UI/관리자 표시와 문서 요약용으로 쓰이므로, 우선 `현재 런타임 값 기준으로 스키마 문서를 맞추는 방향`이 가장 안전합니다.

### 2. drop profile 허용값 불일치

`enemy_data_schema.md`는 `drop_profile` 대표값을 `none/common/boss` 중심으로만 적고 있지만, 실제 코드와 데이터는 아래 값을 이미 사용/허용합니다.

- `none`
- `common`
- `elite`
- `rare`
- `boss`

특히 `elite`는 실제 `enemies.json`에서 사용 중이므로, 문서만 읽고 작업하면 오해가 생깁니다.

### 3. loader validation 범위 부족

현재 `scripts/autoload/game_database.gd`는 아래 정도만 검증합니다.

- 필수 필드 일부 존재 여부
- duplicate `enemy_id`
- `enemy_grade`
- `drop_profile`

하지만 새 문서 체계 기준으로는 최소 아래도 검증하는 편이 맞습니다.

- `role`
- `attack_damage_type`
- `attack_element`
- 저항 필드 누락 여부
- `super_armor_tags` 타입
- 문서상 필수 필드 전체

### 4. runtime fallback 과다 허용

`scripts/enemies/enemy_base.gd`는 `attack_damage_type`, `attack_element`, `enemy_grade`가 비어도 fallback 값을 채워 계속 진행합니다.

이 fallback 자체는 유지해도 되지만, 장기 운영용이라면 아래가 필요합니다.

- validation 단계에서 먼저 잡기
- fallback은 `테스트/헤드리스 안전장치`로만 두기
- 실제 체크인 데이터에서는 validation error가 0개여야 하기

## 마이그레이션 원칙

1. 플레이 감각 유지 우선
   - 수치/행동 변경보다 스키마/validation 정합성 정리를 먼저 한다.
2. 문서가 runtime을 덮어쓰지 않음
   - 현재 실행 중인 값이 있으면 먼저 baseline과 코드로 사실을 확인한다.
3. 고비용 리네이밍 최소화
   - `role`처럼 UI/문서 요약용 값은 코드 전역 rename보다 스키마 문서 동기화가 우선이다.
4. validation 강화는 단계적으로
   - 한 번에 hard error를 늘리기보다, 현재 catalog가 통과하는 수준으로 단계적으로 올린다.

## 목표 상태

마이그레이션 완료 후 아래 상태를 목표로 합니다.

- `enemy_catalog.md`는 roster/역할/편입 우선순위만 관리한다.
- `enemy_data_schema.md`는 실제 허용값과 validation 기준을 정확히 반영한다.
- `enemy_content_tracker.md`는 구현/에셋/테스트 상태를 근거와 함께 추적한다.
- `game_database.gd`는 새 스키마 문서 수준까지 validation을 수행한다.
- `tests/test_game_state.gd`는 invalid grade/profile뿐 아니라 invalid role/type/element도 회귀 검증한다.
- `enemy_base.gd` fallback은 유지하더라도, 체크인 데이터 기준 validation report는 항상 비어 있다.

## 진행 상태

기준 날짜: 2026-04-02

### 완료

- Phase 0 완료:
  - `enemy_data_schema.md`의 `role` 대표값을 현재 체크인 `enemies.json` 기준으로 정리했다.
  - `drop_profile`에 대해 `대표값`과 `허용값`을 구분했다.
  - `elite`, `rare` 허용 범위를 문서에 반영했다.
- Phase 1 최소 버전 완료:
  - `game_database.gd`가 `role`, `attack_damage_type`, `attack_element` enum validation을 수행하도록 확장했다.
  - `tests/test_game_state.gd`에 invalid role/type/element 회귀 테스트를 추가했다.
  - 현재 체크인 `enemies.json`이 확장된 enum validation을 통과하는 상태를 유지했다.
- Phase 1 필수 필드 확장 완료:
  - `game_database.gd`가 `role`, `attack_damage_type`, `attack_element`, `attack_period`, `drop_profile`, `knockback_resistance`를 필수 필드로 강제하도록 확장했다.
  - `tests/test_game_state.gd`에 위 6개 필드 누락 회귀 테스트를 추가했다.
  - 현재 체크인 `enemies.json`이 필수 필드 확장 validation도 통과하는 상태를 유지했다.
- Phase 1 구조 검증 일부 완료:
  - `game_database.gd`가 `super_armor_tags`를 `Array[String]`으로 검증하도록 확장했다.
  - `tests/test_game_state.gd`에 non-array / non-string `super_armor_tags` 회귀 테스트를 추가했다.
  - 현재 체크인 `enemies.json`이 `super_armor_tags` 구조 검증도 통과하는 상태를 유지했다.
- Phase 1 구조 검증 완료:
  - `game_database.gd`가 속성 저항 10종과 상태이상 저항 8종의 필수 존재를 검증하도록 확장했다.
  - `tests/test_game_state.gd`에 필수 저항 필드 누락 회귀 테스트를 추가했다.
  - 현재 체크인 `enemies.json`이 저항 필드 존재 검증도 통과하는 상태를 유지했다.
- Phase 2 최소 버전 완료:
  - `enemy_base.gd`가 unknown `attack_damage_type`을 `physical`, unknown `attack_element`를 `none`으로 경고와 함께 정규화하도록 hardening되었다.
  - `tests/test_enemy_base.gd`에 attack contract fallback 회귀 테스트를 추가했다.
  - fallback은 유지하되, malformed runtime 값이 조용히 전투 동작으로 새어 나가는 가능성을 줄였다.
- Phase 2 완료:
  - `enemy_base.gd`가 empty `display_name`과 empty / invalid `enemy_grade`도 경고와 함께 안전한 기본값으로 정규화하도록 hardening되었다.
  - `tests/test_enemy_base.gd`에 loaded identity fallback 회귀 테스트를 추가했다.
  - `display_name`, `enemy_grade`, `attack_damage_type`, `attack_element`의 runtime fallback이 모두 명시적 warning 경로를 가지게 되었다.
- Phase 3 완료:
  - `enemy_content_tracker.md`에 `verification_type`, `last_verified`, 공통 validation 근거 섹션을 추가했다.
  - monster row별 근거를 함수명 중심으로 다시 정리했다.
  - `bat`, `worm`의 테스트 상태를 직접 GUT 근거 기준으로 `covered`로 정정했다.
- Phase 0 잔여 검토 완료:
  - `enemy_catalog.md`에 `runtime role` 열을 추가해 자연어 역할 설명과 스키마 role 값을 직접 연결했다.
  - 신규 5종 상세 초안에도 각 `runtime role`을 명시했다.
  - 카탈로그와 스키마를 함께 읽을 때 role taxonomy 혼선이 줄어들도록 정리했다.

### 미완료

- 현재 마이그레이션 기준 잔여 없음

### 다음 안전 단위

- 현재 마이그레이션 계획 기준으로 다음 필수 안전 단위는 없습니다.
- 이후 후속 작업이 필요하면 신규 몬스터 추가나 role taxonomy 변경처럼 새 변경 요구를 기준으로 별도 문서를 연다.

## 단계별 실행 계획

### Phase 0. 문서 기준선 확정

상태: 완료

목표:

- 스키마 문서의 허용값을 실제 런타임과 맞춘다.

수정 문서:

- `docs/progression/schemas/enemy_data_schema.md`
- 필요 시 `docs/progression/catalogs/enemy_catalog.md`

작업:

1. `role` 대표값을 실제 `data/enemies/enemies.json` 기준으로 정리한다.
2. `drop_profile` 허용값에 `elite`, `rare`를 추가한다.
3. `대표값`과 `허용값`을 구분해서 쓴다.
   - 대표값: 자주 쓰는 값
   - 허용값: validation 대상 전체 값

완료 기준:

- 문서의 `role` / `drop_profile` 항목을 보고 실제 JSON을 수정할 때 혼선이 없다.

2026-04-02 진행 메모:

- `enemy_data_schema.md`의 `role` 대표값을 현재 체크인 `enemies.json` 기준으로 동기화 완료
- `drop_profile`의 대표값 / 허용값 분리 완료
- `enemy_catalog.md`에 `runtime role` 열과 신규 5종 `runtime role` 메모 추가 완료

### Phase 1. GameDatabase validation 확장

목표:

- 로더가 새 스키마 문서 수준까지 enemy catalog를 검증한다.

상태: 완료

핵심 파일:

- `scripts/autoload/game_database.gd`
- `tests/test_game_state.gd`

추가/정리할 validation:

1. enum-like 값
   - `role`
   - `attack_damage_type`
   - `attack_element`
2. 필수 필드 확장
   - `role`
   - `attack_damage_type`
   - `attack_element`
   - `attack_period`
   - `drop_profile`
   - `knockback_resistance`
3. 구조 검증
   - `super_armor_tags`가 `Array[String]`인지
   - 필수 저항 필드가 모두 있는지
4. 선택 확장
   - `enemy_type`와 `enemy_id`가 다를 때 warning 또는 note 남기기

권장 상수 추가:

- `VALID_ATTACK_DAMAGE_TYPES`
- `VALID_ATTACK_ELEMENTS`
- `VALID_ENEMY_ROLES`
- `REQUIRED_ELEMENT_RESIST_FIELDS`
- `REQUIRED_STATUS_RESIST_FIELDS`

완료 기준:

- 현재 체크인된 `enemies.json`이 확장 validation을 통과한다.
- invalid role/type/element 샘플에 대해 validation error 테스트가 생긴다.
- Phase 1 필수 필드 누락 샘플에 대해 validation error 테스트가 생긴다.

2026-04-02 진행 메모:

- `role`, `attack_damage_type`, `attack_element` enum validation 추가 완료
- invalid role/type/element 회귀 테스트 추가 완료
- `role`, `attack_damage_type`, `attack_element`, `attack_period`, `drop_profile`, `knockback_resistance` 필수 필드 확장 완료
- 필수 필드 누락 회귀 테스트 추가 완료
- `super_armor_tags` 구조 검증 완료
- non-array / non-string `super_armor_tags` 회귀 테스트 추가 완료
- 속성 저항 10종 / 상태이상 저항 8종 필수 존재 검증 완료
- 저항 필드 누락 회귀 테스트 추가 완료

### Phase 2. enemy_base runtime hardening

목표:

- 스키마 오류가 런타임에서 조용히 숨지지 않게 한다.

핵심 파일:

- `scripts/enemies/enemy_base.gd`
- 필요 시 `scripts/autoload/game_database.gd`

작업:

1. `_apply_stats_from_data()`는 현재 fallback을 유지하되, 아래 원칙으로 정리한다.
   - validation이 정상 통과한 catalog에서는 fallback이 거의 필요 없어야 한다.
   - fallback은 누락 데이터 방치가 아니라 테스트 안정성용으로만 남긴다.
2. 필요 시 debug build warning 또는 `push_warning()`를 추가한다.
   - unknown `attack_damage_type`
   - unknown `attack_element`
   - empty `role`은 `enemy_base`보다 loader에서 먼저 차단
3. `display_name`, `enemy_grade`, `attack_damage_type`, `attack_element`는 `GameDatabase`를 신뢰하는 쪽으로 점진 정리한다.

완료 기준:

- JSON 실수 때문에 런타임이 조용히 이상 동작하는 가능성이 줄어든다.

2026-04-02 진행 메모:

- `_finalize_combat_runtime_defaults()`가 unknown `attack_damage_type`을 `physical`, unknown `attack_element`를 `none`으로 경고와 함께 정규화하도록 hardening 완료
- `tests/test_enemy_base.gd`에 unknown attack contract fallback 회귀 테스트 추가 완료
- loaded data 기준 empty `display_name`, empty / invalid `enemy_grade`도 경고와 함께 안전한 기본값으로 정규화하도록 hardening 완료
- `tests/test_enemy_base.gd`에 loaded identity fallback 회귀 테스트 추가 완료

### Phase 3. tracker-근거 연결 강화

목표:

- 상태 추적표를 “사람 기억”이 아니라 “코드/테스트 근거” 기반으로 유지한다.

핵심 문서:

- `docs/progression/trackers/enemy_content_tracker.md`

권장 확장:

1. `근거` 열을 유지한다.
2. 필요 시 `last_verified` 열을 추가한다.
3. 필요 시 `verification_type` 열을 추가한다.
   - `gut`
   - `asset_only`
   - `runtime_manual`

완료 기준:

- `partial` 또는 `covered` 판정 이유를 새 작업자가 바로 이해할 수 있다.

2026-04-02 진행 메모:

- `enemy_content_tracker.md`에 `verification_type`, `last_verified` 열 추가 완료
- 공통 validation 근거 섹션 추가 완료
- row별 근거를 구체적인 함수명 / 파일 근거 기준으로 재정리 완료
- `bat`, `worm` 테스트 상태를 직접 GUT 근거 기준으로 `covered`로 정정 완료

## 추천 실제 수정 순서

가장 안전한 실행 순서는 아래입니다.

1. `enemy_data_schema.md`를 실제 runtime 값에 맞게 정리
2. `game_database.gd` validation 상수/검사 로직 추가
3. `tests/test_game_state.gd`에 invalid role/type/element 테스트 추가
4. `enemy_base.gd` warning/fallback 정리
5. `enemy_content_tracker.md`를 테스트 근거 기준으로 다시 갱신

## 예상 수정 파일 목록

문서:

- `docs/progression/schemas/enemy_data_schema.md`
- `docs/progression/trackers/enemy_content_tracker.md`
- 필요 시 `docs/progression/catalogs/enemy_catalog.md`
- 필요 시 `docs/implementation/baselines/current_runtime_baseline.md`

코드:

- `scripts/autoload/game_database.gd`
- `scripts/enemies/enemy_base.gd`
- 필요 시 `scripts/admin/admin_menu.gd`

테스트:

- `tests/test_game_state.gd`
- 필요 시 `tests/test_enemy_base.gd`

데이터:

- `data/enemies/enemies.json`

## 구체적 체크리스트

### 문서 정리

- [ ] `enemy_data_schema.md`의 `role` 허용값을 실제 데이터와 맞췄다
- [ ] `enemy_data_schema.md`의 `drop_profile` 허용값을 실제 코드와 맞췄다
- [ ] 스키마 문서의 `대표값`과 `허용값`이 구분되어 있다

### validation 강화

- [ ] `game_database.gd`가 invalid `role`을 잡는다
- [ ] `game_database.gd`가 invalid `attack_damage_type`을 잡는다
- [ ] `game_database.gd`가 invalid `attack_element`를 잡는다
- [ ] 필수 저항 필드 누락을 잡는다
- [ ] `super_armor_tags` 타입 오류를 잡는다

### runtime hardening

- [ ] `enemy_base.gd` fallback이 validation 보조 수준으로 정리되었다
- [ ] unknown 값에 대한 warning 경로가 필요하면 추가되었다

### 테스트

- [ ] invalid `role` 회귀 테스트 추가
- [ ] invalid `attack_damage_type` 회귀 테스트 추가
- [ ] invalid `attack_element` 회귀 테스트 추가
- [ ] 현재 catalog validation report가 여전히 0개다

## 수용 기준

- 현재 체크인된 `enemies.json`이 새 validation을 통과한다.
- `enemy_data_schema.md`를 보고 새 enemy row를 추가할 때 role/profile 혼선이 없다.
- `enemy_content_tracker.md`의 상태값이 테스트 또는 파일 근거와 연결된다.
- 플레이 감각은 바뀌지 않는다.

## 비목표

- 몬스터 밸런스 전면 재조정
- 적 AI 역할 재설계
- 신규 몬스터 추가
- 에셋 파이프라인 전면 교체
- 관리자 UI 문구 전면 개편

## 다음 가장 작은 구현 작업

가장 먼저 할 일은 `Phase 0 + Phase 1의 최소 버전`입니다.

1. `enemy_data_schema.md`의 `role` / `drop_profile` 허용값 정리
2. `game_database.gd`에 `VALID_ATTACK_DAMAGE_TYPES`, `VALID_ATTACK_ELEMENTS`, `VALID_ENEMY_ROLES` 추가
3. `tests/test_game_state.gd`에 invalid enum validation 테스트 3개 추가

이 세 가지가 끝나면, 이후 몬스터 문서 체계는 실제 런타임 검증과 연결된 상태로 굴릴 수 있습니다.
