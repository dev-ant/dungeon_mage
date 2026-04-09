---
title: 내 작업 스트림 아카이브
doc_type: archive
status: archived
section: collaboration
owner: owner_core
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/owner_core_workstream.md
update_when:
  - status_changed
  - structure_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 내 작업 스트림 아카이브

상태: 아카이브  
최종 갱신: 2026-04-02  
담당자: 프로젝트 오너  
AI 역할: 전투 코어 / 데이터 / 비 GUI 구현

이 문서는 2026-04-02에 [owner_core_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/owner_core_workstream.md)에서 롤오버된 누적 로그 보관본이다.

현재 작업 우선순위와 활성 교차 의존 요청은 [owner_core_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/owner_core_workstream.md)를 우선해서 본다.

## 역할 요약

이 문서는 `아이템창`, `스킬창`, `설정창`, `장비창` GUI 구현을 제외한 내 작업만 추적한다.

친구가 맡은 GUI 창 관련 파일은 수정하지 않는다.

## 읽어야 할 기준 문서

- [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)
- [combat_first_build_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md)
- [combat_increment_02_spell_runtime.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_02_spell_runtime.md)
- [combat_increment_03_buff_action_loop.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_03_buff_action_loop.md)
- [combat_increment_04_enemy_combat_set.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_04_enemy_combat_set.md)
- [combat_increment_05_equipment_minimum.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_05_equipment_minimum.md)
- [combat_increment_09_soul_dominion_risk.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_09_soul_dominion_risk.md)
- [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)

## 내 작업 범위

- 전투 런타임 구조 보강
- 스킬 추가 구현
- 버프 조합과 리스크 시스템
- 몬스터 확장
- 샌드박스 전투 흐름
- 데이터 정리와 로더 유지보수
- GUI 창과 직접 관련되지 않은 테스트 보강

## 제외 범위

- 아이템창 GUI
- 스킬창 GUI
- 설정창 GUI
- 장비창 GUI
- 위 창들의 입력, 버튼, 패널, 드래그/드롭, 마우스 상호작용
- 친구 소유 파일 전체

## 수정 가능한 파일

- `data/**`
- `scripts/player/**`
- `scripts/enemies/**`
- `scripts/world/**`
- `scripts/autoload/**`
- `tests/test_player_controller.gd`
- `tests/test_spell_manager.gd`
- `tests/test_game_state.gd`
- `tests/test_enemy_base.gd`
- `tests/test_equipment_system.gd`

## 수정 금지 파일

- `scripts/admin/admin_menu.gd`
- `scripts/ui/game_ui.gd`
- `scripts/ui/**` 의 GUI 창 관련 파일
- `scenes/ui/**`
- `scenes/main/Main.tscn`
- `tests/test_admin_menu.gd`

## 현재 우선순위

1. GUI 창과 독립적인 전투 로직을 계속 전진시킨다.
2. 친구 GUI 작업이 요구할 수 있는 읽기 전용 데이터 구조를 안정적으로 유지한다.
3. GUI가 붙었을 때 바로 연결 가능한 런타임 상태를 문서와 테스트로 고정한다.

## 진행 체크리스트

- [ ] 다음 전투 코어 목표를 한 번에 하나씩 선택한다.
- [ ] 수정 파일이 내 소유 파일인지 먼저 확인한다.
- [ ] 적 스탯, 데미지 감쇠, 저항, 슈퍼아머, 브레이크 규칙을 바꿀 때 `enemy_stat_and_damage_rules.md`를 함께 수정한다.
- [ ] 구현 전 관련 GUT 테스트를 만들거나 보강한다.
- [ ] 구현 후 headless 체크와 GUT를 돌린다.
- [ ] 아래 진행 로그를 갱신한다.

## 진행 로그

### 2026-04-01

- 적 전투 수치 기준 문서 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)를 실제 런타임과 테스트에 반영했다.
- `data/enemies/enemies.json`에 방어력, 속성 저항, 상태이상 저항, 슈퍼아머, 취약 배수 필드를 전 적 타입에 확장했다.
- `scripts/enemies/enemy_base.gd`에 방어력 감쇠, 속성 저항/약점, 최소 피해 10%, 슈퍼아머 감쇠, 브레이크, 취약 상태, 상태이상 저항 계산 경로를 연결했다.
- `scripts/main/main.gd`에 엘리트 후보 타입의 `3%` variant 승격 훅을 추가하고, 기존 standalone `elite` 타입은 호환 유지 단계로 남겼다.
- `scripts/player/spell_projectile.gd`와 관련 테스트를 갱신해 projectile hit 경로도 최종 계산 피해를 기준으로 기록하게 맞췄다.
- `tests/test_enemy_base.gd`, `tests/test_spell_manager.gd`를 새 규칙 기준으로 갱신했고 headless + GUT `516/516`을 통과했다.

### 2026-03-30

- 역할 분리 문서 생성.
- GUI 창 관련 코드는 친구 workstream으로 이관.

### 2026-03-31 (1차 세션)

- `combat_increment_04_enemy_combat_set.md`에 `미궁박쥐`, `웜`, `미궁버섯` 에셋 우선 적용 기준 추가.
- `combat_first_build_plan.md`에 다음 몬스터 에셋 우선 적용 대상 연결 메모 추가.
- 세 몬스터 모두 `대표 PNG 1장`이 아니라 `해당 폴더의 전체 애니메이션 세트`를 적용 대상으로 보도록 문구 보강.

### 2026-03-31 (2차 세션 - Cycle 1)

#### 박쥐(bat) + 웜(worm) 적 스프라이트 및 타입 구현 완료

**완료 항목:**
- `asset-import` 파이프라인 실행: bat(64×64), worm(90×90) 프레임 분석 + 픽셀 바운드 계산
  - bat: char_h=31, feet_from_center=+9.9, scale=1.4, position=(0,-10)
  - worm: char_h=44, feet_from_center=+12.0, scale=1.1, position=(0,+14)
- 에셋 복사: `assets/monsters/bat/`, `assets/monsters/worm/`
- `scripts/enemies/enemy_base.gd` 수정:
  - `BAT_SHEETS`, `BAT_SHEET_DIR`, `BAT_ANIM_FILES` 상수 추가 (idle/run/attack/attack2/hurt/death/sleep/wakeup)
  - `WORM_SHEETS`, `WORM_SHEET_DIR`, `WORM_ANIM_FILES` 상수 추가 (idle/run/attack/hurt/death)
  - `_setup_sprite()` 리팩터링: match 분기로 bat/worm/mushroom 타입별 파라미터 분기
  - `_physics_process()`: bat 호버링 (타겟 90px 위 유지, velocity.y 능동 제어)
  - `_apply_stats_from_data()` fallback: bat(HP28/speed110/dmg9/period1.8), worm(HP45/speed160/dmg14/period2.2)
  - `_run_ai()` pursue 분기: bat(kite 140px/attack 320px), worm(대시 예고 0.55s/charge 140px)
  - `_run_ai()` kite 분기: bat(320px 이탈→추격, 140px 이상 공격)
  - `_on_attack_state_entered()`: bat→_fire_bat_shot(), worm→480px 지상 돌진
  - `_fire_bat_shot()` 헬퍼 추가: 플레이어 방향 280px/s 투사체, damage=9, range=400
  - `_build_state_chart()`: "bat" kite 복귀 타입 목록 추가
- `data/enemies/enemies.json`: bat/worm 엔트리 추가
- `tests/test_enemy_base.gd`: bat 4개 + worm 4개 = 8개 테스트 추가

**검증:**
- `godot --headless --quit`: 통과
- GUT 전체: 141/141 통과 (신규 포함)

### 2026-03-31 (2차 세션 - Cycle 2)

#### projectile_speed_multiplier 런타임 연결 완료

**완료 항목:**
- `scripts/autoload/game_state.gd`: `get_equipment_projectile_speed_multiplier()` 함수 추가
  - `_get_equipment_stat_product("projectile_speed_multiplier")`, 하한 1.0
- `scripts/player/spell_manager.gd`: 투사체 생성 시 speed_mult 적용
  - `velocity_value = Vector2(speed * facing * speed_mult, 0.0)`
- `data/items/equipment.json`: 3개 신규 아이템 추가
  - `focus_swift_prism` (offhand, rare): projectile_speed ×1.20 + lightning ×1.08
  - `ring_flux_band` (accessory_1, uncommon): projectile_speed ×1.10
  - `armor_guardian_coat` (body, rare): barrier_power ×1.20 + max_hp +10 (보호막 계열 확장)
- `tests/test_equipment_system.gd`: 5개 테스트 추가
  - projectile_speed 기본값 1.0 확인
  - Swift Prism/Flux Band 각각 multiplier 증가 확인
  - 두 아이템 중첩 시 1.25× 초과 확인
  - Guardian Coat barrier_power ≥1.15 확인

**검증:**
- `godot --headless --quit`: 통과
- GUT 전체: 141+40+21+71+16+37 = 326/326 통과 (신규 5개 포함)

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd에 bat/worm 소환 타입 추가 요청** (교차 의존, 친구 소유)
2. **인크리먼트 2 (스킬 런타임)**: 7서클 스킬 구현 계획 수립
3. **인크리먼트 3 (버프 액션 루프)**: 관리자 버프 강제 발동 탭은 친구 소유이므로 건너뜀
   - 남은 작업 없음 (내 담당 버프 런타임은 모두 완료)
4. **인크리먼트 4 확장**: mushroom을 독립 타입으로 분리하거나 비주얼 개선 검토

### 2026-03-31 (3차 세션 - Cycle 1~5)

#### mushroom 독립 타입 구현 (Cycle 1)

**완료 항목:**
- `scripts/enemies/enemy_base.gd`:
  - `MUSHROOM_FULL_SHEETS` / `MUSHROOM_FULL_ANIM_FILES` 상수 추가 (attack2=24프레임, stun=18프레임)
  - `mushroom_stun_attack_active`, `mushroom_stun_attack_counter` 변수 추가
  - `_setup_sprite()` "mushroom" 분기 추가 (MUSHROOM_FULL_SHEETS, frame 80×64)
  - `_apply_stats_from_data()` fallback에 "mushroom" 추가 (HP60/speed100/dmg12/period1.8)
  - `_run_ai()` pursue에 "mushroom" 분기 추가 (72px 이내 attack_window)
  - `_update_enemy_anim()` attack 상태에서 mushroom_stun_attack_active → "attack2" 사용
  - `_on_attack_state_entered()` "mushroom" 분기: 매 3번째 공격이 stun attack (dmg+6, knockback 320)
  - `attack_state.state_exited`: mushroom_stun_attack_active 리셋 추가
- `data/enemies/enemies.json`: mushroom 엔트리 추가
- `tests/test_enemy_base.gd`: mushroom 5개 테스트 추가

**검증:** GUT 331/331 통과

#### projectile_count_bonus 런타임 연결 (Cycle 2)

**완료 항목:**
- `scripts/autoload/game_state.gd`: `get_equipment_projectile_count_bonus()` 추가
- `scripts/player/spell_manager.gd`: attempt_cast() 내 extra projectile 방출 로직 추가 (각도 ±15° 스프레드)
- `data/items/equipment.json`: 2개 신규 아이템 추가
  - `accessory_split_lens` (accessory_2, rare): projectile_count +1
  - `accessory_triple_prism` (accessory_2, epic): projectile_count +2
- `tests/test_equipment_system.gd`: 4개 테스트 추가

**검증:** GUT 335/335 통과

#### 방 데이터 확장 + get_all_rooms() API (Cycle 3)

**완료 항목:**
- `scripts/autoload/game_database.gd`: `get_all_rooms()` 함수 추가
- `data/rooms.json`:
  - entrance 방: mushroom 스폰 추가
  - vault_sector 4번째 방 추가 (mushroom×2 + charger + elite + bat, rest point 포함)
- `tests/test_game_state.gd`: room 로딩 5개 테스트 추가

**검증:** GUT 340/340 통과

#### wind/water/plant 속성 스펠 + 장비 multiplier 연결 (Cycle 4)

**완료 항목:**
- `data/spells.json`: 2개 신규 스펠 추가
  - `water_aqua_bullet`: water 속성, damage 16, speed 820, range 360, pierce 없음
  - `wind_gale_cutter`: wind 속성, damage 14, speed 1100, range 480, pierce 3
- `scripts/autoload/game_state.gd`:
  - `SCHOOL_ORDER` 확장: wind/water/plant 추가
  - `get_equipment_damage_multiplier()`: wind/water/plant case 추가
  - `resonance` 초기값 및 `reset_progress_for_tests()` 내 리셋에 wind/water/plant 추가
- `data/items/equipment.json`: 3개 신규 아이템 추가
  - `focus_gale_shard` (offhand, rare): wind_damage ×1.20
  - `ring_tidal_crest` (accessory_1, rare): water_damage ×1.18
  - `ring_verdant_coil` (accessory_2, uncommon): plant_damage ×1.12 + installation_duration ×1.10
- `tests/test_game_state.gd`: 6개 테스트 추가

**검증:** GUT 346/346 통과, headless --quit/--quit-after 120 모두 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd에 mushroom 소환 타입 추가 요청** (교차 의존, 친구 소유)
2. **7서클 스킬 구현**: plant_vine_snare (deploy) 런타임 편입 검토
3. **water/wind 스펠 hotbar 슬롯 추가**: DEFAULT_SPELL_HOTBAR에 water/wind 슬롯 추가 (현재 6슬롯 중 일부 교체 또는 확장 방안 결정 필요)
4. **Soul Dominion 이후**: 인크리먼트 미작성 고서클 스킬 (arcane_astral_compression, dark_soul_dominion 외 추가 toggle 스킬) 런타임 점검

### 2026-03-31 (4차 세션 - Cycle 1~4)

#### water/wind/plant 핫바 슬롯 추가 (Cycle 1~2)

**완료 항목:**
- `scripts/autoload/game_state.gd`:
  - `DEFAULT_SPELL_HOTBAR`: `spell_water` (U, water_aqua_bullet), `spell_wind` (I, wind_gale_cutter), `spell_plant` (P, plant_vine_snare) 3개 슬롯 추가 → 총 9슬롯
  - `ensure_input_map()`: `spell_water` (KEY_U), `spell_wind` (KEY_I), `spell_plant` (KEY_P) 액션 등록 추가
- `tests/test_game_state.gd`: 5개 테스트 추가
  - 핫바에 spell_water/spell_wind/spell_plant 슬롯 존재 확인 (skill_id, label 포함)
  - plant_vine_snare 스킬 타입 = "deploy", element = "plant" 확인
  - plant_vine_snare deploy 파라미터 유효성 확인 (range_base, duration_base, mana_cost_base > 0)

**검증:** GUT 353/353 통과, headless --quit 통과

#### plant_vine_snare deploy 런타임 연결 (Cycle 2)

**완료 항목:**
- plant_vine_snare는 `skills.json`에 `skill_type: "deploy"`, `element: "plant"`로 이미 정의됨
- `_cast_deploy()` → `_build_skill_runtime()` 파이프라인 자동 처리 확인
  - duration = `duration_base * duration_scale * get_equipment_install_duration_multiplier()`
  - `ring_verdant_coil` 장착 시 duration 증가 검증
- `tests/test_spell_manager.gd`: 2개 테스트 추가
  - plant_vine_snare deploy 캐스트 → payload school = "plant" 확인
  - ring_verdant_coil 장착 시 deploy duration 증가 확인

**검증:** GUT 353/353 통과

#### 고서클 toggle 스킬 런타임 점검 (Cycle 3~4)

**완료 항목:**
- `ice_glacial_dominion` (circle 8, ice toggle), `lightning_tempest_crown` (circle 9, lightning toggle) 런타임 확인
  - 두 스킬 모두 `_cast_toggle()` 제네릭 파이프라인으로 처리됨 (코드 수정 불필요)
  - 각각 school = "ice" / "lightning" payload 방출 검증
  - 두 toggle 동시 활성 시 각 school payload 방출 검증
- `arcane_astral_compression` (circle 8, buff) 런타임 확인
  - `skill_type: "buff"` → `try_activate_buff()` 제네릭 처리
  - `final_damage_multiplier: 1.16` → `_apply_buff_runtime_modifiers()` line 1473에서 이미 처리
  - `mana_efficiency_multiplier: 0.88` → `get_skill_mana_cost()` line 1612에서 이미 처리
  - 코드 수정 없이 완전한 런타임 지원 확인됨
- `tests/test_spell_manager.gd`: 3개 테스트 추가
  - ice_glacial_dominion toggle on/off + ice payload 방출 확인
  - lightning_tempest_crown toggle on/off + lightning payload 방출 확인
  - dark_grave_echo + ice_glacial_dominion 동시 활성 다중 school payload 확인
- `tests/test_game_state.gd`: 4개 테스트 추가
  - arcane_astral_compression skill_type = "buff" 확인
  - Astral Compression 활성 시 fire_bolt damage 증가 확인
  - Astral Compression 활성 시 mana cost 감소 확인
  - Astral Compression final_multiplier가 모든 school(fire, lightning)에 적용되는지 확인

**검증:** GUT 360/360 통과, headless --quit-after 120 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd에 bat/worm/mushroom 소환 타입 추가 요청** (교차 의존, 친구 소유)
2. **인크리먼트 5 (장비 최소화)**: 장비 시스템 미완성 부분 점검 — 장비 최대 강화 tier 또는 추가 레어리티(legendary) 아이템 검토
3. **Soul Dominion 리스크 시스템**: `combat_increment_09_soul_dominion_risk.md` 기준으로 aftershock 타이머 관련 추가 테스트 보강
4. **새 방 추가**: 현재 4개 방 (entrance, conduit, deep_gate, vault_sector) → 5번째 방 설계 검토

### 2026-03-31 (5차 세션 - Cycle 1~5)

#### legendary 장비 3개 + boss 전용 드롭 프로필 추가 (Cycle 1)

**완료 항목:**
- `data/items/equipment.json`: legendary 희귀도 아이템 3개 추가
  - `focus_arcane_sovereign` (offhand, legendary): fire/lightning ×1.10, magic_attack +6, cooldown_recovery +0.08, max_mp +20
  - `armor_soul_weave` (body, legendary): max_hp +25, max_mp +30, mp_regen +6, damage_taken_multiplier 0.85
  - `ring_prismatic_apex` (accessory_1, legendary): buff_duration ×1.30, aoe_radius ×1.20, projectile_speed ×1.15
- `scripts/autoload/game_database.gd`:
  - `DROP_CHANCE`에 "boss": 0.70 추가
  - `DROP_RARITY_FILTER`에 "boss": ["epic", "legendary"] 추가
- `data/enemies/enemies.json`: boss 적 drop_profile "rare" → "boss" 변경
- `tests/test_equipment_system.gd`: 6개 테스트 추가
  - legendary 아이템 3종 로드 확인
  - boss 드롭 풀에 epic/legendary만 포함되는지 확인
  - focus_arcane_sovereign fire/lightning 배율 확인

**주의:** weapon 슬롯 카운트는 test_admin_menu.gd가 "Items 1-4/4" 고정 체크함 → weapon 아이템 추가 불가

**검증:** GUT 366/366 통과

#### arcane_core 5번째 방 추가 (Cycle 2)

**완료 항목:**
- `data/rooms.json`: `arcane_core` 방 추가
  - width=2200, background="#0d0d1f" (아케인/어둠 테마)
  - floor_segments 6개 (최고 높이 구성)
  - spawns: bat + ranged + worm + elite + boss (최난이도)
  - objects: echo ×3 + rest + rope
  - core_position 포함 (최종 목표 오브젝트)
  - entry_text: 현재 위치를 이미 알고 있는 무언가에 대한 암시
- `tests/test_game_state.gd`: 4개 테스트 추가

**검증:** GUT 370/370 통과

#### Soul Dominion aftershock 엣지케이스 테스트 보강 (Cycle 3)

**완료 항목:**
- `tests/test_spell_manager.gd`: 3개 테스트 추가
  - aftershock 기간 중 damage_taken_multiplier 증가 확인
  - get_soul_dominion_risk_summary() active/aftershock 상태 문자열 확인
  - aftershock 만료 후 Soul Dominion 재활성화 가능 확인

