---
title: 기초 설정 인덱스
doc_type: index
status: active
section: foundation
owner: design
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/target_doc_structure.md
update_when:
  - structure_changed
  - rule_changed
last_updated: 2026-04-06
last_verified: 2026-04-06
---

# 기초 설정 인덱스

상태: 사용 중  
최종 갱신: 2026-04-06

## 범위

이 섹션은 세계관 정설, 주인공 기본 설정, 미궁 전제, 서사 진행, 스토리 의도를 정의합니다.

2026-04-02 기준으로 `foundation`의 1차 하위 폴더 분리가 적용되었고, 현재 살아 있는 기준 문서는 `rules/`, `catalogs/` 아래에서 관리합니다.

이 섹션의 상세 문서 등록 책임은 이 `README.md`가 가집니다. 루트 `docs/README.md`에는 대표 진입점만 유지합니다.

## 문서 목록

### `rules/`

- [world_and_power.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/world_and_power.md)
- [protagonist.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/protagonist.md)
- [dungeon_premise.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_premise.md)
- [dungeon_floor_structure.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_floor_structure.md)
- [story_arc.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/story_arc.md)
- [art_direction.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/art_direction.md)

### `catalogs/`

- [ai_style_board.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/catalogs/ai_style_board.md)

### `archive/`

- 현재 비어 있습니다. 폐기되거나 dated snapshot 성격의 기초 설정 문서는 이 폴더로 이동합니다.

## 수정 규칙

- 세계관 계급과 서클 체계는 `rules/world_and_power.md`를 수정합니다.
- 주인공 정체성과 기본 판타지는 `rules/protagonist.md`를 수정합니다.
- 미궁 사실과 졸업 시험 전제는 `rules/dungeon_premise.md`를 수정합니다.
- 층별 맵 역할과 공간 해석 기준은 `rules/dungeon_floor_structure.md`를 수정합니다.
- 기승전결과 스토리 의도는 `rules/story_arc.md`를 수정합니다.
- 전체 비주얼 방향과 AI img2img 기준은 `rules/art_direction.md`를 수정합니다.
- 카테고리별 AI reference board와 prompt anchor는 `catalogs/ai_style_board.md`를 수정합니다.
- 기초 설정 문서를 새로 만들 때는 먼저 이 인덱스에 등록하고, 문서 타입에 따라 기본 위치를 `rules/` 또는 `catalogs/`로 둡니다.
