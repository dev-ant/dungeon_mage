---
title: 전투 3차 작업 체크리스트 - 버프 중심 액션 루프
doc_type: plan
status: active
section: implementation
owner: runtime
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/buff_system.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 전투 3차 작업 체크리스트 - 버프 중심 액션 루프

상태: 사용 중  
최종 갱신: 2026-04-01  
섹션: 구현 기준

## 목표

이 문서는 [전투 우선 구현 계획](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md)의 세 번째 증분인 `버프 중심 액션 루프 구축`을 Claude가 바로 구현할 수 있도록 쪼갠 작업 체크리스트다.

이번 증분의 핵심은 `강한 버프`, `동일 버프 중복`, `조합 발동`, `순간 폭발 구간`, `종료 페널티`를 실제 전투 템포 안에 넣는 것이다.

## 현재 기준

- 버프 규칙 문서는 [buff_system.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/buff_system.md)에 있다.
- 버프 목록은 [buff_skill_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_skill_catalog.md)에 있다.
- 조합 효과 목록은 [buff_combo_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md)에 있다.
- 조합 데이터 스키마는 [buff_combo_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/buff_combo_data_schema.md)에 있다.
- 현재 런타임에는 [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd) 기준으로 일부 버프와 조합 로직이 이미 들어가 있다.
- 이번 작업은 기존 구현을 유지하면서 `전투 중심 시스템`으로 정리하고, 테스트 가능성과 확장성을 높이는 방향으로 본다.

## 플레이 경험 목표

- 버프를 켜는 순간 전투 리듬이 눈에 띄게 빨라지거나 강해져야 한다.
- 같은 버프를 겹쳐 쌓는 선택이 손해가 아니라 분명한 전술적 의미를 가져야 한다.
- 특정 조합을 완성했을 때 `지금이 폭딜 타이밍`이라는 감각이 분명해야 한다.
- 강한 버프는 쿨타임이 길고, 필살급 조합은 끝난 뒤 리스크가 있어야 한다.
- 버프를 켜고 누적시키고 터뜨리는 흐름 자체가 전투의 핵심 루프가 되어야 한다.

## 이번 범위

### 포함

- 버프 동시 유지 수 제한
- 동일 버프 중복 시전
- 버프 중첩별 효과 계산
- 버프 지속시간과 쿨타임 처리
- 조합 조건 감지
- 조합별 전투 효과 적용
- 필살 조합 종료 페널티
- HUD의 버프/조합 정보 강화
- 버프 관련 GUT 테스트

### 제외

- 모든 버프의 완성형 시각효과
- 스토리 이벤트로 버프 해금
- 장비와 버프의 고급 시너지 전부
- 관리자 메뉴의 버프 전용 탭 상세 UI

## Claude 작업 순서

1. [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)의 현재 버프 구조를 읽고, 중첩/조합/패널티 관련 책임을 정리한다.
2. [buff_combos.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/skills/buff_combos.json)와 문서 기준을 비교해 실제 런타임에 필요한 필드를 확정한다.
3. 버프 인스턴스 구조를 `remaining_time`, `stacks`, `source_skill_id`, `tags` 중심으로 정리한다.
4. 서클 기반 동시 유지 수 제한을 실제 시전 로직과 연결한다.
5. 동일 버프 중복 시전 규칙과 점감 규칙이 필요하면 계산 함수로 분리한다.
6. 조합 발동 감지와 조합 해제 처리를 정리한다.
7. 조합별 실전 효과를 적용한다.
8. HUD에 버프 지속시간, 중첩 수, 활성 조합, 페널티 상태를 표시한다.
9. GUT 테스트를 추가하고 헤드리스 검증을 통과시킨다.

## 핵심 규칙

### 1. 버프 슬롯 제한

- `4서클`: 동시 유지 2개
- `6서클`: 동시 유지 3개
- `8서클`: 동시 유지 4개
- `10서클`: 동시 유지 5개