**검증:** GUT 373/373 통과

#### earth/holy 스펠 추가 (Cycle 4)

**완료 항목:**
- `data/spells.json`: 2개 신규 스펠 추가
  - `earth_tremor`: earth 속성, damage 20, range 88 (근거리 AOE), knockback 380, pierce 없음
  - `holy_radiant_burst`: holy 속성, damage 19, speed 680, range 320 (투사체)
- `scripts/autoload/game_state.gd`:
  - `SCHOOL_ORDER` 확장: earth/holy 추가
  - `resonance` 초기값 및 `reset_progress_for_tests()` 리셋에 earth/holy 추가
- `tests/test_game_state.gd`: 5개 테스트 추가

**검증:** GUT 378/378 통과

#### earth/holy 핫바 슬롯 + 전용 장비 추가 (Cycle 5)

**완료 항목:**
- `scripts/autoload/game_state.gd`:
  - `DEFAULT_SPELL_HOTBAR`: `spell_earth` (O, earth_tremor), `spell_holy` (K, holy_radiant_burst) 2개 슬롯 추가 → 총 11슬롯
  - `ensure_input_map()`: spell_earth (KEY_O), spell_holy (KEY_K) 액션 등록
- `data/items/equipment.json`: 2개 장비 추가
  - `greaves_earthen_stride` (legs, rare): earth_damage ×1.16, installation_duration ×1.08
  - `helm_holy_halo` (head, rare): holy_damage ×1.16, buff_duration ×1.10
- `tests/test_game_state.gd`: 4개 테스트 추가

**검증:** GUT 382/382 통과, headless --quit/--quit-after 120 모두 통과

---

## 6차 세션

### Cycle 1 — 신규 에셋 5종 몬스터 정식 편입 (2026-03-31)

**배경:** combat_first_build_plan.md line 94: "다음 우선 구현은 신규 에셋 5종(Rat, tooth walker, Eye ball Monster, Trash Monster, Sword)의 정식 몬스터 편입과 에셋 적용으로 고정한다"

**완료 항목:**

**에셋 분석 결과:**
- Rat: 32×32 separate PNG ×5 (idle 6f, run 6f, attack 6f, hurt 1f, death 6f)
- Tooth Walker: 384×320 grid sheet → 64×64 per frame, 6 cols × 5 rows
- Eye Ball Monster: 128×2400 vertical strip → 128×48 per frame, 50 frames total
- Trash Monster: 384×384 grid sheet → 64×64 per frame, 6 cols × 6 rows
- Sword: 1792×512 grid sheet → 128×64 per frame, 14 cols × 8 rows

**에셋 복사:**
- `asset_sample/Monster/Rat/NoneOutlinedRat/*.png` → `assets/monsters/rat/`
- `asset_sample/Monster/tooth walker/*.png` → `assets/monsters/tooth_walker/tooth-walker-sheet.png`
- `asset_sample/Monster/Eye ball Monster/*.png` → `assets/monsters/eyeball/eyeball-sheet.png`
- `asset_sample/Monster/Trash Monster/Trash Monster-Sheet.png` → `assets/monsters/trash_monster/trash-monster-sheet.png`
- `asset_sample/Monster/Sword/Sword.png` → `assets/monsters/sword/sword-sheet.png`

**`data/enemies/enemies.json`**: 5개 적 추가
- `rat` (fast_melee_swarm): HP 22, speed 170, dmg 8, period 1.2
- `tooth_walker` (slow_bite_chaser): HP 55, speed 85, dmg 16, period 1.6
- `eyeball` (flying_observer): HP 32, speed 90, dmg 7, period 2.0, tint #b06dc8
- `trash_monster` (trash_tank): HP 80, speed 70, dmg 18, period 2.0
- `sword` (agile_sword_fighter): HP 38, speed 190, dmg 14, period 1.8

**`scripts/enemies/enemy_base.gd`**: 다수 수정
- 5종 스프라이트 상수 추가 (RAT_SHEETS, TOOTH_WALKER_ANIM_ROWS, EYEBALL_ANIM_VERT, TRASH_MONSTER_ANIM_ROWS, SWORD_ANIM_ROWS)
- `_setup_sprite()`: rat은 기존 separate-PNG 방식, 나머지 4종은 grid/vertical 전처리 분기
- `_setup_sprite_grid()`: 신규 helper — 행 기반 다중 애니메이션 그리드 시트 로더
- `_setup_sprite_vertical()`: 신규 helper — 수직 스트립 시트 로더
- 5종 폴백 스탯 추가 (GameDatabase 미사용 시)
- flying 호버 조건: `"bat"` → `["bat", "eyeball"]`
- pursue AI: rat(56px), tooth_walker(96px), eyeball(kite 120px), trash_monster(80px), sword(telegraph rush)
- kite AI: eyeball 전용 분기 추가 (280px 복귀, 120px 공격)
- 상태전환: eyeball → kite 세트에 포함
- `_on_attack_state_entered()`: 5종 공격 분기 추가
- `_fire_eyeball_shot()`: 신규 — 플레이어 방향 조준 투사체 발사

**`tests/test_enemy_base.gd`**: 9개 테스트 추가
- rat/tooth_walker/eyeball/trash_monster/sword 각 configure 확인
- eyeball 투사체 발사 시그널 확인
- 5종 일괄 로드 확인

**검증:** GUT 390/390 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd에 5종 신규 몬스터 소환 타입 추가 요청** (교차 의존, 친구 소유): rat, tooth_walker, eyeball, trash_monster, sword
2. **dark/arcane 원소 스펠 추가**: dark와 arcane 속성 projectile 스펠 추가 (현재 dark는 toggle, arcane은 buff만 있음)
3. **장비 프리셋 확장**: earth/holy 빌드 프리셋 추가 — 기존 fire_burst/lightning_tempo/ritual_control에 earth_deploy/holy_guard 프리셋 추가
4. **LEGACY_SPELL_TO_SKILL 확장**: earth_tremor, holy_radiant_burst를 skills.json과 연결 (mastery_bonus 적용 경로 확인)

### Cycle 2 — 몬스터 체력바 구현 (2026-03-31)

**완료 항목:**

`scripts/enemies/enemy_base.gd` 수정:
- 변수 추가: `health_bar_bg: Polygon2D`, `health_bar_fill: Polygon2D`
- 상수 추가: `HP_BAR_W = 36.0`, `HP_BAR_H = 4.0`, `HP_BAR_Y = -38.0`
- `_build_health_bar()` 신규 추가:
  - headless 가드 (`DisplayServer.get_name() == "headless"` 시 skip)
  - 배경 바: `#374151` (어두운 회색), z_index=2
  - 채움 바: 초기 `#4ade80` (초록), z_index=3
  - 위치: `Vector2(0, -38)` — body_polygon 상단(-28) 기준 10px 위
- `_update_health_bar()` 신규 추가:
  - `ratio = health / max_health`
  - fill polygon 너비를 ratio에 비례해 왼쪽 정렬로 재계산
  - 컬러 분기: `> 50%` → `#4ade80` 초록 / `> 20%` → `#fb923c` 주황 / `≤ 20%` → `#ef4444` 빨강
- `_ready()`: `_build_health_bar()` 호출 추가 (`_build_state_chart()` 직후)
- `configure()`: `_update_health_bar()` 호출 추가 (stats 반영 + health = max_health 직후)
- `receive_hit()`: `_update_health_bar()` 호출 추가 (`health -= amount` 직후)

**검증:** GUT 390/390 통과

---

### Cycle 3 — fire_bolt 스킬 이펙트 에셋 시범 적용 (2026-03-31)

**배경:** `asset_sample/Effect/Fx_pack/3/` 폴더에 fire bolt 애니메이션 PNG 61장(1_0.png ~ 1_60.png, 각 100×100 RGBA)이 추가됨. 스킬 이펙트 에셋을 투사체에 최초 시범 적용.

**분석 결과:**
- 61프레임 전체가 동일 위치(x=15~61, y=40~68)에서 반복되는 루프 패턴
- 기본 방향: RIGHT (콘텐츠가 캔버스 좌측에 위치 — 화염이 오른쪽으로 이동)
- 파일 수 절감 전략: **4프레임 간격 샘플링** (0, 4, 8, ..., 56) → 전체 사이클을 고르게 커버하면서 파일 수를 61 → 15장으로 4분의 1 감축

**에셋 복사:**
- `asset_sample/Effect/Fx_pack/3/1_{0,4,8,...,56}.png` (15장) → `assets/effects/fire_bolt/fire_bolt_0~14.png`

**`scripts/player/spell_projectile.gd`** 수정:
- `_build_visual()`: `spell_id == "fire_bolt"` 시 폴리곤 대신 `_build_fire_bolt_visual()` 호출
- `_build_fire_bolt_visual()` 신규 추가:
  - `AnimatedSprite2D` 생성, SpriteFrames에 15장 로드
  - `loop: true`, `fps: 12.0` (1.25초 루프)
  - `scale = 0.5` (100px 캔버스 → 50px 인게임 표시)
  - 방향: `velocity.x >= 0` → `scale.x = +0.5` / `velocity.x < 0` → `scale.x = -0.5`

**검증:** headless --quit 통과, asset_sample 참조 없음 확인

**비고 — 향후 이펙트 에셋 확장 기준:**
- 이 fire_bolt 적용이 스킬 이펙트 에셋 적용의 기준 패턴이 됨
- 이후 다른 스펠(frost_nova, volt_spear 등) 이펙트 추가 시 동일 패턴 사용:
  1. `assets/effects/<spell_id>/` 폴더에 복사
  2. `spell_projectile.gd`의 `_build_visual()`에 `spell_id == "<id>"` 분기 추가
  3. 방향은 `velocity.x` 기준 `scale.x` 반전

### 2026-04-01 (7차 세션 - Cycle 1~5)

#### dark/arcane 원소 스펠 추가 (Cycle 1)

**완료 항목:**
- `data/spells.json`: 2개 신규 스펠 추가
  - `dark_void_bolt`: dark 속성, damage 24, speed 880, range 400, pierce 1
  - `arcane_force_pulse`: arcane 속성, damage 17, speed 940, range 460
- `scripts/autoload/game_state.gd`:
  - `SCHOOL_ORDER` 확장: dark/arcane 추가 → 총 10개 스쿨
  - `DEFAULT_SPELL_HOTBAR`: `spell_dark` (L, dark_void_bolt), `spell_arcane` (M, arcane_force_pulse) 슬롯 추가 → 총 13슬롯
  - `ensure_input_map()`: spell_dark (KEY_L), spell_arcane (KEY_M) 등록 추가
  - `resonance` 초기값: dark/arcane 0으로 추가
  - `reset_progress_for_tests()`: dark/arcane 리셋 추가
  - `get_equipment_damage_multiplier()`: arcane 분기 추가 (dark는 기존 존재)
- `tests/test_game_state.gd`: 8개 테스트 추가
  - dark_void_bolt / arcane_force_pulse 스펠 DB 확인
  - dark/arcane resonance 초기값 0 확인
  - dark/arcane 스펠 사용 시 resonance +1 확인
  - 핫바에 spell_dark/spell_arcane 슬롯 존재 확인

**검증:** GUT 398/398 통과, headless --quit 통과

#### 장비 프리셋 확장 + LEGACY_SPELL_TO_SKILL 확장 (Cycle 2)

**완료 항목:**
- `scripts/autoload/game_state.gd`:
  - `LEGACY_SPELL_TO_SKILL` 확장: `earth_tremor` → `earth_terra_break`, `holy_radiant_burst` → `holy_healing_pulse` 추가
  - `EQUIPMENT_PRESETS` 확장: `earth_deploy` (earth 데미지 + deploy 빌드), `holy_guard` (holy 데미지 + 방어막 빌드) 추가
    - earth_deploy: legs=greaves_earthen_stride, acc1=ring_earth_seed, acc2=ring_verdant_coil
    - holy_guard: head=helm_holy_halo, body=armor_guardian_coat, acc2=ring_sanctum_loop
- `tests/test_equipment_system.gd`: 7개 테스트 추가
  - earth_deploy 프리셋 적용 + earth 데미지 증가 확인
  - holy_guard 프리셋 적용 + holy 데미지 증가 확인
  - holy_guard 배리어 파워 증가 확인
  - earth_deploy legs 슬롯 확인
  - earth_tremor → earth_terra_break 매핑 확인
  - holy_radiant_burst → holy_healing_pulse 매핑 확인

**검증:** GUT 404/404 통과

#### SCHOOL_TO_MASTERY 확장 + dark_void_bolt 연결 + void_rift 방 추가 (Cycle 3)

**완료 항목:**
- `scripts/autoload/game_state.gd`:
  - `SCHOOL_TO_MASTERY` 확장: `arcane` → `arcane_magic_mastery` 추가 (전체 10개 스쿨 중 9개 마스터리 매핑)
  - `LEGACY_SPELL_TO_SKILL` 확장: `dark_void_bolt` → `dark_abyss_gate` 추가
- `data/rooms.json`: `void_rift` 방 추가 (6번째 방)
  - width=1800, background="#080010" (void/dark 테마)
  - floor_segments 6개
  - spawns: eyeball + rat + sword + trash_monster + elite
  - objects: echo ×2 + rest + rope
  - entry_text: void 관련 분위기 텍스트
- `tests/test_game_state.gd`: 7개 테스트 추가
  - SCHOOL_TO_MASTERY에 arcane 매핑 확인
  - dark_void_bolt → dark_abyss_gate 매핑 확인
  - arcane 스펠 사용 시 arcane_magic_mastery 레벨 유지 확인
  - void_rift 방 존재 확인
  - void_rift 방 스폰 수 확인
  - 전체 방 수 6개 이상 확인

**검증:** GUT 410/410 통과

#### dark/arcane 전용 장비 4종 + dark_shadow 프리셋 추가 (Cycle 4)

**완료 항목:**
- `data/items/equipment.json`: 4개 신규 아이템 추가
  - `focus_void_lens` (offhand, rare): dark_damage ×1.22, projectile_speed ×1.08
  - `ring_abyss_signet` (accessory_1, rare): dark_damage ×1.18, buff_duration ×1.10
  - `focus_arcane_prism` (offhand, rare): arcane_damage ×1.20, magic_attack +4
  - `ring_arcane_coil` (accessory_2, uncommon): arcane_damage ×1.12, mp_regen +3
- `scripts/autoload/game_state.gd`:
  - `EQUIPMENT_PRESETS` 확장: `dark_shadow` 프리셋 추가 (focus_void_lens + ring_abyss_signet + ring_grave_whisper)
- `tests/test_equipment_system.gd`: 7개 테스트 추가
  - 4종 아이템 각각의 데미지 배율 증가 확인
  - dark_shadow 프리셋 적용 + dark 데미지 증가 확인
  - void_lens + abyss_signet 중첩 시 1.25× 초과 확인

**검증:** GUT 416/416 통과

#### arcane_pulse 프리셋 + spell_manager dark/arcane 캐스트 테스트 (Cycle 5)

**완료 항목:**
- `scripts/autoload/game_state.gd`:
  - `EQUIPMENT_PRESETS` 확장: `arcane_pulse` 프리셋 추가 (focus_arcane_prism + ring_arcane_coil)
- `tests/test_spell_manager.gd`: 4개 테스트 추가
  - dark_void_bolt 캐스트 → payload school = "dark" 확인
  - arcane_force_pulse 캐스트 → payload school = "arcane" 확인
  - arcane_pulse 프리셋 적용 + arcane 데미지 증가 확인
  - focus_void_lens 장착 시 dark_void_bolt 데미지 증가 확인

**검증:** GUT 420/420 통과, headless --quit/--quit-after 120 모두 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd에 dark/arcane 스펠 핫바 슬롯 표시 요청** (교차 의존, 친구 소유): spell_dark(L), spell_arcane(M) 슬롯이 추가되었으나 admin 메뉴에 반영 필요
2. **admin_menu.gd에 신규 프리셋 추가 요청** (교차 의존): earth_deploy, holy_guard, dark_shadow, arcane_pulse 프리셋 추가 필요
3. ~~spell_projectile.gd 시각 효과 개선~~ **완료** (2026-04-01 8차 세션)
4. ~~water/wind 스펠 spell_manager 캐스트 테스트 추가~~ → 진행 예정

### 2026-04-01 (8차 세션 - Cycle 1~5)

#### spell_projectile 스쿨별 shape 차별화 (Cycle 1)

**완료 항목:**
- `scripts/player/spell_projectile.gd`:
  - `_build_visual()` 리팩터: else 분기에서 `_build_school_polygon(school, radius)` 호출로 전환
  - `_build_school_polygon()` 신규 추가: school match로 8가지 shape 반환
    - dark: 역삼각 오각형 (넓고 위협적)
    - arcane: 마름모 (4각 다이아몬드)
    - water: 물방울 6각형 (전방 넓음, 후방 좁음)
    - wind: 긴 날카로운 수평 날 (5각)
    - earth: 두꺼운 사각형 (8각)
    - holy: 넓은 가로 광선 사각형
    - ice: 정육각형 (눈꽃 기반)
    - lightning: 지그재그 볼트 (7각)
    - default: 기존 삼각형 유지

**검증:** GUT 420/420 통과, headless --quit 통과

#### water/wind/earth/holy 스펠 캐스트 페이로드 테스트 추가 (Cycle 2)

**완료 항목:**
- `tests/test_spell_manager.gd`: 4개 테스트 추가
  - water_aqua_bullet 캐스트 → school="water", speed>0 확인
  - wind_gale_cutter 캐스트 → school="wind", pierce>0 확인
  - earth_tremor 캐스트 → school="earth", knockback>0 확인
  - holy_radiant_burst 캐스트 → school="holy", speed>0 확인

**검증:** GUT 424/424 통과

#### resonance 마일스톤 알림 시스템 (Cycle 3)

**완료 항목:**
- `scripts/autoload/game_state.gd`:
  - `RESONANCE_MILESTONES` 상수 추가: `{5: "...", 15: "...", 30: "..."}`
    - 5: "[School] resonance sharpens. The pattern is beginning to take hold."
    - 15: "Deep [School] resonance. Your spells carry a crystallized edge."
    - 30: "Peak [School] resonance. The maze reshapes around your casting pattern."
  - `register_spell_use()` 에 `_check_resonance_milestone()` 호출 추가
  - `_check_resonance_milestone(school, new_value)` 신규 추가: RESONANCE_MILESTONES.has(new_value) 시 push_message
- `tests/test_game_state.gd`: 4개 테스트 추가
  - resonance 5에서 메시지 발행 + school 이름 포함 확인
  - resonance 15에서 메시지 발행 + "Lightning" 포함 확인
  - resonance 30에서 메시지 발행 + "Ice" 포함 확인
  - resonance 3에서 메시지 없음 확인

**검증:** GUT 428/428 통과

#### 가중 드롭 선택 시스템 추가 (Cycle 4)

**완료 항목:**
- `scripts/autoload/game_database.gd`:
  - `DROP_RARITY_WEIGHT` 상수 추가: `{common:10, uncommon:6, rare:3, epic:1, legendary:1}`
  - `get_weighted_drop_for_profile(profile)` 신규 추가:
    - allowed 필터 기반 아이템 목록에서 rarity weight에 비례해 weighted_ids 배열 구성
    - `randi() % weighted_ids.size()`로 무작위 선택
  - `get_drop_for_profile()` 내부 선택 로직을 `get_weighted_drop_for_profile()` 호출로 전환
- `tests/test_equipment_system.gd`: 4개 테스트 추가
  - common 프로파일 가중 드롭 → common/uncommon 아이템 반환 확인
  - boss 프로파일 가중 드롭 → epic/legendary 아이템 반환 확인
  - 미지 프로파일 → 빈 문자열 반환 확인
  - DROP_RARITY_WEIGHT 상수 구조 + 가중치 순서(common>rare>epic) 확인

**검증:** GUT 432/432 통과

