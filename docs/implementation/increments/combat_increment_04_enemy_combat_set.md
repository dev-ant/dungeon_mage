---
title: 전투 4차 작업 체크리스트 - 몬스터 전투 세트
doc_type: plan
status: active
section: implementation
owner: runtime
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 전투 4차 작업 체크리스트 - 몬스터 전투 세트

상태: 사용 중 (확장 중)
최종 갱신: 2026-04-01
섹션: 구현 기준

## 목표

이 문서는 [전투 우선 구현 계획](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md)의 네 번째 증분인 `몬스터 전투 세트 구축`을 Claude가 바로 구현할 수 있도록 쪼갠 작업 체크리스트다.

이번 증분의 핵심은 `플레이어의 이동, 스킬, 버프 조합을 실제로 시험할 수 있는 적 생태계`를 만드는 것이다.

## 현재 기준

- 적 공통 로직은 [enemy_base.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/enemies/enemy_base.gd)에 있다.
- 현재 적 상태 흐름은 `Godot State Charts`를 사용 중이다.
- 메인 프로토타입에는 최소 적 세트와 준보스가 이미 일부 존재하지만, 전투 샌드박스 기준으로 역할 분리가 더 분명해야 한다.
- 플레이어 쪽에는 버프 조합과 스킬 런타임이 일부 들어가 있으므로, 이번 작업은 적이 그 시스템에 제대로 반응하도록 만드는 데 초점을 둔다.
- 적 스탯 구조, 방어력 감쇠, 속성 저항, 상태이상 저항, 슈퍼아머, 브레이크, 최종 피해 순서는 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)를 우선 기준으로 삼는다.
- 현재 빌드는 `enemy_base.gd receive_hit()` 에 방어력/속성 저항/최소 피해/슈퍼아머/취약 보정이 실제 반영되어 있다.
- `main.gd` 는 엘리트 후보 타입에 대해 `3%` 승격 훅을 가지며, 기존 `enemy_type == "elite"` 데이터도 함께 유지한다.
- 상태이상은 `slow` 완전 연결, `root/stun/freeze` AI 정지, `shock/burn/poison/silence` 저항/타이머 기반의 구조적 수용까지 들어간 상태로 본다.
- `game_database.gd`는 enemy load 시 필수 필드, `enemy_grade`, `drop_profile`, duplicate `enemy_id`를 검증하고, 현재 카탈로그가 그 validation report를 비운 상태인지 GUT로 고정한다.
- 같은 로더는 `get_enemy_spawn_entries()`로 `enemy_id/display_name/enemy_grade/role/max_hp/drop_profile/has_super_armor_hint` 요약을 노출해 GUI나 관리자 읽기 전용 소비 경로가 원본 JSON 구조에 직접 의존하지 않게 한다.
- `get_drop_profile_preview()`와 확장된 `get_enemy_spawn_entries()`는 `drop_chance`, `drop_rarity_preview`까지 함께 노출해, 적 정보 소비자가 드롭 규칙을 raw constant에 직접 의존하지 않고 읽을 수 있게 한다.
- `resolve_drop_for_profile(profile, chance_roll, weighted_roll)`는 drop chance gate와 weighted rarity pick을 한 번에 고정된 입력으로 재현할 수 있게 해, owner_core 테스트가 실제 드롭 소비 경로를 deterministic하게 검증할 수 있게 한다.
- `get_drop_profile_summary(profile)`와 `get_drop_profile_summaries()`는 pool size, weighted pool size, rarity count까지 함께 노출해, 드롭 소비자나 QA 경로가 장비 카탈로그 전체를 직접 순회하지 않고도 profile별 드롭 규모를 읽을 수 있게 한다.
- 같은 로더는 room `spawns[].type`가 실제 enemy catalog의 `enemy_id`를 가리키는지 교차 검증하고, `get_room_spawn_validation_errors()`로 현재 rooms/enemy 매핑 상태를 읽기 전용으로 확인할 수 있게 한다.
- 같은 로더는 `get_room_spawn_summary(room_id)`와 `get_room_spawn_summaries()`로 room title/spawn count/type count/rest/core/rope 힌트를 요약해, 방 소비자가 raw room JSON 전체 구조에 직접 의존하지 않고 읽을 수 있게 한다.
- `get_room_spawn_enemy_summaries(room_id)`는 room별 스폰 roster를 first-seen order + aggregated count + enemy/drop hint까지 요약해, 소비자가 raw rooms/enemies 데이터를 직접 join하지 않고도 방 전투 구성을 읽을 수 있게 한다.

