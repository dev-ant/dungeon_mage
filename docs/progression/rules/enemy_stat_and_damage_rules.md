---
title: 적 스탯 체계와 최종 전투 계산 규칙
doc_type: rule
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_level_rules.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - rule_changed
  - runtime_changed
  - schema_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 적 스탯 체계와 최종 전투 계산 규칙

상태: 기준 문서  
최종 갱신: 2026-04-01  
섹션: 성장 시스템 / 전투 수치 규칙

## 범위

이 문서는 적의 공통 스탯 구조, 등급별 수치 원칙, 방어력/속성 저항/상태이상 저항, 슈퍼아머, 최종 피해 계산 순서를 고정하는 기준 문서입니다.

플레이어 스킬 자체의 계수 공식은 [skill_level_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_level_rules.md)에서 관리하고, 이 문서는 `그 스킬 피해가 적에게 어떻게 적용되는지`를 관리합니다.

## 문서 역할과 경계

- 이 문서는 `전투 수치 규칙`만 관리합니다.
- 몬스터 roster, 역할, 엘리트 후보, 신규 편입 우선순위는 [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md)에서 관리합니다.
- `data/enemies/enemies.json`의 필드 구조와 허용값은 [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md)에서 관리합니다.
- 현재 빌드에 실제로 반영된 몬스터 상태는 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)와 실제 코드를 기준으로 확인합니다.

## 이 문서를 반드시 수정해야 하는 경우

아래 항목 중 하나라도 바꾸면, 코드만 바꾸지 말고 이 문서를 함께 갱신합니다.

- 전투 계산에 영향을 주는 `data/enemies/enemies.json`의 스탯 의미 변경
- 적 등급 규칙 변경
- 방어력 공식 변경
- 속성 저항/약점 규칙 변경
- 상태이상 저항 규칙 변경
- 슈퍼아머/브레이크 규칙 변경
- 적이 받는 최종 피해 계산 순서 변경
- 전투 수치가 바뀌는 테스트 기준 변경

아래 변경은 이 문서보다 [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md)를 먼저 갱신합니다.

- 새 JSON 필드 추가
- 필드 타입 변경
- enum-like 허용값 변경
- validation 규칙 변경

다만 위 스키마 변경이 실제 전투 계산 의미까지 바꾸면, 이 문서도 함께 갱신합니다.

## 적 공통 스탯 구조

모든 적은 아래 스탯 그룹을 기준으로 설계합니다.

### 기본 생존/공격

- `max_hp`
- `physical_attack`
- `magic_attack`
- `attack_damage_type`
- `attack_element`

### 방어

- `physical_defense`
- `magic_defense`

### 속성 상성

- `fire_resist`
- `water_resist`
- `ice_resist`
- `lightning_resist`
- `wind_resist`
- `earth_resist`
- `plant_resist`
- `dark_resist`
- `holy_resist`
- `arcane_resist`

### 상태이상 저항

- `slow_resist`
- `root_resist`
- `stun_resist`
- `freeze_resist`
- `shock_resist`
- `burn_resist`
- `poison_resist`
- `silence_resist`

### 특수 전투 상태

- `enemy_grade`
- `super_armor_enabled`
- `super_armor_break_threshold`
- `super_armor_break_duration`
- `super_armor_damage_multiplier`
- `vulnerability_damage_multiplier`

## 적 등급

적 등급은 아래 세 단계로 고정합니다.

- `normal`
- `elite`
- `boss`

### normal

- 일반 전투 템포를 유지하는 기본 적입니다.
- 잘 녹아야 하지만, 완전한 종잇장처럼 느껴지지는 않도록 약한 방어를 가집니다.

### elite

- 일부 중형 이상 몬스터에서만 생성합니다.
- 기본 생성 규칙은 `엘리트 가능 타입 중 3% 확률 생성`입니다.
- 일반보다 체력, 공격력, 방어력, 저항, 상태이상 저항이 모두 눈에 띄게 높아야 합니다.
- 외형 변화가 반드시 동반되어야 합니다.

### boss

- 필드 일반 몬스터의 강화판이 아니라 별도 종으로 설계합니다.
- 계산 순서는 일반 적과 동일하게 유지하고, 수치 테이블만 별도 운영합니다.

## 등급별 수치 원칙

### normal

- `physical_defense`, `magic_defense`: 각각 `15~35`
- 속성 상성: `저항 1개 +15%`, `약점 1개 -15%`, 나머지 `0%`
- 상태이상 저항: 항목별 `5~15%`

