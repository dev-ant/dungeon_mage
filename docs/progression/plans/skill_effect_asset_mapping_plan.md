---
title: 신규 스킬 이펙트 에셋 매핑 계획
doc_type: plan
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_02_spell_runtime.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 신규 스킬 이펙트 에셋 매핑 계획

상태: 사용 중  
최종 갱신: 2026-04-07  
섹션: 성장 시스템

## 목적

이 문서는 `asset_sample/Effect/new`에 추가된 신규 스킬 이펙트를 현재 `Dungeon Mage` 스킬 기획과 연결하는 실행 계획이다.

이번 라운드의 목표는 세 가지다.

- 기존 기획 스킬에 자연스럽게 붙는 에셋은 바로 적용 대상으로 잠근다.
- 기존 스킬과 맞지만 연출/판정/가독성 보완이 필요한 경우는 보완안까지 함께 남긴다.
- 기존 스킬과 억지로 맞지 않는 에셋은 현재 클래스 구조를 해치지 않는 신규 스킬 후보로 분리한다.

## 검토 범위와 판단 기준

- 검토 범위는 `asset_sample/Effect/new`의 압축 해제된 실제 에셋만 포함한다.
- `zip`, `rar` 파일은 이번 계획에서 제외한다.
- 판단은 파일명만이 아니라 폴더 구조, 프레임 흐름, 시트 구성, 반복 루프 여부, 시작/종료 구간 분리 여부를 함께 본다.
- 1순위 기준은 `기존 기획 스킬에 자연스럽게 붙는가`다.
- 읽기 어려운 화려함, 역할이 불분명한 대형 실루엣, 현재 스킬 역할과 충돌하는 근접/검술성 연출은 우선 제외한다.

## 현재 런타임 연결 제약

- 가장 빠른 연결 경로는 `spell_projectile.gd`가 이미 지원하는 `attack effect` / `hit effect` 분리 payload와 one-shot world effect 경로다.
- 현재 build에서 즉시 체감이 큰 축은 `dark_void_bolt`, `volt_spear`, `holy_radiant_burst` 같은 proxy-active 계열이다.
- 버프, 토글, 설치형 필드 계열은 `projectile split`만으로 해결되지 않으므로 공용 `activation burst`, `owner aura`, `loop field` 훅이 추가로 필요하다.
- 따라서 이번 문서는 `즉시 적용`, `기획 보완 후 적용`, `신규 스킬 기획`, `우선 보류`를 분리해 남긴다.

## 2026-04-06 실행 결과

- `dark_abyss_gate -> dark_void_bolt`, `lightning_thunder_lance -> volt_spear`, `holy_healing_pulse -> holy_radiant_burst`의 1차 direct attach는 실제 runtime frame 교체와 회귀 검증까지 완료했다.
- `PixelHolyEffectsPack01/HolyShield`는 후보 상태를 넘어서 현재 runtime의 shared buff activation / owner overlay 훅으로 실제 연결됐다. `holy_mana_veil`, `holy_crystal_aegis`는 shared holy guard family를 계속 사용하고, `holy_dawn_oath`는 2026-04-09 follow-up으로 copied-strip 기반 `holy_dawn_oath_activation`, `holy_dawn_oath_overlay` dedicated final-guard family로 승격했다.
- `Water Effect 2 -> water_aqua_bullet`, `Wind Effect 01 -> wind_gale_cutter`도 후속 저위험 refresh까지 실제 연결 완료했다. 둘 다 split effect 유지 위에 projectile body AnimatedSprite2D family를 추가해 기존 역할을 바꾸지 않고 실루엣만 정제했다.
- `Earth Effect 01`, `Fire Effect 2`, `Wind Effect 02`는 아래 보완안 기준으로 실제 연결까지 마쳤고, 다음 증분은 `Holy VFX 01-02`, `Ice Effect`, `Water Effect 01` 계열 보완으로 넘긴다.
- 2026-04-07 후속으로 큰 정지형 burst / field는 개별 authored sprite만 믿지 않고 `spell_projectile.gd`의 절차적 `GroundTelegraph`도 함께 사용한다. 현재 source of truth는 `radius >= 96`, `정지형 burst 또는 persistent field`일 때 바닥 타원형 telegraph를 자동 생성하고, startup에는 `StartupRing`, 종료에는 `TerminalFlash`를 겹쳐 단계 대비를 분리하는 것이다. 추가로 school profile도 잠갔다. `fire/lightning/wind`는 더 빠르고 날카롭게, `ice/earth/dark`는 더 무겁고 오래, `holy/water/plant/arcane`는 중간군으로 색감과 폭만 차등화한다. 그 위에 대표 고서클은 `spell signature override`를 더 얹는다. 현재 잠긴 케이스는 `fire_inferno_buster`, `fire_solar_cataclysm`, `earth_gaia_break`, `earth_world_end_break`, `holy_judgment_halo`, `plant_genesis_arbor`, `ice_absolute_freeze`, `ice_absolute_zero`다. `dark`는 현재 high-circle stationary 비교쌍이 부족해 telegraph 레인은 보류하고, 대신 toggle 레인에서 `dark_grave_echo`와 `dark_soul_dominion`의 stage signature를 분리했고, `dark_soul_dominion`은 종료 직후 `aftershock` pulse를 한 번 더 사용한다.

## 즉시 적용 우선 조합

### 1차 direct attach 완료 기준

| 우선순위 | 에셋군 | 우선 대상 스킬 | 현재 runtime anchor | 적용 방식 | 판단 근거 | 구현 메모 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `Dark VFX 1-2` | `dark_abyss_gate` | `dark_void_bolt` | 투사체 + hit collapse 교체 | 흑구체와 붕괴 burst 실루엣이 현재 흑마법 burst proxy와 가장 가깝다 | 2026-04-06 증분에서 projectile / hit runtime frame 세트를 실제 교체했다. 실제 pull telegraph는 후속 분리 |
| 2 | `Thunder Effect 01-02` | `lightning_thunder_lance` | `volt_spear` | 직선 랜스 + impact 교체 | 관통 burst read가 명확하고 보스 대응 단일 burst 축과 맞다 | 2026-04-06 증분에서 직선 랜스 + impact runtime frame 세트를 실제 교체했다. hit linger는 짧게 유지한다 |
| 3 | `PixelHolyEffectsPack01/Heal`, `HolyNova` | `holy_healing_pulse` | `holy_radiant_burst` | cast activation + heal burst 교체 | 회복 계열임이 즉시 읽히고 백마법 정체성과 맞는다 | 2026-04-06 증분에서 `holy_radiant_burst_attack/hit` runtime frame 세트를 실제 교체했다. 회복 숫자/표식 보강은 후속 UI 연동으로 남긴다 |
| 4 | `PixelHolyEffectsPack01/HolyShield` | `holy_crystal_aegis` | 현재 runtime에서는 `holy_mana_veil`에 동일 family 확장 적용 가능. `holy_dawn_oath`는 copied-strip 기반 dedicated final-guard family로 승격했다 | buff activation + owner overlay | 보호막/방어 read가 가장 선명하다 | 2026-04-06 증분에서 shared buff activation / owner overlay 훅을 열었고, 2026-04-09 follow-up으로 `holy_dawn_oath_activation`, `holy_dawn_oath_overlay` dedicated family까지 분기했다 |

### 저위험 visual refresh 완료

