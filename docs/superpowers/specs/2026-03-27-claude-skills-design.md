# Claude Code 스킬 설계 - Dungeon Mage

**작성일:** 2026-03-27  
**프로젝트:** Dungeon Mage  
**범위:** `.claude/skills/` 아래에 두는 로컬 프로젝트 스킬 설계

## 목적

이 문서는 Dungeon Mage 프로젝트에서 Claude가 일관되게 작업하도록 만드는 세 가지 로컬 스킬의 설계 기준을 정리합니다.

## 프로젝트 맥락

- 엔진: Godot 4.6 headless
- 해상도 기준: 1280 x 720
- 장르: 2D 액션 메트로베니아
- 사용 애드온: Phantom Camera, Godot State Charts, GUT
- 기획 담당: Codex
- 구현 담당: Claude

## 방지해야 할 문제

1. 캐릭터 좌우 방향 판단 오류
2. 프레임 수 계산 오류로 인한 애니메이션 깨짐
3. 캐릭터와 배경의 스케일 불일치
4. 문서와 실제 구현 간의 해석 차이

## 스킬 1: `asset-import`

### 목적

에셋을 프로젝트에 넣기 전에 PNG의 속성을 분석하고, Godot 반영에 필요한 정보를 바로 산출하는 스킬입니다.

### 처리 흐름

1. 대상 폴더의 PNG를 스캔한다.
2. 스트립형과 시트형을 판별한다.
3. 프레임 수와 프레임 크기를 추정한다.
4. 첫 프레임 상단 기준으로 기본 방향을 감지한다.
5. 캐릭터, 보스, 적, 무기, 배경에 맞는 기준 스케일을 계산한다.
6. Godot 씬과 스크립트에 필요한 값을 적용한다.
7. headless 실행으로 로딩 오류를 확인한다.

### 기준 규칙

- 모든 스프라이트는 기본적으로 오른쪽을 바라보는 기준으로 정규화한다.
- 좌측을 향하는 원본은 `flip_h`로 보정한다.
- 런타임 방향 전환은 `scale.x`를 사용한다.

## 스킬 2: `godot-combat`

### 목적

이 프로젝트의 전투 시스템을 설치된 애드온과 현재 구조에 맞게 구현하기 위한 기준 스킬입니다.

### 다루는 범위

- 상태 흐름: Idle, Walk, Jump, Fall, Cast, Hit, Dead
- 마법 유형별 구현 방식: 액티브, 버프, 설치, 온앤오프, 패시브
- 타격감 요소: 히트스톱, 화면 흔들림, 데미지 숫자
- 마나 시스템
- 스킬 숙련도와 레벨 기반 성장

### 구현 기준

- 상태 흐름은 Godot State Charts로 처리한다.
- 카메라는 Phantom Camera를 사용한다.
- 새 전투 동작은 가능한 한 GUT 테스트로 검증한다.

## 스킬 3: `spec-to-godot`

### 목적

Codex가 작성한 문서를 Claude가 바로 구현 작업으로 바꾸기 위한 번역 스킬입니다.

### 번역 규칙

| 문서 요소 | 구현 변환 결과 |
| --- | --- |
| `Implementation Handoff` | 실제 작업 항목 |
| `Likely Files Or Systems` | 수정 또는 생성할 파일 경로 |
| `Acceptance Criteria` | GUT 테스트 초안 |
| `Non-Goals` | 구현 제외 항목 |
| 스펠 표 행 | `data/spells.json` 항목 |

### 필수 점검

- 카메라 작업이 Phantom Camera를 쓰는지 확인한다.
- 상태 흐름이 Godot State Charts를 쓰는지 확인한다.
- 새 기능에 대응하는 테스트가 있는지 확인한다.

## 권장 폴더 구조

```text
data/          - 스펠, 방, 아이템 JSON
scripts/
  autoload/    - GameState, GameDatabase
  player/      - 플레이어 및 스펠 관련 코드
  enemies/     - 적 관련 코드
  world/       - 방 구성 및 상호작용 요소
  ui/          - HUD 및 UI
scenes/        - Godot 씬 파일
assets/        - 처리된 에셋
tests/         - GUT 테스트
```

## 검증 명령어

```bash
godot --headless --path . --quit
godot --headless --path . --quit-after 120
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

## 비목표

- 전역 사용자 스킬 설치
- 자동 파일 저장 훅 구성
- 스킬 자체가 모든 테스트를 자동 생성하는 구조