### 2. 동일 버프 중복

- 같은 버프 스킬을 다시 사용할 수 있다.
- 중복 시 `지속시간 갱신`과 `중첩 증가`를 분리해 처리한다.
- 일부 버프는 선형 증가, 일부는 점감 증가를 허용한다.

### 3. 긴 쿨타임

- 버프는 강한 대신 액티브보다 긴 쿨타임을 가진다.
- 필살급 버프는 조합 성공 여부와 관계없이 리스크를 가진다.

### 4. 종료 페널티

- 강한 버프 또는 필살 조합은 종료 후 약화 상태를 남길 수 있다.
- 페널티는 `재시전 제한`, `마나 회복 감소`, `피해 증가`, `이동 저하` 중 최소 하나를 가진다.

## 우선 구현 조합

### Prismatic Guard

- 생존형 조합
- 보호막 우선 흡수
- 중첩 수에 따라 보호막량 증가 가능

### Overclock Circuit

- 번개 폭딜형 조합
- 특정 번개 스킬 쿨타임 감소
- 투사체 속도, 관통 수, 타격 템포 증가

### Time Collapse

- 범용 폭딜 창구
- 일정 횟수의 시전이 강화됨
- 강화 횟수 소모 후 조합 종료

### Ashen Rite

- 3버프 필살 조합
- 유지 중 누적 스택 발생
- 종료 시 누적 스택 기반 폭발
- 종료 후 분명한 페널티 발생

## 대표 burst 조합 구체화 (2026-04-01)

### Ashen Rite를 전투 커버리지의 대표 burst 조합으로 고정

- 전투 커버리지 매트릭스의 `버프 폭발/조합` 행은 우선 `Ashen Rite` 하나로 닫는다.
- 이 조합의 핵심 재미는 `긴 준비`보다 `짧은 타이밍 폭딜`에 둔다.

### 구현 기준

- 준비 구간:
  - 활성화 후 스택이 누적되어야 한다.
  - HUD/요약에서 현재 stack 상태가 읽혀야 한다.
- 폭발 구간:
  - 조건 충족 시 burst가 실제 전투 결과로 확인되어야 한다.
  - burst는 단순 메시지가 아니라 적 피해 또는 combo effect emission으로 검증 가능해야 한다.
- 후속 페널티 구간:
  - burst 이후 `마나 소진`, `방어 약화`, `재시전 봉인`이 반드시 붙어야 한다.
  - penalty duration 동안 플레이어 상태가 실제 수치와 시전 가능 여부에 반영되어야 한다.
  - burst 종료 직후 활성 조합이 사라져도 aftermath penalty window는 요약 문자열에서 계속 읽혀야 한다.
  - penalty 종료 후 정상 상태로 복귀해야 한다.

### 우선 테스트 기준

- `Ashen Rite` stack 누적
- burst 발동
- burst 이후 penalty timers 적용
- penalty 동안 피해 증가 또는 재시전 제한 반영
- penalty 종료 후 정상 복귀

## 버프 데이터 구조 요구사항

### 활성 버프 인스턴스 필드

- `skill_id`
- `display_name`
- `stack_count`
- `remaining_time`
- `max_duration`
- `source_circle`
- `buff_tags`
- `cooldown_end_time`
- `penalty_tags`

### 활성 조합 인스턴스 필드

- `combo_id`
- `display_name`
- `required_buffs`
- `remaining_charges`
- `runtime_values`
- `penalty_state`

## 계산 방향

### 버프 적용 순서

1. 기본 스킬 수치
2. 스킬 레벨 보정
3. 장비 보정
4. 일반 버프 가산 또는 배율
5. 마스터리 최종 배수
6. 조합 최종 배수 또는 특수효과

### 버프 스택 처리

- 스택이 쌓이면 `피해`, `지속시간`, `범위`, `대상 수`, `투사체 수`, `보호막량` 중 일부가 증가할 수 있다.
- 동일 버프 전부가 같은 증가 공식을 쓰지 않도록 `stack_rule` 분기가 필요할 수 있다.

