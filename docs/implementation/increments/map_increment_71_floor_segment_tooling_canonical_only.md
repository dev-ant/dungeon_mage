---
title: 맵 증분 71 - floor segment tooling canonical-only
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_70_floor_segment_runtime_legacy_removal.md
last_updated: 2026-04-08
last_verified: 2026-04-08
---

# 맵 증분 71 - floor segment tooling canonical-only

## 목표

runtime/validation canonical-only 전환 이후 오프라인 canonicalizer/helper에만 남아 있던 legacy floor-segment 변환 분기를 제거해 `floor_segments` 계약을 tooling까지 canonical-only로 닫는다.

## 이번에 잠근 결정

- `scripts/tools/floor_segment_canonicalizer.gd`는 더 이상 legacy array `[x, y, width, height]`나 `x/y/width/height` fallback dictionary를 변환하지 않는다.
- canonicalizer는 canonical dictionary shape가 아닌 floor segment를 만나면 now fail-fast로 종료한다.
- `GameDatabase.normalize_floor_segment_to_canonical_dictionary()` helper도 canonical dictionary 입력만 정규화하고 legacy shape는 빈 결과로 거부한다.
- 관련 테스트 fixture는 legacy 변환 기대 대신 legacy reject 계약으로 단순화한다.

## 왜 지금 잠갔는가

- checked-in room과 generated room 모두 canonical dict로 이미 잠겨 있어 legacy 변환을 툴링에 유지할 실소비자가 없다.
- runtime/validation/tooling이 같은 입력 계약을 사용해야 회귀 원인 추적이 단순해진다.
- canonicalizer가 legacy를 묵시적으로 변환하면 잘못된 데이터가 조용히 통과할 위험이 있었다.

## 이번 증분에서 확인한 것

- floor-segment 관련 helper/validator/test seam은 모두 canonical-only로 정렬됐다.
- room builder regression과 floor-segment targeted GUT는 canonical-only tooling 변경 이후에도 통과한다.
- 전체 GUT는 현재 floor-segment 변경과 무관한 `test_large_stationary_burst_ground_telegraph_plays_startup_ring_intro` failure 1건이 남는다.

## 의도적으로 제외한 것

- historical increment 문서의 narrative 정리/archive 레이블링
- floor-segment 외 다른 legacy compatibility 정리