## 문서 경계

- 이 문서는 `전투 4차 증분 구현 핸드오프`와 `완료 로그`를 관리한다.
- 몬스터 roster, 역할 정의, 신규 편입 우선순위, 엘리트 후보는 [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md)에서 관리한다.
- `data/enemies/enemies.json` 필드 구조와 허용값은 [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md)에서 관리한다.
- 적 스탯, 저항, 슈퍼아머, 최종 피해 계산은 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)를 기준으로 유지한다.

## 다음 에셋 우선 적용 몬스터 기준 (2026-03-31)

신규 몬스터 편입 우선순위와 에셋 적용 기준의 장기 보관판은 [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md)에서 관리한다.

이번 증분에서는 아래 우선순위를 구현 핸드오프 기준으로만 유지한다.

1. `rat`
2. `tooth_walker`
3. `eyeball`
4. `trash_monster`
5. `sword`

## 플레이 경험 목표

- 적의 역할이 분명해야 한다.
- 근접 적은 압박을 만들고, 원거리 적은 위치 선정을 강제해야 한다.
- 돌진형 또는 점프형 적은 대시와 공중 시전의 가치를 드러내야 한다.
- 엘리트 적은 버프 폭발 타이밍을 요구해야 한다.
- 적이 많아져도 전투가 난잡하기보다 읽히는 편이 중요하다.

## 이번 범위

### 포함

- 근접 추격형 적 1종
- 원거리 견제형 적 1종
- 돌진 또는 점프 압박형 적 1종
- 엘리트 적 1종
- 적 감지, 추격, 공격, 피격, 경직, 사망
- 넉백과 슈퍼아머 최소 구조
- 플레이어 스킬/버프에 대한 반응
- 드롭 연결용 기본 슬롯
- 적 관련 GUT 테스트

### 제외

- 보스전 연출
- 복수 페이즈 보스
- 복잡한 상태이상 시스템 전부
- 지역별 몬스터 분포
- 몬스터 전용 스토리 연출

## Claude 작업 순서

1. [enemy_base.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/enemies/enemy_base.gd)의 공통 책임과 개별 적 책임을 분리한다.
2. 적 상태 차트의 공통 상태를 확정한다.
3. 근접형, 원거리형, 돌진형, 엘리트형 순서로 구현한다.
4. 플레이어 스킬 히트, 넉백, 경직, 사망 반응을 통일한다.
5. 버프 조합이 적에게 어떤 식으로 적용되는지 검증한다.
6. 적 스탯 JSON 또는 데이터 구조가 필요하면 분리한다.
7. GUT 테스트를 추가하고 헤드리스 검증을 통과시킨다.

## 적 역할 정의

### 1. 근접 추격형

- 가장 기본이 되는 적
- 짧은 감지 후 빠르게 접근
- 플레이어에게 지속 압박
- 버프 없는 기본 화력을 시험하는 기준 대상
- 현재 우선 비주얼 후보: `미궁버섯`, `웜`

### 2. 원거리 견제형

- 일정 거리 유지
- 투사체 발사
- 이동 중 시전과 포지셔닝을 요구
- `Overclock Circuit` 같은 폭딜 조합의 효율을 보기 좋음
- 현재 우선 비주얼 후보: `미궁박쥐`

