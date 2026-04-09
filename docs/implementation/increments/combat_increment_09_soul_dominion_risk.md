---
title: 전투 9차 작업 체크리스트 - Soul Dominion 리스크 구현
doc_type: plan
status: active
section: implementation
owner: runtime
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/buff_system.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 전투 9차 작업 체크리스트 - Soul Dominion 리스크 구현

상태: 구현 완료
최종 갱신: 2026-03-28
섹션: 구현 완료

## 목표

이 문서는 `Soul Dominion`의 전용 리스크를 Claude가 안전하게 단계별로 구현할 수 있도록 정리한 handoff 문서다.

이번 작업은 단순 토글 수치 조정이 아니라 `플레이어 자원`, `피해 배수`, `HUD`, `자동 해제`, `종료 후 후유증`이 함께 얽힌다. 범위가 커서 반쪽 구현보다 별도 증분으로 처리하는 편이 안전하다.

## 현재 상태

- [spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd)에서 토글형 스킬의 유지 마나 소모는 데이터 기반으로 동작한다.
- `Glacial Dominion`은 둔화 유틸리티를 실제 적에게 전달한다.
- `Tempest Crown`은 토글 오라 타격에 관통 수치가 실제 반영된다.
- `Soul Dominion`은 현재 강한 유지 마나 소모를 갖지만, 문서상 부작용인 `마나 재생 차단`, `피해 증가`, `종료 후 후유증`은 아직 런타임에 직접 반영되지 않는다.

## Claude 작업 목표

1. `Soul Dominion` 유지 중에는 플레이어의 MP 재생을 0으로 만든다.
2. `Soul Dominion` 유지 중에는 받는 피해 배수를 높인다.
3. 유지 종료 시 짧은 후유증 상태를 적용한다.
4. HUD에서 이 리스크를 바로 읽을 수 있게 표시한다.

## 권장 구현 순서

1. [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)에 `soul_dominion_active`, `soul_dominion_aftershock_time` 같은 런타임 상태를 추가한다.
2. [spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd)에서 `dark_soul_dominion` 토글 on/off 시 전용 상태를 `GameState`에 알린다.
3. MP 재생 계산과 플레이어 피해 계산에 전용 리스크 배수를 연결한다.
4. HUD에 `Soul Dominion ACTIVE`, `Aftershock`, `MP Regen Locked` 같은 짧은 상태 문구를 노출한다.
5. GUT 테스트로 유지 중 MP 재생 차단, 종료 후 후유증, 피해 배수 증가를 검증한다.

## 비목표

- 새로운 전용 이펙트 씬 추가
- 전체 토글형 공통 리스크 시스템 일반화
- 버프 조합 재설계

## 수용 기준

- `Soul Dominion` 유지 중 MP가 자연 회복되지 않는다.
- `Soul Dominion` 유지 중 플레이어가 더 큰 피해를 받는다.
- 토글 종료 후 짧은 후유증이 남고 HUD에서 읽힌다.
- 기존 토글형과 관리자 프리셋 흐름을 깨지 않는다.

## 테스트 체크포인트

- `Soul Dominion` on 상태에서 일정 시간 후 MP가 증가하지 않음
- `Soul Dominion` off 직후 후유증 타이머 생성
- 후유증 동안 피해 배수 또는 MP 회복 제한 유지
- `ApexToggles` 프리셋에서 headless/GUT 회귀 통과

## 구현 결과 (2026-03-28)

### 런타임 상태
- `GameState.soul_dominion_active: bool` — Soul Dominion 토글 ON 시 true
- `GameState.soul_dominion_aftershock_timer: float` — 종료 후 5초 카운트다운
- 상수: `SOUL_DOMINION_DAMAGE_TAKEN_MULT = 1.35`, `SOUL_DOMINION_AFTERSHOCK_DURATION = 5.0`, `SOUL_DOMINION_AFTERSHOCK_DAMAGE_MULT = 1.2`

### 실제 적용 리스크
1. **MP 재생 차단**: `soul_dominion_active` 또는 `soul_dominion_aftershock_timer > 0` 동안 `_tick_mana_regeneration`이 MP를 전혀 회복시키지 않음
2. **받는 피해 증가**: `get_damage_taken_multiplier()`가 active 시 ×1.35, aftershock 시 ×1.20 적용
3. **종료 후유증**: 토글 off(수동 또는 마나 고갈) 시 5초 aftershock 시작, 동 기간 동안 위 효과 유지

### HUD 반영
- `GameState.get_soul_dominion_risk_summary()` 함수 추가
- `game_ui.gd` buff_label 마지막 줄에 상태 문구 표시 (active/aftershock 모두)
- 2026-04-07 후속 잠금으로 `scripts/ui/game_ui.gd`는 warning row / MP bar / edge overlay에 active, aftershock, clear beat 구간을 분리해 읽히게 했고, `scripts/main/main.gd`는 `aftershock -> safe` 전환 순간 아주 약한 full-screen cool release wash를 한 번 더 띄워 전장 전체 해제 감각을 닫는다.
- 같은 후속에서 `scripts/main/main.gd`는 player camera zoom도 함께 조정한다. active는 소폭 인줌, aftershock는 기본값 쪽으로 천천히 이완, clear는 짧은 아웃줌 복귀로 운용해 `위험 진입 -> 잔여 위험 -> 해제`의 시선 압력을 분리한다.
- 같은 후속에서 `scripts/ui/damage_label.gd`도 `Soul Dominion` 리스크 상태를 읽는다. active 중 적 피격 숫자는 조금 더 크고 더 차가운 violet 쪽으로, aftershock 중에는 약간 더 작고 더 warm한 tint 쪽으로 이동해 월드 hit feedback도 HUD/카메라 리듬과 같은 위계를 따르도록 잠갔다.
- 같은 후속에서 `scripts/enemies/enemy_base.gd`의 enemy hit flash도 `Soul Dominion` 리스크 상태를 읽는다. active 중 적 피격 flash는 더 차갑고 더 violet 쪽으로, aftershock 중에는 조금 더 warm하게 풀어 HUD / camera / damage label과 같은 `위험 진입 -> 잔여 위험` 위계를 월드 본체에도 이어 붙였다.

### 변경 파일
- `scripts/autoload/game_state.gd`
- `scripts/player/spell_manager.gd`
- `scripts/player/player.gd`
- `scripts/ui/game_ui.gd`
- `scripts/ui/damage_label.gd`
- `scripts/main/main.gd`
- `scripts/enemies/enemy_base.gd`
- `tests/test_spell_manager.gd` (+4 tests)
- `tests/test_game_ui.gd`
- `tests/test_main_integration.gd`
- `tests/test_enemy_base.gd`

### 테스트 결과
- `godot --headless --path . --quit` 통과
- `tests/test_spell_manager.gd 297/297` 통과
- `tests/test_game_ui.gd 15/15` 통과
- `tests/test_main_integration.gd 19/19` 통과
- `tests/test_enemy_base.gd 93/93` 통과

## 관련 파일

- [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd)
- [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)
- [test_spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_spell_manager.gd)
- [test_game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_state.gd)
