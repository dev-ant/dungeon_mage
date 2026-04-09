---
title: 전투 1차 작업 체크리스트 - 플레이어 컨트롤러
doc_type: plan
status: active
section: implementation
owner: runtime
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 전투 1차 작업 체크리스트 - 플레이어 컨트롤러

상태: 사용 중  
최종 갱신: 2026-04-01  
섹션: 구현 기준

## 목표

이 문서는 [전투 우선 구현 계획](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md)의 첫 번째 증분인 `플레이어 컨트롤러 고정`을 Claude가 바로 구현할 수 있도록 쪼갠 작업 체크리스트다.

이번 증분에서는 `전투 샌드박스에서 손에 붙는 이동과 입력 반응`을 만드는 데만 집중한다.

## 진행 상태

### 현재 완료

- 기본 상태 플래그 추가
- 더블점프 구현
- 대시 재사용 대기시간 정리
- 피격 시 경직/무적 시간 기본 처리
- 사망 시 입력 잠금
- 플레이어 컨트롤러 GUT 테스트 추가
- `GameState.restore_after_death()`와 연결되는 `player.respawn_from_saved_route()` seam 추가
- 저장 지점 복귀 시 `Dead` 상태, 잔여 슬로우, 무적 프레임, 카메라 흔들림을 함께 초기화하도록 정리
- 저장 지점 복귀와 사망 복구 경로에 대한 GUT 회귀 추가
- 사망 복귀 시 남아 있던 버프, 페널티, 배리어, Soul Dominion aftershock, 마지막 피격 표시를 함께 비우도록 `restore_after_death()` 정리
- 로프 진입 시 플레이어가 rope centerline으로 스냅되고, rope 상·하단 범위를 벗어나지 않도록 클램프하는 런타임 보강
- 실제 `scripts/world/rope.gd`를 사용하는 로프 중심선/경계 GUT 회귀 추가
- `rest_point.gd`가 저장 지점 spawn anchor를 local `position`이 아니라 world `global_position` 기준으로 기록하도록 보강
- translated parent 아래 놓인 rest point와 `rest_entrance` progression event에 대한 GUT 회귀 추가
- room shift 경계 요청이 같은 edge 체류 중에는 한 번만 발화되도록 edge lock 기반 debounce 보강
- room shift edge lock이 safe zone 재진입과 `reset_at()`에서 풀리는지 GUT 회귀 추가
- 해제되었거나 사라진 interactable이 `current_interactable`에 남아도 `_try_interact()`가 stale reference를 안전하게 비우도록 보강
- 등록된 interactable 호출과 stale interactable 정리 경로에 대한 GUT 회귀 추가
- 겹친 interactable 중 최신 대상이 사라지거나 range를 벗어나면 직전 유효 대상에게 포커스가 자연스럽게 되돌아가도록 보강
- interactable unregister/stale fallback 경로에 대한 GUT 회귀 추가
- 겹친 rope area에서도 최신 rope가 사라지거나 range를 벗어나면 직전 유효 rope로 grab 대상이 자연스럽게 되돌아가도록 보강
- rope unregister/stale fallback 경로에 대한 GUT 회귀 추가
- mock rope 테스트도 실제 rope와 같은 bound helper를 타도록 `_handle_rope_physics()`의 meta/property 경로를 통일

### 아직 남은 작업

- `Godot State Charts`를 플레이어 상태 흐름에 본격 연결
- 로프 또는 사다리 상태 추가
- 공중 시전 감도와 대시 후딜 추가 튜닝
- 실제 씬 기준 상태 전이 시각 피드백 보강

## 현재 기준

- 플레이어 스크립트는 [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)에 있다.
- 전투 프로토타입은 이미 존재하지만, 입력 체계와 전투용 상태 구조를 전투 샌드박스 기준으로 다시 고정할 필요가 있다.
- 현재 저장소에는 `scenes/player/` 폴더가 없으므로, 이번 작업은 현재 씬 구조를 유지하면서 시작해도 된다.
- [CLAUDE.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/CLAUDE.md)의 규칙상 상태 전환은 `Godot State Charts`, 검증은 `GUT`와 헤드리스 실행을 사용해야 한다.

## 플레이 경험 목표

- 좌우 이동이 즉시 반응하고 미끄러짐이 과하지 않다.
- 점프와 더블점프가 확실히 구분되고 공중 제어가 가능하다.
- 대시는 회피와 포지셔닝에 실제로 유용하다.
- 공중 시전이 막히지 않고, 피격/무적/사망 상태가 명확하다.
- 추후 스킬 시스템과 적 AI를 붙여도 구조를 다시 갈아엎지 않아도 된다.

