---
title: 몬스터 콘텐츠 추적표
doc_type: tracker
status: active
section: progression
owner: design
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - runtime_changed
  - status_changed
  - structure_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 몬스터 콘텐츠 추적표

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 성장 시스템 / 몬스터 상태 추적

## 목적

이 문서는 정식 몬스터 roster의 `구현`, `에셋 반영`, `테스트 반영` 상태를 한눈에 추적하는 상태 보고 문서입니다.

몬스터 역할과 편입 우선순위는 [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md)에서, 데이터 필드는 [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md)에서, 전투 계산 규칙은 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)에서 관리합니다.

현재 빌드 사실이 이 문서와 다르면 코드와 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)를 우선하고, 이후 이 문서를 맞춥니다.

## 상태 값 규칙

### 구현 상태

- `implemented`: 런타임 타입, 기본 행동, 스폰 가능 경로가 존재
- `partial`: 일부 행동만 있거나 임시 분기 상태
- `planned`: 데이터나 기획만 있고 런타임 미반영

### 에셋 상태

- `dedicated`: 전용 런타임 몬스터 에셋 연결 완료
- `shared`: 다른 적과 공유하거나 제한적 비주얼 사용
- `none`: 전용 런타임 에셋 미연결

### 테스트 상태

- `covered`: GUT 또는 자동 검증이 직접 커버
- `partial`: 간접 검증만 있음
- `none`: 자동 검증 없음

### verification_type

- `gut`: named GUT가 직접 runtime 또는 validation을 검증
- `asset_only`: 에셋 연결 근거만 있고 직접 자동 검증은 약함
- `runtime_manual`: 현재 빌드 수동 확인만 존재

### last_verified

- 이 값은 최근에 tracker 근거를 다시 대조한 날짜를 의미합니다.
- 자동화 타임스탬프가 아니라, 문서와 코드 기준을 다시 맞춘 날짜로 기록합니다.

## 공통 검증 기준

- enemy catalog validation report 기준선:
  - `test_enemy_database_validation_report_is_empty_for_current_catalog()`
- invalid sample validation 기준선:
  - `test_enemy_validation_rejects_invalid_role()`
  - `test_enemy_validation_rejects_invalid_attack_damage_type()`
  - `test_enemy_validation_rejects_invalid_attack_element()`
  - `test_enemy_validation_rejects_missing_phase_1_required_fields()`
  - `test_enemy_validation_rejects_non_array_super_armor_tags()`
  - `test_enemy_validation_rejects_missing_required_element_resist_fields()`
  - `test_enemy_validation_rejects_missing_required_status_resist_fields()`

## 현재 추적표