### 3. 돌진 또는 점프 압박형

- 예측 가능한 준비 동작 후 크게 돌진 또는 점프 공격
- 대시와 공중 회피의 가치를 드러냄
- `Time Collapse`의 짧은 폭딜 창 활용에 적합

### 4. 엘리트 적

- 체력이 높고 일부 공격에 슈퍼아머 보유
- 버프를 모아서 터뜨리는 감각 검증용
- `Ashen Rite` 같은 필살 조합의 대상

## 공통 상태 흐름

- `Idle`
- `Patrol`
- `Chase`
- `Attack`
- `Hit`
- `Stagger`
- `Dead`

### 상태 전이 요구사항

- 플레이어가 감지 범위 밖이면 `Idle` 또는 `Patrol`
- 감지 범위 진입 시 `Chase`
- 공격 가능 거리 진입 시 `Attack`
- 피격 시 `Hit`
- 강한 타격 또는 누적 경직 시 `Stagger`
- HP가 0 이하가 되면 `Dead`

## 공통 적 기능

### 필수 수치

- 최대 HP
- 이동 속도
- 감지 거리
- 공격 거리
- 기본 공격력
- 경직 저항
- 넉백 저항
- 슈퍼아머 여부
- 속성 저항 태그

### 필수 반응

- 히트 시 데미지 적용
- 경직 또는 넉백
- 짧은 피격 플래시
- 사망 처리
- 드롭 슬롯 호출 가능 상태 유지

## 역할별 요구사항

### 근접형

- 벽과 낙하를 감지하며 순찰
- 플레이어 접근 시 근접 타격
- 너무 긴 선딜은 금지

### 원거리형

- 플레이어와 일정 거리 유지
- 지나치게 뒤로 빠지지 않도록 거리 범위 제한
- 발사체는 명확한 궤적과 속도 보유

### 돌진형

- 준비 동작이 보여야 함
- 돌진 중 피격 반응 규칙을 별도 가질 수 있음
- 준비 동작을 본 뒤 회피 가능한 구조여야 함

### 엘리트

- 버프 폭딜 없이는 시간이 걸리는 체력량
- 일부 패턴 중 슈퍼아머
- 일정 피해 누적 시 강한 경직 허용

## 플레이어 시스템과의 연결

### 스킬 히트

- 액티브 투사체
- 광역 판정
- 설치물 지속 타격
- 조합 폭발 판정

모두 적에게 정상 적용되어야 한다.

### 버프 조합 반응

- `Prismatic Guard`는 생존 검증용
- `Overclock Circuit`는 원거리형과 다수전 검증용
- `Time Collapse`는 짧은 강공 창 검증용
- `Ashen Rite`는 엘리트 마무리용

## 데이터 구조 기준

적 데이터 구조와 필드 규칙은 [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md)를 기준으로 유지한다.

이번 증분 구현에서 최소 확인해야 할 핵심 키는 아래와 같다.

- `enemy_id`
- `display_name`
- `enemy_type`
- `enemy_grade`
- `role`
- `max_hp`
- `move_speed`
- `attack_damage_type`
- `attack_element`
- `stagger_threshold`
- `knockback_resistance`
- `super_armor_tags`
- `drop_profile`

## 예상 구현 파일

- [enemy_base.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/enemies/enemy_base.gd)
- 새 `scripts/enemies/enemy_melee.gd`
- 새 `scripts/enemies/enemy_ranged.gd`
- 새 `scripts/enemies/enemy_dash.gd`
- 새 `scripts/enemies/enemy_elite.gd`
- 적 씬 파일
- 필요 시 `data/enemies/enemies.json`
- 새 테스트 파일 또는 기존 테스트 확장

## 세부 작업 체크리스트

### 1. 공통 기반 정리

- 적 공통 수치와 함수 추출
- 상태 차트 이벤트 정리
- 피격과 사망 공통 처리 통일

