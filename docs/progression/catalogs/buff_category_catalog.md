---
title: 버프 카테고리 목록
doc_type: catalog
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/buff_system.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_skill_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md
update_when:
  - rule_changed
  - runtime_changed
  - data_changed
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 버프 카테고리 목록

상태: 사용 중  
최종 갱신: 2026-04-03  
섹션: 성장 시스템

## 범위

이 문서는 `skills.json`의 buff row가 사용하는 `buff_category`의 현재 운영 목록과 의미를 정리하는 closed catalog입니다.

- `buff_category`는 자유 입력 태그가 아니라 버프 운영 성격을 구분하는 관리 enum입니다.
- 현재 runtime validator는 catalog 밖 값을 즉시 `error`로 처리합니다.
- 새 category를 추가하거나 이름을 바꾸려면 [game_database.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd)의 `VALID_BUFF_CATEGORIES`와 이 문서를 같은 턴에 같이 갱신합니다.

## 현재 운영 카테고리

| ID | 의미 | 현재 예시 |
| --- | --- | --- |
| `defense` | 생존, 경직 안정화, 방호 성격의 버프. 피해 감소나 방어적 보조를 담당한다 | Mana Veil, Crystal Aegis, Frostblood Ward |
| `offense` | 직접 피해 증폭이나 공격 창구 확대를 담당하는 공격형 버프 | Pyre Heart, Conductive Surge, Astral Compression |
| `tempo` | 이동, 캐스팅, 후딜, 쿨 회전처럼 전투 리듬을 빠르게 만드는 템포형 버프 | Tempest Drive, World Hourglass |
| `ritual` | 고위험 고보상 의식형 버프. 강한 리스크와 폭발 창구를 함께 가진다 | Grave Pact, Throne of Ash |
| `utility` | 설치, 범위, 편의, 운용 안정성처럼 빌드 구조를 보조하는 버프 | Verdant Overflow |

## 운영 메모

- 현재 checked-in 데이터는 위 5개 category만 사용합니다.
- `buff_category`는 조합 태그나 중첩 규칙 ID와 달리 “버프의 대표 전투 역할”을 빠르게 분류하는 축입니다.
- 세부 효과나 중첩 규칙은 [buff_skill_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_skill_catalog.md), [buff_stack_rule_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_stack_rule_catalog.md), [buff_combo_tag_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_tag_catalog.md)를 같이 봅니다.