## 이번 범위

### 포함

- 이동 가속과 감속 정리
- 점프
- 더블점프
- 대시
- 공중 시전 허용
- 피격 경직
- 무적 시간
- 사망 처리
- 입력 액션 정리
- 상태 차트 연결
- 플레이어 관련 GUT 테스트 추가

### 제외

- 스킬 슬롯 UI
- 관리자 메뉴
- 장비 수치
- 버프 조합
- 적 AI
- 스토리/배경/연출

## Claude 작업 순서

1. [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)의 현재 상태 플래그 구현을 읽고, 이를 `Godot State Charts` 상태 리소스로 옮길 설계를 확정한다.
2. `Idle`, `Walk`, `Jump`, `DoubleJump`, `Fall`, `Dash`, `Cast`, `Hit`, `Dead` 상태를 실제 상태 차트 이벤트와 연결한다.
3. `move_up`, `move_down`, `admin_menu` 액션은 이미 입력 맵에 있으므로, 부족한 액션만 추가한다.
4. 현재 구현된 더블점프/대시/피격/사망 로직을 상태 이벤트 중심으로 재배치한다.
5. 공중 시전 감도와 대시 종료 후 다음 입력 허용 타이밍을 실제 플레이 기준으로 조정한다.
6. 로프 또는 사다리용 `OnRope` 상태를 추가한다.
7. GUT 테스트를 보강하고 헤드리스 검증 3종을 다시 통과시킨다.

## 상태 설계

### 필수 상태

- `Idle`
- `Walk`
- `Jump`
- `DoubleJump`
- `Fall`
- `Dash`
- `Cast`
- `Hit`
- `Dead`

### 상태 전이 요구사항

- 지상에서 이동 입력이 있으면 `Walk`, 없으면 `Idle`
- 점프 시작 시 `Jump`
- 공중에서 추가 점프 성공 시 `DoubleJump`
- 상승이 끝나고 하강하면 `Fall`
- 대시 입력 시 `Dash`
- 시전 입력 시 지상/공중 모두 `Cast`
- 피격 시 `Hit`
- HP가 0 이하가 되면 `Dead`

### 구현 메모

- 상태는 직접 분기문으로 늘리지 말고 `Godot State Charts` 이벤트를 중심으로 연결한다.
- `Dash`, `Hit`, `Dead`는 이동보다 우선순위가 높아야 한다.
- `Cast`는 이동을 완전히 막는 대신, 짧은 시전 잠금만 허용하는 쪽이 전투 감각에 유리하다.

## 입력 기준

| 액션 | 기본 키 | 비고 |
| --- | --- | --- |
| `move_left` | `Left` | 유지 |
| `move_right` | `Right` | 유지 |
| `jump` | `Alt` | 유지 |
| `dash` | `Shift` | 필요 시 추가 |
| `move_up` | `Up` | 추후 로프/사다리 대응용 |
| `move_down` | `Down` | 추후 로프/사다리 대응용 |
| `skill_1` | `Z` | 임시 전투 슬롯 |
| `skill_2` | `X` | 임시 전투 슬롯 |
| `skill_3` | `C` | 임시 전투 슬롯 |
| `admin_menu` | `Escape` | 추후 관리자 메뉴용 |

## 세부 작업 체크리스트

### 1. 이동 반응 정리

- 지상 가속/감속 값을 전투 기준으로 재조정
- 방향 전환 시 체감 지연 최소화
- 공중 제어는 지상보다 약하되 답답하지 않게 유지

### 2. 점프와 더블점프

- 점프 1회
- 공중 추가 점프 1회
- 착지 시 점프 횟수 초기화
- 더블점프는 일반 점프와 구분되는 반응이 있어야 함

### 3. 대시

- 짧은 무적 또는 피해 경감 여부를 정한다
- 대시 도중 속도 고정
- 대시 종료 후 즉시 다음 입력 가능
- 대시 쿨타임은 너무 길지 않게 유지

### 4. 공중 시전

- 공중에서 최소 기본 스킬 3종 시전 가능
- 시전 때문에 공중 이동이 완전히 죽지 않도록 조정
- 시전 후 낙하가 자연스럽게 이어져야 함

### 5. 피격과 무적

- 피격 시 짧은 경직
- 무적 시간 동안 연속 피해 방지
- 피격 직후 상태와 색상 또는 점멸 피드백 제공

### 6. 사망 처리