| 에셋군 | 대상 스킬 | 현재 runtime anchor | 판단 |
| --- | --- | --- | --- |
| `Water Effect 2` | `water_bullet` | `water_aqua_bullet` | `WaterBall - Startup and Infinite`, `WaterBall - Impact`를 써서 startup 8프레임, projectile loop 18프레임, hit 15프레임 family로 실제 교체했다. 기존 역할은 유지하고 loop read만 정제한 저위험 refresh다 |
| `Wind Effect 01` | `wind_cutter` | `wind_gale_cutter` | `Wind Projectile`, `Wind Hit Effect` 2프레임 family를 좌우 반전 기준으로 실제 교체했다. cutter/hit puff 조합을 더 짧고 선명한 실루엣으로 정리했다 |

### 즉시 적용 완료 메모

1. `dark_abyss_gate -> dark_void_bolt`, `lightning_thunder_lance -> volt_spear`, `holy_healing_pulse -> holy_radiant_burst` split effect 교체를 실제 runtime asset 기준으로 완료했다.
2. shared buff activation hook 1건을 확장해 `HolyShield` 계열을 `holy_mana_veil`, `holy_crystal_aegis` family에 공용 적용했고, `holy_dawn_oath`는 copied-strip 기반 dedicated final-guard family로 분기했다.
3. 같은 fallback buff 계획의 ritual 확장으로 `dark_throne_of_ash`도 `Free/Part 14` activation + `Free/Part 13` orbit 조합을 `dark_throne_activation`, `dark_throne_overlay` family로 실제 연결했다. 2026-04-09 follow-up에서는 copied-strip 기준 checked-in `assets/effects/dark_throne_activation`, `assets/effects/dark_throne_overlay` 전용 디렉터리로 승격해 verified visual source를 분리했다.
4. 같은 fallback buff 계획의 lightning 확장으로 `lightning_conductive_surge`도 `Free/Part 14` activation + `Free/Part 13` orbit 조합을 `conductive_surge_activation`, `conductive_surge_overlay` family로 실제 연결했다. 2026-04-09 follow-up에서는 copied-strip 기준 checked-in `assets/effects/conductive_surge_activation`, `assets/effects/conductive_surge_overlay` 전용 디렉터리로 승격해 verified visual source를 분리했다.
5. 같은 fallback buff 계획의 plant 확장으로 `plant_verdant_overflow`도 `Free/Part 14` activation + `Free/Part 13` orbit 조합을 `verdant_overflow_activation`, `verdant_overflow_overlay` family로 실제 연결했다. 2026-04-09 follow-up에서는 copied-strip 기준 checked-in `assets/effects/verdant_overflow_activation`, `assets/effects/verdant_overflow_overlay` 전용 디렉터리로 승격해 verified visual source를 분리했다.
6. 같은 fallback buff 계획의 dark 확장으로 `dark_grave_pact`도 `Free/Part 14` activation + `Free/Part 13` orbit 조합을 `grave_pact_activation`, `grave_pact_overlay` family로 실제 연결했다. 2026-04-09 follow-up에서는 copied-strip 기준 checked-in `assets/effects/grave_pact_activation`, `assets/effects/grave_pact_overlay` 전용 디렉터리로 승격해 verified visual source를 분리했다.
7. 같은 fallback wind 확장으로 `wind_tempest_drive`도 `Free/Part 14` activation family를 active startup visual로 실제 연결했고, activation 순간 중거리 전방 mobility burst와 소형 activation burst payload까지 함께 붙였다. 2026-04-07 사용자 결정 반영 후 current source of truth는 `spells.json`의 `wind_tempest_drive` activation burst row와 `skills.json.wind_tempest_drive` active metadata + dash direct field다. persistent overlay와 buff slot semantics는 current runtime에서 제거했고, `Overclock Circuit`는 active-combo 재설계 전까지 pending으로 돌렸다.
8. 같은 fallback buff 계획의 fire / ice / arcane 후속 확장으로 `fire_pyre_heart`, `ice_frostblood_ward`, `arcane_astral_compression`, `arcane_world_hourglass`도 `Free/Part 14` activation + `Free/Part 13` orbit 조합을 school tint별 `pyre_heart_*`, `frostblood_ward_*`, `astral_compression_*`, `world_hourglass_*` family로 실제 연결했다. 2026-04-09 follow-up으로 네 row 모두 copied-strip checked-in `assets/effects/pyre_heart_*`, `assets/effects/frostblood_ward_*`, `assets/effects/astral_compression_*`, `assets/effects/world_hourglass_*` 전용 디렉터리로 승격해 verified visual source를 분리했다.
9. 이번 후속 잠금 기준에서 버프 overlay 위계는 `일반 offense/utility < arcane tempo < defense ward < holy guard < dark ritual finisher`로 둔다. 따라서 `fire_pyre_heart < lightning_conductive_surge < arcane_astral_compression < dark_grave_pact < arcane_world_hourglass < ice_frostblood_ward < holy_mana_veil < holy_crystal_aegis < holy_dawn_oath < dark_throne_of_ash` 순서를 source of truth로 유지한다.
10. 회귀 기준은 split effect registry sync, 64x64 cropped tile, holy guard activation/overlay GUT, dark ritual activation/overlay GUT, dark pact activation/overlay GUT, lightning buff activation/overlay GUT, verdant buff activation/overlay GUT, tempest drive activation/overlay GUT, fire/ice/arcane buff activation/overlay GUT와 overlay priority GUT로 잠갔다.
11. `water_bullet`, `wind_cutter` visual refresh도 후속 턴에 실제 완료했다. 회귀 기준은 split effect frame count + projectile body AnimatedSprite2D asset load/좌우 반전 검증까지 포함한다.

## 기획 보완 후 적용안

| 대상 스킬 | 권장 에셋 | 보완안 | 리스크 / 주의점 |
| --- | --- | --- | --- |
| `ice_ice_wall` | `earth_tremor` blue variant | `earth_tremor_attack / hit` frame family를 청색 계열로 재색상해 `ice_ice_wall_attack / ice_ice_wall / ice_ice_wall_hit / ice_ice_wall_end` temporary wall shell로 먼저 연결한다. direct attach는 이 family 기준으로 재개하고, 이후 장벽 전용 원본으로 교체한다 | 현재는 냉기 장벽 전용 원본이 아니라 재색상 placeholder이므로, 장기적으로는 더 넓고 평평한 wall silhouette로 교체해야 한다 |

## 기존 `asset_sample/Effect` fallback 적용안

`img2img` 재생성 전까지는 `asset_sample/Effect/new`만이 아니라 기존 `Everything`, `Free`, `FXpack13`, `Fx_pack`도 임시 소스로 허용한다. 이 섹션의 목적은 `최종 아트 퀄리티`가 아니라 `역할 판독`, `테스트 가능 상태`, `스킬군별 family 잠금`이다.

### fallback 운용 원칙

- runtime 연결 전제는 `전용 완성본`이 아니라 `임시 read 확보`다.
- 색은 속성에 맞게 과감하게 보정한다. `hue shift`, `채도 -10%~-35%`, `명도 -15%~+12%`, `alpha 0.45~0.90` 범위 보정을 기본값으로 둔다.
- `loop` 성격 에셋은 alpha를 더 낮추고, `startup / hit / finisher`는 alpha와 brightness를 높여 역할을 분리한다.
- `holy`, `earth`처럼 공격 오독이 위험한 계열은 채도를 더 낮추고 밝기 대비로 읽히게 한다.
- `ice_ice_wall`처럼 실루엣이 어긋나는 스킬은 임시 적용은 허용하되, current tracker 상태는 `placeholder`로 유지하고 release-grade 원본 확보 전까지 `verified art`로 승격하지 않는다.
- 큰 정지형 burst / field는 fallback sprite 실루엣만으로 실제 판정 반경이 충분히 읽히지 않으면 procedural ground telegraph를 병행한다.
- current runtime lock:
  - `radius >= 96`
  - `velocity == Vector2.ZERO` 또는 `persistent field`
  - x축 반경은 실제 판정 반경과 동일
  - y축은 side-view 바닥 read를 위해 `0.42` 배율의 flattened ellipse
  - persistent field는 inner contour를 추가
  - moving projectile / line은 ground telegraph를 깔지 않는다

