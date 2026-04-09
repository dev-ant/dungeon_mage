---
title: 협업 작업 인덱스
doc_type: index
status: active
section: collaboration
owner: shared
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/single_stream_collaboration.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
update_when:
  - structure_changed
  - ownership_changed
  - handoff_changed
last_updated: 2026-04-10
last_verified: 2026-04-10
---

# 협업 작업 인덱스

상태: 사용 중  
최종 갱신: 2026-04-10  
섹션: 협업 운영

## 목적

이 섹션은 현재 활성 협업 정책, workstream, prompt 진입점을 관리한다.

2026-04-10 기준으로 기본 모드는 `owner_core / friend_gui` 병렬 분리에서 `single-stream`으로 전환됐다. 역할 분리 문서는 보존하지만, 새 진행 로그와 기본 정책은 shared 문서를 기준으로 해석한다.

핵심 원칙은 아래 세 가지다.

- 활성 진행 로그는 `shared_ui_runtime_workstream.md` 하나에만 남긴다.
- 구현이 바뀌면 관련 source-of-truth 문서를 같은 턴에 바로 동기화한다.
- legacy owner/friend 문서는 삭제하지 않고 읽기 전용 역사 기록으로 둔다.

`collaboration`은 계속 `policies / workstreams / prompts / archive` 구조를 유지한다. 다만 active entrypoint는 shared policy/workstream 기준으로 읽는다.

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
9. [single_stream_collaboration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/single_stream_collaboration.md)
10. [shared_ui_runtime_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/shared_ui_runtime_workstream.md)
11. 넓은 요청이면 [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)를 `plan`보다 먼저 읽는다.
12. 그다음 관련 `plan`, `baseline`, `rule`, `schema`, `tracker`를 읽는다.

## 거버넌스 잠금 규칙

- 기획이 모호하면 구현보다 먼저 정확히 `10문항` 질문 라운드로 전환한다.
- 반복 작업은 등록된 skill을 먼저 사용한다.
- scene/node/script wiring 확인은 Godot MCP를 먼저 시도한다.
- active shared policy는 공통 시작 체인 뒤에 해석한다.
- 실행 프롬프트는 `Allowed implementation files`, `Allowed documentation files`, 역할에 맞는 조건부 동기화 구역, `Forbidden files`를 분리해서 직접 적는다.
- legacy owner/friend prompt는 과거 병렬 세션을 재현할 때만 사용한다.

## 문서 목록

### `policies/`

- 활성 shared 정책: [single_stream_collaboration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/single_stream_collaboration.md)
- 레거시 역할 분리 계약: [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)

### `workstreams/`

- 활성 shared workstream: [shared_ui_runtime_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/shared_ui_runtime_workstream.md)
- 레거시 owner workstream: [owner_core_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/owner_core_workstream.md)
- 레거시 friend workstream: [friend_gui_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/friend_gui_workstream.md)

### `prompts/`

- 활성 shared prompt: [prompt_template_shared_build.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/prompts/prompt_template_shared_build.md)
- Gemini/AI CLI 온보딩: [ai_cli_handoff_for_gemini.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/prompts/ai_cli_handoff_for_gemini.md)
- 레거시 owner 프롬프트: [prompt_template_owner_core.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/prompts/prompt_template_owner_core.md)
- 레거시 friend 프롬프트: [prompt_template_friend_gui.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/prompts/prompt_template_friend_gui.md)
- 레거시 Codex owner 프롬프트: [prompt_codex_owner_core.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/prompts/prompt_codex_owner_core.md)
- 진행 점검 프롬프트: [progress_check_prompt.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/prompts/progress_check_prompt.md)

### `archive/`

- 오너 누적 로그 아카이브: [owner_core_workstream_archive_2026-03-30_to_2026-04-02_session_57.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/archive/owner_core_workstream_archive_2026-03-30_to_2026-04-02_session_57.md)
- 장기 누적 로그를 주간 단위로 롤오버하거나 폐기된 협업 프롬프트를 보관할 때 사용합니다.

## 운영 규칙

- 문서 충돌 시 구현 기준은 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md) 를 우선한다.
- 적 스탯, 데미지 계산, 저항, 슈퍼아머 관련 충돌은 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md) 를 우선한다.
- 활성 정책 판단은 [single_stream_collaboration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/single_stream_collaboration.md)를 우선한다.
- 진행 상황 기록은 [shared_ui_runtime_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/shared_ui_runtime_workstream.md)에만 남긴다.
- legacy owner/friend 문서는 새 로그를 받지 않는다.
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