- HP 0 시 `Dead`
- 입력 차단
- 전투 샌드박스에서 재시작 가능하도록 후속 연결 지점 확보

현재 구현 메모 (2026-04-01):
- `GameState.save_progress(room_id, spawn_position)`로 기록된 저장 지점은 `GameState.restore_after_death()`로 복구 가능
- `player.respawn_from_saved_route()`는 위 복구 정보를 읽어 `reset_at()`을 호출하고, 향후 메인 씬이 room reload와 이어 붙일 수 있는 `room_id/spawn_position` 딕셔너리를 반환함
- `restore_after_death()`는 저장 지점 좌표와 풀 HP/MP만 되돌리는 수준을 넘어서, 활성 버프/페널티/버프 쿨다운/배리어/후유증/마지막 피격 표시까지 초기화해 사망 직전 전투 상태를 다음 생에 끌고 오지 않도록 고정됨
- `OnRope` 상태는 rope grab 직후 중심선에 정렬되고, `_handle_rope_physics()`가 매 프레임 rope centerline과 top/bottom bounds를 다시 맞춰 횡스크롤 이동 오차로 rope에서 비스듬히 매달리는 상태를 막음
- `rest_point.interact()`는 object layer나 부모 transform이 있더라도 저장 지점을 올바르게 복구할 수 있도록 `global_position + (0, -60)`을 저장하며, entrance에서는 기존처럼 `rest_entrance` progression event를 함께 기록함
- `player._check_room_edges()`는 같은 좌/우 room shift 경계에 머무는 동안에는 `request_room_shift`를 한 번만 emit하고, 플레이어가 safe zone으로 돌아오거나 `reset_at()`이 호출되면 다음 경계 진입을 다시 허용함
- `player._try_interact()`는 유효한 interactable만 호출하고, 월드 오브젝트가 먼저 free된 경우에는 stale `current_interactable` 참조를 자동으로 비워 다음 입력이 안전하게 계속 진행되도록 함
- `player.register_interactable()`는 최근 진입 interactable을 우선 포커스로 올리되 내부 목록도 함께 유지하고, `unregister_interactable()` 또는 stale prune 뒤에는 직전 유효 interactable로 자동 fallback되어 겹친 상호작용 구간에서도 포커스가 끊기지 않음
- `player.register_rope()`도 rope 목록을 함께 유지하고, `unregister_rope()` 또는 stale rope prune 뒤에는 직전 유효 rope로 자동 fallback되어 겹친 rope area에서도 grab 대상이 끊기지 않음
- `player._handle_rope_physics()`도 이제 실제 rope property와 mock rope meta를 같은 `_get_rope_bound()` 경로로 읽어서, headless GUT의 mock rope가 실제 런타임과 다른 분기를 타지 않음

## 예상 수정 파일

- [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)
- [Main.tscn](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scenes/main/Main.tscn)
- [main.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/main/main.gd)
- [project.godot](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/project.godot)
- 새 플레이어 상태 차트 리소스 또는 씬 파일
- [test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)
- 필요 시 [test_game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_state.gd) 확장

## 수용 기준

- 플레이어가 키보드만으로 이동, 점프, 더블점프, 대시, 시전, 피격, 사망을 수행한다.
- 전투 중 입력 누락이나 과도한 잠금이 없다.
- 상태 전환이 `Godot State Charts` 기반으로 정리된다.
- 헤드리스 실행이 깨지지 않는다.
- 관련 GUT 테스트가 추가된다.

## 테스트 체크포인트

### GUT

- 점프 횟수와 착지 초기화
- 더블점프 조건
- 대시 중 상태 전환
- 피격 무적 시간
- 사망 시 입력 차단

### 헤드리스

- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

## 비목표

- 스킬 밸런스 조정
- 적 AI 확대
- HUD 대개편
- 장비/아이템 연동
- 관리자 메뉴 구현

## 다음 증분

이 작업이 끝나면 다음은 `스킬 런타임 구조 정리`다. 그때는 슬롯 장착, 마나/쿨타임, 액티브/버프/설치 타입 분리, 시전 실패 피드백을 붙인다.

## Claude 바로 다음 작업

Claude는 다음 순서로 이어서 작업하면 된다.

1. 플레이어 상태 차트 리소스를 추가한다.
2. 현재 `state_name` 기반 판정을 상태 차트 이벤트 송신 구조로 교체한다.
3. 로프 또는 사다리 테스트용 최소 오브젝트와 `OnRope` 상태를 붙인다.
4. 공중 시전과 대시 후 연계 감도를 다시 튜닝한다.
