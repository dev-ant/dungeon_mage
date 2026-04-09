---
title: 전투 2차 작업 체크리스트 - 스킬 런타임 구조
doc_type: plan
status: active
section: implementation
owner: runtime
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 전투 2차 작업 체크리스트 - 스킬 런타임 구조

상태: 사용 중  
최종 갱신: 2026-04-07  
섹션: 구현 기준

## 목표

이 문서는 [전투 우선 구현 계획](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md)의 두 번째 증분인 `스킬 런타임 구조 정리`를 Claude가 바로 구현할 수 있도록 쪼갠 작업 체크리스트다.

이번 증분의 핵심은 `문서와 JSON에 있는 스킬 정의를 실제 전투 슬롯과 시전 흐름에 연결하는 것`이다.

## 진행 상태

### 현재 완료

- [spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd) 추가
- 플레이어 시전 책임 일부를 `spell_manager`로 분리
- 기본 3개 전투 스킬의 쿨타임 시작과 재시전 제한을 매니저로 이동
- `Z/C/V + Q/R/F` 기준 6슬롯 1차 구조 추가
- 버프 3종을 `spell_manager`를 통해 같은 슬롯 흐름에서 시전 가능하게 정리
- HUD에 현재 핫바 요약 표시 추가
- 핫바 슬롯 구성을 `GameState` 저장 데이터로 분리
- 슬롯 교체 결과가 저장 구조에 반영되도록 연결
- 기본 시전 실패 이유를 메시지로 노출
- 설치형 스킬 1종 `Stone Spire` 런타임 편입
- 온앤오프 스킬 1종 `Grave Echo` 런타임 편입
- `Escape` 기반 관리자 메뉴 최소 버전 추가
- 관리자 메뉴에서 슬롯 선택, 스킬 교체, 프리셋 적용 가능
- 마나 자원 추가
- 마나 부족 시 시전 실패와 메시지 노출 추가
- 관리자 `무한 MP`, `쿨타임 무시` 플래그 추가
- 시전 피드백을 HUD 고정 영역에 노출
- 설치형/토글형 실험용 핫바 프리셋 추가
- 상위 토글형 `Glacial Dominion`, `Tempest Crown`, `Soul Dominion` 샌드박스 프리셋 추가
- 토글형 스킬의 지속 마나 소모와 마나 고갈 시 자동 해제 추가
- 토글형별 유지 마나 소모를 `skills.json` 데이터 기반으로 분기
- `spell_projectile.gd` 시각 분기 확장: `fire_bolt`, `volt_spear`, `frost_nova`, `ice_frost_needle`, `water_tidal_ring`가 `assets/effects/` 기반 AnimatedSprite2D 이펙트 사용
- `asset_sample/Effect/Free` 1차 분석 기준으로, 활성 스킬마다 `attack effect`와 `hit effect`를 별도 실루엣으로 배정하는 계획 수립
- `volt_spear`는 `attack_effect_id` / `hit_effect_id` payload와 one-shot sibling effect hook까지 실제 연결 완료
- `fire_bolt`는 `attack_effect_id` / `hit_effect_id` payload와 one-shot sibling effect hook까지 실제 연결 완료
- `holy_radiant_burst`는 `attack_effect_id` / `hit_effect_id` payload와 one-shot sibling effect hook까지 실제 연결 완료
- `water_aqua_bullet`는 `attack_effect_id` / `hit_effect_id` payload와 one-shot sibling effect hook까지 실제 연결 완료
- `wind_gale_cutter`는 `attack_effect_id` / `hit_effect_id` payload와 one-shot sibling effect hook까지 실제 연결 완료
- `earth_tremor`는 `attack_effect_id` / `hit_effect_id` payload와 one-shot sibling effect hook까지 실제 연결 완료
- `dark_void_bolt`는 `attack_effect_id` / `hit_effect_id` payload와 one-shot sibling effect hook까지 실제 연결 완료
- 2026-04-06 direct attach 1차 대상인 `dark_void_bolt`, `volt_spear`, `holy_radiant_burst` split frame 세트를 신규 에셋 기반 runtime tile로 실제 교체 완료
- `spell_manager.gd`의 buff cast path는 이제 `player.on_buff_activated(skill_id)` 훅을 호출하고, `player.gd`는 shared `holy_guard_activation` / `holy_guard_overlay` family를 로드해 owner 기준 activation/overlay visual을 처리한다
- `holy_mana_veil`, `holy_crystal_aegis`는 `skills.json`의 `buff_effects`에 `activation_visual_*`, `overlay_visual_*` authored stat을 직접 들고, 현재 runtime은 이 값을 읽어 buff visual을 조립한다
- `spell_manager` 관련 GUT 테스트 추가
- split effect payload와 one-shot world effect 매핑을 registry 형태로 정리
- 연결된 split effect가 다시 Free Preview 전체 시트로 돌아가지 않도록 64×64 cropped tile 회귀 테스트 추가
- split effect payload registry와 one-shot world effect registry가 서로 다른 id 집합으로 벌어지지 않도록 sync 회귀 테스트 추가
- 대표 단일 투사체(`fire_bolt`)와 대표 관통 투사체(`wind_gale_cutter`)가 근접/원거리/압박/엘리트 적 아키타입에 실제 명중 경로로 들어가는지 교차 검증 GUT 추가
- payload 기준 hitstop 정책을 명시적으로 추가
  - 설치형/토글형 tick은 `hitstop_mode = "none"`
  - `earth_tremor`, `frost_nova` 같은 순간 area burst는 `hitstop_mode = "area_burst"`
  - 기본 단일/관통 투사체는 `hitstop_mode = "default"`