#### tooth_walker/trash_monster AI 수치 보강 (Cycle 5)

**완료 항목:**
- `data/enemies/enemies.json`:
  - tooth_walker: `stagger_threshold` 9999 → 60 (중간 저항)
  - trash_monster: `stagger_threshold` 9999 → 120, `super_armor_tags` [] → ["slam"] (슈퍼아머 활성화)
- `scripts/enemies/enemy_base.gd`:
  - tooth_walker fallback 스탯: `stagger_threshold = 60` 추가
  - trash_monster fallback 스탯: `stagger_threshold = 120`, `has_super_armor_attack = true` 추가
- `tests/test_enemy_base.gd`: 3개 테스트 추가
  - tooth_walker stagger_threshold < 9999 확인 (유한값)
  - trash_monster has_super_armor_attack = true + stagger_threshold < 9999 확인
  - trash_monster stagger_threshold > tooth_walker stagger_threshold 확인 (탱크 역할)

**검증:** GUT 435/435 통과, headless --quit 통과

### 2026-04-01 (9차 세션 - Cycle 1)

#### tooth_walker 공격 둔화 + player utility_effects 처리 (Cycle 1)

**완료 항목:**
- `scripts/player/player.gd`:
  - 변수 추가: `player_slow_timer := 0.0`, `player_slow_multiplier := 1.0`
  - `receive_hit()` 파라미터 `_school`/`_utility_effects` (무시) → `school`/`utility_effects` (처리)로 변경
  - `_apply_player_utility_effects(effects)` 신규 추가:
    - "slow" 타입 처리: `player_slow_multiplier = min(player_slow_multiplier, 1.0 - slow_value)`
    - `player_slow_timer = max(player_slow_timer, duration)` (중첩 시 더 긴 쪽 유지)
  - `_tick_timers()`: `player_slow_timer` 틱 + 만료 시 `player_slow_multiplier = 1.0` 복원 추가
  - `_physics_process()` move_speed: `* player_slow_multiplier` 추가
  - `reset_at()`: `player_slow_timer = 0.0`, `player_slow_multiplier = 1.0` 추가
- `scripts/enemies/enemy_base.gd`:
  - `_on_attack_state_entered()` tooth_walker 분기: receive_hit에 `[{"type":"slow","value":0.3,"duration":1.5}]` 전달
- `tests/test_player_controller.gd`: 4개 테스트 추가
  - receive_hit slow 효과 → slow_timer/slow_multiplier 설정 확인
  - slow_timer 만료 → slow_multiplier 1.0 복원 확인
  - utility_effects 없는 히트 → slow 미발동 확인
  - reset_at → slow 상태 초기화 확인

**검증:** GUT 439/439 통과, headless --quit 통과

#### Cycle 2 — resonance 30 → 임시 school 데미지 10% 버프

**완료 항목:**
- `scripts/autoload/game_state.gd`:
  - 변수 추가: `resonance_bonus_school := ""`, `resonance_bonus_timer := 0.0`
  - `_process()`: `resonance_bonus_timer` 틱 + 만료 시 `resonance_bonus_school = ""` 초기화
  - `_check_resonance_milestone()`: new_value == 30일 때 `resonance_bonus_school = school`, `resonance_bonus_timer = 15.0` 설정
  - `get_equipment_damage_multiplier()`: `resonance_bonus_timer > 0 and resonance_bonus_school == school` 시 `total *= 1.10` 적용
  - `reset_progress_for_tests()`: 두 변수 초기화 추가
- `tests/test_game_state.gd`: 4개 테스트 추가
  - resonance 30 도달 시 bonus_school/timer 설정 확인
  - lightning resonance 30 → get_equipment_damage_multiplier("lightning") * 1.10 확인
  - 다른 school (ice)에는 fire resonance 보너스 미적용 확인
  - reset_progress_for_tests() 후 bonus 상태 초기화 확인

**검증:** GUT 443/443 통과

#### Cycle 3 — rat 2연타 콤보 패턴

**완료 항목:**
- `scripts/enemies/enemy_base.gd`:
  - 변수 추가: `rat_combo_timer := 0.0`
  - `_physics_process()`: `rat_combo_timer` 틱, 만료 시 72px 이내라면 2타 `receive_hit(contact_damage, ..., 140.0)` 발동
  - `_on_attack_state_entered()` rat 분기: 56px 이내 1타 후 `rat_combo_timer = 0.18` 설정
- `tests/test_enemy_base.gd`: 3개 테스트 추가
  - rat_combo_timer 초기값 0 확인
  - rat 공격 후 combo_timer > 0 확인
  - rat attack_period < brute attack_period 확인

**검증:** GUT 446/446 통과

#### Cycle 4 — sword 공격 후 후퇴 패턴

**완료 항목:**
- `scripts/enemies/enemy_base.gd`:
  - 변수 추가: `sword_retreat_timer := 0.0`
  - `_physics_process()`: `sword_retreat_timer` 틱 추가
  - `_on_attack_state_entered()` sword 분기: `sword_retreat_timer = 0.45` 설정 추가
  - `_run_ai()` sword pursue 분기: `sword_retreat_timer > 0` 시 반대 방향으로 move_speed * 0.7 속도 후퇴
- `tests/test_enemy_base.gd`: 3개 테스트 추가
  - sword_retreat_timer 초기값 0 확인
  - sword 공격 후 retreat_timer > 0 확인
  - sword move_speed > brute move_speed 확인

**검증:** GUT 449/449 통과

#### Cycle 5 — eyeball 투사체 school=dark + stagger_threshold 설정

**완료 항목:**
- `scripts/enemies/enemy_base.gd`:
  - `_fire_eyeball_shot()`: `"school": "void"` → `"school": "dark"` 변경
  - `_apply_stats_from_data()` fallback eyeball: `stagger_threshold = 40` 추가
- `data/enemies/enemies.json`: eyeball `stagger_threshold` 9999 → 40
- `tests/test_enemy_base.gd`: 3개 테스트 추가
  - eyeball 투사체 school = "dark" 확인
  - eyeball stagger_threshold < 9999 확인
  - eyeball projectile_color != "" 확인

**검증:** GUT 452/452 통과, headless --quit 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **volt_spear / frost_nova 이펙트 에셋**: fire_bolt 패턴 재사용 — 에셋 추가 시 즉시 적용 가능
3. **bomber 폭탄 시각/피격감 후속 보강 검토**: 필요 시 이펙트나 경고 보강
4. **새 owner_core 소유 전투 증분 재선정**: 교차 의존/에셋 상태를 보고 가장 작은 안전 구현으로 이어가기

### 2026-04-01 (10차 세션 - Cycle 1)

#### bomber 곡선 감속 투사체 구현 (Cycle 1)

**완료 항목:**
- `scripts/enemies/enemy_base.gd`:
  - `_fire_bomb()` payload에 `horizontal_drag_per_second: 24.0`, `min_horizontal_speed: 34.0`, `gravity_per_second: 180.0` 추가
  - bomber 폭탄이 직선탄이 아니라 아래로 처지며 수평 속도가 죽는 억제형 궤적을 갖도록 조정
- `scripts/player/spell_projectile.gd`:
  - 런타임 선택 필드 `horizontal_drag_per_second`, `min_horizontal_speed`, `gravity_per_second` 추가
  - `_apply_runtime_motion()` 신규 추가: 투사체별 중력 곡선 + 수평 감속 처리
  - 기존 플레이어/적 투사체는 필드를 주지 않으면 기존 직선 이동 유지
- `tests/test_enemy_base.gd`:
  - bomber payload에 곡선/감속 필드가 포함되는지 검증 1개 추가
  - `spell_projectile` 실제 운동이 아래로 휘고 수평 속도가 줄어드는지 검증 1개 추가

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 453/453 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **bomber 후속 보강 여부 점검**: curve 수치가 충분한지, 경고 마커가 필요한지 플레이 체감 기준으로 재평가
3. **새 owner_core 소유 전투 증분 재선정**: 적/스킬/월드 중 가장 작은 안전 구현으로 이어가기

### 2026-04-01 (11차 세션 - Cycle 1~2)

#### volt_spear 이펙트 에셋 적용 (Cycle 1)

**완료 항목:**
- 분석 대상:
  - `asset_sample/Effect/Fx_pack/1/1_0.png` ~ `1_60.png` (100×100, 61프레임)
  - 대표 프레임 bbox: `(23,41)-(66,62)` 근방의 우향 번개형 실루엣 확인
- 에셋 복사:
  - `asset_sample/Effect/Fx_pack/1/1_{0,4,8,...,56}.png` → `assets/effects/volt_spear/volt_spear_0~14.png`
- `scripts/player/spell_projectile.gd`:
  - `_build_visual()`에 `volt_spear` AnimatedSprite2D 분기 추가
  - `_build_sampled_effect_visual()` 공용 helper 추가
  - `volt_spear`는 15프레임, 26fps, scale 0.46, 좌향 이동 시 자동 반전
- `tests/test_spell_manager.gd`:
  - `volt_spear` 투사체가 AnimatedSprite2D 이펙트 자식을 만들고 15프레임을 로드하는지 검증 1개 추가
- import:
  - `godot --editor --headless --path . --quit`로 reimport 수행
  - `.godot/imported/volt_spear_*.ctex/.md5` 생성 확인

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 454/454 통과

#### frost_nova 이펙트 에셋 적용 (Cycle 2)

**완료 항목:**
- 분석 대상:
  - `asset_sample/Effect/Fx_pack/2/1_0.png` ~ `1_60.png` (100×100, 61프레임)
  - 대표 프레임 bbox: `(21,38)-(70,74)` 근방의 중앙 burst 실루엣 확인
- 에셋 복사:
  - `asset_sample/Effect/Fx_pack/2/1_{0,8,16,...,56}.png` → `assets/effects/frost_nova/frost_nova_0~7.png`
- `scripts/player/spell_projectile.gd`:
  - `_build_visual()`에 `frost_nova` AnimatedSprite2D 분기 추가
  - `frost_nova`는 8프레임, 40fps, scale 0.82, `Color("#8cecff")` 모듈레이션, 방향 반전 없음
- `tests/test_spell_manager.gd`:
  - `frost_nova` 투사체가 AnimatedSprite2D burst를 만들고 8프레임을 로드하는지 검증 1개 추가
- import:
  - `godot --editor --headless --path . --quit`로 reimport 수행
  - `.godot/imported/frost_nova_*.ctex/.md5` 생성 확인

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 455/455 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **bomber 후속 보강 여부 점검**: curve 수치가 충분한지, 경고 마커나 폭발 이펙트가 필요한지 재평가
3. **새 owner_core 소유 전투 증분 재선정**: 적/스킬/월드 중 가장 작은 안전 구현으로 이어가기

### 2026-04-01 (12차 세션 - Cycle 1)

#### bomber 타깃 고정 warning marker 구현 (Cycle 1)

**완료 항목:**
- `scripts/enemies/enemy_base.gd`:
  - `_emit_bomber_warning_marker()` 추가
  - bomber 공격 상태 진입 시 플레이어 현재 발밑 조준점(`target.global_position + Vector2(0, 12)`)에 `team:"marker"`, `damage:0`, `duration:0.55s`, `color:"#e3a83a"` 마커 emit 후 `_fire_bomb()` 호출
  - 기존 bomb payload의 곡선/감속 수치는 유지
- `tests/test_enemy_base.gd`:
  - bomber 공격 상태에서 marker → bomb 순서로 payload 2개가 나가는지 검증 1개 추가
  - marker가 플레이어의 현재 조준 위치에 고정되고, 무해한 짧은 텔레그래프인지 검증
- `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`:
  - bomber warning marker 완료 상태를 구현 문서에 동기화

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 456/456 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **bomber 폭발 이펙트 필요 여부 재평가**: warning marker까지 추가된 상태에서 시각/피격감이 충분한지 점검
3. **새 owner_core 소유 전투 증분 재선정**: 적/스킬/월드 중 가장 작은 안전 구현으로 이어가기

### 2026-04-01 (13차 세션 - Cycle 1)

#### bomber 터미널 burst 이펙트 구현 (Cycle 1)

**완료 항목:**
- 분석 대상:
  - `asset_sample/Effect/Everything/Alternative 3/1/Alternative_3_01.png` ~ `Alternative_3_06.png`
  - 주황 링형 6프레임이라 bomber 착탄 burst에 가장 읽기 쉬운 세트로 선택
- 에셋 복사:
  - `asset_sample/Effect/Everything/Alternative 3/1/Alternative_3_01~06.png` → `assets/effects/bomber_burst/bomber_burst_0~5.png`
- import:
  - `godot --editor --headless --path . --quit`로 reimport 수행
- `scripts/enemies/enemy_base.gd`:
  - `_fire_bomb()` payload에 `spell_id:"enemy_bomber_bomb"`, `terminal_effect_id:"bomber_burst"` 추가
- `scripts/player/spell_projectile.gd`:
  - 선택형 `terminal_effect_id` 지원 추가
  - 충돌/수명 종료 시 `bomber_burst` one-shot AnimatedSprite2D를 재생하고 난 뒤 queue_free
- `tests/test_enemy_base.gd`:
  - bomber payload가 terminal effect를 요청하는지 검증 1개 추가
  - projectile 종료 시 6프레임 one-shot burst로 전환되는지 검증 1개 추가
- `docs/implementation/increments/combat_increment_04_enemy_combat_set.md` / `docs/implementation/plans/combat_first_build_plan.md`:
  - bomber burst 완료 상태를 구현 문서에 동기화

**검증:**
- `godot --editor --headless --path . --quit`: 수행
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 457/457 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **새 owner_core 소유 전투 증분 재선정**: bomber 보강은 warning + burst까지 닫혔으므로, 적/스킬/월드 중 가장 작은 다음 구현 찾기
3. **신규 몬스터 에셋 적용 재진입 여부 점검**: Rat 우선 적용이 지금 시점에서 가장 작은 안전 증분인지 재평가

### 2026-04-01 (14차 세션 - Cycle 1)

#### Rat runtime asset 회귀 검증용 sprite builder 정리 (Cycle 1)

**완료 항목:**
- 분석 대상:
  - `asset_sample/Monster/Rat/NoneOutlinedRat/rat-idle.png`
  - analyzer 결과: 192×32 strip, 32×32 프레임, 6프레임, 우향 기준
  - `rat-run/attack/hurt/death`도 함께 bbox 확인
- `scripts/enemies/enemy_base.gd`:
  - strip/grid/vertical 스프라이트 로딩 로직을 `_build_strip_sprite_frames()`, `_build_grid_sprite_frames()`, `_build_vertical_sprite_frames()` 헬퍼로 분리
  - `_setup_sprite()`는 기존 동작을 유지하면서 공용 builder를 재사용하도록 정리
- `tests/test_enemy_base.gd`:
  - rat가 실제 `res://assets/monsters/rat/` runtime asset bundle을 읽어 idle/run/attack/hurt/death 프레임을 구성하는지 검증 1개 추가
  - idle loop / attack one-shot 설정까지 함께 검증
- `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`:
  - Rat 섹션에 현재 런타임 적용 및 GUT 회귀 검증 상태 메모 추가

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 458/458 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **신규 몬스터 에셋 적용 재진입 여부 점검**: tooth_walker 또는 eyeball이 Rat 다음 최소 안전 증분인지 재평가
3. **새 owner_core 소유 전투 증분 재선정**: 적/스킬/월드 중 가장 작은 다음 구현 찾기

### 2026-04-01 (15차 세션 - Cycle 1)

#### tooth_walker runtime sheet blank tail trim + 회귀 검증 (Cycle 1)

**완료 항목:**
- 분석 대상:
  - `asset_sample/Monster/tooth walker/tooth walker sprite-Sheet.png`
  - `assets/monsters/tooth_walker/tooth-walker-sheet.png`
  - 시트 크기 384×320, 64×64 기준 6열×5행 확인
  - row 4(death)는 6칸 중 앞 2칸만 실제 픽셀이 있고 뒤 4칸은 비어 있음
- `scripts/enemies/enemy_base.gd`:
  - `TOOTH_WALKER_ANIM_ROWS.death`에 `trim_empty_tail: true` 추가
  - `_build_grid_sprite_frames()`가 선택적으로 빈 꼬리 프레임을 제거하도록 보강
  - `_count_nonempty_grid_frames()` 헬퍼 추가로 grid sheet의 실제 사용 프레임 수를 계산
- `tests/test_enemy_base.gd`:
  - tooth walker runtime sheet가 실제 `res://assets/monsters/tooth_walker/`를 읽는지 검증 1개 추가
  - idle/run/attack/hurt는 6프레임 유지, death는 빈 tail을 제거한 2프레임으로 고정되는지 검증
- `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`:
  - tooth walker 섹션에 런타임 sheet 적용과 death trim 상태 메모 추가

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 459/459 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **신규 몬스터 에셋 적용 재진입 여부 점검**: eyeball이 tooth_walker 다음 최소 안전 증분인지 재평가
3. **새 owner_core 소유 전투 증분 재선정**: 적/스킬/월드 중 가장 작은 다음 구현 찾기

#### eyeball vertical runtime sheet 회귀 검증 추가 (Cycle 2)

**완료 항목:**
- 분석 대상:
  - `assets/monsters/eyeball/eyeball-sheet.png`
  - 시트 크기 128×2400, 128×48 기준 총 50프레임 확인
  - `idle/run/attack/hurt/death` 구간(10/10/15/10/5)에 빈 프레임 없음 확인
- `tests/test_enemy_base.gd`:
  - eyeball runtime sheet가 실제 `res://assets/monsters/eyeball/`를 읽는지 검증 1개 추가
  - vertical builder가 `idle/run/attack/hurt/death`를 10/10/15/10/5 프레임으로 구성하는지 검증
  - idle loop / attack one-shot 설정까지 함께 검증
- `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`:
  - eyeball 섹션에 vertical runtime sheet 적용 및 GUT 회귀 검증 상태 메모 추가

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 460/460 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **신규 몬스터 에셋 적용 재진입 여부 점검**: trash_monster 또는 sword가 eyeball 다음 최소 안전 증분인지 재평가
3. **새 owner_core 소유 전투 증분 재선정**: 적/스킬/월드 중 가장 작은 다음 구현 찾기

#### sword runtime sheet blank tail trim + 회귀 검증 (Cycle 3)

**완료 항목:**
- 분석 대상:
  - `assets/monsters/sword/sword-sheet.png`
  - 시트 크기 1792×512, 128×64 기준 14열×8행 확인
  - idle/run/attack/death 행에서 trailing blank cell 다수 확인
    - idle 7프레임 사용 + 7칸 blank
    - run 4프레임 사용 + 10칸 blank
    - attack 8프레임 사용 + 6칸 blank
    - death 2프레임 사용 + 12칸 blank
- `scripts/enemies/enemy_base.gd`:
  - `SWORD_ANIM_ROWS`의 idle/run/attack/death에 `trim_empty_tail: true` 추가
  - 기존 grid trim helper를 재사용해 sword 런타임 애니메이션 길이를 실제 사용 프레임 수로 보정
- `tests/test_enemy_base.gd`:
  - sword runtime sheet가 실제 `res://assets/monsters/sword/`를 읽는지 검증 1개 추가
  - frame count가 `7/4/8/14/2`로 보정되는지 검증
  - idle loop / death one-shot 설정을 함께 검증
- `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`:
  - Sword 섹션에 runtime sheet 적용 및 blank tail trim 상태 메모 추가

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 461/461 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **신규 몬스터 에셋 적용 재진입 여부 점검**: trash_monster가 sword 다음 최소 안전 증분인지 재평가
3. **새 owner_core 소유 전투 증분 재선정**: 적/스킬/월드 중 가장 작은 다음 구현 찾기

#### trash_monster grid runtime sheet 회귀 검증 추가 (Cycle 4)

**완료 항목:**
- 분석 대상:
  - `assets/monsters/trash_monster/trash-monster-sheet.png`
  - 시트 크기 384×384, 64×64 기준 6열×6행 확인
  - idle/run/attack/hurt/death 구간 모두 6프레임이 실제 픽셀로 채워져 있음