## 예상 구현 파일

- [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)
- [buff_combos.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/skills/buff_combos.json)
- 필요 시 새 버프 런타임 헬퍼 스크립트
- 새 테스트 파일 또는 [test_game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_state.gd) 확장

## 세부 작업 체크리스트

### 1. 버프 활성 구조 정리

- 활성 버프 저장 형식 통일
- 동일 버프 중복 시 동작 명확화
- 종료 시 제거와 페널티 연결

### 2. 슬롯 제한 연결

- 현재 서클에 따른 유지 가능 개수 계산
- 제한 초과 시 새 버프 시전 정책 결정
- 권장안: 가장 오래된 버프를 밀어내지 말고 시전 실패 피드백 제공

### 3. 조합 감지 정리

- 버프 활성 시 조합 재계산
- 버프 종료 시 조합 해제
- 조합 우선순위 충돌 시 `priority` 기준 적용

### 4. 조합 효과 적용

- 생존형은 보호막, 피해 경감, 상태 보호
- 공격형은 쿨타임 감소, 피해 증폭, 투사체 강화
- 필살형은 누적 스택과 종료 폭발

### 5. 종료 페널티 구현

- `Ashen Rite` 종료 후 재사용 불가 시간 또는 약화 상태
- `Time Collapse` 종료 후 일정 시간 쿨다운 회복 효율 저하 같은 디버프 검토

### 6. HUD 강화

- 버프 아이콘
- 남은 지속시간
- 중첩 수
- 활성 조합 목록
- 조합 전용 자원 예: `Time Charges`, `Ash Stacks`
- 페널티 상태 표시

## 수용 기준

- 버프를 중첩해서 실제 전투 수치를 끌어올릴 수 있다.
- 같은 버프를 중복 시전할 수 있다.
- 조합 4종이 실제 전투 감각을 바꾼다.
- 강한 조합은 종료 후 분명한 리스크를 남긴다.
- HUD에서 현재 버프 상황과 조합 상태를 읽을 수 있다.
- 관리자 샌드박스에서는 버프 슬롯 제한 무시를 통해 고서클 조합을 즉시 재현할 수 있다.

## 테스트 체크포인트

### GUT

- 서클별 동시 유지 수 제한
- 동일 버프 중복 시 중첩 증가
- 조합 발동과 해제
- `Prismatic Guard` 보호막 흡수
- `Overclock Circuit` 번개 강화
- `Time Collapse` 강화 횟수 소모
- `Ashen Rite` 스택 누적과 종료 폭발
- 종료 페널티 부여와 해제

### 헤드리스

- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

## 비목표

- 모든 버프의 전용 이펙트 아트
- 버프 획득 연출
- 관리자 버프 프리셋 저장
- 네트워크 동기화

## 다음 증분

이 작업이 끝나면 다음은 `몬스터 전투 세트 구축`이다. 그때는 근접, 원거리, 돌진형, 엘리트 적을 붙여 버프 중심 전투 루프가 실제 전장에서도 재미있는지 검증한다.

---

## 구현 완료 상태 (2026-03-28)

### 완료된 항목

#### Prismatic Guard (배리어 흡수)
- `try_activate_buff()` 시 `_refresh_combo_runtime()`에서 감지, `combo_barrier`에 배리어량 설정
- `damage()` 호출 시 배리어를 우선 흡수, 잔량은 HP에서 차감
- `get_damage_taken_multiplier()` 반환값에 경감 배율 반영
- GUT: `test_prismatic_guard_barrier_absorbs_damage`, `test_buff_combo_resolves_from_active_buffs`

#### Time Collapse (3회 할인 시전)
- `time_collapse_charges = 3` 초기화, `consume_spell_cast()` 호출마다 1 소모
- `_apply_buff_runtime_modifiers()`에서 쿨다운·피해 보정 적용
- `get_combo_summary()`에서 `[BURST]` 마커 표시
- GUT: `test_time_collapse_grants_three_discounted_casts`, `test_combo_summary_shows_burst_marker_when_time_collapse_active`

