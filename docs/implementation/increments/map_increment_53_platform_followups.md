---
title: 맵 증분 53 - one-way platform 후속 작업
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_05_prototype_flow.md
last_updated: 2026-04-10
last_verified: 2026-04-10
---

# 맵 증분 53 - one-way platform 후속 작업

## 목표

thin `floor_segments`를 one-way platform으로 바꾼 현재 증분 다음에, 반드시 이어서 처리할 follow-up 범위를 잊지 않도록 현재 저장소 기준으로 고정한다.

## 현재 잠긴 상태

- `scripts/world/room_builder.gd`는 `size.y <= ROOM_FLOOR_THRESHOLD` thin segment를 one-way top-strip collision으로 생성한다.
- 일반 ground segment와 좌우 boundary wall은 full solid collision을 유지한다.
- 현재 build는 `아래 + 점프` 드롭다운 입력을 지원한다.
- 현재 구현은 room-builder one-way collision에 더해, `player.gd`가 현재 밟고 있는 `one_way_platform`에 짧은 collision exception window를 거는 최소 drop-through helper를 가진다.

## 요청된 후속 작업 세트와 현재 상태

아래 세 작업은 one-way platform 증분 직후 사용자 요청으로 명시적으로 기억해 두기로 한 follow-up 세트다.

1. 완료: `아래 + 점프` 입력으로 현재 밟고 있는 platform 아래로 내려가기
2. 완료: `floor_segments` canonical format은 dictionary `{position, size}`로 잠겼고 generated room canonical emit, checked-in room 전면 canonical migration, validator, migration tool, runtime canonical-only path, offline canonicalizer/helper canonical-only cleanup, `floor_segment_format` live metadata retirement 및 validator key 금지까지 landed 됐다.
3. 최소 완료: `player.gd` 쪽 별도 drop-through/helper 로직 추가

## 실행 메모

