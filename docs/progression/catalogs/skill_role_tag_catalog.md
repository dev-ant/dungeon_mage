---
title: 스킬 역할 태그 목록
doc_type: catalog
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - schema_changed
  - rule_changed
  - runtime_changed
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 스킬 역할 태그 목록

상태: 사용 중  
최종 갱신: 2026-04-03  
섹션: 성장 시스템

## 범위

이 문서는 `data/skills/skills.json`의 `role_tags` 필드가 어떤 의미로 쓰이는지 정리하는 기준 catalog입니다.

- 최신 스킬 이름, 서클, 컨셉은 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)를 우선합니다.
- 필드 구조와 로드 시점 validation 범위는 [skill_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md)를 우선합니다.
- 현재 실제 데이터에 어떤 태그가 쓰이고 있는지는 코드와 `skills.json`이 먼저 결정합니다.

## 현재 운영 규칙

- `role_tags`는 현재 로드 시점에 `array[string]` 구조까지만 hard validation합니다.
- 이 문서는 `현재 운영 중인 태그 목록과 의미`를 정리하는 source 문서입니다.
- 새 태그를 추가할 수는 있지만, 같은 턴에 이 문서와 schema를 함께 갱신해야 합니다.
- 아직 runtime whitelist는 잠그지 않았으므로, 이 문서는 `미래 enum hardening 후보 목록`도 겸합니다.

## 태그 분류

### 형태 / 전달 방식

| 태그 | 의미 |
| --- | --- |
| `projectile` | 기본 투사체형 |
| `line` | 직선형 / 관통형 |
| `cone` | 전방 cone / 즉발 pulse |
| `circle` | 원형 폭발 / 장판 중심 |
| `wall` | 장벽 생성형 |
| `aura` | 주변 지속형 오라 |
| `deploy` | 설치형 / 필드 배치형 |
| `summon` | 소환물 또는 개체 생성형 |

### 전투 역할

| 태그 | 의미 |
| --- | --- |
| `single_target` | 단일 대상 압박 |
| `aoe` | 광역 타격 |
| `mob_clear` | 다수 처리 특화 |
| `boss_burst` | 보스 순간 화력 특화 |
| `burst` | 순간 폭발 화력 |
| `dot` | 지속 피해 중심 |
| `control` | 위치 제어 / 상태 제어 |
| `soft_cc` | 둔화 / 밀쳐내기 위주 경제어 |
| `bind` | 속박 / 이동 고정 |
| `pull` | 적을 끌어모음 |
| `push` | 적을 밀어냄 |
| `pierce` | 관통 / 다중 대상 연쇄 |
| `heal` | 회복 역할 |
| `cleanse` | 해제 / 정화 역할 |
| `defense` | 방어 / 보호 역할 |
| `offense` | 공격 버프 / 딜 증폭 역할 |
| `utility` | 범용 유틸 / 비직접 화력 |
| `stability` | 생존 안정화 / 경직 저항 |
| `resist` | 저항 / 방어 보정 |
| `super_armor` | 슈퍼아머 보조 |
| `reflect` | 반사 / 역공 트리거 |
| `mobility` | 이동 / 기동성 강화 |
| `cast_speed` | 시전 속도 / 템포 강화 |
| `tempo` | 전투 리듬 가속 |
| `fortress` | 장기전 거점 유지 |
| `main_deploy` | 현재 빌드의 핵심 설치기 축 |
| `poke` | 견제형 소형 딜링 |
| `heavy` | 묵직한 일격 / 무게감 있는 히트 |
| `melee` | 근접 판정 중심 |
| `drain` | 흡수 / 자원 전환 |
| `curse` | 저주 / 디버프 위주 |
| `ritual` | 의식형 버프 / 위험한 준비 동작 |
| `finisher` | 마무리용 피니시 축 |
| `rule_break` | 리스크를 감수하는 특수 규칙 파괴형 |
| `burst_window` | 짧은 극딜 창구 생성 |
| `auto_strike` | 자동 추적 / 자동 낙뢰 / 자동 타격 |

### 속성 / 계열 힌트

| 태그 | 의미 |
| --- | --- |
| `fire` | 화염 정체성 강조 |
| `water` | 물 정체성 강조 |
| `ice` | 얼음 정체성 강조 |
| `lightning` | 번개 정체성 강조 |
| `wind` | 바람 정체성 강조 |
| `earth` | 대지 정체성 강조 |
| `plant` | 식물 정체성 강조 |
| `dark` | 흑마법 / 암흑 정체성 강조 |
| `arcane` | 아케인 / 공용 마법 정체성 강조 |
| `fire_dark` | 화염 + 흑마법 혼합 정체성 |

### 시스템 / 운영 메타 태그

| 태그 | 의미 |
| --- | --- |
| `mastery` | 패시브 mastery row |
| `global` | 전 school 공용 적용 |
| `universal` | 빌드 무관 범용 지원 |
| `starter` | 초반 기본기 / 시작 해금 row |

## 데이터에서 실제 사용 중인 태그

2026-04-03 기준 `skills.json`에서 실제 관측된 태그는 아래와 같습니다.

`aoe`, `arcane`, `aura`, `auto_strike`, `bind`, `boss_burst`, `burst`, `burst_window`, `cast_speed`, `chain`, `circle`, `cleanse`, `cone`, `control`, `curse`, `dark`, `defense`, `deploy`, `dot`, `drain`, `earth`, `finisher`, `fire`, `fire_dark`, `fortress`, `global`, `heal`, `heavy`, `ice`, `lightning`, `line`, `main_deploy`, `mastery`, `melee`, `mob_clear`, `mobility`, `offense`, `pierce`, `plant`, `poke`, `projectile`, `pull`, `push`, `reflect`, `resist`, `ritual`, `rule_break`, `single_target`, `slow`, `soft_cc`, `stability`, `starter`, `summon`, `super_armor`, `tempo`, `universal`, `utility`, `wall`, `water`, `wind`

## 운영 메모

- 태그는 중복 없이 쓰는 것을 기본값으로 둡니다.
- `shape` 성격 태그와 `combat role` 태그를 함께 써도 됩니다.
- 태그 추가는 허용하지만, 의미가 겹치는 새 태그를 늘리기보다 기존 태그 재사용을 우선합니다.
- future hardening에서 whitelist enum을 잠글 때는 이 문서를 먼저 줄여서 정리한 뒤 validator를 따라오게 합니다.