#### Ashen Rite (스택 누적 + 종료 폭발)
- `ashen_rite_active` 플래그, `ash_stacks` 카운터
- `register_skill_damage()` 시 스택 증가
- `_tick_buff_runtime()` 내 만료 감지 시 `ash_detonation` 이펙트 방출 (`_emit_combo_effect`)
- `get_combo_summary()`에서 `[BURST]` 마커 표시
- GUT: `test_ashen_rite_builds_stacks_and_emits_detonation`, `test_combo_summary_shows_burst_marker_when_ashen_rite_active`

#### Overclock Circuit (번개 연계 활성화)
- `overclock_circuit_active` 변수 추가 (`game_state.gd`)
- `_refresh_combo_runtime()`에서 combo 감지 시 `push_message("Overclock Circuit engaged. Lightning chains accelerate.", 1.2)` 전송
- 만료 시 플래그 해제
- `_apply_buff_runtime_modifiers()`에서 번개 스킬 쿨다운·관통·속도 보정 적용
- GUT: `test_overclock_circuit_activates_and_shows_activation_message`, `test_overclock_circuit_deactivates_when_buff_expires`

#### Funeral Bloom (배치킬 감지 + ICD + 폭발)
- `funeral_bloom_active`, `funeral_bloom_icd_timer` 변수 추가
- `_refresh_combo_runtime()`에서 `combo_funeral_bloom` 감지 시 활성화, push_message 전송, 만료 시 ICD 초기화 후 해제
- `_tick_buff_runtime()` 내 ICD 타이머 틱 처리
- `notify_deploy_kill()` 퍼블릭 API: 활성 + ICD 없을 때 `corruption_burst` 이펙트 방출, ICD 1.5초 시작
- `get_combo_summary()`에서 Bloom 상태(ready/ICD 잔여시간) 표시
- GUT: `test_funeral_bloom_activates_when_required_buffs_are_present`, `test_funeral_bloom_notify_deploy_kill_emits_corruption_burst`, `test_funeral_bloom_icd_blocks_rapid_repeat_triggers`, `test_funeral_bloom_combo_summary_shows_bloom_state`

#### 기타
- `reset_progress_for_tests()`와 `heal_full()`에 새 상태 변수 초기화 추가
- GUT 전체 156/156 통과 (이번 세션 추가 테스트 6개 포함)

### 미완료 항목 (다음 작업으로 이관)

| 항목 | 설명 | 상태 |
|------|------|------|
| 관리자 버프 탭 강제 발동 | 관리자 샌드박스에서 특정 조합을 즉시 재현할 수 있는 버프 강제 발동 UI | ✅ 완료 (admin buffs 탭 추가) |
| Verdant Overflow 설치형 버프 효과 연결 | plant_verdant_overflow 버프의 deploy_range/duration_multiplier가 실제 설치 스킬에 적용되도록 연결 | ✅ 완료 (2026-03-28) |

#### Verdant Overflow 설치형 버프 효과 연결 (2026-03-28 완료)

- `game_state.gd` — `apply_deploy_buff_modifiers(data)` 추가: `_collect_active_effects()` 순회하여 `deploy_range_multiplier`, `deploy_duration_multiplier`, `deploy_target_bonus` 를 payload에 반영
- `spell_manager.gd _cast_deploy()` — `_build_skill_runtime()` 직후 `GameState.apply_deploy_buff_modifiers(runtime)` 호출
- 효과: `plant_verdant_overflow` 버프 활성 시 Stone Spire 등 설치형 스킬의 사거리와 지속시간이 즉시 증가
- GUT 3개 추가: duration 확장, size 확장, 버프 없을 때 수치 불변
- 전체 205/205 통과