### 기존 팩별 임시 용도

| 기존 에셋군 | 실제로 읽히는 역할 | 권장 보정 |
| --- | --- | --- |
| `Everything/Classic`, `Alternative 1-3` | 소형 투사체, 직선 관통, 커터형 slash, 낙하 탄체 | 속성별 hue shift, `alpha 0.80~0.90`, `lightning`은 brightness `+8%`, `earth`는 saturation `-30%` |
| `FXpack13/Effect1-3`, `Fx_pack/1-3` | 화염구, 짧은 폭발, 발사체 hit, 낙하 폭발 코어 | `fire`는 거의 원색 유지, `dark`는 purple shift, `earth`는 sepia shift + saturation `-35%` |
| `Free/Part 1` | 원형 시길, field startup, heal ring, ritual gate | `loop alpha 0.45~0.60`, `activation alpha 0.85`, `holy`는 gold-white, `dark`는 violet, `ice`는 cyan-white |
| `Free/Part 4` | 눈송이/꽃문양형 sigil, freeze pulse, plant bless pulse | `ice`는 brightness `+10%`, `plant`는 saturation `-15%`, `holy`는 alpha를 낮춰 보조 pulse로만 사용 |
| `Free/Part 10` | 수직 화염기둥, 장판 tick flame, 메테오 잔불 | `loop alpha 0.50`, `terminal burst alpha 0.80`, scale은 `0.85~1.10` 범위만 허용 |
| `Free/Part 11` | 뿌리/서리 분출, 수직 상승 proc, 소환 시작점 | `plant`는 green-brown, `ice`는 cyan-white, `earth` 차용 시 brightness `-10%` |
| `Free/Part 12` | 짧은 파동, 소형 물결탄, chain hop, 수평 spray | `water`는 saturation `-10%`, `lightning` 차용 시 yellow-white shift, `alpha 0.70~0.85` |
| `Free/Part 13` | 궤도 링, 작은 orbit orb, vortex 보조 | `wind/dark/holy` aura 보조용으로만 사용, 단독 주연출 금지 |
| `Free/Part 14` | halo, radial burst, aura ring, telegraph | `holy` gold-white, `wind` mint, `lightning` yellow-white, `earth` amber-gray, `loop alpha 0.45`, `activation alpha 0.85` |
| `Free/Part 15` | cross shard, chain impact, finisher rune, 절단형 별무늬 | `lightning` chain node, `ice` freeze cross, `dark` ritual mark로 적합. `holy`는 finisher 한정 |

### 미구현 스킬 임시 매핑안

| 스킬 또는 스킬군 | 우선 fallback 에셋군 | 필요한 보정 | 임시 적용 메모 |
| --- | --- | --- | --- |
| `wind_arrow`, `wind_gust_bolt` | `Everything/Alternative 2`, `Everything/Classic` | green-mint hue, `alpha 0.88`, speed read를 위해 밝기 `+5%` | low-risk projectile family로 바로 묶기 좋다 |
| `earth_stone_shot`, `earth_rock_spear` | `Everything/Classic` projectile + `FXpack13/Effect3` hit | sepia shift, saturation `-35%`, brightness `-12%` | 돌창 느낌은 약하지만 대지 단일기 read는 확보 가능하다 |
| `holy_halo_touch` | `Free/Part 1`, `Free/Part 14` | gold-white, saturation `-20%`, `loop alpha 0.0`, `activation alpha 0.85` | 공격처럼 보이지 않게 ring + halo 위주로 쓴다 |
| `fire_flame_bullet` | `FXpack13/Effect1`, `Fx_pack/2` | fire 원색 유지, `alpha 0.90` | 연사형 화염탄 임시 family로 충분하다 |
| `water_aqua_spear`, `ice_spear` | `Everything/Alternative 2` projectile + `Free/Part 12` hit | cyan-blue hue, saturation `-10%`, brightness `+8%` | 관통 spear read를 임시로 확보할 수 있다 |
| `lightning_thunder_arrow` | `Everything/Classic` projectile + `Free/Part 15` hit | yellow-white, brightness `+10%`, `alpha 0.82` | 빠른 관통 + 감전 hit read가 가능하다 |
| `fire_burst`, `fire_inferno_buster` | `FXpack13/Effect2`, `Fx_pack/3` | fire 유지, scale `1.0~1.25`, brightness `-5%` | 현재는 `fire_inferno_buster_attack / fire_inferno_buster / fire_inferno_buster_hit` dedicated family와 `phase_signature = fire_inferno_buster`가 verified runtime source of truth다 |
| `wind_storm`, `wind_heavenly_storm` | `Everything` crescent slash + `Free/Part 14` radial | mint hue, `loop alpha 0.50`, `hit alpha 0.80` | 현재는 `wind_storm_attack / wind_storm / wind_storm_hit`, `wind_heavenly_storm_attack / wind_heavenly_storm / wind_heavenly_storm_hit` dedicated family와 각 phase signature가 runtime source of truth다 |
| `water_wave`, `water_tsunami`, `water_ocean_collapse` | `Free/Part 12` + `Free/Part 13` | cyan-blue, `alpha 0.70`, x-scale `1.2~1.6` | 수평 파동과 와류 보조는 가능하지만 최종 wave 볼륨은 부족하다 |
| `earth_gaia_break`, `earth_continental_crush`, `earth_world_end_break` | `Free/Part 14` + `FXpack13/Effect2` | amber-gray, saturation `-40%`, brightness `-10%` | 진짜 지면 파괴는 아니고 radial shock + dust burst로 임시 대체한다 |
| `fire_meteor_strike`, `fire_apocalypse_flame`, `fire_solar_cataclysm` | `Everything` projectile streak + `FXpack13/Effect2` + `Free/Part 10` | meteor/apocalypse/solar core를 orange-white에서 pale-gold까지 단계 분리한다 | 현재는 `fire_meteor_strike_*`, `fire_apocalypse_flame_*`, `fire_solar_cataclysm_*` dedicated family와 각 phase signature가 runtime source of truth다 |
| `fire_solar_cataclysm` | `Everything` projectile streak + `FXpack13/Effect2` + `Free/Part 10` | pale-gold core, brightness `+10%`, scale `fire_apocalypse_flame` 대비 `1.05~1.10` | `fire_apocalypse_flame`보다 더 큰 stationary burst와 strongest burn read를 placeholder로 확보했던 축은 verified solar collapse로 승격됐다 |
| `wind_heavenly_storm` | `Everything` crescent slash + `Free/Part 14` radial | mint-white, brightness `+8%`, scale `wind_storm` 대비 `1.15~1.20` | 현재는 checked-in `wind_heavenly_storm_attack / wind_heavenly_storm / wind_heavenly_storm_hit` family와 dedicated `phase_signature = wind_heavenly_storm`가 verified runtime source of truth다 |
| `fire_flame_storm`, `fire_hellfire_field` | `Free/Part 10` + `Free/Part 1` startup | flame loop `alpha 0.45~0.55`, startup ring `alpha 0.80` | 장판 위협 read를 빠르게 확보할 수 있다 |
| `ice_storm`, `ice_absolute_freeze`, `ice_absolute_zero` | `Free/Part 4`, `Free/Part 11`, `Free/Part 15` | cyan-white, brightness `+10%`, saturation `-15%` | 서리장/빙결 cross/수직 분출 조합으로 임시 CC read를 만든다 |
| `holy_bless_field`, `holy_sanctuary_of_reversal`, `holy_seraph_chorus` | `Free/Part 1` + `Free/Part 14` | gold-white, saturation `-25%`, `loop alpha 0.40~0.55` | 백마법 장판/오라 계열의 안전한 임시 family다 |
| `earth_fortress`, `wind_storm_zone`, `lightning_tempest_crown`, `dark_soul_dominion` | `Free/Part 14` + `Free/Part 13` | 속성별 hue shift, `owner aura alpha 0.45`, `pulse alpha 0.75` | 토글/오라 계열의 activation-loop-pulse를 빠르게 분리할 수 있다 |
| `lightning_bolt` | `Free/Part 12` chain hop + `Free/Part 15` impact | yellow-white, brightness `+12%`, `alpha 0.82` | 진짜 chain beam은 아니지만 hop + impact node로 연쇄 read를 임시 확보한다 |
| `fire_pyre_heart`, `ice_frostblood_ward`, `wind_tempest_drive`, `arcane_astral_compression`, `arcane_world_hourglass` | `Free/Part 14` activation + `Free/Part 13` orbit | school별 hue shift, `overlay alpha 0.40`, `activation alpha 0.85` | 버프/의식형 placeholder는 activation과 owner-follow overlay만 있어도 플레이 테스트가 가능하다 |
| `plant_root_bind`, `plant_world_root`, `plant_worldroot_bastion`, `plant_genesis_arbor` | `Free/Part 11` + `Free/Part 4` | green-brown, saturation `-10%`, brightness `-5%` | 뿌리 분출 + 식생 문양 조합으로 자연 계열 read를 확보한다 |
| `ice_ice_wall` | `earth_tremor` recolor | cyan-white, cold blue highlight, `loop fps 7`, `main scale 1.62`, `attack/hit/end`는 tremor family를 그대로 재색상 | 지금은 blue tremor wall shell로 runtime attach를 재개했다. release-grade wall art는 후속 교체 대상이지만, direct attach blocker는 해소됐다 |

