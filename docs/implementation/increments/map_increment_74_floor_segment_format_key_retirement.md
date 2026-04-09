---
title: 맵 증분 74 - floor segment format key 완전 퇴역
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_73_floor_segment_canonicalizer_metadata_write_removal.md
last_updated: 2026-04-08
last_verified: 2026-04-08
---

# 맵 증분 74 - floor segment format key 완전 퇴역

## 목표

`floor_segment_format`를 optional metadata로 남겨 둔 마지막 validator compatibility를 제거해, floor segment 계약을 payload shape(`position/size`)만으로 완전히 닫는다.

## 이번에 잠근 결정

- `scripts/autoload/game_database.gd` room floor-segment validator는 `floor_segment_format` key가 있으면 값과 무관하게 authoring error로 거부한다.
- 즉 `legacy_array`뿐 아니라 `canonical_dict` 값도 허용하지 않는다.
- floor segment canonical 계약의 source of truth는 `floor_segments` entry shape와 override field(`decor_kind`, `collision_mode`)만 남는다.
- floor-segment validation 테스트는 key 금지 계약을 직접 검증하도록 갱신한다.

## 왜 지금 잠갔는가

- checked-in/generated room 모두 이미 key를 기록하지 않는 canonical payload로 잠겼다.
- metadata를 validator에서 계속 허용하면 tooling이나 fixture에서 키가 재유입될 여지가 남는다.
- key를 완전히 퇴역시키면 계약 위반 원인이 오직 payload shape로 수렴해 디버깅이 단순해진다.

## 이번 증분에서 확인한 것

- `floor_segment_format` key를 넣은 synthetic room fixture는 validation error가 발생한다.
- floor-segment targeted GUT, room-builder regression, 전체 GUT, headless boot 검증이 모두 통과한다.

## 의도적으로 제외한 것

- `floor_segments` 구조 재설계/마이그레이션
- player drop-through helper 확장(예: 추가 입력 규칙)