#### notify_deploy_kill() 연결 (2026-03-28 완료)

- `main.gd` `_on_enemy_died()`에서 `GameState.notify_deploy_kill()` 호출 추가
- `player.gd` `receive_hit()`에서 `_school`을 `GameState.damage(amount, _school)`로 전달 (school 추적 활성화)

#### Ashen Rite 종료 페널티 (2026-03-28 완료)

- `_refresh_combo_runtime()` Ashen Rite 종료 분기에서 JSON `penalties` 배열 적용:
  - 즉시: `mana = 0.0` (마나 전량 소진)
  - `active_penalties.append({"stat": "defense_multiplier", "mode": "mul", "value": 0.75, "remaining": 10.0})` — 방어력 25% 감소 10초
  - `active_penalties.append({"stat": "ritual_recast_lock", "mode": "set", "value": 1, "remaining": 6.0})` — 버프 재시전 차단 6초
- `get_damage_taken_multiplier()`에 `defense_multiplier` stat 처리 추가 (`total /= def_val`)
- `try_activate_buff()`에 `ritual_recast_lock` 페널티 체크 추가 (admin_ignore_cooldowns 무시 가능)
- GUT 3개 추가: `test_ashen_rite_end_drains_mana_and_applies_penalties`, `test_ashen_rite_end_penalty_increases_damage_taken`, `test_ashen_rite_recast_lock_blocks_buff_activation`
- 전체 159/159 통과

#### Ashen Rite aftermath summary + penalty recovery 회귀 고정 (2026-04-01 완료)

- `game_state.gd` — `get_combo_summary()`가 활성 조합이 끝난 뒤에도 `active_penalties`를 읽어 `Aftermath / GuardBreak / Lock` 잔여시간을 계속 노출하도록 확장
- `game_state.gd` — `_get_penalty_remaining()`, `_get_ashen_rite_aftermath_summary()` 헬퍼 추가로 페널티 요약 경로를 분리
- 효과: `Ashen Rite` burst 종료 후 `[BURST]` 마커는 사라지지만, 방어 약화와 재시전 봉인 잔여시간은 combo summary에서 계속 읽힌다
- `tests/test_game_state.gd`:
  - `test_combo_summary_shows_ashen_rite_aftermath_window_after_burst`
  - `test_ashen_rite_penalties_expire_and_runtime_returns_to_normal`
- 회귀 기준:
  - burst 종료 직후 summary에 `Aftermath`, `GuardBreak`, `Lock`이 남아야 한다
  - penalty timer 만료 후 `get_damage_taken_multiplier() == 1.0`
  - penalty timer 만료 후 `try_activate_buff()`가 다시 정상 동작해야 한다
- GUT `521/521` 통과, headless `--quit` / `--quit-after 120` 통과

#### hp_drain_percent_per_second 버프 활성 중 틱 처리 + poise_bonus hit_stun 감소 (2026-03-28 완료)

- `game_state.gd` — `_tick_active_buff_drains(delta)` 추가: 각 active_buff의 skill_data `downside_effects` 중 `hp_drain_percent_per_second && duration == 0` 항목을 버프 활성 중 지속 드레인으로 처리 (duration 0 = 만료 페널티 아닌 활성 비용으로 해석). `dark_grave_pact` 활성 시 초당 최대 HP 1.5% 소진. HP 1 이하로 내려가지 않음
- `game_state.gd` — `get_poise_bonus()` 추가: active_effects 순회 → `poise_bonus` stat 합산 반환
- `player.gd receive_hit()` — `HIT_STUN_TIME * (1.0 - poise_reduction)` 적용: `holy_mana_veil`의 poise_bonus 20 → hit_stun_timer 20% 단축
- `_tick_buff_runtime()` — `_tick_active_buff_drains(delta)` 호출 삽입
- GUT 2개 추가: Grave Pact 활성 중 5초 delta → HP 감소, Mana Veil 활성 시 poise_bonus > 0
- 전체 217/217 통과