### elite

엘리트는 일반 개체를 기준으로 아래 보정을 적용합니다.

- `max_hp x 3.0`
- `공격력 x 1.4`
- `physical_defense x 2.0`
- `magic_defense x 2.0`
- 전 속성 저항 `+10%p`
- 전 상태이상 저항 `+15%p`

추가 규칙:

- 외형 변화 필수
- 패턴형 슈퍼아머 사용 가능

### boss

- 일반 적과 같은 계산식을 쓰되, 별도 종 기준으로 수치를 직접 설계합니다.
- 상태이상 저항은 기본적으로 `35~50%` 범위에서 시작합니다.
- 상시 슈퍼아머 또는 상시 + 강화형 슈퍼아머 패턴을 허용합니다.

## 공격 타입 규칙

적 공격은 아래 두 축을 동시에 가질 수 있습니다.

- 피해 계열: `physical` 또는 `magic`
- 속성: `fire`, `water`, `ice`, `lightning`, `wind`, `earth`, `plant`, `dark`, `holy`, `arcane`, `none`

예시:

- 칼날 돌진: `physical + none`
- 화염 폭발: `magic + fire`
- 저주 장판: `magic + dark`

## 방어력 공식

적이 받는 피해의 방어력 감쇠는 아래 공식으로 고정합니다.

`방어 후 피해 = 원피해 x (100 / (100 + 대응 방어력))`

규칙:

- 물리 공격은 `physical_defense`를 사용합니다.
- 마법 공격은 `magic_defense`를 사용합니다.
- 일반 적은 방어가 약하게 체감되어야 하고, 엘리트에서만 체감이 확실히 커집니다.

## 속성 저항과 약점 규칙

### 기본 규칙

- 적은 기본적으로 `저항 1개`, `약점 1개`를 가질 수 있습니다.
- 기본 권장값은 `저항 +15%`, `약점 -15%`입니다.
- 일반 적의 상성은 빌드를 막기보다 `조금 더 유리하거나 불리한 정도`로 느껴져야 합니다.

### 적용 공식

`속성 적용 후 피해 = 방어 후 피해 x (1 - 속성저항값)`

예시:

- `fire_resist = 0.15` 이면 화염 피해 15% 감소
- `fire_resist = -0.15` 이면 화염 피해 15% 증가

## 상태이상 저항 규칙

상태이상은 아래 8종을 모두 개별 저항으로 관리합니다.

- `slow`
- `root`
- `stun`
- `freeze`
- `shock`
- `burn`
- `poison`
- `silence`

### 공통 방향

- 저항 수치가 높을수록 `적용 확률`과 `지속시간`이 모두 줄어듭니다.
- 다만 상태이상 종류에 따라 어느 축이 더 크게 줄어드는지는 다르게 적용합니다.

### 구속/중단 계열

대상:

- `root`
- `stun`
- `freeze`
- `silence`

권장 공식:

- `최종 적용확률 = 기본확률 x (1 - 저항)`
- `최종 지속시간 = 기본지속시간 x (1 - 저항 x 0.5)`

### 지속/약화 계열

대상:

- `slow`
- `shock`
- `burn`
- `poison`

권장 공식:

- `최종 적용확률 = 기본확률 x (1 - 저항 x 0.5)`
- `최종 지속시간 = 기본지속시간 x (1 - 저항)`

### 등급별 권장 범위

- `normal`: 항목별 `5~15%`
- `elite`: 항목별 `20~35%`
- `boss`: 항목별 `35~50%`

## 상태이상 시스템 v1 기준선

이 문단은 `현재 구현 중인 상태이상 시스템의 실제 완료 기준`을 고정합니다.

### 대표 검증 스킬

상태이상 시스템 v1은 아래 3개 스킬을 대표 검증 대상으로 고정합니다.

- `ice_glacial_dominion`
- `plant_vine_snare`
- `frost_nova`

의도:

- `ice_glacial_dominion`: 유지형 `slow` 오라 검증
- `plant_vine_snare`: 설치형 `root` 재적용 검증
- `frost_nova`: 순간 burst형 `freeze` 시동 검증

### 우선 검증 적과 상황

- 첫 검증 적은 `leaper`로 고정합니다.
- 첫 검증 상황은 `leaper`가 파고드는 압박 상황에서 접근을 끊고 후속 연계를 여는 장면입니다.
- 이후 동일 규칙을 `brute`, `bomber`, `elite`까지 확대합니다.

