---
title: 목표 문서 구조
doc_type: rule
status: active
section: governance
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
update_when:
  - structure_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 목표 문서 구조

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 문서 거버넌스

## 목적

이 문서는 Dungeon Mage 문서 구조를 장기 운영형으로 재정리할 때 따라야 할 목표 폴더 구조와 분리 원칙을 정의한다.

핵심 목표는 아래와 같다.

- 최상위 통합 문서는 `탐색과 규칙`만 담당한다.
- 하위 섹션 문서는 `영역별 인덱스와 소스 오브 트루스 안내`를 담당한다.
- 세부 문서는 `문서 타입별 하위 폴더` 안에서 역할이 분리된 상태로 유지한다.

## 목표 계층

권장 기본 구조는 아래와 같다.

```text
docs/
  README.md
  governance/
    README.md
    ai_native_operating_model.md
    target_doc_structure.md
    ai_update_protocol.md
    clarification_loop_protocol.md
    skills_and_mcp_policy.md
    templates/
      README_template.md
      doc_frontmatter_template.md
  foundation/
    README.md
    rules/
    catalogs/
    archive/
  progression/
    README.md
    rules/
    catalogs/
    schemas/
    trackers/
    plans/
    archive/
  implementation/
    README.md
    baselines/
    plans/
    increments/
    runbooks/
    spec_clarification_backlog.md
    archive/
  collaboration/
    README.md
    policies/
    workstreams/
    prompts/
    archive/
```

## 폴더 역할 정의

### 루트 `docs/`

- 프로젝트 전체 문서의 진입점이다.
- 최상위 원칙, 섹션 링크, 거버넌스 핵심 문서, 섹션별 대표 진입점만 둔다.
- 활성 운영 문서와 `archive/deprecated` 진입점을 명시적으로 분리한다.
- 섹션 내부의 상세 문서 등록 책임은 각 섹션 `README.md`에 둔다.
- 세부 운영 로그나 긴 체크리스트는 두지 않는다.

### `governance/`

- 문서 운영 정책, 템플릿, AI 갱신 규칙을 둔다.
- 다른 섹션에 중복될 공통 규칙은 먼저 이곳에서 정의한다.

### `foundation/`

- 세계관, 캐릭터, 서사 전제 같은 기초 설정을 둔다.
- 서사 규칙과 설정 카탈로그를 분리한다.

### `progression/`

- 성장 규칙, 스킬/적 카탈로그, 데이터 스키마, 상태 추적표, 마이그레이션 계획을 분리한다.
- 현재 프로젝트에서 가장 먼저 하위 폴더 분리가 필요한 영역이다.

### `implementation/`

- 현재 런타임 기준선, 구현 계획, 증분 문서, 실무 런북을 분리한다.
- 장기 계획 문서와 현재 사실 문서가 섞이지 않게 유지한다.

### `collaboration/`

- 협업 정책, 역할 분리 문서, 역할별 workstream, AI 프롬프트를 분리한다.
- 장기 로그는 `workstreams/` 아래 날짜 단위 또는 주간 단위로 롤오버한다.

## 문서 타입 규칙

각 문서는 아래 타입 중 하나로 관리한다.

| 타입 | 역할 | 예시 |
| --- | --- | --- |
| `index` | 섹션 진입점, 읽기 순서, 기준 문서 연결 | `README.md` |
| `rule` | 기획/운영 규칙의 소스 오브 트루스 | 스킬 규칙, 피해 계산 규칙 |
| `catalog` | 콘텐츠 목록, 라인업, roster | 스킬 목록, 몬스터 목록 |
| `schema` | 데이터 필드, enum-like 허용값, validation 기준 | `skill_data_schema.md` |
| `tracker` | 구현, 자산, 검증 상태 추적 | `skill_implementation_tracker.md` |
| `baseline` | 현재 코드/런타임 사실 기준선 | `current_runtime_baseline.md` |
| `plan` | 앞으로의 구현/마이그레이션 계획 | 증분 계획, migration plan |
| `runbook` | 작업 절차, 검증 절차, 운영 핸드오프 | MCP setup, release checklist |
| `prompt` | AI 온보딩용 프롬프트 문서. 공통 거버넌스 시작 체인과 핵심 운영 규칙을 직접 드러낸다. | 역할별 시작 프롬프트 |
| `archive` | 과거 기준, 폐기 안내, 스냅샷 | 레거시 문서, dated snapshot |

## 파일명 규칙

- 살아 있는 운영 문서는 날짜를 파일명에 넣지 않는다.
- 날짜는 `archive`, `snapshot`, `decision` 성격의 문서에만 사용한다.
- README는 항상 섹션 또는 하위 폴더의 인덱스 역할만 맡긴다.
- 파일명은 가능하면 `snake_case`를 유지한다.
- 하나의 문서에 규칙, 카탈로그, 트래커, 실행 로그를 함께 섞지 않는다.

## 현재 적용 상태

- `docs/progression/` 하위 폴더 분리: 1차 적용 완료
- `docs/implementation/` 하위 폴더 분리: 1차 적용 완료
- `docs/foundation/` 하위 폴더 분리: 1차 적용 완료
- `docs/collaboration/` 하위 폴더 분리: 1차 적용 완료
- `docs/` 하위 활성 운영 문서 frontmatter 적용: 완료
- `archive`, 레거시 리다이렉트, `docs/superpowers/` 레거시 보존 문서 frontmatter 적용: 완료

## 운영 상태

- 구조 개편 기준의 1차 목표는 모두 적용 완료 상태다.
- 앞으로의 작업은 `새 문서도 동일한 타입/메타데이터 규칙으로 추가하기`, `문서 길이 롤오버 유지하기`, `필요 시 foundation catalogs 확장하기` 같은 유지보수 단계로 본다.
- `docs/superpowers/`는 목표 활성 구조에 편입하지 않고, 레거시 보존 영역으로만 유지한다.

## 문서 분할 기준

- 한 문서가 300~400줄을 넘고, 서로 다른 타입 정보를 함께 담기 시작하면 분할 후보로 본다.
- `현재 기준`, `진행 현황`, `실행 로그`, `에셋 기준`, `검증 명세`가 한 문서에 함께 있으면 우선 분리한다.
- 분할 후 원문서는 짧은 인덱스 또는 리다이렉트 문서로 축소한다.

## 마이그레이션 원칙

1. 먼저 인덱스를 만든다.
2. 그다음 기준 문서의 새 위치를 확정한다.
3. 실제 문서를 이동하거나 쪼갠다.
4. 마지막에 링크와 등록표를 갱신한다.

## 이번 리팩터링의 산출물 기준

- 루트 `docs/README.md`에서 `governance` 섹션으로 진입할 수 있어야 한다.
- 새 섹션 README는 읽기 순서, 문서 목록, 운영 규칙을 공통 형식으로 가져야 한다.
- 실행 프롬프트는 `docs/README -> governance/README -> ai_native_operating_model -> ai_update_protocol -> clarification_loop_protocol -> skills_and_mcp_policy -> 관련 섹션 README` 순서를 공통 시작 체인으로 공유해야 한다.
- 실행 프롬프트는 `넓은 요청이면 spec_clarification_backlog 우선`, `모호하면 정확히 10문항 질문`, `반복 작업은 skill 우선`, `scene/node/script wiring 확인은 Godot MCP 우선`을 직접 적어야 한다.
- AI는 문서 수정 전에 이 구조 문서와 AI 업데이트 규칙 문서를 먼저 읽으면 된다.