### 실제 구현 우선순위

1. `projectile / line` family부터 묶는다. `Everything`과 `FXpack13`만으로 1~4서클 planned 액티브를 가장 많이 열 수 있다.
2. 그다음 `field / aura` family를 묶는다. `Free/Part 1`, `Part 10`, `Part 14` 조합으로 fire/holy/wind/lightning 계열을 빠르게 덮을 수 있다.
3. `plant`와 `ice`는 `Part 4`, `Part 11`, `Part 15`를 shared placeholder family로 먼저 잠근다.
4. `ice_ice_wall`은 임시 fallback을 이제 실제 runtime에 사용하지만, 새 장벽형 원본 확보 뒤 다시 교체하는 전제는 유지한다.

### `ice_ice_wall` 현재 잠금 기준

- `ice_ice_wall`은 `생성 -> 유지 -> 파괴` 3단 family를 `ice_ice_wall_attack / ice_ice_wall / ice_ice_wall_end`로 이미 갖췄고, contact burst는 `ice_ice_wall_hit`로 분리했다.
- 읽기 기준은 최소 `가로 2.2 플레이어 폭`, `세로 1.3 플레이어 높이`다.
- 생성 후 `0.20초` 안에 플레이어가 `벽이 솟아오른다`고 읽어야 하며, 원형 field나 수직 pillar로 오독되면 불합격이다.
- 양 끝단이 중심보다 먼저 사라지는 시트는 허용하지 않는다. edge silhouette가 끝까지 남아야 공간 차단 read가 유지된다.
- 현재 temporary family는 `earth_tremor` blue recolor, centered startup, `loop fps 7`, `scale 1.62`, terminal collapse를 하한선으로 삼는다.
- 위 조건을 만족하지 못하면 tracker 상태는 다시 `placeholder`로만 유지하고, 장벽 전용 원본 확보 전까지 art 검증 상태를 올리지 않는다.

### 2026-04-06 fallback projectile / line 1차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `wind_arrow`, `wind_gust_bolt` | `fallback_wind_attack`, `fallback_wind_projectile`, `fallback_wind_hit` | `Everything` 기반 placeholder 투사체 family를 shared spec으로 연결했고 좌우 반전 / split effect 회귀까지 잠갔다 | 최종 art 교체 시 speed read만 유지하면 된다 |
| `earth_stone_shot`, `earth_rock_spear` | `fallback_stone_attack`, `fallback_stone_projectile`, `fallback_stone_hit` | sepia stone placeholder family를 실제 active runtime에 연결했다 | `earth_rock_spear`의 방어 감소 디버프는 상태 계약 정리 뒤 붙인다 |
| `holy_halo_touch` | `fallback_holy_attack`, `fallback_holy_projectile`, `fallback_holy_hit` | halo 중심 placeholder family와 self-heal rider를 함께 연결해 solo runtime에서도 white starter read를 확보했다 | ally target heal contract가 생기면 self-heal rider를 재정리한다 |
| `fire_flame_bullet` | `fallback_fire_attack`, `fallback_fire_projectile`, `fallback_fire_hit` | `FXpack13/Effect1` + `Fx_pack/2` 조합을 64px runtime tile로 정규화해 실제 연결했다 | 최종 art 교체 전까지 alpha/brightness 미세 튜닝만 선택적으로 검토한다 |
| `water_aqua_spear` | `fallback_water_attack`, `fallback_water_line`, `fallback_water_hit` | water line placeholder family로 관통 spear read를 먼저 확보했다 | 진짜 spear silhouette는 최종 art 단계에서 보강한다 |
| `ice_spear` | `fallback_shard_attack`, `fallback_shard_projectile`, `fallback_shard_hit` | shard placeholder family를 연결했고 forced roll 회귀로 freeze utility를 잠갔다 | projectile silhouette를 더 길게 보이게 하는 최종 art 교체가 권장된다 |
| `lightning_thunder_arrow` | `fallback_wind_attack`, `fallback_wind_projectile`, `fallback_holy_hit` | 빠른 line body + 밝은 impact 조합으로 관통/감전 read를 먼저 확보했고 forced roll 회귀로 shock utility를 잠갔다 | chain/afterimage 성격은 lightning 전용 최종 art에서 보강한다 |

### 2026-04-06 fallback projectile / line 6차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `water_wave` | `water_wave_attack`, `water_wave`, `water_wave_hit` | 기존 `fallback_water_attack/line/hit` family를 그대로 재사용하되 scale과 color를 더 넓은 cyan control-wave로 재해석해 actual spell row와 실제 연결했다. moving line projectile + slow utility + split effect contract를 함께 잠갔다 | 진짜 wave crest와 수면 밀도는 최종 art 단계에서 보강해야 한다. 현재는 수평 crowd-control read를 먼저 확보한 placeholder 단계다 |