이유:

- 상태이상 시스템의 핵심 역할을 `공간 통제와 접근 차단`으로 보며, 이 체감은 `leaper` 압박 상황에서 가장 분명하게 드러납니다.

### v1에서 완전 연결할 상태이상

v1에서 실제 행동 효과까지 완전 연결하는 상태이상은 아래 3종입니다.

- `slow`
- `root`
- `freeze`

나머지 4종은 이번 단계에서 아래까지만 고정합니다.

- `shock`
- `burn`
- `poison`
- `silence`

적용 범위:

- 데이터 필드 유지
- 저항 계산 유지
- 적용 확률/지속시간 계산 유지
- 적 내부 타이머 저장 유지
- 개별 행동 효과는 후속 증분으로 분리

### 핵심 역할

상태이상 시스템 v1의 핵심 역할은 `직접 딜 상승`보다 `공간 통제와 접근 차단`입니다.

세부 방향:

- `slow`: 적 접근 템포를 늦춘다.
- `root`: 적의 이동 경로를 끊는다.
- `freeze`: 짧은 burst 정지와 후속 연계 창을 연다.

### slow 실제 운용 규칙

- `slow`는 `이동 속도 + 공격 준비/행동 템포`를 함께 늦춥니다.
- 단순 이동 감속이 아니라, 적이 플레이어를 압박하는 `리듬` 자체를 늦추는 상태이상으로 봅니다.
- 기본 의도는 `카이팅 시간 확보`와 `다음 스킬 연결 여유 확보`입니다.

### root 실제 운용 규칙

- `root`는 `이동만 봉인`합니다.
- 공격/시전은 허용합니다.
- 즉, 적을 완전히 끊는 hard stun이 아니라 `자리 고정형 통제`로 해석합니다.

의도:

- 설치형 스킬과 지형 통제의 가치를 살리되, 적의 위협 자체가 완전히 사라지지는 않게 합니다.

### freeze 실제 운용 규칙

- `freeze`는 `짧은 완전 정지 + 다음 피해 연계 창`을 여는 burst CC로 고정합니다.
- 기본 의도는 빙결 계열이 `순간 접근 차단`과 `연속 공격 시동`을 동시에 담당하게 만드는 것입니다.

운용 규칙:

- `freeze` 중에는 이동과 공격이 모두 정지합니다.
- `freeze` 종료 직후의 첫 후속 피해는 플레이어가 연계를 체감할 수 있을 만큼 읽혀야 합니다.
- v1에서는 별도 전용 취약 디버프를 만들기보다, `freeze` 그 자체가 짧은 연계 창 역할을 하는 방향으로 고정합니다.

### 중첩과 재적용 규칙

같은 상태이상을 다시 맞았을 때는 아래 규칙을 공통 기준으로 사용합니다.

- `더 강한 수치 우선`
- `지속시간 갱신`

해석 예시:

- 기존 `slow 20%` 상태에 `slow 28%`가 들어오면 `28%`로 덮어씁니다.
- 기존 `root 0.8초` 상태 중 다시 `root 0.8초`가 들어오면 지속시간을 갱신합니다.
- 기존 `freeze 0.6초` 상태에 더 약한 `freeze 0.4초`가 들어오면 수치는 유지하고 지속시간만 갱신할 수 있습니다.

### 엘리트/보스 대응 원칙

- 상태이상도 일반 적과 같은 규칙을 쓰되, `저항 수치`로 차이를 냅니다.
- 엘리트는 `적용 확률 감소 + 지속시간 감소`가 눈에 띄게 체감되어야 합니다.
- 보스는 같은 규칙을 쓰되, v1의 실제 완전 연결 검증 대상에서는 제외합니다.

### v1 완료 기준

상태이상 시스템 v1은 아래가 모두 충족될 때 완료로 간주합니다.

- `ice_glacial_dominion`, `plant_vine_snare`, `frost_nova`가 대표 스킬로 고정된다.
- `slow`, `root`, `freeze`가 실제 행동 효과까지 완전 연결된다.
- 첫 검증은 `leaper` 압박 상황에서 진행한다.
- 이후 `brute`, `bomber`, `elite`까지 동일 규칙으로 확대한다.
- `4개 적 아키타입 x 3개 대표 스킬`에 대해 적용, 저항, 재적용, 엘리트 차이가 GUT로 고정된다.