### 2. 근접형 구현

- 순찰
- 감지 후 추격
- 근접 공격
- 피격/사망

### 3. 원거리형 구현

- 거리 유지
- 발사 패턴
- 공격 간격
- 피격/사망

### 4. 돌진형 구현

- 준비 동작
- 돌진
- 돌진 종료 후 빈틈
- 피격 규칙

### 5. 엘리트 구현

- 체력 증가
- 일부 슈퍼아머
- 버프 폭발에 대한 체감 검증

### 6. 드롭 슬롯 연결

- 실제 아이템 구현 전이라도 드롭 훅은 남긴다.
- 추후 장비/아이템 증분과 연결하기 쉽게 한다.

## 수용 기준

- 전투 샌드박스에서 4종 적을 모두 소환하거나 배치할 수 있다.
- 각 적의 역할 차이가 플레이 중 분명하게 느껴진다.
- 플레이어의 스킬과 버프 조합이 적에게 정상 반응한다.
- 피격, 경직, 사망이 모두 읽기 쉽게 표현된다.

## 테스트 체크포인트

### GUT

- 감지 후 상태 전환
- 공격 거리 진입 시 공격 상태 진입
- 피격 시 HP 감소
- HP 0 시 사망 처리
- 경직 또는 넉백 처리
- 엘리트의 슈퍼아머 조건

### 헤드리스

- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

## 비목표

- 보스 2페이즈 이상
- 고급 AI 협동
- 군중 제어 상태이상 전부
- 지역별 리스폰 규칙

## 구현 현황 (2026-03-28)

### 현재 구현된 적 타입 (전체)

| 타입 | 역할 | 소환 키(spawn 탭) | 비고 |
|---|---|---|---|
| brute | 근접 추격 | C | 기본 근접 |
| ranged | 원거리 견제 | V | 거리 유지 + 수평 발사체 |
| boss | 광역 볼리 | G | 양방향 발사 |
| dummy | 훈련 대상 | Q | 무적 |
| dasher | 텔레그래프 돌진 | B | 0.42s 준비 → 고속 돌진 |
| sentinel | 범위 제어 | J | 2방향 조준 사격 |
| elite | 버스트 체크 | H | 슈퍼아머 + 고체력(180HP) + 누적 경직 |
| leaper | 이동 압박 | N | 0.48s 텔레그래프 → 포물선 점프 |
| **bomber** | **정지 패널티 / 설치물 압박** | **Y** | 느린 대형 투사체, 240-500px 키팅 |
| **charger** | **정지 패널티 / 이동 유도** | **R** | 텔레그래프 중 위치 잠금, 620px/s 돌진 |

### bomber 구현 내용
- `move_speed = 62`, `attack_period = 2.8`, `tint = amber`
- 플레이어 위치를 향해 느린 대형 투사체(속도 88px/s, 크기 16) 발사
- 플레이어가 제자리에 있으면 자연스럽게 맞는 구조
- 공격 후 kite 상태로 복귀 (240-500px 유지)
- 설치물(Stone Spire 등) 근처에서 정지 시 설치물도 타격

### charger 구현 내용
- `charge_locked_x` 변수: 텔레그래프 시작 시 플레이어 X 좌표 잠금
- 0.65s 정지 텔레그래프 → 잠금된 X 방향으로 620px/s 돌진
- 플레이어가 텔레그래프 중 이동하면 돌진이 빗나감
- dasher보다 텔레그래프가 길고(0.65s vs 0.42s) 잠금 방향 고정으로 읽기 명확함

### 관련 파일
- `scripts/enemies/enemy_base.gd` (+bomber, +charger configure/AI/attack, +_fire_bomb, +charge_locked_x var)
- `scripts/admin/admin_menu.gd` (Y=bomber, R=charger 소환 키 추가, spawn tab 안내 갱신)
- `tests/test_enemy_base.gd` (+4 테스트, 총 15개 통과)