- `tests/test_enemy_base.gd`:
  - trash monster runtime sheet가 실제 `res://assets/monsters/trash_monster/`를 읽는지 검증 1개 추가
  - grid builder가 `idle/run/attack/hurt/death`를 6/6/6/6/6 프레임으로 구성하는지 검증
  - idle loop / attack one-shot 설정까지 함께 검증
- `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`:
  - Trash Monster 섹션에 runtime sheet 적용 및 GUT 회귀 검증 상태 메모 추가

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 462/462 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **새 owner_core 소유 전투 증분 재선정**: 신규 몬스터 runtime 회귀는 거의 닫혔으므로, 전투/월드 쪽 가장 작은 다음 구현 찾기
3. **잔여 에셋 회귀 정리 여부 검토**: sword 이후에도 추가 trim 또는 신규 연출 보강이 필요한지 재평가

### 2026-04-01 (16차 세션 - Cycle 1)

#### 저장 지점 복귀 seam 추가 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 신규 몬스터 runtime 에셋 회귀는 거의 닫혔고, 다음 최소 owner_core 증분은 전투 샌드박스의 사망 후 복귀 seam 정리였음
  - `GameState.restore_after_death()`는 이미 있었지만 플레이어 쪽에서 바로 쓸 수 있는 runtime helper와 회귀 테스트가 없었음
- `scripts/player/player.gd`:
  - `respawn_from_saved_route()` 추가
  - `GameState.restore_after_death()` 결과를 읽어 `reset_at()`으로 복귀시키고 `room_id/spawn_position` 딕셔너리를 반환하도록 정리
  - `reset_at()`에서 `invuln_timer`, `current_rope`, `current_interactable`, `_cam_shake_timer`, `_cam_shake_intensity`도 함께 초기화하도록 보강
- `scripts/autoload/game_state.gd`:
  - `reset_progress_for_tests()`가 `current_room_id`, `save_room_id`, `save_spawn_position`, `seen_room_texts`, `seen_echoes`, `ui_message` 등 저장/진행 상태를 함께 초기화하도록 보강
- `tests/test_player_controller.gd`:
  - 저장 지점 복귀 시 위치/Dead 상태/슬로우/무적/카메라 흔들림이 초기화되는지 검증 1개 추가
- `tests/test_game_state.gd`:
  - `restore_after_death()`가 저장된 room/spawn과 풀 체력을 복구하는지 검증 1개 추가
- `docs/implementation/increments/combat_increment_01_player_controller.md`:
  - 플레이어 컨트롤러 문서에 저장 지점 복귀 seam과 현재 구현 메모 추가

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 464/464 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **새 owner_core 소유 전투/월드 증분 재선정**: 저장 지점 seam이 생겼으므로 room reload 또는 sandbox restart와 이어질 가장 작은 다음 구현 찾기
3. **잔여 에셋 회귀 정리 여부 검토**: 추가 trim/연출 보강이 정말 필요한지 재평가

### 2026-04-01 (17차 세션 - Cycle 1)

#### 사망 복귀 시 transient combat runtime 정리 보강 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `player.respawn_from_saved_route()` seam은 이미 있었지만, `GameState.restore_after_death()`가 체력만 복구하고 사망 직전 버프/페널티/후유증을 끌고 올 수 있었음
  - `main.gd` room reload 자체는 이미 연결되어 있으므로, 이번 owner_core 증분은 GameState 내부 전투 상태를 저장 지점 기준으로 다시 고정하는 쪽이 가장 작고 안전했음
- `scripts/autoload/game_state.gd`:
  - `_reset_transient_combat_runtime(clear_effects, clear_hit_feedback)` 헬퍼 추가
  - `heal_full()`은 기존과 같은 코어 상태 초기화를 위 헬퍼로 정리
  - `restore_after_death()`는 HP/MP 복구와 함께 active buff/penalty, buff cooldown, combo barrier, Time Collapse, Soul Dominion aftershock, 마지막 피격 표시까지 비우도록 보강
- `tests/test_game_state.gd`:
  - `restore_after_death()`가 mana, active_buffs, active_penalties, buff_cooldowns, barrier, aftershock, last-hit feedback까지 정리하는지 검증 1개 추가
- `tests/test_player_controller.gd`:
  - `respawn_from_saved_route()` 경로에서 GameState mana와 buff/penalty 정리가 실제로 따라오는지 기존 respawn 테스트 확장
- `docs/implementation/increments/combat_increment_01_player_controller.md`:
  - 저장 지점 복귀 seam 문구를 현재 구현 상태에 맞게 동기화

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 465/465 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **새 owner_core 소유 전투/월드 증분 재선정**: respawn seam과 transient cleanup이 닫혔으므로, room reload 이후 가장 작은 전투/월드 증분 재선정
3. **잔여 에셋 회귀 정리 여부 검토**: 추가 trim/연출 보강이 정말 필요한지 재평가

### 2026-04-01 (18차 세션 - Cycle 1)

#### 로프 centerline snap + bounds clamp 보강 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - respawn seam은 닫혔고, 다음 최소 owner_core 증분으로 플레이어/월드 경계 안에서 끝나는 로프 런타임 보강을 선택
  - `OnRope` 상태는 이미 있었지만 rope grab 직후 플레이어가 rope 중심선 밖에서 매달릴 수 있고, rope physics 회귀도 충분히 고정돼 있지 않았음
- `scripts/player/player.gd`:
  - `_snap_to_rope_anchor()` 추가
  - `_try_grab_rope()`가 rope grab 직후 player x를 rope centerline에 맞추고 y를 rope top/bottom 범위로 clamp하도록 보강
  - `_handle_rope_physics()`도 매 프레임 같은 정렬을 재사용해 rope 위아래 경계와 중심선을 유지
  - 기존 mock rope 테스트와 실제 rope 노드를 둘 다 지원하도록 `meta`/property 기반 bound lookup 헬퍼 추가
- `tests/test_player_controller.gd`:
  - `before_each()`에 `GameState.ensure_input_map()` 추가
  - 실제 `scripts/world/rope.gd`를 사용하는 rope grab snap 회귀 1개 추가
  - rope physics가 centerline과 bottom clamp를 유지하는지 검증 1개 추가
- `docs/implementation/increments/combat_increment_01_player_controller.md`:
  - 로프 중심선 스냅과 bounds clamp, 실제 rope GUT 회귀 상태를 현재 구현 메모에 반영

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 467/467 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **새 owner_core 소유 전투/월드 증분 재선정**: 플레이어/월드 seam 쪽에서 rest point 또는 room shift 경계처럼 같은 밀도의 최소 증분이 있는지 재평가
3. **잔여 에셋 회귀 정리 여부 검토**: 추가 trim/연출 보강이 정말 필요한지 재평가

### 2026-04-01 (19차 세션 - Cycle 1)

#### rest point 저장 지점 world anchor 보강 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 로프 런타임 보강까지 닫힌 뒤, 같은 밀도의 다음 owner_core 증분으로 rest point 저장 지점 정확도를 선택
  - 기존 `scripts/world/rest_point.gd`는 `position + (0, -60)`을 저장해서 부모 transform이 있는 object layer 또는 translated parent 아래에서는 잘못된 spawn anchor가 기록될 수 있었음
- `scripts/world/rest_point.gd`:
  - `interact()`가 저장 지점을 `global_position + Vector2(0, -60)` 기준으로 기록하도록 수정
  - entrance에서 `rest_entrance` progression event를 주는 기존 흐름은 유지
- `tests/test_player_controller.gd`:
  - translated parent 아래 rest point가 local이 아니라 global spawn anchor를 저장하는지 검증 1개 추가
  - entrance rest point interaction이 `rest_entrance` progression event를 남기는지 검증 1개 추가
  - orphan 경고를 막기 위해 dummy player fixture를 autofree로 정리
- `docs/implementation/increments/combat_increment_01_player_controller.md`:
  - 저장 지점 seam 문구에 world anchor 기준 저장과 rest point 회귀 상태를 반영

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 469/469 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **새 owner_core 소유 전투/월드 증분 재선정**: rest point까지 닫혔으므로, room shift 경계나 다른 플레이어/월드 seam 중 같은 밀도의 최소 증분 재평가
3. **잔여 에셋 회귀 정리 여부 검토**: 추가 trim/연출 보강이 정말 필요한지 재평가

### 2026-04-01 (20차 세션 - Cycle 1)

#### room shift 경계 재발화 debounce 보강 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - rest point 저장 지점 world anchor까지 닫힌 뒤, 같은 밀도의 다음 owner_core 증분으로 player/world seam 안에서 끝나는 room shift 경계 재발화 방지를 선택
  - 기존 `scripts/player/player.gd`는 플레이어가 좌우 edge 밖에 머무는 동안 `_check_room_edges()`가 프레임마다 `request_room_shift`를 반복 emit할 수 있었고, 실제 room transition guard는 `main.gd`에만 있어 seam 자체가 과하게 시끄러웠음
- `scripts/player/player.gd`:
  - `_room_shift_edge_lock` 필드 추가
  - `_check_room_edges()`가 좌/우 경계 방향을 계산해, 같은 edge 체류 중에는 `request_room_shift`를 한 번만 emit하고 safe zone 재진입 시 lock을 해제하도록 보강
  - `reset_at()`도 room shift edge lock을 함께 초기화해 사망 복귀나 저장 지점 복귀 직후 다음 경계 진입을 정상적으로 다시 받을 수 있게 정리
- `tests/test_player_controller.gd`:
  - 같은 우측 edge에 연속 체류할 때 emit이 1회만 발생하고, safe zone으로 돌아온 뒤에는 다시 emit되는지 검증 1개 추가
  - 좌측 edge lock이 `reset_at()`에서 풀려 다음 경계 진입이 다시 emit되는지 검증 1개 추가
- `docs/implementation/increments/combat_increment_01_player_controller.md`:
  - room shift debounce와 GUT 회귀 상태를 현재 구현 메모에 반영

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 471/471 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **새 owner_core 소유 전투/월드 증분 재선정**: room shift debounce까지 닫혔으므로, rest point/rope/respawn과 같은 밀도의 다음 플레이어/월드 seam을 다시 선별
3. **잔여 에셋 회귀 정리 여부 검토**: 추가 trim/연출 보강이 정말 필요한지 재평가

### 2026-04-01 (21차 세션 - Cycle 1)

#### stale interactable 참조 정리 보강 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - room shift debounce까지 닫힌 뒤, 같은 밀도의 다음 owner_core 증분으로 player/world interactable seam 안정화를 선택
  - 기존 `scripts/player/player.gd`는 `current_interactable`가 world object 해제 뒤에도 남아 있으면 입력 순간 stale reference를 바로 정리하는 경로가 없어, interactable lifecycle이 body exit보다 먼저 끝나는 케이스에 취약했음
- `scripts/player/player.gd`:
  - `_try_interact()` 헬퍼 추가
  - `_physics_process()`의 interact 입력이 위 헬퍼를 통해서만 실행되도록 정리
  - `_get_valid_interactable()` 추가: free된 interactable이 남아 있으면 `current_interactable`를 자동으로 null로 비우고 입력을 안전하게 무시
- `tests/test_player_controller.gd`:
  - 등록된 interactable이 실제로 1회 호출되는지 검증 1개 추가
  - free된 interactable reference가 `_try_interact()`에서 안전하게 정리되고 crash 없이 false를 반환하는지 검증 1개 추가
- `docs/implementation/increments/combat_increment_01_player_controller.md`:
  - stale interactable 정리와 GUT 회귀 상태를 현재 구현 메모에 반영

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 473/473 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **새 owner_core 소유 전투/월드 증분 재선정**: interactable seam까지 닫혔으므로, 같은 밀도의 다음 플레이어/월드 안정화 포인트 재선별
3. **잔여 에셋 회귀 정리 여부 검토**: 추가 trim/연출 보강이 정말 필요한지 재평가

### 2026-04-01 (22차 세션 - Cycle 1)

#### 겹친 interactable 포커스 fallback 보강 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - stale interactable 정리까지 닫힌 뒤, 같은 밀도의 다음 owner_core 증분으로 겹친 player/world interactable 포커스 seam을 선택
  - 기존 `scripts/player/player.gd`는 최신 interactable이 unregister되거나 free된 뒤에도 이전 interactable로 자동 복귀하지 않아, 겹친 상호작용 구간에서 포커스가 끊길 수 있었음
- `scripts/player/player.gd`:
  - `nearby_interactables` 목록 추가
  - `register_interactable()`가 최근 진입 대상을 포커스로 올리면서 목록을 유지하도록 보강
  - `unregister_interactable()`가 단순 null 처리 대신 남은 유효 interactable로 fallback하도록 정리
  - `_get_valid_interactable()`가 stale reference를 prune한 뒤 남은 최근 유효 interactable로 다시 포커스를 맞추도록 보강
  - `reset_at()`에서 interactable 목록도 함께 비우도록 정리
- `tests/test_player_controller.gd`:
  - 최신 interactable이 unregister되면 직전 대상에게 포커스가 되돌아가는지 검증 1개 추가
  - 최신 interactable이 free되어도 이전 유효 대상에게 상호작용이 복구되는지 검증 1개 추가
- `docs/implementation/increments/combat_increment_01_player_controller.md`:
  - 겹친 interactable fallback과 GUT 회귀 상태를 현재 구현 메모에 반영

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 475/475 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **새 owner_core 소유 전투/월드 증분 재선정**: interactable fallback까지 닫혔으므로, 같은 밀도의 다음 플레이어/월드 seam을 다시 선별
3. **잔여 에셋 회귀 정리 여부 검토**: 추가 trim/연출 보강이 정말 필요한지 재평가

### 2026-04-01 (23차 세션 - Cycle 1)

#### rope grab 대상 fallback 보강 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 겹친 interactable 포커스 fallback까지 닫힌 뒤, 같은 밀도의 다음 owner_core 증분으로 rope seam 안정화를 선택
  - 기존 `scripts/player/player.gd`는 `current_rope`가 최신 rope 하나만 가리켜서, 겹친 rope area에서 최근 rope가 unregister되거나 free되면 이전 유효 rope로 자동 복귀하지 못했고 stale rope 참조로 grab 대상이 끊길 수 있었음
- `scripts/player/player.gd`:
  - `nearby_ropes` 목록 추가
  - `register_rope()`가 최근 진입 rope를 우선 대상으로 올리면서 목록을 유지하도록 보강
  - `unregister_rope()`가 단순 null 처리 대신 남은 유효 rope로 fallback하도록 정리
  - `_get_valid_rope()`, `_refresh_current_rope()`, `_prune_invalid_ropes()` 추가
  - `_try_grab_rope()`와 `_handle_rope_physics()`가 stale rope를 정리한 뒤 현재 유효 rope만 사용하도록 보강
  - `reset_at()`에서 rope 목록도 함께 비우도록 정리
- `tests/test_player_controller.gd`:
  - 최신 rope가 unregister되면 이전 rope로 fallback되는지 검증 1개 추가
  - 최신 rope가 free되어도 이전 유효 rope로 grab 대상이 복구되는지 검증 1개 추가
- `docs/implementation/increments/combat_increment_01_player_controller.md`:
  - rope fallback과 GUT 회귀 상태를 현재 구현 메모에 반영

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 477/477 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **새 owner_core 소유 전투/월드 증분 재선정**: rope fallback까지 닫혔으므로, 같은 밀도의 다음 플레이어/월드 seam을 다시 선별
3. **잔여 에셋 회귀 정리 여부 검토**: 추가 trim/연출 보강이 정말 필요한지 재평가

### 2026-04-01 (24차 세션 - Cycle 1)

#### rope physics mock/runtime bound 경로 통일 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - rope grab 대상 fallback까지 닫힌 뒤, 같은 밀도의 다음 owner_core 증분으로 rope physics helper 경로의 잔여 불일치를 선택
  - `scripts/player/player.gd`는 rope grab 단계에서는 `_get_rope_bound()`를 통해 meta/property fallback을 지원했지만, `_handle_rope_physics()` 안에서는 아직 `current_rope.rope_top_y` / `rope_bottom_y`를 직접 읽어 headless mock rope가 실제 rope와 다른 분기를 탈 수 있었음
- `scripts/player/player.gd`:
  - `_handle_rope_physics()`의 rope bounds clamp가 `_get_rope_bound("rope_top_y")` / `_get_rope_bound("rope_bottom_y")`를 재사용하도록 정리
  - 결과적으로 rope grab, rope snap, rope physics가 모두 동일한 meta/property helper를 사용하게 되어 mock rope와 실제 rope의 bound lookup 경로가 통일됨
- `tests/test_player_controller.gd`:
  - meta만 가진 mock rope를 붙인 상태에서 `_handle_rope_physics()`가 bottom clamp를 정상 적용하는지 검증 1개 추가