- `spell_projectile.gd`가 payload의 `hitstop_mode`를 읽어 전역 time_scale 변경 여부를 분기하도록 정리
- GUT는 `stone_spire`, `glacial_dominion`, `earth_tremor` 대표 케이스의 hitstop 정책과 recovery를 회귀 검증
- `frost_nova`가 `area_burst` 대표 payload를 실제로 사용하고, `leaper` 압박 상황에서 짧은 hitstop, 즉시 AnimatedSprite2D burst visual, hit flash를 남기는지 GUT로 고정
- `player.gd`는 `area_burst` payload 시전에 한해 짧은 로컬 cast shake를 추가해 순간 광역 burst의 camera 반응을 플레이어 기준선으로 통일
- `frost_nova`는 `freeze` utility effect를 실제 payload에 싣고, `brute`, `bomber`, `leaper`, `elite` 4개 적 아키타입에 대해 damage / hitstop / burst visual / hit flash / freeze 적용을 GUT로 고정
- `plant_vine_snare`는 `root` 대표 설치형 제어기로 고정됐고, `brute`, `bomber`, `leaper`, `elite` 4개 적 아키타입에 대해 repeated root pulse, 재적용, deploy 유지, 엘리트 저항 차이를 GUT로 고정
- `enemy_base.gd`의 `root` 처리도 문서 기준선과 맞췄다.
  - `root`는 이제 이동만 봉인한다.
  - `stun` / `freeze`만 full hard CC로 행동을 끊는다.
  - 따라서 rooted enemy는 이동은 멈추지만 공격/시전은 계속 가능하다.
- `ice_glacial_dominion`의 `slow`도 문서 기준선과 더 가깝게 맞췄다.
  - `slow`는 이제 이동 속도만이 아니라 적의 행동 템포에도 직접 영향을 준다.
  - 적 `attack_cooldown` 회복과 owner-owned telegraph delay가 `slow_multiplier`에 따라 느려진다.
  - `brute`, `bomber`, `leaper`, `elite` 4개 적 아키타입에 대해 `slow timer + movement multiplier + behavior tempo`를 함께 GUT로 고정했다.
- 2026-04-07 후속으로 `4서클 이상 성장 체감` 보정을 런타임에 추가했다.
  - `game_state.gd`의 공용 runtime stat block이 `circle >= 4` 스킬에 한해 `range`, `size`, `duration`을 hit shape별로 추가 보정한다.
  - `circle/aura/wall/deploy` 계열은 큰 폭으로, `line/cone` 계열은 중간 폭으로, `projectile` 계열은 과하지 않게 늘린다.
  - `spell_projectile.gd`는 현재 반경 대비 비주얼 scale multiplier를 계산해 고서클 광역기가 충돌 반경만 커지고 화면 실루엣은 그대로 남는 문제를 막는다.
  - `tests/test_spell_manager.gd`에는 고서클 stationary/line/deploy 성장 검증과 terminal effect 재진입 safety 회귀를 추가했다.
- 같은 2026-04-07 후속으로 `큰 정지형 광역기/장판의 바닥 텔레그래프`도 런타임 기준으로 잠갔다.
  - `spell_projectile.gd`는 `radius >= 96` 이고 `정지형 burst 또는 persistent field`인 경우 절차적 `GroundTelegraph`를 자동 생성한다.
  - 텔레그래프는 실제 판정 반경과 같은 x축 반경을 쓰고, side-view 바닥 read를 위해 y축은 `0.42`로 눌린 타원형을 사용한다.
  - 시전 직후에는 `StartupRing`이 짧게 확장됐다가 빠져 `attack/startup warning`과 지속 본체 read를 분리한다.
  - persistent field는 inner ring를 하나 더 써서 tick zone이 유지형 장판이라는 점을 더 분명하게 보여준다.
  - 종료 시점에는 같은 조건의 큰 정지형 burst / field에 procedural `TerminalFlash`를 함께 얹어 `terminal burst`와 steady telegraph를 분리한다.
  - phase 대비는 school profile을 따른다.
    - `fire`, `lightning`, `wind`는 더 빠르고 더 크게 퍼지는 쪽으로 튜닝한다.
    - `ice`, `earth`, `dark`는 더 느리고 더 무겁거나 더 오래 남는 쪽으로 튜닝한다.
    - `holy`, `water`, `plant`, `arcane`는 중간군으로 두고 색감/두께만 school identity에 맞게 분기한다.
  - 일부 대표 고서클 광역기는 school profile 위에 spell signature override를 더 얹는다.
    - `fire_inferno_buster`는 더 압축되고 빠른 화염 압력 burst로 읽히게 한다.
    - `fire_solar_cataclysm`은 더 넓고 더 오래 남는 최종 solar collapse로 읽히게 한다.
    - `earth_gaia_break`는 중형 collapse, `earth_world_end_break`는 가장 무겁고 가장 넓은 final collapse로 읽히게 한다.
    - `holy_judgment_halo`는 `holy_bless_field`보다 더 빠르고 더 멀리 flare하는 verdict burst로 읽히게 한다.
    - `plant_genesis_arbor`는 `plant_worldroot_bastion`보다 더 두껍고 더 오래 남는 최종 canopy field로 읽히게 한다.
    - `ice_absolute_freeze`는 넓은 구속 burst, `ice_absolute_zero`는 더 느리고 더 깊게 잠기는 final frost collapse로 읽히게 한다.
    - 현재 signature override는 `spell_projectile.gd` 내부 source of truth로 유지하고, 새 대표 스킬이 생길 때만 좁게 추가한다.
  - `dark` school은 현재 runtime에 high-circle stationary burst / field 비교쌍이 부족하므로 같은 telegraph 레인에 억지 확장하지 않는다. 대신 toggle 레인에서 `player.gd`의 stage signature를 잠가 `dark_grave_echo`는 더 작고 탁한 mid-tier curse aura, `dark_soul_dominion`은 더 크고 밝은 final risk aura로 구분한다. 추가로 `dark_soul_dominion`은 종료 직후 `aftershock` pulse를 한 번 더 띄워 `toggle off`와 `여진 위험 구간`을 분리하고, `aftershock`가 끝날 때는 더 작고 차가운 `clear` beat를 한 번 더 띄워 위험 해제 감각을 닫는다.
  - moving projectile / moving line 계열은 stationary floor warning을 깔지 않고 기존 travel-body read를 유지한다.
  - `tests/test_spell_manager.gd`는 startup ring intro, terminal flash overlay, non-stationary 제외, fire-vs-ice startup profile, wind-vs-earth terminal profile, `inferno_buster-vs-solar_cataclysm`, `gaia_break-vs-world_end_break`, `bless_field-vs-judgment_halo`, `worldroot_bastion-vs-genesis_arbor`, `absolute_freeze-vs-absolute_zero`, `grave_echo-vs-soul_dominion` signature 비교, `soul_dominion aftershock pulse`, `aftershock clear beat` 회귀까지 포함한 전체 green 기준으로 다시 잠갔다.
  - 같은 날짜 follow-up으로 hotbar/toggle/feedback summary 기대값도 현재 한글 source of truth에 맞춰 정리했다. `사용 중`, `재사용:`, `[빈 슬롯]`, `MP 봉인`, `관통 x`, `활성/비활성화` 같은 localized runtime string이 이제 대표 회귀의 기준선이다.
  - 이 증분의 최종 검증 기준은 headless startup + `tests/test_spell_manager.gd 297/297`다.