## 구현 현황 추가 (2026-03-28)

### leaper 착지 충격 판정 (완료)
- `_on_leaper_land()` 추가: 착지 시 좌우 방향으로 `size: 18` 쇼크웨이브 투사체 2개 발사
- `land_timer.timeout`에서 `leaper_jumping = false` 직접 처리 → `_on_leaper_land()` 호출로 변경
- 플레이어가 착지 지점을 피해야 하는 구조 완성; Stone Spire 설치물 근처에서도 유효 타격 가능
- 새 테스트 1개 추가: `_on_leaper_land()` 호출 시 투사체 2개 발사 확인, 크기/데미지/넉백/leaper_jumping 플래그 검증
- 전체 테스트 122/122 통과

### elite 원거리 버스트 공격 (완료)
- elite 공격 분기에 거리 체크 추가: `absf(dx) < 120.0` 이면 슬램, 이상이면 `_fire_elite_burst(dx)` 호출
- `_fire_elite_burst()` 추가: ±15도 각도로 3방향 투사체 발사 (`damage: 12`, `range: 480`, `speed: 300px/s`, `color: #c84bff`)
- 버스트 스킬 없이는 elite를 중거리에서도 안전하게 처리하기 어려운 구조 완성
- 새 테스트 1개 추가: `_fire_elite_burst()` 호출 시 투사체 3개 발사, 데미지/사거리/속도 검증

## 다음 우선 작업

### 1. 적 수치 데이터 분리 ✅ (2026-03-28 완료)
- **의도**: `stagger_threshold`, `max_health`, `attack_period` 등이 현재 하드코딩. `data/enemies/enemies.json` 도입 시 수치 조정이 코드 밖에서 가능
- **파일**: `data/enemies/enemies.json` (신규), `enemy_base.gd` — `_apply_stats_from_data()` 추가, `game_database.gd` — `enemy_catalog`/`enemy_by_id`/`get_enemy_data()`/`get_all_enemies()` 추가
- **결과**: 전투 밸런싱을 JSON 수정만으로 조정 가능. GameDatabase 미사용 환경(헤드리스 GUT)에서는 fallback 하드코딩으로 테스트 통과 보장
- **검증**: GUT 3개 추가 — bomber/charger fallback 수치 검증, configure() 후 `health == max_health` 확인. 전체 21/21 통과

### 2. leaper 착지 지점 예고 표시 연결 ✅ (2026-03-28 완료)
- **의도**: `leaper_jumping = true` 구간에서 착지 예상 지점에 경고 마커를 남기면 회피 판단이 더 명확해짐
- **파일**:
  - `enemy_base.gd` — `_emit_leaper_warning_marker(dx_l)` 헬퍼 추가. 점프 시작 시 예측 착지 X(±238px)에 `team:"marker"`, `damage:0`, `duration:0.65s`, 붉은 납작 다이아몬드 마커 emit. `_on_attack_state_entered()` leaper 분기에서 호출, `get_tree()` null-check 추가
  - `spell_projectile.gd` — `is_marker` 변수 추가. `setup()`에서 `config["marker"]` 플래그 읽기. `_build_visual()`에서 마커일 때 납작 수평 다이아몬드 폴리곤 + `modulate.a = 0.65` 적용. team이 "marker"이면 body_entered 콜백에서 어떤 피해도 적용되지 않음
- **결과**: 플레이어가 leaper 텔레그래프(0.48s) 중 착지 지점을 붉은 마커로 확인하고 이동 결정 가능
- **검증**: GUT 2개 추가 — 마커 방출 확인(`team/damage/duration/marker 플래그`), 방향별 착지 X 좌표 방향 검증. 전체 174/174 통과