- 1번은 현재 플레이 감각을 완성하는 가장 작은 후속 증분으로 이번 구현에서 landed 됐다.
- 2번은 현재 `floor_segments` 계약을 한 번에 뒤엎지 않기 위해 additive schema, validation seam, generated room canonical emit, checked-in room 전면 canonical migration, migration tool, default runtime canonical-first path, 최종 runtime legacy 제거, offline canonicalizer/helper legacy 제거, `floor_segment_format` live metadata retirement 및 validator key 금지까지 landed 됐다. 자세한 잠금 내용은 [map_increment_54_floor_segment_override_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_54_floor_segment_override_schema.md), [map_increment_55_floor_segment_validation.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_55_floor_segment_validation.md), [map_increment_56_floor5_live_floor_segment_dict.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_56_floor5_live_floor_segment_dict.md), [map_increment_57_anchor_floor_segment_dict_pilot.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_57_anchor_floor_segment_dict_pilot.md), [map_increment_58_second_anchor_floor_segment_dict_pilot.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_58_second_anchor_floor_segment_dict_pilot.md), [map_increment_59_floor_segment_canonical_lock.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_59_floor_segment_canonical_lock.md), [map_increment_60_gate_threshold_canonical_floor_segment_migration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_60_gate_threshold_canonical_floor_segment_migration.md), [map_increment_61_royal_inner_hall_canonical_floor_segment_migration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_61_royal_inner_hall_canonical_floor_segment_migration.md), [map_increment_62_throne_approach_canonical_floor_segment_migration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_62_throne_approach_canonical_floor_segment_migration.md), [map_increment_63_inverted_spire_canonical_floor_segment_migration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_63_inverted_spire_canonical_floor_segment_migration.md), [map_increment_64_arcane_core_canonical_floor_segment_pilot.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_64_arcane_core_canonical_floor_segment_pilot.md), [map_increment_65_void_rift_canonical_floor_segment_pilot.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_65_void_rift_canonical_floor_segment_pilot.md), [map_increment_66_deep_gate_canonical_floor_segment_pilot.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_66_deep_gate_canonical_floor_segment_pilot.md), [map_increment_67_conduit_canonical_floor_segment_pilot.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_67_conduit_canonical_floor_segment_pilot.md), [map_increment_68_vault_sector_canonical_floor_segment_completion.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_68_vault_sector_canonical_floor_segment_completion.md), [map_increment_69_floor_segment_legacy_runtime_boundary.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_69_floor_segment_legacy_runtime_boundary.md), [map_increment_70_floor_segment_runtime_legacy_removal.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_70_floor_segment_runtime_legacy_removal.md), [map_increment_71_floor_segment_tooling_canonical_only.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_71_floor_segment_tooling_canonical_only.md), [map_increment_72_floor_segment_format_metadata_retirement.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_72_floor_segment_format_metadata_retirement.md), [map_increment_73_floor_segment_canonicalizer_metadata_write_removal.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_73_floor_segment_canonicalizer_metadata_write_removal.md), [map_increment_74_floor_segment_format_key_retirement.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_74_floor_segment_format_key_retirement.md), [map_increment_75_room_builder_metadata_independence.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_75_room_builder_metadata_independence.md)에 정리한다.
- 2번 후속으로 runtime warning/validator error의 legacy floor-segment 토큰 계약(`legacy floor segment array|dictionary`)도 [map_increment_76_floor_segment_legacy_token_alignment.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_76_floor_segment_legacy_token_alignment.md)에서 잠겼다.
- 같은 축의 다음 후속으로 validator helper 내부 parse도 canonical array-only로 단순화됐다. `x/y/width/height` fallback parse branch 제거와 회귀 규칙은 [map_increment_77_floor_segment_validator_parse_canonical_only.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_77_floor_segment_validator_parse_canonical_only.md)에 정리한다.
- 같은 축의 다음 후속으로 `tests/test_game_state.gd` floor-segment helper도 canonical `position/size` array만 읽도록 잠겼다. legacy parse 토큰 재유입 방지는 [map_increment_78_floor_segment_test_helper_canonical_only.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_78_floor_segment_test_helper_canonical_only.md)에 정리한다.
- 같은 테스트 축의 후속으로 floor-segment 음수 fixture도 helper로 묶어 canonical/legacy 회귀 입력 소스를 한 곳으로 잠갔다. fixture helper 재유입 규칙은 [map_increment_79_floor_segment_test_fixture_helper_lock.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_79_floor_segment_test_fixture_helper_lock.md)에 정리한다.
- 같은 tooling 축의 후속으로 offline canonicalizer의 중복 floor-segment parse/emit helper를 제거하고 `GameDatabase.normalize_floor_segment_to_canonical_dictionary()` 단일 helper로 위임했다. canonical parse source 일원화 규칙은 [map_increment_80_floor_segment_canonicalizer_helper_delegation.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_80_floor_segment_canonicalizer_helper_delegation.md)에 정리한다.
- 같은 tooling 축의 다음 후속으로 canonicalizer에 static normalization seam을 추가해 실행 계약(`ok/segments/error`, 첫 invalid index 보고)을 headless-friendly 단위 테스트로 잠갔다. 회귀 규칙은 [map_increment_81_floor_segment_canonicalizer_execution_seam.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_81_floor_segment_canonicalizer_execution_seam.md)에 정리한다.
- 같은 tooling 축의 다음 후속으로 canonicalizer room-id selection도 static seam으로 분리해 CLI 계약(`인자 없음 usage error`, `room id 미매치 error`, `catalog order match index`)을 headless 단위 테스트로 잠갔다. 회귀 규칙은 [map_increment_82_floor_segment_canonicalizer_cli_match_seam.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_82_floor_segment_canonicalizer_cli_match_seam.md)에 정리한다.
- player 하드닝 축의 다음 후속으로 drop-through 시작 조건을 dead/hit/rope/active 상태에서 차단하고 stale platform 해제 회귀를 추가해 최소 helper 안전성을 강화했다. 회귀 규칙은 [map_increment_83_player_drop_through_hardening.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_83_player_drop_through_hardening.md)에 정리한다.
- 3번은 이번 증분에서 최소 범위로 landed 됐고, 이후 데이터 구조 조정이나 edge case가 늘어날 때만 확장한다.

## 예상 파일 터치포인트

- [scripts/world/room_builder.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/room_builder.gd)
- [scripts/player/player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)
- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
- [tests/test_room_builder.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_room_builder.gd)
- [tests/test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)

## 보류 규칙

- `floor_segments` 전면 재설계는 현재 one-way platform 계약, additive dictionary override schema, validation seam을 먼저 굳힌 뒤에만 건드린다.
- 현재 `player.gd` helper는 드롭다운 입력만 닫는 최소 범위로 제한한다.
