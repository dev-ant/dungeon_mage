---
title: 협업 작업 인덱스
doc_type: index
status: active
section: collaboration
owner: shared
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
update_when:
  - structure_changed
  - ownership_changed
  - handoff_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 협업 작업 인덱스

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 병렬 개발 운영

## 목적

이 섹션은 `나`와 `친구`가 동시에 개발할 때 Git 충돌 없이 병렬 작업하기 위한 기준 문서다.

핵심 원칙은 아래 세 가지다.

- 각자 `서로 다른 파일 집합`만 수정한다.
- 각자 `자기 workstream 문서`만 진행 상황을 갱신한다.
- 같은 턴 소스 오브 트루스 동기화는 역할 프롬프트에 정의된 최소 문서 범위 안에서만 예외적으로 허용한다.

2026-04-02 기준으로 `collaboration`의 1차 하위 폴더 분리가 적용되었고, 정책 문서, 역할별 진행 문서, AI 프롬프트 문서를 분리해 관리한다.

이 섹션의 상세 문서 등록 책임은 이 `README.md`가 가집니다. 루트 `docs/README.md`에는 대표 진입점만 유지합니다.

## 문서 읽기 순서

1. [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md)
2. [docs/governance/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md)
3. [ai_native_operating_model.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_native_operating_model.md)
4. [ai_update_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md)
5. [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)
6. [skills_and_mcp_policy.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md)
7. [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
8. [docs/collaboration/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md)
9. [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)
10. 본인 역할 workstream 문서
11. 넓은 요청이면 [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)를 `plan`보다 먼저 읽는다.
12. 그다음 관련 `plan`, `baseline`, `rule`, `schema`, `tracker`를 읽는다.

## 거버넌스 잠금 규칙

- 기획이 모호하면 구현보다 먼저 정확히 `10문항` 질문 라운드로 전환한다.
- 반복 작업은 등록된 skill을 먼저 사용한다.
- scene/node/script wiring 확인은 Godot MCP를 먼저 시도한다.
- 역할 분리 계약은 공통 시작 체인 뒤에만 해석한다.
- 실행 프롬프트는 `Allowed implementation files`, `Allowed documentation files`, 역할에 맞는 조건부 동기화 구역, `Forbidden files`를 분리해서 직접 적는다.
- `owner_core` 계열 프롬프트는 `Conditionally allowed source-of-truth docs for same-turn sync`를 사용한다.
- `friend_gui` 계열 프롬프트는 `Conditionally allowed implementation-facing docs for same-turn sync`를 사용한다.

## 문서 목록

### `policies/`

- 역할 분리 계약: [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)

### `workstreams/`

- 내 작업 문서: [owner_core_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/owner_core_workstream.md)
- 친구 작업 문서: [friend_gui_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/friend_gui_workstream.md)

### `prompts/`

- Gemini/AI CLI 온보딩: [ai_cli_handoff_for_gemini.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/prompts/ai_cli_handoff_for_gemini.md)
- 내 AI 시작 프롬프트: [prompt_template_owner_core.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/prompts/prompt_template_owner_core.md)
- 친구 AI 시작 프롬프트: [prompt_template_friend_gui.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/prompts/prompt_template_friend_gui.md)
- Codex owner 프롬프트: [prompt_codex_owner_core.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/prompts/prompt_codex_owner_core.md)
- 진행 점검 프롬프트: [progress_check_prompt.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/prompts/progress_check_prompt.md)

### `archive/`

- 오너 누적 로그 아카이브: [owner_core_workstream_archive_2026-03-30_to_2026-04-02_session_57.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/archive/owner_core_workstream_archive_2026-03-30_to_2026-04-02_session_57.md)
- 장기 누적 로그를 주간 단위로 롤오버하거나 폐기된 협업 프롬프트를 보관할 때 사용합니다.

## 운영 규칙

- 문서 충돌 시 구현 기준은 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md) 를 우선한다.
- 적 스탯, 데미지 계산, 저항, 슈퍼아머 관련 충돌은 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md) 를 우선한다.
- 공용 기준 문서는 기본적으로 읽기 전용으로 간주한다.
- 단, 같은 턴 문서 동기화에 필요한 최소 범위의 `baseline`, `rule`, `schema`, `tracker`, `plan`, `catalog` 문서는 역할별 허용 범위 안에서만 예외적으로 수정할 수 있다.
- 진행 상황 기록은 각자 자기 workstream 문서에만 남긴다.
- 상대 소유 파일을 수정해야 할 이유가 생기면 직접 수정하지 말고 자기 workstream 문서의 `교차 의존 요청` 섹션에 적는다.
- 역할 분리 기간에는 상대 소유 파일에 대해 `작은 수정`도 예외 없이 금지한다.
- 병합 직전에는 각자 자기 소유 파일 목록 기준으로만 diff를 검토한다.
- 전투 구현 중 적 수치 규칙을 바꿨다면 코드 변경만 남기지 말고 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md) 도 함께 수정한다.
- 새 협업 문서를 추가할 때는 정책은 `policies/`, 진행 로그는 `workstreams/`, AI용 프롬프트는 `prompts/`에 둔다.

## Workstream 롤오버 규칙

- 활성 workstream 문서는 항상 하나만 유지하고, 현재 상태와 다음 작업만 빠르게 읽을 수 있게 관리한다.
- 활성 workstream 문서가 대략 `200줄`을 넘기기 시작하거나, 하나의 큰 마일스톤이 닫히면 누적 로그를 `archive/`로 롤오버한다.
- 롤오버 후 활성 문서에는 `현재 상태`, `다음 우선 작업`, `교차 의존 요청`, `아카이브 링크`만 남긴다.
- 아카이브 문서는 읽기 전용으로 간주하고, 새 로그를 이어 쓰지 않는다.
- 아카이브 파일명은 기본적으로 `<workstream_name>_archive_<start_date>_to_<end_date>_session_<last_session>.md` 형식을 사용한다.
- 세션 번호가 없거나 약한 경우에는 `<workstream_name>_archive_<start_date>_to_<end_date>.md` 형식을 사용한다.
- 롤오버가 끝나면 이 README와 활성 workstream 문서 양쪽에서 아카이브로 진입 가능해야 한다.
