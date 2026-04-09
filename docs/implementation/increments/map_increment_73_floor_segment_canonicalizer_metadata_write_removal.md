---
title: 맵 증분 73 - floor segment canonicalizer metadata write 제거
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_72_floor_segment_format_metadata_retirement.md
last_updated: 2026-04-08
last_verified: 2026-04-08
---

# 맵 증분 73 - floor segment canonicalizer metadata write 제거

## 목표

`floor_segment_format` live metadata retirement 이후에도 offline canonicalizer가 room rewrite 시 metadata를 다시 쓰던 경로를 제거해 tooling contract까지 metadata-optional 상태로 잠근다.

## 이번에 잠근 결정

- `scripts/tools/floor_segment_canonicalizer.gd`는 이제 room rewrite 시 `floor_segments`만 갱신하고 `floor_segment_format`를 쓰지 않는다.
- canonicalizer 내부의 legacy fallback helper (`_is_legacy_floor_segment_fallback_dictionary`)를 제거해 canonical dictionary parse 실패 경로 하나로 단순화한다.
- `GameDatabase.normalize_floor_segment_to_canonical_dictionary()` helper에서도 legacy fallback probe 분기를 줄이고 canonical `position/size` parse 결과만으로 정규화 여부를 판단한다.
- `tests/test_project_rules.gd`에 canonicalizer source contract 테스트를 추가해 metadata write/legacy helper 재도입 회귀를 막는다.

## 왜 지금 잠갔는가

- runtime/validation/live data가 이미 metadata-optional canonical-only로 잠긴 상태에서 tooling만 metadata를 다시 쓰면 계약이 흔들린다.
- canonicalizer와 helper에서 legacy shape 분기를 더 줄이면 fixture/회귀 포인트가 payload shape 하나로 수렴해 유지보수가 단순해진다.

## 이번 증분에서 확인한 것

- canonicalizer source에는 `room["floor_segment_format"]` write가 더 이상 없다.
- canonicalizer source에는 retired legacy fallback helper가 더 이상 없다.
- floor-segment 관련 GUT와 headless 부팅 검증은 변경 후에도 통과한다.

## 의도적으로 제외한 것

- validator에서 `floor_segment_format` 키 자체를 완전히 금지하는 breaking change
  - 후속으로 [map_increment_74_floor_segment_format_key_retirement.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_74_floor_segment_format_key_retirement.md)에서 처리됨
- 과거 increment 문서 전체의 historical narrative 정리
