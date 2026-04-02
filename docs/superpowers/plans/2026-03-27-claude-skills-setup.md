---
title: Claude Code 스킬 설정 구현 계획
doc_type: archive
status: archived
section: governance
owner: shared
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md
update_when:
  - status_changed
  - structure_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# Claude Code 스킬 설정 구현 계획

> 에이전트 작업자용 메모: 이 문서는 Dungeon Mage 프로젝트에서 Claude용 로컬 스킬과 `CLAUDE.md`를 구성하기 위한 구현 계획입니다.

## 목표

- 로컬 프로젝트 스킬 3개를 만든다.
- 프로젝트 루트에 `CLAUDE.md`를 만든다.
- 에셋 분석용 Python 도구를 준비한다.
- Claude가 이 프로젝트에서 Godot 4.6, 설치된 애드온, 테스트 규칙을 항상 따르도록 만든다.

## 산출물

| 작업 | 경로 | 역할 |
| --- | --- | --- |
| 생성 | `.claude/skills/asset-import.md` | 에셋 분석 및 반영 스킬 |
| 생성 | `.claude/skills/godot-combat.md` | 전투 구현 규칙 스킬 |
| 생성 | `.claude/skills/spec-to-godot.md` | 문서를 구현 작업으로 변환하는 스킬 |
| 생성 | `.claude/skills/asset_analyzer.py` | 픽셀 단위 에셋 분석 도구 |
| 생성 | `CLAUDE.md` | 프로젝트 전역 지침 |

## 기본 전제

- 엔진: Godot 4.6 headless
- 보조 도구: Python 3, Pillow
- 필수 애드온: Phantom Camera, Godot State Charts, GUT
- 문서 작성 담당: Codex
- 구현 담당: Claude

## 구현 단계

### 1. `.claude/skills/`와 `CLAUDE.md` 생성

- `.claude/skills/` 디렉터리를 만든다.
- 프로젝트 루트에 `CLAUDE.md`를 만든다.
- `CLAUDE.md`에는 다음 규칙을 담는다.
- 항상 Phantom Camera를 사용한다.
- 항상 Godot State Charts를 사용한다.
- 새 동작에는 GUT 테스트를 추가한다.
- `asset_sample/`에 에셋이 추가되면 먼저 `asset-import` 스킬을 실행한다.
- Codex 문서를 구현할 때는 먼저 `spec-to-godot` 스킬을 사용한다.

### 2. `asset_analyzer.py` 작성

- PNG 크기와 프레임 후보를 계산한다.
- 첫 프레임 상단 40퍼센트 기준으로 좌우 질량 중심을 확인해 기본 방향을 추정한다.
- 캐릭터, 보스, 적, 무기, 배경별 기준 화면 크기에 맞는 스케일 값을 제안한다.
- 출력은 사람이 바로 읽을 수 있는 요약 형태로 제공한다.

### 3. `asset-import` 스킬 작성

- 대상 폴더의 PNG를 모두 찾는다.
- 스트립형인지 시트형인지 판별한다.
- 프레임 수, 프레임 크기, 방향, 스케일 후보를 계산한다.
- Godot 씬과 스크립트에 필요한 값을 바로 반영하는 절차를 안내한다.
- 마지막에 `godot --headless --path . --quit-after 120`으로 검증한다.

### 4. `godot-combat` 스킬 작성

- 플레이어와 적 상태는 Godot State Charts 기반으로 다룬다.
- 마법 유형별 구현 규칙을 정의한다.
- 액티브, 버프, 설치, 온앤오프, 패시브를 각각 어떤 방식으로 코드에 반영할지 문서화한다.
- 히트스톱, 카메라 흔들림, 데미지 숫자 같은 타격감 규칙을 정리한다.

### 5. `spec-to-godot` 스킬 작성

- Codex 문서의 `Implementation Handoff`를 실제 작업 리스트로 바꾼다.
- `Acceptance Criteria`를 GUT 테스트 초안으로 연결한다.
- 문서의 스펠 표는 `data/spells.json` 데이터 행으로 옮긴다.
- 새 기능 구현 전, 설치된 애드온 사용 여부를 먼저 확인한다.

## 검증 명령어

```bash
# 프로젝트 로딩 확인
godot --headless --path . --quit

# 짧은 런타임 확인
godot --headless --path . --quit-after 120

# 전체 GUT 테스트 실행
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

## 성공 기준

- `.claude/skills/` 아래에 3개 스킬 문서가 존재한다.
- `asset_analyzer.py`가 실행 가능하다.
- `CLAUDE.md`가 프로젝트 규칙을 명확히 담고 있다.
- Claude가 문서 기반 구현, 에셋 반영, 전투 구현 시 항상 지정된 스킬을 따를 수 있다.

## 비목표

- 전역 사용자 스킬 설치
- 파일 저장 시 자동 트리거 훅 구성
- 스킬만으로 전체 테스트 세트를 자동 생성하는 것