### 2026-04-06 fallback projectile / line 15차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `fire_apocalypse_flame` | `fire_apocalypse_flame_attack`, `fire_apocalypse_flame`, `fire_apocalypse_flame_hit`, `fire_apocalypse_flame_end` | 기존 fallback source를 copied seed로 삼되, 2026-04-10 follow-up에서 checked-in dedicated apocalypse family와 dedicated `phase_signature = fire_apocalypse_flame`를 실제 runtime source of truth로 승격했고, level scaling regression까지 함께 잠갔다 | 최종 art 단계에서는 meteor telegraph의 낙하감보다 “종말형 대폭발” read를 더 분명히 분리해 주는 편이 좋다 |

### 2026-04-06 fallback projectile / line 16차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `water_ocean_collapse` | `water_ocean_collapse_attack`, `water_ocean_collapse`, `water_ocean_collapse_hit`, `water_ocean_collapse_end` | 기존 `fallback_water_attack/line/hit` family를 더 넓은 ocean lane과 heavier vortex terminal로 재해석한 뒤, 2026-04-10 follow-up에서 checked-in dedicated ocean-collapse family와 level scaling regression까지 더해 verified runtime source of truth로 승격했다 | 최종 art 단계에서는 파고 높이와 후류 와류의 밀도를 더 분리해 “대해일 붕괴” read를 강화하는 편이 좋다 |

### 2026-04-06 fallback projectile / line 7차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `lightning_bolt` | `lightning_bolt_attack`, `lightning_bolt`, `lightning_bolt_hit` | 기존 `fallback_shard_attack/projectile/hit` family를 그대로 재사용하되 brightness와 scale을 더 밝은 yellow-white chain-control bolt로 재해석해 actual spell row와 실제 연결했다. moving line projectile + shock utility + split effect contract를 함께 잠갔다 | 진짜 chain hop와 타겟 간 arc 연결은 최종 art/runtime 단계에서 보강해야 한다. 현재는 high-pierce crowd-control read를 먼저 확보한 placeholder 단계다 |

### 2026-04-06 fallback projectile / line 8차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `ice_absolute_freeze` | `ice_absolute_freeze_attack`, `ice_absolute_freeze`, `ice_absolute_freeze_hit` | 2026-04-10 follow-up으로 checked-in dedicated freeze family 경로를 runtime source of truth로 승격했고, existing freeze phase signature 위에 level scaling + family path regression까지 함께 잠겼다 | 최종 art 단계에서는 절대영도 중심핵과 외곽 빙결 균열을 더 분리해야 한다 |

### 2026-04-06 fallback field / aura 2차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `fire_flame_storm` | `fire_flame_storm_attack`, `fire_flame_storm`, `fire_flame_storm_hit`, `fire_flame_storm_end` | `Free/Part 1` startup + `Free/Part 10` flame loop를 64px runtime tile로 정규화해 실제 deploy row와 split effect / terminal family까지 연결했고, 2026-04-09 follow-up에서는 copied-strip 기준 checked-in `assets/effects/fire_flame_storm_attack`, `assets/effects/fire_flame_storm`, `assets/effects/fire_flame_storm_hit`, `assets/effects/fire_flame_storm_end` 전용 디렉터리로 승격해 verified visual source를 분리했다 | 최종 art 교체 전까지는 장판 alpha만 실전 플레이 기준으로 소폭 조정하면 된다 |
| `holy_sanctuary_of_reversal` | `fallback_holy_field_attack`, `fallback_holy_field_loop`, `fallback_holy_field_hit`, `fallback_holy_field_end` | gold-white halo field family를 deploy runtime에 연결해 성역 read를 먼저 확보했다 | cleanse 전용 proc나 ally-target heal read는 최종 art/UI 단계에서 보강한다 |
| `fire_hellfire_field` | `fire_hellfire_field_attack`, `fire_hellfire_field`, `fire_hellfire_field_hit`, `fire_hellfire_field_end` | `fire_flame_storm`과 같은 flame source를 더 큰 scale/brightness 세팅으로 late-game hellfire field로 재해석해 실제 연결했고, 2026-04-09 follow-up에서는 copied-strip 기준 checked-in `assets/effects/fire_hellfire_field_attack`, `assets/effects/fire_hellfire_field`, `assets/effects/fire_hellfire_field_hit`, `assets/effects/fire_hellfire_field_end` 전용 디렉터리로 승격해 verified visual source를 분리했다 | 고서클 위협감은 최종 art 단계에서 더 차별화하는 편이 좋다 |
| `lightning_tempest_crown` | `tempest_crown_activation`, `tempest_crown_loop`, `tempest_crown_end` | `Free/Part 13`, `Part 14` 기반 owner-centered aura family를 toggle visual로 연결했고, activation/overlay/end 회귀까지 잠갔다. 2026-04-09 follow-up에서는 copied-strip 기준 checked-in `assets/effects/tempest_crown_activation`, `assets/effects/tempest_crown_loop`, `assets/effects/tempest_crown_end` 전용 디렉터리로 승격해 verified visual source를 분리했다 | 실제 chain lightning/낙뢰 전용 strike는 최종 art 단계에서 추가하는 편이 좋다 |
| `dark_soul_dominion` | `soul_dominion_activation`, `soul_dominion_loop`, `soul_dominion_end`, `soul_dominion_aftershock`, `soul_dominion_clear` | violet aura family를 toggle visual로 연결했고, 2026-04-07 후속 잠금으로 `dark_grave_echo`보다 더 큰 activation/overlay/end scale과 더 밝은 violet signature를 사용해 final risk aura로 읽히게 했다. 추가 후속으로 종료 직후 단발 `aftershock` pulse를 붙여 꺼짐과 여진 구간을 분리했고, 여진이 끝날 때는 더 작고 차가운 `clear` beat를 한 번 더 써서 위험 해제 감각까지 닫는다. 2026-04-09 follow-up에서는 copied-strip 기준 checked-in `assets/effects/soul_dominion_activation`, `assets/effects/soul_dominion_loop`, `assets/effects/soul_dominion_end`, `assets/effects/soul_dominion_aftershock`, `assets/effects/soul_dominion_clear` 전용 디렉터리로 승격해 verified visual source를 분리했다 | 지속형 여진 파문이나 카메라/월드 레이어 반응 연동은 후속 강화 여지가 있다 |
| `dark_grave_echo` | `grave_echo_activation`, `grave_echo_loop`, `grave_echo_end` | `Free/Part 13`, `Part 14` 기반 aura family를 muted violet curse aura로 재해석해 toggle visual로 연결했고, 2026-04-07 후속 잠금으로 `dark_soul_dominion`보다 더 작고 탁한 stage signature를 유지한다. 2026-04-09 follow-up에서는 copied-strip 기준 checked-in `assets/effects/grave_echo_activation`, `assets/effects/grave_echo_loop`, `assets/effects/grave_echo_end` 전용 디렉터리로 승격해 verified visual source를 분리했다 | 묘비/원혼 pulse나 저주 파문 위계는 최종 art 단계에서 분리하는 편이 좋다 |