## 최소 피해 보장 규칙

방어력과 속성 저항을 모두 거친 뒤에도 최종 피해는 원피해의 일부를 보장합니다.

`최종 피해 = max(원피해 x 0.10, 감쇠 후 피해)`

의도:

- 고방어 적이 있어도 플레이어가 완전히 벽을 때리는 느낌이 나지 않게 합니다.
- 고단계 빌드가 항상 최소한의 진전은 내도록 만듭니다.

## 슈퍼아머 규칙

### 공통 원칙

- 슈퍼아머는 잡몹이 아니라 `엘리트/보스 전용`입니다.
- `무적`이 아니라 `강한 피해 경감 + 경직/넉백 무시` 상태로 취급합니다.
- 항상 대응 수단이 있어야 하며, 브레이크 후 짧은 취약 시간이 열려야 합니다.

### elite

- 상시 슈퍼아머 금지
- `특정 공격 패턴 중에만` 슈퍼아머 활성
- 슈퍼아머 중 실제 HP 피해: `최종 계산 피해의 20%`
- 브레이크 시 취약 시간: `2.5초`
- 취약 중 받는 피해 배수: `120%`

### boss

- 상시 슈퍼아머 또는 상시 + 강화형 패턴 허용
- 슈퍼아머 중 실제 HP 피해: `최종 계산 피해의 10%`
- 브레이크 시 취약 시간: `1.5초`
- 취약 중 받는 피해 배수: `120%`

### 브레이크 규칙

- 슈퍼아머 활성 중에도 브레이크 누적은 계속 쌓입니다.
- 브레이크 누적은 `슈퍼아머 감쇠 전 최종 계산 피해` 기준으로 누적합니다.

권장 기본값:

- `elite`: `super_armor_break_threshold = 최대 HP의 35%`
- `boss`: `super_armor_break_threshold = 최대 HP의 20%`

### 슈퍼아머 중 상태이상 처리

상태이상 완전 무효는 기본값으로 두지 않습니다. 대신 매우 높은 저항을 적용합니다.

예시 방향:

- 구속/중단 계열: 적용 확률 대폭 감소, 지속시간 대폭 감소
- 지속/약화 계열: 적용 확률 감소, 지속시간 크게 감소

## 최종 피해 계산 순서

적이 피해를 받을 때 계산 순서는 아래를 고정합니다.

1. 공격자 기본공격력
2. 스킬 계수와 고정 가산치
3. 공격자 버프/배수
4. 적 방어력
5. 적 속성 저항 또는 약점
6. 최소 피해 보정
7. 슈퍼아머 감쇠 또는 취약 보정
8. 기타 최종 배수

## 기준 공식 v1

```text
원피해 = (공격자 기본공격력 x 스킬계수 + 고정가산치) x 공격자 버프

방어 후 피해 = 원피해 x (100 / (100 + 대응 방어력))

속성 후 피해 = 방어 후 피해 x (1 - 속성저항값)

최소피해 보정 후 = max(원피해 x 0.10, 속성 후 피해)

슈퍼아머 중:
- elite 실제 피해 = max(1, 최소피해 보정 후 x 0.20)
- boss 실제 피해 = max(1, 최소피해 보정 후 x 0.10)
- 브레이크 누적치 += 최소피해 보정 후

취약 상태 중:
- 실제 피해 = 최소피해 보정 후 x 1.20
```

## 구현 연결 원칙

코드와 데이터는 아래 파일들과 함께 해석합니다.

- [skill_level_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_level_rules.md)
- [combat_increment_04_enemy_combat_set.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_04_enemy_combat_set.md)
- [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)
- `data/enemies/enemies.json`
- `scripts/enemies/enemy_base.gd`
- `scripts/autoload/game_state.gd`

## 구현자 체크리스트

- [ ] 적 스탯 키가 이 문서의 공통 구조와 일치하는가
- [ ] 방어력 공식이 이 문서의 공식과 일치하는가
- [ ] 속성 저항/약점 수치가 이 문서의 기본 범위를 벗어나면 이유가 문서화되어 있는가
- [ ] 상태이상 저항 처리 방식이 이 문서의 혼합 규칙과 일치하는가
- [ ] 슈퍼아머와 브레이크 로직이 이 문서의 등급별 규칙과 일치하는가
- [ ] 전투 수치 규칙이 바뀌었다면 이 문서를 함께 수정했는가
