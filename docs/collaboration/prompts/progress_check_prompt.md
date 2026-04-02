---
title: Dungeon Mage 진행도 점검 프롬프트
doc_type: prompt
status: active
section: collaboration
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md
update_when:
  - handoff_changed
  - runtime_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# Dungeon Mage 진행도 점검 프롬프트

이 문서는 `현재 어디까지 구현됐고, 다음에 무엇을 해야 하는지`를 빠르게 파악하기 위한 진행도 점검 전용 프롬프트다.

아래 프롬프트를 그대로 사용한다.

```text
현재 Dungeon Mage 프로젝트의 작업 진행도를 파악해줘.

중요:
- 구현 작업을 새로 시작하지 말고, 먼저 현재 상태를 읽고 정리하는 데 집중한다.
- 코드, 문서, 현재 워크트리 상태를 근거로만 판단한다.
- 추측으로 완료 여부를 말하지 않는다.
- 문서와 실제 코드가 어긋나면 둘 다 언급하고, 어느 쪽이 최신으로 보이는지 함께 정리한다.

반드시 아래 순서로 확인해라:
1. docs/README.md
2. docs/governance/README.md
3. docs/governance/ai_native_operating_model.md
4. docs/governance/ai_update_protocol.md
5. docs/governance/clarification_loop_protocol.md
6. docs/governance/skills_and_mcp_policy.md
7. docs/implementation/README.md
8. docs/collaboration/README.md
9. CLAUDE.md
10. docs/collaboration/policies/role_split_contract.md
11. docs/collaboration/workstreams/owner_core_workstream.md
12. docs/collaboration/workstreams/friend_gui_workstream.md
13. 넓은 실행 요청으로 이어질 가능성을 보기 위해 docs/implementation/spec_clarification_backlog.md
14. 현재 작업과 직접 관련된 구현 문서들
15. git status로 현재 워크트리 변경사항
16. 필요하면 관련 코드 파일

거버넌스 잠금 규칙:
- 넓은 실행 요청으로 이어질 때는 spec_clarification_backlog를 plan보다 먼저 본다.
- 기획이 모호하면 구현 대신 정확히 10문항 질문 라운드로 전환해야 한다.
- 반복 작업은 등록된 skill을 먼저 사용한다.
- scene/node/script wiring 확인은 Godot MCP를 먼저 시도한다.

확인 목표:
- 이미 끝난 것
- 현재 진행 중인 것
- 바로 다음 작업
- 나중 작업
- 역할 분리 기준에서 owner_core와 friend_gui가 각각 맡고 있는 것
- 문서상 진행도와 실제 코드 상태가 어긋나는 부분

출력 형식:
1. 이미 끝난 것
2. 진행 중인 것
3. 바로 다음 작업
4. 친구가 바로 맡을 작업
5. 내가 바로 맡을 작업
6. 나중 작업
7. 문서와 코드가 어긋나는 부분
8. 현재 워크트리 변경사항 메모

출력 규칙:
- 번호로 구분해서 사람이 보기 쉽게 쓴다.
- 각 항목은 짧고 명확하게 쓴다.
- 파일/문서 근거가 있으면 함께 적는다.
- "왜 그렇게 판단했는지"를 한두 문장으로 덧붙인다.
- 필요 이상으로 길게 쓰지 말고, 다음 행동을 결정하는 데 필요한 정보만 남긴다.

추가 규칙:
- owner_core와 friend_gui의 파일 소유권 경계를 반드시 지켜서 설명한다.
- 진행도 점검 요청에서는 코드 수정, 테스트 실행, 문서 수정은 하지 않는다.
- 사용자가 별도로 요청한 경우가 아니면 구현 제안만 하고 실제 변경은 하지 않는다.
```
