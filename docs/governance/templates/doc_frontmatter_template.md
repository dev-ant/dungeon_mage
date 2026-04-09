---
title: 문서 frontmatter 템플릿
doc_type: rule
status: active
section: governance
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/target_doc_structure.md
update_when:
  - structure_changed
  - handoff_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 문서 frontmatter 템플릿

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 문서 거버넌스

## 목적

이 문서는 운영 문서 상단에 공통적으로 붙일 frontmatter 템플릿과 필드 의미를 정의한다.

## 권장 템플릿

```md
---
title: 문서 제목
doc_type: index
status: active
section: progression
owner: shared
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
update_when:
  - structure_changed
last_updated: YYYY-MM-DD
last_verified: YYYY-MM-DD
---
```

## 필드 정의

| 필드 | 의미 | 권장값 |
| --- | --- | --- |
| `title` | 문서 표시 제목 | 사람이 읽는 한글 제목 |
| `doc_type` | 문서 타입 | `index`, `rule`, `catalog`, `schema`, `tracker`, `baseline`, `plan`, `runbook`, `prompt`, `archive` |
| `status` | 문서 생명주기 상태 | `active`, `draft`, `deprecated`, `archived` |
| `section` | 상위 섹션 | `root`, `governance`, `foundation`, `progression`, `implementation`, `collaboration` |
| `owner` | 문서 관리 책임 | `design`, `runtime`, `gui`, `shared`, `owner_core`, `friend_gui` |
| `source_of_truth` | 기준 문서 여부 | `true`, `false` |
| `parent` | 상위 인덱스 문서 경로 | 절대 경로 1개, 루트 인덱스는 self-reference 허용 |
| `depends_on` | 함께 읽어야 할 기준 문서 | 절대 경로 배열 |
| `update_when` | 어떤 조건에서 갱신해야 하는지 | 이벤트 키 배열 |
| `last_updated` | 마지막 수정일 | `YYYY-MM-DD` |
| `last_verified` | 코드/운영 기준과 마지막 대조일 | `YYYY-MM-DD` |

## `doc_type` 선택 기준

- `index`: 섹션 진입 문서
- `rule`: 최신 규칙 정의
- `catalog`: 콘텐츠 목록 관리
- `schema`: 데이터 구조 정의
- `tracker`: 상태 추적
- `baseline`: 현재 사실 기준
- `plan`: 향후 작업 계획
- `runbook`: 절차서
- `prompt`: AI용 작업 프롬프트
- `archive`: 과거 기준 보존

## `update_when` 권장 키

- `rule_changed`
- `runtime_changed`
- `schema_changed`
- `status_changed`
- `structure_changed`
- `handoff_changed`
- `ownership_changed`

## 적용 규칙

- 새 운영 문서를 만들 때는 이 템플릿을 먼저 붙이고 시작한다.
- 기존 문서가 아직 frontmatter를 쓰지 않더라도, 신규 문서부터 일관되게 적용한다.
- 기존 문서 전체를 한 번에 바꾸기보다 섹션 단위로 점진 전환한다.
- 2026-04-02 기준으로 루트 인덱스와 핵심 `governance` 문서군부터 실제 적용을 시작했다.
- 같은 날짜 기준으로 `progression`과 `implementation`의 핵심 인덱스/기준 문서에도 2차 적용을 시작했다.
- 같은 날짜 기준으로 `collaboration`의 핵심 `index / rule / tracker` 문서에도 3차 적용을 시작했다.
- 같은 날짜 기준으로 `collaboration`의 핵심 `prompt` 문서와 `progression`의 핵심 `tracker` 문서에도 4차 적용을 시작했다.
- 같은 날짜 기준으로 `progression`의 핵심 `catalog / schema` 문서에도 5차 적용을 시작했다.
- 같은 날짜 기준으로 남은 `foundation / implementation / progression / collaboration` 활성 문서와 `archive`, 루트 리다이렉트, `docs/superpowers/` 레거시 보존 문서까지 적용을 완료했다.

## 점진 전환 순서

1. `governance` 문서부터 적용한다.
2. 다음으로 섹션 인덱스와 핵심 기준 문서에 적용한다.
3. 그다음 tracker, prompt, archive, legacy redirect 문서에 확장한다.
4. 새 문서가 추가될 때는 처음부터 같은 템플릿으로 시작한다.
