---
title: 스킬 성장 축 목록
doc_type: catalog
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_level_rules.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - schema_changed
  - rule_changed
  - runtime_changed
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 스킬 성장 축 목록

상태: 사용 중  
최종 갱신: 2026-04-03  
섹션: 성장 시스템

## 범위

이 문서는 `data/skills/skills.json`의 `growth_tracks` 필드가 표현하는 성장축 이름과 사용 의도를 정리하는 기준 catalog입니다.

- 레벨/성장 규칙 자체는 [skill_level_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_level_rules.md)를 우선합니다.
- 필드 구조와 로드 시점 validation 범위는 [skill_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md)를 우선합니다.
- 현재 실제 사용값은 `skills.json`과 코드가 먼저 결정합니다.

## 현재 운영 규칙

- `growth_tracks`는 현재 로드 시점에 `array[string]` 구조까지만 hard validation합니다.
- 이 문서는 `현재 쓰는 성장축 이름이 무엇을 뜻하는가`를 정리하는 source 문서입니다.
- 새 성장축을 추가할 때는 같은 턴에 이 문서와 schema를 함께 갱신합니다.
- 향후 whitelist enum을 잠글 때는 먼저 이 catalog를 줄이고 의미를 잠근 뒤 validator를 따라오게 합니다.

## 성장 축 표

| growth_track | 의미 | 주 사용 타입 |
| --- | --- | --- |
| `damage` | 직접 피해 / tick 피해 증가 축 | `active`, `deploy`, `toggle` |
| `range` | 사거리, 반경, 오라 범위 증가 축 | `active`, `deploy`, `toggle` |
| `duration` | 버프/설치/오라 지속시간 증가 축 | `buff`, `deploy`, `toggle` |
| `targets` | 기본 대상 수 증가 축 | `active`, `deploy`, `toggle` |
| `pierce` | 관통 수 또는 연쇄 타격 수 증가 축 | `active`, `toggle` |
| `projectiles` | 투사체 수 증가 축 | `active`, `deploy` |
| `heal` | 회복량 / 치유 계수 증가 축 | `active`, `deploy` |
| `buff_power` | 버프 수치 강도 증가 축 | `buff` |
| `final_multiplier` | mastery나 최종 배수 계열 증가 축 | `passive` |
| `threshold_bonuses` | milestone 기반 보너스 묶음 | `passive` |
| `milestone` | 레벨 milestone 기반 특수 성장 메모용 축 | 예외 row / legacy 표기 |

## 데이터에서 실제 사용 중인 성장 축

2026-04-03 기준 `skills.json`에서 실제 관측된 성장 축은 아래와 같습니다.

`buff_power`, `damage`, `duration`, `final_multiplier`, `heal`, `milestone`, `pierce`, `projectiles`, `range`, `targets`, `threshold_bonuses`

## 운영 메모

- `growth_tracks`는 `이 row가 어떤 성장 설명을 가져야 하는가`를 읽기 쉽게 드러내는 메타 필드입니다.
- 실제 수치 계산은 개별 `*_per_level`, `damage_formula`, `milestone_bonuses`, `threshold_bonuses` 같은 세부 필드가 결정합니다.
- 따라서 `growth_tracks`는 계산식 source 자체가 아니라 `성장 방향 label`로 해석합니다.
- 새 축이 필요해도 계산 필드를 먼저 정의하지 않고 이름만 추가하는 것은 피합니다.
