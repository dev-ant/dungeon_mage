---
title: 맵 증분 70 - floor segment runtime legacy removal
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_69_floor_segment_legacy_runtime_boundary.md
last_updated: 2026-04-08
last_verified: 2026-04-08
---

# 맵 증분 70 - floor segment runtime legacy removal

## 목표

`floor_segments` checked-in data와 generated room이 모두 canonical dict로 잠긴 뒤 남아 있던 runtime legacy compatibility seam을 실제 코드에서 제거한다.

## 이번에 잠근 결정

- `scripts/world/room_builder.gd`는 이제 `floor_segment_format = legacy_array`를 봐도 runtime에서 legacy array나 `x/y/width/height` fallback을 복구하지 않는다.
- `GameDatabase` room validation도 canonical-only로 잠겼다. `legacy_array` format flag 자체가 이제 retired authoring 값이다.
- runtime/validation에서 제거된 legacy shape 해석은 오직 offline canonical migration helper/tool에만 남긴다.

## 왜 지금 제거했는가

- checked-in `rooms.json`과 generated prototype room에 더 이상 live legacy consumer가 없었다.
- 이전 증분 69에서 compatibility seam을 눈에 보이게 분리했기 때문에, 이번엔 runtime branch를 지워도 영향 범위를 명확히 검증할 수 있었다.
- one-way platform contract와 canonical dict authoring contract가 이제 같은 방향으로 완전히 정렬됐다.

## 이번 증분에서 실제로 확인한 것

- checked-in canonical room build와 generated floor 5 build는 그대로 유지된다.
- synthetic room fixture는 canonical dict 기준으로 representative collision/landmark 구조를 계속 검증한다.
- retired `legacy_array` format flag와 legacy raw entry는 validation error 또는 runtime warning으로만 남고, 실제 빌드 결과에는 더 이상 참여하지 않는다.

## 여전히 보류한 것

- offline canonicalizer/helper에서 legacy normalization branch를 언제 제거할지
- historical increment 문서들에 남아 있는 additive migration narrative를 archive-level로 정리할지 여부