### 현재 기준선 메모 (2026-04-01)

- `6슬롯 1차 구조`는 이 증분이 처음 정리되던 시점의 프로토타입 기준이다.
- 현재 빌드의 실제 핫바 기준선은 `10개 주문 + 3개 버프 = 총 13칸`이다.
- 이 문서는 `초기 6슬롯에서 출발해 현재 13칸 구조로 확장된 스킬 런타임`을 설명하는 문서로 해석한다.

### 아직 남은 작업

- 관리자 메뉴에 자원/몬스터/아이템 기능 확장
- 마나 회복 연출 또는 소비 피드백 강화
- 토글형 지속 피해/특수효과를 스킬별로 더 분기
- `Soul Dominion` 전용 리스크와 후유증은 별도 증분으로 분리
- 남은 액티브 스킬의 `attack effect` / `hit effect` payload 연결 확장
- 전투 커버리지 매트릭스의 설치형/토글형/가독성 행을 대표 스킬 기준으로 GUT 명세화

### 2026-04-06 신규 이펙트 direct attach 구현 결과

- 신규 에셋 기준 문서는 [skill_effect_asset_mapping_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/plans/skill_effect_asset_mapping_plan.md)다.
- 1차 direct attach는 아래 3개를 실제 runtime frame set 교체까지 완료했다.
  - `dark_abyss_gate -> dark_void_bolt`에 `Dark VFX 1-2`
  - `lightning_thunder_lance -> volt_spear`에 `Thunder Effect 01-02`
  - `holy_healing_pulse -> holy_radiant_burst`에 `PixelHolyEffectsPack01/Heal`, `HolyNova`
- `PixelHolyEffectsPack01/HolyShield`도 후속 검토 후보가 아니라 현재 runtime 훅으로 실제 연결 완료 상태다. `holy_mana_veil`, `holy_crystal_aegis`가 shared buff activation / owner aura family를 공용 사용한다.
- 회귀 기준은 `tests/test_spell_manager.gd`의 split effect registry/cropped tile 검증 + holy guard activation/overlay 검증 + 전체 GUT 통과다.
- 추가 follow-up으로 `Water Effect 2 -> water_aqua_bullet`, `Wind Effect 01 -> wind_gale_cutter` 저위험 refresh도 실제 연결했다. `water_aqua_bullet`는 `WaterBall` startup / projectile loop / impact family를, `wind_gale_cutter`는 좌우 반전된 `Wind Projectile` / `Wind Hit Effect` family를 사용한다.
- 후속 보완 연결로 `earth_stone_spire`, `fire_flame_arc`, `wind_cyclone_prison`도 실제 런타임 attach까지 닫혔다.
  - `earth_stone_spire`는 deploy payload가 `earth_stone_spire_attack` / `earth_stone_spire_hit` split effect를 싣고, 본체는 sampled `earth_stone_spire` visual을 사용한다.
  - `fire_flame_arc`는 `data/spells.json` runtime spell row를 추가해 실제 cast 경로를 열고, `Fire Effect 2` 16프레임 burst를 메인 visual로 사용한다.
  - `wind_cyclone_prison`는 `data/skills/skills.json` deploy row를 신규 추가했고, `pull_strength` payload + startup / loop / hit / terminal effect family를 함께 사용한다.
- 추가 follow-up으로 `ice_frost_needle` canonical/runtime 정리를 마치고, `data/spells.json`의 `ice_frost_needle` active row + `attack / projectile / hit` 3단 family를 실제 연결했다. 기본 ice hotbar는 이제 `ice_frost_needle`를 기준으로 읽고, `frost_nova`는 legacy freeze burst runtime으로 남긴다.
- 추가 follow-up으로 `water_tidal_ring` active row와 `Water Effect 01`의 startup ring / ring burst / splash hit family를 실제 연결했다. `Water Spike`는 쓰지 않고 신규 `water_aqua_geyser` 후보로 남긴다.
- 추가 follow-up으로 `ice_glacial_dominion` runtime proxy 위에 `Ice Effect 01 - VFX2`의 `activation / loop / end` toggle visual family를 실제 연결했다. canonical alias는 여전히 `ice_frozen_domain`다.
- 추가 follow-up으로 `holy_cure_ray`와 `holy_judgment_halo`도 실제 runtime row + effect family 연결까지 닫았다. `holy_cure_ray`는 `Heal` glyph + `Holy VFX 02` ray + `Holy VFX 01 Impact`, `holy_judgment_halo`는 `Smite` startup/hit + `SwordOfJustice` main + `HeavensFury` closing burst를 사용한다.
- 추가 follow-up으로 `earth_quake_break`도 runtime proxy `earth_tremor` 위에서 실제 visual refresh를 닫았다. startup은 `Earth Bump` 기반 centered crack 12프레임, hit는 `Impact` 7프레임 strip으로 교체해 `earth_stone_spire`의 솟구침 설치기 read와 분리했다.
- 추가 follow-up으로 `fire_inferno_sigil`도 `Fire Effect 2` linger 계열을 startup / loop / tick hit / terminal burst 4단 family로 실제 연결했고, 이후 실전 가독성 마감으로 tick cadence `2.4s`, brightness down, scale down 튜닝을 반영했다. deploy payload는 `terminal_effect_id = fire_inferno_sigil_end`까지 계약에 포함한다.
- practical validation follow-up으로 inferno 전용 회귀에 `hit flash duration < pulse gap`, `direct-hit 이후 다음 pulse 재개 시점`을 추가했고, 관리자 `deploy_lab` 프리셋에서도 즉시 반복 검증 가능하도록 열었다.
- 추가 follow-up으로 `water_aqua_bullet`, `wind_gale_cutter`는 split effect 유지 위에 projectile body AnimatedSprite2D visual까지 신규 에셋 기반으로 교체했다. 둘 다 역할은 그대로 유지하고 실루엣만 정제하는 저위험 refresh 원칙을 지켰다.
- 2026-04-07 후속으로 `ice_ice_wall`도 direct attach를 재개했다. 현재는 `earth_tremor` startup/hit family를 청색 계열로 재색상한 `ice_ice_wall_attack / ice_ice_wall / ice_ice_wall_hit / ice_ice_wall_end` temporary wall shell을 사용하고, deploy payload는 `attack_effect_id`, `hit_effect_id`, `terminal_effect_id`까지 실제 계약에 포함한다. 장벽 전용 원본은 후속 교체 대상이지만, runtime read와 GUT 회귀는 이제 이 temporary family 기준으로 잠근다.

