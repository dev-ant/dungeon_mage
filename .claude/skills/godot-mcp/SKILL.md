---
name: godot-mcp
description: Use when inspecting Godot project structure, creating or modifying .tscn scene files, adding nodes, running the project, or capturing debug output. Also use when connecting sprites to Sprite2D nodes or resolving UID mismatches.
---

# Godot MCP Skill

## 이 스킬을 쓰는 경우

다음 중 하나라도 해당하면 이 스킬을 먼저 적용한다.

- 씬 파일(`.tscn`)을 생성하거나 노드를 추가할 때
- 프로젝트 구조(씬·스크립트 목록)를 파악할 때
- Godot 프로젝트를 실행하거나 런타임 출력을 캡처할 때
- 기존 씬에 텍스처/스프라이트를 연결할 때
- UID 불일치나 씬 저장 오류를 디버깅할 때

## 역할 분담 (다른 스킬과의 구분)

| 스킬 | 담당 |
|------|------|
| `godot-mcp` | **언제/어떻게** MCP 툴을 사용할지 — 씬 조작, 실행, 디버그 |
| `godot-combat` | **무엇을** 쓸지 — 전투 코드 패턴, 상태 전이, 히트필 |
| `spec-to-godot` | 설계 문서 → 구현 태스크 변환 |
| `asset-import` | 스프라이트 분석 및 Godot 임포트 설정 |

## Step 0 — MCP 연결 확인

작업 시작 전 MCP 상태를 확인한다.

```bash
claude mcp list
# 출력 예: godot: npx -y @coding-solo/godot-mcp - ✓ Connected
```

`✓ Connected`이면 MCP-first 워크플로우를 따른다.
`✗ Failed` 또는 툴이 없으면 **Fallback** 섹션으로 이동한다.

---

## MCP-First 워크플로우

### Step 1 — 구조 파악 (항상 첫 번째)

씬이나 스크립트를 수정하기 전에 반드시 현재 프로젝트 상태를 가져온다.

```
get_project_info(project_path=".")
```

반환값에서 확인:
- 이미 존재하는 씬 파일 경로
- 스크립트 파일 목록
- 에셋 디렉토리 구조

> **dungeon_mage 예시**: `scripts/player/player.gd`가 있지만 `scenes/player/Player.tscn`이 없다면 씬 생성 단계로 진행.

### Step 2 — 씬 생성 (새 씬이 필요할 때)

```
create_scene("scenes/player/Player.tscn", root_type="CharacterBody2D")
add_node("scenes/player/Player.tscn", "Sprite2D", parent="/root")
add_node("scenes/player/Player.tscn", "CollisionShape2D", parent="/root")
add_node("scenes/player/Player.tscn", "PhantomCamera2D", parent="/root")
save_scene("scenes/player/Player.tscn")
```

규칙:
- 루트 노드 타입은 스크립트의 `extends` 값과 일치시킨다
- 카메라는 반드시 `PhantomCamera2D` (raw `Camera2D` 금지 — CLAUDE.md 규정)
- `save_scene` 없이 종료하지 않는다

### Step 3 — 런타임 검증

씬 수정 후 바로 실행해서 출력을 확인한다.

```
run_project(project_path=".", scene="res://scenes/admin/AdminMap.tscn")
# 2~5초 대기
get_debug_output()
stop_project()
```

출력에서 확인:
- `ERROR:` / `SCRIPT ERROR:` 없음
- 예상한 `print()` 출력 존재
- GUT 실행이면 `PASSED` / `FAILED` 카운트

### Step 4 — UID 이슈 발생 시

씬 참조 오류나 UID 불일치 경고가 나오면:

```
get_uid(path="res://scenes/player/Player.tscn")
update_project_uids(project_path=".")
```

---

## MCP 툴 우선순위 요약

| 우선순위 | 툴 | 사용 시점 |
|---------|-----|----------|
| 1 | `get_project_info` | 모든 작업의 첫 번째 단계 |
| 2 | `create_scene` | 새 `.tscn` 파일 생성 |
| 3 | `add_node` | 씬에 노드 추가 |
| 4 | `save_scene` | 씬 변경 사항 저장 |
| 5 | `run_project` + `get_debug_output` | 런타임 동작 확인 |
| 6 | `load_sprite` | Sprite2D에 텍스처 연결 |
| 7 | `stop_project` | 실행 종료 |
| 8 | `get_uid` / `update_project_uids` | UID 불일치 수정 |

---

## Fallback — MCP 사용 불가 시

MCP가 `✗ Failed`이거나 툴 목록이 비어 있을 때 파일 툴로 대체한다.

