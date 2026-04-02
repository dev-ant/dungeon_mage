---
title: 문서 운영 인덱스
doc_type: index
status: active
section: governance
owner: shared
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/target_doc_structure.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
update_when:
  - structure_changed
  - handoff_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 문서 운영 인덱스

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 문서 거버넌스

## 목적

이 섹션은 Dungeon Mage 문서 구조, 문서 타입 규칙, AI 문서 갱신 절차를 관리하는 최상위 운영 문서 모음이다.

이 섹션의 목표는 아래 세 가지다.

- 문서를 `통합 문서 -> 하위 섹션 -> 세부 문서` 구조로 정리한다.
- 사람이든 AI든 같은 규칙으로 문서를 읽고 갱신하게 만든다.
- 장기 운영 중에도 기준 문서, 계획 문서, 상태 추적 문서, 아카이브 문서가 서로 역할을 침범하지 않게 유지한다.

## 문서 목록

- 목표 구조: [target_doc_structure.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/target_doc_structure.md)
- AI 네이티브 운영 모델: [ai_native_operating_model.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_native_operating_model.md)
- AI 업데이트 규칙: [ai_update_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md)
- 10문항 기획 구체화 프로토콜: [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)
- Skills 및 Godot MCP 사용 정책: [skills_and_mcp_policy.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md)
- README 템플릿: [templates/README_template.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/templates/README_template.md)
- frontmatter 템플릿: [templates/doc_frontmatter_template.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/templates/doc_frontmatter_template.md)

## 읽기 순서

1. [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md)
2. [docs/governance/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md)
3. [ai_native_operating_model.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_native_operating_model.md)
4. [ai_update_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md)
5. [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)
6. [skills_and_mcp_policy.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md)
7. 관련 섹션 `README.md`
8. 구조, 인덱스, 프롬프트 체계를 바꿀 때만 [target_doc_structure.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/target_doc_structure.md)

## 실행 프롬프트 잠금 규칙

- 모든 실행 프롬프트는 위 읽기 순서를 같은 기본 시작 체인으로 직접 적는다.
- 요청 범위가 넓으면 [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)를 관련 `plan`보다 먼저 읽는다.
- 기획이 모호하면 구현보다 먼저 정확히 `10문항` 질문 라운드로 전환한다.
- 반복 작업은 등록된 skill을 먼저 사용한다.
- scene/node/script wiring 확인은 Godot MCP를 먼저 시도한다.

## 운영 규칙

- 새 문서 체계를 제안하거나 폴더를 재구성할 때는 먼저 [target_doc_structure.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/target_doc_structure.md)를 기준으로 판단한다.
- AI가 실제 작업 요청을 받았을 때 어떤 문서 체인을 읽고 움직일지는 [ai_native_operating_model.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_native_operating_model.md)를 따른다.
- AI가 문서를 수정할 때는 먼저 [ai_update_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md)를 따른다.
- 기획이 모호할 때 질문 라운드는 [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)를 따른다.
- skill과 Godot MCP 사용은 [skills_and_mcp_policy.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md)를 따른다.
- 2026-04-02 기준 `foundation`, `progression`, `implementation`, `collaboration`의 1차 하위 폴더 분리는 적용 완료 상태다.
- 섹션 인덱스나 기준 문서를 새로 만들 때는 템플릿 문서를 그대로 복사해 시작한다.
- 운영 규칙을 바꿀 때는 개별 섹션 README에 중복 규칙을 추가하기 전에 이 섹션 문서를 먼저 수정한다.
- 실행 프롬프트의 시작 체인을 바꾸면 루트 `README`, 이 문서, 관련 섹션 `README`, 해당 프롬프트를 같은 턴에 함께 맞춘다.
- 루트 `docs/README.md`는 전체 탐색 포털로만 유지하고, 상세 문서 등록 책임은 각 섹션 `README.md`가 가진다.

## 연관 문서

- 루트 인덱스: [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md)
- 구현 현재 사실 기준: [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)