### 2026-04-06 fallback field / aura 3차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `holy_bless_field` | `holy_bless_field_attack`, `holy_bless_field`, `holy_bless_field_hit`, `holy_bless_field_end` | dedicated blessing family를 deploy visual source로 승격했고, payload도 `self_heal + poise_bonus` owner-facing support field contract와 함께 잠갔다 | 완료. 이후 후속은 verified 이후 아트 리프레시가 필요할 때만 다룬다 |
| `wind_storm_zone` | `wind_storm_zone_activation`, `wind_storm_zone_loop`, `wind_storm_zone_end` | dedicated storm-zone family를 toggle visual source로 승격했고, 현재 payload는 `slow + pull_strength` control zone contract와 함께 실제 enemy-facing 제어 read를 제공한다 | 완료. 이후 후속은 verified 이후 아트 리프레시가 필요할 때만 다룬다 |
| `holy_seraph_chorus` | `holy_seraph_chorus_activation`, `holy_seraph_chorus_loop`, `holy_seraph_chorus_end` | dedicated chorus family를 toggle visual source로 승격했고, payload는 `damage + self_heal + poise_bonus` mixed holy aura contract와 함께 owner-heal/enemy-damage 동시 기여를 제공한다 | 완료. 이후 후속은 verified 이후 아트 리프레시가 필요할 때만 다룬다 |

### 2026-04-06 fallback field / aura 4차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `ice_storm` | `ice_storm_attack`, `ice_storm`, `ice_storm_hit`, `ice_storm_end` | 기존 `fallback_ice_field_*` family를 checked-in dedicated frost-storm family로 승격해 cyan-white 냉기 장판 read와 slow/freeze control contract를 실제 deploy runtime source of truth에 잠갔다 | 최종 art 단계에서는 분출과 장판 경계만 더 또렷하게 정리하면 된다 |
| `earth_fortress` | `earth_fortress_activation`, `earth_fortress_loop`, `earth_fortress_end` | `Free/Part 13/14` 기반 fortress family를 brown-earth tint로 재해석해 owner-following toggle visual source로 승격했고, payload도 `defense_multiplier + poise_bonus + status_resistance` pure guard contract와 함께 잠갔다 | 완료. 이후 후속은 verified 이후 아트 리프레시가 필요할 때만 다룬다 |
| `plant_vine_snare` | `plant_vine_snare_attack`, `plant_vine_snare`, `plant_vine_snare_hit`, `plant_vine_snare_end` | `fallback_plant_field_*` family를 early snare scale/tint로 재해석해 2서클 자연 설치기 read를 먼저 확보했다. 실제 deploy payload, split effect, terminal contract까지 runtime에 연결했다 | 최종 덩굴 속박 실루엣과 뿌리 성장 방향성은 art와 CC semantics가 들어올 때 재정리한다 |
| `plant_world_root` | `plant_world_root_attack`, `plant_world_root`, `plant_world_root_hit`, `plant_world_root_end` | 기존 `fallback_plant_field_*` family를 checked-in dedicated world-root family로 승격해 광역 root field read와 root control contract를 실제 deploy runtime source of truth에 잠갔다 | 거목/덩굴 볼륨은 최종 art 단계에서 더 크게 차별화하는 편이 좋다 |
| `plant_worldroot_bastion` | `plant_worldroot_bastion_attack`, `plant_worldroot_bastion`, `plant_worldroot_bastion_hit`, `plant_worldroot_bastion_end` | 기존 `fallback_plant_field_*` family를 checked-in dedicated bastion family로 승격해 `plant_world_root`와 `plant_genesis_arbor` 사이 scale/tint hierarchy, root control contract, deploy payload source of truth를 실제 runtime에 잠갔다 | 성채 기둥, 덩굴 보루 외곽, 방어 위계는 최종 art와 fortress semantics가 들어올 때 재정리한다 |
| `dark_shadow_bind` | `dark_shadow_bind_attack`, `dark_shadow_bind`, `dark_shadow_bind_hit`, `dark_shadow_bind_end` | 기존 `fallback_aura_activation/loop/end` family를 checked-in dedicated curse-field family로 승격해 3서클 흑마법 설치 디버프 read와 slow control contract를 실제 deploy runtime source of truth에 잠갔다 | 묘비, 영혼 파문, 바닥 저주문 위계는 최종 art와 debuff semantics가 들어올 때 재정리한다 |

### 2026-04-06 fallback field 5차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `plant_genesis_arbor` | `plant_genesis_arbor_attack`, `plant_genesis_arbor`, `plant_genesis_arbor_hit`, `plant_genesis_arbor_end` | 기존 `fallback_plant_field_*` family를 checked-in dedicated genesis family로 승격해 final canopy read, root control contract, `plant_worldroot_bastion`보다 더 큰 최종 위계를 실제 runtime source of truth에 잠갔다 | 거목 줄기 실루엣, 흡수 pulse, 뿌리 확장 위계는 최종 art와 support semantics가 들어올 때 재정리한다 |

### 2026-04-06 fallback field / aura 6차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `wind_sky_dominion` | `sky_dominion_activation`, `sky_dominion_loop`, `sky_dominion_end` | `Free/Part 13/14` 기반 aura family를 더 큰 pale mint-white ultimate wind overlay로 재해석해 owner-following toggle visual로 연결했고, 2026-04-09 follow-up으로 zero-damage aerial utility runtime까지 함께 잠갔다 | 완료. move-speed/jump/low-gravity/extra-jump contract와 owner expiry regression까지 verified 기준으로 사용한다 |

### 2026-04-06 fallback projectile / line 11차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `fire_meteor_strike` | `fire_meteor_strike_attack`, `fire_meteor_strike`, `fire_meteor_strike_hit`, `fire_meteor_strike_end` | 기존 fallback source를 copied seed로 삼되, 2026-04-10 follow-up에서 checked-in dedicated meteor family와 dedicated `phase_signature = fire_meteor_strike`를 실제 runtime source of truth로 승격했고, level scaling regression까지 함께 잠갔다 | 최종 art 단계에서는 낙하 streak와 지면 충돌 telegraph를 더 분리해 주는 편이 좋다 |
| `fire_solar_cataclysm` | `fire_solar_cataclysm_attack`, `fire_solar_cataclysm`, `fire_solar_cataclysm_hit`, `fire_solar_cataclysm_end` | 기존 fallback source를 copied seed로 삼되, 2026-04-10 follow-up에서 checked-in dedicated solar family와 dedicated `phase_signature = fire_solar_cataclysm`를 실제 runtime source of truth로 승격했고, level scaling regression까지 함께 잠갔다 | 최종 art 단계에서는 apocalypse_flame보다 더 밝고 더 넓은 solar corona terminal을 따로 분리해 주는 편이 좋다 |

### 2026-04-06 fallback projectile / line 12차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `water_tsunami` | `water_tsunami_attack`, `water_tsunami`, `water_tsunami_hit`, `water_tsunami_end` | 기존 `fallback_water_attack/line/hit` family를 더 넓은 tidal lane과 trailing vortex terminal로 재해석한 뒤, 2026-04-10 follow-up에서 checked-in dedicated tidal family와 level scaling regression까지 더해 verified runtime source of truth로 승격했다 | 최종 art 단계에서는 wave crest 높이와 후류 와류 밀도를 더 분리하는 편이 좋다 |

### 2026-04-06 fallback projectile / line 13차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `earth_gaia_break` | `earth_gaia_break_attack`, `earth_gaia_break`, `earth_gaia_break_hit`, `earth_gaia_break_end` | 2026-04-10 follow-up으로 checked-in dedicated collapse family 경로를 runtime source of truth로 승격했고, dedicated family path + level scaling regression까지 함께 잠겼다 | 최종 art 단계에서는 지면 균열 telegraph와 종단 먼지 붕괴를 더 분리해 주는 편이 좋다 |

