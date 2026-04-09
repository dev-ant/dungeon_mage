---
title: 스킬 엑셀 리포트 생성 워크플로
doc_type: runbook
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tools/generate_skill_excel_report.py
update_when:
  - runtime_changed
  - handoff_changed
  - structure_changed
last_updated: 2026-04-06
last_verified: 2026-04-06
---

# 스킬 엑셀 리포트 생성 워크플로

상태: 사용 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목적

이 문서는 `스킬 / 서클 / 에셋 적용 상태`를 엑셀 파일로 빠르게 다시 뽑아야 할 때 사용하는 고정 워크플로다.

앞으로 같은 요청이 오면 이 문서와 [generate_skill_excel_report.py](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tools/generate_skill_excel_report.py)를 우선 사용한다.

## 기본 출력물

스크립트는 기본적으로 아래 4개 시트를 만든다.

1. `Overview`
2. `Skill_Details`
3. `Circle_Mismatch`
4. `Legacy_Candidates`

## 입력 소스

스크립트는 아래 파일을 source of truth로 읽는다.

- [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)
- [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)
- [skills.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/skills/skills.json)
- [spells.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/spells.json)
- `assets/effects/`
- `tests/test_game_state.gd`
- `tests/test_spell_manager.gd`
- `tests/test_admin_menu.gd`

## 실행 방법

프로젝트 루트에서 실행한다.

```bash
python3 tools/generate_skill_excel_report.py
```

출력 파일명을 직접 지정하고 싶으면 아래처럼 실행한다.

```bash
python3 tools/generate_skill_excel_report.py \
  --output skill_circle_asset_report_custom.xlsx
```

다른 위치에서 실행할 때는 프로젝트 루트를 명시한다.

```bash
python3 /absolute/path/to/tools/generate_skill_excel_report.py \
  --project-root /absolute/path/to/dungeon_mage \
  --output /absolute/path/to/output.xlsx
```

## 빠른 응답용 요청 템플릿

아래 표현이 들어오면 이 워크플로를 바로 적용한다.

- `스킬 구현 상태를 엑셀로 정리해줘`
- `써클별 스킬/에셋 현황 엑셀로 만들어줘`
- `문서-코드-에셋 불일치까지 포함해서 xlsx로 뽑아줘`

## 출력 해석 규칙

- `design_circle`: 최신 기획 문서 기준 서클
- `tracker_circle`: 운영 추적표 기준 서클
- `data_circle`: 실제 `skills.json` 기준 서클
- `circle_match_tracker_vs_data = N`: 지금 바로 확인할 가치가 큰 불일치
- `runtime_reference`: 실제 시전 런타임 또는 프록시 참조
- `asset_folders`: 현재 코드/폴더 기준으로 찾은 연결 가능 에셋 디렉토리
- `test_reference = Y`: 관련 테스트 파일에서 스킬 ID 또는 런타임 참조가 확인됨

## 운영 메모

- 이 스크립트는 표준 라이브러리만 사용한다. `openpyxl`, `xlsxwriter`, `pandas`가 없어도 동작한다.
- 새 시트를 추가하거나 열 구성을 바꿀 때는 스크립트와 이 문서를 같은 턴에 같이 갱신한다.
- 엑셀 내용이 문서와 다르면 우선 코드/데이터와 tracker를 다시 확인하고, 그다음 이 runbook을 수정한다.