#### dark_grave_pact kill_leech — 적 처치 HP 흡수 연결 (2026-03-28 완료)

- `game_state.gd` — `notify_enemy_killed()` 추가: `_collect_active_effects()` 순회 → `kill_leech` stat 합산 → `max_health * total * 0.01` HP 회복, push_message로 알림
- `main.gd _on_enemy_died()` — `GameState.notify_enemy_killed()` 호출 추가 (notify_deploy_kill 이전)
- GUT 2개 추가: Grave Pact 활성 시 적 처치 후 HP 증가, kill_leech 없을 때 HP 불변
- 전체 215/215 통과

#### arcane_world_hourglass cast_speed/cooldown_flow 연결 (2026-03-28 완료)

- `game_state.gd _apply_buff_runtime_modifiers()` — `cast_speed_multiplier` case 추가: `cooldown / value` 적용 (1.3x 속도 → 쿨타임 23% 단축)
- `game_state.gd _apply_buff_runtime_modifiers()` — `cooldown_flow_multiplier` case 추가: `cooldown * value` 적용 (0.78 → 쿨타임 22% 추가 단축)
- `downside_effects` 경로(active_penalties)도 동일 match 문 처리 → 버프 만료 후 cast_speed 0.75 페널티로 쿨타임 33% 증가
- GUT 2개 추가: 버프 활성 시 fire_bolt 쿨타임 감소, 만료 페널티 직접 주입 시 쿨타임 증가
- 전체 213/213 통과

#### Dark buff modifiers — apply_spell_modifiers + toggle tick 연결 (2026-03-28 완료)

- `game_state.gd` — `dark_final_damage_multiplier`, `aftercast_multiplier` case를 `_apply_buff_runtime_modifiers()`에 추가
- `game_state.gd` — `mana_efficiency_multiplier` 처리를 `get_skill_mana_cost()`에 추가 (arcane_astral_compression 효과)
- `game_state.gd` — `apply_spell_modifiers(data)` public wrapper 추가 (스펠 매니저·테스트에서 직접 호출 가능)
- `spell_manager.gd _tick_toggles()` — toggle 틱 payload에 `GameState.apply_spell_modifiers(payload)` 적용 (dark_grave_pact 등 버프가 Soul Dominion/Grave Echo 데미지에 반영)
- GUT 3개 추가 (test_game_state.gd): dark_grave_pact 배율 검증, mana_efficiency_multiplier 비용 감소 검증, 버프 없을 때 비용 불변
- 전체 208/208 통과

#### super_armor_charges — holy_crystal_aegis 슈퍼아머 연결 (2026-03-28 완료)

- `game_state.gd` — `get_super_armor_charges()` 추가: `_collect_active_effects()` 순회 → `super_armor_charges` stat 합산 반환
- `player.gd receive_hit()` — `get_super_armor_charges() > 0` 시 velocity/hit_stun 적용 없이 `GameState.damage(amount, _school)`만 처리하고 즉시 반환
- 효과: Crystal Aegis 활성 중 피격 시 넉백·경직 없이 데미지만 받음
- GUT 2개 추가: 버프 활성 시 super_armor_charges > 0, Crystal Aegis 활성 시 charges 존재 확인
- 전체 219/219 통과

#### mana_regen_multiplier 페널티 + self_burn 페널티 처리 (2026-03-28 완료)

- `game_state.gd _tick_mana_regeneration()` — `_collect_active_effects()`에서 `mana_regen_multiplier` stat 합산 → regen_per_second에 배율 적용. 0.0이면 재생 즉시 차단 (lightning_conductive_surge 만료 후 6초 마나 재생 정지)
- `game_state.gd _tick_active_buff_drains()` — `active_penalties` 순회 추가: `self_burn` stat 발견 시 `max_health * value * 0.01 * delta` HP 소진. HP 1 이하 내려가지 않음 (fire_pyre_heart 만료 후 4초 자기 화염 피해)
- GUT 4개 추가: mana_regen_multiplier 0.0 시 마나 재생 차단, 페널티 없을 때 정상 재생, self_burn 틱 피해 확인, HP 1 최솟값 보호
- 전체 223/223 통과