### 2026-04-06 fallback projectile / line 14차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `earth_continental_crush` | `earth_continental_crush_attack`, `earth_continental_crush`, `earth_continental_crush_hit`, `earth_continental_crush_end` | 2026-04-10 follow-up으로 checked-in dedicated collapse family 경로와 dedicated `phase_signature = earth_continental_crush`를 runtime source of truth로 승격했고, level scaling + family path regression까지 함께 잠겼다 | 최종 art 단계에서는 광역 균열 telegraph와 낙반/먼지 종단을 더 분리해 주는 편이 좋다 |

### 2026-04-06 fallback projectile / line 19차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `earth_world_end_break` | `earth_world_end_break_attack`, `earth_world_end_break`, `earth_world_end_break_hit`, `earth_world_end_break_end` | 2026-04-10 follow-up으로 checked-in dedicated collapse family 경로를 runtime source of truth로 승격했고, existing world-end phase signature 위에 level scaling + family path regression까지 함께 잠겨 final earth burst verified 기준을 만족한다 | 최종 art 단계에서는 world-end 전용 균열 telegraph, 낙반 레이어, 먼지 잔광을 `earth_continental_crush`보다 더 크게 분리해 주는 편이 좋다 |

### 2026-04-06 fallback projectile / line 20차 실제 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `ice_absolute_zero` | `ice_absolute_zero_attack`, `ice_absolute_zero`, `ice_absolute_zero_hit`, `ice_absolute_zero_end` | 2026-04-10 follow-up으로 checked-in dedicated final-freeze family 경로를 runtime source of truth로 승격했고, existing zero phase signature 위에 level scaling + family path regression까지 함께 잠겨 final freeze burst verified 기준을 만족한다 | 최종 art 단계에서는 절대영도 중심핵, 외곽 서리 균열, 종단 냉기 파편을 `ice_absolute_freeze`보다 더 크게 분리해 주는 편이 좋다 |

### 2026-04-09 arcane canonical active 후속 연결 결과

| 대상 스킬 | 실제 연결 family | 구현 메모 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `arcane_force_pulse` | `arcane_force_pulse_attack`, `arcane_force_pulse`, `arcane_force_pulse_hit` | 기존 `fallback_shard_attack/projectile/hit` family를 checked-in dedicated arcane shard family로 승격해 독립 canonical active row에 실제 연결했다. `source_skill_id = arcane_force_pulse`, split effect payload, low-circle zero-cooldown runtime contract, dedicated projectile family regression까지 함께 닫았다 | 최종 art 단계에서는 회전 sigil cast와 작은 vortex pop의 차이를 더 강하게 벌리는 편이 좋다 |

## 2026-04-06 보완안 실제 연결 결과

| 대상 스킬 | 연결된 runtime hook | 구현 결과 | 남은 보완 포인트 |
| --- | --- | --- | --- |
| `earth_stone_spire` | `earth_stone_spire_attack`, `earth_stone_spire`, `earth_stone_spire_hit` | deploy cast payload가 startup/hit split effect를 실제 싣고, 본체는 별도 sampled spell visual로 솟구침을 유지한다 | `earth_quake_break` proxy가 이제 centered crack burst family로 분리됐으므로, 이후에도 솟구침형 설치기 read를 유지하는 방향으로만 튜닝한다 |
| `earth_quake_break` | `earth_tremor_attack`, `earth_tremor_hit` | runtime proxy `earth_tremor`의 startup을 `Earth Bump` 기반 12프레임 균열로, hit를 `Impact` 7프레임 strip으로 교체했다. canonical `earth_quake_break` 입력은 그대로 `earth_tremor` payload와 새 split family로 정규화된다 | runtime ID가 아직 `earth_tremor`이므로, future rename 없이도 문서/툴팁에서 proxy 설명이 계속 필요하다 |
| `fire_flame_arc` | `fire_flame_arc` sampled spell visual | `spells.json` runtime row를 추가해 canonical 입력이 실제 active cast로 이어지고, 정지형 16프레임 burst를 메인 visual로 연결했다 | 근접 난전에서 실루엣 과밀이 생기면 scale만 소폭 줄이고 연출 family는 유지한다 |
| `fire_inferno_sigil` | `fire_inferno_sigil_attack`, `fire_inferno_sigil`, `fire_inferno_sigil_hit`, `fire_inferno_sigil_end` | `Fire Effect 2`의 linger 폭발군을 startup / loop / tick hit / terminal burst 4단 family로 분리 연결했고, 후속으로 tick cadence `2.4s`, brightness down, scale down 튜닝까지 반영했다. 추가로 practical validation 기준으로 hit flash 길이 < pulse 간격, direct-hit 이후 다음 pulse 재개 시점, `deploy_lab` 프리셋 반복 검증 루프, 보스 1체 + 잡몹 혼합 pressure sandbox 회귀까지 잠갔다 | 남은 미세 조정은 실제 플레이 로그 기준의 선택적 brightness / terminal contrast 재튜닝 정도다 |
| `holy_cure_ray` | `holy_cure_ray_attack`, `holy_cure_ray`, `holy_cure_ray_hit` | `Heal` glyph + `Holy VFX 02` ray + `Holy VFX 01 Impact`를 실제 projectile runtime에 연결했다. 현재 solo runtime 제약상 `self_heal` rider를 함께 붙여 지원기 역할을 살린다 | ally-target heal runtime이 생기면 self-heal rider는 line-heal contract로 재정리할 수 있다 |
| `holy_judgment_halo` | `holy_judgment_halo_attack`, `holy_judgment_halo`, `holy_judgment_halo_hit`, `holy_judgment_halo_end` | `Smite` startup, `SwordOfJustice` main, `HeavensFury` closing burst까지 실제 stationary final burst runtime에 연결했고, 2026-04-10 follow-up으로 dedicated `phase_signature = holy_judgment_halo` ground telegraph와 level scaling regression까지 더해 verified representative로 잠갔다 | target-point casting이 생기면 현재 self-centered burst를 target-drop judgment로 승격할 수 있다 |
| `ice_frost_needle` | `ice_frost_needle_attack`, `ice_frost_needle`, `ice_frost_needle_hit` | canonical/runtime mapping을 `ice_frost_needle` 기준으로 정리하고, 기본 ice hotbar와 projectile split effect family를 실제 연결했다 | `frost_nova`는 legacy freeze burst runtime으로 남아 있으므로 이후 저장/프리셋 청소는 별도 추적한다 |
| `water_tidal_ring` | `water_tidal_ring_attack`, `water_tidal_ring`, `water_tidal_ring_hit` | 신규 active spell row를 추가해 stationary burst cast 경로를 열고, startup ring + main ring + splash hit family를 실제 연결했다 | 수직 geyser 표현은 의도적으로 배제했다. `Water Spike`는 여전히 신규 `water_aqua_geyser` 쪽이 더 자연스럽다 |
| `wind_cyclone_prison` | `wind_cyclone_prison_attack`, `wind_cyclone_prison_loop`, `wind_cyclone_prison_hit`, `wind_cyclone_prison_end` | 신규 deploy row, pull payload, terminal burst override까지 연결해 준비-흡인-유지-종료 4단 구조를 실제 런타임에 닫았다 | 현 pull은 position nudge 기반 1차 구현이라, 추후 이동 저항/보스 면역 규칙과 더 정교하게 맞출 수 있다 |
| `ice_frozen_domain` | `ice_frozen_domain_activation`, `ice_frozen_domain_loop`, `ice_frozen_domain_end` | canonical alias는 유지하고 runtime proxy `ice_glacial_dominion`에 토글 visual family를 실제 연결했다. 켜짐/유지/종료가 player-following field로 읽히며, 2026-04-09 follow-up 기준 성장 검증과 slow 유지 regression까지 더해 verified proxy source로 잠겼다 | 진짜 설치형 필드로 재해석할지 여부는 후속 canonical/runtime 재정리 과제다 |