## 현재 기준

- 스킬 데이터는 [skills.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/skills/skills.json)에 존재한다.
- 버프 조합 데이터는 [buff_combos.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/skills/buff_combos.json)에 존재한다.
- 데이터 로더는 [game_database.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd)에 있다.
- 스킬 성장과 버프 일부 런타임은 [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)에 이미 일부 연결되어 있다.
- 플레이어 시전 입력은 [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)에 분산되어 있으므로, 이번 작업에서는 시전 책임을 별도 매니저로 정리하는 것이 우선이다.

## 플레이 경험 목표

- 스킬을 누르면 즉시 발동한다.
- 슬롯별 스킬 교체가 쉬워야 한다.
- 마나 부족, 쿨타임, 시전 불가 상황이 명확하게 느껴져야 한다.
- 액티브, 버프, 설치, 온앤오프 스킬이 같은 런타임 체계 안에서 처리되어야 한다.
- 이후 관리자 메뉴에서 스킬 레벨과 슬롯을 즉시 바꿔도 구조가 흔들리지 않아야 한다.

## 이번 범위

### 포함

- 스킬 슬롯 기반 체계
- 스킬 데이터 로드와 슬롯 매핑
- 시전 가능 여부 판정
- 마나 차감
- 쿨타임 시작과 종료
- 액티브/버프/설치/온앤오프 타입 분기
- 공중 시전 허용
- 시전 실패 피드백
- 런타임 수치 계산
- 스킬 관련 GUT 테스트

### 제외

- 관리자 메뉴 슬롯 UI
- 장비 수치 최종 반영
- 적 AI 확장
- 신규 스킬 15종 전부의 완전한 연출 구현
- 보스 전용 스킬 로직

## Claude 작업 순서

1. 현재 [spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd)의 슬롯 구조와 split effect registry를 함께 읽는다.
2. 현재 저장 가능한 `skill_id` 장착 상태를 읽고, 관리자 메뉴가 바로 쓸 수 있는 API를 다듬는다.
3. 관리자 메뉴에 자원, 몬스터, 아이템 테스트 기능을 확장한다.
4. 설치/온앤오프 스킬을 빠르게 시험할 수 있는 샌드박스 프리셋을 보강한다.
5. 마나 회복, 마나 소비량, 무한 MP 상태를 전투 HUD에서 더 명확하게 보이게 한다.
6. `Soul Dominion` 전용 리스크는 [combat_increment_09_soul_dominion_risk.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_09_soul_dominion_risk.md) 기준으로 별도 진행한다.
7. GUT 테스트를 보강하고 헤드리스 검증을 다시 통과시킨다.

## 전투 커버리지 우선 구체화 (2026-04-01)

### 1. 설치형 대표 검증: `stone_spire`

- 설치형은 우선 `지속 누적 딜 장치`로 본다.
- 첫 검증 적은 `brute`로 고정한다.
- 구현/테스트 기준:
  - 생성 성공
  - 유지시간 후 자동 제거
  - 유지 중 범위 안 적에게 고정 간격 반복 타격
  - `brute`가 범위를 짧게 스쳐도 최소 1회 타격 보장
  - `brute`가 범위 안에 오래 머물면 누적 피해 총합 증가
  - `brute`, `bomber`, `elite`도 최소 1회 이상 정상 타격
  - 장비/버프 반영 우선순위는 `tick damage` 증가
  - 생성 순간 effect와 지속 타격 effect가 분리되어 읽힘

### 2. 토글형 대표 검증: `ice_glacial_dominion`

- 토글형은 우선 `유틸/상태이상 오라`로 본다.
- 첫 검증 적은 `leaper`로 고정한다.
- 첫 검증 상황은 `카이팅 중 적 접근 둔화`로 둔다.
- 구현/테스트 기준:
  - 유지 마나 tick 감소
  - 다음 tick 유지 비용을 낼 수 없으면 즉시 자동 해제
  - 활성 중 `slow` utility effect 적용
  - `slow`는 이동 속도와 행동 템포를 둘 다 낮추는 방향으로 읽힘
  - `slow`는 적 `attack_cooldown` 회복과 telegraph/action delay도 함께 늦춰야 한다.
  - 해제 후 신규 `slow` 적용 중단
  - `leaper`가 파고드는 상황에서 접근 템포 둔화 확인
  - `brute`, `bomber`, `leaper`, `elite` 전부에 반응 확인
  - 켜짐/꺼짐 순간과 유지 중 적 피드백이 분리되어 읽힘

### 2-1. 상태이상 시스템 v1 대표 검증 세트

- 대표 스킬은 아래 3개로 고정한다.
  - `ice_glacial_dominion`
  - `plant_vine_snare`
  - `frost_nova`
- 첫 검증 적은 `leaper`로 고정한다.
- 첫 검증 상황은 `leaper`가 파고드는 압박을 끊고 후속 연계를 여는 장면이다.
- 상태이상 시스템 v1의 핵심 역할은 `직접 딜 보조`보다 `공간 통제와 접근 차단`이다.