### 2-1. bomber 곡선 감속 투사체 ✅ (2026-04-01 완료)
- **의도**: bomber가 `slow_ranged_denial` 역할답게, 발사 직후 스쳐 지나가는 직선탄이 아니라 "천천히 날아오다 아래로 처지고 수평 속도가 죽는" 억제형 궤적을 가져야 함
- **파일**:
  - `enemy_base.gd` — `_fire_bomb()` payload에 `horizontal_drag_per_second`, `min_horizontal_speed`, `gravity_per_second` 추가
  - `spell_projectile.gd` — 선택형 런타임 운동 필드 지원: `_apply_runtime_motion()`에서 중력 곡선 + 수평 감속 처리
  - `tests/test_enemy_base.gd` — bomber payload/운동 회귀 테스트 2개 추가
- **결과**:
  - bomber 폭탄은 플레이어 방향으로 88px/s로 출발
  - 비행 중 `gravity_per_second = 180`으로 아래로 처지고, `horizontal_drag_per_second = 24`로 수평 속도가 감소
  - 최종적으로 `min_horizontal_speed = 34` 바닥 속도를 유지해 정지 플레이를 더 강하게 벌하는 패턴으로 보강
- **검증**: `godot --headless --path . --quit`, `godot --headless --path . --quit-after 120`, GUT 453/453 통과

### 2-2. bomber 타깃 고정 warning marker ✅ (2026-04-01 완료)
- **의도**: bomber가 느린 탄을 쏘기 전에 "여기 서 있으면 맞는다"는 정보를 짧게 보여 주면, 정지 패널티가 억울한 피격이 아니라 읽을 수 있는 압박으로 바뀜
- **파일**:
  - `enemy_base.gd` — `_emit_bomber_warning_marker()` 추가. 공격 상태 진입 시 플레이어의 현재 발밑 조준점(`target.global_position + (0, 12)`)에 `team:"marker"`, `damage:0`, `duration:0.55s`, 호박색 마커 emit 후 `_fire_bomb()` 호출
  - `tests/test_enemy_base.gd` — bomber 공격 상태에서 marker → live bomb 순서로 payload 2개가 나가는지, marker 좌표/지속시간이 고정 타깃 위치와 일치하는지 검증 1개 추가
- **결과**:
  - bomber는 공격 직전 플레이어의 현재 위치를 짧게 예고하고
  - 이어서 기존 곡선/감속 폭탄을 발사해 "멈춰 있으면 맞는" 압박을 더 명확하게 전달함
- **검증**: `godot --headless --path . --quit`, `godot --headless --path . --quit-after 120`, GUT 456/456 통과

### 2-3. bomber 터미널 burst 이펙트 ✅ (2026-04-01 완료)
- **의도**: warning marker와 곡선탄만으로는 착탄 순간의 읽힘이 약해서, bomber 폭탄이 닿거나 수명이 끝날 때 짧은 burst를 보여 주어 피격감과 종료 지점을 분명히 함
- **분석 대상:**
  - `asset_sample/Effect/Everything/Alternative 3/1/Alternative_3_01.png` ~ `Alternative_3_06.png`
  - 주황 링/아크 형태 6프레임으로 bomber 폭발용 one-shot burst 후보로 선택
- **파일**:
  - `assets/effects/bomber_burst/` — `bomber_burst_0~5.png` 복사
  - `enemy_base.gd` — `_fire_bomb()` payload에 `spell_id:"enemy_bomber_bomb"`, `terminal_effect_id:"bomber_burst"` 추가
  - `spell_projectile.gd` — 선택형 terminal effect 지원. 충돌/수명 종료 시 `bomber_burst` one-shot AnimatedSprite2D를 재생하고 난 뒤 queue_free
  - `tests/test_enemy_base.gd` — bomber payload가 terminal effect를 요청하는지, projectile이 종료 시 6프레임 burst로 전환되는지 검증 2개 추가
- **결과**:
  - bomber 폭탄은 플레이어 접촉이나 사거리 종료 시 바로 사라지지 않고
  - 짧은 주황 burst를 재생한 뒤 제거되어 종료 지점이 더 선명하게 읽힘
