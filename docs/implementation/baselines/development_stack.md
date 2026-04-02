---
title: 개발 스택
doc_type: baseline
status: active
section: implementation
owner: runtime
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - runtime_changed
  - structure_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 개발 스택

상태: 사용 중  
최종 갱신: 2026-03-27  
섹션: 구현 기준

## 범위

이 문서는 구현에 사용해야 하는 기본 툴과 규칙의 기준 문서입니다.

## 설치된 애드온

- `Phantom Camera` 경로: `res://addons/phantom_camera`
- `Godot State Charts` 경로: `res://addons/godot_state_charts`
- `GUT` 경로: `res://addons/gut`

## 필수 사용 규칙

- 카메라 작업은 `PhantomCameraHost`와 `PhantomCamera2D`를 사용합니다.
- 엔티티 상태 흐름은 `Godot State Charts`를 사용합니다.
- 게임플레이 상태와 유틸리티 검증은 `GUT`를 사용합니다.

## 현재 프로젝트 사용 상태

- `scenes/main/Main.tscn`은 플레이어 추적 카메라와 이벤트 카메라에 `Phantom Camera`를 사용합니다.
- `scripts/enemies/enemy_base.gd`는 적 상태 흐름에 `Godot State Charts`를 사용합니다.
- `tests/test_game_state.gd`는 `GUT` 기반 테스트를 사용합니다.

## 검증 명령어

- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