## 신규 스킬 기획

### `earth_stone_rampart` / 스톤 램파트

- 제안 서클: `4`
- 타입: `설치형 / wall control`
- 스킬 컨셉: 전방 짧은 석벽을 솟게 만들어 적 돌진과 직선 투사체 진입을 잠깐 끊고, 생성 순간에만 약한 지진 타격을 준다.
- 전투 역할: 생존 보조, 진입 차단, 좁은 통로 제어, 원거리 적 라인 끊기.
- 핵심 연출 포인트: `Earth Effect 02 / Earth Wall`의 상승 구간을 메인으로 쓰고, 생성 지점에 약한 `Earth Bump`를 섞어 타격과 벽 생성을 분리한다.
- 기본 수치 초안: `26 MP`, `12초`, `생성 피해 = (마공 x 0.82) + 12`, `4초 지속`
- 레벨 성장 초안: 생성 계수 `+0.014`, 지속 `+1%`, 벽 길이 `+0.8%`
- 적합 이유: `Earth Wall`은 현 스킬풀 어느 기술에도 자연히 붙지 않지만, 지형을 세운다는 읽기는 매우 명확하다.
- 기존 스킬과 차별점: `earth_fortress`가 자기 강화 토글이라면, `stone_rampart`는 공간을 조작하는 설치형 방어기다.
- 2026-04-09 구현 결과: checked-in `earth_stone_rampart_attack / earth_stone_rampart / earth_stone_rampart_hit / earth_stone_rampart_end` family를 실제 runtime에 연결했고, `Earth Bump` startup/hit와 `Earth Wall` loop/end를 조합해 stone wall read를 잠갔다. 현재 short wall deploy contract, contact `slow + root`, dedicated wall telegraph regression까지 verified 기준으로 잠겼다.

### `fire_inferno_breath` / 인페르노 브레스

- 제안 서클: `4`
- 타입: `액티브 / cone / 다단`
- 스킬 컨셉: 전방 부채꼴 화염을 짧게 분사해 근중거리 적을 빠르게 태우는 화염 압박기다.
- 전투 역할: 근접 진입 대응, 좁은 부채꼴 청소, 연소 부여용 다단 압박.
- 핵심 연출 포인트: `Fire Effect 1 / Fire Breath`의 전방 확산을 메인으로 쓰고, 접촉 지점의 짧은 flare만 남겨 판정 범위를 읽기 쉽게 만든다.
- 기본 수치 초안: `28 MP`, `5.2초`, `총합 피해 = (마공 x 1.95) + 30`
- 레벨 성장 초안: 계수 `+0.038`, 점화 확률 `+0.4%p`, 사거리 `+0.8%`
- 적합 이유: 현재 불 라인은 투사체와 원형 burst 비중이 높아 근거리 cone 압박기가 비어 있다.
- 기존 스킬과 차별점: `fire_flame_arc`는 즉발 원형 burst, `fire_inferno_breath`는 전방 유지 압박기다.
- 2026-04-09 구현 결과: checked-in `fire_inferno_breath_attack / fire_inferno_breath / fire_inferno_breath_hit` family를 실제 runtime에 연결했고, `Fire Breath` 원본 48px 프레임은 split-effect 규약에 맞춰 64x64 tile로 정규화했다. 현재 five-hit cone pressure + burn chance scaling + dedicated split-effect regression까지 verified 기준으로 잠겼다.

### `water_aqua_geyser` / 아쿠아 가이저
- 제안 서클: `3`
- 타입: `액티브 / forward burst / launch`
- 스킬 컨셉: 전방 고정 지점에서 수기둥을 폭발시켜 적을 짧게 띄우고 파티의 후속 공격을 여는 제어기다.
- 전투 역할: 전방 고정 포인트 제어, 짧은 공중 띄우기 read, 진입 차단, 연계 시동.
- 핵심 연출 포인트: `Water Effect 01`의 원형 startup 뒤에 수직 분출을 짧게 터뜨리고, 종료 시 splash를 남겨 타격 지점을 분명하게 한다.
- 기본 수치 초안: `22 MP`, `6.0초`, `(마공 x 1.48) + 20`
- 레벨 성장 초안: 계수 `+0.03`, knockback `+1.2%`, 반경 `+0.8%`
- 적합 이유: `Water Effect 01`은 현재 `water_tidal_ring`보다 geyser형 point control로 읽히는 성격이 강하다.
- 기존 스킬과 차별점: `water_tidal_ring`이 시전자 중심 원형 밀쳐내기라면, `water_aqua_geyser`는 전방 고정 지점에 떨어지는 수직 분출 제어기다.
- 2026-04-09 구현 결과: checked-in `water_aqua_geyser_attack / water_aqua_geyser / water_aqua_geyser_hit / water_aqua_geyser_end` family를 실제 runtime에 연결했고, `Water StartUp 2`, `Water Spike 01`, `Water Splash 01` 원본을 64x64 tile 규약으로 정규화했다. 현재 keyboard-first fixed-forward burst spawn, dedicated geyser telegraph phase signature, high-knockback launch read, level 1 대비 level 30 damage/size/knockback scaling representative regression까지 verified 기준으로 잠겼다.

## 우선 보류

- `PixelHolyEffectsPack01/HolySlash A/B/C`
  - 현재 마도사 core identity에서 근접 검술 read가 강해, 신규 스킬로 받아도 클래스 톤이 흔들릴 가능성이 높다.
- `Effects/Thrust`
  - 주연출보다는 proc, micro hit, 보조 타격 연출에 더 가깝다. 단독 신규 스킬 후보로는 우선순위가 낮다.

## 문서 반영 위치

- 최신 기획/신규 후보 등록: [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)
- 구현/에셋 상태 추적: [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)
- 즉시 구현 핸드오프: [combat_increment_02_spell_runtime.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_02_spell_runtime.md)

## 다음 최소 안전 증분

1. `earth_stone_spire`, `earth_quake_break`, `fire_flame_arc`, `wind_cyclone_prison`, `fire_inferno_sigil`의 representative visual hook과 가독성 검증 기준은 실제 runtime 연결과 GUT 회귀까지 닫혔다.
2. `wind_tempest_drive` canonical은 2026-04-07에 5서클 순수 active로 잠겼다. 다음 최소 안전 증분은 `Overclock Circuit`를 active timing/state window 기준으로 다시 정의할지, 아니면 별도 lightning lane concept로 내릴지 결정하는 것이다.
3. 다음 보완 대상은 여전히 `ice_ice_wall` 단독이다. 다만 이제 blocked lane이 아니라 blue tremor temporary wall shell이 실제 연결된 상태이며, 남은 일은 장벽 전용 원본 교체와 wall-read 가독성 추가 개선이다.
4. 신규 스킬 후보는 `HolySlash`, `Thrust`처럼 보류한 근접 계열을 억지로 살리지 않고 `stone_rampart`, `inferno_breath`, `aqua_geyser` 3개만 1차 후보로 유지한다.
5. 저위험 refresh였던 `water_bullet`, `wind_cutter`는 실제 연결까지 완료했다. 남은 low-risk lane은 별도 신규 후보가 아니라 `ice_ice_wall` temporary wall shell 유지와 실전 플레이 검증이다.
