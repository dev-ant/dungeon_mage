---
title: Skills 및 Godot MCP 사용 정책
doc_type: rule
status: active
section: governance
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_native_operating_model.md
update_when:
  - rule_changed
  - handoff_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# Skills 및 Godot MCP 사용 정책

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 문서 거버넌스

## 목적

이 문서는 Dungeon Mage에서 반복 작업을 할 때 AI가 등록된 skill과 Godot MCP를 먼저 사용하도록 고정하는 운영 규칙을 정의한다.

## Skill 우선 원칙

- 반복되는 작업은 가능한 한 skill을 먼저 사용한다.
- 같은 종류의 작업을 두 번 이상 수동으로 반복했다면 skill 개선 후보로 본다.
- 문서에 이미 skill이 지정된 작업은 ad-hoc 방식보다 skill 기반 워크플로를 우선한다.

## 이 프로젝트의 기본 skill 매핑

| 작업 유형 | 기본 skill |
| --- | --- |
| 문서 구조 정리, 기획 문서 정리 | `codex-design-doc-manager`, `codex-game-design-docs` |
| Godot 장면/노드 조사, MCP 연동 | `codex-godot-mcp-workflow`, `dungeon-mage-godot-mcp` |
| 전투 런타임/스킬/적 구현 | `dungeon-mage-godot-combat`, `claude-godot-implementer` |
| 에셋 분석, 복사, 런타임 연결 | `dungeon-mage-asset-import` |
| 진행도 점검, 현재 상태 요약 | `dungeon-mage-progress-check` |
| 문서-코드 동기화 | `claude-doc-sync-implementer` |

## 운영 모드별 기본 skill

이 프로젝트의 반복 운영 모드는 아래 skill 조합을 기본값으로 사용한다.

| 운영 모드 | 기본 skill |
| --- | --- |
| 기획 잠금 / 10문항 구체화 | `dungeon-mage-clarification-loop` |
| 증분 구현 | `dungeon-mage-spec-to-godot`, `dungeon-mage-godot-combat`, `dungeon-mage-godot-mcp` |
| 문서 동기화 | `claude-doc-sync-implementer`, `codex-design-doc-manager` |
| 진행도 점검 | `dungeon-mage-progress-check` |
| 운영 / 릴리즈 검증 | `rest-quality-release` |

- 증분 구현 중 에셋 반영이 포함되면 `dungeon-mage-asset-import`를 함께 사용한다.
- 증분 구현 중 scene/node/script wiring 검증이 핵심이면 `dungeon-mage-godot-mcp` 또는 `codex-godot-mcp-workflow`를 먼저 사용한다.

## Skill 사용 트리거

### 에셋 작업

아래 작업은 먼저 `dungeon-mage-asset-import`를 검토한다.

- `asset_sample/` 아래 PNG 세트 분석
- `assets/`로 복사 및 경로 정리
- 스킬, 적, UI 에셋을 코드/씬/문서에 연결

### 전투 구현

아래 작업은 먼저 `dungeon-mage-godot-combat` 또는 `claude-godot-implementer`를 검토한다.

- 플레이어 전투 흐름
- 스킬 동작
- 버프/토글/설치형 처리
- 적 전투 반응

### 문서 동기화

아래 작업은 먼저 `claude-doc-sync-implementer` 또는 `codex-design-doc-manager`를 검토한다.

- 구현 후 문서 갱신
- 기준 문서와 tracker 동기화
- stale doc 정리

### 기획 잠금

아래 작업은 먼저 `dungeon-mage-clarification-loop`를 검토한다.

- 구현 전에 정확히 `10문항` 질문 라운드로 기획을 잠글 때
- `spec_clarification_backlog.md`의 상위 항목을 선제 구체화할 때
- acceptance criteria가 구현 수준으로 잠기지 않았을 때

### 증분 구현

아래 작업은 먼저 `dungeon-mage-spec-to-godot`를 검토한다.

- `plan`, `increment`, `rule` 문서를 실제 구현 증분으로 번역할 때
- 관련 파일, 테스트, 검증, 문서 동기화 범위를 먼저 잠가야 할 때

### 릴리즈 검증

아래 작업은 먼저 `rest-quality-release`를 검토한다.

- 출시 전 `go / no-go` 판단
- 서비스 수준 회귀 위험 점검
- 문서/코드/테스트/에셋 readiness 종합 점검

## Skill 개선 규칙

아래 조건 중 하나를 만족하면 AI는 skill 개선을 먼저 검토한다.

- 같은 수동 절차를 두 세션 이상 반복했다.
- 특정 skill이 현재 저장소 구조를 반영하지 못한다.
- asset import, progress check, Godot MCP 사용 순서가 실제 프로젝트와 다르다.
- 문서상 요구하는 체크리스트가 skill에 없어서 작업 품질이 흔들린다.

## Skill 개선 방법

1. 현재 작업을 막는 정확한 부족점을 한 줄로 정리한다.
2. 관련 `SKILL.md`를 수정해 절차, 체크리스트, 출력 형식을 보강한다.
3. 그다음 원래 작업으로 돌아간다.
4. 필요하면 관련 문서에 새 skill 사용 규칙을 한 줄로 남긴다.

## Godot MCP 우선 규칙

아래 상황에서는 Godot MCP를 먼저 시도한다.

- 어느 scene에 어떤 script가 붙었는지 확실하지 않을 때
- node tree와 scene wiring이 핵심일 때
- scene 구조와 script 로직이 함께 얽힌 변경일 때
- admin/combat/main scene의 실제 조립 상태를 먼저 봐야 할 때

## Godot MCP 기본 순서

1. 프로젝트 정보 확인
2. 메인 scene 또는 관련 scene 확인
3. 필요한 node tree 조사
4. 연결된 script와 resource 확인
5. 그다음에만 repo 파일 편집
6. headless 검증
7. 문서 동기화

## MCP fallback 규칙

- MCP가 없거나 실패하면 진행을 멈추지 않는다.
- `rg`, 파일 읽기, headless 실행으로 안전한 범위에서 대체한다.
- 다만 scene wiring을 추정으로 바꾸는 것은 피하고, 그 경우 문서에 불확실성을 남긴다.

## 문서 반영 규칙

- Godot MCP를 써야 하는 작업 절차는 `runbook` 또는 `plan` 문서에도 적는다.
- 특정 영역에서 skill 사용이 사실상 필수면 해당 섹션 README에 연결한다.
- 실행 프롬프트에는 `반복 작업은 skill 우선`, `scene/node/script wiring 확인은 Godot MCP 우선`을 짧게 직접 적고, 상세 절차만 이 문서로 위임한다.

## 검증 기본값

Godot 관련 변경에서는 아래 검증을 기본값으로 둔다.

- `godot --headless --path . --quit`
- GUT 전체 또는 관련 테스트
- 관련 `baseline`과 `plan` 문서 갱신 확인
