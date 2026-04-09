---
title: 버프 조합 태그 목록
doc_type: catalog
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_skill_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md
update_when:
  - rule_changed
  - data_changed
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 버프 조합 태그 목록

상태: 사용 중  
최종 갱신: 2026-04-03  
섹션: 성장 시스템

## 범위

이 문서는 `data/skills/skills.json`의 `skill_type = buff` row가 쓰는 `combo_tags`의 현재 운영 목록과 의미를 정리하는 기준 catalog입니다.

- 실제 버프 조합 이름과 효과는 [buff_combo_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md)가 관리합니다.
- `combo_tags`는 조합 이름 자체가 아니라, 개별 버프 row를 조합 규칙과 느슨하게 연결하는 저수준 태그입니다.
- 현재 runtime은 `combo_tags`를 로드 시점에 `array[string]` 구조까지 hard validation하고, 이 catalog 바깥 값은 `warning-only`로 드리프트를 알립니다.
- 새 태그가 정말 필요하면 이 catalog와 `GameDatabase` validator를 같은 턴에 같이 갱신합니다.

## 태그 설계 원칙

- 태그는 짧고 재사용 가능한 의미 단위로 유지합니다.
- 버프 하나에 `1~3`개 정도만 붙여 조합 의도를 읽을 수 있게 합니다.
- named combo를 그대로 태그로 복사하지 않습니다.
- 속성 축과 전투 기능 축을 섞되, 같은 의미를 중복 표기하지 않습니다.

## 현재 운영 태그

2026-04-03 기준 `skills.json`에서 실제 관측된 `combo_tags`는 아래 18개입니다.

### 속성 / 계열 축

| 태그 | 의미 | 현재 예시 |
| --- | --- | --- |
| `arcane` | 공용 아케인 버프 축 | Astral Compression, World Hourglass |
| `dark` | 흑마법 축 | Grave Pact, Throne of Ash |
| `fire` | 화염 축 | Pyre Heart |
| `holy` | 백마법/성역 방어 축 | Crystal Aegis |
| `ice` | 빙결 축 | Frostblood Ward |
| `lightning` | 번개 축 | Conductive Surge |
| `plant` | 식물/설치 보조 축 | Verdant Overflow |
| `wind` | 바람/기동 축 | Tempest Drive |

### 기능 / 조합 힌트 축

| 태그 | 의미 | 현재 예시 |
| --- | --- | --- |
| `ash` | 잿불 의식/흑화염 최종 창구 | Throne of Ash |
| `compression` | 데미지 압축, 마나 효율 상승 | Astral Compression |
| `deploy` | 설치형 강화 또는 설치 조합 연결 | Verdant Overflow |
| `guard` | 방어, 보호막, 경직 안정화 | Mana Veil, Crystal Aegis |
| `ignition` | 화염 점화/폭발 시동 | Pyre Heart |
| `ritual` | 의식형 고위험 버프 | Grave Pact, Throne of Ash |
| `tempo` | 속공 템포, 후딜 감소, 기동 리듬 | Tempest Drive, Conductive Surge |
| `time` | 시간 압축, 극딜 타이밍 열기 | World Hourglass |
| `veil` | 보호막/막 계열 초입 버프 | Mana Veil |
| `ward` | 방호 결계/반사 방어 축 | Frostblood Ward |

## 운영 메모

- `combo_tags`는 open text처럼 보이지만, 실제 운영상은 이 catalog를 기준으로 관리합니다.
- 다만 2026-04-03 현재 단계에서는 기존 데이터를 한 번에 깨지 않기 위해 out-of-catalog 값을 `error`가 아니라 `warning`으로만 다룹니다.
- named combo 변경이 있어도 버프 간 의미 연결이 유지되면 `combo_tags`를 바로 바꿀 필요는 없습니다.
- 새 버프를 추가할 때는 [buff_skill_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_skill_catalog.md), [buff_combo_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md), [skill_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md)를 함께 확인합니다.
