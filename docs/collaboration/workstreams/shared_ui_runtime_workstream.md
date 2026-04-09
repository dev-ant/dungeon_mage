---
title: 통합 UI 런타임 작업 스트림
doc_type: tracker
status: active
section: collaboration
owner: shared
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/single_stream_collaboration.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/maple_style_ui_migration_plan.md
update_when:
  - runtime_changed
  - handoff_changed
  - validation_changed
last_updated: 2026-04-10
last_verified: 2026-04-10
---

# 통합 UI 런타임 작업 스트림

상태: 사용 중  
최종 갱신: 2026-04-10  
운영 모드: single-stream

## 목적

이 문서는 `owner_core` 와 `friend_gui` 로 나뉘어 있던 병렬 workstream을 종료한 뒤, 현재 단일 구현 흐름의 `현재 상태`, `다음 우선 작업`, `검증 상태`, `known risk`만 빠르게 읽기 위한 활성 tracker다.

2026-04-10 기준으로 새 진행 로그는 이 문서에만 남기고, 기존 `owner_core_workstream.md`, `friend_gui_workstream.md` 는 읽기 전용 legacy 문서로 취급한다.

## 먼저 읽을 문서

1. [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md)
2. [docs/governance/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md)
3. [ai_update_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md)
4. [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
5. [single_stream_collaboration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/single_stream_collaboration.md)
6. [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)
7. [maple_style_ui_migration_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/maple_style_ui_migration_plan.md)

## 현재 우선순위

1. Maple-style UI 마이그레이션의 남은 시각 마감 작업을 닫는다.
2. `소비 / 기타` 인벤토리의 실제 전장 드롭/경제 루프를 런타임에 연결한다.
3. 통합 문서 체계 기준으로 legacy owner/friend prompt와 handoff 문서를 정리한다.

## 현재 런타임 상태

- `ESC / I / K / E / T / Q` 창 시스템, topmost close, draggable floating window, window opacity persistence가 실제 runtime에 있다.
- `InventoryWindow / SkillWindow / KeyBindingsWindow / SettingsWindow / EquipmentWindow / StatWindow / QuestWindow` 가 모두 실제 입력 경로와 연결되어 있다.
- `InventoryWindow` 는 `장비 / 소비 / 기타` 3탭, `20칸` grid, organize, drag swap/move, stack merge, use/equip action까지 runtime에 연결돼 있다.
- `SkillWindow`, `KeyBindingsWindow`, HUD quickslot 은 direct drag bind, fixed 21-slot action registry, pseudo-icon, drag ghost preview를 실제 제공한다.
- `SettingsWindow` 는 `오디오 / 그래픽 / 효과 / HUD` 탭, custom slider/checkbox skin, HUD visibility persistence, `Music / SFX / Effect` bus volume apply까지 닫혔다.
- 공통 `UiWindowFrame` 는 close button skin, accent strip, shared tab/action helpers, settings row skin helper를 제공한다.

## 검증 상태

- 최신 headless startup: `godot --headless --path . --quit` 통과
- 최신 전체 GUT: `1264/1264 passed`
- 알려진 종료 경고: `ObjectDB instances leaked at exit`

## Known Risk

- 최종 checked-in icon atlas / frame texture / tab texture는 아직 없어 일부 UI는 procedural skin 기반이다.
- target panel은 아직 explicit lock-on이 아니라 `가장 가까운 살아 있는 적` 휴리스틱을 사용한다.
- `소비 / 기타` 아이템은 GUI와 save path는 닫혔지만 실제 전장 드롭/경제 루프는 아직 장비 위주다.
- legacy owner/friend prompt 문서는 아직 보존 중이며, 새 single-stream prompt로 완전 전환되기 전까지 혼용 리스크가 있다.

## 다음 구현 handoff

1. `Phase 7` follow-up으로 `slot / tab / frame`의 최종 texture skin 또는 checked-in atlas 통합 여부를 정한다.
2. `Phase 8` follow-up으로 legacy prompt 진입점과 archive 링크를 shared policy 기준으로 더 정리한다.
3. `consumable / other` drop 루프를 `GameState` inventory source of truth와 연결한다.

## Legacy 문서

- [owner_core_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/owner_core_workstream.md)
- [friend_gui_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/friend_gui_workstream.md)