- `docs/implementation/increments/combat_increment_01_player_controller.md`:
  - rope physics가 mock rope와 실제 rope를 같은 bound helper로 처리한다는 현재 구현 메모 반영

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`: 478/478 통과

#### 다음 우선 작업 (다음 세션)

1. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가
2. **새 owner_core 소유 전투/월드 증분 재선정**: rope mock/runtime bound 경로까지 닫혔으므로, 같은 밀도의 다음 플레이어/월드 seam을 다시 선별
3. **잔여 에셋 회귀 정리 여부 검토**: 추가 trim/연출 보강이 정말 필요한지 재평가

### 2026-04-01 (25차 세션 - Cycle 1)

#### Free effect 기반 스킬별 attack/hit 이펙트 기획 문서화 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 최근 세션들은 플레이어/월드 seam 안정화가 중심이었고, 이번 요청은 스킬 연출 기획을 문서에 먼저 고정하는 방향
  - 수정 허용 범위상 `docs/implementation/**`와 `owner_core_workstream.md`만 갱신 가능하므로, 이번 세션에서는 구현 기준 문서와 개발 계획 문서 안에서 `attack effect` / `hit effect` 분리 계획을 고정
- `asset_sample/Effect/Free` 분석:
  - `Free Preview All.gif`와 `Part 1` ~ `Part 15`의 preview GIF를 직접 확인
  - 각 Part의 12개 PNG가 4프레임 × 3세트 구조임을 확인하고, set1/set2/set3 단위로 후보를 분류
  - 시전용(`attack effect`)과 피격용(`hit effect`)으로 실루엣과 motion readability가 높은 세트를 선택
- `docs/implementation/plans/combat_first_build_plan.md`:
  - 전투 경험 목표와 구현 원칙에 `attack effect` / `hit effect` 분리 원칙 추가
  - 전투 UI/스킬 이펙트 진행 메모에 스킬별 2단계 이펙트 확장 계획 반영
  - `asset_sample/Effect/Free`를 `assets/effects/<skill>/<attack|hit>/` 구조로 들여온 뒤 runtime에 연결한다는 기준 추가
- `docs/implementation/increments/combat_increment_02_spell_runtime.md`:
  - `Free effect 1차 배정안` 섹션 추가
  - `fire_bolt`, `frost_nova`, `volt_spear`, `water_aqua_bullet`, `wind_gale_cutter`, `earth_tremor`, `holy_radiant_burst`, `dark_void_bolt`, `arcane_force_pulse`의 `attack effect` / `hit effect` 후보 세트와 파일 번호를 명시

**검증:**
- 문서 전용 세션으로 코드/런타임 변경 없음
- 별도 headless/GUT 실행 없음

#### 다음 우선 작업 (다음 세션)

1. **`asset_sample/Effect/Free` 1차 배정안 중 실제 구현 대상으로 1~2스킬 선택**
   - `volt_spear`, `fire_bolt`, `holy_radiant_burst`처럼 silhouette 차이가 큰 스킬부터 attack/hit 분리 적용 검토
2. **`spell_projectile.gd` 확장 설계**
   - `attack_effect_id`, `hit_effect_id` 또는 terminal effect와 유사한 hook 구조로 붙일 수 있는지 검토
3. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가

### 2026-04-01 (26차 세션 - Cycle 1)

#### `volt_spear` attack/hit effect 실제 런타임 연결 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 직전 세션에서 `asset_sample/Effect/Free` 기반 attack/hit 분리 계획과 스킬별 배정안을 문서에 먼저 고정
  - 이번 세션은 그중 가장 작은 실제 증분으로 `volt_spear` 한 종을 선택
- `asset_sample/Effect/Free` 분석 및 에셋 반영:
  - 문서 기준 배정안 그대로 `Part 11 set2 (516~519.png)`를 `attack effect`, `Part 4 set3 (194~197.png)`를 `hit effect`로 채택
  - `asset_sample/` 원본은 직접 참조하지 않고 다음 경로로 복사
    - `assets/effects/volt_spear_attack/volt_spear_attack_0~3.png`
    - `assets/effects/volt_spear_hit/volt_spear_hit_0~3.png`
- 런타임 변경:
  - `spell_manager.gd`가 `volt_spear` payload에 `attack_effect_id:"volt_spear_attack"`, `hit_effect_id:"volt_spear_hit"`를 싣도록 확장
  - `spell_projectile.gd`에 one-shot sibling effect hook 추가
  - projectile 생성 시 몸쪽에서 `attack effect` 재생
  - 적 명중 시 피격 지점에서 `hit effect` 재생
  - raw PNG fallback 로더를 넣어 import 유무와 관계없이 headless/GUT에서 Free 복사본을 안전하게 읽도록 보강
- 테스트:
  - `volt_spear` cast payload에 effect id가 실리는지 검증
  - scene 진입 시 attack effect sibling이 생기는지 검증
  - 적 명중 시 hit effect sibling이 생기는지 검증

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` 통과
- 전체 GUT `481/481` 통과

#### 다음 우선 작업 (다음 세션)

1. **`fire_bolt` 또는 `holy_radiant_burst` 1종 추가 연결**
   - 이미 문서에 배정된 `attack effect` / `hit effect`를 같은 payload-hook 구조로 붙이기
2. **공용 effect hook 확장 재평가**
   - `spell_projectile.gd`의 one-shot sibling effect 구조가 burst형(`frost_nova`)과 direct pulse형에도 그대로 맞는지 확인
3. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가

### 2026-04-01 (27차 세션 - Cycle 1)

#### `volt_spear` effect를 통합 시트가 아니라 단일 cropped sequence로 교체 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 직전 세션에서 `volt_spear` attack/hit hook은 실제 연결됐지만, Free 원본의 큰 시트를 그대로 1프레임처럼 재생해서 한 번에 여러 effect가 보이는 문제가 남아 있었음
  - 이번 세션은 그 seam만 가장 작게 닫는 후속 보정
- `asset_sample/Effect/Free` 재분석:
  - `Part 11/517.png`와 `Part 4/194.png`를 64×64 그리드로 다시 확인
  - 두 시트 모두 내부에 여러 color row와 frame column이 섞여 있는 형태라, 시트 전체를 쓰면 단일 effect가 아니라 통합 미리보기처럼 보인다는 점을 확인
- 에셋 교체:
  - `Part 11/517.png` row 5, col 1~8의 white sequence를 잘라 `assets/effects/volt_spear_attack/volt_spear_attack_0~7.png`로 재생성
  - `Part 4/194.png` row 5, col 1~8의 white sequence를 잘라 `assets/effects/volt_spear_hit/volt_spear_hit_0~7.png`로 재생성
  - 두 effect 모두 alpha만 유지한 white silhouette로 변환해 runtime tint가 안정적으로 먹도록 보정
- 런타임 변경:
  - `spell_projectile.gd`의 `volt_spear_attack` / `volt_spear_hit` frame count를 8로 확장
  - cropped 64×64 frame에 맞춰 scale을 재조정
- 테스트:
  - attack effect가 8프레임 단일 sequence를 사용하고 첫 프레임 폭이 64px인지 확인
  - hit effect도 동일하게 8프레임/64px cropped tile을 쓰는지 확인

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` 통과
- 전체 GUT `481/481` 통과

#### 다음 우선 작업 (다음 세션)

1. **`fire_bolt` 또는 `holy_radiant_burst` 1종에 동일한 single-effect crop 적용**
   - 문서에 배정된 Free 세트에서 큰 통합 시트가 아니라 단일 sequence만 잘라 붙이기
2. **`volt_spear` anchor/scale 미세 조정 여부 점검**
   - 실제 손 위치와 피격 위치에서 너무 크거나 작지 않은지 후속 보정 검토
3. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가

### 2026-04-01 (28차 세션 - Cycle 1)

#### `fire_bolt` attack/hit effect를 단일 cropped sequence로 실제 연결 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `volt_spear`는 이미 단일 cropped effect로 정리됐고, 다음 최소 증분은 같은 payload-hook 구조를 `fire_bolt`에 재사용하는 것이었음
  - `fire_bolt`는 기존에 fly loop만 있고 cast/hit 분리 이펙트는 아직 없었음
- `asset_sample/Effect/Free` 재분석:
  - `Part 1/13.png`를 64×64 그리드로 확인해 row 5, col 1~8의 white sequence를 `attack effect`로 선택
  - `Part 9/426.png`를 64×64 그리드로 확인해 row 5, col 1~8의 white sequence를 `hit effect`로 선택
- 에셋 반영:
  - `assets/effects/fire_bolt_attack/fire_bolt_attack_0~7.png` 생성
  - `assets/effects/fire_bolt_hit/fire_bolt_hit_0~7.png` 생성
  - 두 effect 모두 alpha만 유지한 white silhouette로 저장해 runtime tint를 안정화
- 런타임 변경:
  - `spell_manager.gd`가 `fire_bolt` payload에 `attack_effect_id:"fire_bolt_attack"`, `hit_effect_id:"fire_bolt_hit"`를 싣도록 확장
  - `spell_projectile.gd`의 one-shot sibling effect 분기에 `fire_bolt_attack`, `fire_bolt_hit` 추가
  - 기존 `fire_bolt` fly loop(`assets/effects/fire_bolt/`)는 유지하고, cast/hit만 별도 one-shot으로 재생되도록 분리
- 테스트:
  - `fire_bolt` cast payload에 effect id가 실리는지 검증
  - scene 진입 시 attack effect sibling이 생기고 8프레임/64px cropped tile을 쓰는지 검증
  - 적 명중 시 hit effect sibling이 생기고 8프레임/64px cropped tile을 쓰는지 검증

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` 통과
- 전체 GUT `484/484` 통과

#### 다음 우선 작업 (다음 세션)

1. **`holy_radiant_burst` 1종에 동일한 single-effect crop 적용**
   - 문서에 배정된 `Part 14 set2` / `Part 6 set1` 기반으로 cast/hit 분리 이펙트 연결
2. **공용 effect hook 확장 재평가**
   - direct pulse형, ground burst형 스킬도 `attack_effect_id` / `hit_effect_id`만으로 충분한지 검토
3. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가

### 2026-04-01 (29차 세션 - Cycle 1)

#### `holy_radiant_burst` attack/hit effect를 단일 cropped sequence로 실제 연결 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `volt_spear`, `fire_bolt`는 이미 단일 cropped effect로 정리됐고, 다음 최소 증분은 같은 구조를 `holy_radiant_burst`에 붙이는 것이었음
  - `holy_radiant_burst`는 holy school payload만 있었고 cast/hit 분리 이펙트는 아직 없었음
- `asset_sample/Effect/Free` 재분석:
  - `Part 14/662.png`를 64×64 그리드로 확인해 row 5, col 1~8의 white sequence를 `attack effect`로 선택
  - `Part 6/273.png`를 64×64 그리드로 확인해 row 5, col 0~7의 white sequence를 `hit effect`로 선택
- 에셋 반영:
  - `assets/effects/holy_radiant_burst_attack/holy_radiant_burst_attack_0~7.png` 생성
  - `assets/effects/holy_radiant_burst_hit/holy_radiant_burst_hit_0~7.png` 생성
  - 두 effect 모두 alpha만 유지한 white silhouette로 저장해 runtime tint를 안정화
- 런타임 변경:
  - `spell_manager.gd`가 `holy_radiant_burst` payload에 `attack_effect_id:"holy_radiant_burst_attack"`, `hit_effect_id:"holy_radiant_burst_hit"`를 싣도록 확장
  - `spell_projectile.gd`의 one-shot sibling effect 분기에 `holy_radiant_burst_attack`, `holy_radiant_burst_hit` 추가
  - holy projectile 판정은 그대로 유지하고, cast/hit만 별도 one-shot으로 재생되도록 분리
- 테스트:
  - `holy_radiant_burst` cast payload에 effect id가 실리는지 검증
  - scene 진입 시 attack effect sibling이 생기고 8프레임/64px cropped tile을 쓰는지 검증
  - 적 명중 시 hit effect sibling이 생기고 8프레임/64px cropped tile을 쓰는지 검증

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` 통과
- 전체 GUT `487/487` 통과

#### 다음 우선 작업 (다음 세션)

1. **`water_aqua_bullet` 또는 `wind_gale_cutter` 1종에 동일한 single-effect crop 적용**
   - 이미 문서에 배정된 Free 세트에서 단일 sequence만 잘라 cast/hit 분리 연결
2. **공용 effect hook 확장 재평가**
   - direct pulse형, ground burst형, radial burst형 스킬을 같은 helper로 계속 묶어도 충분한지 점검
3. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가

### 2026-04-01 (30차 세션 - Cycle 1)

#### `water_aqua_bullet` attack/hit effect를 단일 cropped sequence로 실제 연결 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `volt_spear`, `fire_bolt`, `holy_radiant_burst`는 이미 단일 cropped effect로 정리됐고, 다음 최소 증분은 같은 구조를 `water_aqua_bullet`에 붙이는 것이었음
  - `water_aqua_bullet`는 water school payload만 있었고 cast/hit 분리 이펙트는 아직 없었음
- `asset_sample/Effect/Free` 재분석:
  - `Part 10/474.png`를 64×64 그리드로 확인해 row 5, col 2~9의 white sequence를 `attack effect`로 선택
  - `Part 1/23.png`를 64×64 그리드로 확인해 row 5, col 2~9의 white sequence를 `hit effect`로 선택
- 에셋 반영:
  - `assets/effects/water_aqua_bullet_attack/water_aqua_bullet_attack_0~7.png` 생성
  - `assets/effects/water_aqua_bullet_hit/water_aqua_bullet_hit_0~7.png` 생성
  - 두 effect 모두 alpha만 유지한 white silhouette로 저장해 runtime tint를 안정화
- 런타임 변경:
  - `spell_manager.gd`가 `water_aqua_bullet` payload에 `attack_effect_id:"water_aqua_bullet_attack"`, `hit_effect_id:"water_aqua_bullet_hit"`를 싣도록 확장
  - `spell_projectile.gd`의 one-shot sibling effect 분기에 `water_aqua_bullet_attack`, `water_aqua_bullet_hit` 추가
  - water projectile 판정은 그대로 유지하고, cast/hit만 별도 one-shot으로 재생되도록 분리
- 테스트:
  - `water_aqua_bullet` cast payload에 effect id가 실리는지 검증
  - scene 진입 시 attack effect sibling이 생기고 8프레임/64px cropped tile을 쓰는지 검증
  - 적 명중 시 hit effect sibling이 생기고 8프레임/64px cropped tile을 쓰는지 검증

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` 통과
- 전체 GUT `490/490` 통과

#### 다음 우선 작업 (다음 세션)

1. **`wind_gale_cutter` 1종에 동일한 single-effect crop 적용**
   - 이미 문서에 배정된 `Part 2 set1` / `Part 3 set1` 기반으로 cast/hit 분리 이펙트 연결
2. **공용 effect hook 확장 재평가**
   - direct pulse형, ground burst형, radial burst형 스킬을 같은 helper로 계속 묶어도 충분한지 점검
3. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가

### 2026-04-01 (31차 세션 - Cycle 1)

#### `wind_gale_cutter` attack/hit effect를 단일 cropped sequence로 실제 연결 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `volt_spear`, `fire_bolt`, `holy_radiant_burst`, `water_aqua_bullet`는 이미 단일 cropped effect로 정리됐고, 다음 최소 증분은 같은 구조를 `wind_gale_cutter`에 붙이는 것이었음
  - `wind_gale_cutter`는 wind school payload만 있었고 cast/hit 분리 이펙트는 아직 없었음
- `asset_sample/Effect/Free` 재분석:
  - `Part 2/62.png`를 64×64 그리드로 확인해 row 5, col 0~7의 white gust sequence를 `attack effect`로 선택
  - `Part 3/113.png`를 64×64 그리드로 확인해 row 5, col 1~8의 white impact fan sequence를 `hit effect`로 선택
- 에셋 반영:
  - `assets/effects/wind_gale_cutter_attack/wind_gale_cutter_attack_0~7.png` 생성
  - `assets/effects/wind_gale_cutter_hit/wind_gale_cutter_hit_0~7.png` 생성
  - 두 effect 모두 alpha만 유지한 white silhouette로 저장해 runtime tint를 안정화
- 런타임 변경:
  - `spell_manager.gd`가 `wind_gale_cutter` payload에 `attack_effect_id:"wind_gale_cutter_attack"`, `hit_effect_id:"wind_gale_cutter_hit"`를 싣도록 확장
  - `spell_projectile.gd`의 one-shot sibling effect 분기에 `wind_gale_cutter_attack`, `wind_gale_cutter_hit` 추가
  - wind projectile 판정은 그대로 유지하고, cast/hit만 별도 one-shot으로 재생되도록 분리
- 테스트:
  - `wind_gale_cutter` cast payload에 effect id가 실리는지 검증
  - scene 진입 시 attack effect sibling이 생기고 8프레임/64px cropped tile을 쓰는지 검증
  - 적 명중 시 hit effect sibling이 생기고 8프레임/64px cropped tile을 쓰는지 검증

**검증:**
- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

#### 다음 우선 작업 (다음 세션)

1. **`earth_tremor` 또는 `dark_void_bolt` 1종에 동일한 single-effect crop 적용**
   - 이미 문서에 배정된 Free 세트에서 단일 sequence만 잘라 cast/hit 분리 연결
2. **공용 effect hook 확장 재평가**
   - direct pulse형, ground burst형, radial burst형 스킬을 같은 helper로 계속 묶어도 충분한지 점검
3. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가

### 2026-04-01 (32차 세션 - Cycle 1)

#### `earth_tremor` attack/hit effect를 단일 cropped sequence로 실제 연결 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `volt_spear`, `fire_bolt`, `holy_radiant_burst`, `water_aqua_bullet`, `wind_gale_cutter`는 이미 단일 cropped effect로 정리됐고, 다음 최소 증분은 같은 구조를 `earth_tremor`에 붙이는 것이었음
  - `earth_tremor`는 earth school payload만 있었고 cast/hit 분리 이펙트는 아직 없었음
- `asset_sample/Effect/Free` 재분석:
  - `Part 10/464.png`를 64×64 그리드로 확인해 row 5, col 1~8의 white pillar sequence를 `attack effect`로 선택
  - `Part 2/69.png`를 64×64 그리드로 확인해 row 5, col 0~7의 white debris burst sequence를 `hit effect`로 선택
- 에셋 반영:
  - `assets/effects/earth_tremor_attack/earth_tremor_attack_0~7.png` 생성
  - `assets/effects/earth_tremor_hit/earth_tremor_hit_0~7.png` 생성
  - 두 effect 모두 alpha만 유지한 white silhouette로 저장해 runtime tint를 안정화
- 런타임 변경:
  - `spell_manager.gd`가 `earth_tremor` payload에 `attack_effect_id:"earth_tremor_attack"`, `hit_effect_id:"earth_tremor_hit"`를 싣도록 확장
  - `spell_projectile.gd`의 one-shot sibling effect 분기에 `earth_tremor_attack`, `earth_tremor_hit` 추가
  - earth projectile 판정은 그대로 유지하고, cast/hit만 별도 one-shot으로 재생되도록 분리
- 테스트:
  - `earth_tremor` cast payload에 effect id가 실리는지 검증
  - scene 진입 시 attack effect sibling이 생기고 8프레임/64px cropped tile을 쓰는지 검증
  - 적 명중 시 hit effect sibling이 생기고 8프레임/64px cropped tile을 쓰는지 검증

**검증:**
- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

#### 다음 우선 작업 (다음 세션)

1. **`dark_void_bolt` 또는 `arcane_force_pulse` 1종에 동일한 single-effect crop 적용**
   - 이미 문서에 배정된 Free 세트에서 단일 sequence만 잘라 cast/hit 분리 연결
2. **공용 effect hook 확장 재평가**
   - direct pulse형, ground burst형, radial burst형 스킬을 같은 helper로 계속 묶어도 충분한지 점검
3. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가

### 2026-04-01 (33차 세션 - Cycle 1)

#### `dark_void_bolt` attack/hit effect를 단일 cropped sequence로 실제 연결 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `volt_spear`, `fire_bolt`, `holy_radiant_burst`, `water_aqua_bullet`, `wind_gale_cutter`, `earth_tremor`는 이미 단일 cropped effect로 정리됐고, 다음 최소 증분은 같은 구조를 `dark_void_bolt`에 붙이는 것이었음
  - `dark_void_bolt`는 dark school payload만 있었고 cast/hit 분리 이펙트는 아직 없었음
- `asset_sample/Effect/Free` 재분석:
  - `Part 9/446.png`를 64×64 그리드로 확인해 row 5, col 1~8의 white crescent sigil sequence를 `attack effect`로 선택
  - `Part 13/632.png`를 64×64 그리드로 확인해 row 5, col 0~7의 white void ring sequence를 `hit effect`로 선택
- 에셋 반영:
  - `assets/effects/dark_void_bolt_attack/dark_void_bolt_attack_0~7.png` 생성
  - `assets/effects/dark_void_bolt_hit/dark_void_bolt_hit_0~7.png` 생성
  - 두 effect 모두 alpha만 유지한 white silhouette로 저장해 runtime tint를 안정화
- 런타임 변경:
  - `spell_manager.gd`가 `dark_void_bolt` payload에 `attack_effect_id:"dark_void_bolt_attack"`, `hit_effect_id:"dark_void_bolt_hit"`를 싣도록 확장
  - `spell_projectile.gd`의 one-shot sibling effect 분기에 `dark_void_bolt_attack`, `dark_void_bolt_hit` 추가
  - dark projectile 판정은 그대로 유지하고, cast/hit만 별도 one-shot으로 재생되도록 분리
- 테스트:
  - `dark_void_bolt` cast payload에 effect id가 실리는지 검증
  - scene 진입 시 attack effect sibling이 생기고 8프레임/64px cropped tile을 쓰는지 검증
  - 적 명중 시 hit effect sibling이 생기고 8프레임/64px cropped tile을 쓰는지 검증

**검증:**
- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

#### 다음 우선 작업 (다음 세션)

1. **`arcane_force_pulse` 1종에 동일한 single-effect crop 적용**
   - 이미 문서에 배정된 Free 세트에서 단일 sequence만 잘라 cast/hit 분리 연결
2. **공용 effect hook 확장 재평가**
   - direct pulse형, ground burst형, radial burst형 스킬을 같은 helper로 계속 묶어도 충분한지 점검
3. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가

### 2026-04-01 (34차 세션 - Cycle 1)

#### split effect registry 정리 + 64x64 cropped frame 회귀 고정 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 다음 후보는 `arcane_force_pulse` single-effect crop이었지만, 이번 세션의 수정 가능 파일 목록에는 `assets/**`가 없어 새 PNG 생성 증분은 바로 진행하지 않음
  - 대신 이미 연결된 일곱 스킬 split effect가 다시 Preview 전체 시트로 돌아가지 않도록 runtime registry와 회귀 테스트를 먼저 고정했음
- 런타임 정리:
  - `spell_manager.gd`의 spell→`attack_effect_id`/`hit_effect_id` 분기를 `SPLIT_EFFECT_PAYLOADS` registry로 정리
  - `spell_projectile.gd`의 world effect 분기를 `WORLD_EFFECT_SPECS` registry로 정리
  - split effect 추가 시 payload 매핑과 visual spec을 더 짧고 안전하게 확장할 수 있는 구조로 정렬
- 테스트:
  - `test_spell_manager.gd`에 연결된 일곱 스킬 전체를 순회하는 split-effect regression 추가
  - 모든 `attack/hit effect`가 8프레임이며 첫 프레임이 64×64 cropped tile인지 한 번에 검증

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` 통과
- 전체 GUT `501/501` 통과

#### 다음 우선 작업 (다음 세션)

1. **`arcane_force_pulse` 1종에 동일한 single-effect crop 적용**
   - 단, 이번 세션과 같은 수정 가능 범위가 유지되면 `assets/**`가 범위 밖이므로 새 effect PNG 생성 전 범위 재확인 필요
2. **공용 effect hook 확장 재평가**
   - direct pulse형, ground burst형, radial burst형 스킬을 같은 helper로 계속 묶어도 충분한지 점검
3. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가

### 2026-04-01 (35차 세션 - Cycle 1)

#### split effect payload/visual registry sync 회귀 고정 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 직전 세션에서 split effect 매핑을 registry로 정리했지만, payload registry와 world visual registry가 서로 다른 id 집합으로 벌어지는지 막는 직접 검증은 없었음
  - `arcane_force_pulse`는 여전히 새 crop PNG가 필요한 후보지만, 이번 세션 수정 가능 파일 목록에는 `assets/**`가 없어 더 작은 안전 증분으로 registry sync 회귀를 선택
- 런타임 정리:
  - `spell_manager.gd`에 split-effect registry 조회 helper(`get_split_effect_skill_ids`, `get_split_effect_payload`) 추가
  - `spell_projectile.gd`에 world effect registry 조회 helper(`has_world_effect_spec`, `get_world_effect_ids`) 추가
- 테스트:
  - `test_spell_manager.gd`에 payload registry와 world effect registry를 양방향 비교하는 회귀 테스트 추가
  - 각 skill의 attack/hit id가 visual spec을 반드시 가지고 있는지, 반대로 visual spec 목록이 payload registry에서 도달 가능한 id와 정확히 일치하는지 검증

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` 통과
- 전체 GUT `501/501` 통과

#### 다음 우선 작업 (다음 세션)

1. **`arcane_force_pulse` 1종에 동일한 single-effect crop 적용**
   - 단, 같은 수정 가능 범위가 유지되면 `assets/**`가 범위 밖이므로 새 effect PNG 생성 전 범위 재확인 필요
2. **공용 effect hook 확장 재평가**
   - direct pulse형, ground burst형, radial burst형 스킬을 같은 helper로 계속 묶어도 충분한지 점검
3. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가

### 2026-04-01 (36차 세션 - Cycle 1)

#### 전투 MVP 종료 조건 + 우선순위 재조정 + 핫바 기준선 문서 고정 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 전투 우선 개발 방향 자체는 맞지만, 기준 문서상 `6슬롯 초기 구조`, `에셋/GUI 우선순위 재정렬`, `전투 MVP 종료 조건`이 현재 빌드와 완전히 맞물려 있지 않았음
  - 실제 코드 기준 `DEFAULT_SPELL_HOTBAR`는 `10개 주문 + 3개 버프`로 확장돼 있어, 문서의 오래된 6슬롯 기준선을 그대로 두면 PM/구현 우선순위가 흔들릴 수 있었음
- 문서 정리:
  - `combat_first_build_plan.md`에 현재 전투 MVP 종료 조건 추가
  - `전투 코어 우선 -> 그래픽/UI 확장` 순서를 다시 고정하는 2026-04-01 우선순위 재조정 섹션 추가
  - 스킬 타입과 적 아키타입의 교차 검증을 위한 전투 커버리지 매트릭스 추가
  - 다음 개발 스테이지를 `Stage A~E`로 정리해 프로토타입 이후 확장 순서를 명시
  - `combat_increment_02_spell_runtime.md`에 현재 빌드 기준 핫바 13칸(주문 10 + 버프 3) 기준선을 반영

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` 통과
- 전체 GUT `501/501` 통과

#### 다음 우선 작업 (다음 세션)

1. **`arcane_force_pulse` 1종에 동일한 single-effect crop 적용**
   - 단, 같은 수정 가능 범위가 유지되면 `assets/**`가 범위 밖이므로 새 effect PNG 생성 전 범위 재확인 필요
2. **전투 커버리지 매트릭스의 빈 칸을 실제 테스트 항목으로 전환**
   - 스킬 타입 × 적 아키타입 교차 검증을 GUT 기준으로 단계별 고정
3. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가

### 2026-04-01 (37차 세션 - Cycle 1)

#### 전투 커버리지 매트릭스의 대표 액티브 행을 실제 교차 검증 GUT로 전환 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 직전 세션에서 문서에 `스킬 타입 × 적 아키타입` 전투 커버리지 매트릭스를 추가했지만, 실제 테스트로 연결된 항목은 아직 없었음
  - 자산 추가가 필요한 `arcane_force_pulse`보다 더 작은 안전 증분으로, 이미 연결된 대표 액티브 2종의 적 아키타입 교차 검증을 먼저 고정했음
- 테스트 보강:
  - `test_spell_manager.gd`에 `fire_bolt`가 근접(`brute`), 원거리(`bomber`), 압박(`leaper`), 엘리트(`elite`)에 모두 실제 projectile hit 경로로 피해/피격 flash/session hit를 남기는지 검증 추가
  - `test_spell_manager.gd`에 `wind_gale_cutter`가 같은 네 아키타입에 실제 projectile hit 경로로 피해를 주고, 관통 수를 유지하는지 검증 추가
  - 두 테스트 모두 split `hit effect`가 실제 sibling sprite로 생성되는지 함께 확인

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` 통과
- 전체 GUT `503/503` 목표로 재검증

#### 다음 우선 작업 (다음 세션)

1. **전투 커버리지 매트릭스의 설치형/토글형 행도 실제 교차 검증으로 확대**
   - `plant_vine_snare`, `ice_glacial_dominion` 또는 `lightning_tempest_crown`을 대표로 삼아 적 아키타입 반응을 GUT로 고정
2. **`arcane_force_pulse` 1종에 동일한 single-effect crop 적용**
   - 단, 같은 수정 가능 범위가 유지되면 `assets/**`가 범위 밖이므로 새 effect PNG 생성 전 범위 재확인 필요
3. **admin_menu.gd 교차 의존 요청들**: (친구 소유 — 직접 불가)
   - spell_dark/spell_arcane 핫바 슬롯 반영
   - earth_deploy/holy_guard/dark_shadow/arcane_pulse 프리셋 목록 추가
   - rat/tooth_walker/eyeball/trash_monster/sword 몬스터 spawn 탭 추가

### 2026-04-01 (38차 세션 - Cycle 1)

#### 전투 커버리지 매트릭스의 가장 비어 있던 행을 구현 가능한 기획 명세로 구체화 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `단일 투사체`, `관통 투사체`는 이미 실제 GUT로 일부 닫혔지만, `설치형`, `토글형`, `버프 폭발/조합`, `attack/hit effect 가독성`은 아직 “필요” 수준 메모에 가까웠음
  - 구현 순서상 가장 시급한 것은 새 스킬 추가보다, 이 빈 행들을 대표 스킬과 완료 기준이 있는 명세로 바꾸는 일이었음
- 문서 구체화:
  - `combat_first_build_plan.md`에 `설치형=stone_spire`, `토글형=ice_glacial_dominion`, `버프 폭발=Ashen Rite`를 대표 케이스로 고정
  - 설치형은 `지속 누적 딜`, 토글형은 `유틸/상태이상 오라`, burst 조합은 `짧은 타이밍 폭딜`로 해석 기준을 명시
  - `attack effect`/`hit effect`는 위치, 프레임 수, 64×64 cropped tile, school별 색감 방향까지 완료 기준을 추가
  - `combat_increment_02_spell_runtime.md`에는 설치형/토글형 대표 검증 기준과 split effect 가독성 공통 규칙을 추가
  - `combat_increment_03_buff_action_loop.md`에는 `Ashen Rite`를 대표 burst 조합으로 고정하고 stack → burst → penalty 3단 검증 기준을 추가
  - 검증 blocker였던 `SceneTreeTimer` 누수를 없애기 위해 `enemy_attack_profiles.gd`, `enemy_base.gd`, `spell_projectile.gd`의 tree timer 경로를 owner-managed `Timer` 노드로 정리
  - 다만 최종 GUT 종료 시점에는 `scripts/main/main.gd`의 `create_timer()` async 경로에서 남는 `SceneTreeTimer` leak 경고가 계속 남았고, 이 파일은 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - 테스트 본문 `509/509` 통과
  - 종료 시 `SceneTreeTimer` leak warning 2개 남음 (`scripts/main/main.gd` async timer 경로로 추정)

#### 다음 우선 작업 (다음 세션)

1. **`stone_spire` 설치형 교차 검증을 실제 GUT로 전환**
   - `brute` 우선, 이후 `bomber/leaper/elite`까지 반복 타격과 유지시간 경로 고정
2. **`ice_glacial_dominion` 토글형 교차 검증을 실제 GUT로 전환**
   - 유지 마나 tick, 자동 해제, `slow` utility effect를 전 적 아키타입 기준으로 고정
3. **`Ashen Rite` burst + penalty 경로를 대표 조합 회귀로 고정**
   - stack 누적, burst 발동, penalty 적용/해제까지 한 사이클로 묶어 검증
4. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 `test_main_integration.gd` 종료 시 `SceneTreeTimer` warning 2개를 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-01 (39차 세션 - Cycle 1)

#### `stone_spire` 설치형 대표 검증 기준을 `brute` 우선 누적 딜 명세로 재고정 (Cycle 1)

**완료 항목:**
- 사용자 선택 기반으로 설치형 대표 검증 기준을 다시 구체화함
- `combat_first_build_plan.md`의 설치형 명세를 `leaper` 우선에서 `brute` 우선으로 수정
- `stone_spire`를 `지속 누적 딜 장치`로 더 명확히 정의하고 아래 구현 기준을 추가
  - 범위 안 적에게 고정 간격 반복 타격
  - 짧게 스쳐도 최소 1회 타격 보장
  - 낮은 순간 화력 + 높은 누적 기대값
  - 장비/버프 반영 우선순위는 `tick damage`
  - 생성 연출과 지속 타격 연출 분리
- `combat_increment_02_spell_runtime.md`에도 같은 기준을 반영해 즉시 GUT로 옮길 수 있게 정리
- `tests/test_spell_manager.gd`의 `stone_spire` 대표 설치형 회귀를 바닥 없는 테스트 환경에서도 안정적으로 돌도록 보정
  - 적 아키타입을 정지 상태로 고정
  - deploy duration 검증 프레임 여유를 늘림

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `518/518` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 여전히 남음
  - 기존과 동일하게 `scripts/main/main.gd` async timer 경로가 의심되며, 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

#### 다음 우선 작업 (다음 세션)

1. **`stone_spire` 설치형 교차 검증을 실제 GUT로 전환**
   - `brute` 우선
   - spawn / duration / repeated tick / graze minimum hit / other archetype minimum hit 순서로 고정
2. **`ice_glacial_dominion` 토글형 교차 검증을 실제 GUT로 전환**
3. **`Ashen Rite` burst + penalty 경로를 대표 조합 회귀로 고정**

### 2026-04-01 (39차 세션 - Cycle 2)

#### `stone_spire` 설치형 교차 검증을 실제 GUT + 런타임 보정으로 고정 (Cycle 2)

**완료 항목:**
- 현재 상태 요약:
  - `Stone Spire`는 대표 설치형으로 이미 문서화돼 있었지만, 실제 런타임에서는 반복 타격이 안정적으로 유지되지 않았음
  - 첫 타 이후 적이 설치 범위 밖으로 밀려나거나, 지속형 타격에도 hitstop이 걸려 펄스와 만료 시간이 흔들리는 문제가 있었음
- 런타임 보정:
  - `scripts/player/spell_manager.gd`에서 스킬 데이터 기반 `knockback_base`를 deploy runtime/payload로 반영하도록 확장
  - `data/skills/skills.json`의 `earth_stone_spire`에 `knockback_base: 0.0`, `tick_interval: 0.2`를 고정
  - `scripts/player/spell_projectile.gd`에서 지속형 area effect는 hitstop을 발생시키지 않게 조정
- 테스트 고정:
  - `tests/test_spell_manager.gd`의 `stone_spire` 교차 검증을 `brute/bomber/leaper/elite` 기준으로 확장
  - 반복 타격 중 처치되는 케이스까지 허용하면서도 `session_hit_count > 1`과 설치물 만료를 함께 검증하도록 정리
  - deploy payload가 `knockback 0.0`을 내보내는지 회귀 체크 추가

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `519/519` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

### 2026-04-01 (39차 세션 - Cycle 3)

#### `ice_glacial_dominion` 토글형 교차 검증을 실제 GUT로 고정 (Cycle 3)

**완료 항목:**
- 현재 상태 요약:
  - `Glacial Dominion`은 payload 방출, 요약 문자열, mana drain 테스트는 있었지만, 실제로 핵심 적 아키타입에 `slow`가 적용되는지는 owner_core 회귀로 고정되지 않았음
- 테스트 보강:
  - `tests/test_spell_manager.gd`에 `Glacial Dominion` 교차 검증 추가
  - `brute/bomber/leaper/elite` 각각에 대해 toggle aura tick payload를 실제 projectile로 생성하고, `slow` timer / `slow_multiplier` / `session_hit_count`를 검증하도록 구성
- 테스트 안정화:
  - toggle aura hitstop이 다음 테스트로 번지지 않도록 해당 교차 테스트 내에서 `Engine.time_scale = 1.0` 및 `GameState.reset_progress_for_tests()` cleanup을 명시

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `519/519` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **`Ashen Rite` burst + penalty 경로를 대표 조합 회귀로 고정**
   - stack 누적, burst 발동, penalty 적용/해제까지 한 사이클로 묶기
2. **toggle/deploy 계열 hitstop 정책을 문서 기준으로 정리**
   - 지속형 설치물은 비활성화로 정리됐지만, 짧은 토글 오라/근접 area hitstop 정책은 아직 명문화되지 않았음
3. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-01 (39차 세션 - Cycle 4)

#### `Ashen Rite` burst + penalty 경로를 aftermath summary + recovery 회귀까지 고정 (Cycle 4)

**완료 항목:**
- 현재 상태 요약:
  - `Ashen Rite`는 stack 누적, burst 발동, penalty 적용 자체는 이미 구현돼 있었지만, burst가 끝난 직후 penalty window가 combo summary에서 바로 사라져 후속 리스크 구간이 읽히지 않았음
  - penalty 만료 후 수치와 시전 가능 상태가 정상 복귀하는지도 대표 회귀로 아직 고정되지 않았음
- 런타임 보정:
  - `scripts/autoload/game_state.gd`의 `get_combo_summary()`를 확장해 활성 조합이 없어도 `active_penalties` 기반 aftermath 문자열을 노출하도록 정리
  - `_get_penalty_remaining()`, `_get_ashen_rite_aftermath_summary()` 헬퍼를 추가해 `GuardBreak` / `Lock` 잔여시간을 summary에 표시
  - 결과적으로 burst 종료 후 `[BURST]`는 사라지되 `Aftermath  GuardBreak ...  Lock ...`이 penalty 구간 내내 유지됨
- 테스트 고정:
  - `tests/test_game_state.gd`에 `test_combo_summary_shows_ashen_rite_aftermath_window_after_burst` 추가
  - `tests/test_game_state.gd`에 `test_ashen_rite_penalties_expire_and_runtime_returns_to_normal` 추가
  - penalty 종료 후 `get_damage_taken_multiplier() == 1.0`, `try_activate_buff()` 재활성 가능, `get_combo_summary() == "Combos  none"`까지 한 사이클로 묶어 검증

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `521/521` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **toggle/deploy 계열 hitstop 정책을 owner_core 문서 + 회귀 기준으로 고정**
   - `stone_spire`는 비활성화로 정리됐지만 `glacial_dominion` 같은 짧은 오라 tick과 근접 area burst의 기준은 아직 흩어져 있음
   - `combat_increment_02_spell_runtime.md`와 관련 GUT에 `지속형/토글형/순간 area` hitstop 규칙을 명시적으로 닫는 것이 다음 작은 안전 증분
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-01 (39차 세션 - Cycle 5)

#### toggle/deploy/area burst hitstop 정책을 payload 기준으로 고정 (Cycle 5)

**완료 항목:**
- 현재 상태 요약:
  - 기존 런타임은 `persistent area effect면 hitstop 없음` 정도만 암묵적으로 갖고 있었고, 설치형/토글형/순간 area burst의 기준이 payload 수준에서는 명시되지 않았음
  - `stone_spire`와 `glacial_dominion`은 우연히 맞았지만, 다음 리팩터링에서 쉽게 다시 흔들릴 수 있는 상태였음
- 런타임 보정:
  - `scripts/player/spell_manager.gd`에 `_apply_hitstop_policy()`를 추가해 payload에 `hitstop_mode`를 명시적으로 넣도록 정리
  - 설치형 `deploy`와 토글 aura tick은 `hitstop_mode = "none"`으로 고정
  - `earth_tremor`, `frost_nova` 같은 순간 area burst는 `speed == 0`, `duration > 0`, `size >= 48` 조건에서 `hitstop_mode = "area_burst"`로 분류
  - 기본 단일/관통 투사체는 `hitstop_mode = "default"` 유지
  - `scripts/player/spell_projectile.gd`는 payload의 `hitstop_mode`를 읽어 hitstop duration을 분기하고, hitstop 복구용 `Timer`는 `ignore_time_scale = true`로 고정해 짧은 stun window가 실제 시간 기준으로 안정적으로 끝나게 정리
- 테스트 고정:
  - `tests/test_spell_manager.gd`에 `stone_spire` payload가 `none`, `glacial_dominion` tick payload가 `none`, `earth_tremor`가 `area_burst`를 내보내는지 검증 추가
  - `stone_spire` pulse와 `glacial_dominion` aura tick이 실제로 `Engine.time_scale`을 바꾸지 않는지 회귀 추가
  - `earth_tremor` area burst가 짧은 hitstop을 만들고 자동 복구하는지 회귀 추가

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `525/525` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **`frost_nova`를 순간 area burst 대표 스킬로 승격해 hitstop/effect/camera coverage를 고정**
   - hitstop 정책 문서 기준을 `earth_tremor` 임시 대표에서 `frost_nova` 공식 대표로 재정렬
   - `leaper` 압박 상황 우선, 이후 `brute/bomber/elite`로 확대
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-01 (40차 세션 - Cycle 1)

#### toggle/deploy/area burst hitstop 정책을 `frost_nova` / `leaper` 기준으로 재구체화 (Cycle 1)

**완료 항목:**
- 사용자 선택 기반으로 hitstop 정책의 대표 스킬과 우선 검증 상황을 다시 고정
- `combat_first_build_plan.md`에 아래 기준을 반영
  - 지속형 비투사체는 전투 템포를 끊지 않고, 결정적인 순간만 강하게 읽힌다
  - 설치형 대표: `stone_spire`
  - 토글형 대표: `ice_glacial_dominion`
  - 순간 area burst 대표: `frost_nova`
  - 우선 검증 상황: `leaper`가 파고드는 압박/카이팅 상황
- `combat_increment_02_spell_runtime.md`에 아래 구현 기준을 반영
  - `ice_glacial_dominion`은 `leaper` 기준 카이팅 slow 검증을 먼저 본다
  - 설치형 tick은 `sparse_tick`, 토글 tick은 `none`, 순간 area burst는 `area_burst`
  - 1차 GUT 완료 기준은 `stone_spire`, `ice_glacial_dominion`, `frost_nova`의 4아키타입 + effect/camera 반응까지 포함
- 이번 세션 추가 구체화:
  - `frost_nova`의 대표 역할을 `상태이상 시동 burst`로 고정
  - 첫 검증 적은 `leaper`, 첫 장면은 `다수 적 광역 정리`
  - 단일 투사체보다 강한 짧은 hitstop + burst shake 1회 + cast seed/bloom 분리 연출을 공식 기준으로 고정

**검증:**
- 문서 변경만 수행. 런타임/테스트 코드는 이번 사이클에서 수정하지 않음

#### 다음 우선 작업 (다음 세션 갱신)

1. **`frost_nova`를 순간 area burst 대표 스킬로 고정하는 실제 GUT 추가**
   - `leaper` 우선 + `brute/bomber/elite` 확대
   - damage / hitstop / effect / camera 반응까지 1차 완료 기준에 맞춰 닫기
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-01 (41차 세션 - Cycle 1)

#### `frost_nova` 순간 area burst 대표 검증 명세를 구현 가능한 수준으로 추가 구체화 (Cycle 1)

**완료 항목:**
- 사용자 선택 기반으로 `frost_nova` 대표 burst 명세를 문서에 추가 반영
- `combat_first_build_plan.md`에 아래 기준을 추가
  - `frost_nova`는 접근 차단 + 다음 냉기 연계를 여는 `상태이상 시동 burst`
  - 첫 검증 적: `leaper`
  - 첫 검증 상황: `다수 적 광역 정리`, 특히 `leaper` 압박 차단
  - 수치 방향: 넓은 범위 + 중상급 burst
  - 상태이상: 짧고 강한 `slow` 또는 짧은 경직
  - camera: 짧은 burst shake 1회
  - 연출: cast seed와 bloom 분리
- `combat_increment_02_spell_runtime.md`에는 `frost_nova` 전용 구현/테스트 기준 섹션을 추가

**검증:**
- 문서 변경만 수행. 런타임/테스트 코드는 이번 사이클에서 수정하지 않음

#### 다음 우선 작업 (다음 세션 갱신)

1. **`frost_nova` 대표 area burst GUT 추가**
   - `leaper` 우선
   - 4개 적 아키타입 damage / hitstop / effect / camera 반응 고정
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-01 (42차 세션 - Cycle 1)

#### `frost_nova` 순간 area burst 대표 회귀를 `leaper` 실전 경로로 고정 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `frost_nova`는 문서상 대표 순간 area burst였지만, 실제 owner_core 회귀는 `earth_tremor` 쪽이 더 강했고 `leaper` 압박 상황에서의 hitstop/effect/camera 반응은 아직 고정되지 않았음
  - payload 수준의 `area_burst` 규칙은 이미 있었지만, 플레이어 cast shake와 실제 `leaper` 피격 경로가 함께 닫히지 않은 상태였음
- 런타임/테스트 보정:
  - `scripts/player/player.gd`에서 `hitstop_mode = "area_burst"` payload 시전에만 짧은 로컬 cast shake를 부여해 순간 burst camera 반응을 플레이어 기준선으로 추가
  - `tests/test_spell_manager.gd`에 `frost_nova` payload가 `area_burst`를 내보내는지, `leaper` 실전 경로에서 짧은 hitstop + 즉시 AnimatedSprite2D visual + hit flash가 함께 발생하는지 회귀 추가
  - `tests/test_player_controller.gd`에 핫바에서 `frost_nova`를 실제 시전했을 때 짧은 camera shake가 시작되는지 회귀 추가
  - `combat_increment_02_spell_runtime.md`에 `frost_nova` 대표 burst의 실제 회귀 기준을 `payload + leaper hit path + visual + local cast shake`까지 반영

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `528/528` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **`frost_nova` 대표 area burst coverage를 4개 적 아키타입으로 확대**
   - 현재는 `leaper` 실전 경로와 payload/camera 반응을 먼저 닫았음
   - 다음 owner_core 증분은 `brute`, `bomber`, `elite`까지 damage / hitstop / effect / camera 반응을 같은 규칙으로 확대
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-01 (43차 세션 - Cycle 1)

#### `frost_nova`를 실제 freeze 대표 burst로 승격하고 4개 적 아키타입 coverage를 닫음 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `frost_nova`는 문서상 `freeze` 대표 burst로 재정렬됐지만, 실제 runtime payload는 여전히 상태이상 없이 area burst damage만 전달하는 상태였음
  - 회귀도 `leaper` 단일 케이스까지만 닫혀 있어 `brute`, `bomber`, `elite`까지 같은 규칙으로 유지되는지는 아직 고정되지 않았음
- 런타임/테스트 보정:
  - `data/spells.json`의 `frost_nova`에 `freeze` utility effect를 추가해 실제 payload가 빙결 시동 burst 역할을 갖도록 보정
  - `tests/test_spell_manager.gd`에 `frost_nova` payload가 `freeze` utility effect를 싣는지 확인하는 회귀 추가
  - 같은 파일에서 `brute`, `bomber`, `leaper`, `elite` 4개 적 아키타입에 대해 damage / hitstop / burst visual / hit flash / freeze 적용이 모두 유지되는지 교차 검증 회귀 추가
  - `tests/test_enemy_base.gd`에 `freeze`가 적 runtime에서 hard CC로 인식되는지 직접 검증하는 회귀 추가
  - `combat_increment_02_spell_runtime.md`에 `frost_nova`의 실제 완료 기준을 `freeze payload + 4 archetype coverage`까지 반영

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `529/529` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 기존과 동일하게 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **`plant_vine_snare`를 root 대표 설치형 제어기로 확장**
  - 현재는 `brute` 단일 케이스 중심
  - 다음 owner_core 증분은 `brute`, `bomber`, `leaper`, `elite`에 대해 root 적용, 재적용, duration 갱신, 엘리트 저항 차이를 닫는 일
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-01 (44차 세션 - Cycle 1)

#### `plant_vine_snare`를 root 대표 설치형 제어기로 고정하고 root/runtime 의미를 문서 기준과 일치시킴 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `plant_vine_snare`는 문서상 대표 `root` 설치형이었지만, 실제 회귀는 `brute` 단일 케이스만 닫혀 있었음
  - 더 중요한 불일치로, `enemy_base.gd`는 `root`를 `freeze/stun`과 같은 hard CC로 취급해 행동까지 멈추고 있었음
- 런타임/테스트 보정:
  - `scripts/enemies/enemy_base.gd`에 `root` 전용 이동 잠금 경로를 추가해, 이제 `root`는 이동만 봉인하고 `stun/freeze`만 full hard CC로 유지
  - rooted enemy는 `velocity.x = 0`으로 묶이지만 AI와 공격/시전 경로는 계속 실행되도록 정리
  - `tests/test_enemy_base.gd`에 `root는 hard CC가 아님`, `rooted bomber도 시전 가능` 회귀 추가
  - `tests/test_spell_manager.gd`에 `plant_vine_snare`가 `brute`, `bomber`, `leaper`, `elite` 4개 적 아키타입에 대해 repeated root pulse, 재적용, deploy 유지 조건을 만족하는지 회귀 추가
  - `tests/test_enemy_base.gd`에는 `root는 hard CC가 아님`, `rooted bomber도 시전 가능`, `엘리트 root duration이 brute보다 짧음` 회귀를 추가
  - `docs/implementation/increments/combat_increment_02_spell_runtime.md`에 root 대표 설치형 기준과 현재 구현 상태를 동기화

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **`ice_glacial_dominion` slow 대표 검증을 4개 적 아키타입 + 행동 템포 기준으로 재정렬**
   - 현재는 `slow timer / multiplier` 중심
   - 다음 owner_core 증분은 `이동 속도 + 행동 템포`가 실제로 둘 다 늦어지는지 대표 적 기준으로 더 직접 닫는 일
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-01 (44차 세션 - Cycle 2)

#### `room_builder.gd` 파싱 blocker를 수습해 owner_core 검증 경로를 다시 복구함 (Cycle 2)

**완료 항목:**
- 현재 상태 요약:
  - Cycle 1의 `root` 런타임 보정 자체는 통과했지만, 공식 검증 단계에서 `scripts/world/room_builder.gd`가 PNG `preload`와 타입 추론 문제로 파싱 실패
  - 그 결과 수정 금지 파일인 `scripts/main/main.gd`까지 연쇄적으로 실패하며 `headless`와 `test_main_integration.gd`가 함께 무너졌음
- 런타임 보정:
  - `scripts/world/room_builder.gd`의 배경/타일 PNG 참조를 컴파일 타임 `preload` 대신 runtime texture load + cache 경로로 정리
  - `chunk_width`, `bottom_y`, `x` 등의 타입 추론 불안정 변수에 명시 타입을 부여
  - 결과적으로 `room_builder`가 headless와 GUT에서 다시 정상 파싱되고, `Main` 통합 테스트도 복구됨
- 검증 복구 결과:
  - `tests/test_room_builder.gd`가 다시 정상 수집/통과
  - `tests/test_main_integration.gd` 5건이 다시 통과
  - Cycle 1에서 추가한 `root`/`vine_snare` 회귀와 함께 전체 검증 경로가 다시 살아남

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `534/534` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **`ice_glacial_dominion` slow 대표 검증을 4개 적 아키타입 + 행동 템포 기준으로 재정렬**
   - 현재는 `slow timer / multiplier` 중심
   - 다음 owner_core 증분은 `이동 속도 + 행동 템포`가 실제로 둘 다 늦어지는지 대표 적 기준으로 더 직접 닫는 일
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-01 (45차 세션 - Cycle 1)

#### `장비 반영` 대표 검증 명세를 구현 가능한 수준으로 추가 구체화 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 설치형, 토글형, burst, hitstop 대표 명세는 많이 잠겼지만 `장비 반영`은 아직 일반 옵션 나열 수준이라 구현자가 바로 테스트로 옮기기 어려웠음
  - 특히 어떤 장비 세트, 어떤 스킬, 어떤 적/상황을 대표 검증 대상으로 볼지 부족했음
- 사용자 선택 기반으로 장비 반영 대표 명세를 문서에 추가 반영
- `combat_first_build_plan.md`에 아래 기준을 추가
  - 첫 검증 축은 `속성 특화 장비가 대표 스킬 화력과 운용을 즉시 바꾸는지`
  - 대표 장비 3빌드: `속성 특화`, `운용 특화`, `생존/자원`
  - 대표 스킬 3종: `fire_bolt`, `wind_gale_cutter`, `stone_spire`
  - 대표 상황 3종: `brute`, `leaper`, `elite`
  - 장비는 스킬/버프보다 앞서 빌드 정체성을 만들지 않고, 이번 단계에서는 수치 차이가 명확히 보이면 충분
  - 완료 기준은 `장착 즉시 실제 전투 결과 변화 + GUT 고정 가능`
- `combat_increment_05_equipment_minimum.md`에는 같은 기준을 구현/수용/테스트 체크포인트 수준으로 추가

**검증:**
- 문서 변경만 수행. 런타임/테스트 코드는 이번 사이클에서 수정하지 않음

#### 다음 우선 작업 (다음 세션 갱신)

1. **장비 반영 대표 GUT 추가**
   - `속성 특화 / 운용 특화 / 생존·자원` 3빌드 기준
   - `fire_bolt / wind_gale_cutter / stone_spire`
   - `brute / leaper / elite`
2. **`ice_glacial_dominion` slow 대표 검증을 4개 적 아키타입 + 행동 템포 기준으로 재정렬**
   - 현재는 `slow timer / multiplier` 중심
   - 다음 owner_core 증분은 `이동 속도 + 행동 템포`가 실제로 둘 다 늦어지는지 대표 적 기준으로 더 직접 닫는 일
3. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-01 (46차 세션 - Cycle 1)

#### `ice_glacial_dominion`을 slow 대표 토글로 고정하고 행동 템포 저하까지 실제 런타임/GUT에 반영함 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `ice_glacial_dominion`은 이미 `slow timer / movement multiplier` 기준으로는 대표 회귀가 있었지만, 문서가 요구한 `행동 템포까지 함께 저하`는 runtime에 직접 고정되지 않았음
  - 그 결과 `slow`가 실제로 적 접근 압박만 늦추는지, 아니면 공격/패턴 회전까지 느려지는지는 다음 리팩터링에서 다시 흔들릴 수 있는 상태였음
- 런타임/테스트 보정:
  - `scripts/enemies/enemy_base.gd`에 `get_behavior_tempo_multiplier()`, `get_behavior_delay_multiplier()`, `_tick_runtime_timers()`를 추가
  - `slow` 활성 중에는 이동 배수뿐 아니라 `attack_cooldown`, `rat_combo_timer`, `sword_retreat_timer`가 더 천천히 감소하도록 정리
  - `scripts/enemies/enemy_attack_profiles.gd`의 owner-owned delay helper도 적의 행동 템포 배율을 읽어 telegraph/action delay가 느려지도록 보정
  - `tests/test_enemy_base.gd`에 `slow`가 행동 템포 multiplier와 cooldown recovery를 실제로 늦추는지 검증 추가
  - `tests/test_spell_manager.gd`의 `ice_glacial_dominion` 대표 회귀를 확장해 `brute`, `bomber`, `leaper`, `elite` 4개 적 아키타입에 대해 `slow timer + movement multiplier + behavior tempo + cooldown recovery slowdown`을 함께 고정
  - `docs/implementation/increments/combat_increment_02_spell_runtime.md`에 `slow`가 이동 속도뿐 아니라 공격 쿨다운 회복과 telegraph/action delay까지 늦춘다는 구현 기준을 반영

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `535/535` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **장비 반영 대표 GUT 추가**
   - `속성 특화 / 운용 특화 / 생존·자원` 3빌드 기준
   - `fire_bolt / wind_gale_cutter / stone_spire`
   - `brute / leaper / elite`
   - 장착 즉시 전투 결과와 운용이 실제로 달라지는지 대표 회귀를 닫기
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-02 (47차 세션 - Cycle 1)

#### 장비 반영 대표 GUT를 `fire_burst / wind_tempo / earth_deploy` 기준으로 실제 런타임에 고정함 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `combat_increment_05_equipment_minimum.md`에는 대표 장비 3빌드와 `fire_bolt / wind_gale_cutter / stone_spire`, `brute / leaper / elite` 축이 문서화돼 있었지만, 실제 owner_core GUT는 아직 그 교차를 직접 닫지 못한 상태였음
  - 특히 초기 시도에서 `player.gd`를 씬 트리에 올리면 입력/노드 의존성이 섞여 테스트가 불안정해졌고, 대표 회귀는 실제 runtime 의미를 살리면서도 더 deterministic하게 정리할 필요가 있었음
- 런타임/테스트 보정:
  - `scripts/autoload/game_state.gd`
    - `wind_tempo` 프리셋 추가: `focus_gale_shard`, `ring_flux_band`, `accessory_split_lens`를 묶어 wind 운용/화력 대표 빌드로 고정
  - `tests/test_equipment_system.gd`
    - 장비 대표 검증용 helper 추가: `enemy`/`projectile` spawn helper, frame advance helper
    - `fire_burst -> fire_bolt -> brute`
      - 장착 전후 `payload.damage` 증가 + 실제 projectile hit path 피해 증가 회귀 추가
    - `wind_tempo -> wind_gale_cutter -> leaper`
      - 장착 시 추가 spread projectile 발생, primary projectile 속도 증가, wind 피해 증가, 실제 projectile hit path 정상 타격 회귀 추가
    - `earth_deploy -> earth_stone_spire -> elite`
      - 설치형 누적 타격 총합이 baseline보다 증가하는 회귀 추가
  - 테스트 안정화:
    - 장비 대표 GUT에서는 `player`를 씬 트리에 붙이지 않고 `spell_manager` payload 생성 전용으로만 사용
    - 실제 적 상호작용 검증은 deterministic한 projectile hit path와 누적 deploy tick 경로로 고정
  - `docs/implementation/increments/combat_increment_05_equipment_minimum.md`
    - 대표 장비 GUT가 실제로 통과한 상태와 다음 남은 장비 축(`생존/자원`)을 반영

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `538/538` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **`생존/자원` 대표 장비 GUT 추가**
   - `holy_guard` 또는 동급 빌드를 대표로 삼아 barrier / max_mp / regen / damage_taken 축을 실제 런타임 회귀로 고정
   - 장비 3빌드 문서 축 중 아직 덜 닫힌 `생존/자원` 대표 검증을 실제 owner_core GUT로 마무리
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-02 (48차 세션 - Cycle 1)

#### `생존/자원` 대표 장비 GUT를 `sanctum_sustain` 기준으로 실제 런타임에 고정함 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `fire_burst / wind_tempo / earth_deploy` 대표 회귀는 이미 닫혔지만, 문서상 3번째 축인 `생존/자원`은 아직 stat getter 수준 메모에 가까웠고 실제 전투 루프 회귀가 없었음
  - 기존 `holy_guard` 프리셋은 holy/guard 성향은 뚜렷했지만 `max_mp / mp_regen / damage_taken`을 한 장면에서 같이 닫기엔 덜 명확했음
- 런타임/테스트 보정:
  - `scripts/autoload/game_state.gd`
    - `sanctum_sustain` 프리셋 추가
    - 구성: `focus_storm_orb`, `armor_soul_weave`, `greaves_strider_boots`, `ring_copper_band`, `ring_sanctum_loop` 중심으로 `barrier + max_mp + regen + damage_taken` 축을 한 프리셋에 묶음
  - `tests/test_equipment_system.gd`
    - `Prismatic Guard` 대표 helper 추가
    - `sanctum_sustain` 적용 시 `Prismatic Guard` barrier 총량이 no-equipment baseline보다 커지고, 같은 대표 히트 뒤 남는 barrier가 더 많은지 회귀 추가
    - `sanctum_sustain` 적용 시 `max_mana`, 1초 기준 `mana_regen`, 직접 받는 피해가 실제 runtime 경로에서 개선되는지 회귀 추가
  - `docs/implementation/increments/combat_increment_05_equipment_minimum.md`
    - `생존/자원` 대표 빌드가 실제 GUT로 통과한 상태를 반영

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `540/540` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **장비 프리셋 간 역할 분리를 더 읽기 좋게 보강**
   - 현재 `sanctum_sustain`이 `생존/자원` 대표 축은 닫았지만, `holy_guard`와의 역할 차이는 아직 테스트 기준으로는 겹쳐 보일 수 있음
   - 다음 owner_core 증분은 `holy_guard`를 holy projectile/guard 혼합 대표 회귀로 따로 닫거나, 프리셋 수치 차등을 더 벌려 두 빌드의 역할을 명확히 가르는 것
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-02 (49차 세션 - Cycle 1)

#### `holy_guard`를 holy projectile/guard 혼합 대표 회귀로 실제 런타임에 고정함 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `sanctum_sustain`이 `생존/자원` 대표 축은 닫았지만, `holy_guard`와의 역할 차이는 아직 실제 runtime GUT 기준으로는 충분히 읽히지 않았음
  - 기존 `holy_guard`는 holy damage / barrier getter 수준 테스트만 있었고, `holy_radiant_burst`와 `Prismatic Guard`를 한 프리셋으로 묶는 대표 장면은 없었음
- 런타임/테스트 보정:
  - `scripts/autoload/game_state.gd`
    - `holy_guard` 프리셋 offhand를 `focus_swift_prism`으로 교체
    - holy projectile/guard 성향을 더 분명하게 하고, `sanctum_sustain`의 자원/생존 축과 역할을 분리
  - `tests/test_equipment_system.gd`
    - `holy_guard -> holy_radiant_burst -> brute`
      - 장착 전후 `payload.damage`, projectile speed, 실제 hit path 피해가 모두 증가하는 회귀 추가
    - `holy_guard -> Prismatic Guard`
      - barrier 총량이 `sanctum_sustain`보다 높아 guard-focused 역할이 실제로 드러나는지 회귀 추가
  - `docs/implementation/increments/combat_increment_05_equipment_minimum.md`
    - `holy_guard`를 실제 대표 장비 GUT 목록에 추가
    - `sanctum_sustain`은 sustain, `holy_guard`는 holy projectile + guard 출력이라는 역할 분리를 문서 기준으로 반영

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `542/542` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **`dark_shadow` 또는 `arcane_pulse` 대표 장비 GUT 추가**
   - 현재 `fire / wind / earth / sustain / holy_guard`까지 대표 장비 축이 닫혔고, 다음 작은 owner_core 증분은 dark 또는 arcane 축 중 하나를 실제 런타임 회귀로 추가하는 것
   - 추천 우선순위는 `dark_shadow -> dark_void_bolt`로 projectile school damage + dark build 정체성을 먼저 고정하는 것
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-02 (50차 세션 - Cycle 1)

#### `dark_shadow`를 dark projectile 대표 회귀로 실제 런타임에 고정함 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `holy_guard`까지는 대표 장비 회귀가 닫혔지만, dark 계열 프리셋은 아직 getter 수준 테스트와 단일 payload 증가 확인에 가까웠음
  - 다음 가장 작은 owner_core 증분은 `dark_shadow -> dark_void_bolt`를 실제 hit path까지 포함한 대표 장면으로 고정하는 것이었음
- 런타임/테스트 보정:
  - `tests/test_equipment_system.gd`
    - `dark_shadow -> dark_void_bolt -> brute`
      - 장착 전후 `payload.damage`, projectile speed, 실제 hit path 피해가 모두 증가하는 회귀 추가
    - 첫 시도에서는 `bomber` 기준으로 잡았지만, hit path 중 free timing과 겹쳐 비결정성이 생겨 `brute` 기준으로 정리해 안정화
  - `docs/implementation/increments/combat_increment_05_equipment_minimum.md`
    - `dark_shadow`를 대표 장비 GUT 목록에 추가
    - 다음 owner_core 장비 증분을 `arcane_pulse` 대표 회귀로 재정렬

**검증:**
- `godot --headless --path . --quit` 통과
- `godot --headless --path . --quit-after 120` 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `543/543` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **`arcane_pulse` 대표 장비 GUT 추가**
   - 현재 `fire / wind / earth / sustain / holy_guard / dark_shadow`까지 대표 장비 축이 닫혔고, 다음 작은 owner_core 증분은 `arcane_pulse -> arcane_force_pulse`를 실제 런타임 회귀로 추가하는 것
   - 추천 검증 축은 payload damage + projectile speed 또는 hit path 결과 중 하나를 deterministic하게 닫는 방식
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-02 (51차 세션 - Cycle 1)

#### `arcane_pulse`를 arcane projectile 대표 회귀로 실제 런타임에 고정함 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - `dark_shadow`까지는 대표 장비 회귀가 닫혔지만, arcane 계열 프리셋은 아직 getter 수준 테스트와 payload school 확인에 가까웠음
  - 다음 가장 작은 owner_core 증분은 `arcane_pulse -> arcane_force_pulse`를 실제 hit path까지 포함한 대표 장면으로 고정하는 것이었음
- 런타임/테스트 보정:
  - `tests/test_equipment_system.gd`
    - `arcane_pulse -> arcane_force_pulse -> brute`
      - 장착 전후 `payload.damage`가 증가하고, 실제 hit path 피해도 함께 증가하는 회귀 추가
    - arcane 장비에는 직접적인 projectile speed 옵션이 없으므로 이번 대표 검증은 damage + hit result 축으로 고정
  - `docs/implementation/increments/combat_increment_05_equipment_minimum.md`
    - `arcane_pulse`를 대표 장비 GUT 목록에 추가
    - 장비 커버리지 메모를 7개 대표 회귀 기준으로 갱신

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `544/544` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **장비 프리셋 후속 축 재선정**
   - 현재 `fire / wind / earth / sustain / holy_guard / dark_shadow / arcane_pulse`까지 대표 장비 축이 닫혔고, 다음 작은 owner_core 증분은 장비 이후의 빈 커버리지 행 또는 적/월드 쪽 안전 증분을 다시 고르는 것
   - 우선 후보는 enemy 데이터 유효성/드롭 경로 보강처럼 owner_core 소유 안에서 끝나는 검증성 증분
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-02 (52차 세션 - Cycle 1)

#### enemy 데이터 로더에 validation report를 추가해 적 카탈로그 안정성을 고정함 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - workstream의 다음 후보 중 가장 작은 안전 증분은 enemy 데이터 유효성/드롭 경로 보강이었음
  - `game_database.gd`는 필수 필드 누락만 `push_error`로 알렸고, duplicate `enemy_id`, 잘못된 `enemy_grade`, 잘못된 `drop_profile`을 구조적으로 보고하거나 테스트로 고정하지 못했음
- 런타임/테스트 보정:
  - `scripts/autoload/game_database.gd`
    - `enemy_validation_errors`, `VALID_ENEMY_GRADES`, `VALID_DROP_PROFILES` 추가
    - enemy load 시 duplicate `enemy_id`, invalid `enemy_grade`, invalid `drop_profile`를 validation report에 누적하도록 보강
    - `get_enemy_validation_errors()`, `has_enemy_validation_errors()` 공개 API 추가
  - `tests/test_game_state.gd`
    - `get_all_enemies()`가 duplicate copy를 반환하는지 회귀 추가
    - 현재 `enemies.json` 카탈로그가 validation report를 비운 상태인지 회귀 추가
    - validation error accessor가 내부 배열을 직접 노출하지 않는지 회귀 추가
  - `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`
    - enemy loader validation report 기준을 현재 구현 메모에 동기화

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `547/547` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **enemy 데이터 후속 검증 축 재선정**
   - 현재는 적 카탈로그 로더 안정성을 먼저 고정했으므로, 다음 작은 owner_core 증분은 drop profile 소비 경로나 enemy read-only summary처럼 같은 영역의 안전한 후속 API를 고르는 것
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-02 (52차 세션 - Cycle 2)

#### enemy spawn summary API를 추가해 GUI 친화적인 read-only 데이터 구조를 고정함 (Cycle 2)

**완료 항목:**
- 현재 상태 요약:
  - Cycle 1에서 적 카탈로그 validation report는 고정했지만, friend GUI나 관리자 읽기 전용 경로가 그대로 원본 enemy JSON 전체 구조를 직접 읽어야 하는 상태였음
  - 현재 우선순위 2의 “읽기 전용 데이터 구조 안정화”에 맞춰, 원본 스키마에 덜 의존하는 작은 summary API를 owner_core 쪽에서 먼저 제공하는 것이 가장 안전했음
- 런타임/테스트 보정:
  - `scripts/autoload/game_database.gd`
    - `get_enemy_spawn_entries()` 추가
    - 각 entry는 `enemy_id`, `display_name`, `enemy_grade`, `role`, `max_hp`, `drop_profile`, `has_super_armor_hint`만 노출하도록 정리
  - `tests/test_game_state.gd`
    - boss 요약이 grade/drop_profile/super armor hint를 정확히 드러내는지 회귀 추가
    - spawn summary accessor가 duplicate dictionaries를 반환해 소비자가 원본 catalog를 오염시키지 않는지 회귀 추가
  - `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`
    - enemy read-only summary API 기준을 현재 구현 메모에 동기화

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `549/549` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **enemy 데이터/드롭 후속 증분 재선정**
   - validation report와 spawn summary API까지 닫혔으므로, 다음 작은 owner_core 증분은 실제 drop consumption 회귀나 enemy/world 교차 검증처럼 한 단계 더 런타임 쪽으로 내려가는 작업을 고르는 것
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-02 (53차 세션 - Cycle 1)

#### enemy drop preview API를 추가해 read-only 드롭 규칙 소비 경로를 고정함 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - Cycle 2까지 enemy summary API는 있었지만, 드롭 규칙은 여전히 `DROP_CHANCE` / `DROP_RARITY_FILTER` 상수를 직접 읽어야만 의미를 해석할 수 있었음
  - `main.gd` 실제 드롭 소비 경로는 이번 역할 경계 밖이므로, owner_core 안에서 끝낼 수 있는 가장 작은 후속 증분은 drop preview read-only API를 노출하는 것이었음
- 런타임/테스트 보정:
  - `scripts/autoload/game_database.gd`
    - `get_drop_profile_preview(profile)` 추가
    - `get_enemy_spawn_entries()`에 `drop_chance`, `drop_rarity_preview`를 포함하도록 확장
  - `tests/test_game_state.gd`
    - boss spawn summary가 chance/pool preview를 함께 드러내는지 회귀 추가
    - spawn summary가 nested rarity preview array까지 duplicate로 반환하는지 회귀 추가
    - `get_drop_profile_preview("boss"|"none")`가 chance/filter를 정확히 노출하는지 회귀 추가
  - `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`
    - enemy drop preview read-only API 기준을 구현 문서에 동기화

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `550/550` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### room spawn → enemy catalog 교차 검증 report를 추가해 world/enemy 데이터 결합을 고정함 (Cycle 2)

**완료 항목:**
- 현재 상태 요약:
  - Cycle 1까지 enemy/drop read-only API는 닫혔지만, 다음 작은 후보였던 enemy/world 교차 검증은 아직 rooms의 `spawns[].type`가 실제 enemy catalog와 계속 맞물리는지 구조적으로 보고하지 못했음
  - `main.gd`/통합 런타임 경로를 직접 건드리지 않고 owner_core 안에서 끝낼 수 있는 가장 작은 후속 증분은 room spawn reference validation report를 로더에 추가하는 것이었음
- 런타임/테스트 보정:
  - `scripts/autoload/game_database.gd`
    - `room_spawn_validation_errors` backing store 추가
    - enemy catalog 로드 후 rooms의 `spawns[].type`가 실제 `enemy_id`를 참조하는지 검증하도록 보강
    - `get_room_spawn_validation_errors()`, `has_room_spawn_validation_errors()` 공개 API 추가
  - `tests/test_game_state.gd`
    - 현재 rooms catalog가 room spawn validation report를 비운 상태인지 회귀 추가
    - room spawn validation accessor가 내부 배열을 직접 노출하지 않는지 회귀 추가
  - `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`
    - rooms/enemy 교차 검증 report 기준을 구현 문서에 동기화

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `552/552` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **실제 drop consumption 회귀 또는 room 소비 경로 read-only API 재선정**
   - drop preview API와 rooms/enemy 교차 검증까지 닫혔으므로, 다음 작은 owner_core 증분은 실제 드롭 소비 결과를 owner_core 테스트로 우회 검증할지, rooms 쪽 read-only summary를 더 얹을지 다시 판단해야 함
   - 다만 `main.gd`/`test_main_integration.gd`는 현재 역할 경계 밖이라, 그 경로를 직접 건드리려면 우회 가능한 owner_core 범위 작업인지 먼저 확인 필요
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-02 (54차 세션 - Cycle 1)

#### room spawn summary API를 추가해 room 소비 경로의 read-only 구조를 고정함 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 53차 세션까지 enemy/drop read-only API와 rooms/enemy 교차 검증 report는 닫혔지만, room 소비자는 여전히 raw `rooms.json` 구조 전체를 직접 읽어야 했음
  - 다음 우선 작업 후보 중 owner_core 소유 파일 안에서 가장 작게 닫히는 실제 증분은 room spawn summary API를 제공하는 것이었음
- 런타임/테스트 보정:
  - `scripts/autoload/game_database.gd`
    - `get_room_spawn_summary(room_id)` 추가
    - `get_room_spawn_summaries()` 추가
    - 각 room summary는 `room_id`, `title`, `width`, `spawn_count`, `spawn_type_counts`, `has_rest_point`, `has_rope`, `has_core`를 노출하도록 정리
  - `tests/test_game_state.gd`
    - `arcane_core` room summary가 spawn count, boss count, rest/core/rope 힌트를 정확히 드러내는지 회귀 추가
    - unknown room id가 빈 summary를 반환하는지 회귀 추가
    - room summary accessor가 nested spawn count dictionary까지 duplicate로 반환하는지 회귀 추가
  - `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`
    - room read-only summary API 기준을 구현 문서에 동기화

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `555/555` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **실제 drop consumption 회귀 재선정**
   - enemy/drop/room read-only API 축은 일단 닫혔으므로, 다음 작은 owner_core 증분은 실제 drop consumption 결과를 owner_core 테스트로 우회 검증할 수 있는지 다시 판단해야 함
   - 다만 `main.gd`/`test_main_integration.gd`는 현재 역할 경계 밖이라, 통합 경로 직접 수정 없이 닫히는 회귀여야 함
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-02 (55차 세션 - Cycle 1)

#### deterministic drop resolver를 추가해 실제 드롭 소비 경로를 owner_core 회귀로 고정함 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 54차 세션까지 enemy/drop/room read-only API는 정리됐지만, 실제 drop consumption은 여전히 `get_drop_for_profile()`의 무작위 chance gate 때문에 deterministic한 owner_core 회귀가 부족했음
  - `main.gd` 통합 드롭 경로를 건드리지 않고 owner_core 안에서 닫을 수 있는 가장 작은 후속 증분은 deterministic drop resolver를 추가해 chance gate + weighted pick을 함께 고정하는 것이었음
- 런타임/테스트 보정:
  - `scripts/autoload/game_database.gd`
    - `resolve_drop_for_profile(profile, chance_roll, weighted_roll)` 추가
    - `get_drop_for_profile()`가 위 resolver를 통해 chance gate + weighted pick을 한 번에 지나가도록 정리
    - `get_weighted_drop_for_profile(profile, weighted_roll = -1)`로 forced roll 경로를 지원하도록 확장
  - `tests/test_equipment_system.gd`
    - boss profile에서 chance roll 실패 시 빈 문자열이 반환되는지 회귀 추가
    - chance roll 성공 시 `resolve_drop_for_profile()`가 weighted boss pool과 같은 결과를 쓰는지 회귀 추가
    - forced weighted roll이 wraparound 상황에서도 유효 rarity만 반환하는지 회귀 추가
  - `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`
    - deterministic drop resolver 기준을 구현 문서에 동기화

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `558/558` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **drop/room 후속 검증 축 재선정**
   - deterministic drop resolver까지 닫혔으므로, 다음 작은 owner_core 증분은 드롭 통계 분포 회귀처럼 더 넓은 검증을 볼지, 다시 전투 코어 다른 빈 축으로 이동할지 재선정해야 함
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-02 (56차 세션 - Cycle 1)

#### drop profile summary API를 추가해 드롭 소비 경로의 읽기 전용 통계 구조를 고정함 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 55차 세션까지 deterministic drop resolver는 생겼지만, 드롭 소비자나 QA 경로가 profile별 pool 규모와 rarity 분포를 보려면 여전히 raw 장비 카탈로그를 직접 순회해야 했음
  - 다음 작은 owner_core 증분으로는 `drop profile` 단위의 읽기 전용 통계 요약 API를 제공하는 것이 가장 안전했음
- 런타임/테스트 보정:
  - `scripts/autoload/game_database.gd`
    - `get_drop_profile_summary(profile)` 추가
    - `get_drop_profile_summaries()` 추가
    - 각 summary는 `profile`, `drop_chance`, `rarity_preview`, `pool_size`, `weighted_pool_size`, `rarity_counts`, `weighted_rarity_counts`를 노출하도록 정리
  - `tests/test_game_state.gd`
    - boss summary가 chance/pool size/weighted size/rarity count를 정확히 드러내는지 회귀 추가
    - unknown profile summary가 빈 count와 0 size를 반환하는지 회귀 추가
    - drop profile summaries accessor가 nested rarity count dictionary까지 duplicate로 반환하는지 회귀 추가
  - `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`
    - drop profile summary read-only API 기준을 구현 문서에 동기화

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `561/561` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **drop/room 후속 검증 축 재선정**
   - drop read-only summary까지 닫혔으므로, 다음 작은 owner_core 증분은 실제 분포 샘플링 회귀처럼 더 넓은 검증을 볼지, 다시 전투 코어의 다른 빈 축으로 이동할지 재선정해야 함
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

### 2026-04-02 (57차 세션 - Cycle 1)

#### room spawn enemy roster summary API를 추가해 room 소비 경로의 room/enemy join 부담을 줄임 (Cycle 1)

**완료 항목:**
- 현재 상태 요약:
  - 56차 세션까지 room summary와 enemy summary는 각각 있었지만, room 소비자나 GUI/read-only 경로가 `방별 어떤 적이 몇 마리 나오는지`를 읽으려면 여전히 raw `rooms.json`과 enemy catalog를 직접 join해야 했음
  - 이번 owner_core 증분에서는 같은 read-only 안정화 축 안에서 가장 작은 실제 진전으로, room별 spawn roster를 aggregated count + enemy/drop hint까지 묶은 summary API를 제공하는 것이 가장 안전했음
- 런타임/테스트 보정:
  - `scripts/autoload/game_database.gd`
    - `get_room_spawn_enemy_summaries(room_id)` 추가
    - helper가 room별 spawn roster를 first-seen order 기준으로 집계하고, `enemy_id/display_name/enemy_grade/role/count/max_hp/drop_profile/drop_chance/drop_rarity_preview/has_super_armor_hint`를 노출하도록 정리
  - `tests/test_game_state.gd`
    - `vault_sector` roster가 first-seen order를 보존하고, duplicate `mushroom` spawn을 `count = 2`로 집계하는지 회귀 추가
    - `arcane_core` boss roster가 grade/drop/super armor/drop rarity hint를 정확히 드러내는지 회귀 추가
    - unknown room이 빈 roster를 반환하는지, accessor가 nested rarity preview까지 duplicate로 반환하는지 회귀 추가
  - `docs/implementation/increments/combat_increment_04_enemy_combat_set.md`
    - room spawn enemy roster summary API 기준을 구현 문서에 동기화

**검증:**
- `godot --headless --path . --quit`: 통과
- `godot --headless --path . --quit-after 120`: 통과
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  - `564/564` 통과
  - 종료 시 `ObjectDB instances leaked at exit` warning은 계속 남음

#### 다음 우선 작업 (다음 세션 갱신)

1. **drop/room 후속 검증 축 재선정**
   - room spawn enemy roster summary까지 닫혔으므로, 다음 작은 owner_core 증분은 drop/room 축의 경계 검증을 더 볼지, 전투 코어의 다른 빈 축으로 이동할지 다시 판단해야 함
2. **`scripts/main/main.gd` timer leak blocker 정리 필요**
   - 현재 `create_timer()` 기반 async 경로가 종료 시 leak warning을 남김
   - 이번 owner_core 세션 수정 금지 범위라 직접 수정하지 않음

## 교차 의존 요청

### [2026-03-31] admin spawn 탭에 bat/worm 타입 추가 요청

- **이유:** `scripts/admin/admin_menu.gd`는 친구 소유 파일. bat과 worm이 `enemies.json`에 추가되었으나 admin spawn 탭의 소환 가능 타입 목록이 자동 갱신되는지 확인이 필요.
- **필요 입력:** admin_menu.gd에서 소환 타입 목록을 hardcode하고 있다면 "bat", "worm" 추가 필요.
- **예상 파일:** `scripts/admin/admin_menu.gd`
- **우선순위:** 낮음 (게임 진행은 가능, admin 편의성 문제)

### [2026-03-31] admin spawn 탭에 mushroom 타입 추가 요청

- **이유:** mushroom이 enemy_base.gd와 enemies.json에 독립 타입으로 추가되었으나 admin spawn 탭 소환 키 미할당.
- **필요 입력:** admin_menu.gd의 spawn 타입 목록과 키 바인딩에 "mushroom" 추가.
- **예상 파일:** `scripts/admin/admin_menu.gd`
- **우선순위:** 낮음 (게임 내 방 배치를 통해 소환 가능)

### [2026-03-31] admin spawn 탭에 5종 신규 몬스터 추가 요청

- **이유:** 6차 세션에서 rat, tooth_walker, eyeball, trash_monster, sword가 enemy_base.gd와 enemies.json에 추가되었으나 admin spawn 탭의 소환 가능 타입 목록에 없음.
- **필요 입력:** admin_menu.gd의 spawn 타입 목록에 다음 추가: "rat", "tooth_walker", "eyeball", "trash_monster", "sword"
- **예상 파일:** `scripts/admin/admin_menu.gd`
- **우선순위:** 낮음 (rooms.json에 spawn 배치로 인게임 등장 가능)