#### v1에서 완전 연결할 상태이상

- `slow`
- `root`
- `freeze`

#### 후속 증분으로 미루는 상태이상

- `shock`
- `burn`
- `poison`
- `silence`

이번 증분에서는 위 4종의 `데이터 필드`, `저항`, `적용 확률`, `지속시간`, `타이머 저장`까지만 고정한다.

#### 공통 운용 규칙

- `slow`
  - 이동 속도와 공격 준비/행동 템포를 함께 늦춘다.
  - 핵심 체감은 `카이팅 시간 확보`와 `접근 압박 지연`이다.
- `root`
  - 이동만 봉인한다.
  - 공격과 시전은 허용한다.
  - 설치형 제어기와 위치 선점의 가치를 읽히게 하는 것이 핵심이다.
  - `plant_vine_snare`는 대표 설치형으로서 opening pulse 이후 반복 pulse로 root를 다시 건다.
  - 엘리트는 같은 pulse를 맞아도 일반 적보다 root 지속시간이 짧아야 한다.
- `freeze`
  - 짧은 완전 정지와 다음 피해 연계 창을 연다.
  - 순간 burst 이후의 후속 공격이 자연스럽게 이어져야 한다.

#### 같은 상태이상 재적용 규칙

- `더 강한 수치 우선`
- `지속시간 갱신`

#### 1차 완료 기준

- `ice_glacial_dominion`, `plant_vine_snare`, `frost_nova`가 각자 `slow`, `root`, `freeze` 대표 스킬로 고정된다.
- 첫 실제 회귀는 `leaper` 기준으로 닫는다.
- 이후 `brute`, `bomber`, `elite`까지 확대한다.
- 대표 3스킬 x 4적 아키타입 기준으로 적용, 저항, 재적용, 엘리트 차이가 GUT로 고정된다.

### 3. hitstop 정책 기준선

- 기본 철학:
  - 지속형 비투사체 스킬은 전역 전투 템포를 끊지 않는다.
  - 대신 `결정적인 순간`에만 강한 hitstop을 준다.
- 대표 검증 스킬:
  - 설치형: `stone_spire`
  - 토글형: `ice_glacial_dominion`
  - 순간 area burst: `frost_nova`
- 기본 단일/관통 투사체는 `default` hitstop 정책을 사용한다.
- 설치형 지속 pulse는 `sparse_tick` 규칙을 사용한다.
  - 첫 적중 또는 충분한 간격이 지난 tick에만 아주 짧은 hitstop을 허용한다.
  - 나머지 tick은 hitstop 없이 누적 딜과 이펙트로 읽힌다.
- 토글 오라 tick은 `none` hitstop 정책을 사용한다.
  - 반복 tick이 전역 timescale을 흔들지 않아야 한다.
  - 읽히는 제어감은 `slow`와 적 피드백에서 확보한다.
- 순간 area burst는 `area_burst` hitstop 정책을 사용한다.
  - 기본 단일 투사체보다 더 강한 짧은 hitstop을 허용한다.
  - effect와 camera 반응이 함께 붙되, 전투 루프 전체를 끊을 정도로 길어지면 안 된다.
- 우선 검증 상황:
  - `leaper`가 플레이어에게 파고드는 압박 상황에서 세 대표 스킬의 hitstop 체감을 먼저 비교한다.
- 1차 GUT 완료 기준:
  - `stone_spire`, `ice_glacial_dominion`, `frost_nova`가 4개 적 아키타입 기준으로 hitstop mode, effect, camera 반응까지 함께 검증된다.

### 4. 순간 area burst 대표 검증: `frost_nova`

- 순간 area burst는 우선 `상태이상 시동 burst`로 본다.
- 첫 검증 적은 `leaper`로 고정한다.
- 첫 검증 상황은 `다수 적 광역 정리`, 그중에서도 `leaper` 압박을 끊는 장면으로 둔다.
- 구현/테스트 기준:
  - payload가 `hitstop_mode = "area_burst"`를 명시한다.
  - payload가 `freeze` utility effect를 명시한다.
  - burst damage가 4개 적 아키타입에 모두 정상 적용된다.
  - 단일 투사체보다 강하지만 매우 짧은 hitstop이 발생한다.
  - 짧은 근거리 burst shake 1회가 함께 발생한다.
  - 짧은 `freeze` 또는 그에 준하는 완전 정지로 접근을 끊고 후속 연계 창을 연다.
  - cast seed와 bloom이 시각적으로 분리되어 읽힌다.
  - 첫 실제 회귀는 `leaper` 압박 상황에서 `hitstop + 즉시 burst visual + hit flash + local cast shake + freeze 적용`을 함께 확인한다.
  - `leaper` 우선 + `brute`, `bomber`, `elite`까지 damage / hitstop / effect / camera 반응과 freeze 적용이 확인된다.

### 5. split effect 가독성 공통 기준

- `attack effect`는 플레이어 몸/손 근처에서 시작한다.
- `hit effect`는 적 피격 지점 중심에서 시작한다.
- 기본 one-shot 프레임은 `6~8프레임`
- 기본 프레임 크기는 `64x64` cropped tile
- school별 색감 방향:
  - fire: orange/red
  - ice: cyan/blue
  - lightning: yellow/white
  - holy: gold/white
  - dark: purple/black
  - earth: brown/orange
  - wind: pale green/white
  - water: blue/cyan
  - arcane: magenta/blue-white

## 슬롯 구조

### 현재 빌드 기준 슬롯

| 슬롯 | 기본 키 | 역할 |
| --- | --- | --- |
| 1 | `Z` | fire 액티브 |
| 2 | `C` | ice 액티브 |
| 3 | `V` | lightning 액티브 |
| 4 | `U` | water 액티브 |
| 5 | `I` | wind 액티브 |
| 6 | `P` | plant 설치 |
| 7 | `O` | earth 액티브 |
| 8 | `K` | holy 액티브 |
| 9 | `L` | dark 액티브 |
| 10 | `M` | arcane 액티브 |
| 11 | `Q` | 버프 |
| 12 | `R` | 버프 |
| 13 | `F` | 버프 |

### 요구사항