| MCP 툴 | Fallback |
|--------|----------|
| `get_project_info` | `Glob("**/*.tscn")` + `Glob("**/*.gd")` |
| `create_scene` / `add_node` | `Write` / `Edit` 로 `.tscn` 직접 편집 |
| `run_project` + `get_debug_output` | 아래 headless 명령 |
| `load_sprite` | `.tscn` 파일의 `texture = ExtResource(...)` 직접 수정 |

`.tscn` 직접 편집 시 주의:
- `ExtResource` ID 충돌 방지 — 기존 파일의 최대 ID + 1 사용
- `[node name=...]` 들여쓰기 규칙 준수
- `save_scene` 대신 `Write`로 전체 파일 저장

---

## Headless 검증 명령

모든 씬/스크립트 작업 완료 후 순서대로 실행한다.

```bash
# 1. 스타트업 체크 (파싱 오류, 씬 로드 오류)
godot --headless --path . --quit

# 2. 런타임 체크 (120초 내 크래시 없음)
godot --headless --path . --quit-after 120

# 3. GUT 테스트 전체
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

셋 다 오류 없이 통과해야 커밋 가능하다.

---

## 문서-구현 동기화 원칙

씬이나 스크립트를 추가/수정할 때마다:

1. `docs/implementation/` 하위의 관련 increment 문서를 찾는다
2. 완료된 항목을 체크 또는 제거한다
3. 새로 발견된 미구현 항목을 pending 테이블에 추가한다
4. `combat_first_build_plan.md`의 해당 행을 갱신한다

> 문서와 구현이 일치하지 않으면 다음 작업자(또는 다음 세션)가 중복 작업을 한다.

---

## 작은 안전 증분 원칙

- 한 번에 하나의 씬 또는 하나의 기능 단위만 수정한다
- 각 단계 후 headless startup check를 통과하면 진행한다
- 실패하면 직전 변경만 되돌린다 (전체 롤백 금지)
- GUT 테스트는 기능 추가 전에 먼저 스텁을 작성하고, 구현 후 통과시킨다

---

## dungeon_mage 프로젝트 예시

### 예시 1 — 플레이어 씬 생성

```
# 1. 구조 파악
get_project_info(project_path=".")
# → scripts/player/player.gd 있음, scenes/player/Player.tscn 없음

# 2. 씬 생성
create_scene("scenes/player/Player.tscn", root_type="CharacterBody2D")
add_node("scenes/player/Player.tscn", "Sprite2D", parent="/root")
add_node("scenes/player/Player.tscn", "CollisionShape2D", parent="/root")
add_node("scenes/player/Player.tscn", "PhantomCamera2D", parent="/root")
save_scene("scenes/player/Player.tscn")

# 3. 런타임 확인
run_project(project_path=".", scene="res://scenes/player/Player.tscn")
get_debug_output()
stop_project()

# 4. GUT 통과
# godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

### 예시 2 — 적 씬 디버그

```
# AdminMap에서 적이 spawn되지 않는 문제 확인
run_project(project_path=".", scene="res://scenes/admin/AdminMap.tscn")
get_debug_output()
# → "ERROR: EnemyBase: node path 'AnimatedSprite2D' is invalid" 발견
stop_project()

# 씬에 AnimatedSprite2D 누락 확인
get_project_info(project_path=".")
# → scenes/enemies/ 없음

# 씬 생성 후 재검증
create_scene("scenes/enemies/SlimeDreg.tscn", root_type="CharacterBody2D")
add_node("scenes/enemies/SlimeDreg.tscn", "AnimatedSprite2D", parent="/root")
save_scene("scenes/enemies/SlimeDreg.tscn")
```

### 예시 3 — 스프라이트 연결 (asset-import 이후)

```
# asset-import 스킬로 처리된 텍스처를 씬에 연결
load_sprite(
    scene_path="scenes/player/Player.tscn",
    node_path="/root/Sprite2D",
    texture_path="res://assets/player/player_sheet.png"
)
save_scene("scenes/player/Player.tscn")
```

---

## 점검 체크리스트

- [ ] `claude mcp list`에서 godot `✓ Connected` 확인
- [ ] 씬 작업 전 `get_project_info` 호출
- [ ] 씬 생성 시 PhantomCamera2D 사용 (raw Camera2D 금지)
- [ ] 모든 씬 변경 후 `save_scene` 호출
- [ ] headless startup check 통과
- [ ] GUT 테스트 전체 통과
- [ ] 관련 docs/implementation/ 문서 갱신 완료