- **검증**: `godot --editor --headless --path . --quit`로 import 후, `godot --headless --path . --quit`, `godot --headless --path . --quit-after 120`, GUT 457/457 통과

### 3. elite 2단계 슈퍼아머 트리거 (2026-03-28 완료)
- `enemy_base.gd`: `elite_phase2_activated` 변수 추가
- `receive_hit()`: HP가 `max_health / 2` 이하가 되면 `stagger_threshold = 90`으로 단회 전환 (55→90)
- GUT 2개 추가: 단계 전환 확인, 중복 발동 방지 확인

### 3. super_armor_tags JSON → has_super_armor_attack 연결 ✅ (2026-03-28 완료)
- **의도**: `super_armor_tags` JSON 필드가 `_apply_stats_from_data()`에서 읽히지 않아 데이터 완결성 부족
- **파일**: `enemy_base.gd` — `has_super_armor_attack` 변수 추가. JSON 분기에서 `armor_tags.size() > 0` 이면 true 설정. fallback 분기 elite에도 `has_super_armor_attack = true` 추가. `_on_attack_state_entered()` 첫 줄에서 `has_super_armor_attack` 이면 `super_armor_active = true` 설정, elite 하드코딩 제거
- **결과**: JSON의 `super_armor_tags` 필드로 슈퍼아머 공격 활성화를 제어 가능. elite 외 적을 슈퍼아머 공격형으로 만들려면 JSON만 수정하면 됨
- **검증**: GUT 4개 추가 — elite 플래그 확인, brute 플래그 없음 확인, elite 공격 상태 슈퍼아머 활성화, brute 공격 상태 슈퍼아머 없음. 전체 178/178 통과

### 4. admin spawn 탭 enemies.json 기반 표시 ✅ (2026-03-28 완료)
- **의도**: spawn 탭의 적 목록과 설명이 하드코딩되어 있어 enemies.json 추가/변경 시 관리자 메뉴도 수동 수정 필요
- **파일**: `admin_menu.gd` — `SPAWN_KEY_MAP` 상수 추가(10종 키 매핑). `_get_spawn_tab_lines()` 전면 교체: `GameDatabase.get_all_enemies()` 순회하여 `key display_name  (role  HP:N  [SA])` 형식 자동 생성. DB 비어있을 때 기존 하드코딩 폴백 유지. `[SA]` = super_armor_tags 비지 않을 때 표시
- **결과**: enemies.json에 새 적 추가 시 spawn 탭에 자동 반영. HP·역할·슈퍼아머 여부가 메뉴에서 직접 확인 가능
- **검증**: GUT 3개 추가 — 전체 적 수 반영, C/H 키 및 [SA] 표시, elite HP 180 표시. 전체 181/181 통과

#### 적 피격 히트 플래시 (2026-03-28 완료)

- `enemy_base.gd` — `hit_flash_timer: float = 0.0` 변수 추가
- `receive_hit()` 진입 시 `hit_flash_timer = 0.12` 설정
- `_physics_process()` — `hit_flash_timer` 틱 감소 + `body_polygon.color = WHITE if hit_flash_timer > 0 else tint` 적용
- 효과: 피격 시 0.12s 동안 적이 흰색으로 번쩍이며 타격감 즉각 피드백 제공
- GUT 2개 추가: receive_hit 후 hit_flash_timer > 0, 기본값 0.0 확인
- 전체 237/237 통과

#### 세션 전투 통계 추적 (2026-03-28 완료)