- 모든 슬롯은 `skill_id` 기반으로 관리한다.
- 스킬 장착 상태는 저장 가능한 구조여야 한다.
- 슬롯 비어 있음 상태를 허용한다.
- 이후 관리자 메뉴에서 즉시 교체 가능해야 한다.
- 문서의 오래된 `6슬롯` 표현은 초기 프로토타입 설명으로만 남기고, 현재 기준선은 13칸으로 통일한다.

## 런타임 책임 분리

### Player

- 입력 수집
- 이동/상태 처리
- 시전 요청 전달

### SpellManager

- 슬롯 관리
- 시전 가능 여부 판단
- 마나/쿨타임 처리
- 스킬 타입 분기
- 런타임 인스턴스 생성

### GameState

- 스킬 레벨
- 숙련도
- 버프 상태
- 자원 상태
- 최종 계산용 전역 보정

### GameDatabase

- JSON 로드
- 스킬 원본 데이터 제공

## 스킬 타입 처리 기준

### 액티브

- 투사체 또는 근접 판정 생성
- 방향은 플레이어 바라보는 방향 기준
- 마법 공격력, 스킬 레벨, 마스터리 보정을 반영
- 추가 연출 규칙: 플레이어 몸 근처에서 재생되는 `attack effect`와 몬스터 피격점에서 재생되는 `hit effect`를 별도 payload 또는 후속 effect hook으로 분리

### 버프

- `GameState.active_buffs`에 등록
- 지속시간 시작
- 중첩과 중복 허용 규칙 반영
- 조합 재계산 호출

### 설치

- 월드에 오브젝트 생성
- 유지시간 후 자동 제거
- 설치 수 제한이 필요하면 스킬별 옵션으로 처리

### 온앤오프

- 누르면 켜지고 다시 누르면 꺼짐
- 유지 중 마나 소모는 스킬 데이터의 `sustain_mana_*` 필드로 분기
- 마나가 바닥나면 자동 해제됨

### 패시브

- 이번 증분에서는 직접 시전 대상이 아님
- 계산식에서 최종 보정으로만 반영

## 시전 가능 조건

다음 조건을 모두 만족해야 한다.

- 슬롯에 스킬이 장착되어 있음
- 플레이어가 `Dead` 상태가 아님
- 플레이어가 강제 경직 또는 불가 상태가 아님
- 마나가 충분함
- 쿨타임이 없음
- 특정 스킬이 공중 불가라면 지상에 있음

## 수치 계산 기준

기본 방향은 기존 문서를 따른다.

- 피해: `마법 공격력 x 스킬 계수 + 고정 가산`
- 최종 보정: 마스터리, 버프, 장비, 조합 효과
- 마나: 스킬 레벨과 패시브/버프 보정 적용
- 쿨타임: 스킬 레벨과 패시브/버프 보정 적용

이번 증분에서는 아래까지 연결하면 충분하다.

- 스킬 레벨이 오르면 기본 피해 상승
- 스킬 레벨이 오르면 마나 소모 감소
- 스킬 레벨이 오르면 쿨타임 감소
- 해당 속성 마스터리가 최종 배수로 붙음

## 예상 구현 파일

- [game_database.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd)
- [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)
- [spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd)
- 기존 [spell_projectile.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_projectile.gd)
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)
- [test_spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_spell_manager.gd)
- 필요 시 [test_game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_state.gd) 확장

## Free Effect 1차 배정안

### 분석 기준

- 분석 소스: `asset_sample/Effect/Free/Part 1` ~ `Part 15`의 Preview GIF와 각 Part의 12개 PNG 세트
- 해석 규칙:
  - `attack effect`: 플레이어 손/몸 근처에서 짧게 터지는 cast start 이펙트
  - `hit effect`: 적 피격 지점에 짧게 남는 impact/shatter 이펙트
  - Free 원본은 주황 계열이 많으므로, 실제 런타임에서는 스킬 school에 맞춰 tint/modulate를 분리 적용
- 세트 표기:
  - `set1` = 각 Part의 첫 4장
  - `set2` = 각 Part의 중간 4장
  - `set3` = 각 Part의 마지막 4장

### 관찰 메모

- `Part 2 set1`은 전방으로 휘두르는 짧은 gust/slash 실루엣이라 시전 모션과 잘 붙는다.
- `Part 4 set3`은 분기형 번개/균열 형태라 hit effect에 적합하다.
- `Part 10 set1`은 바닥 융기와 기둥형 motion이 보여서 지면계 cast start에 맞다.
- `Part 11 set2`는 직선으로 길게 뻗는 lance/streak 계열이라 spear형 발사 시작점에 읽기 좋다.
- `Part 14 set2`는 halo, 원형 sigil, radial flare가 분리돼 holy/arcane cast start 후보로 읽힌다.

### 스킬별 1차 계획

| 스킬 | attack effect 계획 | hit effect 계획 | 분석 근거 |
| --- | --- | --- | --- |
| `fire_bolt` | `Part 1 set2` (`13~16.png`) | `Part 9 set1` (`426~429.png`) | `Part 1 set2`는 짧은 반월형 muzzle flare, `Part 9 set1`은 작고 빠른 화염 pop이라 단발 화염구에 맞음 |
| `frost_nova` | `Part 12 set1` (`566~569.png`) | `Part 4 set2` (`184~187.png`) | 초승 파편형 cast seed + 원형 bloom hit 조합이 냉기 burst 시작/피격에 읽기 좋음 |
| `volt_spear` | `Part 11 set2` (`516~519.png`) | `Part 4 set3` (`194~197.png`) | 직선 lance streak와 분기형 shock web 조합이 번개 관통창의 시전/명중을 분리해 줌 |
| `water_aqua_bullet` | `Part 10 set2` (`474~477.png`) | `Part 1 set3` (`23~26.png`) | 압축된 물방울 launch와 원형 ripple burst가 물 탄환의 출수/착탄으로 읽힘 |
| `wind_gale_cutter` | `Part 2 set1` (`62~65.png`) | `Part 3 set1` (`113~116.png`) | 전방 slash gust + 흩어지는 shard fan이 바람 칼날의 발사/절단 히트에 적합 |
| `earth_tremor` | `Part 10 set1` (`464~467.png`) | `Part 2 set2` (`69~72.png`) | 지면 융기 cast와 돌/파편이 터지는 원형 hit가 지진계 타격과 잘 맞음 |
| `holy_radiant_burst` | `Part 14 set2` (`662~665.png`) | `Part 6 set1` (`273~276.png`) | halo/sigil cast와 star flash hit가 holy burst의 정제된 시전감에 적합 |
| `dark_void_bolt` | `Part 9 set3` (`446~449.png`) | `Part 13 set3` (`632~635.png`) | 조준성 있는 crescent/mark cast와 void cloud 계열 hit가 dark school과 잘 맞음 |
| `arcane_force_pulse` | `Part 4 set1` (`174~177.png`) | `Part 2 set3` (`76~79.png`) | 회전 sigil cast와 작은 vortex/arcane pop hit가 arcane pulse의 시작/충돌을 분리함 |