#### extra_lightning_ping — lightning_conductive_surge 번개 추가 핑 연결 (2026-03-28 완료)

- `game_state.gd apply_spell_modifiers()` — 반환 직전 lightning spell 감지: `_collect_active_effects()`에서 `extra_lightning_ping` 발견 시 `_emit_combo_effect()`로 `lightning_ping` 버스트 방출 (damage × 0.45, radius 52, school lightning)
- 효과: lightning_conductive_surge 버프 활성 중 번개 스킬 시전 시 자동으로 보조 번개 방전 발생
- GUT 2개 추가: 번개 스킬 시전 시 lightning_ping 이펙트 방출, 비번개 스킬 시전 시 미방출
- 전체 225/225 통과

#### mana_percent 즉시 소진 + deploy_recast_delay 페널티 차단 (2026-03-28 완료)

- `game_state.gd try_activate_buff()` — 버프 추가 직후 `downside_effects` 중 `mana_percent && mode == set && duration == 0.0` 항목 처리: `mana = max_mana * value`로 즉시 설정 (dark_throne_of_ash 활성화 시 마나 전량 소진)
- `spell_manager.gd _cast_deploy()` — 최상단에 `active_penalties` 순회 추가: `deploy_recast_delay` stat 발견 시 즉시 실패 반환 (plant_verdant_overflow 만료 후 6초 설치형 스킬 재시전 차단)
- GUT 4개 추가 (test_game_state 2, test_spell_manager 2): ash 버프 활성화 시 마나 0 확인, 일반 버프 마나 유지 확인, deploy_recast_delay 시 배치 차단, 페널티 없을 때 배치 정상 시전
- 전체 229/229 통과

#### stagger_taken_multiplier 페널티 + ice_reflect_wave 보조 파동 연결 (2026-03-28 완료)

- `game_state.gd` — `get_stagger_taken_multiplier()` 추가: `_collect_active_effects()` 순회 → `stagger_taken_multiplier` stat 곱산 반환 (wind_tempest_drive 만료 후 2s 페널티로 경직·넉백 15% 증가)
- `player.gd receive_hit()` — stagger_mult 적용: `hit_stun_timer *= stagger_mult`, `knockback *= stagger_mult` (슈퍼아머가 없을 때만 적용)
- `game_state.gd apply_spell_modifiers()` — ice spell 감지 시 `ice_reflect_wave` effect 확인 → `_emit_combo_effect()` 로 `ice_reflect_wave` 버스트 방출 (damage × 0.35, radius 60, school ice). `ice_frostblood_ward` 버프 활성 중 빙결 스킬 시전 시 자동 반사파 발생
- GUT 4개 추가: stagger 배율 기본값 1.0, 페널티 주입 시 1.0 초과, 얼음 스킬 시전 시 반사파 방출, 비얼음 스킬 미방출
- 전체 233/233 통과

#### ash_residue_burst 솔로 버프 경로 연결 (2026-03-28 완료)

- `game_state.gd _tick_buff_runtime()` — `ashen_rite_active` 단독 조건을 확장: `_collect_active_effects()`에서 `ash_residue_burst` stat 발견 시에도 동일하게 1.25s 주기 버스트 방출. 이제 `dark_throne_of_ash`를 Ashen Rite 콤보 없이 단독 사용해도 잔여물 버스트가 발생
- 효과: dark_throne_of_ash 단독 활성 시에도 fire 범위 폭발이 1.25s마다 자동 방출 (damage = 16 + ash_stacks × 2, radius 54)
- GUT 2개 추가: dark_throne_of_ash 단독 활성 시 ash_residue_burst 방출 확인, 버프 없을 때 미방출 확인
- 전체 235/235 통과