- `game_state.gd` — `session_damage_dealt: int`, `session_hit_count: int` 변수 추가
- `record_enemy_hit(amount: int, school: String)` 공개 함수 추가: 두 카운터 증가 + `progression_flags["school_hits_<school>"]` 누적
- `get_combat_stats_summary() -> String` 추가: `"Hits: N  DMG: N"` 형식 반환
- `reset_progress_for_tests()` — 두 카운터 초기화 추가
- `enemy_base.gd receive_hit()` — 피해 적용 전 `GameState.record_enemy_hit(amount, school)` 호출
- GUT 5개 추가(test_game_state 4개, test_enemy_base 1개): 카운터 증분, 학교별 브레이크다운, reset 초기화, summary 포맷, enemy receive_hit 전달
- 전체 242/242 통과

#### 전투 통계 HUD 표시 (2026-03-28 완료)

- `game_ui.gd refresh()` — `combo_label.text`에 `GameState.get_combat_stats_summary()` 추가
- HUD 포맷: `<콤보 요약>   Hits: N  DMG: N   Keys …`
- 프레임마다 갱신되므로 실시간으로 세션 누적 피해·피격 수 확인 가능
- `game_ui.gd`는 씬 트리 의존으로 GUT 단위 테스트 불가 — `get_combat_stats_summary()` 자체는 test_game_state에서 이미 검증됨
- 전체 242/242 유지

## 다음 증분

이 작업이 끝나면 다음은 `장비 시스템 최소 버전`이다. 그때는 적 드롭, 장비 지급, 장착 수치, 전투 계산 반영을 붙여 레벨 없는 성장 루프를 실전 전투에 연결한다.

## 21차 증분 완료 상태 (2026-03-30)

버섯 몬스터(Mushroom) 스프라이트 적용:

**에셋 분석**
- `asset_sample/Monster/Forest_Monsters_FREE/Mushroom/Mushroom without VFX/`
- 프레임 크기: 80×64px (가로 합산으로 역산)
- 5개 애니메이션: idle(7프레임), run(8프레임), attack(10프레임), hurt(5프레임), death(15프레임)
- 픽셀 분석: char_h≈33px, feet_from_center≈+31 → scale=1.2, position.y=-10 (발이 충돌박스 하단 y=+27에 정렬)

**`enemy_base.gd` 변경**
- `MUSHROOM_SHEETS`, `MUSHROOM_SHEET_DIR`, `MUSHROOM_ANIM_FILES` 상수 추가
- `var enemy_sprite: AnimatedSprite2D = null` 추가
- `_ready()`에서 `_setup_sprite()` 호출
- `_setup_sprite()`:
  - `DisplayServer.get_name() == "headless"`이면 즉시 return (GUT 테스트 안전)
  - "brute", "dummy", "ranged" 타입에만 적용
  - `ResourceLoader.load()`로 각 animation sheet 로드, AtlasTexture per frame으로 SpriteFrames 구성
  - AnimatedSprite2D 생성: scale=(1.2,1.2), position=(0,-10), texture_filter=NEAREST
  - 성공 시 `body_polygon.visible = false`
- `_update_enemy_anim()`: behavior_state → animation 매핑, scale.x로 방향 전환
- `_physics_process`: sprite가 있으면 sprite.modulate으로 hit flash, 없으면 body_polygon 유지

**`.import` 파일 신규 생성 (5개)**
- Mushroom-Idle/Run/Attack/Hit/Die.png.import

**전체 313/313 통과**

## 25차 증분 완료 상태 (2026-03-30)

적 사망 딜레이 (death 애니메이션 후 제거):

- `enemy_base.gd` — `receive_hit()` 에서 `queue_free()` 대신 `_play_death_and_free()` 호출
- `_play_death_and_free()`:
  1. `set_physics_process(false)`, `set_process(false)` — AI/이동 즉시 정지
  2. `state_chart` process 비활성화 — 상태 전환 차단
  3. `collision_shape.disabled = true` — 추가 피격 차단
  4. `enemy_sprite`가 "death" 애니메이션을 가지면: `play("death")` → `frames/fps`로 재생 시간 계산 → `await timer`
  5. `queue_free()`
- 스프라이트 없는 적(headless/비-brute 타입): 즉시 제거
- 전체 313/313 통과