### 구현 메모

- 1차 구현 범위는 현재 액티브 projectile 계열 9종에 한정한다.
- `buff`, `toggle`, `deploy`는 이 표를 그대로 재사용하지 않고, 별도 `cast circle`, `aura`, `expire burst` 분류로 나눈 뒤 후속 증분에서 배정한다.
- `toggle`, `deploy`의 1차 대표 검증 스킬은 각각 `ice_glacial_dominion`, `stone_spire`로 고정한다.
- 런타임에서는 `spell_projectile.gd`의 현재 sampled effect builder 패턴을 확장해 `attack_effect_id`, `hit_effect_id`를 분리하는 방향을 우선 고려한다.
- 2026-04-01 기준 첫 실제 연결 스킬은 `volt_spear`다.
  - `attack effect`: `Part 11/517.png`의 단일 white row sequence를 64×64로 잘라 `assets/effects/volt_spear_attack/volt_spear_attack_0~7.png`로 저장
  - `hit effect`: `Part 4/194.png`의 단일 white row sequence를 64×64로 잘라 `assets/effects/volt_spear_hit/volt_spear_hit_0~7.png`로 저장
  - 런타임 구조: `spell_manager.gd`가 payload에 `attack_effect_id:"volt_spear_attack"`, `hit_effect_id:"volt_spear_hit"`를 싣고, `spell_projectile.gd`가 생성 시 몸쪽 one-shot cast effect, 명중 시 impact effect를 sibling sprite로 재생
  - 중요한 보정: 큰 Free 통합 시트를 그대로 1프레임처럼 재생하지 않고, 단일 sequence만 crop한 64×64 프레임만 사용
  - 로더 보강: Free 원본 PNG는 import 유무와 무관하게 headless/GUT에서 읽히도록 raw PNG fallback 로더를 사용
- 2026-04-01 기준 두 번째 실제 연결 스킬은 `fire_bolt`다.
  - `attack effect`: `Part 1/13.png`의 단일 white row sequence(row 5, col 1~8)를 64×64로 잘라 `assets/effects/fire_bolt_attack/fire_bolt_attack_0~7.png`로 저장
  - `hit effect`: `Part 9/426.png`의 단일 white row sequence(row 5, col 1~8)를 64×64로 잘라 `assets/effects/fire_bolt_hit/fire_bolt_hit_0~7.png`로 저장
  - 런타임 구조: `spell_manager.gd`가 payload에 `attack_effect_id:"fire_bolt_attack"`, `hit_effect_id:"fire_bolt_hit"`를 싣고, `spell_projectile.gd`가 생성 시 몸쪽 one-shot cast effect, 명중 시 impact effect를 sibling sprite로 재생
  - 중요한 보정: 기존 `fire_bolt` fly loop는 유지하고, cast/hit만 통합 시트가 아니라 단일 sequence crop 64×64 프레임으로 분리한다
- 2026-04-01 기준 세 번째 실제 연결 스킬은 `holy_radiant_burst`다.
  - `attack effect`: `Part 14/662.png`의 단일 white row sequence(row 5, col 1~8)를 64×64로 잘라 `assets/effects/holy_radiant_burst_attack/holy_radiant_burst_attack_0~7.png`로 저장
  - `hit effect`: `Part 6/273.png`의 단일 white row sequence(row 5, col 0~7)를 64×64로 잘라 `assets/effects/holy_radiant_burst_hit/holy_radiant_burst_hit_0~7.png`로 저장
  - 런타임 구조: `spell_manager.gd`가 payload에 `attack_effect_id:"holy_radiant_burst_attack"`, `hit_effect_id:"holy_radiant_burst_hit"`를 싣고, `spell_projectile.gd`가 생성 시 몸쪽 one-shot cast effect, 명중 시 impact effect를 sibling sprite로 재생
  - 중요한 보정: fly 본체는 기존 holy projectile 판정을 유지하고, cast/hit만 통합 시트가 아니라 단일 sequence crop 64×64 프레임으로 분리한다
- 2026-04-01 기준 네 번째 실제 연결 스킬은 `water_aqua_bullet`다.
  - `attack effect`: `Part 10/474.png`의 단일 white row sequence(row 5, col 2~9)를 64×64로 잘라 `assets/effects/water_aqua_bullet_attack/water_aqua_bullet_attack_0~7.png`로 저장
  - `hit effect`: `Part 1/23.png`의 단일 white row sequence(row 5, col 2~9)를 64×64로 잘라 `assets/effects/water_aqua_bullet_hit/water_aqua_bullet_hit_0~7.png`로 저장
  - 런타임 구조: `spell_manager.gd`가 payload에 `attack_effect_id:"water_aqua_bullet_attack"`, `hit_effect_id:"water_aqua_bullet_hit"`를 싣고, `spell_projectile.gd`가 생성 시 몸쪽 one-shot cast effect, 명중 시 impact effect를 sibling sprite로 재생
  - 중요한 보정: water projectile 본체는 기존 payload를 유지하고, cast/hit만 통합 시트가 아니라 단일 sequence crop 64×64 프레임으로 분리한다
