# Godot MCP 서버 설정 가이드

상태: 설치 완료
최종 갱신: 2026-03-28
섹션: 개발 환경

---

## 설치한 MCP

| 항목 | 내용 |
|------|------|
| **이름** | `@coding-solo/godot-mcp` |
| **저장소** | https://github.com/Coding-Solo/godot-mcp |
| **npm 패키지** | `@coding-solo/godot-mcp` v0.1.1 |
| **라이선스** | MIT |
| **선택 이유** | stars 2,679 (가장 신뢰도 높음), headless 호환, 프로젝트 코드 수정 불필요, Claude Code 공식 통합 방법 문서화 |

---

## 설치 위치 및 설정 파일

### 설정 파일

`.mcp.json` (프로젝트 루트 — `res://` 기준 `/`)

```json
{
  "mcpServers": {
    "godot": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@coding-solo/godot-mcp"],
      "env": {
        "GODOT_PATH": "/opt/homebrew/bin/godot"
      }
    }
  }
}
```

- **스코프**: `project` (`.mcp.json` — 저장소에 포함, 팀 공유 가능)
- **npx `-y`**: 매번 패키지 설치 확인 없이 자동 실행
- **GODOT_PATH**: Homebrew로 설치된 Godot 4.6.1 바이너리 경로

### 패키지 캐시

npx가 처음 실행 시 `~/.npm/_npx/` 또는 npm cache에 자동 저장된다. 별도 전역 설치 없음.

---

## Claude Code 연결 방법

`.mcp.json`이 프로젝트 루트에 있으면 Claude Code가 이 디렉토리에서 세션을 시작할 때 자동으로 서버를 기동한다.

### 현재 상태 확인

```bash
claude mcp list
# 출력: godot: npx -y @coding-solo/godot-mcp - ✓ Connected
```

### 서버 상세 확인

```bash
claude mcp get godot
```

---

## 제공하는 도구 (툴 목록)

| 툴 이름 | 기능 |
|---------|------|
| `get_godot_version` | 설치된 Godot 바이너리 버전 확인 |
| `list_projects` | 지정 디렉토리 내 `project.godot` 파일 탐색 |
| `get_project_info` | 프로젝트 구조(씬, 스크립트, 에셋 목록) 반환 |
| `run_project` | Godot 프로젝트 실행 (debug 모드) |
| `get_debug_output` | 실행 중인 프로젝트의 stdout/stderr 캡처 |
| `stop_project` | 실행 중인 프로젝트 종료 |
| `launch_editor` | Godot 에디터 GUI 실행 |
| `create_scene` | 지정 루트 노드 타입으로 `.tscn` 파일 생성 |
| `add_node` | 기존 씬에 노드 추가 (속성 포함) |
| `load_sprite` | Sprite2D에 텍스처 로드 |
| `save_scene` | 씬 저장/변형 |
| `get_uid` | Godot 4.4+ UID 조회 |
| `update_project_uids` | 프로젝트 UID 일괄 갱신 |

> **중요**: 툴은 새 Claude Code 세션 시작 시 로드된다. 현재 세션에서 MCP를 처음 추가했다면 세션을 재시작해야 툴 목록이 보인다.

---

## 현재 프로젝트에서 추천하는 사용 방식

### 씬 작업

`create_scene`, `add_node`, `save_scene`을 조합해 `Player.tscn`, `Enemy.tscn` 등 씬 파일을 Claude Code가 직접 생성하고 노드를 구성할 수 있다.

```
# 예시: Claude Code가 Player 씬을 MCP로 생성
create_scene("scenes/player/Player.tscn", root_type="CharacterBody2D")
add_node("scenes/player/Player.tscn", "Sprite2D", parent="/root")
add_node("scenes/player/Player.tscn", "CollisionShape2D", parent="/root")
```

### 프로젝트 구조 파악

```
get_project_info(project_path=".")
```

씬 목록, 스크립트 파일 구조를 한 번에 파악할 때 유용하다.

### 실행/디버그 출력 캡처

```
run_project(project_path=".", scene="res://scenes/admin/AdminMap.tscn")
get_debug_output()
stop_project()
```

---

## 실패 시 점검 포인트

| 증상 | 점검 사항 |
|------|-----------|
| `npx: command not found` | Node.js가 설치되어 있는지 확인. `which node` |
| `Using Godot at: godot` (경로 없음) | `.mcp.json`의 `GODOT_PATH` 값 확인. 절대 경로여야 함 |
| `✗ Failed` (mcp list) | `npx -y @coding-solo/godot-mcp` 수동 실행으로 오류 확인 |
| 툴이 Claude 세션에서 안 보임 | 세션 재시작 필요. MCP는 세션 시작 시 로드됨 |
| Godot 씬 조작 실패 | Godot 4.6.1 바이너리가 `GODOT_PATH`에 실제로 있는지 확인 |
| `.mcp.json` 신뢰 확인 팝업 | Claude Code가 project MCP 사용 허가를 요청 — 허용 선택 |

---

## headless 검증이 여전히 정상 동작하는지

MCP 설치는 프로젝트 코드에 일절 영향을 주지 않는다. 기존 headless 명령은 그대로 유효하다.

```bash
# 스타트업 체크
godot --headless --path . --quit

# 런타임 체크
godot --headless --path . --quit-after 120

# GUT 테스트
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

---

## 추천 프롬프트 예시

### 예시 1 — 씬 생성 자동화

```
Godot MCP를 사용해서 scripts/player/player.gd에 있는 Player 로직에 맞는
Player.tscn을 scenes/player/ 에 생성해줘.
CharacterBody2D 루트 노드에 Sprite2D, CollisionShape2D, PhantomCamera2D 자식을
달고, player.gd 스크립트를 루트에 attach해줘.
```

→ MCP의 `create_scene`, `add_node`, `save_scene` 툴을 연속으로 사용.

---

### 예시 2 — 프로젝트 씬 구조 파악

```
Godot MCP로 현재 프로젝트의 씬과 스크립트 목록을 가져와서,
scenes/ 폴더에 아직 없는 씬이 무엇인지 scripts/ 폴더와 비교해서 알려줘.
```

→ MCP의 `get_project_info`로 실제 파일 트리를 가져와 누락된 씬 파악.

---

### 예시 3 — 에셋 임포트 후 씬 연결

```
asset_sample/Character/ 에 있는 플레이어 스프라이트시트를 분석하고,
asset-import 스킬로 처리한 뒤 Godot MCP를 사용해서
scenes/player/Player.tscn의 Sprite2D에 해당 텍스처를 load_sprite로 연결해줘.
```

→ asset-import 스킬 + MCP `load_sprite` 툴의 조합.

---

## Godot MCP 제거 방법

```bash
claude mcp remove godot -s project
# .mcp.json에서 해당 항목이 제거된다
```