| enemy_id | 구현 | 에셋 | 테스트 | verification_type | last_verified | 근거 | 메모 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `brute` | implemented | shared | covered | `gut` | `2026-04-02` | `test_damage_pipeline_applies_defense_before_health_loss()`, `test_receive_hit_emits_damage_label_signal_with_correct_school()` | 기본 근접 기준 적, 생존/피격/신호 경로 GUT 존재 |
| `ranged` | implemented | shared | covered | `gut` | `2026-04-02` | `test_hit_flash_timer_starts_at_zero()` | 전용 명명 테스트는 얇지만 직접 runtime configure 근거 존재 |
| `boss` | implemented | none | covered | `gut` | `2026-04-02` | `test_boss_super_armor_reduces_damage_to_ten_percent()`, `test_enemy_validation_rejects_non_array_super_armor_tags()` | 보스 전용 수치/슈퍼아머/validation 근거 존재, 전용 몬스터 에셋은 미연결 |
| `dummy` | implemented | shared | covered | `gut` | `2026-04-02` | `test_dummy_enemy_configures_as_stationary_training_target()` | 훈련 대상, stationary runtime 검증 존재 |
| `dasher` | implemented | none | covered | `gut` | `2026-04-02` | `test_dasher_configures_as_fast_mobile_pressure_enemy()`, `test_dasher_receives_hit_and_loses_health()` | 돌진형 기본 동작과 피격 GUT 존재 |
| `sentinel` | implemented | none | covered | `gut` | `2026-04-02` | `test_sentinel_configures_as_area_control_enemy()`, `test_sentinel_receives_hit_and_applies_knockback()` | 범위 제어형 동작 GUT 존재 |
| `elite` | implemented | none | covered | `gut` | `2026-04-02` | `test_elite_configures_with_high_health_and_stagger_threshold()`, `test_elite_phase2_super_armor_triggers_at_half_health()` | standalone elite, 슈퍼아머/버스트/phase2 검증 존재 |
| `leaper` | implemented | none | covered | `gut` | `2026-04-02` | `test_leaper_configures_as_mobile_burst_enemy()`, `test_leaper_warning_marker_lands_at_predicted_x()` | 점프/착지/경고 마커 검증 존재 |
| `bomber` | implemented | none | covered | `gut` | `2026-04-02` | `test_bomber_attack_state_emits_warning_marker_before_bomb()`, `test_bomber_projectile_plays_terminal_burst_effect_on_finish()` | warning marker, 곡선탄, terminal burst까지 자동 검증 |
| `charger` | implemented | none | covered | `gut` | `2026-04-02` | `test_charger_configures_as_punish_stationary_enemy()`, `test_charger_locks_target_position_at_telegraph_start()` | 잠금 돌진 동작 검증 존재 |
| `bat` | implemented | dedicated | covered | `gut` | `2026-04-02` | `test_bat_configures_as_flying_ranged_harasser()`, `test_bat_fires_projectile_toward_player()` | 직접 GUT와 전용 런타임 에셋 근거가 모두 존재 |
| `worm` | implemented | dedicated | covered | `gut` | `2026-04-02` | `test_worm_configures_as_ground_charge_enemy()`, `test_worm_attack_charges_toward_player()` | 직접 GUT와 전용 런타임 에셋 근거가 모두 존재 |
| `mushroom` | implemented | dedicated | covered | `gut` | `2026-04-02` | `test_mushroom_configures_as_melee_stunner()`, `test_mushroom_stun_attack_activates_every_third_attack()` | 런타임 에셋 연결 및 전용 행동 테스트 존재 |
| `rat` | implemented | dedicated | covered | `gut` | `2026-04-02` | `test_rat_configures_as_fast_melee_swarm_enemy()`, `test_rat_runtime_sprite_frames_load_from_assets()` | 신규 5종 중 완료, 구성/피격/에셋 GUT 존재 |
| `tooth_walker` | implemented | dedicated | covered | `gut` | `2026-04-02` | `test_tooth_walker_configures_as_slow_bite_chaser()`, `test_tooth_walker_runtime_sprite_frames_trim_empty_death_tail()` | 신규 5종 중 완료, 구성/에셋/경직 GUT 존재 |
| `eyeball` | implemented | dedicated | covered | `gut` | `2026-04-02` | `test_eyeball_configures_as_flying_observer()`, `test_eyeball_runtime_sprite_frames_load_from_vertical_sheet()` | 신규 5종 중 완료, 구성/발사/에셋 GUT 존재 |
| `trash_monster` | implemented | dedicated | covered | `gut` | `2026-04-02` | `test_trash_monster_configures_as_high_hp_tank()`, `test_trash_monster_runtime_sprite_frames_load_from_grid_sheet()` | 신규 5종 중 완료, 구성/에셋/경직 GUT 존재 |
| `sword` | implemented | dedicated | covered | `gut` | `2026-04-02` | `test_sword_configures_as_fast_rusher()`, `test_sword_runtime_sprite_frames_trim_empty_tail_cells()` | 신규 5종 중 완료, 구성/에셋/행동 GUT 존재 |

## 신규 5종 진행 상태

| enemy_id | 편입 | 런타임 에셋 | 전용 행동 | 테스트 | 메모 |
| --- | --- | --- | --- | --- | --- |
| `rat` | 완료 | 완료 | 완료 | 완료 | swarm 성격 반영 |
| `tooth_walker` | 완료 | 완료 | 완료 | 완료 | stagger threshold 조정 포함 |
| `eyeball` | 완료 | 완료 | 완료 | 완료 | 공중 감시 / 발사 동작 포함 |
| `trash_monster` | 완료 | 완료 | 완료 | 완료 | 탱크형 경직 임계치 반영 |
| `sword` | 완료 | 완료 | 완료 | 완료 | retreat timer 기반 압박 동작 반영 |

## 현재 리스크 메모

- `boss`, `elite`, `dasher`, `sentinel`, `leaper`, `bomber`, `charger`는 전용 몬스터 비주얼 에셋보다 동작 검증이 먼저 닫혀 있는 상태입니다.
- `ranged`는 직접 configure 근거는 있지만 전용 명명 테스트가 얇아서, 장기적으로는 archetype 전용 테스트를 더 보강할 수 있습니다.
- `brute`, `ranged`, `dummy`는 shared 또는 제한적 비주얼 경로에 기대는 구간이 있으므로, 장기적으로는 전용 외형 정책을 다시 정리할 수 있습니다.

## 갱신 규칙

- 새 몬스터가 `enemies.json`에 추가되면 이 표에 같은 턴에 row를 추가합니다.
- 전용 런타임 에셋을 연결하면 `에셋` 상태를 갱신합니다.
- 전용 GUT나 자동 검증을 추가하면 `테스트` 상태를 갱신합니다.
- 상태 판정을 바꿀 때는 `verification_type`, `last_verified`, `근거` 열도 함께 갱신합니다.
- 코드와 이 문서가 어긋나면 코드를 먼저 사실로 보고 이 문서를 수정합니다.

## 구현자 체크리스트

- [ ] 새 몬스터의 row가 추가되었는가
- [ ] 구현 / 에셋 / 테스트 상태가 각각 최신인가
- [ ] 상태 판정의 근거가 함수명, 파일 경로, 검증 단위 중 하나로 남아 있는가
- [ ] `verification_type`과 `last_verified`가 최신 검증 기준과 맞는가
- [ ] dedicated / shared / none 구분이 실제 런타임과 맞는가
- [ ] covered / partial / none 구분에 근거가 남아 있는가