- 2026-04-01 기준 다섯 번째 실제 연결 스킬은 `wind_gale_cutter`다.
  - `attack effect`: `Part 2/62.png`의 단일 white row sequence(row 5, col 0~7)를 64×64로 잘라 `assets/effects/wind_gale_cutter_attack/wind_gale_cutter_attack_0~7.png`로 저장
  - `hit effect`: `Part 3/113.png`의 단일 white row sequence(row 5, col 1~8)를 64×64로 잘라 `assets/effects/wind_gale_cutter_hit/wind_gale_cutter_hit_0~7.png`로 저장
  - 런타임 구조: `spell_manager.gd`가 payload에 `attack_effect_id:"wind_gale_cutter_attack"`, `hit_effect_id:"wind_gale_cutter_hit"`를 싣고, `spell_projectile.gd`가 생성 시 몸쪽 one-shot cast effect, 명중 시 impact effect를 sibling sprite로 재생
  - 중요한 보정: wind projectile 본체는 기존 payload를 유지하고, cast/hit만 통합 시트가 아니라 단일 sequence crop 64×64 프레임으로 분리한다
- 2026-04-01 기준 여섯 번째 실제 연결 스킬은 `earth_tremor`다.
  - `attack effect`: `Part 10/464.png`의 단일 white row sequence(row 5, col 1~8)를 64×64로 잘라 `assets/effects/earth_tremor_attack/earth_tremor_attack_0~7.png`로 저장
  - `hit effect`: `Part 2/69.png`의 단일 white row sequence(row 5, col 0~7)를 64×64로 잘라 `assets/effects/earth_tremor_hit/earth_tremor_hit_0~7.png`로 저장
  - 런타임 구조: `spell_manager.gd`가 payload에 `attack_effect_id:"earth_tremor_attack"`, `hit_effect_id:"earth_tremor_hit"`를 싣고, `spell_projectile.gd`가 생성 시 몸쪽 one-shot cast effect, 명중 시 impact effect를 sibling sprite로 재생
  - 중요한 보정: earth projectile 본체는 기존 payload를 유지하고, cast/hit만 통합 시트가 아니라 단일 sequence crop 64×64 프레임으로 분리한다
- 2026-04-01 기준 일곱 번째 실제 연결 스킬은 `dark_void_bolt`다.
  - `attack effect`: `Part 9/446.png`의 단일 white row sequence(row 5, col 1~8)를 64×64로 잘라 `assets/effects/dark_void_bolt_attack/dark_void_bolt_attack_0~7.png`로 저장
  - `hit effect`: `Part 13/632.png`의 단일 white row sequence(row 5, col 0~7)를 64×64로 잘라 `assets/effects/dark_void_bolt_hit/dark_void_bolt_hit_0~7.png`로 저장
  - 런타임 구조: `spell_manager.gd`가 payload에 `attack_effect_id:"dark_void_bolt_attack"`, `hit_effect_id:"dark_void_bolt_hit"`를 싣고, `spell_projectile.gd`가 생성 시 몸쪽 one-shot cast effect, 명중 시 impact effect를 sibling sprite로 재생
  - 중요한 보정: dark projectile 본체는 기존 payload를 유지하고, cast/hit만 통합 시트가 아니라 단일 sequence crop 64×64 프레임으로 분리한다

## 세부 작업 체크리스트

### 1. 슬롯 데이터 정리

- 기본 장착 슬롯 6개 정의
- `skill_id` 기반 저장 구조 확정
- 빈 슬롯 처리

### 2. 시전 매니저 생성

- 입력과 시전 책임 분리
- `request_cast(slot_index)` 형태의 인터페이스 제공
- 실패 시 원인 반환

### 3. 마나와 쿨타임 처리

- 시전 성공 시 마나 차감
- 시전 성공 시 쿨타임 시작
- 쿨타임 남은 시간 조회 가능

### 4. 타입별 실행

- 액티브는 투사체 또는 판정 생성
- 버프는 `GameState` 반영
- 설치는 월드 오브젝트 생성
- 온앤오프는 토글

### 5. UI 연결

- 슬롯별 쿨타임 표시용 데이터 제공
- 마나 부족 피드백 제공
- 슬롯 이름과 키 라벨 연동

### 6. 성장 수치 연결

- 스킬 레벨 반영
- 마스터리 최종 배수 반영
- 속성별 기본 계산 함수 확정

## 수용 기준

- 플레이어가 6개 슬롯 스킬을 시전할 수 있다.
- 마나 부족, 쿨타임, 상태 제한으로 시전 실패가 구분된다.
- 버프 스킬과 액티브 스킬이 같은 슬롯 구조 안에서 공존한다.
- 런타임 계산이 현재 문서 기준과 크게 어긋나지 않는다.
- 관리자 메뉴 없이도 기본 슬롯만으로 전투 테스트가 가능하다.

## 테스트 체크포인트

### GUT

- 슬롯 장착/해제
- 마나 부족 시 시전 실패
- 쿨타임 중 재시전 실패
- 관리자 쿨타임 무시 시 재시전 가능
- 스킬 레벨에 따른 피해/마나/쿨타임 변화
- 버프형 스킬 시전 시 활성 버프 등록
- 설치형 스킬 시전 시 노드 생성

### 헤드리스

- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

## 비목표

- 모든 스킬의 전용 시각효과 완성
- 장비 UI
- 관리자 슬롯 편집 UI
- 보스 패턴용 특수 스킬 처리

## 다음 증분

이 작업이 끝나면 다음은 `버프 중심 액션 루프 구축`이다. 그때는 중첩, 조합, 서클 기반 슬롯 제한, 필살 버프 종료 페널티를 실제 전투 템포에 맞게 붙인다.

## Claude 바로 다음 작업

Claude는 다음 순서로 이어서 작업하면 된다.

1. 관리자 메뉴에 무한 HP/MP, 쿨타임 리셋 같은 자원 테스트 기능을 추가한다.
2. 관리자 메뉴에 적 소환 또는 슬롯 프리셋 기능을 더 붙인다.
3. 시전 실패 이유를 HUD나 관리자 패널에서 읽을 수 있는 형태로 고정 표시한다.
4. 그다음 버프 중심 액션 루프 문서에 맞춰 조합과 핫바가 자연스럽게 이어지도록 정리한다.
